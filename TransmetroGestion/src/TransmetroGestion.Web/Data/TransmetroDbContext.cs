using System.Data;
using System.Security.Claims;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Models;

namespace TransmetroGestion.Web.Data;

public class TransmetroDbContext : DbContext
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public TransmetroDbContext(
        DbContextOptions<TransmetroDbContext> options,
        IHttpContextAccessor httpContextAccessor)
        : base(options)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    // =============================================
    // ENTIDADES
    // =============================================

    public DbSet<Municipalidad> Municipalidades => Set<Municipalidad>();
    public DbSet<Linea> Lineas => Set<Linea>();
    public DbSet<Estacion> Estaciones => Set<Estacion>();
    public DbSet<LineaEstacion> LineasEstaciones => Set<LineaEstacion>();
    public DbSet<TramoLinea> TramosLinea => Set<TramoLinea>();
    public DbSet<Acceso> Accesos => Set<Acceso>();
    public DbSet<Parqueo> Parqueos => Set<Parqueo>();
    public DbSet<Bus> Buses => Set<Bus>();
    public DbSet<LineaBus> LineasBuses => Set<LineaBus>();
    public DbSet<HistorialParqueoBus> HistorialParqueos => Set<HistorialParqueoBus>();
    public DbSet<AsignacionPilotoBus> AsignacionesPilotoBus => Set<AsignacionPilotoBus>();
    public DbSet<RegistroParadaViaje> RegistrosParadaViaje => Set<RegistroParadaViaje>();
    public DbSet<PaseLineaTarjeta> PasesLineaTarjeta => Set<PaseLineaTarjeta>();
    public DbSet<Viaje> Viajes => Set<Viaje>();
    public DbSet<VisitaEstacionViaje> VisitasEstacionViaje => Set<VisitaEstacionViaje>();
    public DbSet<ConteoEstacion> ConteosEstacion => Set<ConteoEstacion>();
    public DbSet<AlertaOcupacion> AlertasOcupacion => Set<AlertaOcupacion>();
    public DbSet<RegistroOcupacionBus> RegistrosOcupacionBus => Set<RegistroOcupacionBus>();
    public DbSet<EsperaAdicional> EsperasAdicionales => Set<EsperaAdicional>();
    public DbSet<Piloto> Pilotos => Set<Piloto>();
    public DbSet<HistorialEducativoPiloto> HistorialEducativoPilotos => Set<HistorialEducativoPiloto>();
    public DbSet<Guardia> Guardias => Set<Guardia>();
    public DbSet<AsignacionGuardiaAcceso> AsignacionesGuardiaAcceso => Set<AsignacionGuardiaAcceso>();
    public DbSet<Operador> Operadores => Set<Operador>();
    public DbSet<AsignacionOperadorEstacion> AsignacionesOperadorEstacion => Set<AsignacionOperadorEstacion>();
    public DbSet<Usuario> Usuarios => Set<Usuario>();
    public DbSet<Rol> Roles => Set<Rol>();
    public DbSet<Permiso> Permisos => Set<Permiso>();
    public DbSet<UsuarioRol> UsuariosRoles => Set<UsuarioRol>();
    public DbSet<RolPermiso> RolesPermisos => Set<RolPermiso>();
    public DbSet<Bitacora> Bitacora => Set<Bitacora>();
    public DbSet<TitularTarjeta> TitularesTarjeta => Set<TitularTarjeta>();
    public DbSet<TarjetaAcceso> TarjetasAcceso => Set<TarjetaAcceso>();
    public DbSet<TransaccionTarjeta> TransaccionesTarjeta => Set<TransaccionTarjeta>();

    // =============================================
    // VISTAS DE CONSULTA
    // =============================================

    public DbSet<VistaEstacion> VistaEstaciones => Set<VistaEstacion>();
    public DbSet<VistaLinea> VistaLineas => Set<VistaLinea>();
    public DbSet<VistaBusPorLinea> VistaBusesPorLinea => Set<VistaBusPorLinea>();
    public DbSet<VistaEstacionPorLinea> VistaEstacionesPorLinea => Set<VistaEstacionPorLinea>();
    public DbSet<VistaAlertaPendiente> VistaAlertasPendientes => Set<VistaAlertaPendiente>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        // Las tablas incluyen triggers de integridad y auditoría.
        foreach (var entity in modelBuilder.Model.GetEntityTypes())
            if (entity.GetTableName() is not null)
                entity.SetAnnotation("SqlServer:UseSqlOutputClause", false);
        modelBuilder.Entity<AsignacionPilotoBus>().HasKey(x => x.AsignacionID);
        modelBuilder.Entity<RegistroParadaViaje>().HasKey(x => x.RegistroParadaID);
        modelBuilder.Entity<PaseLineaTarjeta>().HasKey(x => x.PaseID);

        // =============================================
        // CLAVES PRIMARIAS COMPUESTAS
        // =============================================

        modelBuilder.Entity<LineaEstacion>()
            .HasKey(x => new { x.LineaID, x.EstacionID });

        modelBuilder.Entity<VisitaEstacionViaje>()
            .HasKey(x => new { x.ViajeID, x.EstacionID });

        modelBuilder.Entity<UsuarioRol>()
            .HasKey(x => new { x.UsuarioID, x.RolID });

        modelBuilder.Entity<RolPermiso>()
            .HasKey(x => new { x.RolID, x.PermisoID });

        // =============================================
        // CLAVES PRIMARIAS INDIVIDUALES
        // =============================================

        modelBuilder.Entity<LineaBus>()
            .HasKey(x => x.BusID);

        modelBuilder.Entity<TramoLinea>()
            .HasKey(x => x.TramoID);

        modelBuilder.Entity<HistorialParqueoBus>()
            .HasKey(x => x.HistorialParqueoID);

        modelBuilder.Entity<AlertaOcupacion>()
            .HasKey(x => x.AlertaID);

        modelBuilder.Entity<RegistroOcupacionBus>()
            .HasKey(x => x.RegistroOcupacionID);

        modelBuilder.Entity<EsperaAdicional>()
            .HasKey(x => x.EsperaID);

        modelBuilder.Entity<HistorialEducativoPiloto>()
            .HasKey(x => x.HistorialEducativoID);

        modelBuilder.Entity<AsignacionGuardiaAcceso>()
            .HasKey(x => x.AsignacionGuardiaID);

        modelBuilder.Entity<AsignacionOperadorEstacion>()
            .HasKey(x => x.AsignacionOperadorID);

        modelBuilder.Entity<TitularTarjeta>()
            .HasKey(x => x.TitularID);

        modelBuilder.Entity<TarjetaAcceso>()
            .HasKey(x => x.TarjetaID);

        modelBuilder.Entity<TransaccionTarjeta>()
            .HasKey(x => x.TransaccionID);

        // =============================================
        // VISTAS DE CONSULTA SIN CLAVE
        // =============================================

        modelBuilder.Entity<VistaEstacion>()
            .HasNoKey()
            .ToView("vw_Estaciones", "rep");

        modelBuilder.Entity<VistaLinea>()
            .HasNoKey()
            .ToView("vw_Lineas", "rep");

        modelBuilder.Entity<VistaBusPorLinea>()
            .HasNoKey()
            .ToView("vw_BusesPorLinea", "rep");

        modelBuilder.Entity<VistaEstacionPorLinea>()
            .HasNoKey()
            .ToView("vw_EstacionesPorLinea", "rep");

        modelBuilder.Entity<VistaAlertaPendiente>()
            .HasNoKey()
            .ToView("vw_AlertasPendientes", "rep");

        // =============================================
        // PRECISIÓN DE VALORES DECIMALES
        // =============================================

        modelBuilder.Entity<Estacion>()
            .Property(x => x.Latitud)
            .HasPrecision(9, 6);

        modelBuilder.Entity<Estacion>()
            .Property(x => x.Longitud)
            .HasPrecision(9, 6);

        modelBuilder.Entity<TramoLinea>()
            .Property(x => x.DistanciaKm)
            .HasPrecision(9, 3);

        modelBuilder.Entity<AlertaOcupacion>()
            .Property(x => x.Porcentaje)
            .HasPrecision(7, 2);

        modelBuilder.Entity<RegistroOcupacionBus>()
            .Property(x => x.PorcentajeOcupacion)
            .HasPrecision(7, 2);

        modelBuilder.Entity<TarjetaAcceso>()
            .Property(x => x.Saldo)
            .HasPrecision(12, 2);

        modelBuilder.Entity<TransaccionTarjeta>()
            .Property(x => x.Monto)
            .HasPrecision(12, 2);

        modelBuilder.Entity<TransaccionTarjeta>()
            .Property(x => x.SaldoAnterior)
            .HasPrecision(12, 2);

        modelBuilder.Entity<TransaccionTarjeta>()
            .Property(x => x.SaldoNuevo)
            .HasPrecision(12, 2);
    }

    // =============================================
    // GUARDAR CAMBIOS CON EL USUARIO DE APLICACIÓN
    // =============================================

    public override Task<int> SaveChangesAsync(
        CancellationToken cancellationToken = default)
        => SaveWithApplicationUserAsync(cancellationToken);

    private async Task<int> SaveWithApplicationUserAsync(
        CancellationToken cancellationToken)
    {
        var claim = _httpContextAccessor.HttpContext?
            .User.FindFirstValue(ClaimTypes.NameIdentifier);

        if (!int.TryParse(claim, out var userId))
        {
            return await base.SaveChangesAsync(cancellationToken);
        }

        var connection = Database.GetDbConnection();
        var wasOpen = connection.State == ConnectionState.Open;

        if (!wasOpen)
        {
            await Database.OpenConnectionAsync(cancellationToken);
        }

        try
        {
            await Database.ExecuteSqlInterpolatedAsync(
                $"EXEC sys.sp_set_session_context @key=N'UsuarioAplicacionID', @value={userId}",
                cancellationToken);

            return await base.SaveChangesAsync(cancellationToken);
        }
        finally
        {
            await Database.ExecuteSqlRawAsync(
                "EXEC sys.sp_set_session_context @key=N'UsuarioAplicacionID', @value=NULL",
                cancellationToken);

            if (!wasOpen)
            {
                await Database.CloseConnectionAsync();
            }
        }
    }
}