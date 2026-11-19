using System.Globalization;
using System.Text;
using System.Text.Json.Nodes;
using DocumentFormat.OpenXml.Packaging;
using UglyToad.PdfPig;
using UglyToad.PdfPig.DocumentLayoutAnalysis.TextExtractor;

namespace Workly.Models;

public class LectorCV
{
    private const int LargoMaximo = 15000;

    private const string Instrucciones =
        "Leés currículums en español o inglés y devolvés solo un objeto JSON con estas claves: " +
        "\"sobre_mi\" (un resumen profesional en primera persona de hasta 400 caracteres, o null si el CV no da datos para armarlo), " +
        "\"experiencias\" (lista de objetos con \"puesto\", \"empresa\", \"descripcion\" de hasta 400 caracteres, \"inicio\" y \"fin\" en formato MM/AAAA; " +
        "\"fin\" es null si sigue trabajando ahí), " +
        "\"formaciones\" (lista de objetos con \"titulo\", \"institucion\", \"inicio\" y \"fin\" en formato MM/AAAA; \"fin\" es null si sigue cursando), " +
        "\"habilidades\" (lista de habilidades concretas, cada una de hasta 4 palabras), " +
        "\"idiomas\" (lista de objetos con \"idioma\" en español y \"nivel\", que tiene que ser Básico, Intermedio, Avanzado o Nativo). " +
        "Usá solo datos que estén escritos en el CV. No inventes nada. Si una fecha solo tiene el año, usá 01 como mes. " +
        "Si falta una fecha de inicio, no incluyas esa experiencia o formación.";

    private readonly Groq _groq;

    public LectorCV(Groq groq)
    {
        _groq = groq;
    }

    public bool Disponible => _groq.Configurada;

    public static string? ExtraerTexto(string ruta)
    {
        try
        {
            var extension = Path.GetExtension(ruta).ToLowerInvariant();
            string texto;
            if (extension == ".pdf")
            {
                using var documento = PdfDocument.Open(ruta);
                texto = string.Join("\n", documento.GetPages().Select(p => ContentOrderTextExtractor.GetText(p)));
            }
            else if (extension == ".docx")
            {
                using var documento = WordprocessingDocument.Open(ruta, false);
                var cuerpo = documento.MainDocumentPart?.Document?.Body;
                texto = cuerpo == null ? "" : string.Join("\n", cuerpo.Descendants<DocumentFormat.OpenXml.Wordprocessing.Paragraph>().Select(p => p.InnerText));
            }
            else
            {
                return null;
            }
            texto = texto.Trim();
            return texto.Length == 0 ? null : texto.Length > LargoMaximo ? texto[..LargoMaximo] : texto;
        }
        catch (Exception ex) when (ex is IOException or InvalidOperationException or ArgumentException or FormatException or OpenXmlPackageException)
        {
            return null;
        }
        catch (Exception ex) when (ex.GetType().Namespace?.StartsWith("UglyToad") == true)
        {
            return null;
        }
    }

    public async Task<string?> CompletarPerfil(int idUsuario, string ruta)
    {
        if (!Disponible)
        {
            return null;
        }
        var texto = ExtraerTexto(ruta);
        if (texto == null)
        {
            return "No pudimos leer el texto del CV para completar tu perfil. Probá con un PDF o un Word (.docx) que no sea una imagen escaneada.";
        }
        using var limite = new CancellationTokenSource(TimeSpan.FromSeconds(45));
        var datos = await _groq.ResponderJson(Instrucciones, texto, limite.Token);
        if (datos == null)
        {
            return "No pudimos completar tu perfil con los datos del CV en este momento. Podés cargarlos a mano.";
        }
        var perfil = BD.ObtenerMiPerfil(idUsuario);
        if (perfil == null)
        {
            return null;
        }
        return Aplicar(idUsuario, perfil, datos);
    }

    private static string Aplicar(int idUsuario, MiPerfilViewModel perfil, JsonObject datos)
    {
        var agregados = new List<string>();

        var sobreMi = Texto(datos["sobre_mi"], 500);
        if (string.IsNullOrWhiteSpace(perfil.Perfil.Descripcion) && sobreMi != null)
        {
            BD.ActualizarDescripcion(idUsuario, sobreMi);
            agregados.Add("tu \"Sobre mí\"");
        }

        var experiencias = 0;
        foreach (var item in Lista(datos["experiencias"]))
        {
            var puesto = Texto(item["puesto"], 100);
            var empresa = Texto(item["empresa"], 100);
            var inicio = Fecha(item["inicio"]);
            if (puesto == null || empresa == null || inicio == null || inicio > Fechas.MesActual)
            {
                continue;
            }
            if (perfil.Experiencias.Any(e => Igual(e.Puesto, puesto) && Igual(e.Empresa, empresa)))
            {
                continue;
            }
            var fin = Fecha(item["fin"]);
            BD.AgregarExperiencia(idUsuario, new ExperienciaNueva
            {
                Puesto = puesto,
                Empresa = empresa,
                Descripcion = Texto(item["descripcion"], 500),
                Inicio = inicio.Value,
                Fin = fin != null && fin >= inicio ? fin : null
            });
            perfil.Experiencias.Add(new ExperienciaItem { Puesto = puesto, Empresa = empresa });
            experiencias++;
        }
        if (experiencias > 0)
        {
            agregados.Add(experiencias == 1 ? "1 experiencia" : $"{experiencias} experiencias");
        }

        var formaciones = 0;
        foreach (var item in Lista(datos["formaciones"]))
        {
            var titulo = Texto(item["titulo"], 100);
            var institucion = Texto(item["institucion"], 100);
            var inicio = Fecha(item["inicio"]);
            if (titulo == null || institucion == null || inicio == null || inicio > Fechas.MesActual)
            {
                continue;
            }
            if (perfil.Formaciones.Any(f => Igual(f.Titulo, titulo) && Igual(f.Institucion, institucion)))
            {
                continue;
            }
            var fin = Fecha(item["fin"]);
            BD.AgregarFormacion(idUsuario, new FormacionNueva
            {
                Titulo = titulo,
                Institucion = institucion,
                Inicio = inicio.Value,
                Fin = fin != null && fin >= inicio ? fin : null
            });
            perfil.Formaciones.Add(new FormacionItem { Titulo = titulo, Institucion = institucion });
            formaciones++;
        }
        if (formaciones > 0)
        {
            agregados.Add(formaciones == 1 ? "1 formación" : $"{formaciones} formaciones");
        }

        var habilidades = perfil.Habilidades.ToList();
        var nuevasHabilidades = Lista(datos["habilidades"]).Select(h => Texto(h, 60)).OfType<string>()
            .Where(h => !habilidades.Any(e => Igual(e, h))).Distinct(StringComparer.OrdinalIgnoreCase)
            .Take(Math.Max(0, 40 - habilidades.Count)).ToList();
        habilidades.AddRange(nuevasHabilidades);

        var idiomas = perfil.Idiomas.Select(i => (i.IDIdioma, i.Nivel)).ToList();
        var catalogo = BD.ObtenerCatalogoIdiomas();
        var nuevosIdiomas = 0;
        foreach (var item in Lista(datos["idiomas"]))
        {
            var nombre = Texto(item["idioma"], 60);
            var nivel = Catalogos.NivelesIdioma.FirstOrDefault(n => Igual(n, Texto(item["nivel"], 30) ?? ""));
            var idioma = nombre == null ? null : catalogo.FirstOrDefault(c => Igual(c.Nombre, nombre));
            if (idioma == null || nivel == null || idiomas.Any(i => i.IDIdioma == idioma.ID))
            {
                continue;
            }
            idiomas.Add((idioma.ID, nivel));
            nuevosIdiomas++;
        }

        if (nuevasHabilidades.Count > 0 || nuevosIdiomas > 0)
        {
            BD.GuardarHabilidadesEIdiomas(idUsuario, habilidades, idiomas);
        }
        if (nuevasHabilidades.Count > 0)
        {
            agregados.Add(nuevasHabilidades.Count == 1 ? "1 habilidad" : $"{nuevasHabilidades.Count} habilidades");
        }
        if (nuevosIdiomas > 0)
        {
            agregados.Add(nuevosIdiomas == 1 ? "1 idioma" : $"{nuevosIdiomas} idiomas");
        }

        if (agregados.Count == 0)
        {
            return "Leímos tu CV, pero no encontramos datos nuevos para agregar a tu perfil.";
        }
        var lista = agregados.Count == 1 ? agregados[0] : string.Join(", ", agregados.Take(agregados.Count - 1)) + " y " + agregados[^1];
        return $"Con los datos del CV agregamos a tu perfil {lista}. Revisalos por si hay que corregir algo.";
    }

    private static IEnumerable<JsonNode> Lista(JsonNode? nodo) =>
        nodo is JsonArray lista ? lista.OfType<JsonNode>() : Enumerable.Empty<JsonNode>();

    private static string? Texto(JsonNode? nodo, int largo)
    {
        if (nodo is not JsonValue valor || !valor.TryGetValue<string>(out var texto))
        {
            return null;
        }
        texto = texto.Trim();
        if (texto.Length == 0 || texto.Equals("null", StringComparison.OrdinalIgnoreCase))
        {
            return null;
        }
        return texto.Length > largo ? texto[..largo].TrimEnd() : texto;
    }

    private static DateTime? Fecha(JsonNode? nodo) => Fechas.ParsearMesAnio(Texto(nodo, 10));

    private static bool Igual(string a, string b) =>
        string.Compare(a.Trim(), b.Trim(), CultureInfo.GetCultureInfo("es-AR"), CompareOptions.IgnoreCase | CompareOptions.IgnoreNonSpace) == 0;
}
