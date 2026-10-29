namespace Workly.Models;

public class Perfil
{
    public int ID { get; set; }
    public int IDUsuario { get; set; }

    public string? Foto { get; set; }

    public string? Descripcion { get; set; }

    public int? IDProvincia { get; set; }

    public string? Telefono { get; set; }

    public string? Estado_Busqueda { get; set; }

    public string? Provincia { get; set; }
    public int? IDPais { get; set; }
    public string? Pais { get; set; }
    public string? Codigo_Telefono { get; set; }

    public string? Ubicacion => Provincia == null ? null : $"{Provincia}, {Pais}";
}
