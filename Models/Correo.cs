using System.Net;
using System.Net.Http.Json;
using System.Net.Mail;

namespace Workly.Models;

public class Correo
{
    private const string UrlBrevo = "https://api.brevo.com/v3/smtp/email";

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

    private bool UsaBrevo => !string.IsNullOrWhiteSpace(Datos["BrevoApiKey"]);

    private bool SmtpConfigurado => !string.IsNullOrWhiteSpace(Datos["Servidor"])
                                    && (string.IsNullOrWhiteSpace(Datos["Usuario"]) || !string.IsNullOrWhiteSpace(Datos["Contrasena"]));

    public bool Configurado => !string.IsNullOrWhiteSpace(Datos["Remitente"]) && (UsaBrevo || SmtpConfigurado);

    public async Task<bool> Enviar(string destino, string asunto, string texto)
    {
        if (!Configurado)
        {
            return false;
        }
        return UsaBrevo ? await EnviarPorBrevo(destino, asunto, texto) : await EnviarPorSmtp(destino, asunto, texto);
    }

    private async Task<bool> EnviarPorBrevo(string destino, string asunto, string texto)
    {
        try
        {
            using var pedido = new HttpRequestMessage(HttpMethod.Post, UrlBrevo)
            {
                Content = JsonContent.Create(new
                {
                    sender = new { name = Datos["NombreRemitente"] ?? "Workly", email = Datos["Remitente"] },
                    to = new[] { new { email = destino } },
                    subject = asunto,
                    textContent = texto
                })
            };
            pedido.Headers.Add("api-key", Datos["BrevoApiKey"]);
            pedido.Headers.Accept.ParseAdd("application/json");
            using var cliente = _http.CreateClient();
            cliente.Timeout = TimeSpan.FromSeconds(20);
            using var respuesta = await cliente.SendAsync(pedido);
            if (respuesta.IsSuccessStatusCode)
            {
                return true;
            }
            _logger.LogError("Brevo no mandó el mail a {Destino}: {Estado} {Detalle}", destino, (int)respuesta.StatusCode,
                await respuesta.Content.ReadAsStringAsync());
            return false;
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException)
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
