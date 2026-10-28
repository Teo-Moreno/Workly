using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

// Tablero de postulaciones de la persona: ella misma mueve cada una entre
// Enviada, En revisión, Pasé y No pasé.
[Authorize]
public class PostulacionesController : Controller
{
    public IActionResult Index()
    {
        if (User.EsEmpresa())
        {
            return RedirectToAction("Index", "Publicaciones");
        }
        return View(BD.ObtenerPostulaciones(User.IdUsuario()));
    }

    // Lo usa el tablero al arrastrar una tarjeta (fetch) y el menú de cada tarjeta (formulario)
    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult CambiarEstado(int id, string estado)
    {
        var valido = Catalogos.EstadosPostulacion.Any(e => e.Estado == estado);
        var cambiado = valido && BD.CambiarEstadoPostulacion(User.IdUsuario(), id, estado);
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
        var borrada = BD.EliminarPostulacion(User.IdUsuario(), id);
        TempData["Mensaje"] = borrada ? "Sacamos la postulación de tu tablero." : "No encontramos esa postulación.";
        TempData["MensajeTipo"] = borrada ? "exito" : "error";
        return RedirectToAction(nameof(Index));
    }
}
