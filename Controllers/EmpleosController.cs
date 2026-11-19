using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using Workly.Models;

namespace Workly.Controllers;

public class EmpleosController : Controller
{
    private readonly JSearch _jsearch;
    private readonly IMemoryCache _cache;

    public EmpleosController(JSearch jsearch, IMemoryCache cache)
    {
        _jsearch = jsearch;
        _cache = cache;
    }

    public IActionResult Index(BuscarTrabajoViewModel filtros)
    {
        ViewBag.Busqueda = Empleos.Preparar(filtros);
        ViewBag.UrlResultados = Url.Action(nameof(Resultados)) + Request.QueryString;
        return View();
    }

    public async Task<IActionResult> Resultados(BuscarTrabajoViewModel filtros)
    {
        ViewBag.Busqueda = await Empleos.Buscar(filtros, Request.Query, User.IdUsuario(), _jsearch, _cache);
        return PartialView("_Resultados");
    }

    public IActionResult Detalle(int id)
    {
        var detalle = Empleos.Detalle(id, User.IdUsuario(), User.EstaLogueado(), User.EsModerador(), User.EsEmpresa(), User.EsPersona());
        if (detalle == null)
        {
            return NotFound();
        }
        MostrarDetalle(detalle);
        return View();
    }

    public IActionResult Externa(int id)
    {
        var detalle = Empleos.DetalleExterna(id, User.IdUsuario(), User.EsEmpresa(), User.EsPersona());
        if (detalle == null)
        {
            return NotFound();
        }
        MostrarDetalle(detalle);
        return View("Detalle");
    }

    [HttpPost]
    [Authorize]
    [ValidateAntiForgeryToken]
    public IActionResult Postular(int id, string? volver) =>
        Volver(Empleos.Postular(User.IdUsuario(), id, User.EsPersona()), volver, id);

    [HttpPost]
    [Authorize]
    [ValidateAntiForgeryToken]
    public IActionResult RegistrarExterna(int id, string? volver) =>
        Volver(Empleos.RegistrarExterna(User.IdUsuario(), id, User.EsPersona()), volver, null, id);

    private void MostrarDetalle(DetalleOferta detalle)
    {
        ViewBag.Oferta = detalle.Oferta;
        ViewBag.Empresa = detalle.Empresa;
        ViewBag.EsPropia = detalle.EsPropia;
        ViewBag.EsRevision = detalle.EsRevision;
        ViewBag.PuedePostular = detalle.PuedePostular;
        ViewBag.TieneCV = detalle.TieneCV;
    }

    private IActionResult Volver(Resultado resultado, string? volver, int? idOferta, int? idExterna = null)
    {
        TempData["Mensaje"] = resultado.Mensaje;
        TempData["MensajeTipo"] = resultado.Tipo;
        if (!string.IsNullOrEmpty(volver) && Url.IsLocalUrl(volver))
        {
            return LocalRedirect(volver);
        }
        return idExterna.HasValue
            ? RedirectToAction(nameof(Externa), new { id = idExterna })
            : RedirectToAction(nameof(Detalle), new { id = idOferta });
    }
}
