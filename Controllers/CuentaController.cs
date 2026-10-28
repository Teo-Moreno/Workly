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

    public CuentaController(IWebHostEnvironment entorno, ILogger<CuentaController> logger, IAuthenticationSchemeProvider esquemas)
    {
        _entorno = entorno;
        _logger = logger;
        _esquemas = esquemas;
    }

    // ================================================================ Iniciar sesión

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
        if (!ModelState.IsValid)
        {
            return View(modelo);
        }

        Usuario? usuario;
        try
        {
            usuario = BD.ObtenerUsuarioPorEmail(NormalizarEmail(modelo.Email));
        }
        catch (SqlException ex)
        {
            _logger.LogError(ex, "Error de base de datos al iniciar sesión");
            ModelState.AddModelError(string.Empty, ErrorConexion);
            return View(modelo);
        }

        // Si el email no existe igual se verifica un hash de relleno, así la respuesta tarda lo mismo.
        if (!Contrasenas.Verificar(modelo.Contrasena, usuario?.Contraseña) || usuario == null)
        {
            var soloExterno = usuario != null && !usuario.TieneContrasena;
            ModelState.AddModelError(string.Empty, soloExterno
                ? "Esta cuenta entra con Google o LinkedIn. Usá el botón de abajo, o creá una contraseña desde Configuración."
                : "El email o la contraseña no son correctos.");
            modelo.Contrasena = "";
            return View(modelo);
        }

        await Sesion.Iniciar(HttpContext, usuario.ID, modelo.Recordarme);
        TempData["Mensaje"] = $"¡Hola de nuevo, {usuario.Nombre}!";
        return RedirigirDespuesDeIngresar(modelo.ReturnUrl);
    }

    // ================================================================ Crear cuenta

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
        CargarListas(persona);
        return View("CrearCuentaPersona", persona);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [RequestSizeLimit(12 * 1024 * 1024)]
    public async Task<IActionResult> CrearCuentaPersona(RegistroPersonaViewModel modelo)
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
        modelo.Descripcion = NormalizarSaltos(modelo.Descripcion, nameof(modelo.Descripcion), 500);

        ValidarContrasena(modelo, externo);
        var (provincia, telefono) = ValidarUbicacionYTelefono(modelo.Paises, modelo.Provincias, modelo.IDPais, modelo.IDProvincia, modelo.Telefono,
                                                              nameof(modelo.IDProvincia), nameof(modelo.Telefono));
        if (modelo.EstadoBusqueda != null && !Catalogos.EstadosBusqueda.Contains(modelo.EstadoBusqueda))
        {
            ModelState.AddModelError(nameof(modelo.EstadoBusqueda), "Elegí una opción de la lista");
        }

        var preferencia = Validaciones.Preferencia(modelo.PuestoBuscado, modelo.Niveles, modelo.Modalidades, modelo.Jornada, modelo.Contratacion,
                                                   modelo.IDProvinciaPreferida, modelo.SalarioMinimo, modelo.SalarioMaximo, modelo.Disponibilidad,
                                                   modelo.Provincias, nameof(modelo.SalarioMaximo), ModelState);
        var habilidades = Validaciones.Habilidades(modelo.Habilidades, nameof(modelo.Habilidades), ModelState);
        var idiomas = Validaciones.Idiomas(modelo.IdiomaIds, modelo.IdiomaNiveles, modelo.CatalogoIdiomas, "Idiomas", ModelState);
        var experiencias = ArmarExperiencias(modelo);
        var formaciones = ArmarFormaciones(modelo);

        ValidarArchivo(modelo.Foto, Archivos.ExtensionesFoto, nameof(modelo.Foto));
        ValidarArchivo(modelo.ArchivoCV, Archivos.ExtensionesCV, nameof(modelo.ArchivoCV));
        if (!ValidarEmailLibre(modelo.Email, nameof(modelo.Email)) || !ModelState.IsValid)
        {
            return VolverAlRegistro("CrearCuentaPersona", modelo);
        }

        // Archivos: se guardan antes de insertar; si el INSERT falla se borran.
        var rutaFoto = await Archivos.GuardarFoto(modelo.Foto, _entorno.WebRootPath);
        var nombreCV = await Archivos.GuardarCV(modelo.ArchivoCV, _entorno.ContentRootPath);
        var sitioWeb = Limpiar(modelo.SitioWeb);

        var datos = new PersonaNueva
        {
            Usuario = new Usuario
            {
                Nombre = modelo.Nombre,
                Apellido = modelo.Apellido,
                Email = modelo.Email,
                Contraseña = string.IsNullOrEmpty(modelo.Contrasena) ? null : Contrasenas.Hashear(modelo.Contrasena)
            },
            Perfil = new Perfil
            {
                IDProvincia = provincia?.ID,
                Foto = rutaFoto,
                Descripcion = Limpiar(modelo.Descripcion),
                Telefono = telefono,
                Estado_Busqueda = modelo.EstadoBusqueda
            },
            CV = nombreCV != null || sitioWeb != null ? new CV { Nombre_Archivo = nombreCV, Sitio_Web = sitioWeb } : null,
            Preferencia = preferencia.TieneDatos || preferencia.IDProvincia.HasValue ? preferencia : null,
            Habilidades = habilidades,
            Idiomas = idiomas,
            Experiencias = experiencias,
            Formaciones = formaciones,
            LoginExterno = externo == null ? null : new LoginExternoNuevo { Proveedor = externo.Proveedor, ID_Externo = externo.ID }
        };

        int id;
        try
        {
            id = BD.RegistrarPersona(datos);
        }
        catch (SqlException ex)
        {
            Archivos.Borrar(Archivos.RutaImagen(rutaFoto, _entorno.WebRootPath));
            if (nombreCV != null) Archivos.Borrar(Path.Combine(Archivos.CarpetaCV(_entorno.ContentRootPath), nombreCV));
            ManejarErrorDeRegistro(ex, nameof(modelo.Email));
            return VolverAlRegistro("CrearCuentaPersona", modelo);
        }

        await TerminarRegistro(id);
        TempData["Mensaje"] = $"¡Te damos la bienvenida a Workly, {modelo.Nombre}! Tu cuenta está lista.";
        return RedirectToAction("Index", "Panel");
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

        // Verificación de la empresa: CUIT válido y email del dominio de la empresa
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
        TempData["Mensaje"] = $"¡Listo! La cuenta de {modelo.NombreEmpresa} está creada. Ya podés publicar tu primera búsqueda.";
        return RedirectToAction("Index", "Publicaciones");
    }

    // ================================================================ Google y LinkedIn

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
            // 1. Ya entró antes con esta cuenta
            var id = BD.ObtenerUsuarioDeLoginExterno(externo.Proveedor, externo.ID);
            // 2. Ya tiene una cuenta con ese email: se vinculan
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

        // 3. Es nueva: completa el registro con sus datos ya cargados
        return RedirectToAction(nameof(CrearCuenta), new { tipo });
    }

    // ================================================================ Cerrar sesión

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> CerrarSesion()
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        TempData["Mensaje"] = "Cerraste sesión. ¡Hasta pronto!";
        return RedirectToAction("Index", "Home");
    }

    // ================================================================ Auxiliares

    private record DatosExternos(string Proveedor, string ID, string Email, string Nombre, string Apellido);

    // Datos que dejó Google o LinkedIn en la cookie temporal (null si no hay)
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
        modelo.Email = externo.Email; // El email lo confirmó Google o LinkedIn: no se cambia
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

    private void CargarListas(RegistroBase modelo)
    {
        try
        {
            modelo.Paises = BD.ObtenerPaises();
            modelo.Provincias = BD.ObtenerProvincias();
            if (modelo.IDPais == null && modelo.Paises.Count == 1)
            {
                modelo.IDPais = modelo.Paises[0].ID;
            }
            if (modelo is RegistroPersonaViewModel persona)
            {
                persona.CatalogoHabilidades = BD.ObtenerCatalogoHabilidades();
                persona.CatalogoIdiomas = BD.ObtenerCatalogoIdiomas();
                persona.Instituciones = BD.ObtenerInstituciones();
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
        // 2627 / 2601: algo único repetido (por ejemplo, dos registros al mismo tiempo con el mismo email)
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

    /// <summary>País y provincia coherentes y teléfono con 10 números. Devuelve la provincia y el teléfono con prefijo.</summary>
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

    private List<ExperienciaNueva> ArmarExperiencias(RegistroPersonaViewModel m)
    {
        var lista = new List<ExperienciaNueva>();
        for (var i = 0; i < m.ExpPuesto.Count; i++)
        {
            var puesto = Valor(m.ExpPuesto, i);
            var empresa = Valor(m.ExpEmpresa, i);
            var inicio = Fechas.ParsearMesAnio(Valor(m.ExpInicio, i));
            var finTexto = Valor(m.ExpFin, i);
            var fin = Fechas.ParsearMesAnio(finTexto);
            var descripcion = Valor(m.ExpDescripcion, i);
            if (puesto.Length is 0 or > 100 || empresa.Length is 0 or > 100 || inicio == null || inicio > Fechas.MesActual ||
                (finTexto.Length > 0 && (fin == null || fin < inicio || fin > Fechas.MesActual)) || descripcion.Length > 500)
            {
                ModelState.AddModelError("Experiencias", "Revisá las experiencias: cada una necesita puesto, empresa y fechas válidas.");
                continue;
            }
            lista.Add(new ExperienciaNueva { Puesto = puesto, Empresa = empresa, Inicio = inicio.Value, Fin = fin, Descripcion = Limpiar(descripcion) });
        }
        return lista;
    }

    private List<FormacionNueva> ArmarFormaciones(RegistroPersonaViewModel m)
    {
        var lista = new List<FormacionNueva>();
        for (var i = 0; i < m.ForTitulo.Count; i++)
        {
            var titulo = Valor(m.ForTitulo, i);
            var institucion = Valor(m.ForInstitucion, i);
            var inicio = Fechas.ParsearMesAnio(Valor(m.ForInicio, i));
            var finTexto = Valor(m.ForFin, i);
            var fin = Fechas.ParsearMesAnio(finTexto);
            if (titulo.Length is 0 or > 150 || institucion.Length is 0 or > 150 || inicio == null || inicio > Fechas.MesActual ||
                (finTexto.Length > 0 && (fin == null || fin < inicio)))
            {
                ModelState.AddModelError("Formaciones", "Revisá la formación: cada una necesita título, institución y fechas válidas.");
                continue;
            }
            lista.Add(new FormacionNueva { Titulo = titulo, Institucion = institucion, Inicio = inicio.Value, Fin = fin });
        }
        return lista;
    }

    private static string Valor(List<string> lista, int i) => i < lista.Count ? (lista[i] ?? "").Trim() : "";

    // El navegador cuenta cada salto de línea como 1 carácter pero envía "\r\n" (2):
    // se normaliza antes de medir para que el límite coincida con el del formulario.
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

    // La contraseña no se devuelve en el HTML: si hubo errores se pide escribirla de nuevo,
    // así el formulario abre en el paso 1 y la persona recorre los pasos marcados en rojo.
    private IActionResult VolverAlRegistro(string vista, RegistroBase modelo)
    {
        modelo.Contrasena = "";
        if (modelo.ProveedorExterno == null && ModelState[nameof(modelo.Contrasena)]?.Errors.Count is null or 0)
        {
            ModelState.AddModelError(nameof(modelo.Contrasena), "Por seguridad, volvé a escribir tu contraseña");
        }
        return View(vista, modelo);
    }

    // Solo redirige a direcciones de este sitio (evita redirecciones abiertas a otros dominios).
    private IActionResult RedirigirDespuesDeIngresar(string? returnUrl) =>
        !string.IsNullOrEmpty(returnUrl) && Url.IsLocalUrl(returnUrl)
            ? LocalRedirect(returnUrl)
            : RedirectToAction("Index", "Panel");

    private static string NormalizarEmail(string? email) => (email ?? "").Trim().ToLowerInvariant();

    private static string? Limpiar(string? texto) => Validaciones.Limpiar(texto);
}
