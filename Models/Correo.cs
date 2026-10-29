using System.Net;
using System.Net.Mail;
using System.Text.Json;

namespace Workly.Models;

public class Correo
{
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

    private bool UsaRelay => !string.IsNullOrWhiteSpace(Datos["Relay"]) && !string.IsNullOrWhiteSpace(Datos["RelayClave"]);

    private bool SmtpConfigurado => !string.IsNullOrWhiteSpace(Datos["Servidor"])
                                    && (string.IsNullOrWhiteSpace(Datos["Usuario"]) || !string.IsNullOrWhiteSpace(Datos["Contrasena"]));

    public bool Configurado => !string.IsNullOrWhiteSpace(Datos["Remitente"]) && (UsaRelay || SmtpConfigurado);

    public async Task<bool> Enviar(string destino, string asunto, string texto)
    {
        if (!Configurado)
        {
            return false;
        }
        return UsaRelay ? await EnviarPorRelay(destino, asunto, texto) : await EnviarPorSmtp(destino, asunto, texto);
    }

    private async Task<bool> EnviarPorRelay(string destino, string asunto, string texto)
    {
        try
        {
            using var pedido = new HttpRequestMessage(HttpMethod.Post, Datos["Relay"])
            {
                Content = new StringContent(JsonSerializer.Serialize(new { destino, asunto, texto }), System.Text.Encoding.UTF8, "application/json")
            };
            pedido.Headers.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", Datos["RelayClave"]);
            using var cliente = _http.CreateClient();
            cliente.Timeout = TimeSpan.FromSeconds(20);
            using var respuesta = await cliente.SendAsync(pedido);
            if (respuesta.IsSuccessStatusCode)
            {
                return true;
            }
            _logger.LogError("El servidor de mails no mandó el mail a {Destino}: {Estado} {Detalle}", destino, (int)respuesta.StatusCode,
                await respuesta.Content.ReadAsStringAsync());
            return false;
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or InvalidOperationException)
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
