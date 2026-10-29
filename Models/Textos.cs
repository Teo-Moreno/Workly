namespace Workly.Models;

public static class Textos
{
    public static string Iniciales(string? nombre)
    {
        var palabras = (nombre ?? "").Split(' ', StringSplitOptions.RemoveEmptyEntries)
                                     .Where(p => char.IsLetterOrDigit(p[0])).ToList();
        var iniciales = string.Concat(palabras.Take(2).Select(p => char.ToUpperInvariant(p[0])));
        return iniciales.Length > 0 ? iniciales : "?";
    }

    public static string? Enlace(string? sitio)
    {
        if (string.IsNullOrWhiteSpace(sitio))
        {
            return null;
        }
        var texto = sitio.Trim();
        return texto.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || texto.StartsWith("https://", StringComparison.OrdinalIgnoreCase)
            ? texto
            : "https://" + texto;
    }

    public static string Pesos(int monto) => "$" + monto.ToString("N0", new System.Globalization.CultureInfo("es-AR"));

    public static string Publicada(DateTime? fecha)
    {
        if (fecha == null)
        {
            return "";
        }
        var dias = (DateTime.Today - fecha.Value.Date).Days;
        return dias switch
        {
            <= 0 => "Publicada hoy",
            1 => "Publicada ayer",
            < 30 => $"Publicada hace {dias} días",
            _ => "Publicada el " + fecha.Value.ToString("d 'de' MMMM", new System.Globalization.CultureInfo("es-AR"))
        };
    }

    public static string Recortar(string? texto, int largo)
    {
        if (string.IsNullOrWhiteSpace(texto))
        {
            return "";
        }
        var limpio = string.Join(' ', texto.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));
        if (limpio.Length <= largo)
        {
            return limpio;
        }
        var corte = limpio.LastIndexOf(' ', largo);
        return limpio[..(corte > 0 ? corte : largo)] + "…";
    }
}
