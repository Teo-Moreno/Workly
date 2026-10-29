using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

public class EmpleosController : Controller
{
    private readonly JSearch _jsearch;

    public EmpleosController(JSearch jsearch)
    {
        _jsearch = jsearch;
    }

    public async Task<IActionResult> Index(BuscarTrabajoViewModel filtros, string? id)
    {
        var modelo = filtros;
        modelo.Q = Validaciones.Limpiar(modelo.Q);
        modelo.Paises = BD.ObtenerPaises();
        modelo.Provincias = BD.ObtenerProvincias();

        var pais = modelo.Paises.FirstOrDefault(p => p.ID == modelo.IDPais) ?? modelo.Paises.FirstOrDefault();
        modelo.IDPais = pais?.ID;
        var provincia = modelo.Provincias.FirstOrDefault(p => p.ID == modelo.IDProvincia && p.IDPais == modelo.IDPais);
        modelo.IDProvincia = provincia?.ID;

        modelo.Modalidad = modelo.Modalidad.Where(Catalogos.Modalidades.Contains).Distinct().ToList();
        modelo.Tipo = modelo.Tipo.Where(t => Catalogos.TiposEmpleo.Any(c => c.Nombre == t)).Distinct().ToList();
        var fecha = Catalogos.FechasPublicacion.FirstOrDefault(f => f.Valor == modelo.Fecha);
        modelo.Fecha = fecha.Valor;
        if (!Catalogos.Ordenes.Any(o => o.Valor == modelo.Orden)) modelo.Orden = "recientes";

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
            }, User.IdUsuario()));
        }

        if (pais != null)
        {
            var lugar = provincia?.Nombre ?? pais.Nombre;
            var soloRemoto = modelo.Modalidad.Count == 1 && modelo.Modalidad[0] == "Remoto";
            var tipos = Catalogos.TiposEmpleo.Where(t => modelo.Tipo.Contains(t.Nombre)).Select(t => t.JSearch);
            var puesto = modelo.BuscoAlgo ? modelo.Q : "empleos";
            var resultado = await _jsearch.Buscar($"{puesto} en {lugar}", pais.Codigo_ISO, soloRemoto, tipos, modelo.Fecha, modelo.Cursor);
            modelo.ErrorExternas = resultado.Error;
            modelo.CursorSiguiente = resultado.Cursor;
            var externas = resultado.Ofertas;
            if (modelo.Modalidad.Count > 0 && !modelo.Modalidad.Contains("Remoto"))
            {
                externas = externas.Where(o => o.Modalidad != "Remoto").ToList();
            }
            BD.MarcarPostuladas(externas, User.IdUsuario());
            ofertas.AddRange(externas);
        }

        modelo.Ofertas = modelo.Orden switch
        {
            "az" => ofertas.OrderBy(o => o.Titulo, StringComparer.Create(new System.Globalization.CultureInfo("es-AR"), true)).ToList(),
            "antiguas" => ofertas.OrderBy(o => o.Fecha_Publicacion ?? DateTime.MaxValue).ToList(),
            _ => ofertas.OrderByDescending(o => o.Fecha_Publicacion ?? DateTime.MinValue).ToList()
        };
        modelo.Seleccionada = modelo.Ofertas.FirstOrDefault(o => o.Clave == id) ?? modelo.Ofertas.FirstOrDefault();
        return View(modelo);
    }

    public IActionResult Detalle(int id)
    {
        var oferta = BD.ObtenerOferta(id, User.IdUsuario());
        if (oferta == null)
        {
            return NotFound();
        }
        var esPropia = User.EstaLogueado() && oferta.IDUsuario_Publicador == User.IdUsuario();
        if (oferta.Estado_Publicacion != "Aprobada" && !esPropia && !User.EsModerador())
        {
            return NotFound();
        }
        return View(ArmarDetalle(oferta, esPropia));
    }

    public IActionResult Externa(int id)
    {
        var oferta = BD.ObtenerOfertaExterna(id, User.IdUsuario());
        if (oferta == null)
        {
            return NotFound();
        }
        return View("Detalle", ArmarDetalle(oferta, false));
    }

    [HttpPost]
    [Authorize]
    [ValidateAntiForgeryToken]
    public IActionResult Postular(int id, string? volver)
    {
        if (!User.EsPersona())
        {
            return Volver("Las cuentas de empresa no se postulan a búsquedas.", "error", volver, id);
        }
        var oferta = BD.ObtenerOferta(id, User.IdUsuario());
        if (oferta == null || oferta.Estado_Publicacion != "Aprobada" || oferta.EstaCerrada)
        {
            return Volver("Esta búsqueda ya no recibe postulaciones.", "error", volver, id);
        }
        if (oferta.IDUsuario_Publicador == User.IdUsuario())
        {
            return Volver("No podés postularte a una búsqueda que publicaste vos.", "error", volver, id);
        }
        if (string.IsNullOrEmpty(BD.ObtenerCV(User.IdUsuario())?.Nombre_Archivo))
        {
            return Volver("Para postularte necesitás subir tu CV. Lo podés subir desde tu perfil.", "advertencia", volver, id);
        }
        return BD.Postular(User.IdUsuario(), id)
            ? Volver($"¡Listo! Te postulaste a {oferta.Titulo}. Seguila desde tu tablero de postulaciones.", "exito", volver, id)
            : Volver("Ya te habías postulado a esta búsqueda.", "advertencia", volver, id);
    }

    [HttpPost]
    [Authorize]
    [ValidateAntiForgeryToken]
    public IActionResult RegistrarExterna(int id, string? volver)
    {
        if (!User.EsPersona())
        {
            return Volver("Las cuentas de empresa no tienen tablero de postulaciones.", "error", volver, null, id);
        }
        return BD.RegistrarPostulacionExterna(User.IdUsuario(), id)
            ? Volver("Agregamos la postulación a tu tablero.", "exito", volver, null, id)
            : Volver("Esa postulación ya estaba en tu tablero.", "advertencia", volver, null, id);
    }

    private OfertaDetalleViewModel ArmarDetalle(Oferta oferta, bool esPropia) => new()
    {
        Oferta = oferta,
        Empresa = oferta.IDEmpresa.HasValue ? BD.ObtenerEmpresa(oferta.IDEmpresa.Value) : null,
        EsPropia = esPropia,
        PuedePostular = !oferta.EsExterna && !esPropia && !oferta.YaPostulado && !User.EsEmpresa() &&
                        oferta.Estado_Publicacion == "Aprobada" && !oferta.EstaCerrada,
        TieneCV = User.EsPersona() && !string.IsNullOrEmpty(BD.ObtenerCV(User.IdUsuario())?.Nombre_Archivo)
    };

    private IActionResult Volver(string mensaje, string tipo, string? volver, int? idOferta, int? idExterna = null)
    {
        TempData["Mensaje"] = mensaje;
        TempData["MensajeTipo"] = tipo;
        if (!string.IsNullOrEmpty(volver) && Url.IsLocalUrl(volver))
        {
            return LocalRedirect(volver);
        }
        return idExterna.HasValue
            ? RedirectToAction(nameof(Externa), new { id = idExterna })
            : RedirectToAction(nameof(Detalle), new { id = idOferta });
    }
}
