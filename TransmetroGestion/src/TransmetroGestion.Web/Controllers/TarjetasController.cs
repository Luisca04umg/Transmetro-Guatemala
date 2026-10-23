using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
using TransmetroGestion.Web.Services;

namespace TransmetroGestion.Web.Controllers;

[Authorize(Policy = "PAGOS_OPERAR")]
public class TarjetasController : Controller
{
    private readonly TransmetroDbContext _db;
    private readonly DatabaseSessionService _session;

    public TarjetasController(TransmetroDbContext db, DatabaseSessionService session)
    {
        _db = db;
        _session = session;
    }

    [HttpGet]
    public async Task<IActionResult> Index(string? q, int pagina = 1)
    {
        q = (q ?? "").Trim();
        if (q.Length > 120) q = q[..120];
        var ct = HttpContext.RequestAborted;
        var consulta = _db.TarjetasAcceso.AsNoTracking();
        if (q.Length > 0)
            consulta = consulta.Where(t => _db.TitularesTarjeta.Any(c => c.TitularID == t.TitularID &&
                ((c.Nombres + " " + c.Apellidos).Contains(q) || (c.DPI != null && c.DPI.Contains(q)))));
        var vm = new TarjetasVm { Q = q, Total = await consulta.CountAsync(ct) };
        vm.Pagina = Math.Clamp(pagina, 1, vm.Paginas);
        vm.Tarjetas = await consulta.OrderBy(x => x.NumeroToken).ThenBy(x => x.TarjetaID)
            .Skip((vm.Pagina - 1) * TarjetasVm.TamanoPagina).Take(TarjetasVm.TamanoPagina).ToListAsync(ct);
        var titulares = vm.Tarjetas.Where(x => x.TitularID.HasValue).Select(x => x.TitularID!.Value).Distinct().ToList();
        vm.Titulares = await _db.TitularesTarjeta.AsNoTracking().Where(x => titulares.Contains(x.TitularID)).ToListAsync(ct);
        return View(vm);
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> CrearTitular(TitularTarjeta model)
    {
        try
        {
            if (!ModelState.IsValid) throw new InvalidOperationException("Revise los datos del ciudadano.");
            if (model.DPI is null || !System.Text.RegularExpressions.Regex.IsMatch(model.DPI, @"^[0-9]{8,9}$"))
                throw new InvalidOperationException("El DPI debe contener exactamente 8 o 9 dígitos.");
            if (await _db.TitularesTarjeta.AnyAsync(x => x.DPI == model.DPI))
                throw new InvalidOperationException("El DPI ya está registrado. Busque el titular existente.");
            model.DocumentoHash = System.Security.Cryptography.SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(model.DPI));
            model.TitularID = 0;
            model.FechaRegistro = DateTime.UtcNow;
            _db.TitularesTarjeta.Add(model);
            await _db.SaveChangesAsync();
            Exito("Titular registrado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> CrearTarjeta(long? titularID, string numeroToken, decimal montoInicial)
    {
        try
        {
            if (!ModelState.IsValid || string.IsNullOrWhiteSpace(numeroToken) || numeroToken.Trim().Length > 64 || montoInicial < 0 || montoInicial > 9999999999.99m || decimal.Round(montoInicial, 2) != montoInicial)
                throw new InvalidOperationException("Revise el número de tarjeta y el monto inicial (máximo dos decimales).");
            if (titularID is null || !await _db.TitularesTarjeta.AnyAsync(x => x.TitularID == titularID))
                throw new InvalidOperationException("Seleccione un ciudadano registrado.");
            await _db.Database.CreateExecutionStrategy().ExecuteAsync(async () =>
            {
            _db.ChangeTracker.Clear();
            await using var tx = await _db.Database.BeginTransactionAsync();
            var tarjeta = new TarjetaAcceso
            {
                TitularID = titularID,
                NumeroToken = numeroToken.Trim(),
                Saldo = 0,
                Estado = "ACTIVA",
                FechaEmision = DateOnly.FromDateTime(DateTime.UtcNow),
                FechaVencimiento = null
            };
            _db.TarjetasAcceso.Add(tarjeta);
            await _db.SaveChangesAsync();
            if (montoInicial > 0)
            {
                var referencia = "INICIAL-" + Guid.NewGuid().ToString("N");
                int.TryParse(User.FindFirstValue(ClaimTypes.NameIdentifier), out var usuarioID);
                await _session.EjecutarAsync(() => _db.Database.ExecuteSqlInterpolatedAsync(
                    $"EXEC fin.sp_RegistrarMovimientoTarjeta @TarjetaID={tarjeta.TarjetaID}, @Tipo={"R"}, @Monto={montoInicial}, @Referencia={referencia}, @UsuarioID={usuarioID}"));
            }
            await tx.CommitAsync();
            });
            Exito("Tarjeta registrada con su monto inicial.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> CambiarEstado(long id, string estado, string? q, int pagina = 1)
    {
        try
        {
            string[] permitidos = ["ACTIVA", "BLOQUEADA", "INACTIVA"];
            if (!permitidos.Contains(estado)) throw new InvalidOperationException("Estado inválido.");
            var tarjeta = await _db.TarjetasAcceso.FindAsync(id);
            if (tarjeta is null) throw new InvalidOperationException("La tarjeta no existe.");
            tarjeta.Estado = estado;
            await _db.SaveChangesAsync();
            Exito("Estado de la tarjeta actualizado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index), new { q, pagina });
    }

    [HttpGet]
    public async Task<IActionResult> BuscarTitulares(string? q)
    {
        q = (q ?? "").Trim();
        if (q.Length < 2 || q.Length > 80) return Json(Array.Empty<object>());
        var items = await _db.TitularesTarjeta.AsNoTracking()
            .Where(x => (x.Nombres + " " + x.Apellidos).Contains(q) || (x.DPI != null && x.DPI.Contains(q)))
            .OrderBy(x => x.Apellidos).Take(20)
            .Select(x => new { id = x.TitularID, nombre = x.Nombres + " " + x.Apellidos, dpi = x.DPI }).ToListAsync();
        return Json(items);
    }

    private void Exito(string mensaje) => TempData["Exito"] = mensaje;
    private void Error(Exception ex) => TempData["Error"] = ex.GetBaseException().Message;
}
