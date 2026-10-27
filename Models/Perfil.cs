namespace Workly.Models;

// Tabla Perfil (1 a 1 con Usuario)
public class Perfil
{
    public int ID { get; set; }
    public int IDUsuario { get; set; }

    /// <summary>Ruta pública de la foto, por ejemplo "/uploads/fotos/abc.jpg".</summary>
    public string? Foto { get; set; }

    public string? Descripcion { get; set; }

    /// <summary>Dónde vive (FK a Provincia). El país sale de la provincia.</summary>
    public int? IDProvincia { get; set; }

    /// <summary>Con el prefijo del país, por ejemplo "+54 11 5555-1234".</summary>
    public string? Telefono { get; set; }

    // Datos de las tablas Provincia y Pais (se completan con un JOIN al leer el perfil)
    public string? Provincia { get; set; }
    public int? IDPais { get; set; }
    public string? Pais { get; set; }
    public string? Codigo_Telefono { get; set; }

    public string? Ubicacion => Provincia == null ? null : $"{Provincia}, {Pais}";
}
