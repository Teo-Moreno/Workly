namespace Workly.Models;

public record CategoriaAyuda(string Id, string Nombre, string Icono, string Texto);

public record PreguntaAyuda(string Categoria, string Pregunta, string Respuesta);

public static class Ayuda
{
    public static readonly CategoriaAyuda[] Categorias =
    {
        new("postulaciones", "Postulaciones", "send", "Postularte y seguir cada proceso"),
        new("perfil", "Mi perfil", "user-square", "Datos, CV y qué buscás"),
        new("cuenta", "Cuenta y seguridad", "lock", "Contraseña y datos de la cuenta"),
        new("publicar", "Publicar búsquedas", "building", "Empresas y personas")
    };

    public static readonly PreguntaAyuda[] Preguntas =
    {
        new("postulaciones", "¿Cómo me postulo a una búsqueda?", "En las búsquedas publicadas en Workly tocá \"Postularme\": quien la publicó recibe tu perfil y tu CV. Para eso necesitás tener tu CV cargado. Las búsquedas de otros sitios se abren en su página original; cuando te postules ahí, tocá \"Ya me postulé\" para sumarla a tu tablero."),
        new("postulaciones", "¿Cómo sé en qué etapa está mi postulación?", "En Mis postulaciones tenés un tablero con cuatro columnas: Enviadas, En revisión, Pasé y No pasé. Las tarjetas las movés vos a medida que avanza cada proceso, arrastrándolas o eligiendo la etapa en cada tarjeta."),
        new("postulaciones", "¿Cómo guardo una oferta para verla después?", "Abrí la oferta y tocá \"Guardar\". Las encontrás todas en Guardadas, donde también las podés quitar. Se pueden guardar búsquedas de Workly y ofertas de otros sitios."),
        new("postulaciones", "¿Puedo sacar una postulación del tablero?", "Sí. En la tarjeta de la postulación tocá \"Quitar\". Si era una búsqueda de Workly, quien la publicó deja de verte entre sus postulantes."),
        new("perfil", "¿Quién ve mi perfil?", "Solo quienes publicaron las búsquedas a las que te postulaste en Workly: ven tus datos, tu experiencia, tu formación y tu CV."),
        new("perfil", "¿Para qué sirve completar \"Qué busco\"?", "Con el puesto que buscás armamos las ofertas de tu inicio. Lo cambiás cuando quieras desde Configuración › Qué busco."),
        new("perfil", "¿Qué formatos de CV y de foto aceptan?", "El CV puede ser PDF, DOC o DOCX, y la foto JPG, PNG o WEBP. En los dos casos, de hasta 5 MB."),
        new("cuenta", "¿Cómo cambio mi contraseña?", "En Configuración › Seguridad escribí tu contraseña actual y la nueva dos veces. Si entrás con Google o LinkedIn, desde ahí también podés crear una contraseña."),
        new("cuenta", "¿Cómo elimino mi cuenta?", "En Configuración › Seguridad, al final, escribí ELIMINAR y confirmá. Se borran tu perfil, tu CV, tus postulaciones y tus publicaciones, y no se puede deshacer."),
        new("publicar", "¿Cómo registro mi empresa?", "En Crear cuenta elegí \"Empresa\". Te pedimos el CUIT, la razón social, el rubro y el sitio web, y el email tiene que ser del dominio de ese sitio. Con la cuenta de empresa publicás búsquedas al instante y ves a todas las personas que se postulan."),
        new("publicar", "¿Puedo publicar una búsqueda sin ser empresa?", "Sí, desde \"Publicar búsqueda\". Antes de salir la revisa el equipo de Workly; si la aceptamos se publica junto con las demás, y si no, en Mis publicaciones vas a ver el motivo.")
    };

    public static List<PreguntaAyuda> PreguntasDe(string categoria) => Preguntas.Where(p => p.Categoria == categoria).ToList();
}
