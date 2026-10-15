using Microsoft.AspNetCore.Mvc;

namespace Workly.Controllers;

public class PerfilController : Controller
{
    // Mi perfil (Figma › Media · WF 05)
    public IActionResult Index()
    {
        return View();
    }

    // Configuración y preferencias (mapa de sitio en Miro)
    public IActionResult Configuracion()
    {
        return View();
    }

    // Ayuda y soporte (mapa de sitio en Miro)
    public IActionResult Ayuda()
    {
        return View();
    }
}
