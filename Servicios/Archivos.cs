using Microsoft.AspNetCore.Http;

namespace Workly.Servicios;

/// <summary>
/// Validación y guardado de archivos subidos (foto de perfil y CV).
/// - Las fotos se guardan en wwwroot/uploads/fotos (son públicas).
/// - Los CV se guardan en ArchivosPrivados/cv (fuera de wwwroot): solo se
///   descargan desde /Perfil/DescargarCV, con la sesión iniciada.
/// </summary>
public static class Archivos
{
    public const long TamanoMaximo = 5 * 1024 * 1024; // 5 MB

    public static readonly string[] ExtensionesFoto = { ".jpg", ".jpeg", ".png", ".webp" };
    public static readonly string[] ExtensionesCV = { ".pdf", ".doc", ".docx" };

    /// <summary>Devuelve un mensaje de error o null si el archivo es válido.</summary>
    public static string? Validar(IFormFile? archivo, string[] extensionesPermitidas)
    {
        if (archivo == null || archivo.Length == 0)
        {
            return null;
        }

        if (archivo.Length > TamanoMaximo)
        {
            return "El archivo pesa más de 5 MB";
        }

        var extension = Path.GetExtension(archivo.FileName).ToLowerInvariant();
        if (!extensionesPermitidas.Contains(extension) || !FirmaValida(archivo, extension))
        {
            return $"Subí un archivo {Formatos(extensionesPermitidas)}";
        }

        return null;
    }

    /// <summary>Lista legible de formatos: { ".jpg", ".jpeg", ".png" } → "JPG o PNG".</summary>
    public static string Formatos(string[] extensiones)
    {
        var nombres = extensiones.Select(e => e.TrimStart('.').ToUpperInvariant())
                                 .Where(e => e != "JPEG" || !extensiones.Contains(".jpg"))
                                 .ToList();
        return nombres.Count == 1
            ? nombres[0]
            : $"{string.Join(", ", nombres.Take(nombres.Count - 1))} o {nombres[^1]}";
    }

    /// <summary>Guarda la foto y devuelve su ruta pública ("/uploads/fotos/..."), o null si no hay archivo.</summary>
    public static async Task<string?> GuardarFoto(IFormFile? archivo, string carpetaWwwroot)
    {
        if (archivo == null || archivo.Length == 0)
        {
            return null;
        }

        var carpeta = Path.Combine(carpetaWwwroot, "uploads", "fotos");
        Directory.CreateDirectory(carpeta);
        var nombre = $"{Guid.NewGuid():N}{Path.GetExtension(archivo.FileName).ToLowerInvariant()}";
        await using (var destino = File.Create(Path.Combine(carpeta, nombre)))
        {
            await archivo.CopyToAsync(destino);
        }
        return $"/uploads/fotos/{nombre}";
    }

    /// <summary>Guarda el CV y devuelve el nombre guardado ("{guid}_{nombre original}"), o null si no hay archivo.</summary>
    public static async Task<string?> GuardarCV(IFormFile? archivo, string carpetaRaiz)
    {
        if (archivo == null || archivo.Length == 0)
        {
            return null;
        }

        var carpeta = CarpetaCV(carpetaRaiz);
        Directory.CreateDirectory(carpeta);
        var nombre = $"{Guid.NewGuid():N}_{NombreSeguro(archivo.FileName)}";
        await using (var destino = File.Create(Path.Combine(carpeta, nombre)))
        {
            await archivo.CopyToAsync(destino);
        }
        return nombre;
    }

    public static string CarpetaCV(string carpetaRaiz) => Path.Combine(carpetaRaiz, "ArchivosPrivados", "cv");

    /// <summary>Borra un archivo guardado (por ejemplo si el registro falló después de subirlo).</summary>
    public static void Borrar(string? rutaCompleta)
    {
        if (!string.IsNullOrEmpty(rutaCompleta) && File.Exists(rutaCompleta))
        {
            File.Delete(rutaCompleta);
        }
    }

    // Deja solo letras, números, guiones y puntos, y limita el largo.
    private static string NombreSeguro(string nombreOriginal)
    {
        var nombre = Path.GetFileNameWithoutExtension(Path.GetFileName(nombreOriginal));
        var extension = Path.GetExtension(nombreOriginal).ToLowerInvariant();
        var limpio = new string(nombre.Select(c => char.IsLetterOrDigit(c) || c is '-' or '_' ? c : '-').ToArray()).Trim('-');
        if (limpio.Length == 0)
        {
            limpio = "CV";
        }
        if (limpio.Length > 80)
        {
            limpio = limpio[..80];
        }
        return limpio + extension;
    }

    // Revisa los primeros bytes para confirmar que el archivo es del tipo que dice ser.
    private static bool FirmaValida(IFormFile archivo, string extension)
    {
        Span<byte> cabecera = stackalloc byte[12];
        using var flujo = archivo.OpenReadStream();
        var leidos = flujo.Read(cabecera);
        var b = cabecera[..leidos];

        return extension switch
        {
            ".jpg" or ".jpeg" => b.Length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF,
            ".png" => b.Length >= 8 && b[..8].SequenceEqual(new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A }),
            ".webp" => b.Length >= 12 && b[..4].SequenceEqual("RIFF"u8) && b[8..12].SequenceEqual("WEBP"u8),
            ".pdf" => b.Length >= 4 && b[..4].SequenceEqual("%PDF"u8),
            ".docx" => b.Length >= 4 && b[..4].SequenceEqual(new byte[] { 0x50, 0x4B, 0x03, 0x04 }),
            ".doc" => b.Length >= 8 && b[..8].SequenceEqual(new byte[] { 0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1 }),
            _ => false
        };
    }
}
