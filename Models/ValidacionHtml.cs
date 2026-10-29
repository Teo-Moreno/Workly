using Microsoft.AspNetCore.Mvc.Rendering;

namespace Workly.Models;

public static class ValidacionHtml
{
    public static string ClaseError(this IHtmlHelper html, string campo) =>
        TieneError(html, campo) ? "campo--error" : "";

    public static string MensajeError(this IHtmlHelper html, string campo, string porDefecto) =>
        html.ViewData.ModelState.TryGetValue(campo, out var estado) && estado.Errors.Count > 0
            ? estado.Errors[0].ErrorMessage
            : porDefecto;

    public static IEnumerable<string> ErroresGenerales(this IHtmlHelper html) =>
        html.ViewData.ModelState.TryGetValue(string.Empty, out var estado)
            ? estado.Errors.Select(e => e.ErrorMessage)
            : Enumerable.Empty<string>();

    private static bool TieneError(IHtmlHelper html, string campo) =>
        html.ViewData.ModelState.TryGetValue(campo, out var estado) && estado.Errors.Count > 0;
}
