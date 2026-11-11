using System.Security.Claims;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;

namespace Workly.Models;

public static class Vistas
{
    public static readonly System.Globalization.CultureInfo Cultura = new("es-AR");

    public static string? Actual(this ViewContext vista, string controlador) =>
        string.Equals(vista.RouteData.Values["controller"]?.ToString(), controlador, StringComparison.OrdinalIgnoreCase) ? "page" : null;

    public static string? ActualAccion(this ViewContext vista, string controlador, string accion) =>
        vista.Actual(controlador) != null && string.Equals(vista.RouteData.Values["action"]?.ToString(), accion, StringComparison.OrdinalIgnoreCase) ? "page" : null;

    public static string Activo(this ViewContext vista, string controlador) => vista.Actual(controlador) != null ? "esta-activo" : "";

    public static string ClaseLink(this ViewContext vista, string controlador, string? accion = null) =>
        (accion == null ? vista.Actual(controlador) : vista.ActualAccion(controlador, accion)) != null ? "nav-link active" : "nav-link";

    public static string Volver(this ViewContext vista) =>
        vista.ViewData["Volver"] as string ?? (vista.HttpContext.Request.Path + vista.HttpContext.Request.QueryString);

    public static string AquiMismo(this ViewContext vista) =>
        vista.HttpContext.Request.Path + vista.HttpContext.Request.QueryString;

    public static int OfertasPendientes(this ViewContext vista)
    {
        var items = vista.HttpContext.Items;
        if (items["Pendientes"] is not int pendientes)
        {
            pendientes = vista.HttpContext.User.EsModerador() ? BD.ContarOfertasPendientes() : 0;
            items["Pendientes"] = pendientes;
        }
        return pendientes;
    }

    public static bool TienePublicaciones(this ViewContext vista)
    {
        var items = vista.HttpContext.Items;
        if (items["TienePublicaciones"] is not bool tiene)
        {
            var usuario = vista.HttpContext.User;
            tiene = usuario.EstaLogueado() && !usuario.EsEmpresa() && BD.TieneOfertasPublicadas(usuario.IdUsuario());
            items["TienePublicaciones"] = tiene;
        }
        return tiene;
    }

    public static string? Inicio(this IUrlHelper url, ClaimsPrincipal usuario) =>
        !usuario.EstaLogueado() ? url.Action("Index", "Home") : usuario.EsEmpresa() ? url.Action("Index", "Publicaciones") : url.Action("Index", "Panel");

    public static bool EsPropia(this ClaimsPrincipal usuario, int? idPublicador) =>
        usuario.EstaLogueado() && idPublicador == usuario.IdUsuario();

    public static string Hoy
    {
        get
        {
            var hoy = DateTime.Today.ToString("dddd d 'de' MMMM", Cultura);
            return char.ToUpper(hoy[0]) + hoy[1..];
        }
    }

    public static string Fecha(DateTime fecha, string formato = "d 'de' MMMM") => fecha.ToString(formato, Cultura);

    public static string Fecha(DateTime? fecha, string formato = "d 'de' MMMM") => fecha?.ToString(formato, Cultura) ?? "";
}

public class LogoEmpresa
{
    public LogoEmpresa(string? logo, string nombre, string clases)
    {
        Logo = logo;
        Nombre = nombre;
        Clases = string.IsNullOrWhiteSpace(clases) ? "logo-empresa" : clases;
    }

    public string? Logo { get; }
    public string Nombre { get; }
    public string Clases { get; }
}

public class BotonesExternos
{
    public BotonesExternos(string texto, string? tipo, string? returnUrl)
    {
        Texto = texto;
        Tipo = tipo;
        ReturnUrl = returnUrl;
    }

    public string Texto { get; }
    public string? Tipo { get; }
    public string? ReturnUrl { get; }
}

public class ColumnaTablero
{
    public string Estado { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Color { get; set; } = "";
    public List<PostulacionItem> Tarjetas { get; set; } = new();

    public static List<ColumnaTablero> Armar(List<PostulacionItem> postulaciones) =>
        Catalogos.EstadosPostulacion.Select(e => new ColumnaTablero
        {
            Estado = e.Estado,
            Nombre = e.Columna,
            Color = e.Color,
            Tarjetas = postulaciones.Where(p => p.Estado == e.Estado).ToList()
        }).ToList();
}
