using System.Text.RegularExpressions;

namespace Workly.Models;

public class BloqueDescripcion
{
    public string Tipo { get; set; } = "parrafo";
    public string Texto { get; set; } = "";
    public List<string> Items { get; set; } = new();

    public bool EsTitulo => Tipo == "titulo";
    public bool EsLista => Tipo == "lista";
}

public static class Descripciones
{
    private const string Vinetas = "•·●▪◦►➢➤✔✓✅-–—*";

    private static readonly Regex VinetaEnLinea = new(@"\s+[•·●▪◦►➢➤✔✓✅]\s+", RegexOptions.Compiled);

    private static readonly Regex TituloConDosPuntos = new(
        @"(?<=^|[\s.;!?])((?:principales\s+|qué\s+|que\s+)?(?:responsabilidades|requisitos|requerimientos|funciones|tareas|beneficios|ofrecemos|se\s+ofrece|te\s+ofrecemos|condiciones|perfil\s+buscado|perfil|competencias|conocimientos|habilidades|lugar\s+de\s+trabajo|horario|horarios|modalidad|jornada|zona\s+de\s+trabajo|deseable|valoramos|objetivo\s+del\s+puesto|sobre\s+nosotros|sobre\s+el\s+puesto)(?:\s+[a-záéíóúñ]+){0,2})\s*:\s*",
        RegexOptions.Compiled | RegexOptions.IgnoreCase);

    private static readonly Regex TituloEnMayusculas = new(
        @"^((?:[A-ZÁÉÍÓÚÑÜ]{2,}[\s/&,]+){1,6}[A-ZÁÉÍÓÚÑÜ]{2,}):?\s+(?=[A-ZÁÉÍÓÚÑ¿¡][a-záéíóúñü])", RegexOptions.Compiled);

    private static readonly Regex FinDeOracion = new(@"(?<=[a-záéíóúñü0-9)][.;])\s+(?=[A-ZÁÉÍÓÚÑ¿¡])", RegexOptions.Compiled);

    private static readonly string[] TitulosDeLista =
    {
        "responsabilidad", "requisito", "requerimiento", "funcion", "función", "tarea", "beneficio", "ofrecemos", "ofrece",
        "competencia", "conocimiento", "habilidad", "deseable", "valoramos"
    };

    public static List<BloqueDescripcion> Armar(string? texto)
    {
        var bloques = new List<BloqueDescripcion>();
        if (string.IsNullOrWhiteSpace(texto))
        {
            return bloques;
        }

        texto = texto.Replace("\r\n", "\n").Replace('\r', '\n').Trim();
        var plano = !texto.Contains('\n');
        if (plano)
        {
            texto = VinetaEnLinea.Replace(texto, "\n• ");
            texto = TituloConDosPuntos.Replace(texto, m => "\n§" + m.Groups[1].Value.Trim() + "\n");
        }

        BloqueDescripcion? lista = null;
        string? tituloActual = null;
        foreach (var crudo in texto.Split('\n'))
        {
            var linea = crudo.Trim();
            if (linea.Length == 0)
            {
                lista = null;
                continue;
            }

            if (linea.StartsWith('§'))
            {
                lista = null;
                tituloActual = linea[1..].Trim();
                Agregar(bloques, "titulo", tituloActual);
                continue;
            }

            var esVineta = Vinetas.Contains(linea[0]) && (linea.Length == 1 || char.IsWhiteSpace(linea[1]) || linea[0] is '•' or '●' or '▪' or '✔' or '✓' or '✅' or '►' or '➢' or '➤');
            if (esVineta)
            {
                linea = linea.TrimStart(Vinetas.ToCharArray()).Trim();
                if (linea.Length == 0)
                {
                    continue;
                }
            }

            var mayusculas = TituloEnMayusculas.Match(linea);
            if (mayusculas.Success && mayusculas.Groups[1].Value.Length >= 6)
            {
                lista = null;
                tituloActual = mayusculas.Groups[1].Value.Trim(' ', ',', '/');
                Agregar(bloques, "titulo", Capitalizar(tituloActual));
                linea = linea[mayusculas.Length..].Trim();
                esVineta = false;
            }
            else if (!esVineta && EsTitulo(linea))
            {
                lista = null;
                tituloActual = linea.TrimEnd(':').Trim();
                Agregar(bloques, "titulo", EsMayuscula(tituloActual) ? Capitalizar(tituloActual) : tituloActual);
                continue;
            }

            if (esVineta)
            {
                lista = AgregarItem(bloques, lista, linea);
            }
            else if (plano && tituloActual != null && EsTituloDeLista(tituloActual) && FinDeOracion.Split(linea).Length > 1)
            {
                foreach (var oracion in FinDeOracion.Split(linea))
                {
                    lista = AgregarItem(bloques, lista, oracion.Trim());
                }
                lista = null;
            }
            else
            {
                lista = null;
                Agregar(bloques, "parrafo", linea);
            }
        }
        return bloques;
    }

    private static void Agregar(List<BloqueDescripcion> bloques, string tipo, string texto)
    {
        if (texto.Length > 0)
        {
            bloques.Add(new BloqueDescripcion { Tipo = tipo, Texto = texto });
        }
    }

    private static BloqueDescripcion? AgregarItem(List<BloqueDescripcion> bloques, BloqueDescripcion? lista, string item)
    {
        if (item.Length == 0)
        {
            return lista;
        }
        if (lista == null)
        {
            lista = new BloqueDescripcion { Tipo = "lista" };
            bloques.Add(lista);
        }
        lista.Items.Add(item);
        return lista;
    }

    private static bool EsTitulo(string linea)
    {
        var letras = linea.TrimStart().SkipWhile(c => !char.IsLetter(c)).ToArray();
        if (letras.Length < 3 || linea.Length > 70)
        {
            return false;
        }
        var texto = new string(letras).Trim();
        return (texto.EndsWith(':') && !texto.TrimEnd(':').Contains(". ")) || (EsMayuscula(texto) && !texto.EndsWith('.') && texto.Count(char.IsLetter) >= 4);
    }

    private static bool EsMayuscula(string texto) =>
        texto.Any(char.IsLetter) && texto.Where(char.IsLetter).All(char.IsUpper);

    private static bool EsTituloDeLista(string titulo)
    {
        var minuscula = titulo.ToLowerInvariant();
        return TitulosDeLista.Any(minuscula.Contains);
    }

    private static string Capitalizar(string texto)
    {
        var minuscula = texto.ToLowerInvariant();
        var inicio = minuscula.TakeWhile(c => !char.IsLetter(c)).Count();
        return inicio >= minuscula.Length ? minuscula : minuscula[..inicio] + char.ToUpperInvariant(minuscula[inicio]) + minuscula[(inicio + 1)..];
    }
}
