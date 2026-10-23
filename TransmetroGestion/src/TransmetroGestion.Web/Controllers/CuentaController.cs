using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
using TransmetroGestion.Web.Services;

namespace TransmetroGestion.Web.Controllers;

[AllowAnonymous]
public class CuentaController : Controller
{
    private readonly TransmetroDbContext _db;
    private readonly PasswordService _passwords;

    public CuentaController(TransmetroDbContext db, PasswordService passwords)
    {
        _db = db;
        _passwords = passwords;
    }

    [HttpGet]
    public async Task<IActionResult> IniciarSesion(string? returnUrl = null)
    {
        if (!await _db.Usuarios.AnyAsync())
            return RedirectToAction(nameof(Inicializar));
        ViewBag.ReturnUrl = returnUrl;
        return View(new LoginVm());
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> IniciarSesion(LoginVm vm, string? returnUrl = null)
    {
        if (string.IsNullOrWhiteSpace(vm.NombreUsuario) || string.IsNullOrWhiteSpace(vm.Contrasena))
        {
            ModelState.AddModelError("", "Ingrese el usuario y la contraseña.");
            return View(vm);
        }

        var usuario = await _db.Usuarios.SingleOrDefaultAsync(x => x.NombreUsuario == vm.NombreUsuario);
        if (usuario is null || !usuario.Activo)
        {
            ModelState.AddModelError("", "Credenciales incorrectas o usuario inactivo.");
            return View(vm);
        }

        if (usuario.BloqueadoHasta.HasValue && usuario.BloqueadoHasta > DateTime.UtcNow)
        {
            ModelState.AddModelError("", "La cuenta está bloqueada temporalmente. Intente más tarde.");
            return View(vm);
        }

        if (!_passwords.Verificar(vm.Contrasena, usuario.ContrasenaHash, usuario.ContrasenaSalt))
        {
            usuario.IntentosFallidos = (byte)Math.Min(10, usuario.IntentosFallidos + 1);
            if (usuario.IntentosFallidos >= 5)
                usuario.BloqueadoHasta = DateTime.UtcNow.AddMinutes(15);
            await _db.SaveChangesAsync();
            ModelState.AddModelError("", "Credenciales incorrectas.");
            return View(vm);
        }

        usuario.IntentosFallidos = 0;
        usuario.BloqueadoHasta = null;
        usuario.UltimoAcceso = DateTime.UtcNow;
        await _db.SaveChangesAsync();
        await CrearSesionAsync(usuario, vm.Recordarme);

        return LocalRedirect(Url.IsLocalUrl(returnUrl) ? returnUrl! : "/");
    }

    [HttpGet]
    public async Task<IActionResult> Inicializar()
    {
        if (await _db.Usuarios.AnyAsync())
            return RedirectToAction(nameof(IniciarSesion));
        return View(new InicializarVm());
    }

    [HttpPost, ValidateAntiForgeryToken]

    public async Task<IActionResult> Inicializar(InicializarVm vm)
    {
        if (await _db.Usuarios.AnyAsync())
            return RedirectToAction(nameof(IniciarSesion));

        if (string.IsNullOrWhiteSpace(vm.NombreUsuario) ||
            string.IsNullOrWhiteSpace(vm.Correo))
        {
            ModelState.AddModelError(
                "", "El usuario y el correo son obligatorios.");
        }

        if (string.IsNullOrEmpty(vm.Contrasena) ||
            vm.Contrasena.Length < 8)
        {
            ModelState.AddModelError(
                "", "La contraseña debe tener al menos 8 caracteres.");
        }

        if (vm.Contrasena != vm.ConfirmarContrasena)
        {
            ModelState.AddModelError(
                "", "Las contraseñas no coinciden.");
        }

        if (!ModelState.IsValid)
            return View(vm);

        var rol = await _db.Roles
            .SingleOrDefaultAsync(x => x.Nombre == "Administrador");

        if (rol is null)
        {
            ModelState.AddModelError(
                "",
                "No existe el rol Administrador. Ejecute nuevamente el script de base de datos.");

            return View(vm);
        }

        var (hash, salt) = _passwords.CrearHash(vm.Contrasena);

        var estrategia = _db.Database.CreateExecutionStrategy();

        var usuarioCreado = await estrategia.ExecuteAsync(async () =>
        {
            _db.ChangeTracker.Clear();
            await using var tx =
                await _db.Database.BeginTransactionAsync();

            var usuario = new Usuario
            {
                NombreUsuario = vm.NombreUsuario.Trim(),
                Correo = vm.Correo.Trim(),
                ContrasenaHash = hash,
                ContrasenaSalt = salt,
                Activo = true,
                FechaCreacion = DateTime.UtcNow
            };

            _db.Usuarios.Add(usuario);
            await _db.SaveChangesAsync();

            _db.UsuariosRoles.Add(new UsuarioRol
            {
                UsuarioID = usuario.UsuarioID,
                RolID = rol.RolID,
                FechaAsignacion = DateTime.UtcNow
            });

            await _db.SaveChangesAsync();
            await tx.CommitAsync();

            return usuario;
        });

        await CrearSesionAsync(usuarioCreado, false);

        return RedirectToAction("Index", "Home");
    }


    [Authorize, HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> CerrarSesion()
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        return RedirectToAction(nameof(IniciarSesion));
    }

    public IActionResult AccesoDenegado() => View();

    private async Task CrearSesionAsync(Usuario usuario, bool persistente)
    {
        var roles = await (
            from ur in _db.UsuariosRoles
            join r in _db.Roles on ur.RolID equals r.RolID
            where ur.UsuarioID == usuario.UsuarioID && r.Activo
            select r.Nombre).ToListAsync();

        var permisos = await (
            from ur in _db.UsuariosRoles
            join rp in _db.RolesPermisos on ur.RolID equals rp.RolID
            join p in _db.Permisos on rp.PermisoID equals p.PermisoID
            where ur.UsuarioID == usuario.UsuarioID
            select p.Codigo).Distinct().ToListAsync();

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, usuario.UsuarioID.ToString()),
            new(ClaimTypes.Name, usuario.NombreUsuario),
            new(ClaimTypes.Email, usuario.Correo)
        };
        claims.AddRange(roles.Select(x => new Claim(ClaimTypes.Role, x)));
        claims.AddRange(permisos.Select(x => new Claim("permiso", x)));

        var principal = new ClaimsPrincipal(new ClaimsIdentity(
            claims, CookieAuthenticationDefaults.AuthenticationScheme));
        await HttpContext.SignInAsync(
            CookieAuthenticationDefaults.AuthenticationScheme,
            principal,
            new AuthenticationProperties { IsPersistent = persistente });
    }
}
