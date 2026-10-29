using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Http;

namespace Workly.Models;

public class LoginViewModel
{
    [Required(ErrorMessage = "Ingresá tu email")]
    [EmailAddress(ErrorMessage = "Ingresá un email válido")]
    [StringLength(100)]
    public string Email { get; set; } = "";

    [Required(ErrorMessage = "Ingresá tu contraseña")]
    [DataType(DataType.Password)]
    public string Contrasena { get; set; } = "";

    public bool Recordarme { get; set; } = true;

    public string? ReturnUrl { get; set; }
}

public class RecuperarClaveViewModel
{
    [Required(ErrorMessage = "Ingresá tu email")]
    [EmailAddress(ErrorMessage = "Ingresá un email válido")]
    [StringLength(100)]
    public string Email { get; set; } = "";
}

public class NuevaClaveViewModel
{
    public string Token { get; set; } = "";

    [Required(ErrorMessage = "Elegí una contraseña nueva")]
    [StringLength(100, MinimumLength = 8, ErrorMessage = "La contraseña debe tener entre 8 y 100 caracteres")]
    [RegularExpression(@"^(?=.*[A-Za-zÁÉÍÓÚÜÑáéíóúüñ])(?=.*\d).+$", ErrorMessage = "Usá al menos una letra y un número")]
    public string Nueva { get; set; } = "";

    [Required(ErrorMessage = "Repetí la contraseña nueva")]
    [Compare(nameof(Nueva), ErrorMessage = "Las contraseñas no coinciden")]
    public string Repetir { get; set; } = "";
}

public abstract class RegistroBase
{
    [Required(ErrorMessage = "Completá tu nombre")]
    [StringLength(50, ErrorMessage = "Usá hasta 50 caracteres")]
    public string Nombre { get; set; } = "";

    [Required(ErrorMessage = "Completá tu apellido")]
    [StringLength(50, ErrorMessage = "Usá hasta 50 caracteres")]
    public string Apellido { get; set; } = "";

    [Required(ErrorMessage = "Ingresá tu email")]
    [EmailAddress(ErrorMessage = "Ingresá un email válido")]
    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string Email { get; set; } = "";

    [StringLength(100, MinimumLength = 8, ErrorMessage = "La contraseña debe tener entre 8 y 100 caracteres")]
    [RegularExpression(@"^(?=.*[A-Za-zÁÉÍÓÚÜÑáéíóúüñ])(?=.*\d).+$", ErrorMessage = "Usá al menos una letra y un número")]
    [DataType(DataType.Password)]
    public string? Contrasena { get; set; }

    [Range(typeof(bool), "true", "true", ErrorMessage = "Tenés que aceptar los términos para continuar")]
    public bool AceptaTerminos { get; set; }

    [Required(ErrorMessage = "Elegí el país")]
    public int? IDPais { get; set; }

    [Required(ErrorMessage = "Elegí la provincia")]
    public int? IDProvincia { get; set; }

    [StringLength(20)]
    public string? Telefono { get; set; }

    public List<Pais> Paises { get; set; } = new();
    public List<Provincia> Provincias { get; set; } = new();

    public string? ProveedorExterno { get; set; }
}

public class RegistroPersonaViewModel : RegistroBase
{
    public IFormFile? Foto { get; set; }

    [StringLength(500, ErrorMessage = "Usá hasta 500 caracteres")]
    public string? Descripcion { get; set; }

    [Required(ErrorMessage = "Contanos si estás buscando trabajo")]
    public string? EstadoBusqueda { get; set; }

    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string? PuestoBuscado { get; set; }

    public List<string> Niveles { get; set; } = new();
    public List<string> Modalidades { get; set; } = new();
    public string? Jornada { get; set; }
    public string? Contratacion { get; set; }
    public int? IDProvinciaPreferida { get; set; }

    [Range(0, 1_000_000_000, ErrorMessage = "Ingresá un monto válido")]
    public int? SalarioMinimo { get; set; }

    [Range(0, 1_000_000_000, ErrorMessage = "Ingresá un monto válido")]
    public int? SalarioMaximo { get; set; }

    public string? Disponibilidad { get; set; }
    public List<string> Habilidades { get; set; } = new();
    public List<int> IdiomaIds { get; set; } = new();
    public List<string> IdiomaNiveles { get; set; } = new();

    public List<string> ExpPuesto { get; set; } = new();
    public List<string> ExpEmpresa { get; set; } = new();
    public List<string> ExpInicio { get; set; } = new();
    public List<string> ExpFin { get; set; } = new();
    public List<string> ExpDescripcion { get; set; } = new();
    public List<string> ForTitulo { get; set; } = new();
    public List<string> ForInstitucion { get; set; } = new();
    public List<string> ForInicio { get; set; } = new();
    public List<string> ForFin { get; set; } = new();

    public IFormFile? ArchivoCV { get; set; }

    [StringLength(200, ErrorMessage = "Usá hasta 200 caracteres")]
    public string? SitioWeb { get; set; }

    public List<Habilidad> CatalogoHabilidades { get; set; } = new();
    public List<Idioma> CatalogoIdiomas { get; set; } = new();
    public List<string> Instituciones { get; set; } = new();
}

public class RegistroEmpresaViewModel : RegistroBase
{
    [Required(ErrorMessage = "Completá el nombre de la empresa")]
    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string NombreEmpresa { get; set; } = "";

    [Required(ErrorMessage = "Completá la razón social")]
    [StringLength(150, ErrorMessage = "Usá hasta 150 caracteres")]
    public string RazonSocial { get; set; } = "";

    [Required(ErrorMessage = "Ingresá el CUIT")]
    public string CUIT { get; set; } = "";

    [Required(ErrorMessage = "Elegí el rubro")]
    public string? Rubro { get; set; }

    [Required(ErrorMessage = "Ingresá el sitio web de la empresa")]
    [StringLength(200, ErrorMessage = "Usá hasta 200 caracteres")]
    public string SitioWeb { get; set; } = "";

    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string? Ubicacion { get; set; }

    [Required(ErrorMessage = "Contá en pocas líneas qué hace la empresa")]
    [StringLength(500, ErrorMessage = "Usá hasta 500 caracteres")]
    public string? Descripcion { get; set; }

    public IFormFile? Logo { get; set; }
}

public class CuentaFormulario
{
    [Required(ErrorMessage = "Completá tu nombre")]
    [StringLength(50, ErrorMessage = "Usá hasta 50 caracteres")]
    public string Nombre { get; set; } = "";

    [Required(ErrorMessage = "Completá tu apellido")]
    [StringLength(50, ErrorMessage = "Usá hasta 50 caracteres")]
    public string Apellido { get; set; } = "";

    [Required(ErrorMessage = "Ingresá tu email")]
    [EmailAddress(ErrorMessage = "Ingresá un email válido")]
    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string Email { get; set; } = "";

    public int? IDPais { get; set; }

    [Required(ErrorMessage = "Elegí tu provincia")]
    public int? IDProvincia { get; set; }

    [StringLength(20)]
    public string? Telefono { get; set; }

    [StringLength(200, ErrorMessage = "Usá hasta 200 caracteres")]
    public string? SitioWeb { get; set; }

    public IFormFile? Foto { get; set; }
    public IFormFile? ArchivoCV { get; set; }
}

public class BusquedaFormulario
{
    public string? EstadoBusqueda { get; set; }

    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string? PuestoBuscado { get; set; }

    public List<string> Niveles { get; set; } = new();
    public List<string> Modalidades { get; set; } = new();
    public string? Jornada { get; set; }
    public string? Contratacion { get; set; }
    public int? IDProvinciaPreferida { get; set; }

    [Range(0, 1_000_000_000, ErrorMessage = "Ingresá un monto válido")]
    public int? SalarioMinimo { get; set; }

    [Range(0, 1_000_000_000, ErrorMessage = "Ingresá un monto válido")]
    public int? SalarioMaximo { get; set; }

    public string? Disponibilidad { get; set; }
    public List<string> Habilidades { get; set; } = new();
    public List<int> IdiomaIds { get; set; } = new();
    public List<string> IdiomaNiveles { get; set; } = new();
}

public class ClaveFormulario
{
    public string? Actual { get; set; }

    [Required(ErrorMessage = "Elegí una contraseña nueva")]
    [StringLength(100, MinimumLength = 8, ErrorMessage = "La contraseña debe tener entre 8 y 100 caracteres")]
    [RegularExpression(@"^(?=.*[A-Za-zÁÉÍÓÚÜÑáéíóúüñ])(?=.*\d).+$", ErrorMessage = "Usá al menos una letra y un número")]
    public string Nueva { get; set; } = "";

    [Required(ErrorMessage = "Repetí la contraseña nueva")]
    [Compare(nameof(Nueva), ErrorMessage = "Las contraseñas no coinciden")]
    public string Repetir { get; set; } = "";
}

public class EmpresaFormulario
{
    [Required(ErrorMessage = "Completá tu nombre")]
    [StringLength(50, ErrorMessage = "Usá hasta 50 caracteres")]
    public string Nombre { get; set; } = "";

    [Required(ErrorMessage = "Completá tu apellido")]
    [StringLength(50, ErrorMessage = "Usá hasta 50 caracteres")]
    public string Apellido { get; set; } = "";

    [Required(ErrorMessage = "Completá el nombre de la empresa")]
    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string NombreEmpresa { get; set; } = "";

    [Required(ErrorMessage = "Elegí el rubro")]
    public string? Rubro { get; set; }

    [Required(ErrorMessage = "Ingresá el sitio web de la empresa")]
    [StringLength(200, ErrorMessage = "Usá hasta 200 caracteres")]
    public string SitioWeb { get; set; } = "";

    public int? IDPais { get; set; }

    [Required(ErrorMessage = "Elegí la provincia")]
    public int? IDProvincia { get; set; }

    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string? Ubicacion { get; set; }

    [StringLength(20)]
    public string? Telefono { get; set; }

    [Required(ErrorMessage = "Contá en pocas líneas qué hace la empresa")]
    [StringLength(500, ErrorMessage = "Usá hasta 500 caracteres")]
    public string? Descripcion { get; set; }

    public IFormFile? Logo { get; set; }
}

public class ExperienciaFormulario
{
    [Required(ErrorMessage = "Completá el puesto")]
    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string Puesto { get; set; } = "";

    [Required(ErrorMessage = "Completá la empresa")]
    [StringLength(100, ErrorMessage = "Usá hasta 100 caracteres")]
    public string Empresa { get; set; } = "";

    [Required(ErrorMessage = "Elegí el mes y el año de inicio")]
    public string Inicio { get; set; } = "";

    public bool Actual { get; set; }
    public string? Fin { get; set; }

    [StringLength(500, ErrorMessage = "Usá hasta 500 caracteres")]
    public string? Descripcion { get; set; }
}

public class FormacionFormulario
{
    [Required(ErrorMessage = "Completá el título o curso")]
    [StringLength(150, ErrorMessage = "Usá hasta 150 caracteres")]
    public string Titulo { get; set; } = "";

    [Required(ErrorMessage = "Completá la institución")]
    [StringLength(150, ErrorMessage = "Usá hasta 150 caracteres")]
    public string Institucion { get; set; } = "";

    [Required(ErrorMessage = "Elegí el mes y el año de inicio")]
    public string Inicio { get; set; } = "";

    public bool EnCurso { get; set; }
    public string? Fin { get; set; }
}

public record ItemPerfil(string Clave, string Texto, bool Listo, string Accion);

public class MiPerfilViewModel
{
    public Usuario Usuario { get; set; } = new();
    public Perfil Perfil { get; set; } = new();
    public CV? CV { get; set; }
    public Preferencia Preferencia { get; set; } = new();
    public List<string> Habilidades { get; set; } = new();
    public List<IdiomaElegido> Idiomas { get; set; } = new();
    public List<ExperienciaItem> Experiencias { get; set; } = new();
    public List<FormacionItem> Formaciones { get; set; } = new();
    public Dictionary<string, int> PostulacionesPorEstado { get; set; } = new();

    public List<Pais> Paises { get; set; } = new();
    public List<Provincia> Provincias { get; set; } = new();
    public List<Habilidad> CatalogoHabilidades { get; set; } = new();
    public List<Idioma> CatalogoIdiomas { get; set; } = new();
    public List<string> Instituciones { get; set; } = new();
    public List<string> ProveedoresVinculados { get; set; } = new();

    public Empresa? Empresa { get; set; }

    public int TotalPostulaciones => PostulacionesPorEstado.Values.Sum();
    public bool TieneCV => !string.IsNullOrEmpty(CV?.Nombre_Archivo);

    public List<ItemPerfil> Checklist => new()
    {
        new("foto", "Foto de perfil", !string.IsNullOrEmpty(Perfil.Foto), "Subir foto"),
        new("sobre-mi", "Sobre mí", !string.IsNullOrWhiteSpace(Perfil.Descripcion), "Escribir"),
        new("telefono", "Teléfono", !string.IsNullOrWhiteSpace(Perfil.Telefono), "Agregar"),
        new("busqueda", "Qué estás buscando", Preferencia.TieneDatos, "Completar"),
        new("habilidades", "Habilidades", Habilidades.Count > 0, "Agregar"),
        new("idiomas", "Idiomas", Idiomas.Count > 0, "Agregar"),
        new("experiencia", "Experiencia laboral", Experiencias.Count > 0, "Agregar"),
        new("formacion", "Formación", Formaciones.Count > 0, "Agregar"),
        new("cv", "CV", TieneCV, "Subir CV")
    };

    public int PorcentajeCompleto
    {
        get
        {
            var items = Checklist;
            return (int)Math.Round(items.Count(i => i.Listo) * 100.0 / items.Count);
        }
    }

    public ItemPerfil? SiguientePaso => Checklist.FirstOrDefault(i => !i.Listo);
}

public class ExperienciaItem
{
    public int ID { get; set; }
    public string Puesto { get; set; } = "";
    public string Empresa { get; set; } = "";
    public string? Descripcion { get; set; }
    public DateTime Fecha_Inicio { get; set; }
    public DateTime? Fecha_Finalizacion { get; set; }

    public string Periodo => Fechas.Periodo(Fecha_Inicio, Fecha_Finalizacion);
}

public class FormacionItem
{
    public int ID { get; set; }
    public string Titulo { get; set; } = "";
    public string Institucion { get; set; } = "";
    public DateTime Fecha_Inicio { get; set; }
    public DateTime? Fecha_Fin { get; set; }

    public string Periodo => Fecha_Fin.HasValue
        ? $"{Fechas.MesAnio(Fecha_Inicio)} – {Fechas.MesAnio(Fecha_Fin.Value)}"
        : $"{Fechas.MesAnio(Fecha_Inicio)} – Actualidad · En curso";
}

public static class Fechas
{
    private static readonly string[] Meses = { "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sept", "Oct", "Nov", "Dic" };

    public static string MesAnio(DateTime fecha) => $"{Meses[fecha.Month - 1]} {fecha.Year}";

    public static DateTime? ParsearMesAnio(string? texto)
    {
        var partes = (texto ?? "").Trim().Split('/');
        if (partes.Length == 2 && int.TryParse(partes[0], out var mes) && int.TryParse(partes[1], out var anio) &&
            mes is >= 1 and <= 12 && anio is >= 1950 and <= 2100)
        {
            return new DateTime(anio, mes, 1);
        }
        return null;
    }

    public static DateTime MesActual => new(DateTime.Today.Year, DateTime.Today.Month, 1);

    public static string Periodo(DateTime inicio, DateTime? fin)
    {
        var hasta = fin ?? DateTime.Today;
        var meses = Math.Max(1, (hasta.Year - inicio.Year) * 12 + hasta.Month - inicio.Month + 1);
        var anios = meses / 12;
        var resto = meses % 12;
        var partes = new List<string>();
        if (anios > 0) partes.Add(anios == 1 ? "1 año" : $"{anios} años");
        if (resto > 0) partes.Add(resto == 1 ? "1 mes" : $"{resto} meses");
        var fechaFin = fin.HasValue ? MesAnio(fin.Value) : "Actualidad";
        return $"{MesAnio(inicio)} – {fechaFin} · {string.Join(" ", partes)}";
    }
}
