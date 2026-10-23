using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
namespace TransmetroGestion.Web.Services;

public class RecorridosService(TransmetroDbContext db)
{
    public async Task<RecorridosVm> ConsultarAsync(bool personal = false, int? lineaID = null)
    {
        var vm = new RecorridosVm
        {
            Lineas = await db.Lineas.AsNoTracking().OrderBy(x => x.Nombre).ToListAsync(),
            LineaSeleccionada = lineaID
        };
        // Ningún dato operativo se carga antes de seleccionar una línea válida.
        if (lineaID is null || !vm.Lineas.Any(x => x.LineaID == lineaID)) return vm;
        var ruta = await db.LineasEstaciones.AsNoTracking().Where(x => x.LineaID == lineaID).OrderBy(x => x.Orden).ToListAsync();
        var estacionesLinea = ruta.Select(x => x.EstacionID).ToList();
        var busesLinea = await db.LineasBuses.Where(x => x.LineaID == lineaID).Select(x => x.BusID).ToListAsync();
        var viajes = await db.Viajes.AsNoTracking().Where(x => x.LineaID == lineaID)
            .OrderByDescending(x => x.Estado == "EN_CURSO").ThenByDescending(x => x.ViajeID).Take(100).ToListAsync();
        var ids = viajes.Select(x => x.ViajeID).ToList();
        vm.Visitas = await db.VisitasEstacionViaje.AsNoTracking().Where(x => ids.Contains(x.ViajeID)).OrderBy(x => x.OrdenVisita).ToListAsync();
        var estacionesConsulta = estacionesLinea.Concat(vm.Visitas.Select(x => x.EstacionID)).Distinct().ToList();
        var busesConsulta = busesLinea.Concat(viajes.Select(x => x.BusID)).Distinct().ToList();
        vm.Buses = await db.Buses.AsNoTracking().Where(x => busesConsulta.Contains(x.BusID)).OrderBy(x => x.CodigoInterno).ToListAsync();
        vm.Estaciones = await db.Estaciones.AsNoTracking().Where(x => estacionesConsulta.Contains(x.EstacionID)).ToListAsync();
        vm.Ruta = ruta;
        vm.Viajes = viajes;
        if (!personal) return vm;
        vm.BusesDisponibles = vm.Buses.Where(x => busesLinea.Contains(x.BusID) && x.Estado == "DISPONIBLE").ToList();
        vm.Asignaciones = await db.AsignacionesPilotoBus.AsNoTracking().Where(x => busesLinea.Contains(x.BusID) && x.FechaFin == null).ToListAsync();
        var pilotosRelacionados = vm.Asignaciones.Select(x => x.PilotoID).Concat(viajes.Where(x => x.PilotoID.HasValue).Select(x => x.PilotoID!.Value)).Distinct().ToList();
        vm.Pilotos = await db.Pilotos.AsNoTracking().Where(x => pilotosRelacionados.Contains(x.PilotoID)).ToListAsync();
        var hoy = DateOnly.FromDateTime(DateTime.UtcNow);
        vm.PilotosDisponibles = await db.Pilotos.AsNoTracking().Where(x => x.Activo && x.FechaVencimientoLicencia >= hoy
            && !db.Viajes.Any(v => v.PilotoID == x.PilotoID && v.Estado == "EN_CURSO")
            && !db.AsignacionesPilotoBus.Any(a => a.PilotoID == x.PilotoID && a.FechaFin == null))
            .OrderBy(x => x.Apellidos).ToListAsync();
        vm.Paradas = await db.RegistrosParadaViaje.AsNoTracking().Where(x => ids.Contains(x.ViajeID)).ToListAsync();
        var ocupacionesLinea = db.RegistrosOcupacionBus.Where(r =>
            (r.ViajeID != null && db.Viajes.Any(v => v.ViajeID == r.ViajeID && v.LineaID == lineaID))
            || (r.ViajeID == null && busesLinea.Contains(r.BusID) && estacionesLinea.Contains(r.EstacionID))).Select(r => r.RegistroOcupacionID);
        vm.Operacion = new OperacionVm
        {
            LineaSeleccionada = lineaID,
            Estaciones = vm.Estaciones.Where(x => estacionesLinea.Contains(x.EstacionID) && x.Estado == "A").OrderBy(x => x.Nombre).ToList(),
            Operadores = await db.Operadores.AsNoTracking().Where(x => x.Activo && db.AsignacionesOperadorEstacion.Any(a => a.OperadorID == x.OperadorID && a.FechaFin == null && estacionesLinea.Contains(a.EstacionID))).ToListAsync(),
            Alertas = await (from a in db.VistaAlertasPendientes.AsNoTracking()
                join alerta in db.AlertasOcupacion on a.AlertaID equals alerta.AlertaID
                join c in db.ConteosEstacion on alerta.ConteoEstacionID equals c.ConteoEstacionID
                where c.LineaID == lineaID || (c.LineaID == null && estacionesLinea.Contains(c.EstacionID))
                orderby a.FechaGeneracion descending select a).ToListAsync(),
            Esperas = await db.EsperasAdicionales.AsNoTracking().Where(x => ocupacionesLinea.Contains(x.RegistroOcupacionID)).OrderByDescending(x => x.FechaIndicacion).Take(100).ToListAsync()
        };
        return vm;
    }
}
