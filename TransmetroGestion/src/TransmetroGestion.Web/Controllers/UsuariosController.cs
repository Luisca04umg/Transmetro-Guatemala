using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Models;
using TransmetroGestion.Web.Services;

namespace TransmetroGestion.Web.Controllers;

[Authorize(Policy = "USUARIOS_EDITAR")]
public class UsuariosController : Controller
{
    private readonly TransmetroDbContext _db;
    private readonly PasswordService _passwords;

    public UsuariosController(TransmetroDbContext db, PasswordService passwords)
    {
        _db = db;
        _passwords = passwords;
    }

    public async Task<IActionResult> Index()
    {
        var vm = new UsuariosVm
        {
            Usuarios = await _db.Usuarios.AsNoTracking().OrderBy(x => x.NombreUsuario).ToListAsync(),
            Roles = await _db.Roles.AsNoTracking().Where(x => x.Activo).OrderBy(x => x.Nombre).ToListAsync(),
            Asignaciones = await _db.UsuariosRoles.AsNoTracking().ToListAsync()
        };
        return View(vm);
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> Crear(string nombreUsuario, string correo, string contrasena, short rolID)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(nombreUsuario) || string.IsNullOrWhiteSpace(correo) || !new System.ComponentModel.DataAnnotations.EmailAddressAttribute().IsValid(correo))
                throw new InvalidOperationException("Ingrese un usuario y correo válidos.");
            if (!await _db.Roles.AnyAsync(x => x.RolID == rolID && x.Activo))
                throw new InvalidOperationException("Seleccione un rol activo.");
            if (string.IsNullOrEmpty(contrasena) || contrasena.Length < 8) throw new InvalidOperationException("La contraseña debe tener al menos 8 caracteres.");
            var (hash, salt) = _passwords.CrearHash(contrasena);
            await _db.Database.CreateExecutionStrategy().ExecuteAsync(async () =>
            {
            _db.ChangeTracker.Clear();
            await using var tx = await _db.Database.BeginTransactionAsync();
            var usuario = new Usuario
            {
                NombreUsuario = nombreUsuario.Trim(),
                Correo = correo.Trim(),
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
                RolID = rolID,
                FechaAsignacion = DateTime.UtcNow
            });
            await _db.SaveChangesAsync();
            await tx.CommitAsync();
            });
            Exito("Usuario creado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> AsignarRol(int usuarioID, short rolID)
    {
        try
        {
            if (!await _db.UsuariosRoles.AnyAsync(x => x.UsuarioID == usuarioID && x.RolID == rolID))
            {
                _db.UsuariosRoles.Add(new UsuarioRol
                {
                    UsuarioID = usuarioID,
                    RolID = rolID,
                    FechaAsignacion = DateTime.UtcNow
                });
                await _db.SaveChangesAsync();
            }
            Exito("Rol asignado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    [HttpPost, ValidateAntiForgeryToken]
    public async Task<IActionResult> CambiarEstado(int id)
    {
        try
        {
            var usuario = await _db.Usuarios.FindAsync(id);
            if (usuario is null) throw new InvalidOperationException("El usuario no existe.");
            usuario.Activo = !usuario.Activo;
            await _db.SaveChangesAsync();
            Exito("Estado del usuario actualizado.");
        }
        catch (Exception ex) { Error(ex); }
        return RedirectToAction(nameof(Index));
    }

    private void Exito(string mensaje) => TempData["Exito"] = mensaje;
    private void Error(Exception ex) => TempData["Error"] = ex.GetBaseException().Message;
}
