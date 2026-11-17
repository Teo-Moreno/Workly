using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class PostulacionesController : Controller
{
    public IActionResult Index()
    {
        if (User.EsEmpresa())
        {
            return RedirectToAction("Index", "Publicaciones");
        }
        var postulaciones = BD.ObtenerPostulaciones(User.IdUsuario());
        ViewBag.HayPostulaciones = postulaciones.Count > 0;
        ViewBag.Columnas = ColumnaTablero.Armar(postulaciones);
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult CambiarEstado(int id, string estado)
    {
        var cambiado = Postulaciones.CambiarEstado(User.IdUsuario(), id, estado);
        if (Request.Headers.Accept.ToString().Contains("application/json"))
        {
            return cambiado ? Json(new { ok = true }) : BadRequest(new { ok = false });
        }
        TempData["Mensaje"] = cambiado ? $"Movimos la postulación a \"{estado}\"." : "No pudimos mover la postulación.";
        TempData["MensajeTipo"] = cambiado ? "exito" : "error";
        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Eliminar(int id)
    {
        var resultado = Postulaciones.Eliminar(User.IdUsuario(), id);
        TempData["Mensaje"] = resultado.Mensaje;
        TempData["MensajeTipo"] = resultado.Tipo;
        return RedirectToAction(nameof(Index));
    }
}
