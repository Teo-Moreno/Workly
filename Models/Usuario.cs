namespace Workly.Models;

public class Usuario
{
    public const string TipoPersona = "Persona";
    public const string TipoEmpresa = "Empresa";

    public int ID { get; set; }
    public string Nombre { get; set; } = "";
    public string Apellido { get; set; } = "";
    public string Email { get; set; } = "";

    public string? Contraseña { get; set; }

    public DateTime Fecha_Registro { get; set; }
    public string Tipo { get; set; } = TipoPersona;
    public bool Es_Moderador { get; set; }

    public string NombreCompleto => $"{Nombre} {Apellido}".Trim();
    public bool EsEmpresa => Tipo == TipoEmpresa;
    public bool TieneContrasena => !string.IsNullOrEmpty(Contraseña);
}
