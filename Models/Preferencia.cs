namespace Workly.Models;

public class Preferencia
{
    public int ID { get; set; }
    public int IDUsuario { get; set; }
    public string? Puesto_Buscado { get; set; }

    public string? Niveles { get; set; }

    public string? Modalidades { get; set; }

    public string? Jornada { get; set; }
    public string? Contratacion { get; set; }

    public int? IDProvincia { get; set; }

    public int? Salario_Minimo { get; set; }
    public int? Salario_Maximo { get; set; }
    public string? Disponibilidad { get; set; }

    public string? Provincia { get; set; }

    public List<string> ListaNiveles => Lista(Niveles);
    public List<string> ListaModalidades => Lista(Modalidades);

    public bool TieneDatos =>
        !string.IsNullOrWhiteSpace(Puesto_Buscado) || ListaNiveles.Count > 0 || ListaModalidades.Count > 0 ||
        Jornada != null || Contratacion != null || Salario_Minimo != null || Salario_Maximo != null || Disponibilidad != null;

    public static List<string> Lista(string? texto) =>
        (texto ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).ToList();

    public static string? Unir(IEnumerable<string>? valores, IEnumerable<string> permitidos)
    {
        var elegidos = (valores ?? Enumerable.Empty<string>()).Where(permitidos.Contains).Distinct().ToList();
        return elegidos.Count == 0 ? null : string.Join(",", elegidos);
    }
}
