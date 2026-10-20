namespace Workly.Models;

// Tabla Perfil (1 a 1 con Usuario)
public class Perfil
{
    public int ID { get; set; }
    public int IDUsuario { get; set; }

    /// <summary>Ruta pública de la foto, por ejemplo "/uploads/fotos/abc.jpg".</summary>
    public string? Foto { get; set; }

    public string? Descripcion { get; set; }
    public string? Ubicacion { get; set; }
    public string? Telefono { get; set; }
}
