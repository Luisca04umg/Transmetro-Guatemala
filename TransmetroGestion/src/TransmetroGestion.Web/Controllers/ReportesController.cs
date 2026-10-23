using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;

namespace TransmetroGestion.Web.Controllers;

[Authorize(Policy = "REPORTES_VER")]
public class ReportesController : Controller
{
    private readonly TransmetroDbContext _db;

    public ReportesController(TransmetroDbContext db) => _db = db;

    [HttpGet]
    public async Task<IActionResult> Index(string? reporte)
    {
        reporte = (reporte ?? "").Trim();
        string[] permitidos = ["", "lineas", "estaciones", "buses", "recorridos", "auditoria"];
        if (!permitidos.Contains(reporte)) return BadRequest();
        if (reporte == "auditoria" && !User.HasClaim("permiso", "AUDITORIA_VER")) return Forbid();
        var vm = new ReportesVm { Reporte = reporte };
        var ct = HttpContext.RequestAborted;
        switch (reporte)
        {
            case "lineas":
                vm.Lineas = await _db.VistaLineas.AsNoTracking().OrderBy(x => x.Codigo).ToListAsync(ct); break;
            case "estaciones":
                vm.Estaciones = await _db.VistaEstaciones.AsNoTracking().OrderBy(x => x.Nombre).ToListAsync(ct); break;
            case "buses":
                vm.Buses = await _db.VistaBusesPorLinea.AsNoTracking().OrderBy(x => x.CodigoLinea).ThenBy(x => x.CodigoInterno).ToListAsync(ct); break;
            case "recorridos":
                vm.Recorridos = await _db.VistaEstacionesPorLinea.AsNoTracking().OrderBy(x => x.CodigoLinea).ThenBy(x => x.Orden).ToListAsync(ct); break;
            case "auditoria":
                vm.Bitacora = await _db.Bitacora.AsNoTracking().OrderByDescending(x => x.FechaHora).ThenByDescending(x => x.BitacoraID).Take(100).ToListAsync(ct); break;
        }
        return View(vm);
    }
}
