using System.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
using TransmetroGestion.Web.Services;

namespace TransmetroGestion.Web.Controllers;

[Authorize(Policy = "LINEAS_VER")]
public class CatalogosController : Controller
{
    private readonly TransmetroDbContext _db;
    private readonly DatabaseSessionService _session;
    private readonly EdicionService _edicion;
    private readonly DirectorioService _directorio;
    private readonly RutasService _rutas;

    public CatalogosController(TransmetroDbContext db, DatabaseSessionService session, EdicionService edicion, RutasService rutas, DirectorioService directorio)
    {
        _db = db;
        _session = session;
        _edicion = edicion;
        _directorio = directorio;
        _rutas = rutas;
    }

    public async Task<IActionResult> Index() => View(await _directorio.CatalogosInicio(HttpContext.RequestAborted));

    [HttpGet]
    public async Task<IActionResult> Directorio(string tipo,string? q,int pagina=1)
    {
        if(!DirectorioService.Permite("Catalogos",tipo))return BadRequest();
        Response.Headers["X-Transmetro-Partial"]="true";
        Response.Headers.CacheControl="no-store";
        return PartialView("_Directorio",await _directorio.ConsultarAsync(tipo,q,pagina,HttpContext.RequestAborted));
    }
    [HttpGet]
    public async Task<IActionResult> Ficha(string tipo,int id)
    {
        if(!DirectorioService.Permite("Catalogos",tipo))return BadRequest();
        try
        {
            var vm=await _directorio.CatalogosFicha(tipo,id,HttpContext.RequestAborted);
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
            ["CrearMunicipalidad"]="LINEAS_EDITAR",
            ["CrearLinea"]="LINEAS_EDITAR",
            ["CrearEstacion"]="ESTACIONES_EDITAR",
            ["GuardarRelacion"]="ESTACIONES_EDITAR",
            ["CrearParqueo"]="ESTACIONES_EDITAR",
            ["CrearBus"]="FLOTA_EDITAR",
            ["AsignarBus"]="FLOTA_EDITAR"
        };
        if(!permisos.TryGetValue(accion,out var permiso))return BadRequest();
        if(!User.HasClaim("permiso",permiso))return Forbid();
        Response.Headers["X-Transmetro-Partial"]="true";
        Response.Headers.CacheControl="no-store";
        return PartialView("_Formulario",await _directorio.CatalogosFormulario(accion,HttpContext.RequestAborted));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "LINEAS_EDITAR")]
    public async Task<IActionResult> CrearMunicipalidad(Municipalidad model)
    {
        try
        {
            model.MunicipalidadID = 0;
            model.Activa = true;
            model.FechaCreacion = DateTime.UtcNow;
            _db.Municipalidades.Add(model);
            await _db.SaveChangesAsync();
            Exito("Municipalidad registrada.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "LINEAS_EDITAR")]
    public async Task<IActionResult> CrearLinea(Linea model)
    {
        try
        {
            model.LineaID = 0;
            model.Estado = "P";
            model.FechaCreacion = DateTime.UtcNow;
            _db.Lineas.Add(model);
            await _db.SaveChangesAsync();
            Exito("Línea registrada en estado pendiente.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "ESTACIONES_EDITAR")]
    public async Task<IActionResult> CrearEstacion(Estacion model)
    {
        try
        {
            model.EstacionID = 0;
            model.Estado = "P";
            model.FechaCreacion = DateTime.UtcNow;
            _db.Estaciones.Add(model);
            await _db.SaveChangesAsync();
            Exito("Estación registrada en estado pendiente.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "ESTACIONES_EDITAR")]
    public async Task<IActionResult> AgregarEstacionLinea(int lineaID, int estacionID, short orden, short? tiempoMinuto)
    {
        return await GuardarRelacion(0,estacionID,lineaID,orden,tiempoMinuto);
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "ESTACIONES_EDITAR")]
    public async Task<IActionResult> CrearParqueo(Parqueo model)
    {
        try
        {
            model.ParqueoID = 0;
            model.Activo = true;
            model.FechaCreacion = DateTime.UtcNow;
            _db.Parqueos.Add(model);
            await _db.SaveChangesAsync();
            Exito("Parqueo registrado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "FLOTA_EDITAR")]
    public async Task<IActionResult> CrearBus(Bus model)
    {
        try
        {
            model.BusID = 0;
            model.Estado = "DISPONIBLE";
            model.FechaRegistro = DateTime.UtcNow;
            _db.Buses.Add(model);
            await _db.SaveChangesAsync();
            Exito("Bus registrado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "FLOTA_EDITAR")]
    public async Task<IActionResult> AsignarBus(int busID, int lineaID)
    {
        try
        {
            await _session.EjecutarAsync(() => _db.Database.ExecuteSqlInterpolatedAsync(
                $"EXEC ops.sp_AsignarBusLinea @BusID={busID}, @LineaID={lineaID}"));
            Exito("Bus asignado a la línea.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "LINEAS_EDITAR")]
    public async Task<IActionResult> ActivarLinea(int id)
    {
        try
        {
            await _session.EjecutarAsync(() => _db.Database.ExecuteSqlInterpolatedAsync(
                $"EXEC ops.sp_ActivarLinea @LineaID={id}"));
            Exito("Línea activada.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken, Authorize(Policy = "ESTACIONES_EDITAR")]
    public async Task<IActionResult> ActivarEstacion(int id)
    {
        try
        {
            await _session.EjecutarAsync(() => _db.Database.ExecuteSqlInterpolatedAsync(
                $"EXEC ops.sp_ActivarEstacion @EstacionID={id}"));
            Exito("Estación activada.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }


    [HttpGet]
    public async Task<IActionResult> Editar(string tipo,int id)
    {
        if(!EdicionService.Configuraciones.TryGetValue(tipo,out var c)||c.Controlador!="Catalogos")return BadRequest();
        if(!User.HasClaim("permiso",c.Permiso))return Forbid();
        try{return View(await _edicion.CargarAsync(tipo,id));}
        catch(Exception ex){Error(ex);return RedirectToAction(nameof(Index));}
    }
    [HttpPost,ValidateAntiForgeryToken]
    public async Task<IActionResult> Guardar(string tipo,int id,string revision)
    {
        if(!EdicionService.Configuraciones.TryGetValue(tipo,out var c)||c.Controlador!="Catalogos")return BadRequest();
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


    [HttpPost,ValidateAntiForgeryToken,Authorize(Policy="ESTACIONES_EDITAR")]
    public async Task<IActionResult> GuardarRelacion(int origenLineaID,int estacionID,int destinoLineaID,short orden,short? tiempoMinuto)
    {
        try
        {
            if(!ModelState.IsValid)throw new InvalidOperationException("Revise los campos de la asignación.");
            string mensaje=await _db.Database.CreateExecutionStrategy().ExecuteAsync(async()=>
            {
                _db.ChangeTracker.Clear();await using var tx=await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
                var resultado=await _rutas.GuardarEstacionAsync(origenLineaID,estacionID,destinoLineaID,orden,tiempoMinuto);await tx.CommitAsync();return resultado;
            });Exito(mensaje);
        }
        catch(Exception ex){Error(ex);}
        return RedirectToAction(nameof(Index));
    }
    [HttpPost,ValidateAntiForgeryToken,Authorize(Policy="FLOTA_EDITAR")]
    public async Task<IActionResult> CambiarLineaBus(int busID,int? lineaID)
    {
        try
        {
            if(!ModelState.IsValid)throw new InvalidOperationException("Seleccione una línea válida.");
            string mensaje=await _db.Database.CreateExecutionStrategy().ExecuteAsync(async()=>
            {
                _db.ChangeTracker.Clear();await using var tx=await _db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
                var resultado=await _rutas.AsignarBusAsync(busID,lineaID);await tx.CommitAsync();return resultado;
            });Exito(mensaje);
        }
        catch(Exception ex){Error(ex);}
        return RedirectToAction(nameof(Index));
    }
    [HttpPost,ValidateAntiForgeryToken,Authorize(Policy="ESTACIONES_EDITAR")]
    public async Task<IActionResult> GuardarTramo(int lineaID,int origenID,int destinoID,decimal distanciaKm)
    {
        try
        {
            if(!ModelState.IsValid||distanciaKm<=0)throw new InvalidOperationException("La distancia debe ser mayor que cero.");
            var origen=await _db.LineasEstaciones.FindAsync(lineaID,origenID);
            var destino=await _db.LineasEstaciones.FindAsync(lineaID,destinoID);
            if(origen is null||destino is null||destino.Orden!=origen.Orden+1)throw new InvalidOperationException("Seleccione estaciones consecutivas de la misma línea.");
            var tramo=await _db.TramosLinea.SingleOrDefaultAsync(x=>x.LineaID==lineaID&&x.EstacionOrigenID==origenID);
            if(tramo is null){tramo=new TramoLinea{LineaID=lineaID,EstacionOrigenID=origenID,EstacionDestinoID=destinoID};_db.TramosLinea.Add(tramo);}
            tramo.EstacionDestinoID=destinoID;tramo.DistanciaKm=distanciaKm;tramo.FechaActualizacion=DateTime.UtcNow;
            await _db.SaveChangesAsync();Exito("Distancia guardada.");
        }
        catch(Exception ex){Error(ex);}
        return RedirectToAction(nameof(Index));
    }

    private void Exito(string mensaje) => TempData["Exito"] = mensaje;
    private void Error(Exception ex) => TempData["Error"] = ex.GetBaseException().Message;
}
