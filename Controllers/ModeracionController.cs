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
        return View(new ModeracionViewModel
        {
            Pendientes = BD.ObtenerOfertasPendientes(),
            Revisadas = BD.ObtenerOfertasRevisadas(20)
        });
    }

    public IActionResult Revisar(int id)
    {
        var oferta = BD.ObtenerOferta(id, 0);
        if (oferta == null)
        {
            return NotFound();
        }
        return View("~/Views/Empleos/Detalle.cshtml", new OfertaDetalleViewModel
        {
            Oferta = oferta,
            Empresa = oferta.IDEmpresa.HasValue ? BD.ObtenerEmpresa(oferta.IDEmpresa.Value) : null,
            EsRevision = true
        });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Aceptar(int id)
    {
        TempData["Mensaje"] = BD.RevisarOferta(id, true, null)
            ? "Aceptaste la búsqueda: ya está publicada."
            : "Esa búsqueda ya estaba revisada.";
        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Rechazar(int id, string? motivo)
    {
        var texto = (motivo ?? "").Replace("\r\n", "\n").Trim();
        if (texto.Length is < 10 or > 500)
        {
            TempData["Mensaje"] = "Escribí el motivo del rechazo (entre 10 y 500 caracteres): se lo vamos a mostrar a quien la publicó.";
            TempData["MensajeTipo"] = "error";
            return RedirectToAction(nameof(Revisar), new { id });
        }
        if (!BD.RevisarOferta(id, false, texto))
        {
            TempData["Mensaje"] = "Esa búsqueda ya estaba revisada.";
            return RedirectToAction(nameof(Index));
        }

        var oferta = BD.ObtenerOferta(id, 0);
        var publicador = oferta?.IDUsuario_Publicador is int idPublicador ? BD.ObtenerUsuarioPorId(idPublicador) : null;
        var mandado = false;
        if (oferta != null && publicador != null && _correo.Configurado)
        {
            var enlace = Url.Action("Index", "Publicaciones", null, Request.Scheme);
            mandado = await _correo.Enviar(publicador.Email, $"Workly: tu búsqueda \"{oferta.Titulo}\" no se publicó",
                $"Hola, {publicador.Nombre}.\n\n" +
                $"Revisamos tu búsqueda \"{oferta.Titulo}\" y no la pudimos publicar. Este es el motivo:\n\n" +
                $"{texto}\n\n" +
                $"Podés verla en Mis publicaciones y publicar una nueva con los cambios: {enlace}\n\n" +
                "Workly");
        }
        TempData["Mensaje"] = mandado
            ? "Rechazaste la búsqueda. Le mandamos un mail con el motivo a quien la publicó, y también lo ve en Mis publicaciones."
            : "Rechazaste la búsqueda. Quien la publicó va a ver el motivo en Mis publicaciones.";
        return RedirectToAction(nameof(Index));
    }
}
