using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class PerfilController : Controller
{
    private readonly IWebHostEnvironment _entorno;

    public PerfilController(IWebHostEnvironment entorno)
    {
        _entorno = entorno;
    }

    // Mi perfil (Figma › Media · WF 05), con los datos de la base
    public async Task<IActionResult> Index()
    {
        var modelo = ObtenerMiPerfil();
        return modelo == null ? await SesionInvalida() : View(modelo);
    }

    // Configuración y preferencias (mapa de sitio en Miro)
    public async Task<IActionResult> Configuracion()
    {
        var modelo = ObtenerMiPerfil();
        if (modelo == null)
        {
            return await SesionInvalida();
        }
        modelo.Paises = BD.ObtenerPaises();
        modelo.Provincias = BD.ObtenerProvincias();
        return View(modelo);
    }

    // Descarga el CV de la persona logueada (los CV no son públicos)
    public async Task<IActionResult> DescargarCV()
    {
        if (!EsUsuarioDeLaSesion(BD.ObtenerUsuarioPorId(User.IdUsuario())))
        {
            return await SesionInvalida();
        }

        var cv = BD.ObtenerCV(User.IdUsuario());
        if (string.IsNullOrEmpty(cv?.Nombre_Archivo) || cv.Nombre_Archivo != Path.GetFileName(cv.Nombre_Archivo))
        {
            return NotFound();
        }

        var ruta = Path.Combine(Archivos.CarpetaCV(_entorno.ContentRootPath), cv.Nombre_Archivo);
        if (!System.IO.File.Exists(ruta))
        {
            return NotFound();
        }

        var tipo = Path.GetExtension(ruta).ToLowerInvariant() switch
        {
            ".pdf" => "application/pdf",
            ".doc" => "application/msword",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            _ => "application/octet-stream"
        };
        return PhysicalFile(ruta, tipo, cv.NombreOriginal ?? "CV" + Path.GetExtension(ruta));
    }

    // ------------------------------------------------------------ Auxiliares

    // Datos de "Mi perfil" de quien inició sesión, o null si la cookie no corresponde a ese usuario.
    private MiPerfilViewModel? ObtenerMiPerfil()
    {
        var modelo = BD.ObtenerMiPerfil(User.IdUsuario());
        return EsUsuarioDeLaSesion(modelo?.Usuario) ? modelo : null;
    }

    // La cookie guarda el ID y el email: si la base se volvió a crear, el ID puede no existir
    // o ser de otra persona. En ese caso no se muestra nada.
    private bool EsUsuarioDeLaSesion(Usuario? usuario) =>
        usuario != null && string.Equals(usuario.Email, User.Email(), StringComparison.OrdinalIgnoreCase);

    // Se cierra la sesión para que el login muestre el formulario (si no, devolvería al panel).
    private async Task<IActionResult> SesionInvalida()
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        return RedirectToAction("IniciarSesion", "Cuenta");
    }

    // Ayuda y soporte: se puede ver sin iniciar sesión
    [AllowAnonymous]
    public IActionResult Ayuda()
    {
        return View();
    }
}
