namespace Workly.Models;

public record DatoOferta(string Etiqueta, string Valor);

public class Oferta
{
    public bool EsExterna { get; set; }

    public int ID { get; set; }

    public string Titulo { get; set; } = "";
    public string Empresa { get; set; } = "";
    public int? IDEmpresa { get; set; }
    public string? Logo { get; set; }
    public string? Ubicacion { get; set; }
    public string? Provincia { get; set; }
    public int? IDProvincia { get; set; }
    public string? Modalidad { get; set; }
    public string? Tipo_Contrato { get; set; }
    public int? Salario { get; set; }
    public string? SalarioTexto { get; set; }
    public int Cantidad_Puestos { get; set; } = 1;
    public string? Descripcion { get; set; }
    public DateTime? Fecha_Publicacion { get; set; }
    public DateTime? Fecha_Cierre { get; set; }
    public string? Puestos { get; set; }

    public int? IDUsuario_Publicador { get; set; }

    public string? TipoPublicador { get; set; }
    public string Estado_Publicacion { get; set; } = "Aprobada";
    public string? Motivo_Rechazo { get; set; }
    public int CantidadPostulantes { get; set; }

    public string? ID_Externo { get; set; }
    public string? Link_Postulacion { get; set; }
    public string? Publicador { get; set; }

    public bool YaPostulado { get; set; }

    public bool Guardada { get; set; }

    public DateTime? Fecha_Guardado { get; set; }
    public int IDFavorito { get; set; }

    public string Clave => (EsExterna ? "x" : "w") + ID;

    public string Iniciales => Textos.Iniciales(Empresa);

    public string? SalarioVisible => SalarioTexto ?? (Salario is > 0 ? Textos.Pesos(Salario.Value) + " brutos por mes" : null);

    public string PublicadaTexto => Textos.Publicada(Fecha_Publicacion);

    public bool EstaCerrada => Fecha_Cierre.HasValue && Fecha_Cierre.Value.Date < DateTime.Today;

    public string? UbicacionVisible =>
        string.Join(" · ", new[] { Ubicacion, Provincia }.Where(t => !string.IsNullOrWhiteSpace(t)).Distinct()) is { Length: > 0 } t ? t : null;

    public bool EsOficial => EsExterna || TipoPublicador == Usuario.TipoEmpresa;

    public string Enlace => EsExterna ? "/Empleos/Externa/" + ID : "/Empleos/Detalle/" + ID;

    public bool NoDisponible => !EsExterna && (EstaCerrada || Estado_Publicacion != "Aprobada");

    public string Resumen => string.Join(" · ", new[] { Empresa, UbicacionVisible, SalarioVisible }.Where(t => !string.IsNullOrEmpty(t)));

    public string ResumenPublicada => string.Join(" · ", new[] { Empresa, UbicacionVisible, PublicadaTexto }.Where(t => !string.IsNullOrEmpty(t)));

    public List<string> DatosCabecera => new[] { UbicacionVisible, PublicadaTexto }.Where(t => !string.IsNullOrEmpty(t)).Select(t => t!).ToList();

    public List<string> ListaPuestos => (Puestos ?? "").Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries).ToList();

    public List<DatoOferta> Datos
    {
        get
        {
            var datos = new List<DatoOferta>();
            if (SalarioVisible != null) datos.Add(new DatoOferta("Salario", SalarioVisible));
            if (!EsExterna) datos.Add(new DatoOferta("Vacantes", Cantidad_Puestos.ToString()));
            if (Fecha_Cierre.HasValue) datos.Add(new DatoOferta("Recibe postulaciones hasta", Vistas.Fecha(Fecha_Cierre)));
            return datos;
        }
    }

    public string EstadoTexto => Estado_Publicacion switch
    {
        "Pendiente" => "En revisión",
        "Rechazada" => "Rechazada",
        _ when EstaCerrada => "Cerrada",
        _ => "Publicada"
    };

    public string EstadoColor => Estado_Publicacion switch
    {
        "Pendiente" => "advertencia",
        "Rechazada" => "error",
        _ when EstaCerrada => "gris",
        _ => "exito"
    };

    public string Fuente => EsExterna ? (string.IsNullOrWhiteSpace(Publicador) ? "otro sitio" : Publicador!) : "Workly";
}
