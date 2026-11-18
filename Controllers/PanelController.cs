using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class PanelController : Controller
{
    public IActionResult Index()
    {
        if (User.EsEmpresa())
        {
            return RedirectToAction("Index", "Publicaciones");
        }

        var perfil = BD.ObtenerMiPerfil(User.IdUsuario());
        if (perfil == null)
        {
            return RedirectToAction("IniciarSesion", "Cuenta");
        }

        ViewBag.Perfil = perfil;
        ViewBag.Puesto = perfil.Preferencia.Puesto_Buscado;
        ViewBag.UrlParaVos = Url.Action(nameof(ParaVos));
        return View();
    }

    public IActionResult ParaVos()
    {
        var perfil = User.EsPersona() ? BD.ObtenerMiPerfil(User.IdUsuario()) : null;
        ViewBag.Puesto = perfil?.Preferencia.Puesto_Buscado;
        ViewBag.ParaVos = perfil == null ? new List<Oferta>() : Empleos.ParaVos(perfil, User.IdUsuario());
        return PartialView("_ParaVos");
    }
}
