using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
using TransmetroGestion.Web.Services;

namespace TransmetroGestion.Web.Controllers;

[Authorize(Policy = "ALERTAS_GESTIONAR")]
public class OperacionController : Controller
{
    private readonly TransmetroDbContext _db;
    private readonly DatabaseSessionService _session;

    public OperacionController(TransmetroDbContext db, DatabaseSessionService session)
    {
        _db = db;
        _session = session;
    }

    public IActionResult Index(int? lineaID) => RedirectToAction("Index", "Recorridos",new{lineaID});

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> RegistrarConteo(int lineaID,int estacionID, int cantidadPasajeros, int? operadorID)
    {
        try
        {
            if(!ModelState.IsValid||!await _db.LineasEstaciones.AnyAsync(x=>x.LineaID==lineaID&&x.EstacionID==estacionID)
                || !await _db.Estaciones.AnyAsync(x=>x.EstacionID==estacionID&&x.Estado=="A"))throw new InvalidOperationException("Seleccione una estación activa de esta línea.");
            if(operadorID.HasValue&&!await _db.AsignacionesOperadorEstacion.AnyAsync(x=>x.OperadorID==operadorID&&x.EstacionID==estacionID&&x.FechaFin==null))throw new InvalidOperationException("El operador no está asignado a esta estación.");
            await _session.EjecutarAsync(() => _db.Database.ExecuteSqlInterpolatedAsync(
                $"EXEC ops.sp_RegistrarConteoEstacion @EstacionID={estacionID}, @CantidadPasajeros={cantidadPasajeros}, @OperadorID={operadorID}, @LineaID={lineaID}"));
            Exito("Conteo registrado. La base generó la alerta automáticamente si alcanzó el 150 %.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction("Index","Recorridos",new{lineaID,seccion=RouteData.Values["action"] as string==nameof(AtenderAlerta)?"alertas":RouteData.Values["action"] as string==nameof(AplicarEspera)?"esperas":"conteo"});
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> RegistrarOcupacionBus(int lineaID,int busID, int estacionID, short cantidadPasajeros, long? viajeID)
    {
        try
        {
            if(!await _db.LineasBuses.AnyAsync(x=>x.BusID==busID&&x.LineaID==lineaID))throw new InvalidOperationException("El bus no pertenece a la línea seleccionada.");
            if (!ModelState.IsValid) throw new InvalidOperationException("Revise las cantidades ingresadas.");
            if (viajeID.HasValue && !await _db.Viajes.AnyAsync(x => x.ViajeID == viajeID && x.BusID == busID && x.LineaID == lineaID))
                throw new InvalidOperationException("El recorrido no existe o no corresponde al bus. Registre los pasajeros desde la parada del recorrido activo.");
            if (viajeID.HasValue && !await _db.VisitasEstacionViaje.AnyAsync(x => x.ViajeID == viajeID && x.EstacionID == estacionID))
                throw new InvalidOperationException("La estación no pertenece al recorrido.");
            await _session.EjecutarAsync(() => _db.Database.ExecuteSqlInterpolatedAsync(
                $"EXEC ops.sp_RegistrarOcupacionBus @BusID={busID}, @EstacionID={estacionID}, @CantidadPasajeros={cantidadPasajeros}, @ViajeID={viajeID}"));
            Exito("Ocupación registrada. Si fue menor al 25 %, se indicó una espera adicional de 5 minutos.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction("Index","Recorridos",new{lineaID,seccion=RouteData.Values["action"] as string==nameof(AtenderAlerta)?"alertas":RouteData.Values["action"] as string==nameof(AplicarEspera)?"esperas":"conteo"});
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> AtenderAlerta(int lineaID,long id, string? observacion)
    {
        try
        {
            var alerta = await _db.AlertasOcupacion.FindAsync(id);
            if (alerta is null) throw new InvalidOperationException("La alerta no existe.");
            var conteo=await _db.ConteosEstacion.FindAsync(alerta.ConteoEstacionID);
            if(conteo is null || (conteo.LineaID.HasValue?conteo.LineaID!=lineaID:!await _db.LineasEstaciones.AnyAsync(x=>x.LineaID==lineaID&&x.EstacionID==alerta.EstacionID)))throw new InvalidOperationException("La alerta no pertenece a la línea seleccionada.");
            alerta.Estado = "ATENDIDA";
            alerta.FechaAtencion = DateTime.UtcNow;
            alerta.Observacion = observacion;
            await _db.SaveChangesAsync();
            Exito("Alerta atendida.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction("Index","Recorridos",new{lineaID,seccion=RouteData.Values["action"] as string==nameof(AtenderAlerta)?"alertas":RouteData.Values["action"] as string==nameof(AplicarEspera)?"esperas":"conteo"});
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> AplicarEspera(int lineaID,long id)
    {
        try
        {
            var espera = await _db.EsperasAdicionales.FindAsync(id);
            if (espera is null) throw new InvalidOperationException("La espera no existe.");
            var ocupacion=await _db.RegistrosOcupacionBus.FindAsync(espera.RegistroOcupacionID);
            if(ocupacion is null || (ocupacion.ViajeID.HasValue?!await _db.Viajes.AnyAsync(x=>x.ViajeID==ocupacion.ViajeID&&x.LineaID==lineaID):!await _db.LineasBuses.AnyAsync(x=>x.BusID==ocupacion.BusID&&x.LineaID==lineaID)))throw new InvalidOperationException("La espera no pertenece a la línea seleccionada.");
            espera.Aplicada = true;
            espera.FechaAplicacion = DateTime.UtcNow;
            await _db.SaveChangesAsync();
            Exito("Espera adicional marcada como aplicada.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction("Index","Recorridos",new{lineaID,seccion=RouteData.Values["action"] as string==nameof(AtenderAlerta)?"alertas":RouteData.Values["action"] as string==nameof(AplicarEspera)?"esperas":"conteo"});
    }

    private void Exito(string mensaje) => TempData["Exito"] = mensaje;
    private void Error(Exception ex) => TempData["Error"] = ex.GetBaseException().Message;
}
