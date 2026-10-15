namespace Workly.Models;

public enum EstadoPostulacion
{
    Enviada,
    EnRevision,
    Entrevista,
    Finalizada
}

public class Postulacion
{
    public int Id { get; set; }
    public int? OfertaId { get; set; }
    public string Puesto { get; set; } = "";
    public string Empresa { get; set; } = "";
    public string Iniciales { get; set; } = "";
    public string Ubicacion { get; set; } = "";
    public EstadoPostulacion Estado { get; set; }

    /// <summary>Etapa visible en la tarjeta: "CV visto por RR.HH.", "Entrevista técnica"...</summary>
    public string Etapa { get; set; } = "";

    /// <summary>Tono de la etiqueta de etapa: neutra, info, advertencia, exito, error, principal.</summary>
    public string Tono { get; set; } = "neutra";

    public string Actualizado { get; set; } = "";
    public string? DestacadoTitulo { get; set; }
    public string? DestacadoTexto { get; set; }
    public bool Archivada { get; set; }

    public string EstadoTexto => Estado switch
    {
        EstadoPostulacion.Enviada => "Enviada",
        EstadoPostulacion.EnRevision => "En revisión",
        EstadoPostulacion.Entrevista => "Entrevista",
        _ => "Finalizada"
    };
}
