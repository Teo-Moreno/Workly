using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.AspNetCore.Razor.TagHelpers;

namespace Workly.Models;

[HtmlTargetElement("icono", TagStructure = TagStructure.WithoutEndTag)]
public class IconoTagHelper : TagHelper
{
    private const string Sprite = "/img/iconos.svg";

    public string Nombre { get; set; } = "";

    public int Tamano { get; set; } = 24;

    public string? Etiqueta { get; set; }

    [ViewContext]
    [HtmlAttributeNotBound]
    public ViewContext ViewContext { get; set; } = default!;

    public override void Process(TagHelperContext context, TagHelperOutput output)
    {
        output.TagName = "svg";
        output.TagMode = TagMode.StartTagAndEndTag;

        var claseExtra = output.Attributes.TryGetAttribute("class", out var clase) ? $" {clase.Value}" : "";
        output.Attributes.SetAttribute("class", $"icono{claseExtra}");
        output.Attributes.SetAttribute("width", Tamano);
        output.Attributes.SetAttribute("height", Tamano);
        output.Attributes.SetAttribute("focusable", "false");

        if (string.IsNullOrWhiteSpace(Etiqueta))
        {
            output.Attributes.SetAttribute("aria-hidden", "true");
        }
        else
        {
            output.Attributes.SetAttribute("role", "img");
            output.Attributes.SetAttribute("aria-label", Etiqueta);
        }

        var basePath = ViewContext.HttpContext.Request.PathBase;
        output.Content.SetHtmlContent($"<use href=\"{basePath}{Sprite}#{Nombre}\"></use>");
    }
}
