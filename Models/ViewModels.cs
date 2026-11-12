using System.ComponentModel.DataAnnotations;

namespace Workly.Models;

public class BuscarTrabajoViewModel
{
    public string? Q { get; set; }
    public int? IDPais { get; set; }
    public int? IDProvincia { get; set; }
    public List<string> Modalidad { get; set; } = new();
    public List<string> Tipo { get; set; } = new();
    public string? Fecha { get; set; }
    public string Orden { get; set; } = "recientes";
    public string? Cursor { get; set; }

    public List<Oferta> Ofertas { get; set; } = new();
    public Oferta? Seleccionada { get; set; }
    public List<Pais> Paises { get; set; } = new();
    public List<Provincia> Provincias { get; set; } = new();

    public string? CursorSiguiente { get; set; }

    public bool ErrorExternas { get; set; }

    public List<string> Consulta { get; set; } = new();

    public bool BuscoAlgo => !string.IsNullOrWhiteSpace(Q);
    public int CantidadFiltros => Modalidad.Count + Tipo.Count + (Fecha != null ? 1 : 0);
    public bool HayFiltros => CantidadFiltros > 0 || IDProvincia != null;

    public string TituloCargando => BuscoAlgo ? $"Ofertas para “{Q}”" : "Ofertas";

    public string Titulo => Ofertas.Count == 0 ? "Sin resultados"
        : $"{Ofertas.Count} {(Ofertas.Count == 1 ? "oferta" : "ofertas")}" + (BuscoAlgo ? $" para “{Q}”" : "");

    public string? Lugar => Provincias.FirstOrDefault(p => p.ID == IDProvincia)?.Nombre ?? Paises.FirstOrDefault(p => p.ID == IDPais)?.Nombre;

    public string ConOferta(string clave) => "/Empleos?" + string.Join("&", Consulta.Where(c => !c.StartsWith("id=")).Append("id=" + clave));

    public string UrlMas => "/Empleos?" + string.Join("&", Consulta.Where(c => !c.StartsWith("Cursor=") && !c.StartsWith("id=")).Append("Cursor=" + Uri.EscapeDataString(CursorSiguiente ?? "")));

    public bool EsSeleccionada(Oferta oferta) => oferta == Seleccionada;
}

public class EmpresasViewModel
{
    public string? Q { get; set; }
    public int? IDPais { get; set; }
    public int? IDProvincia { get; set; }
    public string Orden { get; set; } = "recientes";

    public List<Empresa> Empresas { get; set; } = new();
    public List<Pais> Paises { get; set; } = new();
    public List<Provincia> Provincias { get; set; } = new();
}

public class PublicarViewModel
{
    [Required(ErrorMessage = "Escribí el título de la búsqueda")]
    [StringLength(150, ErrorMessage = "Usá hasta 150 caracteres")]
    public string Titulo { get; set; } = "";

    [Required(ErrorMessage = "Escribí el puesto")]
    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string Puesto { get; set; } = "";

    [Required(ErrorMessage = "Elegí el sector del puesto")]
    public int? IDSector { get; set; }

    public List<Sector> Sectores { get; set; } = new();

    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string? EmpresaNombre { get; set; }

    [Required(ErrorMessage = "Contá de qué se trata el trabajo y qué piden")]
    [StringLength(2000, MinimumLength = 40, ErrorMessage = "Usá entre 40 y 2000 caracteres")]
    public string Descripcion { get; set; } = "";

    [Required(ErrorMessage = "Elegí la modalidad")]
    public string? Modalidad { get; set; }

    [Required(ErrorMessage = "Elegí el tipo de empleo")]
    public string? TipoEmpleo { get; set; }

    [Range(0, 1_000_000_000, ErrorMessage = "Ingresá un monto válido")]
    public int? Salario { get; set; }

    [Range(1, 999, ErrorMessage = "Ingresá entre 1 y 999")]
    public int CantidadPuestos { get; set; } = 1;

    public int? IDPais { get; set; }

    [Required(ErrorMessage = "Elegí la provincia")]
    public int? IDProvincia { get; set; }

    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string? Ubicacion { get; set; }

    [DataType(DataType.Date)]
    public DateTime? FechaCierre { get; set; }

    public bool EsEmpresa { get; set; }
    public string? EmpresaFija { get; set; }
    public List<Pais> Paises { get; set; } = new();
    public List<Provincia> Provincias { get; set; } = new();
}
