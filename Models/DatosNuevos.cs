namespace Workly.Models;

public class ExperienciaNueva
{
    public string Puesto { get; set; } = "";
    public string Empresa { get; set; } = "";
    public string? Descripcion { get; set; }
    public DateTime Inicio { get; set; }
    public DateTime? Fin { get; set; }
}

public class FormacionNueva
{
    public string Titulo { get; set; } = "";
    public string Institucion { get; set; } = "";
    public DateTime Inicio { get; set; }
    public DateTime? Fin { get; set; }
}

public class LoginExternoNuevo
{
    public string Proveedor { get; set; } = "";
    public string ID_Externo { get; set; } = "";
}

public class PersonaNueva
{
    public Usuario Usuario { get; set; } = new();
    public LoginExternoNuevo? LoginExterno { get; set; }
}

public class PerfilCompletado
{
    public int? IDProvincia { get; set; }
    public string? Telefono { get; set; }
    public string? Descripcion { get; set; }
    public string? EstadoBusqueda { get; set; }
    public string? Foto { get; set; }
    public string? ArchivoCV { get; set; }
    public string? SitioWeb { get; set; }
    public Preferencia Preferencia { get; set; } = new();
    public List<string> Habilidades { get; set; } = new();
    public List<(int IDIdioma, string Nivel)> Idiomas { get; set; } = new();
    public List<ExperienciaNueva> Experiencias { get; set; } = new();
    public List<FormacionNueva> Formaciones { get; set; } = new();
}

public class EmpresaNueva
{
    public Usuario Usuario { get; set; } = new();
    public Empresa Empresa { get; set; } = new();
    public LoginExternoNuevo? LoginExterno { get; set; }
}

public class OfertaNueva
{
    public int IDUsuario_Publicador { get; set; }
    public int? IDEmpresa { get; set; }
    public string? EmpresaNombre { get; set; }
    public string Titulo { get; set; } = "";
    public string Puesto { get; set; } = "";
    public string? Descripcion { get; set; }
    public string? Ubicacion { get; set; }
    public int? IDProvincia { get; set; }
    public string Modalidad { get; set; } = "";
    public string Tipo_Contrato { get; set; } = "";
    public int? Salario { get; set; }
    public int Cantidad_Puestos { get; set; } = 1;
    public DateTime? Fecha_Cierre { get; set; }
    public string Estado_Publicacion { get; set; } = "Aprobada";
}

public class FiltrosOfertas
{
    public string? Texto { get; set; }
    public int? IDProvincia { get; set; }
    public List<string> Modalidades { get; set; } = new();
    public List<string> TiposEmpleo { get; set; } = new();
    public int? Dias { get; set; }
}
