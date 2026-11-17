using System.Globalization;
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

    public static async Task<BuscarTrabajoViewModel> Buscar(BuscarTrabajoViewModel filtros, string? idSeleccionada, IQueryCollection consulta,
                                                            int idUsuario, JSearch jsearch)
    {
        var modelo = Preparar(filtros);
        var pais = modelo.Paises.FirstOrDefault(p => p.ID == modelo.IDPais);
        var provincia = modelo.Provincias.FirstOrDefault(p => p.ID == modelo.IDProvincia);
        var fecha = Catalogos.FechasPublicacion.FirstOrDefault(f => f.Valor == modelo.Fecha);

        var ofertas = new List<Oferta>();
        if (string.IsNullOrEmpty(modelo.Cursor))
        {
            ofertas.AddRange(BD.BuscarOfertas(new FiltrosOfertas
            {
                Texto = modelo.Q,
                IDProvincia = modelo.IDProvincia,
                Modalidades = modelo.Modalidad,
                TiposEmpleo = modelo.Tipo,
                Dias = fecha.Valor == null ? null : fecha.Dias
            }, idUsuario));
        }

        if (pais != null)
        {
            var lugar = provincia?.Nombre ?? pais.Nombre;
            var soloRemoto = modelo.Modalidad.Count == 1 && modelo.Modalidad[0] == "Remoto";
            var tipos = Catalogos.TiposEmpleo.Where(t => modelo.Tipo.Contains(t.Nombre)).Select(t => t.JSearch);
            var puesto = modelo.BuscoAlgo ? modelo.Q : "empleos";
            var resultado = await jsearch.Buscar($"{puesto} en {lugar}", pais.Codigo_ISO, soloRemoto, tipos, modelo.Fecha, modelo.Cursor);
            modelo.ErrorExternas = resultado.Error;
            modelo.CursorSiguiente = resultado.Cursor;
            var externas = resultado.Ofertas;
            if (modelo.Modalidad.Count > 0 && !modelo.Modalidad.Contains("Remoto"))
            {
                externas = externas.Where(o => o.Modalidad != "Remoto").ToList();
            }
            BD.MarcarPostuladas(externas, idUsuario);
            ofertas.AddRange(externas);
        }

        modelo.Ofertas = modelo.Orden switch
        {
            "az" => ofertas.OrderBy(o => o.Titulo, StringComparer.Create(new CultureInfo("es-AR"), true)).ToList(),
            "antiguas" => ofertas.OrderBy(o => o.Fecha_Publicacion ?? DateTime.MaxValue).ToList(),
            _ => ofertas.OrderByDescending(o => o.Fecha_Publicacion ?? DateTime.MinValue).ToList()
        };
        modelo.Seleccionada = modelo.Ofertas.FirstOrDefault(o => o.Clave == idSeleccionada) ?? modelo.Ofertas.FirstOrDefault();
        modelo.Consulta = consulta.Where(q => q.Key != "id")
            .SelectMany(q => q.Value.Select(v => $"{Uri.EscapeDataString(q.Key)}={Uri.EscapeDataString(v ?? "")}")).ToList();
        return modelo;
    }

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

    public static async Task<(List<Oferta> Ofertas, bool Error)> ParaVos(MiPerfilViewModel perfil, int idUsuario, JSearch jsearch)
    {
        var puesto = perfil.Preferencia.Puesto_Buscado;
        if (string.IsNullOrWhiteSpace(puesto))
        {
            return (new List<Oferta>(), false);
        }
        var idProvincia = perfil.Preferencia.IDProvincia ?? perfil.Perfil.IDProvincia;
        var provincia = BD.ObtenerProvincias().FirstOrDefault(p => p.ID == idProvincia);
        var paises = BD.ObtenerPaises();
        var pais = paises.FirstOrDefault(p => p.ID == (provincia?.IDPais ?? perfil.Perfil.IDPais)) ?? paises.FirstOrDefault();
        var modalidades = perfil.Preferencia.ListaModalidades;

        var error = false;
        var ofertas = BD.BuscarOfertas(new FiltrosOfertas { Texto = puesto, IDProvincia = provincia?.ID, Modalidades = modalidades }, idUsuario);
        if (pais != null)
        {
            var soloRemoto = modalidades.Count == 1 && modalidades[0] == "Remoto";
            var resultado = await jsearch.Buscar($"{puesto} en {provincia?.Nombre ?? pais.Nombre}", pais.Codigo_ISO, soloRemoto,
                                                 Array.Empty<string>(), "month", null);
            error = resultado.Error;
            BD.MarcarPostuladas(resultado.Ofertas, idUsuario);
            ofertas.AddRange(resultado.Ofertas);
        }
        return (ofertas.Where(o => !o.YaPostulado).Take(6).ToList(), error);
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
