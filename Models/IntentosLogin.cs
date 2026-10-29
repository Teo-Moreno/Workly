using Microsoft.Extensions.Caching.Memory;

namespace Workly.Models;

public class IntentosLogin
{
    public const int AntesDelCaptcha = 3;
    public const int AntesDelBloqueo = 8;
    private static readonly TimeSpan Ventana = TimeSpan.FromMinutes(15);

    private readonly IMemoryCache _cache;
    private readonly object _candado = new();

    public IntentosLogin(IMemoryCache cache)
    {
        _cache = cache;
    }

    private class Registro
    {
        public int Fallidos { get; set; }
        public DateTimeOffset Hasta { get; set; }
    }

    private static string ClaveEmail(string email) => "login-email:" + email.Trim().ToLowerInvariant();
    private static string ClaveIp(string? ip) => "login-ip:" + (ip ?? "sin-ip");

    public int Fallidos(string email, string? ip)
    {
        var porEmail = _cache.Get<Registro>(ClaveEmail(email))?.Fallidos ?? 0;
        var porIp = _cache.Get<Registro>(ClaveIp(ip))?.Fallidos ?? 0;
        return Math.Max(porEmail, porIp / 3);
    }

    public bool PideCaptcha(string email, string? ip) => Fallidos(email, ip) >= AntesDelCaptcha;

    public TimeSpan? Bloqueado(string email)
    {
        var registro = _cache.Get<Registro>(ClaveEmail(email));
        if (registro == null || registro.Fallidos < AntesDelBloqueo)
        {
            return null;
        }
        var resta = registro.Hasta - DateTimeOffset.UtcNow;
        return resta > TimeSpan.Zero ? resta : null;
    }

    public void Fallo(string email, string? ip)
    {
        lock (_candado)
        {
            foreach (var clave in new[] { ClaveEmail(email), ClaveIp(ip) })
            {
                var registro = _cache.Get<Registro>(clave) ?? new Registro();
                registro.Fallidos++;
                registro.Hasta = DateTimeOffset.UtcNow.Add(Ventana);
                _cache.Set(clave, registro, registro.Hasta);
            }
        }
    }

    public void Exito(string email)
    {
        _cache.Remove(ClaveEmail(email));
    }
}
