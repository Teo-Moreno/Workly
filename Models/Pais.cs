namespace Workly.Models;

// Tabla Pais
public class Pais
{
    public int ID { get; set; }
    public string Nombre { get; set; } = "";

    /// <summary>Prefijo internacional del teléfono, por ejemplo "+54".</summary>
    public string Codigo_Telefono { get; set; } = "";
}
