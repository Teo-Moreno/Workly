using Microsoft.AspNetCore.Http;

namespace Workly.Models;

public static class Empleos
{
    public static BuscarTrabajoViewModel Preparar(BuscarTrabajoViewModel modelo)
    {
        modelo.Q = Validaciones.Limpiar(modelo.Q);
        modelo.Paises = BD.ObtenerPaises();
        modelo.Provincias = BD.ObtenerProvincias();
        var pais = modelo.Paises.FirstOrDefault(p => p.ID == modelo.IDPais) ?? modelo.Paises.FirstOrDefault();
        modelo.IDPais = pais?.ID;
        modelo.IDProvincia = modelo.Provincias.FirstOrDefault(p => p.ID == modelo.IDProvincia && p.IDPais == modelo.IDPais)?.ID;
        modelo.Modalidad = modelo.Modalidad.Where(Catalogos.Modalidades.Contains).Distinct().ToList();
        modelo.Tipo = modelo.Tipo.Where(t => Catalogos.TiposEmpleo.Any(c => c.Nombre == t)).Distinct().ToList();
        modelo.Fecha = Catalogos.FechasPublicacion.FirstOrDefault(f => f.Valor == modelo.Fecha).Valor;
        if (!Catalogos.Ordenes.Any(o => o.Valor == modelo.Orden)) modelo.Orden = "recientes";
        return modelo;
    }

    public const int OfertasPorPagina = 42;

    public static BuscarTrabajoViewModel Buscar(BuscarTrabajoViewModel filtros, IQueryCollection consulta, int idUsuario)
    {
        var modelo = Preparar(filtros);
        var fecha = Catalogos.FechasPublicacion.FirstOrDefault(f => f.Valor == modelo.Fecha);
        modelo.Pagina = Math.Clamp(modelo.Pagina, 1, 1000);
        modelo.Ofertas = BD.BuscarOfertas(new FiltrosOfertas
        {
            Texto = modelo.Q,
            IDPais = modelo.IDPais,
            IDProvincia = modelo.IDProvincia,
            Modalidades = modelo.Modalidad,
            TiposEmpleo = modelo.Tipo,
            Dias = fecha.Valor == null ? null : fecha.Dias,
            Orden = modelo.Orden,
            Desde = (modelo.Pagina - 1) * OfertasPorPagina,
            Cantidad = OfertasPorPagina
        }, idUsuario);
        modelo.Total = modelo.Ofertas.FirstOrDefault()?.Total ?? 0;
        modelo.PorPagina = OfertasPorPagina;
        modelo.Consulta = consulta.Where(q => q.Key != "Pagina")
            .SelectMany(q => q.Value.Select(v => $"{Uri.EscapeDataString(q.Key)}={Uri.EscapeDataString(v ?? "")}")).ToList();
        return modelo;
    }

    public static List<string> PuestosParaAnimacion() =>
        BD.ObtenerTitulosRecientes(30)
            .Select(t => Textos.Recortar(t, 48))
            .Where(t => t.Length > 2)
            .Distinct(StringComparer.OrdinalIgnoreCase)
            .Take(8)
            .ToList();

    public static bool TieneCV(int idUsuario) => !string.IsNullOrEmpty(BD.ObtenerCV(idUsuario)?.Nombre_Archivo);

    public static DetalleOferta? Detalle(int idOferta, int idUsuario, bool estaLogueado, bool esModerador, bool esEmpresa, bool esPersona)
    {
        var oferta = BD.ObtenerOferta(idOferta, idUsuario);
        if (oferta == null)
        {
            return null;
        }
        var esPropia = estaLogueado && oferta.IDUsuario_Publicador == idUsuario;
        if (oferta.Estado_Publicacion != "Aprobada" && !esPropia && !esModerador)
        {
            return null;
        }
        return ArmarDetalle(oferta, esPropia, idUsuario, esEmpresa, esPersona);
    }

    public static DetalleOferta? DetalleExterna(int idOferta, int idUsuario, bool esEmpresa, bool esPersona)
    {
        var oferta = BD.ObtenerOfertaExterna(idOferta, idUsuario);
        return oferta == null ? null : ArmarDetalle(oferta, false, idUsuario, esEmpresa, esPersona);
    }

    public static DetalleOferta? ParaRevisar(int idOferta)
    {
        var oferta = BD.ObtenerOferta(idOferta, 0);
        if (oferta == null)
        {
            return null;
        }
        return new DetalleOferta
        {
            Oferta = oferta,
            Empresa = oferta.IDEmpresa.HasValue ? BD.ObtenerEmpresa(oferta.IDEmpresa.Value) : null,
            EsRevision = true
        };
    }

    private static DetalleOferta ArmarDetalle(Oferta oferta, bool esPropia, int idUsuario, bool esEmpresa, bool esPersona) => new()
    {
        Oferta = oferta,
        Empresa = oferta.IDEmpresa.HasValue ? BD.ObtenerEmpresa(oferta.IDEmpresa.Value) : null,
        EsPropia = esPropia,
        PuedePostular = !oferta.EsExterna && !esPropia && !oferta.YaPostulado && !esEmpresa &&
                        oferta.Estado_Publicacion == "Aprobada" && !oferta.EstaCerrada,
        TieneCV = esPersona && TieneCV(idUsuario)
    };

    public static Resultado Postular(int idUsuario, int idOferta, bool esPersona)
    {
        if (!esPersona)
        {
            return Resultado.Mal("Las cuentas de empresa no se postulan a búsquedas.");
        }
        var oferta = BD.ObtenerOferta(idOferta, idUsuario);
        if (oferta == null || oferta.Estado_Publicacion != "Aprobada" || oferta.EstaCerrada)
        {
            return Resultado.Mal("Esta búsqueda ya no recibe postulaciones.");
        }
        if (oferta.IDUsuario_Publicador == idUsuario)
        {
            return Resultado.Mal("No podés postularte a una búsqueda que publicaste vos.");
        }
        if (!TieneCV(idUsuario))
        {
            return Resultado.Mal("Para postularte necesitás subir tu CV. Lo podés subir desde tu perfil.", "advertencia");
        }
        return Resultado.Segun(BD.Postular(idUsuario, idOferta),
            $"¡Listo! Te postulaste a {oferta.Titulo}. Seguila desde tu tablero de postulaciones.", "Ya te habías postulado a esta búsqueda.", "advertencia");
    }

    public static Resultado RegistrarExterna(int idUsuario, int idOfertaExterna, bool esPersona)
    {
        if (!esPersona)
        {
            return Resultado.Mal("Las cuentas de empresa no tienen tablero de postulaciones.");
        }
        return Resultado.Segun(BD.RegistrarPostulacionExterna(idUsuario, idOfertaExterna),
            "Agregamos la postulación a tu tablero.", "Esa postulación ya estaba en tu tablero.", "advertencia");
    }

    public static List<Oferta> ParaVos(MiPerfilViewModel perfil, int idUsuario)
    {
        var puesto = perfil.Preferencia.Puesto_Buscado;
        if (string.IsNullOrWhiteSpace(puesto))
        {
            return new List<Oferta>();
        }
        var idProvincia = perfil.Preferencia.IDProvincia ?? perfil.Perfil.IDProvincia;
        var provincia = BD.ObtenerProvincias().FirstOrDefault(p => p.ID == idProvincia);
        var ofertas = BD.BuscarOfertas(new FiltrosOfertas
        {
            Texto = puesto,
            IDPais = provincia?.IDPais ?? perfil.Perfil.IDPais,
            IDProvincia = provincia?.ID,
            Modalidades = perfil.Preferencia.ListaModalidades,
            Cantidad = 30
        }, idUsuario);
        return ofertas.Where(o => !o.YaPostulado).Take(6).ToList();
    }
}

public class DetalleOferta
{
    public Oferta Oferta { get; set; } = new();
    public Empresa? Empresa { get; set; }
    public bool EsPropia { get; set; }
    public bool EsRevision { get; set; }
    public bool PuedePostular { get; set; }
    public bool TieneCV { get; set; }
}
