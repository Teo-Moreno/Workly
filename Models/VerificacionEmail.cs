using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Caching.Memory;

namespace Workly.Models;

public class VerificacionEmail
{
    public const int Digitos = 6;
    public const int MaxIntentos = 5;
    public static readonly TimeSpan Vigencia = TimeSpan.FromMinutes(15);
    public static readonly TimeSpan EsperaReenvio = TimeSpan.FromSeconds(60);
    private const int MaxReenvios = 3;

    private readonly IMemoryCache _cache;

    public VerificacionEmail(IMemoryCache cache)
    {
        _cache = cache;
    }

    public class Pendiente
    {
        public string Email { get; init; } = "";
        public string Nombre { get; init; } = "";
        public object Datos { get; init; } = new();
        public string? ArchivoTemporal { get; init; }
        public string Codigo { get; set; } = "";
        public int Intentos { get; set; }
        public int Reenvios { get; set; }
        public DateTime UltimoEnvio { get; set; }
        public bool Terminado { get; set; }
    }

    public enum Resultado { Correcto, Incorrecto, SinIntentos, Vencido }

    public (string Token, string Codigo) Crear(string email, string nombre, object datos, string? archivoTemporal)
    {
        var token = Convert.ToBase64String(RandomNumberGenerator.GetBytes(32)).Replace('+', '-').Replace('/', '_').TrimEnd('=');
        var pendiente = new Pendiente
        {
            Email = email,
            Nombre = nombre,
            Datos = datos,
            ArchivoTemporal = archivoTemporal,
            Codigo = NuevoCodigo(),
            UltimoEnvio = DateTime.UtcNow
        };
        var opciones = new MemoryCacheEntryOptions { AbsoluteExpirationRelativeToNow = Vigencia };
        opciones.RegisterPostEvictionCallback((_, valor, _, _) =>
        {
            if (valor is Pendiente { Terminado: false, ArchivoTemporal: { } archivo })
            {
                Archivos.Borrar(archivo);
            }
        });
        _cache.Set(Clave(token), pendiente, opciones);
        return (token, pendiente.Codigo);
    }

    public Pendiente? Obtener(string? token) =>
        string.IsNullOrEmpty(token) ? null : _cache.Get<Pendiente>(Clave(token));

    public Resultado Verificar(string? token, string? codigo)
    {
        var pendiente = Obtener(token);
        if (pendiente == null)
        {
            return Resultado.Vencido;
        }
        var escrito = new string((codigo ?? "").Where(char.IsDigit).ToArray());
        lock (pendiente)
        {
            if (pendiente.Intentos >= MaxIntentos)
            {
                return Resultado.SinIntentos;
            }
            if (CryptographicOperations.FixedTimeEquals(Encoding.UTF8.GetBytes(escrito), Encoding.UTF8.GetBytes(pendiente.Codigo)))
            {
                return Resultado.Correcto;
            }
            pendiente.Intentos++;
            return pendiente.Intentos >= MaxIntentos ? Resultado.SinIntentos : Resultado.Incorrecto;
        }
    }

    public string? Reenviar(string? token)
    {
        var pendiente = Obtener(token);
        if (pendiente == null)
        {
            return null;
        }
        lock (pendiente)
        {
            if (pendiente.Reenvios >= MaxReenvios || DateTime.UtcNow - pendiente.UltimoEnvio < EsperaReenvio)
            {
                return null;
            }
            pendiente.Reenvios++;
            pendiente.Intentos = 0;
            pendiente.UltimoEnvio = DateTime.UtcNow;
            pendiente.Codigo = NuevoCodigo();
            return pendiente.Codigo;
        }
    }

    public void Terminar(string token)
    {
        if (Obtener(token) is { } pendiente)
        {
            pendiente.Terminado = true;
        }
        _cache.Remove(Clave(token));
    }

    public void Descartar(string token) => _cache.Remove(Clave(token));

    private static string NuevoCodigo() => RandomNumberGenerator.GetInt32(0, (int)Math.Pow(10, Digitos)).ToString(new string('0', Digitos));

    private static string Clave(string token) => "verificacion-email:" + token;
}
