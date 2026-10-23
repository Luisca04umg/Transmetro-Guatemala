using System.Data;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
using TransmetroGestion.Web.Services;
namespace TransmetroGestion.Web.Controllers;

[Authorize(AuthenticationSchemes = "Ciudadano")]
public class CiudadanoController(TransmetroDbContext db, RecorridosService recorridos) : Controller
{
    [AllowAnonymous, HttpGet]
    public IActionResult Ingresar() => View();

    [AllowAnonymous, HttpPost, ValidateAntiForgeryToken, EnableRateLimiting("tarjeta")]
    public async Task<IActionResult> Ingresar(string numeroToken)
    {
        var tarjeta = await db.TarjetasAcceso.AsNoTracking().SingleOrDefaultAsync(x => x.NumeroToken == (numeroToken ?? "").Trim() && x.Estado == "ACTIVA");
        if (tarjeta is null) { TempData["Error"] = "Tarjeta inexistente o inactiva."; return View(); }
        var identidad = new ClaimsIdentity(new[] { new Claim("TarjetaID", tarjeta.TarjetaID.ToString()), new Claim(ClaimTypes.Name, "Mi tarjeta") }, "Ciudadano");
        await HttpContext.SignInAsync("Ciudadano", new ClaimsPrincipal(identidad));
        return RedirectToAction(nameof(Index));
    }

    public async Task<IActionResult> Index()
    {
        var tarjeta = await ObtenerTarjeta();
        if (tarjeta is null) return await SalirDeTarjeta();
        return View(await Modelo(tarjeta));
    }

    public async Task<IActionResult> Seguimiento(int? lineaID)
    {
        var tarjeta = await ObtenerTarjeta();
        if (tarjeta is null) return await SalirDeTarjeta();
        var vm = await Modelo(tarjeta);
        vm.LineaSeleccionada = lineaID;
        vm.Recorridos = lineaID.HasValue ? await recorridos.ConsultarAsync(lineaID: lineaID) : new RecorridosVm();
        return View(vm);
    }

    public async Task<IActionResult> Mapa()
    {
        if (await ObtenerTarjeta() is null) return await SalirDeTarjeta();
        return View();
    }

    [HttpPost, ValidateAntiForgeryToken, EnableRateLimiting("tarjeta")]
    public async Task<IActionResult> Recargar(decimal monto, Guid solicitud)
    {
        return await Ejecutar(async () =>
        {
            var tarjeta = await ObtenerTarjeta() ?? throw new InvalidOperationException("La tarjeta no está activa.");
            if (solicitud == Guid.Empty || monto <= 0 || monto > 10000 || decimal.Round(monto, 2) != monto)
                throw new InvalidOperationException("Monto inválido: de Q0.01 a Q10,000, con máximo dos decimales.");
            var referencia = "REC-" + tarjeta.TarjetaID + "-" + solicitud.ToString("N");
            if (!await db.TransaccionesTarjeta.AnyAsync(x => x.Referencia == referencia))
                await Movimiento(tarjeta.TarjetaID, "R", monto, referencia, null);
            return "Recarga de demostración registrada.";
        });
    }

    [HttpPost, ValidateAntiForgeryToken, EnableRateLimiting("tarjeta")]
    public async Task<IActionResult> Pagar(int estacionID, int lineaID, Guid solicitud)
    {
        return await Ejecutar(async () =>
        {
            var tarjeta = await ObtenerTarjeta() ?? throw new InvalidOperationException("La tarjeta no está activa.");
            if (solicitud == Guid.Empty || !await db.LineasEstaciones.AnyAsync(x => x.LineaID == lineaID && x.EstacionID == estacionID)
                || !await db.Estaciones.AnyAsync(x => x.EstacionID == estacionID && x.Estado != "I")
                || !await db.Lineas.AnyAsync(x => x.LineaID == lineaID && x.Estado != "I"))
                throw new InvalidOperationException("Seleccione una estación y una línea a la que pertenezca.");
            var referencia = "PAG-" + tarjeta.TarjetaID + "-" + solicitud.ToString("N");
            if (await db.TransaccionesTarjeta.AnyAsync(x => x.Referencia == referencia)) return "El pago ya fue registrado.";
            var pase = await db.PasesLineaTarjeta.SingleOrDefaultAsync(x => x.TarjetaID == tarjeta.TarjetaID && x.FechaFin == null);
            if (pase?.LineaID == lineaID) return "Su pago vigente cubre esta línea durante el recorrido actual. No se descontó otro monto.";
            if (pase is not null) { pase.FechaFin = DateTime.UtcNow; await db.SaveChangesAsync(); }
            // El cliente nunca determina el importe de pago.
            await Movimiento(tarjeta.TarjetaID, "P", 2.00m, referencia, estacionID);
            var transaccion = await db.TransaccionesTarjeta.SingleAsync(x => x.Referencia == referencia);
            db.PasesLineaTarjeta.Add(new PaseLineaTarjeta { TarjetaID = tarjeta.TarjetaID, LineaID = lineaID,
                EstacionID = estacionID, TransaccionID = transaccion.TransaccionID, FechaInicio = DateTime.UtcNow });
            await db.SaveChangesAsync();
            return "Pago de Q2.00 registrado. Cubre la línea seleccionada hasta finalizar o cambiar de línea.";
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> FinalizarRecorrido()
    {
        return await Ejecutar(async () =>
        {
            var tarjeta = await ObtenerTarjeta() ?? throw new InvalidOperationException("La tarjeta no está activa.");
            var pase = await db.PasesLineaTarjeta.SingleOrDefaultAsync(x => x.TarjetaID == tarjeta.TarjetaID && x.FechaFin == null);
            if (pase is not null) { pase.FechaFin = DateTime.UtcNow; await db.SaveChangesAsync(); }
            return "Recorrido finalizado. Su siguiente recorrido requiere un nuevo pago de Q2.00.";
        });
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Salir() => await SalirDeTarjeta();

    private async Task<IActionResult> SalirDeTarjeta()
    {
        await HttpContext.SignOutAsync("Ciudadano");
        return RedirectToAction(nameof(Ingresar));
    }

    private Task Movimiento(long tarjetaID, string tipo, decimal monto, string referencia, int? estacionID)
    {
        int? usuarioID = null;
        return db.Database.ExecuteSqlInterpolatedAsync($"EXEC fin.sp_RegistrarMovimientoTarjeta @TarjetaID={tarjetaID}, @Tipo={tipo}, @Monto={monto}, @Referencia={referencia}, @EstacionID={estacionID}, @UsuarioID={usuarioID}");
    }

    private async Task<IActionResult> Ejecutar(Func<Task<string>> operacion)
    {
        try
        {
            if (!ModelState.IsValid) throw new InvalidOperationException("Revise los datos ingresados.");
            var mensaje = await db.Database.CreateExecutionStrategy().ExecuteAsync(async () =>
            {
                db.ChangeTracker.Clear();
                await using var tx = await db.Database.BeginTransactionAsync(IsolationLevel.Serializable);
                var resultado = await operacion();
                await tx.CommitAsync();
                return resultado;
            });
            TempData["Exito"] = mensaje;
        }
        catch (Exception ex) { TempData["Error"] = ex.GetBaseException().Message; }
        return RedirectToAction(nameof(Index));
    }

    private async Task<CiudadanoVm> Modelo(TarjetaAcceso tarjeta) => new()
    {
        Tarjeta = tarjeta,
        Movimientos = await db.TransaccionesTarjeta.AsNoTracking().Where(x => x.TarjetaID == tarjeta.TarjetaID).OrderByDescending(x => x.TransaccionID).Take(100).ToListAsync(),
        Estaciones = await db.Estaciones.AsNoTracking().Where(x => x.Estado != "I").OrderBy(x => x.Nombre).ToListAsync(),
        Lineas = await db.Lineas.AsNoTracking().Where(x => x.Estado != "I").OrderBy(x => x.Nombre).ToListAsync(),
        Ruta = await db.LineasEstaciones.AsNoTracking().ToListAsync(),
        PaseActivo = await db.PasesLineaTarjeta.AsNoTracking().SingleOrDefaultAsync(x => x.TarjetaID == tarjeta.TarjetaID && x.FechaFin == null)
    };

    private Task<TarjetaAcceso?> ObtenerTarjeta()
    {
        if (!long.TryParse(User.FindFirstValue("TarjetaID"), out var id)) return Task.FromResult<TarjetaAcceso?>(null);
        return db.TarjetasAcceso.AsNoTracking().SingleOrDefaultAsync(x => x.TarjetaID == id && x.Estado == "ACTIVA");
    }
}
