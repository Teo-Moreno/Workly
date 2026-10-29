using System.Security.Claims;

namespace Workly.Models;

public static class UsuarioActual
{
    public const string ClaimUbicacion = "workly:ubicacion";
    public const string ClaimFoto = "workly:foto";
    public const string ClaimTipo = "workly:tipo";
    public const string ClaimModerador = "workly:moderador";

    public static int IdUsuario(this ClaimsPrincipal usuario) =>
        int.TryParse(usuario.FindFirstValue(ClaimTypes.NameIdentifier), out var id) ? id : 0;

    public static string Nombre(this ClaimsPrincipal usuario) =>
        usuario.FindFirstValue(ClaimTypes.GivenName) ?? "";

    public static string NombreCompleto(this ClaimsPrincipal usuario) =>
        usuario.FindFirstValue(ClaimTypes.Name) ?? "";

    public static string Email(this ClaimsPrincipal usuario) =>
        usuario.FindFirstValue(ClaimTypes.Email) ?? "";

    public static string? Ubicacion(this ClaimsPrincipal usuario) =>
        usuario.FindFirstValue(ClaimUbicacion);

    public static string? Foto(this ClaimsPrincipal usuario) =>
        usuario.FindFirstValue(ClaimFoto);

    public static string Iniciales(this ClaimsPrincipal usuario)
    {
        var nombre = usuario.FindFirstValue(ClaimTypes.GivenName) ?? "";
        var apellido = usuario.FindFirstValue(ClaimTypes.Surname) ?? "";
        return Iniciales(nombre, apellido);
    }

    public static string Iniciales(string nombre, string apellido)
    {
        var iniciales = $"{nombre.Trim().FirstOrDefault()}{apellido.Trim().FirstOrDefault()}".Trim('\0');
        return iniciales.Length > 0 ? iniciales.ToUpperInvariant() : "?";
    }

    public static bool EstaLogueado(this ClaimsPrincipal usuario) =>
        usuario.Identity?.IsAuthenticated == true;

    public static bool EsEmpresa(this ClaimsPrincipal usuario) =>
        usuario.FindFirstValue(ClaimTipo) == Usuario.TipoEmpresa;

    public static bool EsPersona(this ClaimsPrincipal usuario) =>
        usuario.EstaLogueado() && !usuario.EsEmpresa();

    public static bool EsModerador(this ClaimsPrincipal usuario) =>
        usuario.FindFirstValue(ClaimModerador) == "true";
}
