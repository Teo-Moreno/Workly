using Microsoft.AspNetCore.WebUtilities;

namespace Workly.Models;

public static class Vistas
{
    public static readonly System.Globalization.CultureInfo Cultura = new("es-AR");

    public static string Url(string ruta, params (string Nombre, object? Valor)[] parametros) =>
        QueryHelpers.AddQueryString(ruta, parametros
            .Where(p => p.Valor != null && p.Valor.ToString() != "")
            .Select(p => new KeyValuePair<string, string?>(p.Nombre, p.Valor!.ToString())));

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

    public static string Clave(string texto) =>
        string.Concat(texto.Normalize(System.Text.NormalizationForm.FormD)
            .Where(c => char.IsAsciiLetterOrDigit(c) || c == ' ')).Trim().ToLowerInvariant().Replace(' ', '-');
}

public class Menu
{
    private readonly string? _controlador;
    private readonly string? _accion;

    public Menu(string? controlador, string? accion)
    {
        _controlador = controlador;
        _accion = accion;
    }

    public string Clase(string controlador) =>
        string.Equals(_controlador, controlador, StringComparison.OrdinalIgnoreCase) ? "nav-link active" : "nav-link";

    public string Clase(string controlador, string accion) =>
        string.Equals(_accion, accion, StringComparison.OrdinalIgnoreCase) ? Clase(controlador) : "nav-link";
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
    public string UrlGoogle => Vistas.Url("/Cuenta/Externo", ("proveedor", "Google"), ("tipo", Tipo), ("returnUrl", ReturnUrl));
    public string UrlLinkedIn => Vistas.Url("/Cuenta/Externo", ("proveedor", "LinkedIn"), ("tipo", Tipo), ("returnUrl", ReturnUrl));
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
