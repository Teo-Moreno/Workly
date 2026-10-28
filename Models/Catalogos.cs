namespace Workly.Models;

/// <summary>
/// Opciones fijas de los formularios. Los CHECK de la base usan los mismos valores
/// (Perfil.Estado_Busqueda, UsuarioIdioma.Nivel, Postulacion.Estado, OfertaLaboral.Modalidad...).
/// </summary>
public static class Catalogos
{
    public static readonly string[] EstadosBusqueda = { "Buscando activamente", "Abierto a propuestas", "No estoy buscando" };

    public static readonly string[] Niveles = { "Sin experiencia", "Junior", "Semi Senior", "Senior" };
    public static readonly string[] Modalidades = { "Remoto", "Híbrido", "Presencial" };
    public static readonly string[] Jornadas = { "Tiempo completo", "Medio tiempo", "Por horas" };
    public static readonly string[] Contrataciones = { "Relación de dependencia", "Contrato / Freelance", "Pasantía", "Cualquiera" };
    public static readonly string[] Disponibilidades = { "Inmediata", "En 15 días", "En 30 días", "A convenir" };
    public static readonly string[] NivelesIdioma = { "Básico", "Intermedio", "Avanzado", "Nativo" };

    /// <summary>Tipos de empleo de las búsquedas de Workly. Coinciden con los filtros de JSearch.</summary>
    public static readonly (string Nombre, string JSearch)[] TiposEmpleo =
    {
        ("Tiempo completo", "FULLTIME"),
        ("Medio tiempo", "PARTTIME"),
        ("Contrato / Freelance", "CONTRACTOR"),
        ("Pasantía", "INTERN")
    };

    /// <summary>Estados del tablero de postulaciones (los mueve la persona).</summary>
    public static readonly (string Estado, string Columna, string Color)[] EstadosPostulacion =
    {
        ("Enviada", "Enviadas", "info"),
        ("En revisión", "En revisión", "advertencia"),
        ("Pasé", "Pasé", "exito"),
        ("No pasé", "No pasé", "error")
    };

    /// <summary>Filtro "Fecha de publicación" de Buscar trabajo (valor de JSearch, texto, días).</summary>
    public static readonly (string Valor, string Texto, int Dias)[] FechasPublicacion =
    {
        ("today", "Hoy", 1),
        ("3days", "Últimos 3 días", 3),
        ("week", "Última semana", 7),
        ("month", "Último mes", 30)
    };

    public static readonly (string Valor, string Texto)[] Ordenes =
    {
        ("recientes", "Más nuevas a más viejas"),
        ("antiguas", "Más viejas a más nuevas"),
        ("az", "De la A a la Z")
    };

    public static readonly string[] Rubros =
    {
        "Tecnología y software", "Comercio y retail", "Gastronomía", "Construcción", "Industria y manufactura",
        "Salud", "Educación", "Finanzas y seguros", "Logística y transporte", "Agro", "Turismo y hotelería",
        "Servicios profesionales", "Marketing y publicidad", "Inmobiliaria", "Energía", "Medios y comunicación",
        "Organización sin fines de lucro", "Sector público", "Otro"
    };
}
