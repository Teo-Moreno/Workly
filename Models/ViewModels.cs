using System.ComponentModel.DataAnnotations;

namespace Workly.Models;

public class LandingViewModel
{
    public List<string> Puestos { get; set; } = new();
    public List<Empresa> Empresas { get; set; } = new();
}

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

    public bool BuscoAlgo => !string.IsNullOrWhiteSpace(Q);
    public int CantidadFiltros => Modalidad.Count + Tipo.Count + (Fecha != null ? 1 : 0);
}

public class OfertaDetalleViewModel
{
    public Oferta Oferta { get; set; } = new();
    public Empresa? Empresa { get; set; }

    public bool EsPropia { get; set; }

    public bool EsRevision { get; set; }

    public bool PuedePostular { get; set; }

    public bool TieneCV { get; set; }
}

public class PanelViewModel
{
    public MiPerfilViewModel Perfil { get; set; } = new();
    public List<Oferta> ParaVos { get; set; } = new();
    public bool ErrorExternas { get; set; }
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

public class EmpresaDetalleViewModel
{
    public Empresa Empresa { get; set; } = new();
    public List<Oferta> Ofertas { get; set; } = new();
    public bool EsPropia { get; set; }
}

public class PublicacionesViewModel
{
    public List<Oferta> Ofertas { get; set; } = new();
    public bool EsEmpresa { get; set; }
}

public class PublicacionDetalleViewModel
{
    public Oferta Oferta { get; set; } = new();
    public List<Postulante> Postulantes { get; set; } = new();
}

public class PostulanteViewModel
{
    public int IDPostulacion { get; set; }
    public Oferta Oferta { get; set; } = new();
    public MiPerfilViewModel Perfil { get; set; } = new();
}

public class PublicarViewModel
{
    [Required(ErrorMessage = "Escribí el título de la búsqueda")]
    [StringLength(150, ErrorMessage = "Usá hasta 150 caracteres")]
    public string Titulo { get; set; } = "";

    [Required(ErrorMessage = "Escribí el puesto")]
    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string Puesto { get; set; } = "";

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

public class ModeracionViewModel
{
    public List<Oferta> Pendientes { get; set; } = new();
    public List<Oferta> Revisadas { get; set; } = new();
}
