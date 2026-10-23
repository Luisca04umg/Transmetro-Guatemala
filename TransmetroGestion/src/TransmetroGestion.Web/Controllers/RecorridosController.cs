using System.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
using TransmetroGestion.Web.Services;
namespace TransmetroGestion.Web.Controllers;

[Authorize(Policy = "ALERTAS_GESTIONAR")]
public class RecorridosController(TransmetroDbContext db, RecorridosService recorridos) : Controller
{
    public async Task<IActionResult> Index(int? lineaID,string seccion="seguimiento")
    {
        string[] opciones=["seguimiento","asignar","iniciar","pilotos","alertas","esperas","conteo","historial","tiempos","recorridos"];
        var vm=await recorridos.ConsultarAsync(true,lineaID);
        vm.Seccion=opciones.Contains(seccion)?seccion:"seguimiento";
        return View(vm);
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> AsignarPiloto(int lineaID,int busID, int pilotoID)
    {
        return await Ejecutar(lineaID,async () =>
        {
            if(!await db.LineasBuses.AnyAsync(x=>x.BusID==busID&&x.LineaID==lineaID))throw new InvalidOperationException("El bus no está asignado a la línea seleccionada.");
            var bus = await db.Buses.SingleOrDefaultAsync(x => x.BusID == busID);
            var piloto = await db.Pilotos.SingleOrDefaultAsync(x => x.PilotoID == pilotoID && x.Activo);
            if (bus is null || bus.Estado != "DISPONIBLE" || piloto is null || piloto.FechaVencimientoLicencia < DateOnly.FromDateTime(DateTime.UtcNow))
                throw new InvalidOperationException("Seleccione bus disponible y piloto activo con licencia vigente.");
            if (await db.Viajes.AnyAsync(x => (x.BusID == busID || x.PilotoID == pilotoID) && x.Estado == "EN_CURSO"))
                throw new InvalidOperationException("No cambie la asignación durante un recorrido en curso.");
            if (await db.AsignacionesPilotoBus.AnyAsync(x => x.PilotoID == pilotoID && x.BusID != busID && x.FechaFin == null))
                throw new InvalidOperationException("El piloto ya está asignado a otro bus.");
            var anteriores = await db.AsignacionesPilotoBus.Where(x => x.BusID == busID && x.FechaFin == null).ToListAsync();
            foreach (var x in anteriores) x.FechaFin = DateTime.UtcNow;
            await db.SaveChangesAsync();
            db.AsignacionesPilotoBus.Add(new AsignacionPilotoBus { BusID = busID, PilotoID = pilotoID, FechaInicio = DateTime.UtcNow });
            await db.SaveChangesAsync();
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Iniciar(int lineaID,int busID)
    {
        return await Ejecutar(lineaID,async () =>
        {
            if(!await db.Lineas.AnyAsync(x=>x.LineaID==lineaID&&x.Estado=="A"))throw new InvalidOperationException("Active la línea antes de iniciar un recorrido.");
            var bus = await db.Buses.SingleOrDefaultAsync(x => x.BusID == busID && x.Estado == "DISPONIBLE")
                ?? throw new InvalidOperationException("El bus debe estar disponible.");
            var linea = await db.LineasBuses.SingleOrDefaultAsync(x => x.BusID == busID && x.LineaID == lineaID)
                ?? throw new InvalidOperationException("Asigne el bus a la línea seleccionada en Rutas y flota.");
            var asignacion = await db.AsignacionesPilotoBus.SingleOrDefaultAsync(x => x.BusID == busID && x.FechaFin == null)
                ?? throw new InvalidOperationException("Asigne un piloto al bus primero.");
            var piloto = await db.Pilotos.SingleAsync(x => x.PilotoID == asignacion.PilotoID);
            if (!piloto.Activo || piloto.FechaVencimientoLicencia < DateOnly.FromDateTime(DateTime.UtcNow))
                throw new InvalidOperationException("El piloto debe estar activo y tener licencia vigente.");
            if (await db.Viajes.AnyAsync(x => (x.BusID == busID || x.PilotoID == piloto.PilotoID) && x.Estado == "EN_CURSO"))
                throw new InvalidOperationException("El bus o piloto ya tienen un recorrido en curso.");
            var ruta = await db.LineasEstaciones.Where(x => x.LineaID == linea.LineaID).OrderBy(x => x.Orden).ToListAsync();
            var estaciones=await db.Estaciones.Where(x=>ruta.Select(r=>r.EstacionID).Contains(x.EstacionID)).ToListAsync();
            var estados=estaciones.ToDictionary(x=>x.EstacionID,x=>x.Estado);
            if(ruta.Count(x=>estados.GetValueOrDefault(x.EstacionID)=="A")<2)throw new InvalidOperationException("La línea necesita al menos dos estaciones activas. Active las estaciones o espere el fin del mantenimiento.");
            var viaje = new Viaje { LineaID = linea.LineaID, BusID = busID, PilotoID = piloto.PilotoID, FechaSalida = DateTime.UtcNow, Estado = "EN_CURSO" };
            db.Viajes.Add(viaje);
            bus.Estado = "EN_RUTA";
            await db.SaveChangesAsync();
            db.VisitasEstacionViaje.AddRange(RecorridoReglas.Planificar(viaje.ViajeID,ruta,estados,viaje.FechaSalida));
            await db.SaveChangesAsync();
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> RegistrarPaso(int lineaID,long viajeID, string evento)
    {
        return await Ejecutar(lineaID,async () =>
        {
            var viaje = await db.Viajes.SingleOrDefaultAsync(x => x.ViajeID == viajeID && x.LineaID == lineaID && x.Estado == "EN_CURSO")
                ?? throw new InvalidOperationException("El recorrido no está en curso.");
            var visitas = await db.VisitasEstacionViaje.Where(x => x.ViajeID == viajeID).OrderBy(x => x.OrdenVisita).ToListAsync();
            var actual = RecorridoReglas.Siguiente(visitas)
                ?? throw new InvalidOperationException("No quedan estaciones pendientes.");
            var ahora = DateTime.UtcNow;
            if (evento == "LLEGADA" && actual.LlegadaReal == null)
            {
                actual.LlegadaReal = ahora;
                if (actual.LlegadaProgramada.HasValue)
                {
                    var retraso = ahora - actual.LlegadaProgramada.Value;
                    foreach (var v in visitas.Where(x => x.OrdenVisita > actual.OrdenVisita && x.LlegadaProgramada.HasValue))
                        v.LlegadaProgramada = v.LlegadaProgramada!.Value + retraso;
                }
            }
            else if (evento == "SALIDA" && actual.LlegadaReal.HasValue)
            {
                if (!await db.RegistrosParadaViaje.AnyAsync(x => x.ViajeID == viajeID && x.EstacionID == actual.EstacionID))
                    throw new InvalidOperationException("Registre primero cuántos subieron, bajaron y quedaron esperando en la estación.");
                var ocupacion = await db.RegistrosOcupacionBus.Where(x => x.ViajeID == viajeID && x.EstacionID == actual.EstacionID).OrderByDescending(x => x.FechaRegistro).FirstOrDefaultAsync();
                if (ocupacion is not null && ocupacion.PorcentajeOcupacion < 25 && ahora < ocupacion.FechaRegistro.AddMinutes(5))
                    throw new InvalidOperationException("La ocupación es menor al 25 %: espere al menos cinco minutos desde el conteo.");
                if (ocupacion is not null && ocupacion.PorcentajeOcupacion < 25)
                {
                    var espera = await db.EsperasAdicionales.SingleOrDefaultAsync(x => x.RegistroOcupacionID == ocupacion.RegistroOcupacionID);
                    if (espera is not null) { espera.Aplicada = true; espera.FechaAplicacion = ahora; }
                }
                actual.SalidaReal = ahora;
                var demora = ahora - actual.LlegadaReal.Value;
                foreach (var v in visitas.Where(x => x.OrdenVisita > actual.OrdenVisita && x.LlegadaProgramada.HasValue))
                    v.LlegadaProgramada = v.LlegadaProgramada!.Value + demora;
                if (!visitas.Any(x=>!x.OmitidaMantenimiento&&x.SalidaReal==null))
                {
                    viaje.Estado = "FINALIZADO"; viaje.FechaLlegada = ahora;
                    (await db.Buses.SingleAsync(x => x.BusID == viaje.BusID)).Estado = "DISPONIBLE";
                }
            }
            else throw new InvalidOperationException("Registre primero la llegada y después la salida, respetando el orden.");
            await db.SaveChangesAsync();
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> RegistrarPasajeros(int lineaID,long viajeID, int estacionID, short suben, short bajan, int esperanEstacion)
    {
        return await Ejecutar(lineaID,async () =>
        {
            var viaje = await db.Viajes.SingleOrDefaultAsync(x => x.ViajeID == viajeID && x.LineaID == lineaID && x.Estado == "EN_CURSO")
                ?? throw new InvalidOperationException("El recorrido no está en curso.");
            var actual = await db.VisitasEstacionViaje.Where(x => x.ViajeID == viajeID && !x.OmitidaMantenimiento && x.SalidaReal == null).OrderBy(x => x.OrdenVisita).FirstOrDefaultAsync();
            if (actual is null || actual.EstacionID != estacionID || actual.LlegadaReal is null)
                throw new InvalidOperationException("Registre la llegada a la estación actual antes del conteo.");
            if (await db.RegistrosParadaViaje.AnyAsync(x => x.ViajeID == viajeID && x.EstacionID == estacionID))
                throw new InvalidOperationException("Esta parada ya tiene su conteo registrado.");
            var ultimo = await db.RegistrosParadaViaje.Where(x => x.ViajeID == viajeID).OrderByDescending(x => x.RegistroParadaID).FirstOrDefaultAsync();
            int antes = ultimo?.PasajerosDespues ?? 0;
            var bus = await db.Buses.SingleAsync(x => x.BusID == viaje.BusID);
            int despues = antes - bajan + suben;
            if (suben < 0 || bajan < 0 || esperanEstacion < 0 || bajan > antes || despues > bus.CapacidadMaxima)
                throw new InvalidOperationException($"Conteo inválido. Antes de la parada hay {antes} pasajeros; la capacidad es {bus.CapacidadMaxima}.");
            db.RegistrosParadaViaje.Add(new RegistroParadaViaje { ViajeID = viajeID, EstacionID = estacionID,
                PasajerosAntes = (short)antes, Suben = suben, Bajan = bajan, PasajerosDespues = (short)despues,
                EsperanEstacion = esperanEstacion, FechaRegistro = DateTime.UtcNow });
            await db.SaveChangesAsync();
            int? operador = await db.AsignacionesOperadorEstacion.Where(x => x.EstacionID == estacionID && x.FechaFin == null)
                .OrderByDescending(x => x.FechaInicio).Select(x => (int?)x.OperadorID).FirstOrDefaultAsync();
            await db.Database.ExecuteSqlInterpolatedAsync($"EXEC ops.sp_RegistrarConteoEstacion @EstacionID={estacionID}, @CantidadPasajeros={esperanEstacion}, @OperadorID={operador}, @LineaID={lineaID}");
            await db.Database.ExecuteSqlInterpolatedAsync($"EXEC ops.sp_RegistrarOcupacionBus @BusID={viaje.BusID}, @EstacionID={estacionID}, @CantidadPasajeros={(short)despues}, @ViajeID={viajeID}");
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> ConfigurarTiempo(int lineaID, int estacionID, short minutos)
    {
        return await Ejecutar(lineaID,async () =>
        {
            if (minutos < 0) throw new InvalidOperationException("El tiempo no puede ser negativo.");
            var tramo = await db.LineasEstaciones.SingleAsync(x => x.LineaID == lineaID && x.EstacionID == estacionID);
            tramo.TiempoMinuto = minutos;
            await db.SaveChangesAsync();
        });
    }

    private async Task<IActionResult> Ejecutar(int lineaID,Func<Task> operacion)
    {
        try
        {
            if (!ModelState.IsValid)
                throw new InvalidOperationException("Revise los datos: " + string.Join("; ", ModelState.Where(x => x.Value!.Errors.Count > 0).Select(x => x.Key + " " + x.Value!.Errors[0].ErrorMessage)));
            await db.Database.CreateExecutionStrategy().ExecuteAsync(async () =>
            {
                db.ChangeTracker.Clear();
                await using var tx = await db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
                await operacion();
                await tx.CommitAsync();
            });
            TempData["Exito"] = "Registro actualizado correctamente.";
        }
        catch (Exception ex) { TempData["Error"] = ex.GetBaseException().Message; }
        var accion=RouteData.Values["action"] as string;
        string seccion=accion==nameof(ConfigurarTiempo)?"tiempos":accion==nameof(AsignarPiloto)?"asignar":"seguimiento";
        return RedirectToAction(nameof(Index),new{lineaID,seccion});
    }
}
