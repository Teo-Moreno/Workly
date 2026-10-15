namespace Workly.Models;

public class BuscarTrabajoViewModel
{
    public List<Oferta> Ofertas { get; set; } = new();
    public Oferta Seleccionada { get; set; } = new();
    public string Busqueda { get; set; } = "";
}

public class OfertaDetalleViewModel
{
    public Oferta Oferta { get; set; } = new();
    public Empresa Empresa { get; set; } = new();
    public List<Oferta> Similares { get; set; } = new();
}

public class EmpresaDetalleViewModel
{
    public Empresa Empresa { get; set; } = new();
    public List<Oferta> Ofertas { get; set; } = new();
}

public class PostulacionesViewModel
{
    public List<Postulacion> Activas { get; set; } = new();
    public List<Postulacion> Archivadas { get; set; } = new();
    public List<Oferta> Guardadas { get; set; } = new();

    public IEnumerable<Postulacion> PorEstado(EstadoPostulacion estado) =>
        Activas.Where(p => p.Estado == estado);
}

public class PanelViewModel
{
    public List<Oferta> Coincidencias { get; set; } = new();
    public List<Postulacion> Entrevistas { get; set; } = new();
    public List<Empresa> EmpresasSugeridas { get; set; } = new();
}
