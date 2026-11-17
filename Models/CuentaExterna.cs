using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;

namespace Workly.Models;

public class CuentaExterna
{
    public string Proveedor { get; set; } = "";
    public string ID { get; set; } = "";
    public string Email { get; set; } = "";
    public string Nombre { get; set; } = "";
    public string Apellido { get; set; } = "";

    public LoginExternoNuevo Login => new() { Proveedor = Proveedor, ID_Externo = ID };

    public static CuentaExterna? Leer(AuthenticateResult resultado)
    {
        if (!resultado.Succeeded || resultado.Principal == null)
        {
            return null;
        }
        var p = resultado.Principal;
        string? Valor(params string[] tipos) => tipos.Select(p.FindFirstValue).FirstOrDefault(v => !string.IsNullOrEmpty(v));

        var proveedor = resultado.Properties?.Items.TryGetValue("proveedor", out var valor) == true ? valor : null;
        var id = Valor(ClaimTypes.NameIdentifier, "sub");
        if (proveedor == null || id == null)
        {
            return null;
        }
        return new CuentaExterna
        {
            Proveedor = proveedor,
            ID = id,
            Email = Cuentas.NormalizarEmail(Valor(ClaimTypes.Email, "email")),
            Nombre = Valor(ClaimTypes.GivenName, "given_name") ?? "",
            Apellido = Valor(ClaimTypes.Surname, "family_name") ?? ""
        };
    }

    public void CompletarRegistro(RegistroBase modelo)
    {
        modelo.ProveedorExterno = Proveedor;
        modelo.Email = Email;
        if (string.IsNullOrWhiteSpace(modelo.Nombre)) modelo.Nombre = Nombre;
        if (string.IsNullOrWhiteSpace(modelo.Apellido)) modelo.Apellido = Apellido;
    }

    public int? BuscarUsuario()
    {
        var id = BD.ObtenerUsuarioDeLoginExterno(Proveedor, ID);
        if (id == null && BD.ObtenerUsuarioPorEmail(Email) is { } existente)
        {
            BD.VincularLoginExterno(existente.ID, Login);
            id = existente.ID;
        }
        return id;
    }
}
