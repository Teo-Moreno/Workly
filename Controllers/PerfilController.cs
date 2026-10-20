using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Helpers;
using Workly.Models;
using Workly.Servicios;

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
    public IActionResult Index()
    {
        var modelo = BD.ObtenerMiPerfil(User.IdUsuario());
        if (modelo == null)
        {
            // La cookie es de un usuario que ya no existe en la base
            return RedirectToAction("IniciarSesion", "Cuenta");
        }
        return View(modelo);
    }

    // Configuración y preferencias (mapa de sitio en Miro)
    public IActionResult Configuracion()
    {
        var modelo = BD.ObtenerMiPerfil(User.IdUsuario());
        if (modelo == null)
        {
            return RedirectToAction("IniciarSesion", "Cuenta");
        }
        return View(modelo);
    }

    // Descarga el CV de la persona logueada (los CV no son públicos)
    public IActionResult DescargarCV()
    {
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

    // Ayuda y soporte: se puede ver sin iniciar sesión
    [AllowAnonymous]
    public IActionResult Ayuda()
    {
        return View();
    }
}
