using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

// Ofertas guardadas de la persona (tablas Favorito y FavoritoOferta).
// Se puede guardar una búsqueda de Workly o una oferta de otro sitio.
[Authorize]
public class GuardadasController : Controller
{
    public IActionResult Index()
    {
        if (User.EsEmpresa())
        {
            return RedirectToAction("Index", "Publicaciones");
        }
        return View(BD.ObtenerGuardadas(User.IdUsuario()));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Guardar(int id, bool externa, string? volver)
    {
        if (!User.EsPersona())
        {
            return Volver("Las cuentas de empresa no guardan ofertas.", "error", volver);
        }
        return BD.GuardarOferta(User.IdUsuario(), id, externa)
            ? Volver("Guardamos la oferta. La encontrás en Guardadas.", "exito", volver)
            : Volver("Esa oferta ya estaba guardada o ya no está publicada.", "advertencia", volver);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Quitar(int id, bool externa, string? volver)
    {
        return BD.QuitarGuardada(User.IdUsuario(), id, externa)
            ? Volver("Sacamos la oferta de tus guardadas.", "exito", volver)
            : Volver("Esa oferta no estaba en tus guardadas.", "advertencia", volver);
    }

    private IActionResult Volver(string mensaje, string tipo, string? volver)
    {
        TempData["Mensaje"] = mensaje;
        TempData["MensajeTipo"] = tipo;
        return !string.IsNullOrEmpty(volver) && Url.IsLocalUrl(volver) ? LocalRedirect(volver) : RedirectToAction(nameof(Index));
    }
}
