using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

public class AsistenteController : Controller
{
    private readonly Asistente _asistente;

    public AsistenteController(Asistente asistente)
    {
        _asistente = asistente;
    }

    public IActionResult Index(string? c)
    {
        if (User.EsEmpresa())
        {
            return RedirectToAction("Index", "Publicaciones");
        }
        var id = string.IsNullOrWhiteSpace(c) || c.Length != 32 ? Asistente.NuevaConversacion() : c;
        ViewBag.Conversacion = id;
        ViewBag.Mensajes = _asistente.Conversacion(id, User.IdUsuario());
        ViewBag.Disponible = _asistente.Disponible;
        ViewBag.Lleno = ViewBag.Mensajes.Count >= Asistente.MaximoMensajes;
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Enviar(string? c, string? mensaje)
    {
        if (User.EsEmpresa())
        {
            return RedirectToAction("Index", "Publicaciones");
        }
        var id = string.IsNullOrWhiteSpace(c) || c.Length != 32 ? Asistente.NuevaConversacion() : c;
        var resultado = await _asistente.Enviar(id, User.IdUsuario(), mensaje);
        if (!resultado.Exito)
        {
            TempData["Mensaje"] = resultado.Mensaje;
            TempData["MensajeTipo"] = resultado.Tipo;
        }
        return Redirect(Url.Action(nameof(Index), new { c = id }) + "#ultimo");
    }
}
