namespace Workly.Models;

// Tabla Usuario
public class Usuario
{
    public int ID { get; set; }
    public string Nombre { get; set; } = "";
    public string Apellido { get; set; } = "";
    public string Email { get; set; } = "";

    /// <summary>Hash PBKDF2 de la contraseña (ver Servicios/Contrasenas.cs).</summary>
    public string Contraseña { get; set; } = "";

    public DateTime Fecha_Registro { get; set; }

    public string NombreCompleto => $"{Nombre} {Apellido}".Trim();
}
