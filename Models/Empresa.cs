namespace Workly.Models;

public class Empresa
{
    public int ID { get; set; }
    public string Nombre { get; set; } = "";
    public string? Descripcion { get; set; }

    public string? Logo { get; set; }

    public string? Ubicacion { get; set; }

    public string? Sitio_Web { get; set; }
    public int? IDUsuario { get; set; }
    public string? Razon_Social { get; set; }
    public string? CUIT { get; set; }
    public string? Rubro { get; set; }
    public int? IDProvincia { get; set; }
    public string? Telefono { get; set; }
    public DateTime Fecha_Registro { get; set; }

    public string? Provincia { get; set; }
    public int? IDPais { get; set; }
    public string? Pais { get; set; }
    public int BusquedasActivas { get; set; }

    public bool TieneCuenta => IDUsuario.HasValue;
    public string Iniciales => Textos.Iniciales(Nombre);
    public string? EnlaceSitio => Textos.Enlace(Sitio_Web);

    public string? UbicacionCompleta =>
        string.Join(" · ", new[] { Ubicacion, Provincia }.Where(t => !string.IsNullOrWhiteSpace(t))) is { Length: > 0 } texto ? texto : null;
}
