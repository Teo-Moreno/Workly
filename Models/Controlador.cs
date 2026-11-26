using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace Workly.Models;

public class Controlador : Controller
{
    private readonly string _layout;

    public Controlador(string layout)
    {
        _layout = layout;
    }

    public override void OnActionExecuting(ActionExecutingContext context)
    {
        ViewBag.Layout = _layout;
        ViewBag.Errores = new Errores(ModelState);
        base.OnActionExecuting(context);
    }

    public override void OnActionExecuted(ActionExecutedContext context)
    {
        if (context.Result is ViewResult)
        {
            var aca = Request.Path + Request.QueryString;
            ViewBag.Volver = aca;
            ViewBag.UrlIngresar = Vistas.Url("/Cuenta/IniciarSesion", ("returnUrl", aca));
            ViewBag.Inicio = !User.EstaLogueado() ? "/" : User.EsEmpresa() ? "/Publicaciones" : "/Panel";
            ViewBag.Menu = new Menu(RouteData.Values["controller"]?.ToString(), RouteData.Values["action"]?.ToString());
            if (_layout == "_LayoutApp")
            {
                ViewBag.TienePublicaciones = User.EstaLogueado() && !User.EsEmpresa() && BD.TieneOfertasPublicadas(User.IdUsuario());
                ViewBag.OfertasPendientes = User.EsModerador() ? BD.ContarOfertasPendientes() : 0;
            }
        }
        base.OnActionExecuted(context);
    }
}
