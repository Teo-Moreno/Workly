using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class PublicacionesController : Controller
{
    private readonly IWebHostEnvironment _entorno;

    public PublicacionesController(IWebHostEnvironment entorno)
    {
        _entorno = entorno;
    }

    public IActionResult Index()
    {
        return View(new PublicacionesViewModel
        {
            Ofertas = BD.ObtenerOfertasPublicadas(User.IdUsuario()),
            EsEmpresa = User.EsEmpresa()
        });
    }

    [HttpGet]
    public IActionResult Nueva()
    {
        var modelo = new PublicarViewModel();
        CargarFormulario(modelo);
        return View(modelo);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Nueva(PublicarViewModel modelo)
    {
        CargarFormulario(modelo);
        var empresa = User.EsEmpresa() ? BD.ObtenerEmpresaDeUsuario(User.IdUsuario()) : null;
        if (User.EsEmpresa() && empresa == null)
        {
            return RedirectToAction("IniciarSesion", "Cuenta");
        }

        modelo.Descripcion = (modelo.Descripcion ?? "").Replace("\r\n", "\n");
        ModelState.Remove(nameof(modelo.Descripcion));
        if (modelo.Descripcion.Trim().Length is < 40 or > 2000)
        {
            ModelState.AddModelError(nameof(modelo.Descripcion), "Usá entre 40 y 2000 caracteres");
        }
        if (!User.EsEmpresa() && string.IsNullOrWhiteSpace(modelo.EmpresaNombre))
        {
            ModelState.AddModelError(nameof(modelo.EmpresaNombre), "Escribí el nombre de la empresa o el negocio que contrata");
        }
        if (modelo.Modalidad != null && !Catalogos.Modalidades.Contains(modelo.Modalidad))
        {
            ModelState.AddModelError(nameof(modelo.Modalidad), "Elegí una opción de la lista");
        }
        if (modelo.TipoEmpleo != null && !Catalogos.TiposEmpleo.Any(t => t.Nombre == modelo.TipoEmpleo))
        {
            ModelState.AddModelError(nameof(modelo.TipoEmpleo), "Elegí una opción de la lista");
        }
        var provincia = modelo.Provincias.FirstOrDefault(p => p.ID == modelo.IDProvincia);
        if (modelo.IDProvincia != null && (provincia == null || provincia.IDPais != modelo.IDPais))
        {
            ModelState.AddModelError(nameof(modelo.IDProvincia), "Elegí una provincia de la lista");
        }
        if (modelo.FechaCierre.HasValue && modelo.FechaCierre.Value.Date < DateTime.Today)
        {
            ModelState.AddModelError(nameof(modelo.FechaCierre), "La fecha de cierre no puede ser anterior a hoy");
        }
        if (!User.EsEmpresa() && !string.IsNullOrWhiteSpace(modelo.EmpresaNombre) && BD.NombreEmpresaConCuenta(modelo.EmpresaNombre.Trim()))
        {
            ModelState.AddModelError(nameof(modelo.EmpresaNombre), "Esa empresa tiene cuenta en Workly: sus búsquedas las publica ella.");
        }

        if (!ModelState.IsValid)
        {
            return View(modelo);
        }

        var esPersona = !User.EsEmpresa();
        var id = BD.CrearOferta(new OfertaNueva
        {
            IDUsuario_Publicador = User.IdUsuario(),
            IDEmpresa = empresa?.ID,
            EmpresaNombre = modelo.EmpresaNombre?.Trim(),
            Titulo = modelo.Titulo.Trim(),
            Puesto = modelo.Puesto.Trim(),
            Descripcion = modelo.Descripcion.Trim(),
            Ubicacion = Validaciones.Limpiar(modelo.Ubicacion),
            IDProvincia = provincia?.ID,
            Modalidad = modelo.Modalidad!,
            Tipo_Contrato = modelo.TipoEmpleo!,
            Salario = modelo.Salario is > 0 ? modelo.Salario : null,
            Cantidad_Puestos = modelo.CantidadPuestos,
            Fecha_Cierre = modelo.FechaCierre?.Date,
            Estado_Publicacion = esPersona ? "Pendiente" : "Aprobada"
        });

        TempData["Mensaje"] = esPersona
            ? "Recibimos tu búsqueda. La revisamos y, si está todo bien, la publicamos."
            : "¡Publicamos tu búsqueda! Ya aparece en Buscar trabajo.";
        return RedirectToAction(nameof(Detalle), new { id });
    }

    public IActionResult Detalle(int id)
    {
        var oferta = BD.ObtenerOferta(id, User.IdUsuario());
        if (oferta == null || oferta.IDUsuario_Publicador != User.IdUsuario())
        {
            return NotFound();
        }
        return View(new PublicacionDetalleViewModel { Oferta = oferta, Postulantes = BD.ObtenerPostulantes(id) });
    }

    public IActionResult Postulante(int id)
    {
        var postulacion = BD.ObtenerPostulacionDePublicador(id, User.IdUsuario());
        if (postulacion == null)
        {
            return NotFound();
        }
        var perfil = BD.ObtenerMiPerfil(postulacion.Value.IDUsuario);
        var oferta = BD.ObtenerOferta(postulacion.Value.IDOferta, User.IdUsuario());
        if (perfil == null || oferta == null)
        {
            return NotFound();
        }
        return View(new PostulanteViewModel { IDPostulacion = id, Oferta = oferta, Perfil = perfil });
    }

    public IActionResult CV(int id)
    {
        var postulacion = BD.ObtenerPostulacionDePublicador(id, User.IdUsuario());
        var cv = postulacion == null ? null : BD.ObtenerCV(postulacion.Value.IDUsuario);
        if (string.IsNullOrEmpty(cv?.Nombre_Archivo) || cv.Nombre_Archivo != Path.GetFileName(cv.Nombre_Archivo))
        {
            return NotFound();
        }
        var ruta = Path.Combine(Archivos.CarpetaCV(_entorno.ContentRootPath), cv.Nombre_Archivo);
        if (!System.IO.File.Exists(ruta))
        {
            return NotFound();
        }
        var tipo = Path.GetExtension(ruta).ToLowerInvariant() switch
        {
            ".pdf" => "application/pdf",
            ".doc" => "application/msword",
            ".docx" => "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            _ => "application/octet-stream"
        };
        return PhysicalFile(ruta, tipo, cv.NombreOriginal ?? "CV" + Path.GetExtension(ruta));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Cerrar(int id)
    {
        TempData["Mensaje"] = BD.CerrarOferta(id, User.IdUsuario())
            ? "Cerramos la búsqueda: ya no aparece en Buscar trabajo ni recibe postulaciones."
            : "No pudimos cerrar esa búsqueda.";
        return RedirectToAction(nameof(Detalle), new { id });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult Eliminar(int id)
    {
        var borrada = BD.EliminarOferta(id, User.IdUsuario());
        TempData["Mensaje"] = borrada ? "Eliminamos la búsqueda y sus postulaciones." : "No encontramos esa búsqueda.";
        TempData["MensajeTipo"] = borrada ? "exito" : "error";
        return RedirectToAction(nameof(Index));
    }

    private void CargarFormulario(PublicarViewModel modelo)
    {
        modelo.EsEmpresa = User.EsEmpresa();
        modelo.Paises = BD.ObtenerPaises();
        modelo.Provincias = BD.ObtenerProvincias();
        if (modelo.EsEmpresa)
        {
            var empresa = BD.ObtenerEmpresaDeUsuario(User.IdUsuario());
            modelo.EmpresaFija = empresa?.Nombre;
            if (Request.Method == "GET")
            {
                modelo.IDProvincia = empresa?.IDProvincia;
                modelo.Ubicacion = empresa?.Ubicacion;
            }
        }
        else if (Request.Method == "GET")
        {
            modelo.IDProvincia = BD.ObtenerPerfil(User.IdUsuario())?.IDProvincia;
        }
        var provincia = modelo.Provincias.FirstOrDefault(p => p.ID == modelo.IDProvincia);
        modelo.IDPais ??= provincia?.IDPais ?? modelo.Paises.FirstOrDefault()?.ID;
    }
}
