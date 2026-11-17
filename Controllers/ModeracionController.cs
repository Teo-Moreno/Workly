using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class ModeracionController : Controller
{
    private readonly Correo _correo;

    public ModeracionController(Correo correo)
    {
        _correo = correo;
    }

    public override void OnActionExecuting(ActionExecutingContext context)
    {
        if (!User.EsModerador())
        {
            context.Result = NotFound();
        }
    }

    public IActionResult Index()
    {
        ViewBag.Pendientes = BD.ObtenerOfertasPendientes();
        ViewBag.Revisadas = BD.ObtenerOfertasRevisadas(20);
        return View();
    }

    public IActionResult Revisar(int id)
    {
        var detalle = Empleos.ParaRevisar(id);
        if (detalle == null)
        {
            return NotFound();
        }
        ViewBag.Oferta = detalle.Oferta;
        ViewBag.Empresa = detalle.Empresa;
        ViewBag.EsPropia = detalle.EsPropia;
        ViewBag.EsRevision = detalle.EsRevision;
        ViewBag.PuedePostular = detalle.PuedePostular;
        ViewBag.TieneCV = detalle.TieneCV;
        return View("~/Views/Empleos/Detalle.cshtml");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Aceptar(int id)
    {
        TempData["Mensaje"] = Moderacion.Aceptar(id);
        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Rechazar(int id, string? motivo)
    {
        var resultado = await Moderacion.Rechazar(id, motivo, Url.Action("Index", "Publicaciones", null, Request.Scheme), _correo);
        TempData["Mensaje"] = resultado.Mensaje;
        if (!resultado.Exito)
        {
            TempData["MensajeTipo"] = resultado.Tipo;
            return RedirectToAction(nameof(Revisar), new { id });
        }
        return RedirectToAction(nameof(Index));
    }
}
