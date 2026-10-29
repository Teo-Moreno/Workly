using System.Security.Cryptography;

namespace Workly.Models;

public static class Contrasenas
{
    private const string Prefijo = "PBKDF2";
    private const int Iteraciones = 600_000;
    private const int BytesSal = 16;
    private const int BytesHash = 32;

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
