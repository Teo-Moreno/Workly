using System.Security.Cryptography;

namespace Workly.Models;

/// <summary>
/// Hash de contraseñas con PBKDF2-SHA256 (recomendación de OWASP: 600.000 iteraciones).
/// Formato guardado en Usuario.Contraseña: "PBKDF2$iteraciones$sal$hash" (sal y hash en Base64).
/// Nunca se guarda ni se compara la contraseña en texto plano.
/// </summary>
public static class Contrasenas
{
    private const string Prefijo = "PBKDF2";
    private const int Iteraciones = 600_000;
    private const int BytesSal = 16;
    private const int BytesHash = 32;

    // Hash de relleno para que verificar un email inexistente tarde lo mismo
    // que uno existente (evita adivinar qué emails están registrados).
    private static readonly string HashDeRelleno = Hashear("workly-relleno");

    public static string Hashear(string contrasena)
    {
        var sal = RandomNumberGenerator.GetBytes(BytesSal);
        var hash = Rfc2898DeriveBytes.Pbkdf2(contrasena, sal, Iteraciones, HashAlgorithmName.SHA256, BytesHash);
        return $"{Prefijo}${Iteraciones}${Convert.ToBase64String(sal)}${Convert.ToBase64String(hash)}";
    }

    public static bool Verificar(string contrasena, string? guardado)
    {
        if (string.IsNullOrEmpty(guardado))
        {
            Verificar(contrasena, HashDeRelleno);
            return false;
        }

        var partes = guardado.Split('$');
        if (partes.Length != 4 || partes[0] != Prefijo || !int.TryParse(partes[1], out var iteraciones) || iteraciones <= 0)
        {
            return false;
        }

        try
        {
            var sal = Convert.FromBase64String(partes[2]);
            var esperado = Convert.FromBase64String(partes[3]);
            var calculado = Rfc2898DeriveBytes.Pbkdf2(contrasena, sal, iteraciones, HashAlgorithmName.SHA256, esperado.Length);
            return CryptographicOperations.FixedTimeEquals(calculado, esperado);
        }
        catch (FormatException)
        {
            return false;
        }
    }
}
