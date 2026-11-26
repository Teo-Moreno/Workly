using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class GuardadasController : Controlador
{
    public GuardadasController() : base("_LayoutApp")
    {
    }

    public IActionResult Index()
    {
        if (User.EsEmpresa())
        {
            return RedirectToAction("Index", "Publicaciones");
        }
        ViewBag.Guardadas = BD.ObtenerGuardadas(User.IdUsuario());
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Guardar(int id, bool externa, string? volver) =>
        Volver(Postulaciones.Guardar(User.IdUsuario(), id, externa, User.EsPersona()), volver);

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Quitar(int id, bool externa, string? volver) =>
        Volver(Postulaciones.QuitarGuardada(User.IdUsuario(), id, externa), volver);

    private IActionResult Volver(Resultado resultado, string? volver)
    {
        TempData["Mensaje"] = resultado.Mensaje;
        TempData["MensajeTipo"] = resultado.Tipo;
        return !string.IsNullOrEmpty(volver) && Url.IsLocalUrl(volver) ? LocalRedirect(volver) : RedirectToAction(nameof(Index));
    }
}
