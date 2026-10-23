using System.Data;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;

namespace TransmetroGestion.Web.Services;

public class DatabaseSessionService
{
    private readonly TransmetroDbContext _db;
    private readonly IHttpContextAccessor _httpContextAccessor;

    public DatabaseSessionService(TransmetroDbContext db, IHttpContextAccessor httpContextAccessor)
    {
        _db = db;
        _httpContextAccessor = httpContextAccessor;
    }

    public async Task EjecutarAsync(Func<Task> operacion)
    {
        var claim = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier);
        int.TryParse(claim, out var userId);
        var wasOpen = _db.Database.GetDbConnection().State == ConnectionState.Open;
        if (!wasOpen)
            await _db.Database.OpenConnectionAsync();

        try
        {
            if (userId > 0)
                await _db.Database.ExecuteSqlInterpolatedAsync(
                    $"EXEC sys.sp_set_session_context @key=N'UsuarioAplicacionID', @value={userId}");
            await operacion();
        }
        finally
        {
            await _db.Database.ExecuteSqlRawAsync(
                "EXEC sys.sp_set_session_context @key=N'UsuarioAplicacionID', @value=NULL");
            if (!wasOpen)
                await _db.Database.CloseConnectionAsync();
        }
    }
}
