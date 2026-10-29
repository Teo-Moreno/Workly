namespace Workly.Models;

public class PostulacionItem
{
    public int ID { get; set; }
    public string Estado { get; set; } = "Enviada";
    public DateTime Fecha { get; set; }
    public int? IDOfertaLaboral { get; set; }
    public int? IDOfertaExterna { get; set; }
    public string Titulo { get; set; } = "";
    public string Empresa { get; set; } = "";
    public string? Ubicacion { get; set; }
    public string? Publicador { get; set; }
    public string? Link_Postulacion { get; set; }

    public bool EsExterna => IDOfertaExterna.HasValue;
    public string Iniciales => Textos.Iniciales(Empresa);
    public string FechaTexto => "Te postulaste el " + Fecha.ToString("d 'de' MMMM", new System.Globalization.CultureInfo("es-AR"));
}

public class Postulante
{
    public int IDPostulacion { get; set; }
    public int IDUsuario { get; set; }
    public DateTime Fecha { get; set; }
    public string Nombre { get; set; } = "";
    public string Apellido { get; set; } = "";
    public string Email { get; set; } = "";
    public string? Telefono { get; set; }
    public string? Foto { get; set; }
    public string? Provincia { get; set; }
    public string? Estado_Busqueda { get; set; }
    public string? Puesto_Buscado { get; set; }
    public string? Nombre_Archivo { get; set; }

    public string NombreCompleto => $"{Nombre} {Apellido}".Trim();
    public string Iniciales => UsuarioActual.Iniciales(Nombre, Apellido);
    public bool TieneCV => !string.IsNullOrEmpty(Nombre_Archivo);
}
