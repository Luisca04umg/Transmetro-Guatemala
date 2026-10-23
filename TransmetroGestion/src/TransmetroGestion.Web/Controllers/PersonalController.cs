using System.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
using TransmetroGestion.Web.Services;

namespace TransmetroGestion.Web.Controllers;

[Authorize(Policy = "PERSONAL_VER")]
public class PersonalController : Controller
{
    private readonly TransmetroDbContext _db;
    private readonly DatabaseSessionService _session;
    private readonly EdicionService _edicion;
    private readonly DirectorioService _directorio;
    private readonly RutasService _rutas;

    public PersonalController(TransmetroDbContext db, DatabaseSessionService session, EdicionService edicion, RutasService rutas, DirectorioService directorio)
    {
        _db = db;
        _session = session;
        _edicion = edicion;
        _directorio = directorio;
        _rutas = rutas;
    }

    public async Task<IActionResult> Index() => View(await _directorio.PersonalInicio(HttpContext.RequestAborted));

    [HttpGet]
    public async Task<IActionResult> Directorio(string tipo,string? q,int pagina=1)
    {
        if(!DirectorioService.Permite("Personal",tipo))return BadRequest();
        Response.Headers["X-Transmetro-Partial"]="true";
        Response.Headers.CacheControl="no-store";
        return PartialView("_Directorio",await _directorio.ConsultarAsync(tipo,q,pagina,HttpContext.RequestAborted));
    }
    [HttpGet]
    public async Task<IActionResult> Ficha(string tipo,int id)
    {
        if(!DirectorioService.Permite("Personal",tipo))return BadRequest();
        try
        {
            var vm=await _directorio.PersonalFicha(tipo,id,HttpContext.RequestAborted);
            Response.Headers["X-Transmetro-Partial"]="true";
        Response.Headers.CacheControl="no-store";
            return PartialView("_Ficha",vm);
        }
        catch(KeyNotFoundException){return NotFound();}
    }
    [HttpGet]
    public async Task<IActionResult> Formulario(string accion)
    {
        var permisos=new Dictionary<string,string>{
            ["CrearPiloto"]="PERSONAL_EDITAR",
            ["CrearOperador"]="PERSONAL_EDITAR",
            ["CrearGuardia"]="PERSONAL_EDITAR",
            ["CrearAcceso"]="ESTACIONES_EDITAR",
            ["AsignarOperador"]="PERSONAL_EDITAR",
            ["AsignarGuardia"]="PERSONAL_EDITAR"
        };
        if(!permisos.TryGetValue(accion,out var permiso))return BadRequest();
        if(!User.HasClaim("permiso",permiso))return Forbid();
        Response.Headers["X-Transmetro-Partial"]="true";
        Response.Headers.CacheControl="no-store";
        return PartialView("_Formulario",await _directorio.PersonalFormulario(accion,HttpContext.RequestAborted));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "PERSONAL_EDITAR")]
    public async Task<IActionResult> CrearPiloto(Piloto model, DateTime fechaLicencia)
    {
        try
        {
            model.PilotoID = 0;
            model.FechaVencimientoLicencia = DateOnly.FromDateTime(fechaLicencia);
            model.Activo = true;
            model.FechaRegistro = DateTime.UtcNow;
            _db.Pilotos.Add(model);
            await _db.SaveChangesAsync();
            Exito("Piloto registrado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "PERSONAL_EDITAR")]
    public async Task<IActionResult> CrearOperador(Operador model)
    {
        try
        {
            model.OperadorID = 0;
            model.Activo = true;
            model.FechaRegistro = DateTime.UtcNow;
            _db.Operadores.Add(model);
            await _db.SaveChangesAsync();
            Exito("Operador registrado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "PERSONAL_EDITAR")]
    public async Task<IActionResult> AsignarOperador(int operadorID, int estacionID)
    {
        try
        {
            if(!await _db.Operadores.AnyAsync(x=>x.OperadorID==operadorID&&x.Activo))throw new InvalidOperationException("El operador debe estar activo.");
            await _db.Database.CreateExecutionStrategy().ExecuteAsync(async()=>
            {
                _db.ChangeTracker.Clear();await using var tx=await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
                var vigente=await _db.AsignacionesOperadorEstacion.SingleOrDefaultAsync(x=>x.OperadorID==operadorID&&x.FechaFin==null);
                var estacion=await _db.Estaciones.FindAsync(estacionID)??throw new InvalidOperationException("La estación no existe.");
                if(estacion.Estado=="I")throw new InvalidOperationException("Deje la estación en estado Pendiente antes de asignarle un operador y activarla.");
                if(vigente?.EstacionID==estacionID){await tx.CommitAsync();return;}
                if(vigente is not null)
                {
                    if(await _db.Estaciones.AnyAsync(x=>x.EstacionID==vigente.EstacionID&&x.Estado=="A"))throw new InvalidOperationException("Sustituya al operador en su estación anterior antes de trasladarlo.");
                    vigente.FechaFin=DateTime.UtcNow;
                }
                var anterior=await _db.AsignacionesOperadorEstacion.SingleOrDefaultAsync(x=>x.EstacionID==estacionID&&x.FechaFin==null);
                string estado=estacion.Estado;
                if(estado=="A"){estacion.Estado="P";await _db.SaveChangesAsync();}
                if(anterior is not null)anterior.FechaFin=DateTime.UtcNow;
                await _db.SaveChangesAsync();
                _db.AsignacionesOperadorEstacion.Add(new AsignacionOperadorEstacion{OperadorID=operadorID,EstacionID=estacionID,FechaInicio=DateTime.UtcNow});
                await _db.SaveChangesAsync();
                if(estado=="A")await _db.Database.ExecuteSqlInterpolatedAsync($"EXEC ops.sp_ActivarEstacion @EstacionID={estacionID}");
                await tx.CommitAsync();
            });
            Exito("Operador asignado a la estación.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "PERSONAL_EDITAR")]
    public async Task<IActionResult> CrearGuardia(Guardia model)
    {
        try
        {
            model.GuardiaID = 0;
            model.Activo = true;
            model.FechaRegistro = DateTime.UtcNow;
            _db.Guardias.Add(model);
            await _db.SaveChangesAsync();
            Exito("Guardia registrado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "ESTACIONES_EDITAR")]
    public async Task<IActionResult> CrearAcceso(Acceso model)
    {
        try
        {
            model.AccesoID = 0;
            model.Estado = "P";
            model.FechaCreacion = DateTime.UtcNow;
            _db.Accesos.Add(model);
            await _db.SaveChangesAsync();
            Exito("Acceso registrado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "PERSONAL_EDITAR")]
    public async Task<IActionResult> AsignarGuardia(int guardiaID, int accesoID, string turno)
    {
        try
        {
            if(turno is not("DIURNO" or "NOCTURNO" or "MIXTO"))throw new InvalidOperationException("Turno inválido.");
            if(!await _db.Guardias.AnyAsync(x=>x.GuardiaID==guardiaID&&x.Activo))throw new InvalidOperationException("El guardia debe estar activo.");
            await _db.Database.CreateExecutionStrategy().ExecuteAsync(async()=>
            {
                _db.ChangeTracker.Clear();await using var tx=await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
                var vigente=await _db.AsignacionesGuardiaAcceso.SingleOrDefaultAsync(x=>x.GuardiaID==guardiaID&&x.FechaFin==null);
                if(vigente?.AccesoID==accesoID){vigente.Turno=turno;await _db.SaveChangesAsync();await tx.CommitAsync();return;}
                if(vigente is not null)
                {
                    if(await _db.Accesos.AnyAsync(x=>x.AccesoID==vigente.AccesoID&&x.Estado=="A")&&!await _db.AsignacionesGuardiaAcceso.AnyAsync(x=>x.AccesoID==vigente.AccesoID&&x.GuardiaID!=guardiaID&&x.FechaFin==null))throw new InvalidOperationException("Asigne un guardia sustituto al acceso anterior antes de trasladarlo.");
                    vigente.FechaFin=DateTime.UtcNow;await _db.SaveChangesAsync();
                }
                _db.AsignacionesGuardiaAcceso.Add(new AsignacionGuardiaAcceso{GuardiaID=guardiaID,AccesoID=accesoID,Turno=turno,FechaInicio=DateTime.UtcNow});
                await _db.SaveChangesAsync();await tx.CommitAsync();
            });
            Exito("Guardia asignado al acceso.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "ESTACIONES_EDITAR")]
    public async Task<IActionResult> ActivarAcceso(int id)
    {
        try
        {
            await _session.EjecutarAsync(() => _db.Database.ExecuteSqlInterpolatedAsync(
                $"EXEC ops.sp_ActivarAcceso @AccesoID={id}"));
            Exito("Acceso activado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }


    [HttpGet]
    public async Task<IActionResult> Editar(string tipo,int id)
    {
        if(!EdicionService.Configuraciones.TryGetValue(tipo,out var c)||c.Controlador!="Personal")return BadRequest();
        if(!User.HasClaim("permiso",c.Permiso))return Forbid();
        try{return View(await _edicion.CargarAsync(tipo,id));}
        catch(Exception ex){Error(ex);return RedirectToAction(nameof(Index));}
    }
    [HttpPost,ValidateAntiForgeryToken]
    public async Task<IActionResult> Guardar(string tipo,int id,string revision)
    {
        if(!EdicionService.Configuraciones.TryGetValue(tipo,out var c)||c.Controlador!="Personal")return BadRequest();
        if(!User.HasClaim("permiso",c.Permiso))return Forbid();
        try
        {
            var formulario=await Request.ReadFormAsync();
            await _db.Database.CreateExecutionStrategy().ExecuteAsync(async()=>
            {
                _db.ChangeTracker.Clear();await using var tx=await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
                await _edicion.GuardarAsync(tipo,id,revision,formulario);await tx.CommitAsync();
            });
            Exito("Cambios guardados.");return RedirectToAction(nameof(Index));
        }
        catch(Exception ex){Error(ex);return RedirectToAction(nameof(Editar),new{tipo,id});}
    }


    [HttpPost,ValidateAntiForgeryToken,Authorize(Policy="PERSONAL_EDITAR")]
    public async Task<IActionResult> CrearEducacion(HistorialEducativoPiloto model)
    {
        try
        {
            if(!ModelState.IsValid)throw new InvalidOperationException("Revise el historial educativo.");
            model.HistorialEducativoID=0;_db.HistorialEducativoPilotos.Add(model);await _db.SaveChangesAsync();Exito("Historial educativo registrado.");
        }
        catch(Exception ex){Error(ex);}
        return RedirectToAction(nameof(Index));
    }

    private void Exito(string mensaje) => TempData["Exito"] = mensaje;
    private void Error(Exception ex) => TempData["Error"] = ex.GetBaseException().Message;
}
