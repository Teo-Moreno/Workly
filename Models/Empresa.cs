namespace Workly.Models;

public class Empresa
{
    public int Id { get; set; }
    public string Nombre { get; set; } = "";
    public string Iniciales { get; set; } = "";

    /// <summary>Industria tal como se muestra en la tarjeta, por ejemplo "E-commerce y fintech".</summary>
    public string Industria { get; set; } = "";

    /// <summary>Categoría usada por los chips de filtro (Tecnología, Fintech, E-commerce...).</summary>
    public List<string> Categorias { get; set; } = new();

    public string Ubicacion { get; set; } = "";
    public string Descripcion { get; set; } = "";
    public string SobreNosotros { get; set; } = "";
    public string Empleados { get; set; } = "";
    public int BusquedasActivas { get; set; }
    public string Valoracion { get; set; } = "";
    public string RespondeEn { get; set; } = "";
    public string Fundada { get; set; } = "";
    public string SitioWeb { get; set; } = "";
    public List<string> Beneficios { get; set; } = new();
    public List<(string Aspecto, double Puntaje)> Valoraciones { get; set; } = new();
}
