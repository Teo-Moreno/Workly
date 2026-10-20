using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Workly.Helpers;
using Workly.Models;
using Workly.Servicios;

namespace Workly.Controllers;

public class CuentaController : Controller
{
    private const string ErrorConexion =
        "No pudimos conectarnos con la base de datos. Revisá que SQL Server esté funcionando y la cadena de conexión en appsettings.json.";

    private readonly IWebHostEnvironment _entorno;
    private readonly ILogger<CuentaController> _logger;

    public CuentaController(IWebHostEnvironment entorno, ILogger<CuentaController> logger)
    {
        _entorno = entorno;
        _logger = logger;
    }

    // ------------------------------------------------------------ Iniciar sesión

    [HttpGet]
    public IActionResult IniciarSesion(string? returnUrl = null)
    {
        if (User.EstaLogueado())
        {
            return RedirigirDespuesDeIngresar(returnUrl);
        }
        return View(new LoginViewModel { ReturnUrl = returnUrl });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> IniciarSesion(LoginViewModel modelo)
    {
        if (!ModelState.IsValid)
        {
            return View(modelo);
        }

        Usuario? usuario;
        Perfil? perfil = null;
        try
        {
            usuario = BD.ObtenerUsuarioPorEmail(NormalizarEmail(modelo.Email));
            if (usuario != null)
            {
                perfil = BD.ObtenerPerfil(usuario.ID);
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos al iniciar sesión");
            ModelState.AddModelError(string.Empty, ErrorConexion);
            return View(modelo);
        }

        // Si el email no existe igual se verifica un hash de relleno, así la respuesta tarda lo mismo.
        if (!Contrasenas.Verificar(modelo.Contrasena, usuario?.Contraseña) || usuario == null)
        {
            ModelState.AddModelError(string.Empty, "El email o la contraseña no son correctos.");
            modelo.Contrasena = "";
            return View(modelo);
        }

        await CrearSesion(usuario, perfil, modelo.Recordarme);
        TempData["Mensaje"] = $"¡Hola de nuevo, {usuario.Nombre}!";
        return RedirigirDespuesDeIngresar(modelo.ReturnUrl);
    }

    // ------------------------------------------------------------ Crear cuenta

    [HttpGet]
    public IActionResult CrearCuenta()
    {
        if (User.EstaLogueado())
        {
            return RedirectToAction("Index", "Panel");
        }
        return View(new RegistroViewModel());
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(12 * 1024 * 1024)]
    public async Task<IActionResult> CrearCuenta(RegistroViewModel modelo)
    {
        if (User.EstaLogueado())
        {
            return RedirectToAction("Index", "Panel");
        }

        modelo.Email = NormalizarEmail(modelo.Email);
        modelo.Nombre = modelo.Nombre?.Trim() ?? "";
        modelo.Apellido = modelo.Apellido?.Trim() ?? "";

        if (!string.IsNullOrEmpty(modelo.Ubicacion) && !RegistroViewModel.Ubicaciones.Contains(modelo.Ubicacion))
        {
            ModelState.AddModelError(nameof(modelo.Ubicacion), "Elegí una ubicación de la lista");
        }

        var errorFoto = Archivos.Validar(modelo.Foto, Archivos.ExtensionesFoto);
        if (errorFoto != null)
        {
            ModelState.AddModelError(nameof(modelo.Foto), errorFoto);
        }

        var errorCV = Archivos.Validar(modelo.ArchivoCV, Archivos.ExtensionesCV);
        if (errorCV != null)
        {
            ModelState.AddModelError(nameof(modelo.ArchivoCV), errorCV);
        }

        try
        {
            if (ModelState.IsValid && BD.ExisteEmail(modelo.Email))
            {
                ModelState.AddModelError(nameof(modelo.Email), "Ya hay una cuenta con ese email. ¿Querés iniciar sesión?");
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos al validar el email");
            ModelState.AddModelError(string.Empty, ErrorConexion);
        }

        if (!ModelState.IsValid)
        {
            return VolverAlRegistro(modelo);
        }

        // Archivos: se guardan antes de insertar; si el INSERT falla se borran.
        var rutaFoto = await Archivos.GuardarFoto(modelo.Foto, _entorno.WebRootPath);
        var nombreCV = await Archivos.GuardarCV(modelo.ArchivoCV, _entorno.ContentRootPath);

        var usuario = new Usuario
        {
            Nombre = modelo.Nombre,
            Apellido = modelo.Apellido,
            Email = modelo.Email,
            Contraseña = Contrasenas.Hashear(modelo.Contrasena)
        };
        var perfil = new Perfil
        {
            Foto = rutaFoto,
            Descripcion = Limpiar(modelo.Descripcion),
            Ubicacion = modelo.Ubicacion,
            Telefono = Limpiar(modelo.Telefono)
        };
        var sitioWeb = Limpiar(modelo.SitioWeb);
        var cv = nombreCV != null || sitioWeb != null
            ? new CV { Nombre_Archivo = nombreCV, Sitio_Web = sitioWeb }
            : null;

        try
        {
            usuario.ID = BD.RegistrarUsuario(usuario, perfil, cv);
        }
        catch (SqlException ex)
        {
            BorrarArchivosSubidos(rutaFoto, nombreCV);

            // 2627 / 2601: el email ya existe (por ejemplo, dos registros al mismo tiempo)
            if (ex.Number is 2627 or 2601)
            {
                ModelState.AddModelError(nameof(modelo.Email), "Ya hay una cuenta con ese email. ¿Querés iniciar sesión?");
            }
            else
            {
                _logger.LogError(ex, "Error de base de datos al registrar un usuario");
                ModelState.AddModelError(string.Empty, ErrorConexion);
            }
            return VolverAlRegistro(modelo);
        }

        await CrearSesion(usuario, perfil, recordarme: true);
        TempData["Mensaje"] = $"¡Te damos la bienvenida a Workly, {usuario.Nombre}! Tu cuenta está lista.";
        return RedirectToAction("Index", "Panel");
    }

    // ------------------------------------------------------------ Cerrar sesión

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CerrarSesion()
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        TempData["Mensaje"] = "Cerraste sesión. ¡Hasta pronto!";
        return RedirectToAction("Index", "Home");
    }

    // ------------------------------------------------------------ Recuperar contraseña (solo visual por ahora)

    [HttpGet]
    public IActionResult RecuperarClave()
    {
        return View();
    }

    // ------------------------------------------------------------ Auxiliares

    private async Task CrearSesion(Usuario usuario, Perfil? perfil, bool recordarme)
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, usuario.ID.ToString()),
            new(ClaimTypes.Name, usuario.NombreCompleto),
            new(ClaimTypes.GivenName, usuario.Nombre),
            new(ClaimTypes.Surname, usuario.Apellido),
            new(ClaimTypes.Email, usuario.Email)
        };
        if (!string.IsNullOrEmpty(perfil?.Ubicacion))
        {
            claims.Add(new Claim(UsuarioActual.ClaimUbicacion, perfil.Ubicacion));
        }
        if (!string.IsNullOrEmpty(perfil?.Foto))
        {
            claims.Add(new Claim(UsuarioActual.ClaimFoto, perfil.Foto));
        }

        var identidad = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
        var propiedades = new AuthenticationProperties
        {
            IsPersistent = recordarme,
            ExpiresUtc = recordarme ? DateTimeOffset.UtcNow.AddDays(14) : null
        };
        await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(identidad), propiedades);
    }

    // La contraseña no se devuelve en el HTML: si hubo errores se pide escribirla de nuevo,
    // así el formulario abre en el paso 1 y la persona recorre los pasos marcados en rojo.
    private IActionResult VolverAlRegistro(RegistroViewModel modelo)
    {
        modelo.Contrasena = "";
        if (ModelState[nameof(modelo.Contrasena)]?.Errors.Count is null or 0)
        {
            ModelState.AddModelError(nameof(modelo.Contrasena), "Por seguridad, volvé a escribir tu contraseña");
        }
        return View(modelo);
    }

    // Solo redirige a direcciones de este sitio (evita redirecciones abiertas a otros dominios).
    private IActionResult RedirigirDespuesDeIngresar(string? returnUrl) =>
        !string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl)
            ? LocalRedirect(returnUrl)
            : RedirectToAction("Index", "Panel");

    private void BorrarArchivosSubidos(string? rutaFoto, string? nombreCV)
    {
        if (rutaFoto != null)
        {
            Archivos.Borrar(Path.Combine(_entorno.WebRootPath, rutaFoto.TrimStart('/').Replace('/', Path.DirectorySeparatorChar)));
        }
        if (nombreCV != null)
        {
            Archivos.Borrar(Path.Combine(Archivos.CarpetaCV(_entorno.ContentRootPath), nombreCV));
        }
    }

    private static string NormalizarEmail(string? email) => (email ?? "").Trim().ToLowerInvariant();

    private static string? Limpiar(string? texto) => string.IsNullOrWhiteSpace(texto) ? null : texto.Trim();
}
