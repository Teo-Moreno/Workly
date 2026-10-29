using System.Net;
using System.Net.Mail;

namespace Workly.Models;

public class Correo
{
    private readonly IConfiguration _configuracion;
    private readonly ILogger<Correo> _logger;

    public Correo(IConfiguration configuracion, ILogger<Correo> logger)
    {
        _configuracion = configuracion;
        _logger = logger;
    }

    private IConfigurationSection Datos => _configuracion.GetSection("Correo");

    public bool Configurado => !string.IsNullOrWhiteSpace(Datos["Servidor"]) && !string.IsNullOrWhiteSpace(Datos["Remitente"]);

    public async Task<bool> Enviar(string destino, string asunto, string texto)
    {
        if (!Configurado)
        {
            return false;
        }
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
