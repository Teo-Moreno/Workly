using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.Data.SqlClient;

namespace Workly.Models;

public static class Cuentas
{
    public const string ErrorConexion =
        "No pudimos conectarnos con la base de datos. Revisá que SQL Server esté funcionando y la cadena de conexión en appsettings.json.";

    public static readonly string[] ProveedoresExternos = { "Google", "LinkedIn" };

    public static string NormalizarEmail(string? email) => (email ?? "").Trim().ToLowerInvariant();

    public static async Task<List<string>> ProveedoresDisponibles(IAuthenticationSchemeProvider esquemas)
    {
        var proveedores = new List<string>();
        foreach (var nombre in ProveedoresExternos)
        {
            if (await esquemas.GetSchemeAsync(nombre) != null) proveedores.Add(nombre);
        }
        return proveedores;
    }

    public static Usuario? IniciarSesion(LoginViewModel modelo, string? ip, IntentosLogin intentos, Captcha captcha,
                                         string? tokenCaptcha, string? respuestaCaptcha, ModelStateDictionary estado, ILogger logger)
    {
        var email = NormalizarEmail(modelo.Email);
        if (!estado.IsValid)
        {
            return null;
        }

        if (intentos.Bloqueado(email) is { } espera)
        {
            var minutos = Math.Max(1, (int)Math.Ceiling(espera.TotalMinutes));
            estado.AddModelError(string.Empty,
                $"Por seguridad frenamos el ingreso con este email después de varios intentos fallidos. Probá de nuevo en {minutos} {(minutos == 1 ? "minuto" : "minutos")}.");
            return null;
        }

        if (intentos.PideCaptcha(email, ip) && !captcha.Verificar(tokenCaptcha, respuestaCaptcha))
        {
            estado.AddModelError(Captcha.CampoRespuesta, "Escribí las letras de la imagen");
            return null;
        }

        Usuario? usuario;
        try
        {
            usuario = BD.ObtenerUsuarioPorEmail(email);
        }
        catch (SqlException ex)
        {
            logger.LogError(ex, "Error de base de datos al iniciar sesión");
            estado.AddModelError(string.Empty, ErrorConexion);
            return null;
        }

        if (!Contrasenas.Verificar(modelo.Contrasena, usuario?.Contraseña) || usuario == null)
        {
            intentos.Fallo(email, ip);
            var soloExterno = usuario != null && !usuario.TieneContrasena;
            estado.AddModelError(string.Empty, soloExterno
                ? "Esta cuenta entra con Google o LinkedIn. Usá el botón de abajo, o creá una contraseña desde Configuración."
                : "El email o la contraseña no son correctos.");
            return null;
        }

        intentos.Exito(email);
        return usuario;
    }

    public static string HashDeToken(string token) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token))).ToLowerInvariant();

    public static async Task PedirRecuperacion(string email, Func<string, string> enlace, Correo correo)
    {
        var usuario = BD.ObtenerUsuarioPorEmail(NormalizarEmail(email));
        if (usuario == null || BD.ContarRecuperacionesRecientes(usuario.ID) >= 3)
        {
            return;
        }
        var token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32)).Replace('+', '-').Replace('/', '_').TrimEnd('=');
        BD.GuardarRecuperacion(usuario.ID, HashDeToken(token), DateTime.UtcNow.AddHours(1));
        await correo.EnviarRecuperacion(usuario, enlace(token));
    }

    public static bool RecuperacionVigente(string? token) =>
        !string.IsNullOrEmpty(token) && BD.ObtenerUsuarioDeRecuperacion(HashDeToken(token)) != null;

    public static bool UsarRecuperacion(string token, string nueva) =>
        BD.UsarRecuperacion(HashDeToken(token), Contrasenas.Hashear(nueva));

    public static void PrepararRegistro(RegistroBase modelo, CuentaExterna? externa, ModelStateDictionary estado)
    {
        externa?.CompletarRegistro(modelo);
        modelo.Email = NormalizarEmail(modelo.Email);
        modelo.Nombre = modelo.Nombre?.Trim() ?? "";
        modelo.Apellido = modelo.Apellido?.Trim() ?? "";
        if (externa == null && string.IsNullOrEmpty(modelo.Contrasena))
        {
            estado.AddModelError(nameof(modelo.Contrasena), "Elegí una contraseña");
        }
    }

    public static bool EmailLibre(string email, string campo, ModelStateDictionary estado, ILogger logger)
    {
        if (estado[campo]?.Errors.Count > 0 || string.IsNullOrEmpty(email))
        {
            return true;
        }
        try
        {
            if (BD.ExisteEmail(email))
            {
                estado.AddModelError(campo, "Ya hay una cuenta con ese email. ¿Querés iniciar sesión?");
                return false;
            }
        }
        catch (SqlException ex)
        {
            logger.LogError(ex, "Error de base de datos al validar el email");
            estado.AddModelError(string.Empty, ErrorConexion);
            return false;
        }
        return true;
    }

    public static EmpresaValidada ValidarEmpresa(RegistroEmpresaViewModel modelo, ModelStateDictionary estado, ILogger logger)
    {
        modelo.NombreEmpresa = modelo.NombreEmpresa?.Trim() ?? "";
        modelo.RazonSocial = modelo.RazonSocial?.Trim() ?? "";
        modelo.Descripcion = Validaciones.TextoLargo(modelo.Descripcion, nameof(modelo.Descripcion), 500, estado);
        var validada = new EmpresaValidada { CUIT = VerificacionEmpresa.SoloNumeros(modelo.CUIT) };

        (validada.Provincia, validada.Telefono) = Validaciones.Ubicacion(modelo.Paises, modelo.Provincias, modelo.IDPais, modelo.IDProvincia,
                                                                         modelo.Telefono, nameof(modelo.IDProvincia), nameof(modelo.Telefono), estado);
        if (modelo.Rubro != null && !Catalogos.Rubros.Contains(modelo.Rubro))
        {
            estado.AddModelError(nameof(modelo.Rubro), "Elegí un rubro de la lista");
        }
        Validaciones.Archivo(modelo.Logo, Archivos.ExtensionesFoto, nameof(modelo.Logo), estado);

        if (!string.IsNullOrEmpty(modelo.CUIT) && !VerificacionEmpresa.CuitValido(validada.CUIT))
        {
            estado.AddModelError(nameof(modelo.CUIT), "El CUIT no es válido. Revisá los 11 números (el último es el verificador).");
        }
        if (!string.IsNullOrEmpty(modelo.SitioWeb) && VerificacionEmpresa.DominioDelSitio(modelo.SitioWeb) == null)
        {
            estado.AddModelError(nameof(modelo.SitioWeb), "Ingresá una dirección válida, por ejemplo tuempresa.com.ar");
        }
        else if (estado[nameof(modelo.Email)]?.Errors.Count is null or 0 && !string.IsNullOrEmpty(modelo.Email))
        {
            if (VerificacionEmpresa.EsEmailGratuito(modelo.Email))
            {
                estado.AddModelError(nameof(modelo.Email), "Usá el email de la empresa (no se aceptan Gmail, Hotmail, Outlook, etc.)");
            }
            else if (!string.IsNullOrEmpty(modelo.SitioWeb) && !VerificacionEmpresa.EmailCoincideConSitio(modelo.Email, modelo.SitioWeb))
            {
                estado.AddModelError(nameof(modelo.Email),
                    $"El email tiene que ser del dominio de la empresa (@{VerificacionEmpresa.DominioDelSitio(modelo.SitioWeb)})");
            }
        }

        try
        {
            if (VerificacionEmpresa.CuitValido(validada.CUIT) && BD.ExisteCuit(validada.CUIT))
            {
                estado.AddModelError(nameof(modelo.CUIT), "Ya hay una cuenta de empresa con ese CUIT. Si es tu empresa, pedile acceso a quien la creó.");
            }
            if (modelo.NombreEmpresa.Length > 0 && BD.NombreEmpresaConCuenta(modelo.NombreEmpresa))
            {
                estado.AddModelError(nameof(modelo.NombreEmpresa), "Ya hay una cuenta de empresa con ese nombre.");
            }
        }
        catch (SqlException ex)
        {
            logger.LogError(ex, "Error de base de datos al validar la empresa");
            estado.AddModelError(string.Empty, ErrorConexion);
        }
        return validada;
    }

    public static PersonaNueva ArmarPersona(RegistroPersonaViewModel modelo, CuentaExterna? externa) => new()
    {
        Usuario = ArmarUsuario(modelo),
        LoginExterno = externa?.Login
    };

    public static EmpresaNueva ArmarEmpresa(RegistroEmpresaViewModel modelo, CuentaExterna? externa, EmpresaValidada validada, string? rutaLogo) => new()
    {
        Usuario = ArmarUsuario(modelo),
        Empresa = new Empresa
        {
            Nombre = modelo.NombreEmpresa,
            Razon_Social = modelo.RazonSocial,
            CUIT = validada.CUIT,
            Rubro = modelo.Rubro,
            Sitio_Web = modelo.SitioWeb.Trim(),
            IDProvincia = validada.Provincia?.ID,
            Ubicacion = Validaciones.Limpiar(modelo.Ubicacion),
            Telefono = validada.Telefono,
            Descripcion = Validaciones.Limpiar(modelo.Descripcion),
            Logo = rutaLogo
        },
        LoginExterno = externa?.Login
    };

    private static Usuario ArmarUsuario(RegistroBase modelo) => new()
    {
        Nombre = modelo.Nombre,
        Apellido = modelo.Apellido,
        Email = modelo.Email,
        Contraseña = string.IsNullOrEmpty(modelo.Contrasena) ? null : Contrasenas.Hashear(modelo.Contrasena)
    };

    public static int? Registrar(object datos, string campoEmail, ModelStateDictionary estado, ILogger logger)
    {
        try
        {
            return datos is EmpresaNueva empresa ? BD.RegistrarEmpresa(empresa) : BD.RegistrarPersona((PersonaNueva)datos);
        }
        catch (SqlException ex) when (ex.Number is 2627 or 2601)
        {
            estado.AddModelError(campoEmail, "Ya hay una cuenta con ese email. ¿Querés iniciar sesión?");
        }
        catch (SqlException ex)
        {
            logger.LogError(ex, "Error de base de datos al registrar una cuenta");
            estado.AddModelError(string.Empty, ErrorConexion);
        }
        return null;
    }

    public static string Bienvenida(object datos) => datos is EmpresaNueva empresa
        ? $"¡Listo! La cuenta de {empresa.Empresa.Nombre} está creada. Ya podés publicar tu primera búsqueda."
        : $"¡Te damos la bienvenida a Workly, {((PersonaNueva)datos).Usuario.Nombre}! Tu cuenta está lista. Completá tu perfil cuando quieras.";

    public static void PrepararReintento(RegistroBase modelo, ModelStateDictionary estado)
    {
        modelo.Contrasena = "";
        if (modelo.ProveedorExterno == null && estado[nameof(modelo.Contrasena)]?.Errors.Count is null or 0)
        {
            estado.AddModelError(nameof(modelo.Contrasena), "Por seguridad, volvé a escribir tu contraseña");
        }
    }
}

public class EmpresaValidada
{
    public string CUIT { get; set; } = "";
    public Provincia? Provincia { get; set; }
    public string? Telefono { get; set; }
}
