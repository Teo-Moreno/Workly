using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class PanelController : Controlador
{
    public PanelController() : base("_LayoutApp")
    {
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
        ViewBag.TextoCargando = "Buscando ofertas para vos…";
        ViewBag.UrlVerTodas = Vistas.Url("/Empleos", ("Q", perfil.Preferencia.Puesto_Buscado));
        ViewBag.Publicadas = BD.ObtenerOfertasPublicadas(User.IdUsuario(), 3);
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
