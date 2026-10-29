using System.Security.Claims;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;
using Workly.Models;

namespace Workly.Controllers;

public class CuentaController : Controller
{
    private const string ErrorConexion =
        "No pudimos conectarnos con la base de datos. Revisá que SQL Server esté funcionando y la cadena de conexión en appsettings.json.";

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
    public IActionResult NuevoCaptcha()
    {
        var desafio = _captcha.Nuevo();
        return Json(new { token = desafio.Token, imagen = desafio.Imagen });
    }

    [HttpGet]
    public async Task<IActionResult> IniciarSesion(string? returnUrl = null)
    {
        if (User.EstaLogueado())
        {
            return RedirigirDespuesDeIngresar(returnUrl);
        }
        await CargarProveedores();
        return View(new LoginViewModel { ReturnUrl = returnUrl });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> IniciarSesion(LoginViewModel modelo)
    {
        await CargarProveedores();
        var email = NormalizarEmail(modelo.Email ?? "");
        var ip = HttpContext.Connection.RemoteIpAddress?.ToString();
        ViewBag.PideCaptcha = _intentos.PideCaptcha(email, ip);
        if (!ModelState.IsValid)
        {
            return View(modelo);
        }

        if (_intentos.Bloqueado(email) is { } espera)
        {
            var minutos = Math.Max(1, (int)Math.Ceiling(espera.TotalMinutes));
            ModelState.AddModelError(string.Empty,
                $"Por seguridad frenamos el ingreso con este email después de varios intentos fallidos. Probá de nuevo en {minutos} {(minutos == 1 ? "minuto" : "minutos")}.");
            modelo.Contrasena = "";
            return View(modelo);
        }

        if (ViewBag.PideCaptcha == true && !_captcha.Verificar(Request.Form[Captcha.CampoToken], Request.Form[Captcha.CampoRespuesta]))
        {
            ModelState.AddModelError(Captcha.CampoRespuesta, "Escribí las letras de la imagen");
            modelo.Contrasena = "";
            return View(modelo);
        }

        Usuario? usuario;
        try
        {
            usuario = BD.ObtenerUsuarioPorEmail(email);
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos al iniciar sesión");
            ModelState.AddModelError(string.Empty, ErrorConexion);
            return View(modelo);
        }

        if (!Contrasenas.Verificar(modelo.Contrasena, usuario?.Contraseña) || usuario == null)
        {
            _intentos.Fallo(email, ip);
            ViewBag.PideCaptcha = _intentos.PideCaptcha(email, ip);
            var soloExterno = usuario != null && !usuario.TieneContrasena;
            ModelState.AddModelError(string.Empty, soloExterno
                ? "Esta cuenta entra con Google o LinkedIn. Usá el botón de abajo, o creá una contraseña desde Configuración."
                : "El email o la contraseña no son correctos.");
            modelo.Contrasena = "";
            return View(modelo);
        }

        _intentos.Exito(email);
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
        return View(new RecuperarClaveViewModel());
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
            return View(modelo);
        }

        var email = NormalizarEmail(modelo.Email);
        try
        {
            var usuario = BD.ObtenerUsuarioPorEmail(email);
            if (usuario != null && BD.ContarRecuperacionesRecientes(usuario.ID) < 3)
            {
                var token = Convert.ToBase64String(System.Security.Cryptography.RandomNumberGenerator.GetBytes(32))
                    .Replace('+', '-').Replace('/', '_').TrimEnd('=');
                BD.GuardarRecuperacion(usuario.ID, HashDeToken(token), DateTime.UtcNow.AddHours(1));
                var enlace = Url.Action(nameof(NuevaClave), "Cuenta", new { token }, Request.Scheme)!;
                await _correo.Enviar(usuario.Email, "Workly: creá una contraseña nueva",
                    $"Hola, {usuario.Nombre}.\n\n" +
                    "Pediste crear una contraseña nueva para tu cuenta de Workly. Entrá a este link para elegirla:\n\n" +
                    $"{enlace}\n\n" +
                    "El link sirve una sola vez y vence en 1 hora. Si no lo pediste vos, ignorá este mail: tu contraseña no cambia.\n\n" +
                    "Workly");
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos al recuperar la contraseña");
            ModelState.AddModelError(string.Empty, ErrorConexion);
            return View(modelo);
        }

        TempData["Mensaje"] = "Si hay una cuenta con ese email, te mandamos un link para crear una contraseña nueva. Revisá tu correo (y la carpeta de spam).";
        return RedirectToAction(nameof(IniciarSesion));
    }

    [HttpGet]
    public IActionResult NuevaClave(string? token)
    {
        if (string.IsNullOrEmpty(token) || BD.ObtenerUsuarioDeRecuperacion(HashDeToken(token)) == null)
        {
            return View("LinkVencido");
        }
        return View(new NuevaClaveViewModel { Token = token });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult NuevaClave(NuevaClaveViewModel modelo)
    {
        if (!ModelState.IsValid)
        {
            return View(modelo);
        }
        if (!BD.UsarRecuperacion(HashDeToken(modelo.Token), Contrasenas.Hashear(modelo.Nueva)))
        {
            return View("LinkVencido");
        }
        TempData["Mensaje"] = "Listo, ya tenés tu contraseña nueva. Iniciá sesión con ella.";
        return RedirectToAction(nameof(IniciarSesion));
    }

    private static string HashDeToken(string token) =>
        Convert.ToHexString(System.Security.Cryptography.SHA256.HashData(System.Text.Encoding.UTF8.GetBytes(token))).ToLowerInvariant();

    [HttpGet]
    public async Task<IActionResult> CrearCuenta(string? tipo = null)
    {
        if (User.EstaLogueado())
        {
            return RedirectToAction("Index", "Panel");
        }

        await CargarProveedores();
        var externo = await LeerExterno();
        if (tipo == "empresa")
        {
            var empresa = new RegistroEmpresaViewModel();
            CompletarConExterno(empresa, externo);
            CargarListas(empresa);
            return View("CrearCuentaEmpresa", empresa);
        }

        var persona = new RegistroPersonaViewModel();
        CompletarConExterno(persona, externo);
        return View("CrearCuentaPersona", persona);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CrearCuentaPersona(RegistroPersonaViewModel modelo)
    {
        if (User.EstaLogueado())
        {
            return RedirectToAction("Index", "Panel");
        }

        await CargarProveedores();
        var externo = await LeerExterno();
        CompletarConExterno(modelo, externo);
        NormalizarDatosBase(modelo);
        ValidarContrasena(modelo, externo);
        if (!ValidarEmailLibre(modelo.Email, nameof(modelo.Email)) || !ModelState.IsValid)
        {
            return VolverAlRegistro("CrearCuentaPersona", modelo);
        }

        var datos = new PersonaNueva
        {
            Usuario = new Usuario
            {
                Nombre = modelo.Nombre,
                Apellido = modelo.Apellido,
                Email = modelo.Email,
                Contraseña = string.IsNullOrEmpty(modelo.Contrasena) ? null : Contrasenas.Hashear(modelo.Contrasena)
            },
            LoginExterno = externo == null ? null : new LoginExternoNuevo { Proveedor = externo.Proveedor, ID_Externo = externo.ID }
        };

        if (externo == null)
        {
            return await PedirCodigo(datos.Usuario, datos, null) ?? VolverAlRegistro("CrearCuentaPersona", modelo);
        }

        int id;
        try
        {
            id = BD.RegistrarPersona(datos);
        }
        catch (SqlException ex)
        {
            ManejarErrorDeRegistro(ex, nameof(modelo.Email));
            return VolverAlRegistro("CrearCuentaPersona", modelo);
        }

        await TerminarRegistro(id);
        return BienvenidaPersona(datos);
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

        await CargarProveedores();
        var externo = await LeerExterno();
        CompletarConExterno(modelo, externo);
        CargarListas(modelo);
        NormalizarDatosBase(modelo);
        modelo.NombreEmpresa = modelo.NombreEmpresa?.Trim() ?? "";
        modelo.RazonSocial = modelo.RazonSocial?.Trim() ?? "";
        modelo.Descripcion = NormalizarSaltos(modelo.Descripcion, nameof(modelo.Descripcion), 500);
        var cuit = VerificacionEmpresa.SoloNumeros(modelo.CUIT);

        ValidarContrasena(modelo, externo);
        var (provincia, telefono) = ValidarUbicacionYTelefono(modelo.Paises, modelo.Provincias, modelo.IDPais, modelo.IDProvincia, modelo.Telefono,
                                                              nameof(modelo.IDProvincia), nameof(modelo.Telefono));
        if (modelo.Rubro != null && !Catalogos.Rubros.Contains(modelo.Rubro))
        {
            ModelState.AddModelError(nameof(modelo.Rubro), "Elegí un rubro de la lista");
        }
        ValidarArchivo(modelo.Logo, Archivos.ExtensionesFoto, nameof(modelo.Logo));

        if (!string.IsNullOrEmpty(modelo.CUIT) && !VerificacionEmpresa.CuitValido(cuit))
        {
            ModelState.AddModelError(nameof(modelo.CUIT), "El CUIT no es válido. Revisá los 11 números (el último es el verificador).");
        }
        if (!string.IsNullOrEmpty(modelo.SitioWeb) && VerificacionEmpresa.DominioDelSitio(modelo.SitioWeb) == null)
        {
            ModelState.AddModelError(nameof(modelo.SitioWeb), "Ingresá una dirección válida, por ejemplo tuempresa.com.ar");
        }
        else if (ModelState[nameof(modelo.Email)]?.Errors.Count is null or 0 && !string.IsNullOrEmpty(modelo.Email))
        {
            if (VerificacionEmpresa.EsEmailGratuito(modelo.Email))
            {
                ModelState.AddModelError(nameof(modelo.Email), "Usá el email de la empresa (no se aceptan Gmail, Hotmail, Outlook, etc.)");
            }
            else if (!string.IsNullOrEmpty(modelo.SitioWeb) && !VerificacionEmpresa.EmailCoincideConSitio(modelo.Email, modelo.SitioWeb))
            {
                ModelState.AddModelError(nameof(modelo.Email),
                    $"El email tiene que ser del dominio de la empresa (@{VerificacionEmpresa.DominioDelSitio(modelo.SitioWeb)})");
            }
        }

        try
        {
            if (VerificacionEmpresa.CuitValido(cuit) && BD.ExisteCuit(cuit))
            {
                ModelState.AddModelError(nameof(modelo.CUIT), "Ya hay una cuenta de empresa con ese CUIT. Si es tu empresa, pedile acceso a quien la creó.");
            }
            if (modelo.NombreEmpresa.Length > 0 && BD.NombreEmpresaConCuenta(modelo.NombreEmpresa))
            {
                ModelState.AddModelError(nameof(modelo.NombreEmpresa), "Ya hay una cuenta de empresa con ese nombre.");
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos al validar la empresa");
            ModelState.AddModelError(string.Empty, ErrorConexion);
        }

        if (!ValidarEmailLibre(modelo.Email, nameof(modelo.Email)) || !ModelState.IsValid)
        {
            return VolverAlRegistro("CrearCuentaEmpresa", modelo);
        }

        var rutaLogo = await Archivos.GuardarLogo(modelo.Logo, _entorno.WebRootPath);
        var datos = new EmpresaNueva
        {
            Usuario = new Usuario
            {
                Nombre = modelo.Nombre,
                Apellido = modelo.Apellido,
                Email = modelo.Email,
                Contraseña = string.IsNullOrEmpty(modelo.Contrasena) ? null : Contrasenas.Hashear(modelo.Contrasena)
            },
            Empresa = new Empresa
            {
                Nombre = modelo.NombreEmpresa,
                Razon_Social = modelo.RazonSocial,
                CUIT = cuit,
                Rubro = modelo.Rubro,
                Sitio_Web = modelo.SitioWeb.Trim(),
                IDProvincia = provincia?.ID,
                Ubicacion = Limpiar(modelo.Ubicacion),
                Telefono = telefono,
                Descripcion = Limpiar(modelo.Descripcion),
                Logo = rutaLogo
            },
            LoginExterno = externo == null ? null : new LoginExternoNuevo { Proveedor = externo.Proveedor, ID_Externo = externo.ID }
        };

        if (externo == null)
        {
            return await PedirCodigo(datos.Usuario, datos, Archivos.RutaImagen(rutaLogo, _entorno.WebRootPath))
                ?? VolverAlRegistro("CrearCuentaEmpresa", modelo);
        }

        int id;
        try
        {
            id = BD.RegistrarEmpresa(datos);
        }
        catch (SqlException ex)
        {
            Archivos.Borrar(Archivos.RutaImagen(rutaLogo, _entorno.WebRootPath));
            ManejarErrorDeRegistro(ex, nameof(modelo.Email));
            return VolverAlRegistro("CrearCuentaEmpresa", modelo);
        }

        await TerminarRegistro(id);
        return BienvenidaEmpresa(datos);
    }

    [HttpGet]
    public IActionResult VerificarEmail(string? token)
    {
        var pendiente = _verificacion.Obtener(token);
        if (pendiente == null)
        {
            return CodigoVencido();
        }
        return View(new VerificarEmailViewModel { Token = token!, Email = pendiente.Email });
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
            return View(modelo);
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
                return View(modelo);
        }

        int id;
        try
        {
            id = pendiente.Datos is EmpresaNueva empresa ? BD.RegistrarEmpresa(empresa) : BD.RegistrarPersona((PersonaNueva)pendiente.Datos);
        }
        catch (SqlException ex)
        {
            ManejarErrorDeRegistro(ex, string.Empty);
            modelo.Codigo = "";
            return View(modelo);
        }

        _verificacion.Terminar(modelo.Token);
        await TerminarRegistro(id);
        return pendiente.Datos is EmpresaNueva datosEmpresa ? BienvenidaEmpresa(datosEmpresa) : BienvenidaPersona((PersonaNueva)pendiente.Datos);
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
        else if (await EnviarCodigo(pendiente.Email, pendiente.Nombre, codigo))
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
        if (!await EnviarCodigo(usuario.Email, usuario.Nombre, codigo))
        {
            _verificacion.Descartar(token);
            ModelState.AddModelError(string.Empty, "No pudimos mandarte el mail con el código. Revisá que el email esté bien escrito o probá de nuevo en unos minutos.");
            return null;
        }
        return RedirectToAction(nameof(VerificarEmail), new { token });
    }

    private async Task<bool> EnviarCodigo(string email, string nombre, string codigo)
    {
        if (!_correo.Configurado && _entorno.IsDevelopment())
        {
            _logger.LogWarning("El mail no está configurado. Código de verificación para {Email}: {Codigo}", email, codigo);
            return true;
        }
        return await _correo.Enviar(email, $"{codigo} es tu código de Workly",
            $"Hola, {nombre}.\n\n" +
            $"Tu código para terminar de crear tu cuenta en Workly es:\n\n{codigo}\n\n" +
            $"Vence en {VerificacionEmail.Vigencia.TotalMinutes:0} minutos. Si no estás creando una cuenta en Workly, ignorá este mail.\n\n" +
            "Workly");
    }

    private IActionResult CodigoVencido()
    {
        TempData["Mensaje"] = "El código venció o ya lo usaste. Completá el registro de nuevo para que te mandemos otro.";
        TempData["MensajeTipo"] = "error";
        return RedirectToAction(nameof(CrearCuenta));
    }

    private IActionResult BienvenidaPersona(PersonaNueva datos)
    {
        TempData["Mensaje"] = $"¡Te damos la bienvenida a Workly, {datos.Usuario.Nombre}! Tu cuenta está lista. Completá tu perfil cuando quieras.";
        return RedirectToAction("Completar", "Perfil");
    }

    private IActionResult BienvenidaEmpresa(EmpresaNueva datos)
    {
        TempData["Mensaje"] = $"¡Listo! La cuenta de {datos.Empresa.Nombre} está creada. Ya podés publicar tu primera búsqueda.";
        return RedirectToAction("Index", "Publicaciones");
    }

    [HttpGet]
    public async Task<IActionResult> Externo(string proveedor, string? tipo = null, string? returnUrl = null)
    {
        if (await _esquemas.GetSchemeAsync(proveedor) == null || proveedor is not ("Google" or "LinkedIn"))
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
        var externo = await LeerExterno();
        if (externo == null || string.IsNullOrEmpty(externo.Email))
        {
            TempData["Mensaje"] = "No pudimos iniciar sesión con esa cuenta. Probá de nuevo o usá tu email y contraseña.";
            TempData["MensajeTipo"] = "error";
            return RedirectToAction(nameof(IniciarSesion));
        }

        try
        {
            var id = BD.ObtenerUsuarioDeLoginExterno(externo.Proveedor, externo.ID);
            if (id == null && BD.ObtenerUsuarioPorEmail(externo.Email) is { } existente)
            {
                BD.VincularLoginExterno(existente.ID, new LoginExternoNuevo { Proveedor = externo.Proveedor, ID_Externo = externo.ID });
                id = existente.ID;
            }

            if (id != null)
            {
                await HttpContext.SignOutAsync(Sesion.EsquemaExterno);
                await Sesion.Iniciar(HttpContext, id.Value, recordarme: true);
                TempData["Mensaje"] = $"¡Hola, {externo.Nombre}!";
                return RedirigirDespuesDeIngresar(returnUrl);
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos con el inicio de sesión externo");
            TempData["Mensaje"] = ErrorConexion;
            TempData["MensajeTipo"] = "error";
            return RedirectToAction(nameof(IniciarSesion));
        }

        return RedirectToAction(nameof(CrearCuenta), new { tipo });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CerrarSesion()
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        TempData["Mensaje"] = "Cerraste sesión. ¡Hasta pronto!";
        return RedirectToAction("Index", "Home");
    }

    private record DatosExternos(string Proveedor, string ID, string Email, string Nombre, string Apellido);

    private async Task<DatosExternos?> LeerExterno()
    {
        var resultado = await HttpContext.AuthenticateAsync(Sesion.EsquemaExterno);
        if (!resultado.Succeeded || resultado.Principal == null)
        {
            return null;
        }
        var p = resultado.Principal;
        string? Valor(params string[] tipos) => tipos.Select(p.FindFirstValue).FirstOrDefault(v => !string.IsNullOrEmpty(v));

        var proveedor = resultado.Properties?.Items.TryGetValue("proveedor", out var valor) == true ? valor : null;
        var id = Valor(ClaimTypes.NameIdentifier, "sub");
        if (proveedor == null || id == null)
        {
            return null;
        }
        return new DatosExternos(proveedor, id, NormalizarEmail(Valor(ClaimTypes.Email, "email")),
            Valor(ClaimTypes.GivenName, "given_name") ?? "", Valor(ClaimTypes.Surname, "family_name") ?? "");
    }

    private static void CompletarConExterno(RegistroBase modelo, DatosExternos? externo)
    {
        if (externo == null)
        {
            return;
        }
        modelo.ProveedorExterno = externo.Proveedor;
        modelo.Email = externo.Email;
        if (string.IsNullOrWhiteSpace(modelo.Nombre)) modelo.Nombre = externo.Nombre;
        if (string.IsNullOrWhiteSpace(modelo.Apellido)) modelo.Apellido = externo.Apellido;
    }

    private async Task TerminarRegistro(int idUsuario)
    {
        await HttpContext.SignOutAsync(Sesion.EsquemaExterno);
        await Sesion.Iniciar(HttpContext, idUsuario, recordarme: true);
    }

    private async Task CargarProveedores()
    {
        var proveedores = new List<string>();
        foreach (var nombre in new[] { "Google", "LinkedIn" })
        {
            if (await _esquemas.GetSchemeAsync(nombre) != null) proveedores.Add(nombre);
        }
        ViewBag.Proveedores = proveedores;
    }

    private void CargarListas(RegistroEmpresaViewModel modelo)
    {
        try
        {
            modelo.Paises = BD.ObtenerPaises();
            modelo.Provincias = BD.ObtenerProvincias();
            if (modelo.IDPais == null && modelo.Paises.Count == 1)
            {
                modelo.IDPais = modelo.Paises[0].ID;
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos al cargar las listas del registro");
            ModelState.AddModelError(string.Empty, ErrorConexion);
        }
    }

    private void NormalizarDatosBase(RegistroBase modelo)
    {
        modelo.Email = NormalizarEmail(modelo.Email);
        modelo.Nombre = modelo.Nombre?.Trim() ?? "";
        modelo.Apellido = modelo.Apellido?.Trim() ?? "";
    }

    private void ValidarContrasena(RegistroBase modelo, DatosExternos? externo)
    {
        if (externo == null && string.IsNullOrEmpty(modelo.Contrasena))
        {
            ModelState.AddModelError(nameof(modelo.Contrasena), "Elegí una contraseña");
        }
    }

    private bool ValidarEmailLibre(string email, string campo)
    {
        if (ModelState[campo]?.Errors.Count > 0 || string.IsNullOrEmpty(email))
        {
            return true;
        }
        try
        {
            if (BD.ExisteEmail(email))
            {
                ModelState.AddModelError(campo, "Ya hay una cuenta con ese email. ¿Querés iniciar sesión?");
                return false;
            }
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos al validar el email");
            ModelState.AddModelError(string.Empty, ErrorConexion);
            return false;
        }
        return true;
    }

    private void ManejarErrorDeRegistro(SqlException ex, string campoEmail)
    {
        if (ex.Number is 2627 or 2601)
        {
            ModelState.AddModelError(campoEmail, "Ya hay una cuenta con ese email. ¿Querés iniciar sesión?");
        }
        else
        {
            _logger.LogError(ex, "Error de base de datos al registrar una cuenta");
            ModelState.AddModelError(string.Empty, ErrorConexion);
        }
    }

    private void ValidarArchivo(IFormFile? archivo, string[] extensiones, string campo)
    {
        var error = Archivos.Validar(archivo, extensiones);
        if (error != null)
        {
            ModelState.AddModelError(campo, error);
        }
    }

    private (Provincia? Provincia, string? Telefono) ValidarUbicacionYTelefono(List<Pais> paises, List<Provincia> provincias, int? idPais, int? idProvincia,
                                                                             string? telefonoLocal, string campoProvincia, string campoTelefono)
    {
        var pais = paises.FirstOrDefault(p => p.ID == idPais);
        var provincia = provincias.FirstOrDefault(p => p.ID == idProvincia);
        if (idProvincia != null && (provincia == null || provincia.IDPais != idPais))
        {
            ModelState.AddModelError(campoProvincia, "Elegí una provincia de la lista");
            provincia = null;
        }
        return (provincia, Validaciones.Telefono(telefonoLocal, pais, campoTelefono, ModelState));
    }

    private string? NormalizarSaltos(string? texto, string campo, int largo)
    {
        if (texto == null)
        {
            return null;
        }
        texto = texto.Replace("\r\n", "\n");
        ModelState.Remove(campo);
        if (texto.Length > largo)
        {
            ModelState.AddModelError(campo, $"Usá hasta {largo} caracteres");
        }
        return texto;
    }

    private IActionResult VolverAlRegistro(string vista, RegistroBase modelo)
    {
        modelo.Contrasena = "";
        if (modelo.ProveedorExterno == null && ModelState[nameof(modelo.Contrasena)]?.Errors.Count is null or 0)
        {
            ModelState.AddModelError(nameof(modelo.Contrasena), "Por seguridad, volvé a escribir tu contraseña");
        }
        return View(vista, modelo);
    }

    private IActionResult RedirigirDespuesDeIngresar(string? returnUrl) =>
        !string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl)
            ? LocalRedirect(returnUrl)
            : RedirectToAction("Index", "Panel");

    private static string NormalizarEmail(string? email) => (email ?? "").Trim().ToLowerInvariant();

    private static string? Limpiar(string? texto) => Validaciones.Limpiar(texto);
}
