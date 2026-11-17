using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Workly.Models;

namespace Workly.Controllers;

public class CuentaController : Controller
{
    private readonly IWebHostEnvironment _entorno;
    private readonly ILogger<CuentaController> _logger;
    private readonly IAuthenticationSchemeProvider _esquemas;
    private readonly Captcha _captcha;
    private readonly IntentosLogin _intentos;
    private readonly Correo _correo;
    private readonly VerificacionEmail _verificacion;

    public CuentaController(IWebHostEnvironment entorno, ILogger<CuentaController> logger, IAuthenticationSchemeProvider esquemas,
                            Captcha captcha, IntentosLogin intentos, Correo correo, VerificacionEmail verificacion)
    {
        _correo = correo;
        _verificacion = verificacion;
        _entorno = entorno;
        _logger = logger;
        _esquemas = esquemas;
        _captcha = captcha;
        _intentos = intentos;
    }

    [HttpGet]
    public Captcha.Desafio NuevoCaptcha()
    {
        return _captcha.Nuevo();
    }

    [HttpGet]
    public async Task<IActionResult> IniciarSesion(string? returnUrl = null)
    {
        if (User.EstaLogueado())
        {
            return RedirigirDespuesDeIngresar(returnUrl);
        }
        ViewBag.Proveedores = await Cuentas.ProveedoresDisponibles(_esquemas);
        return Formulario(new LoginViewModel { ReturnUrl = returnUrl });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> IniciarSesion(LoginViewModel modelo)
    {
        ViewBag.Proveedores = await Cuentas.ProveedoresDisponibles(_esquemas);
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        var usuario = Cuentas.IniciarSesion(modelo, ip, _intentos, _captcha, Request.Form[Captcha.CampoToken], Request.Form[Captcha.CampoRespuesta],
                                            ModelState, _logger);
        ViewBag.PideCaptcha = _intentos.PideCaptcha(Cuentas.NormalizarEmail(modelo.Email), ip);
        if (usuario == null)
        {
            modelo.Contrasena = "";
            return Formulario(modelo);
        }

        await Sesion.Iniciar(HttpContext, usuario.ID, modelo.Recordarme);
        TempData["Mensaje"] = $"¡Hola de nuevo, {usuario.Nombre}!";
        return RedirigirDespuesDeIngresar(modelo.ReturnUrl);
    }

    [HttpGet]
    public IActionResult RecuperarClave()
    {
        if (!_correo.Configurado)
        {
            return NotFound();
        }
        return Formulario(new RecuperarClaveViewModel());
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> RecuperarClave(RecuperarClaveViewModel modelo)
    {
        if (!_correo.Configurado)
        {
            return NotFound();
        }
        if (!_captcha.Verificar(Request.Form[Captcha.CampoToken], Request.Form[Captcha.CampoRespuesta]))
        {
            ModelState.AddModelError(Captcha.CampoRespuesta, "Escribí las letras de la imagen");
        }
        if (!ModelState.IsValid)
        {
            return Formulario(modelo);
        }

        try
        {
            await Cuentas.PedirRecuperacion(modelo.Email, token => Url.Action(nameof(NuevaClave), "Cuenta", new { token }, Request.Scheme)!, _correo);
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos al recuperar la contraseña");
            ModelState.AddModelError(string.Empty, Cuentas.ErrorConexion);
            return Formulario(modelo);
        }

        TempData["Mensaje"] = "Si hay una cuenta con ese email, te mandamos un link para crear una contraseña nueva. Revisá tu correo (y la carpeta de spam).";
        return RedirectToAction(nameof(IniciarSesion));
    }

    [HttpGet]
    public IActionResult NuevaClave(string? token)
    {
        if (!Cuentas.RecuperacionVigente(token))
        {
            return View("LinkVencido");
        }
        return Formulario(new NuevaClaveViewModel { Token = token! });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult NuevaClave(NuevaClaveViewModel modelo)
    {
        if (!ModelState.IsValid)
        {
            return Formulario(modelo);
        }
        if (!Cuentas.UsarRecuperacion(modelo.Token, modelo.Nueva))
        {
            return View("LinkVencido");
        }
        TempData["Mensaje"] = "Listo, ya tenés tu contraseña nueva. Iniciá sesión con ella.";
        return RedirectToAction(nameof(IniciarSesion));
    }

    [HttpGet]
    public async Task<IActionResult> CrearCuenta(string? tipo = null)
    {
        if (User.EstaLogueado())
        {
            return RedirectToAction("Index", "Panel");
        }

        ViewBag.Proveedores = await Cuentas.ProveedoresDisponibles(_esquemas);
        var externa = await LeerCuentaExterna();
        if (tipo == "empresa")
        {
            var empresa = new RegistroEmpresaViewModel();
            externa?.CompletarRegistro(empresa);
            CargarListas(empresa);
            return Formulario(empresa, "CrearCuentaEmpresa");
        }

        var persona = new RegistroPersonaViewModel();
        externa?.CompletarRegistro(persona);
        return Formulario(persona, "CrearCuentaPersona");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CrearCuentaPersona(RegistroPersonaViewModel modelo)
    {
        if (User.EstaLogueado())
        {
            return RedirectToAction("Index", "Panel");
        }

        ViewBag.Proveedores = await Cuentas.ProveedoresDisponibles(_esquemas);
        var externa = await LeerCuentaExterna();
        Cuentas.PrepararRegistro(modelo, externa, ModelState);
        if (!Cuentas.EmailLibre(modelo.Email, nameof(modelo.Email), ModelState, _logger) || !ModelState.IsValid)
        {
            return VolverAlRegistro("CrearCuentaPersona", modelo);
        }

        var datos = Cuentas.ArmarPersona(modelo, externa);
        if (externa == null)
        {
            return await PedirCodigo(datos.Usuario, datos, null) ?? VolverAlRegistro("CrearCuentaPersona", modelo);
        }

        var id = Cuentas.Registrar(datos, nameof(modelo.Email), ModelState, _logger);
        if (id == null)
        {
            return VolverAlRegistro("CrearCuentaPersona", modelo);
        }
        return await TerminarRegistro(id.Value, datos);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(8 * 1024 * 1024)]
    public async Task<IActionResult> CrearCuentaEmpresa(RegistroEmpresaViewModel modelo)
    {
        if (User.EstaLogueado())
        {
            return RedirectToAction("Index", "Panel");
        }

        ViewBag.Proveedores = await Cuentas.ProveedoresDisponibles(_esquemas);
        var externa = await LeerCuentaExterna();
        CargarListas(modelo);
        Cuentas.PrepararRegistro(modelo, externa, ModelState);
        var validada = Cuentas.ValidarEmpresa(modelo, ModelState, _logger);
        if (!Cuentas.EmailLibre(modelo.Email, nameof(modelo.Email), ModelState, _logger) || !ModelState.IsValid)
        {
            return VolverAlRegistro("CrearCuentaEmpresa", modelo);
        }

        var rutaLogo = await Archivos.GuardarLogo(modelo.Logo, _entorno.WebRootPath);
        var datos = Cuentas.ArmarEmpresa(modelo, externa, validada, rutaLogo);
        if (externa == null)
        {
            return await PedirCodigo(datos.Usuario, datos, Archivos.RutaImagen(rutaLogo, _entorno.WebRootPath))
                ?? VolverAlRegistro("CrearCuentaEmpresa", modelo);
        }

        var id = Cuentas.Registrar(datos, nameof(modelo.Email), ModelState, _logger);
        if (id == null)
        {
            Archivos.BorrarImagen(rutaLogo, _entorno.WebRootPath);
            return VolverAlRegistro("CrearCuentaEmpresa", modelo);
        }
        return await TerminarRegistro(id.Value, datos);
    }

    [HttpGet]
    public IActionResult VerificarEmail(string? token)
    {
        var pendiente = _verificacion.Obtener(token);
        if (pendiente == null)
        {
            return CodigoVencido();
        }
        return Formulario(new VerificarEmailViewModel { Token = token!, Email = pendiente.Email });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> VerificarEmail(VerificarEmailViewModel modelo)
    {
        var pendiente = _verificacion.Obtener(modelo.Token);
        if (pendiente == null)
        {
            return CodigoVencido();
        }
        modelo.Email = pendiente.Email;
        if (!ModelState.IsValid)
        {
            return Formulario(modelo);
        }

        switch (_verificacion.Verificar(modelo.Token, modelo.Codigo))
        {
            case VerificacionEmail.Resultado.Vencido:
                return CodigoVencido();
            case VerificacionEmail.Resultado.SinIntentos:
                _verificacion.Descartar(modelo.Token);
                TempData["Mensaje"] = "Escribiste mal el código demasiadas veces. Por seguridad, completá el registro de nuevo.";
                TempData["MensajeTipo"] = "error";
                return RedirectToAction(nameof(CrearCuenta), new { tipo = pendiente.Datos is EmpresaNueva ? "empresa" : null });
            case VerificacionEmail.Resultado.Incorrecto:
                ModelState.AddModelError(nameof(modelo.Codigo), "El código no es correcto. Revisalo y probá de nuevo.");
                modelo.Codigo = "";
                return Formulario(modelo);
        }

        var id = Cuentas.Registrar(pendiente.Datos, string.Empty, ModelState, _logger);
        if (id == null)
        {
            modelo.Codigo = "";
            return Formulario(modelo);
        }

        _verificacion.Terminar(modelo.Token);
        return await TerminarRegistro(id.Value, pendiente.Datos);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> ReenviarCodigo(string? token)
    {
        var pendiente = _verificacion.Obtener(token);
        if (pendiente == null)
        {
            return CodigoVencido();
        }
        var codigo = _verificacion.Reenviar(token);
        if (codigo == null)
        {
            TempData["Mensaje"] = "Esperá un minuto antes de pedir otro código. Si ya pediste varios, revisá la carpeta de spam.";
            TempData["MensajeTipo"] = "error";
        }
        else if (await _correo.EnviarCodigo(pendiente.Email, pendiente.Nombre, codigo, _entorno.IsDevelopment()))
        {
            TempData["Mensaje"] = $"Te mandamos un código nuevo a {pendiente.Email}. El anterior ya no sirve.";
        }
        else
        {
            TempData["Mensaje"] = "No pudimos mandarte el mail. Probá de nuevo en unos minutos.";
            TempData["MensajeTipo"] = "error";
        }
        return RedirectToAction(nameof(VerificarEmail), new { token });
    }

    private async Task<IActionResult?> PedirCodigo(Usuario usuario, object datos, string? archivoTemporal)
    {
        var (token, codigo) = _verificacion.Crear(usuario.Email, usuario.Nombre, datos, archivoTemporal);
        if (!await _correo.EnviarCodigo(usuario.Email, usuario.Nombre, codigo, _entorno.IsDevelopment()))
        {
            _verificacion.Descartar(token);
            ModelState.AddModelError(string.Empty, "No pudimos mandarte el mail con el código. Revisá que el email esté bien escrito o probá de nuevo en unos minutos.");
            return null;
        }
        return RedirectToAction(nameof(VerificarEmail), new { token });
    }

    private IActionResult CodigoVencido()
    {
        TempData["Mensaje"] = "El código venció o ya lo usaste. Completá el registro de nuevo para que te mandemos otro.";
        TempData["MensajeTipo"] = "error";
        return RedirectToAction(nameof(CrearCuenta));
    }

    [HttpGet]
    public async Task<IActionResult> Externo(string proveedor, string? tipo = null, string? returnUrl = null)
    {
        if (await _esquemas.GetSchemeAsync(proveedor) == null || !Cuentas.ProveedoresExternos.Contains(proveedor))
        {
            return NotFound();
        }
        var propiedades = new AuthenticationProperties
        {
            RedirectUri = Url.Action(nameof(ExternoVuelta), new { tipo, returnUrl })
        };
        propiedades.Items["proveedor"] = proveedor;
        return Challenge(propiedades, proveedor);
    }

    [HttpGet]
    public async Task<IActionResult> ExternoVuelta(string? tipo = null, string? returnUrl = null)
    {
        var externa = await LeerCuentaExterna();
        if (externa == null || string.IsNullOrEmpty(externa.Email))
        {
            TempData["Mensaje"] = "No pudimos iniciar sesión con esa cuenta. Probá de nuevo o usá tu email y contraseña.";
            TempData["MensajeTipo"] = "error";
            return RedirectToAction(nameof(IniciarSesion));
        }

        int? id;
        try
        {
            id = externa.BuscarUsuario();
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos con el inicio de sesión externo");
            TempData["Mensaje"] = Cuentas.ErrorConexion;
            TempData["MensajeTipo"] = "error";
            return RedirectToAction(nameof(IniciarSesion));
        }

        if (id == null)
        {
            return RedirectToAction(nameof(CrearCuenta), new { tipo });
        }
        await HttpContext.SignOutAsync(Sesion.EsquemaExterno);
        await Sesion.Iniciar(HttpContext, id.Value, recordarme: true);
        TempData["Mensaje"] = $"¡Hola, {externa.Nombre}!";
        return RedirigirDespuesDeIngresar(returnUrl);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CerrarSesion()
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        TempData["Mensaje"] = "Cerraste sesión. ¡Hasta pronto!";
        return RedirectToAction("Index", "Home");
    }

    private async Task<CuentaExterna?> LeerCuentaExterna() =>
        CuentaExterna.Leer(await HttpContext.AuthenticateAsync(Sesion.EsquemaExterno));

    private async Task<IActionResult> TerminarRegistro(int idUsuario, object datos)
    {
        await HttpContext.SignOutAsync(Sesion.EsquemaExterno);
        await Sesion.Iniciar(HttpContext, idUsuario, recordarme: true);
        TempData["Mensaje"] = Cuentas.Bienvenida(datos);
        return datos is EmpresaNueva ? RedirectToAction("Index", "Publicaciones") : RedirectToAction("Completar", "Perfil");
    }

    private void CargarListas(RegistroEmpresaViewModel modelo)
    {
        try
        {
            modelo.CargarListas();
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos al cargar las listas del registro");
            ModelState.AddModelError(string.Empty, Cuentas.ErrorConexion);
        }
    }

    private IActionResult VolverAlRegistro(string vista, RegistroBase modelo)
    {
        Cuentas.PrepararReintento(modelo, ModelState);
        return Formulario(modelo, vista);
    }

    private IActionResult Formulario(object modelo, string? vista = null)
    {
        ViewBag.Formulario = modelo;
        return vista == null ? View() : View(vista);
    }

    private IActionResult RedirigirDespuesDeIngresar(string? returnUrl) =>
        !string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl)
            ? LocalRedirect(returnUrl)
            : RedirectToAction("Index", "Panel");
}
