namespace Workly.Models;

public class Habilidad
{
    public int ID { get; set; }
    public string Nombre { get; set; } = "";
}

public class Idioma
{
    public int ID { get; set; }
    public string Nombre { get; set; } = "";
}

public class IdiomaElegido
{
    public int IDIdioma { get; set; }
    public string Idioma { get; set; } = "";
    public string Nivel { get; set; } = "";
}
