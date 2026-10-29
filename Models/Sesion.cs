using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;

namespace Workly.Models;

public static class Sesion
{
    public const string EsquemaExterno = "Externo";

    public static async Task Iniciar(HttpContext http, int idUsuario, bool? recordarme = null)
    {
        var usuario = BD.ObtenerUsuarioPorId(idUsuario) ?? throw new InvalidOperationException("El usuario no existe");
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, usuario.ID.ToString()),
            new(ClaimTypes.GivenName, usuario.Nombre),
            new(ClaimTypes.Surname, usuario.Apellido),
            new(ClaimTypes.Email, usuario.Email),
            new(UsuarioActual.ClaimTipo, usuario.Tipo),
            new(UsuarioActual.ClaimModerador, usuario.Es_Moderador ? "true" : "false")
        };

        if (usuario.EsEmpresa)
        {
            var empresa = BD.ObtenerEmpresaDeUsuario(usuario.ID);
            claims.Add(new Claim(ClaimTypes.Name, empresa?.Nombre ?? usuario.NombreCompleto));
            if (!string.IsNullOrEmpty(empresa?.Logo)) claims.Add(new Claim(UsuarioActual.ClaimFoto, empresa.Logo));
            claims.Add(new Claim(UsuarioActual.ClaimUbicacion, "Cuenta de empresa"));
        }
        else
        {
            var perfil = BD.ObtenerPerfil(usuario.ID);
            claims.Add(new Claim(ClaimTypes.Name, usuario.NombreCompleto));
            if (!string.IsNullOrEmpty(perfil?.Foto)) claims.Add(new Claim(UsuarioActual.ClaimFoto, perfil.Foto));
            if (!string.IsNullOrEmpty(perfil?.Provincia)) claims.Add(new Claim(UsuarioActual.ClaimUbicacion, perfil.Provincia));
        }

        var actual = await http.AuthenticateAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        var persistente = recordarme ?? actual.Properties?.IsPersistent ?? false;
        var propiedades = new AuthenticationProperties
        {
            IsPersistent = persistente,
            ExpiresUtc = persistente ? DateTimeOffset.UtcNow.AddDays(14) : null
        };
        await http.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme,
            new ClaimsPrincipal(new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme)), propiedades);
    }
}
