using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class PublicacionesController : Controller
{
    private readonly IWebHostEnvironment _entorno;

    public PublicacionesController(IWebHostEnvironment entorno)
    {
        _entorno = entorno;
    }

    public IActionResult Index()
    {
        ViewBag.Ofertas = BD.ObtenerOfertasPublicadas(User.IdUsuario());
        ViewBag.EsEmpresa = User.EsEmpresa();
        return View();
    }

    [HttpGet]
    public IActionResult Nueva()
    {
        var modelo = new PublicarViewModel();
        Publicaciones.CargarFormulario(modelo, User.IdUsuario(), User.EsEmpresa(), true);
        ViewBag.Formulario = modelo;
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Nueva(PublicarViewModel modelo)
    {
        Publicaciones.CargarFormulario(modelo, User.IdUsuario(), User.EsEmpresa(), false);
        var empresa = User.EsEmpresa() ? BD.ObtenerEmpresaDeUsuario(User.IdUsuario()) : null;
        if (User.EsEmpresa() && empresa == null)
        {
            return RedirectToAction("IniciarSesion", "Cuenta");
        }

        var id = Publicaciones.Crear(modelo, User.IdUsuario(), empresa, ModelState);
        if (id == null)
        {
            ViewBag.Formulario = modelo;
            return View();
        }
        TempData["Mensaje"] = Publicaciones.MensajeCreada(empresa != null);
        return RedirectToAction(nameof(Detalle), new { id });
    }

    public IActionResult Detalle(int id)
    {
        var oferta = Publicaciones.OfertaPropia(id, User.IdUsuario());
        if (oferta == null)
        {
            return NotFound();
        }
        ViewBag.Oferta = oferta;
        ViewBag.Postulantes = BD.ObtenerPostulantes(id);
        return View();
    }

    public IActionResult Postulante(int id)
    {
        var datos = Publicaciones.Postulante(id, User.IdUsuario());
        if (datos == null)
        {
            return NotFound();
        }
        ViewBag.IDPostulacion = id;
        ViewBag.Oferta = datos.Value.Oferta;
        ViewBag.Perfil = datos.Value.Perfil;
        return View();
    }

    public IActionResult CV(int id)
    {
        var descarga = Publicaciones.CVDePostulante(id, User.IdUsuario(), _entorno.ContentRootPath);
        return descarga == null ? NotFound() : PhysicalFile(descarga.Ruta, descarga.Tipo, descarga.Nombre);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Cerrar(int id)
    {
        TempData["Mensaje"] = Publicaciones.Cerrar(id, User.IdUsuario()).Mensaje;
        return RedirectToAction(nameof(Detalle), new { id });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Eliminar(int id)
    {
        var resultado = Publicaciones.Eliminar(id, User.IdUsuario());
        TempData["Mensaje"] = resultado.Mensaje;
        TempData["MensajeTipo"] = resultado.Tipo;
        return RedirectToAction(nameof(Index));
    }
}
