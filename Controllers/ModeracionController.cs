using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Workly.Models;

namespace Workly.Controllers;

// Revisión de las búsquedas que publican las personas (solo cuentas moderadoras).
// Aceptada: se publica junto a las demás. Rechazada: queda el motivo, que la persona ve
// en "Mis publicaciones" (el aviso por mail se suma cuando esté el envío de mails).
[Authorize]
public class ModeracionController : Controller
{
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

    // Muestra la búsqueda exactamente como la vería una persona al entrar
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
    public IActionResult Rechazar(int id, string? motivo)
    {
        var texto = (motivo ?? "").Replace("\r\n", "\n").Trim();
        if (texto.Length is < 10 or > 500)
        {
            TempData["Mensaje"] = "Escribí el motivo del rechazo (entre 10 y 500 caracteres): se lo vamos a mostrar a quien la publicó.";
            TempData["MensajeTipo"] = "error";
            return RedirectToAction(nameof(Revisar), new { id });
        }
        TempData["Mensaje"] = BD.RevisarOferta(id, false, texto)
            ? "Rechazaste la búsqueda. Quien la publicó va a ver el motivo."
            : "Esa búsqueda ya estaba revisada.";
        return RedirectToAction(nameof(Index));
    }
}
