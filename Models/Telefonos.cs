namespace Workly.Models;

/// <summary>
/// Formato de los teléfonos de Argentina: código de área + número, 10 números en total
/// (sin el 0 ni el 15). Se guardan con el prefijo del país: "+54 11 5555-1234".
/// El JavaScript del formulario usa la misma lista de códigos de área para escribirlos igual.
/// </summary>
public static class Telefonos
{
    public const int Digitos = 10;

    // Códigos de área de 3 números. El 11 (AMBA) es el único de 2; el resto son de 4.
    public static readonly string[] CodigosDeArea3 =
    {
        "220", "221", "223", "230", "236", "237", "249", "260", "261", "263", "264", "266",
        "280", "291", "294", "297", "298", "299", "336", "341", "342", "343", "345", "348",
        "351", "353", "358", "362", "364", "370", "376", "379", "380", "381", "383", "385",
        "387", "388"
    };

    public static string SoloDigitos(string? texto) => new((texto ?? "").Where(char.IsAsciiDigit).ToArray());

    /// <summary>"1155551234" → "11 5555-1234"; "3515551234" → "351 555-1234".</summary>
    public static string Formatear(string digitos)
    {
        var largoArea = digitos.StartsWith("11") ? 2 : CodigosDeArea3.Contains(digitos[..Math.Min(3, digitos.Length)]) ? 3 : 4;
        if (digitos.Length <= largoArea)
        {
            return digitos;
        }

        var area = digitos[..largoArea];
        var numero = digitos[largoArea..];
        var corte = Digitos - largoArea - 4; // el guion va antes de los últimos 4 números
        return numero.Length > corte ? $"{area} {numero[..corte]}-{numero[corte..]}" : $"{area} {numero}";
    }

    /// <summary>Quita el prefijo del país: "+54 11 5555-1234" → "11 5555-1234".</summary>
    public static string ParteLocal(string? telefono, string? codigoPais)
    {
        var texto = (telefono ?? "").Trim();
        if (!string.IsNullOrEmpty(codigoPais) && texto.StartsWith(codigoPais))
        {
            texto = texto[codigoPais.Length..].Trim();
        }
        return texto;
    }
}
