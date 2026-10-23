using System.Diagnostics;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;

namespace TransmetroGestion.Web.Controllers;

[Authorize]
public class HomeController : Controller
{
    private readonly TransmetroDbContext _db;

    public HomeController(TransmetroDbContext db) => _db = db;

    public async Task<IActionResult> Index()
    {
        var vm = new DashboardVm
        {
            Lineas = await _db.Lineas.CountAsync(),
            Estaciones = await _db.Estaciones.CountAsync(),
            Buses = await _db.Buses.CountAsync(),
            Pilotos = await _db.Pilotos.CountAsync(x => x.Activo),
            AlertasPendientes = await _db.AlertasOcupacion.CountAsync(x => x.Estado == "PENDIENTE"),
            TarjetasActivas = await _db.TarjetasAcceso.CountAsync(x => x.Estado == "ACTIVA"),
            Alertas = await _db.VistaAlertasPendientes.AsNoTracking()
                .OrderByDescending(x => x.FechaGeneracion).Take(8).ToListAsync()
        };
        return View(vm);
    }

    [AllowAnonymous]
    public IActionResult Error() => View(new ErrorViewModel
    {
        RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier
    });
}

public class ErrorViewModel
{
    public string? RequestId { get; set; }
}
