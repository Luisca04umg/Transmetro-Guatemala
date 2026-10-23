using System;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
namespace TransmetroGestion.Web.Services;
public sealed class ValidacionDatosInterceptor : SaveChangesInterceptor
{
    private static readonly Regex NombreValido = new(
        @"\A\p{L}[\p{L}\p{M}]*(?: +\p{L}[\p{L}\p{M}]*)*\z",
        RegexOptions.CultureInvariant, TimeSpan.FromMilliseconds(100));
    private static readonly Regex TelefonoValido = new(
        @"\A[0-9]{8}\z", RegexOptions.CultureInvariant,
        TimeSpan.FromMilliseconds(100));
    private static void Validar(DbContext? db)
    {
        if (db is null) return;
        foreach (var entry in db.ChangeTracker.Entries()
            .Where(e => e.State is EntityState.Added or EntityState.Modified))
        foreach (var campo in entry.Properties)
        {
            var nombre = campo.Metadata.Name;
            if (campo.Metadata.ClrType != typeof(string) ||
                (nombre != "Nombres" && nombre != "Apellidos" && nombre != "Telefono")) continue;
            if (entry.State != EntityState.Added && !campo.IsModified) continue;
            var valor = (campo.CurrentValue as string)?.Trim().Normalize(NormalizationForm.FormC) ?? "";
            if (nombre == "Telefono")
            {
                if (valor.Length == 0 && campo.Metadata.IsNullable)
                { campo.CurrentValue = null; continue; }
                if (!TelefonoValido.IsMatch(valor))
                    throw new InvalidOperationException("El teléfono debe tener exactamente 8 dígitos, sin espacios ni guiones.");
            }
            else if (valor.Length == 0 || valor.Length > 100 || !NombreValido.IsMatch(valor))
                throw new InvalidOperationException($"{nombre}: use sólo letras y espacios, máximo 100 caracteres.");
            campo.CurrentValue = valor;
        }
    }
    public override InterceptionResult<int> SavingChanges(
        DbContextEventData eventData, InterceptionResult<int> result)
    { Validar(eventData.Context); return result; }
    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(
        DbContextEventData eventData, InterceptionResult<int> result,
        CancellationToken cancellationToken = default)
    { Validar(eventData.Context); return ValueTask.FromResult(result); }
}
