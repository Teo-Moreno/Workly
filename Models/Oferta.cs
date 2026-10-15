namespace Workly.Models;

public class Oferta
{
    public int Id { get; set; }
    public string Puesto { get; set; } = "";
    public int EmpresaId { get; set; }
    public string Empresa { get; set; } = "";
    public string Iniciales { get; set; } = "";

    /// <summary>Ubicación completa, por ejemplo "Palermo, CABA".</summary>
    public string Ubicacion { get; set; } = "";

    /// <summary>Versión corta para las tarjetas de coincidencias, por ejemplo "CABA · Híbrido".</summary>
    public string UbicacionCorta { get; set; } = "";

    public string Modalidad { get; set; } = "";
    public string ModalidadDetalle { get; set; } = "";
    public string Nivel { get; set; } = "";
    public string Contratacion { get; set; } = "Relación de dependencia";
    public string Jornada { get; set; } = "Full-time";
    public string Salario { get; set; } = "";
    public string Experiencia { get; set; } = "";
    public string ExperienciaDetalle { get; set; } = "en desarrollo frontend";
    public int Match { get; set; }
    public string MatchResumen { get; set; } = "";
    public string Publicado { get; set; } = "";
    public List<string> Tecnologias { get; set; } = new();
    public string SobrePuesto { get; set; } = "";
    public List<string> Requisitos { get; set; } = new();
    public List<string> Beneficios { get; set; } = new();
    public List<string> HabilidadesCumplidas { get; set; } = new();
    public string? HabilidadFaltante { get; set; }
    public bool Guardada { get; set; }

    public string MatchNivel => Match >= 90 ? "Muy alta" : Match >= 80 ? "Alta" : "Media";

    public string PublicadoTexto => Publicado.Length > 0
        ? $"Publicado {char.ToLower(Publicado[0])}{Publicado[1..]}"
        : "";
}
