namespace Workly.Models;

public class CV
{
    public int ID { get; set; }
    public int IDUsuario { get; set; }

    public string? Nombre_Archivo { get; set; }

    public string? Sitio_Web { get; set; }
    public DateTime Fecha_Actualizacion { get; set; }

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
