using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Workly.Models;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();
builder.Services.AddMemoryCache();

// Ofertas de otros sitios (JSearch). La clave va en user-secrets: JSearch:ApiKey
builder.Services.AddHttpClient<JSearch>();

// Sesión con cookie: se crea al iniciar sesión o al registrarse (ver CuentaController)
var autenticacion = builder.Services
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
    })
    // Cookie corta mientras la persona vuelve de Google o LinkedIn
    .AddCookie(Sesion.EsquemaExterno, opciones =>
    {
        opciones.Cookie.Name = "Workly.Externo";
        opciones.ExpireTimeSpan = TimeSpan.FromMinutes(30);
    });

// Iniciar sesión con Google o LinkedIn: solo si están configuradas sus claves (dotnet user-secrets: Authentication:Google:ClientId/ClientSecret y Authentication:LinkedIn:ClientId/ClientSecret)
var google = builder.Configuration.GetSection("Authentication:Google");
if (!string.IsNullOrEmpty(google["ClientId"]) && !string.IsNullOrEmpty(google["ClientSecret"]))
{
    autenticacion.AddGoogle("Google", opciones =>
    {
        opciones.ClientId = google["ClientId"]!;
        opciones.ClientSecret = google["ClientSecret"]!;
        opciones.SignInScheme = Sesion.EsquemaExterno;
        opciones.CallbackPath = "/signin-google";
        opciones.ClaimActions.MapJsonKey("picture", "picture");
    });
}

var linkedin = builder.Configuration.GetSection("Authentication:LinkedIn");
if (!string.IsNullOrEmpty(linkedin["ClientId"]) && !string.IsNullOrEmpty(linkedin["ClientSecret"]))
{
    autenticacion.AddOpenIdConnect("LinkedIn", "LinkedIn", opciones =>
    {
        opciones.Authority = "https://www.linkedin.com/oauth";
        opciones.ClientId = linkedin["ClientId"];
        opciones.ClientSecret = linkedin["ClientSecret"];
        opciones.ResponseType = OpenIdConnectResponseType.Code;
        opciones.SignInScheme = Sesion.EsquemaExterno;
        opciones.CallbackPath = "/signin-linkedin";
        opciones.UsePkce = false;
        opciones.GetClaimsFromUserInfoEndpoint = true;
        opciones.MapInboundClaims = false;
        opciones.Scope.Clear();
        foreach (var permiso in new[] { "openid", "profile", "email" })
        {
            opciones.Scope.Add(permiso);
        }
    });
}

// Base de datos: appsettings.json › ConnectionStrings › Workly
BD.Configurar(builder.Configuration.GetConnectionString("Workly")
    ?? throw new InvalidOperationException("Falta la cadena de conexión \"Workly\" en appsettings.json"));

var app = builder.Build();

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

// Las fotos y logos se suben mientras la app corre (wwwroot/uploads): MapStaticAssets
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
