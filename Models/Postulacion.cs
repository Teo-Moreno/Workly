namespace Workly.Models;

public class PostulacionItem
{
    public int ID { get; set; }
    public string Estado { get; set; } = "Enviada";
    public DateTime Fecha { get; set; }
    public int? IDOfertaLaboral { get; set; }
    public int? IDOfertaExterna { get; set; }
    public string Titulo { get; set; } = "";
    public string Empresa { get; set; } = "";
    public string? Ubicacion { get; set; }
    public string? Publicador { get; set; }
    public string? Link_Postulacion { get; set; }

    public bool EsExterna => IDOfertaExterna.HasValue;
    public string Iniciales => Textos.Iniciales(Empresa);
    public string Enlace => EsExterna ? "/Empleos/Externa/" + IDOfertaExterna : "/Empleos/Detalle/" + IDOfertaLaboral;
    public string Fuente => EsExterna ? "Vía " + (string.IsNullOrWhiteSpace(Publicador) ? "otro sitio" : Publicador) : "En Workly";
    public string FechaTexto => "Te postulaste el " + Fecha.ToString("d 'de' MMMM", new System.Globalization.CultureInfo("es-AR"));
}

public class Postulante
{
    public int IDPostulacion { get; set; }
    public int IDUsuario { get; set; }
    public DateTime Fecha { get; set; }
    public string Nombre { get; set; } = "";
    public string Apellido { get; set; } = "";
    public string Email { get; set; } = "";
    public string? Telefono { get; set; }
    public string? Foto { get; set; }
    public string? Provincia { get; set; }
    public string? Estado_Busqueda { get; set; }
    public string? Puesto_Buscado { get; set; }
    public string? Nombre_Archivo { get; set; }

    public string NombreCompleto => $"{Nombre} {Apellido}".Trim();
    public string Iniciales => UsuarioActual.Iniciales(Nombre, Apellido);
    public bool TieneCV => !string.IsNullOrEmpty(Nombre_Archivo);
    public string Resumen => string.Join(" · ", new[] { Puesto_Buscado, Provincia }.Where(t => !string.IsNullOrEmpty(t)));
    public string TelefonoLink => (Telefono ?? "").Replace(" ", "").Replace("-", "");
}

public static class Postulaciones
{
    public static bool CambiarEstado(int idUsuario, int idPostulacion, string? estado) =>
        Catalogos.EstadosPostulacion.Any(e => e.Estado == estado) && BD.CambiarEstadoPostulacion(idUsuario, idPostulacion, estado!);

    public static Resultado Eliminar(int idUsuario, int idPostulacion) =>
        Resultado.Segun(BD.EliminarPostulacion(idUsuario, idPostulacion), "Sacamos la postulación de tu tablero.", "No encontramos esa postulación.");

    public static Resultado Guardar(int idUsuario, int idOferta, bool externa, bool esPersona)
    {
        if (!esPersona)
        {
            return Resultado.Mal("Las cuentas de empresa no guardan ofertas.");
        }
        return Resultado.Segun(BD.GuardarOferta(idUsuario, idOferta, externa),
            "Guardamos la oferta. La encontrás en Guardadas.", "Esa oferta ya estaba guardada o ya no está publicada.", "advertencia");
    }

    public static Resultado QuitarGuardada(int idUsuario, int idOferta, bool externa) =>
        Resultado.Segun(BD.QuitarGuardada(idUsuario, idOferta, externa),
            "Sacamos la oferta de tus guardadas.", "Esa oferta no estaba en tus guardadas.", "advertencia");
}
