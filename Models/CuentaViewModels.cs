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

public class RegistroViewModel
{
    // ---- Paso 1 · Tus datos (tabla Usuario) ----
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

    [Required(ErrorMessage = "Elegí una contraseña")]
    [StringLength(100, MinimumLength = 8, ErrorMessage = "La contraseña debe tener entre 8 y 100 caracteres")]
    [RegularExpression(@"^(?=.*[A-Za-zÁÉÍÓÚÜÑáéíóúüñ])(?=.*\d).+$", ErrorMessage = "Usá al menos una letra y un número")]
    [DataType(DataType.Password)]
    public string Contrasena { get; set; } = "";

    [Range(typeof(bool), "true", "true", ErrorMessage = "Tenés que aceptar los términos para continuar")]
    public bool AceptaTerminos { get; set; }

    // ---- Paso 2 · Tu perfil (tabla Perfil) ----
    [Required(ErrorMessage = "Elegí dónde vivís")]
    [StringLength(100)]
    public string Ubicacion { get; set; } = "";

    [StringLength(30, ErrorMessage = "Usá hasta 30 caracteres")]
    [RegularExpression(@"^[0-9+()\s-]{6,30}$", ErrorMessage = "Ingresá solo números, espacios y + ( ) -")]
    public string? Telefono { get; set; }

    [StringLength(500, ErrorMessage = "Usá hasta 500 caracteres")]
    public string? Descripcion { get; set; }

    public IFormFile? Foto { get; set; }

    // ---- Paso 3 · Tu CV (tabla CV) ----
    public IFormFile? ArchivoCV { get; set; }

    [StringLength(200, ErrorMessage = "Usá hasta 200 caracteres")]
    public string? SitioWeb { get; set; }

    public static readonly string[] Ubicaciones =
    {
        "CABA", "GBA Norte", "GBA Oeste", "GBA Sur", "La Plata", "Córdoba", "Rosario",
        "Mendoza", "Mar del Plata", "Tucumán", "Neuquén", "Otra ubicación"
    };
}

// Datos que se muestran en "Mi perfil" y "Configuración"
public class MiPerfilViewModel
{
    public Usuario Usuario { get; set; } = new();
    public Perfil Perfil { get; set; } = new();
    public CV? CV { get; set; }
    public List<ExperienciaItem> Experiencias { get; set; } = new();
    public List<FormacionItem> Formaciones { get; set; } = new();

    public List<(string Texto, bool Listo)> Checklist => new()
    {
        ("Datos personales", true),
        ("Foto de perfil", !string.IsNullOrEmpty(Perfil.Foto)),
        ("Sobre mí", !string.IsNullOrWhiteSpace(Perfil.Descripcion)),
        ("Teléfono", !string.IsNullOrWhiteSpace(Perfil.Telefono)),
        ("Experiencia laboral", Experiencias.Count > 0),
        ("Formación", Formaciones.Count > 0),
        ("CV", !string.IsNullOrEmpty(CV?.Nombre_Archivo))
    };

    public int PorcentajeCompleto
    {
        get
        {
            var items = Checklist;
            return (int)Math.Round(items.Count(i => i.Listo) * 100.0 / items.Count);
        }
    }
}

// ExperienciaLaboral + nombre de la Empresa
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

// UsuarioEducacion + datos de la Educacion
public class FormacionItem
{
    public int ID { get; set; }
    public string Titulo { get; set; } = "";
    public string Institucion { get; set; } = "";
    public DateTime Fecha_Inicio { get; set; }
    public DateTime? Fecha_Fin { get; set; }

    public string Periodo => Fecha_Fin.HasValue
        ? $"{Fecha_Inicio.Year} – {Fecha_Fin.Value.Year} · {(Fecha_Fin.Value <= DateTime.Today ? "Finalizada" : "En curso")}"
        : $"{Fecha_Inicio.Year} – Actualidad · En curso";
}

public static class Fechas
{
    private static readonly string[] Meses = { "Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic" };

    public static string MesAnio(DateTime fecha) => $"{Meses[fecha.Month - 1]} {fecha.Year}";

    // "Mar 2025 – Actualidad · 1 año 7 meses"
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
