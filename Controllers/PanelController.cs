using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class PanelController : Controller
{
    private readonly JSearch _jsearch;

    public PanelController(JSearch jsearch)
    {
        _jsearch = jsearch;
    }

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

    public async Task<IActionResult> ParaVos()
    {
        var perfil = User.EsPersona() ? BD.ObtenerMiPerfil(User.IdUsuario()) : null;
        ViewBag.Puesto = perfil?.Preferencia.Puesto_Buscado;
        ViewBag.ErrorExternas = false;
        ViewBag.ParaVos = new List<Oferta>();
        if (perfil != null)
        {
            var (ofertas, error) = await Empleos.ParaVos(perfil, User.IdUsuario(), _jsearch);
            ViewBag.ParaVos = ofertas;
            ViewBag.ErrorExternas = error;
        }
        return PartialView("_ParaVos");
    }
}
