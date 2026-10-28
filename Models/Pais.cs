namespace Workly.Models;

// Tabla Pais
public class Pais
{
    public int ID { get; set; }
    public string Nombre { get; set; } = "";

    /// <summary>Código ISO de 2 letras en minúscula ("ar"): lo usa JSearch para buscar en ese país.</summary>
    public string Codigo_ISO { get; set; } = "";

    /// <summary>Prefijo internacional del teléfono, por ejemplo "+54".</summary>
    public string Codigo_Telefono { get; set; } = "";
}
