namespace Workly.Models;

// Tabla Empresa. Las que tienen cuenta propia (IDUsuario) se registraron con su CUIT;
// las demás se crean cuando alguien carga una experiencia laboral o publica una búsqueda.
public class Empresa
{
    public int ID { get; set; }
    public string Nombre { get; set; } = "";
    public string? Descripcion { get; set; }

    /// <summary>Ruta pública del logo, por ejemplo "/uploads/logos/abc.png".</summary>
    public string? Logo { get; set; }

    /// <summary>Barrio o dirección.</summary>
    public string? Ubicacion { get; set; }

    public string? Sitio_Web { get; set; }
    public int? IDUsuario { get; set; }
    public string? Razon_Social { get; set; }
    public string? CUIT { get; set; }
    public string? Rubro { get; set; }
    public int? IDProvincia { get; set; }
    public string? Telefono { get; set; }
    public DateTime Fecha_Registro { get; set; }

    // JOIN con Provincia y Pais, y cantidad de búsquedas activas
    public string? Provincia { get; set; }
    public int? IDPais { get; set; }
    public string? Pais { get; set; }
    public int BusquedasActivas { get; set; }

    public bool TieneCuenta => IDUsuario.HasValue;
    public string Iniciales => Textos.Iniciales(Nombre);
    public string? EnlaceSitio => Textos.Enlace(Sitio_Web);

    /// <summary>"Palermo · Ciudad Autónoma de Buenos Aires" (lo que haya cargado).</summary>
    public string? UbicacionCompleta =>
        string.Join(" · ", new[] { Ubicacion, Provincia }.Where(t => !string.IsNullOrWhiteSpace(t))) is { Length: > 0 } texto ? texto : null;
}
