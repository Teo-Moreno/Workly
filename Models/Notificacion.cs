namespace Workly.Models;

public class Notificacion
{
    public int Id { get; set; }
    public string Titulo { get; set; } = "";
    public string Texto { get; set; } = "";
    public string Fecha { get; set; } = "";
    public bool Leida { get; set; }
    public string Enlace { get; set; } = "#";
}
