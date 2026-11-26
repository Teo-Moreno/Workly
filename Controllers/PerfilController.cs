using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class PerfilController : Controlador
{
    private readonly Carpetas _carpetas;
    private readonly LectorCV _lector;

    public PerfilController(IWebHostEnvironment entorno, LectorCV lector) : base("_LayoutApp")
    {
        _carpetas = Carpetas.Desde(entorno);
        _lector = lector;
    }

    public async Task<IActionResult> Index()
    {
        if (User.EsEmpresa())
        {
            var empresa = BD.ObtenerEmpresaDeUsuario(User.IdUsuario());
            return empresa == null ? await SesionInvalida() : RedirectToAction("Detalle", "Empresas", new { id = empresa.ID });
        }
        var modelo = Perfiles.PerfilParaMostrar(User.IdUsuario(), User.Email());
        if (modelo == null)
        {
            return await SesionInvalida();
        }
        ViewBag.Perfil = modelo;
        Modales(true, null, null, modelo.Instituciones);
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult GuardarSobreMi(string? descripcion) =>
        Volver(Perfiles.GuardarSobreMi(User.IdUsuario(), descripcion));

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult GuardarEstado(string? estado) =>
        Volver(Perfiles.GuardarEstado(User.IdUsuario(), estado));

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(6 * 1024 * 1024)]
    public async Task<IActionResult> SubirFoto(IFormFile? foto, string? volver)
    {
        var resultado = await Perfiles.CambiarImagen(User.IdUsuario(), User.EsEmpresa(), foto, _carpetas);
        if (resultado.Exito)
        {
            await Sesion.Iniciar(HttpContext, User.IdUsuario());
        }
        return Volver(resultado, volver);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> QuitarFoto(string? volver)
    {
        var resultado = Perfiles.QuitarImagen(User.IdUsuario(), User.EsEmpresa(), _carpetas);
        await Sesion.Iniciar(HttpContext, User.IdUsuario());
        return Volver(resultado, volver);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(6 * 1024 * 1024)]
    public async Task<IActionResult> SubirCV(IFormFile? archivo, string? volver) =>
        Volver(await Perfiles.CambiarCV(User.IdUsuario(), archivo, _carpetas, _lector), volver);

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult QuitarCV(string? volver) =>
        Volver(Perfiles.QuitarCV(User.IdUsuario(), _carpetas), volver);

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult AgregarExperiencia(ExperienciaFormulario formulario)
    {
        if (!Perfiles.AgregarExperiencia(User.IdUsuario(), formulario, ModelState))
        {
            return MostrarPerfilConModal("modal-experiencia", formulario);
        }
        return Volver(Resultado.Bien("Agregamos la experiencia a tu perfil."));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult EliminarExperiencia(int id) =>
        Volver(Perfiles.EliminarExperiencia(User.IdUsuario(), id));

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult AgregarFormacion(FormacionFormulario formulario)
    {
        if (!Perfiles.AgregarFormacion(User.IdUsuario(), formulario, ModelState))
        {
            return MostrarPerfilConModal("modal-formacion", formulario);
        }
        return Volver(Resultado.Bien("Agregamos la formación a tu perfil."));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult EliminarFormacion(int id) =>
        Volver(Perfiles.EliminarFormacion(User.IdUsuario(), id));

    public async Task<IActionResult> DescargarCV()
    {
        if (!Perfiles.EsUsuarioDeLaSesion(BD.ObtenerUsuarioPorId(User.IdUsuario()), User.Email()))
        {
            return await SesionInvalida();
        }
        var descarga = Archivos.DescargaCV(BD.ObtenerCV(User.IdUsuario()), _carpetas.Raiz);
        return descarga == null ? NotFound() : PhysicalFile(descarga.Ruta, descarga.Tipo, descarga.Nombre);
    }

    public async Task<IActionResult> Completar()
    {
        if (User.EsEmpresa())
        {
            return RedirectToAction(nameof(Index));
        }
        var perfil = Perfiles.MiPerfil(User.IdUsuario(), User.Email());
        if (perfil == null)
        {
            return await SesionInvalida();
        }
        var completar = Perfiles.FormularioCompletar(perfil);
        ViewBag.Completar = completar;
        Modales(false, null, null, completar.Instituciones);
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(12 * 1024 * 1024)]
    public async Task<IActionResult> Completar(CompletarPerfilViewModel modelo)
    {
        if (User.EsEmpresa())
        {
            return RedirectToAction(nameof(Index));
        }
        var perfil = Perfiles.MiPerfil(User.IdUsuario(), User.Email());
        if (perfil == null)
        {
            return await SesionInvalida();
        }
        if (!await Perfiles.Completar(User.IdUsuario(), modelo, perfil, ModelState, _carpetas))
        {
            ViewBag.Completar = modelo;
            Modales(false, null, null, modelo.Instituciones);
            return View();
        }
        var completado = modelo.ArchivoCV is { Length: > 0 } ? await Perfiles.CompletarDesdeCV(User.IdUsuario(), _lector, _carpetas) : null;
        return Volver(Resultado.Bien(completado == null ? "Guardamos tu perfil." : $"Guardamos tu perfil. {completado}"));
    }

    public async Task<IActionResult> Configuracion()
    {
        var modelo = Perfiles.MiPerfil(User.IdUsuario(), User.Email());
        if (modelo == null)
        {
            return await SesionInvalida();
        }
        MostrarConfiguracion(Perfiles.Configuracion(modelo, Request.Query["pestana"].ToString(), null));
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(12 * 1024 * 1024)]
    public async Task<IActionResult> GuardarCuenta(CuentaFormulario formulario)
    {
        if (!await Perfiles.GuardarCuenta(User.IdUsuario(), formulario, ModelState, _carpetas))
        {
            return MostrarConfiguracionConErrores("cuenta", formulario);
        }
        await Sesion.Iniciar(HttpContext, User.IdUsuario());
        TempData["Mensaje"] = "Guardamos los datos de tu cuenta.";
        return RedirectToAction(nameof(Configuracion));
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(8 * 1024 * 1024)]
    public async Task<IActionResult> GuardarEmpresa(EmpresaFormulario formulario)
    {
        var empresa = BD.ObtenerEmpresaDeUsuario(User.IdUsuario());
        if (empresa == null)
        {
            return await SesionInvalida();
        }
        if (!await Perfiles.GuardarEmpresa(User.IdUsuario(), empresa, User.Email(), formulario, ModelState, _carpetas))
        {
            return MostrarConfiguracionConErrores("cuenta", formulario);
        }
        await Sesion.Iniciar(HttpContext, User.IdUsuario());
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
        if (!Perfiles.GuardarBusqueda(User.IdUsuario(), formulario, ModelState))
        {
            return MostrarConfiguracionConErrores("busqueda", formulario);
        }
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
        var resultado = Perfiles.CambiarClave(usuario, formulario, ModelState);
        if (resultado == null)
        {
            return MostrarConfiguracionConErrores("seguridad", formulario);
        }
        TempData["Mensaje"] = resultado.Mensaje;
        return Redirect(Url.Action(nameof(Configuracion)) + "#seguridad");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> EliminarCuenta(string? confirmacion)
    {
        var resultado = Perfiles.EliminarCuenta(User.IdUsuario(), confirmacion, _carpetas);
        if (!resultado.Exito)
        {
            TempData["Mensaje"] = resultado.Mensaje;
            TempData["MensajeTipo"] = resultado.Tipo;
            return Redirect(Url.Action(nameof(Configuracion)) + "#seguridad");
        }
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        TempData["Mensaje"] = resultado.Mensaje;
        return RedirectToAction("Index", "Home");
    }

    [AllowAnonymous]
    public IActionResult Ayuda()
    {
        return View();
    }

    private IActionResult MostrarConfiguracionConErrores(string pestana, object formulario)
    {
        var modelo = Perfiles.MiPerfil(User.IdUsuario(), User.Email());
        if (modelo == null)
        {
            return RedirectToAction("IniciarSesion", "Cuenta");
        }
        MostrarConfiguracion(Perfiles.Configuracion(modelo, pestana, formulario));
        return View(nameof(Configuracion));
    }

    private void MostrarConfiguracion(PantallaConfiguracion pantalla)
    {
        ViewBag.Perfil = pantalla.Perfil;
        ViewBag.EsEmpresa = pantalla.EsEmpresa;
        ViewBag.Activa = pantalla.Activa;
        ViewBag.FormularioCuenta = pantalla.FormularioCuenta;
        ViewBag.FormularioEmpresa = pantalla.FormularioEmpresa;
        ViewBag.CamposBusqueda = pantalla.CamposBusqueda;
        ViewBag.CampoTelefono = pantalla.Telefono;
        ViewBag.CampoUbicacion = pantalla.Ubicacion;
    }

    private IActionResult MostrarPerfilConModal(string modal, object formulario)
    {
        var modelo = Perfiles.PerfilParaMostrar(User.IdUsuario(), User.Email());
        if (modelo == null)
        {
            return RedirectToAction("IniciarSesion", "Cuenta");
        }
        ViewBag.Perfil = modelo;
        Modales(true, formulario, modal, modelo.Instituciones);
        return View(nameof(Index));
    }

    private void Modales(bool enServidor, object? formulario, string? modal, List<string> instituciones)
    {
        ViewBag.ModalExperiencia = new ModalExperiencia(enServidor, formulario as ExperienciaFormulario, modal, ModelState);
        ViewBag.ModalFormacion = new ModalFormacion(enServidor, formulario as FormacionFormulario, instituciones, modal, ModelState);
    }

    private IActionResult Volver(Resultado resultado, string? volver = null)
    {
        TempData["Mensaje"] = resultado.Mensaje;
        TempData["MensajeTipo"] = resultado.Tipo;
        return !string.IsNullOrEmpty(volver) && Url.IsLocalUrl(volver) ? LocalRedirect(volver) : RedirectToAction(nameof(Index));
    }

    private async Task<IActionResult> SesionInvalida()
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        return RedirectToAction("IniciarSesion", "Cuenta");
    }
}
