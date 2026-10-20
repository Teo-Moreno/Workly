namespace Workly.Models;

// Tabla CV (1 a 1 con Usuario)
public class CV
{
    public int ID { get; set; }
    public int IDUsuario { get; set; }

    /// <summary>Nombre del archivo guardado en ArchivosPrivados/cv: "{guid}_{nombre original}".</summary>
    public string? Nombre_Archivo { get; set; }

    public string? Sitio_Web { get; set; }
    public DateTime Fecha_Actualizacion { get; set; }

    /// <summary>Nombre original del archivo (sin el prefijo único).</summary>
    public string? NombreOriginal
    {
        get
        {
            if (string.IsNullOrEmpty(Nombre_Archivo))
            {
                return null;
            }
            var separador = Nombre_Archivo.IndexOf('_');
            return separador >= 0 ? Nombre_Archivo[(separador + 1)..] : Nombre_Archivo;
        }
    }
}
