namespace Workly.Models;

/// <summary>
/// Controles para registrar una cuenta de empresa:
/// - CUIT válido (11 números con el dígito verificador correcto).
/// - Email del mismo dominio que el sitio web de la empresa (no se aceptan
///   gmail, hotmail, etc.), así quien se registra tiene un mail de la empresa.
/// </summary>
public static class VerificacionEmpresa
{
    private static readonly int[] Pesos = { 5, 4, 3, 2, 7, 6, 5, 4, 3, 2 };

    private static readonly string[] DominiosGratuitos =
    {
        "gmail.com", "googlemail.com", "hotmail.com", "hotmail.com.ar", "outlook.com", "outlook.com.ar", "live.com",
        "live.com.ar", "yahoo.com", "yahoo.com.ar", "icloud.com", "me.com", "aol.com", "protonmail.com", "proton.me",
        "gmx.com", "mail.com", "yandex.com", "fibertel.com.ar", "speedy.com.ar", "arnet.com.ar"
    };

    /// <summary>Deja solo los números: "30-71234567-1" → "30712345671".</summary>
    public static string SoloNumeros(string? cuit) => new((cuit ?? "").Where(char.IsAsciiDigit).ToArray());

    /// <summary>"30712345671" → "30-71234567-1".</summary>
    public static string Formatear(string cuit) =>
        cuit.Length == 11 ? $"{cuit[..2]}-{cuit[2..10]}-{cuit[10]}" : cuit;

    public static bool CuitValido(string? texto)
    {
        var cuit = SoloNumeros(texto);
        if (cuit.Length != 11 || !new[] { "20", "23", "24", "27", "30", "33", "34" }.Contains(cuit[..2]))
        {
            return false;
        }

        var suma = 0;
        for (var i = 0; i < 10; i++)
        {
            suma += (cuit[i] - '0') * Pesos[i];
        }
        var resto = 11 - suma % 11;
        var verificador = resto == 11 ? 0 : resto == 10 ? 9 : resto;
        return cuit[10] - '0' == verificador;
    }

    /// <summary>"https://www.acme.com.ar/contacto" → "acme.com.ar". Null si no es una dirección válida.</summary>
    public static string? DominioDelSitio(string? sitio)
    {
        if (string.IsNullOrWhiteSpace(sitio))
        {
            return null;
        }
        var texto = sitio.Trim();
        if (!texto.StartsWith("http://", StringComparison.OrdinalIgnoreCase) && !texto.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
        {
            texto = "https://" + texto;
        }
        if (!Uri.TryCreate(texto, UriKind.Absolute, out var uri) || !uri.Host.Contains('.'))
        {
            return null;
        }
        var host = uri.Host.ToLowerInvariant();
        return host.StartsWith("www.") ? host[4..] : host;
    }

    public static string DominioDelEmail(string email)
    {
        var arroba = email.LastIndexOf('@');
        return arroba >= 0 ? email[(arroba + 1)..].Trim().ToLowerInvariant() : "";
    }

    public static bool EsEmailGratuito(string email) => DominiosGratuitos.Contains(DominioDelEmail(email));

    /// <summary>El email es de la empresa: rrhh@acme.com.ar o rrhh@ar.acme.com con el sitio acme.com.ar / acme.com.</summary>
    public static bool EmailCoincideConSitio(string email, string? sitio)
    {
        var dominioSitio = DominioDelSitio(sitio);
        var dominioEmail = DominioDelEmail(email);
        return dominioSitio != null && dominioEmail.Length > 0 &&
               (dominioEmail == dominioSitio || dominioEmail.EndsWith("." + dominioSitio) || dominioSitio.EndsWith("." + dominioEmail));
    }
}
