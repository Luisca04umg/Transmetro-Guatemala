using System.Threading.RateLimiting;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.EntityFrameworkCore;
using TransmetroGestion.Web.Data;
using TransmetroGestion.Web.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();
builder.Services.AddRateLimiter(options =>
{
    options.RejectionStatusCode = 429;
    options.AddPolicy("tarjeta", context => RateLimitPartition.GetFixedWindowLimiter(
        context.Connection.RemoteIpAddress?.ToString() ?? "local",
        _ => new FixedWindowRateLimiterOptions { PermitLimit = 20, Window = TimeSpan.FromMinutes(1), QueueLimit = 0 }));
});
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<PasswordService>();
builder.Services.AddScoped<DatabaseSessionService>();
builder.Services.AddScoped<RecorridosService>();
builder.Services.AddScoped<EdicionService>();
builder.Services.AddScoped<DirectorioService>();
builder.Services.AddScoped<RutasService>();

var connectionString = builder.Configuration.GetConnectionString("TransmetroDb")
    ?? throw new InvalidOperationException("No se encontró la cadena de conexión TransmetroDb.");

builder.Services.AddDbContext<TransmetroDbContext>(options =>
{
    options.UseSqlServer(connectionString, sql => sql.EnableRetryOnFailure(3));
    options.AddInterceptors(new ValidacionDatosInterceptor());
});

builder.Services
    .AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Cuenta/IniciarSesion";
        options.AccessDeniedPath = "/Cuenta/AccesoDenegado";
        options.Cookie.Name = "TransmetroGestion.Auth";
        options.Cookie.HttpOnly = true;
        options.Cookie.SameSite = SameSiteMode.Lax;
        options.ExpireTimeSpan = TimeSpan.FromHours(8);
        options.SlidingExpiration = true;
    })
    .AddCookie("Ciudadano", options =>
    {
        options.LoginPath = "/Ciudadano/Ingresar";
        options.Cookie.Name = "Transmetro.Ciudadano";
        options.Cookie.HttpOnly = true;
        options.Cookie.SameSite = SameSiteMode.Lax;
        options.ExpireTimeSpan = TimeSpan.FromMinutes(30);
    });

builder.Services.AddAuthorization(options =>
{
    string[] permisos =
    [
        "LINEAS_VER", "LINEAS_EDITAR", "ESTACIONES_VER", "ESTACIONES_EDITAR",
        "FLOTA_VER", "FLOTA_EDITAR", "PERSONAL_VER", "PERSONAL_EDITAR",
        "PAGOS_OPERAR", "ALERTAS_GESTIONAR", "REPORTES_VER",
        "USUARIOS_EDITAR", "AUDITORIA_VER"
    ];

    foreach (var permiso in permisos)
        options.AddPolicy(permiso, policy => policy.RequireClaim("permiso", permiso));
});

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();
app.UseRateLimiter();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
