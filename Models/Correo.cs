using System.Net;
using System.Net.Mail;
using System.Text.Json;

namespace Workly.Models;

public class Correo
{
    private const string UrlResend = "https://api.resend.com/emails";

    private readonly IConfiguration _configuracion;
    private readonly IHttpClientFactory _http;
    private readonly ILogger<Correo> _logger;

    public Correo(IConfiguration configuracion, IHttpClientFactory http, ILogger<Correo> logger)
    {
        _configuracion = configuracion;
        _http = http;
        _logger = logger;
    }

    private IConfigurationSection Datos => _configuracion.GetSection("Correo");

    private bool UsaResend => !string.IsNullOrWhiteSpace(Datos["ResendApiKey"]);

    private bool SmtpConfigurado => !string.IsNullOrWhiteSpace(Datos["Servidor"])
                                    && (string.IsNullOrWhiteSpace(Datos["Usuario"]) || !string.IsNullOrWhiteSpace(Datos["Contrasena"]));

    public bool Configurado => !string.IsNullOrWhiteSpace(Datos["Remitente"]) && (UsaResend || SmtpConfigurado);

    public async Task<bool> Enviar(string destino, string asunto, string texto)
    {
        if (!Configurado)
        {
            return false;
        }
        return UsaResend ? await EnviarPorResend(destino, asunto, texto) : await EnviarPorSmtp(destino, asunto, texto);
    }

    public Task<bool> EnviarRecuperacion(Usuario usuario, string enlace) =>
        Enviar(usuario.Email, "Workly: creá una contraseña nueva",
            $"Hola, {usuario.Nombre}.\n\n" +
            "Pediste crear una contraseña nueva para tu cuenta de Workly. Entrá a este link para elegirla:\n\n" +
            $"{enlace}\n\n" +
            "El link sirve una sola vez y vence en 1 hora. Si no lo pediste vos, ignorá este mail: tu contraseña no cambia.\n\n" +
            "Workly");

    public async Task<bool> EnviarCodigo(string email, string nombre, string codigo, bool esDesarrollo)
    {
        if (!Configurado && esDesarrollo)
        {
            _logger.LogWarning("El mail no está configurado. Código de verificación para {Email}: {Codigo}", email, codigo);
            return true;
        }
        return await Enviar(email, $"{codigo} es tu código de Workly",
            $"Hola, {nombre}.\n\n" +
            $"Tu código para terminar de crear tu cuenta en Workly es:\n\n{codigo}\n\n" +
            $"Vence en {VerificacionEmail.Vigencia.TotalMinutes:0} minutos. Si no estás creando una cuenta en Workly, ignorá este mail.\n\n" +
            "Workly");
    }

    public async Task<bool> EnviarRechazo(Usuario publicador, Oferta oferta, string motivo, string? enlace)
    {
        if (!Configurado)
        {
            return false;
        }
        return await Enviar(publicador.Email, $"Workly: tu búsqueda \"{oferta.Titulo}\" no se publicó",
            $"Hola, {publicador.Nombre}.\n\n" +
            $"Revisamos tu búsqueda \"{oferta.Titulo}\" y no la pudimos publicar. Este es el motivo:\n\n" +
            $"{motivo}\n\n" +
            $"Podés verla en Mis publicaciones y publicar una nueva con los cambios: {enlace}\n\n" +
            "Workly");
    }

    public Task<bool> EnviarResumen(OfertaParaResumen oferta, int nuevos, Postulante? mejor, string? enlace)
    {
        var texto = $"Hola, {oferta.Nombre}.\n\n" +
                    $"Este es el resumen de los últimos {ResumenPostulaciones.DiasEntreResumenes} días de tu búsqueda \"{oferta.Titulo}\".\n\n" +
                    (nuevos == 0
                        ? "En estos días no se postuló nadie nuevo.\n\n"
                        : (nuevos == 1 ? "Se postuló 1 persona nueva.\n\n" : $"Se postularon {nuevos} personas nuevas.\n\n")) +
                    $"En total, la búsqueda tiene {oferta.Total} {(oferta.Total == 1 ? "postulación" : "postulaciones")}.\n\n";
        if (mejor != null)
        {
            texto += $"Quien más coincide con lo que pediste es {mejor.NombreCompleto} ({mejor.Puntaje}% de coincidencia" +
                     (mejor.Motivos.Count > 0 ? ": " + string.Join(", ", mejor.Motivos) : "") + ").\n\n";
        }
        if (enlace != null)
        {
            texto += $"Mirá todos los postulantes acá: {enlace}\n\n";
        }
        return Enviar(oferta.Email, $"Workly: resumen de tu búsqueda \"{oferta.Titulo}\"", texto + "Workly");
    }

    private async Task<bool> EnviarPorResend(string destino, string asunto, string texto)
    {
        try
        {
            var remitente = new MailAddress(Datos["Remitente"]!, Datos["NombreRemitente"] ?? "Workly").ToString();
            using var pedido = new HttpRequestMessage(HttpMethod.Post, UrlResend)
            {
                Content = new StringContent(JsonSerializer.Serialize(new { from = remitente, to = new[] { destino }, subject = asunto, text = texto }),
                                            System.Text.Encoding.UTF8, "application/json")
            };
            pedido.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", Datos["ResendApiKey"]);
            using var cliente = _http.CreateClient();
            cliente.Timeout = TimeSpan.FromSeconds(20);
            using var respuesta = await cliente.SendAsync(pedido);
            if (respuesta.IsSuccessStatusCode)
            {
                return true;
            }
            _logger.LogError("Resend no mandó el mail a {Destino}: {Estado} {Detalle}", destino, (int)respuesta.StatusCode,
                await respuesta.Content.ReadAsStringAsync());
            return false;
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or InvalidOperationException or FormatException)
        {
            _logger.LogError(ex, "No se pudo enviar el mail a {Destino}", destino);
            return false;
        }
    }

    private async Task<bool> EnviarPorSmtp(string destino, string asunto, string texto)
    {
        try
        {
            using var mensaje = new MailMessage
            {
                From = new MailAddress(Datos["Remitente"]!, Datos["NombreRemitente"] ?? "Workly"),
                Subject = asunto,
                Body = texto,
                IsBodyHtml = false,
                BodyEncoding = System.Text.Encoding.UTF8,
                SubjectEncoding = System.Text.Encoding.UTF8
            };
            mensaje.To.Add(destino);
            using var cliente = new SmtpClient(Datos["Servidor"], int.TryParse(Datos["Puerto"], out var puerto) ? puerto : 587)
            {
                EnableSsl = !string.Equals(Datos["Ssl"], "false", StringComparison.OrdinalIgnoreCase),
                DeliveryMethod = SmtpDeliveryMethod.Network,
                Timeout = 20000
            };
            if (!string.IsNullOrWhiteSpace(Datos["Usuario"]))
            {
                cliente.Credentials = new NetworkCredential(Datos["Usuario"], Datos["Contrasena"]);
            }
            await cliente.SendMailAsync(mensaje);
            return true;
        }
        catch (Exception ex) when (ex is SmtpException or InvalidOperationException or FormatException)
        {
            _logger.LogError(ex, "No se pudo enviar el mail a {Destino}", destino);
            return false;
        }
    }
}
