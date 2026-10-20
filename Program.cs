using Microsoft.AspNetCore.Authentication.Cookies;
using Workly.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

// Sesión con cookie: se crea al iniciar sesión o al registrarse (ver CuentaController)
builder.Services
    .AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(opciones =>
    {
        opciones.LoginPath = "/Cuenta/IniciarSesion";
        opciones.LogoutPath = "/Cuenta/CerrarSesion";
        opciones.AccessDeniedPath = "/Cuenta/IniciarSesion";
        opciones.Cookie.Name = "Workly.Sesion";
        opciones.Cookie.HttpOnly = true;
        opciones.Cookie.SameSite = SameSiteMode.Lax;
        opciones.ExpireTimeSpan = TimeSpan.FromDays(14);
        opciones.SlidingExpiration = true;
    });

// Base de datos: appsettings.json › ConnectionStrings › Workly
BD.Configurar(builder.Configuration.GetConnectionString("Workly")
    ?? throw new InvalidOperationException("Falta la cadena de conexión \"Workly\" en appsettings.json"));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

// Las fotos de perfil se suben mientras la app corre (wwwroot/uploads): MapStaticAssets
// solo conoce los archivos del build, así que estas se sirven con UseStaticFiles.
// Va después de UseRouting para que el CSS y el JS sigan saliendo por MapStaticAssets
// (comprimidos y con caché); UseStaticFiles solo atiende lo que no tiene endpoint.
app.UseStaticFiles();
app.MapStaticAssets();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();


app.Run();
