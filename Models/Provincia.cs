namespace Workly.Models;

// Tabla Provincia (cada provincia pertenece a un país)
public class Provincia
{
    public int ID { get; set; }
    public int IDPais { get; set; }
    public string Nombre { get; set; } = "";
}
