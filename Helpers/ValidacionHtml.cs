using Microsoft.AspNetCore.Mvc.Rendering;

namespace Workly.Helpers;

/// <summary>
/// Conecta los errores de validación del servidor (ModelState) con los estilos
/// de campos del UI Kit (.campo--error y .campo__mensaje--error).
/// </summary>
public static class ValidacionHtml
{
    /// <summary>Devuelve "campo--error" si el campo tiene errores.</summary>
    public static string ClaseError(this IHtmlHelper html, string campo) =>
        TieneError(html, campo) ? "campo--error" : "";

    /// <summary>Mensaje del servidor para el campo, o el mensaje por defecto (para la validación en el navegador).</summary>
    public static string MensajeError(this IHtmlHelper html, string campo, string porDefecto) =>
        html.ViewData.ModelState.TryGetValue(campo, out var estado) && estado.Errors.Count > 0
            ? estado.Errors[0].ErrorMessage
            : porDefecto;

    /// <summary>Errores generales del formulario (no asociados a un campo).</summary>
    public static IEnumerable<string> ErroresGenerales(this IHtmlHelper html) =>
        html.ViewData.ModelState.TryGetValue(string.Empty, out var estado)
            ? estado.Errors.Select(e => e.ErrorMessage)
            : Enumerable.Empty<string>();

    private static bool TieneError(IHtmlHelper html, string campo) =>
        html.ViewData.ModelState.TryGetValue(campo, out var estado) && estado.Errors.Count > 0;
}
