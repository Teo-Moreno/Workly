using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class PerfilController : Controller
{
    private readonly IWebHostEnvironment _entorno;

    public PerfilController(IWebHostEnvironment entorno)
    {
        _entorno = entorno;
    }

    // ================================================================ Mi perfil

    public async Task<IActionResult> Index()
    {
        if (User.EsEmpresa())
        {
            var empresa = BD.ObtenerEmpresaDeUsuario(User.IdUsuario());
            return empresa == null ? await SesionInvalida() : RedirectToAction("Detalle", "Empresas", new { id = empresa.ID });
        }
        var modelo = ObtenerMiPerfil();
        if (modelo == null)
        {
            return await SesionInvalida();
        }
        modelo.Instituciones = BD.ObtenerInstituciones();
        return View(modelo);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult GuardarSobreMi(string? descripcion)
    {
        var texto = (descripcion ?? "").Replace("\r\n", "\n").Trim();
        if (texto.Length > 500)
        {
            return Volver("Usá hasta 500 caracteres en \"Sobre mí\".", "error");
        }
        BD.ActualizarDescripcion(User.IdUsuario(), texto.Length == 0 ? null : texto);
        return Volver(texto.Length == 0 ? "Borramos el texto de \"Sobre mí\"." : "Guardamos tu \"Sobre mí\".");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult GuardarEstado(string? estado)
    {
        if (estado != null && !Catalogos.EstadosBusqueda.Contains(estado))
        {
            return Volver("Elegí una opción de la lista.", "error");
        }
        BD.ActualizarEstadoBusqueda(User.IdUsuario(), estado);
        return Volver("Actualizamos tu estado de búsqueda.");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(6 * 1024 * 1024)]
    public async Task<IActionResult> SubirFoto(IFormFile? foto, string? volver)
    {
        if (foto == null || foto.Length == 0)
        {
            return Volver("Elegí una foto para subir.", "error", volver);
        }
        var error = Archivos.Validar(foto, Archivos.ExtensionesFoto);
        if (error != null)
        {
            return Volver(error + ".", "error", volver);
        }

        var ruta = await Archivos.GuardarFoto(foto, _entorno.WebRootPath);
        if (User.EsEmpresa())
        {
            Archivos.Borrar(Archivos.RutaImagen(BD.ActualizarLogo(User.IdUsuario(), ruta), _entorno.WebRootPath));
        }
        else
        {
            Archivos.Borrar(Archivos.RutaImagen(BD.ActualizarFoto(User.IdUsuario(), ruta), _entorno.WebRootPath));
        }
        await Sesion.Iniciar(HttpContext, User.IdUsuario());
        return Volver(User.EsEmpresa() ? "Actualizamos el logo." : "Actualizamos tu foto de perfil.", "exito", volver);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> QuitarFoto(string? volver)
    {
        var anterior = User.EsEmpresa() ? BD.ActualizarLogo(User.IdUsuario(), null) : BD.ActualizarFoto(User.IdUsuario(), null);
        Archivos.Borrar(Archivos.RutaImagen(anterior, _entorno.WebRootPath));
        await Sesion.Iniciar(HttpContext, User.IdUsuario());
        return Volver(User.EsEmpresa() ? "Quitamos el logo." : "Quitamos tu foto de perfil.", "exito", volver);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(6 * 1024 * 1024)]
    public async Task<IActionResult> SubirCV(IFormFile? archivo, string? volver)
    {
        if (archivo == null || archivo.Length == 0)
        {
            return Volver("Elegí tu CV para subirlo.", "error", volver);
        }
        var error = Archivos.Validar(archivo, Archivos.ExtensionesCV);
        if (error != null)
        {
            return Volver(error + ".", "error", volver);
        }
        var nombre = await Archivos.GuardarCV(archivo, _entorno.ContentRootPath);
        BorrarCVViejo(BD.ActualizarArchivoCV(User.IdUsuario(), nombre));
        return Volver("Subimos tu CV.", "exito", volver);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult QuitarCV(string? volver)
    {
        BorrarCVViejo(BD.ActualizarArchivoCV(User.IdUsuario(), null));
        return Volver("Quitamos tu CV.", "exito", volver);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult AgregarExperiencia(ExperienciaFormulario formulario)
    {
        formulario.Descripcion = formulario.Descripcion?.Replace("\r\n", "\n");
        ModelState.Remove(nameof(formulario.Descripcion));
        if (formulario.Descripcion?.Length > 500)
        {
            ModelState.AddModelError(nameof(formulario.Descripcion), "Usá hasta 500 caracteres");
        }
        if (!Validaciones.Periodo(formulario.Inicio, formulario.Actual ? null : formulario.Fin, false, out var inicio, out var fin, out var error))
        {
            ModelState.AddModelError(error!.Contains("de inicio") ? nameof(formulario.Inicio) : nameof(formulario.Fin), error);
        }
        else if (!formulario.Actual && fin == null)
        {
            ModelState.AddModelError(nameof(formulario.Fin), "Elegí el mes y el año de finalización, o marcá que trabajás actualmente acá");
        }

        if (!ModelState.IsValid)
        {
            return MostrarPerfilConModal("modal-experiencia", formulario);
        }

        BD.AgregarExperiencia(User.IdUsuario(), new ExperienciaNueva
        {
            Puesto = formulario.Puesto.Trim(),
            Empresa = formulario.Empresa.Trim(),
            Descripcion = Validaciones.Limpiar(formulario.Descripcion),
            Inicio = inicio,
            Fin = formulario.Actual ? null : fin
        });
        return Volver("Agregamos la experiencia a tu perfil.");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult EliminarExperiencia(int id) =>
        Volver(BD.EliminarExperiencia(User.IdUsuario(), id) ? "Borramos la experiencia." : "No encontramos esa experiencia.");

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult AgregarFormacion(FormacionFormulario formulario)
    {
        if (!Validaciones.Periodo(formulario.Inicio, formulario.EnCurso ? null : formulario.Fin, true, out var inicio, out var fin, out var error))
        {
            ModelState.AddModelError(error!.Contains("de inicio") ? nameof(formulario.Inicio) : nameof(formulario.Fin), error);
        }
        else if (!formulario.EnCurso && fin == null)
        {
            ModelState.AddModelError(nameof(formulario.Fin), "Elegí el mes y el año de finalización, o marcá que la estás cursando");
        }

        if (!ModelState.IsValid)
        {
            return MostrarPerfilConModal("modal-formacion", formulario);
        }

        BD.AgregarFormacion(User.IdUsuario(), new FormacionNueva
        {
            Titulo = formulario.Titulo.Trim(),
            Institucion = formulario.Institucion.Trim(),
            Inicio = inicio,
            Fin = formulario.EnCurso ? null : fin
        });
        return Volver("Agregamos la formación a tu perfil.");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult EliminarFormacion(int id) =>
        Volver(BD.EliminarFormacion(User.IdUsuario(), id) ? "Borramos la formación." : "No encontramos esa formación.");

    // Descarga el CV de la persona logueada (los CV no son públicos)
    public async Task<IActionResult> DescargarCV()
    {
        if (!EsUsuarioDeLaSesion(BD.ObtenerUsuarioPorId(User.IdUsuario())))
        {
            return await SesionInvalida();
        }
        return ArchivoCV(BD.ObtenerCV(User.IdUsuario()));
    }

    // ================================================================ Configuración

    public async Task<IActionResult> Configuracion()
    {
        var modelo = ObtenerMiPerfil();
        if (modelo == null)
        {
            return await SesionInvalida();
        }
        CargarConfiguracion(modelo);
        return View(modelo);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(12 * 1024 * 1024)]
    public async Task<IActionResult> GuardarCuenta(CuentaFormulario formulario)
    {
        var id = User.IdUsuario();
        var paises = BD.ObtenerPaises();
        var provincias = BD.ObtenerProvincias();
        formulario.Email = (formulario.Email ?? "").Trim().ToLowerInvariant();

        var provincia = provincias.FirstOrDefault(p => p.ID == formulario.IDProvincia);
        if (formulario.IDProvincia != null && (provincia == null || provincia.IDPais != formulario.IDPais))
        {
            ModelState.AddModelError(nameof(formulario.IDProvincia), "Elegí una provincia de la lista");
        }
        var telefono = Validaciones.Telefono(formulario.Telefono, paises.FirstOrDefault(p => p.ID == formulario.IDPais), nameof(formulario.Telefono), ModelState);
        if (ModelState[nameof(formulario.Email)]?.Errors.Count is null or 0 && BD.ExisteEmail(formulario.Email, id))
        {
            ModelState.AddModelError(nameof(formulario.Email), "Ya hay otra cuenta con ese email");
        }
        if (Archivos.Validar(formulario.Foto, Archivos.ExtensionesFoto) is { } errorFoto)
        {
            ModelState.AddModelError(nameof(formulario.Foto), errorFoto);
        }
        if (Archivos.Validar(formulario.ArchivoCV, Archivos.ExtensionesCV) is { } errorCV)
        {
            ModelState.AddModelError(nameof(formulario.ArchivoCV), errorCV);
        }

        if (!ModelState.IsValid)
        {
            return MostrarConfiguracionConErrores("cuenta", formulario);
        }

        BD.ActualizarDatosPersonales(id, formulario.Nombre.Trim(), formulario.Apellido.Trim(), formulario.Email, provincia?.ID, telefono,
                                     Validaciones.Limpiar(formulario.SitioWeb));
        if (formulario.Foto is { Length: > 0 })
        {
            var ruta = await Archivos.GuardarFoto(formulario.Foto, _entorno.WebRootPath);
            Archivos.Borrar(Archivos.RutaImagen(BD.ActualizarFoto(id, ruta), _entorno.WebRootPath));
        }
        if (formulario.ArchivoCV is { Length: > 0 })
        {
            var nombre = await Archivos.GuardarCV(formulario.ArchivoCV, _entorno.ContentRootPath);
            BorrarCVViejo(BD.ActualizarArchivoCV(id, nombre));
        }

        await Sesion.Iniciar(HttpContext, id);
        TempData["Mensaje"] = "Guardamos los datos de tu cuenta.";
        return RedirectToAction(nameof(Configuracion));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(8 * 1024 * 1024)]
    public async Task<IActionResult> GuardarEmpresa(EmpresaFormulario formulario)
    {
        var id = User.IdUsuario();
        var empresa = BD.ObtenerEmpresaDeUsuario(id);
        if (empresa == null)
        {
            return await SesionInvalida();
        }

        var paises = BD.ObtenerPaises();
        var provincias = BD.ObtenerProvincias();
        formulario.NombreEmpresa = (formulario.NombreEmpresa ?? "").Trim();
        formulario.Descripcion = formulario.Descripcion?.Replace("\r\n", "\n");
        ModelState.Remove(nameof(formulario.Descripcion));
        if (string.IsNullOrWhiteSpace(formulario.Descripcion))
        {
            ModelState.AddModelError(nameof(formulario.Descripcion), "Contá en pocas líneas qué hace la empresa");
        }
        else if (formulario.Descripcion.Length > 500)
        {
            ModelState.AddModelError(nameof(formulario.Descripcion), "Usá hasta 500 caracteres");
        }

        var provincia = provincias.FirstOrDefault(p => p.ID == formulario.IDProvincia);
        if (formulario.IDProvincia != null && (provincia == null || provincia.IDPais != formulario.IDPais))
        {
            ModelState.AddModelError(nameof(formulario.IDProvincia), "Elegí una provincia de la lista");
        }
        var telefono = Validaciones.Telefono(formulario.Telefono, paises.FirstOrDefault(p => p.ID == formulario.IDPais), nameof(formulario.Telefono), ModelState);
        if (formulario.Rubro != null && !Catalogos.Rubros.Contains(formulario.Rubro))
        {
            ModelState.AddModelError(nameof(formulario.Rubro), "Elegí un rubro de la lista");
        }
        // El dominio del sitio tiene que seguir siendo el del email con el que se verificó la cuenta
        if (!string.IsNullOrEmpty(formulario.SitioWeb) && !VerificacionEmpresa.EmailCoincideConSitio(User.Email(), formulario.SitioWeb))
        {
            ModelState.AddModelError(nameof(formulario.SitioWeb), $"El sitio tiene que ser del mismo dominio que tu email ({VerificacionEmpresa.DominioDelEmail(User.Email())})");
        }
        if (formulario.NombreEmpresa.Length > 0 && BD.ExisteNombreEmpresa(formulario.NombreEmpresa, empresa.ID))
        {
            ModelState.AddModelError(nameof(formulario.NombreEmpresa), "Ya hay otra empresa con ese nombre");
        }
        if (Archivos.Validar(formulario.Logo, Archivos.ExtensionesFoto) is { } errorLogo)
        {
            ModelState.AddModelError(nameof(formulario.Logo), errorLogo);
        }

        if (!ModelState.IsValid)
        {
            return MostrarConfiguracionConErrores("cuenta", formulario);
        }

        BD.ActualizarResponsable(id, formulario.Nombre.Trim(), formulario.Apellido.Trim());
        BD.ActualizarEmpresa(new Empresa
        {
            ID = empresa.ID,
            IDUsuario = id,
            Nombre = formulario.NombreEmpresa,
            Descripcion = formulario.Descripcion!.Trim(),
            Ubicacion = Validaciones.Limpiar(formulario.Ubicacion),
            Sitio_Web = formulario.SitioWeb.Trim(),
            Rubro = formulario.Rubro,
            IDProvincia = provincia?.ID,
            Telefono = telefono
        });
        if (formulario.Logo is { Length: > 0 })
        {
            var ruta = await Archivos.GuardarLogo(formulario.Logo, _entorno.WebRootPath);
            Archivos.Borrar(Archivos.RutaImagen(BD.ActualizarLogo(id, ruta), _entorno.WebRootPath));
        }

        await Sesion.Iniciar(HttpContext, id);
        TempData["Mensaje"] = "Guardamos los datos de la empresa.";
        return RedirectToAction(nameof(Configuracion));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult GuardarBusqueda(BusquedaFormulario formulario)
    {
        if (User.EsEmpresa())
        {
            return Forbid();
        }
        if (formulario.EstadoBusqueda != null && !Catalogos.EstadosBusqueda.Contains(formulario.EstadoBusqueda))
        {
            ModelState.AddModelError(nameof(formulario.EstadoBusqueda), "Elegí una opción de la lista");
        }
        var preferencia = Validaciones.Preferencia(formulario.PuestoBuscado, formulario.Niveles, formulario.Modalidades, formulario.Jornada,
                                                   formulario.Contratacion, formulario.IDProvinciaPreferida, formulario.SalarioMinimo,
                                                   formulario.SalarioMaximo, formulario.Disponibilidad, BD.ObtenerProvincias(),
                                                   nameof(formulario.SalarioMaximo), ModelState);
        var habilidades = Validaciones.Habilidades(formulario.Habilidades, nameof(formulario.Habilidades), ModelState);
        var idiomas = Validaciones.Idiomas(formulario.IdiomaIds, formulario.IdiomaNiveles, BD.ObtenerCatalogoIdiomas(), "Idiomas", ModelState);

        if (!ModelState.IsValid)
        {
            return MostrarConfiguracionConErrores("busqueda", formulario);
        }

        BD.GuardarBusqueda(User.IdUsuario(), preferencia, formulario.EstadoBusqueda, habilidades, idiomas);
        TempData["Mensaje"] = "Guardamos lo que estás buscando.";
        return Redirect(Url.Action(nameof(Configuracion)) + "#busqueda");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CambiarClave(ClaveFormulario formulario)
    {
        var usuario = BD.ObtenerUsuarioPorId(User.IdUsuario());
        if (usuario == null)
        {
            return await SesionInvalida();
        }
        if (usuario.TieneContrasena && !Contrasenas.Verificar(formulario.Actual ?? "", usuario.Contraseña))
        {
            ModelState.AddModelError(nameof(formulario.Actual), "La contraseña actual no es correcta");
        }
        if (!ModelState.IsValid)
        {
            return MostrarConfiguracionConErrores("seguridad", formulario);
        }

        BD.CambiarContrasena(usuario.ID, Contrasenas.Hashear(formulario.Nueva));
        TempData["Mensaje"] = usuario.TieneContrasena ? "Cambiamos tu contraseña." : "Creamos tu contraseña: ya podés entrar también con tu email.";
        return Redirect(Url.Action(nameof(Configuracion)) + "#seguridad");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> EliminarCuenta(string? confirmacion)
    {
        if (!string.Equals(confirmacion?.Trim(), "ELIMINAR", StringComparison.Ordinal))
        {
            TempData["Mensaje"] = "Para eliminar la cuenta escribí ELIMINAR en mayúsculas.";
            TempData["MensajeTipo"] = "error";
            return Redirect(Url.Action(nameof(Configuracion)) + "#seguridad");
        }

        var (foto, cv, logo) = BD.EliminarCuenta(User.IdUsuario());
        Archivos.Borrar(Archivos.RutaImagen(foto, _entorno.WebRootPath));
        Archivos.Borrar(Archivos.RutaImagen(logo, _entorno.WebRootPath));
        BorrarCVViejo(cv);
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        TempData["Mensaje"] = "Eliminamos tu cuenta y todos sus datos.";
        return RedirectToAction("Index", "Home");
    }

    // Ayuda y soporte: se puede ver sin iniciar sesión
    [AllowAnonymous]
    public IActionResult Ayuda()
    {
        return View();
    }

    // ================================================================ Auxiliares

    // Datos de "Mi perfil" de quien inició sesión, o null si la cookie no corresponde a ese usuario.
    private MiPerfilViewModel? ObtenerMiPerfil()
    {
        var modelo = BD.ObtenerMiPerfil(User.IdUsuario());
        return EsUsuarioDeLaSesion(modelo?.Usuario) ? modelo : null;
    }

    private void CargarConfiguracion(MiPerfilViewModel modelo)
    {
        modelo.Paises = BD.ObtenerPaises();
        modelo.Provincias = BD.ObtenerProvincias();
        modelo.CatalogoHabilidades = BD.ObtenerCatalogoHabilidades();
        modelo.CatalogoIdiomas = BD.ObtenerCatalogoIdiomas();
        modelo.ProveedoresVinculados = BD.ObtenerProveedoresVinculados(modelo.Usuario.ID);
        if (modelo.Usuario.EsEmpresa)
        {
            modelo.Empresa = BD.ObtenerEmpresaDeUsuario(modelo.Usuario.ID);
        }
    }

    // Vuelve a mostrar Configuración con los errores del formulario (los valores escritos
    // vuelven desde ModelState) en la pestaña que corresponde.
    private IActionResult MostrarConfiguracionConErrores(string pestana, object formulario)
    {
        var modelo = ObtenerMiPerfil();
        if (modelo == null)
        {
            return RedirectToAction("IniciarSesion", "Cuenta");
        }
        CargarConfiguracion(modelo);
        ViewBag.Pestana = pestana;
        ViewBag.Formulario = formulario;
        return View(nameof(Configuracion), modelo);
    }

    // Vuelve a mostrar el perfil con un pop up abierto y sus errores
    private IActionResult MostrarPerfilConModal(string modal, object formulario)
    {
        var modelo = ObtenerMiPerfil();
        if (modelo == null)
        {
            return RedirectToAction("IniciarSesion", "Cuenta");
        }
        modelo.Instituciones = BD.ObtenerInstituciones();
        ViewBag.ModalAbierto = modal;
        ViewBag.Formulario = formulario;
        return View(nameof(Index), modelo);
    }

    private IActionResult Volver(string mensaje, string tipo = "exito", string? volver = null)
    {
        TempData["Mensaje"] = mensaje;
        TempData["MensajeTipo"] = tipo;
        return !string.IsNullOrEmpty(volver) && Url.IsLocalUrl(volver) ? LocalRedirect(volver) : RedirectToAction(nameof(Index));
    }

    private IActionResult ArchivoCV(CV? cv)
    {
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

    private void BorrarCVViejo(string? nombre)
    {
        if (!string.IsNullOrEmpty(nombre) && nombre == Path.GetFileName(nombre))
        {
            Archivos.Borrar(Path.Combine(Archivos.CarpetaCV(_entorno.ContentRootPath), nombre));
        }
    }

    // La cookie guarda el ID y el email: si la base se volvió a crear, el ID puede no existir
    // o ser de otra persona. En ese caso no se muestra nada.
    private bool EsUsuarioDeLaSesion(Usuario? usuario) =>
        usuario != null && string.Equals(usuario.Email, User.Email(), StringComparison.OrdinalIgnoreCase);

    // Se cierra la sesión para que el login muestre el formulario (si no, devolvería al panel).
    private async Task<IActionResult> SesionInvalida()
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        return RedirectToAction("IniciarSesion", "Cuenta");
    }
}
