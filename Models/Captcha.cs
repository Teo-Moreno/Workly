using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.Extensions.Caching.Memory;

namespace Workly.Models;

public class Captcha
{
    public const string CampoToken = "CaptchaToken";
    public const string CampoRespuesta = "CaptchaRespuesta";
    private const string Letras = "ACDEFHJKMNPQRTUVWXY34679";
    private const int Largo = 5;
    private static readonly TimeSpan Vigencia = TimeSpan.FromMinutes(15);

    private readonly ITimeLimitedDataProtector _protector;
    private readonly IMemoryCache _usados;

    public Captcha(IDataProtectionProvider proveedor, IMemoryCache cache)
    {
        _protector = proveedor.CreateProtector("Workly.Captcha").ToTimeLimitedDataProtector();
        _usados = cache;
    }

    public record Desafio(string Token, string Imagen);

    public Desafio Nuevo()
    {
        var codigo = new string(Enumerable.Range(0, Largo).Select(_ => Letras[RandomNumberGenerator.GetInt32(Letras.Length)]).ToArray());
        var token = _protector.Protect(codigo + "|" + Guid.NewGuid().ToString("N"), Vigencia);
        return new Desafio(token, "data:image/svg+xml;base64," + Convert.ToBase64String(Encoding.UTF8.GetBytes(Dibujar(codigo))));
    }

    public bool Verificar(string? token, string? respuesta)
    {
        if (string.IsNullOrWhiteSpace(token) || string.IsNullOrWhiteSpace(respuesta))
        {
            return false;
        }
        string contenido;
        try
        {
            contenido = _protector.Unprotect(token);
        }
        catch (CryptographicException)
        {
            return false;
        }
        var codigo = contenido.Split('|')[0];
        var clave = "captcha:" + contenido;
        if (_usados.TryGetValue(clave, out _))
        {
            return false;
        }
        _usados.Set(clave, true, Vigencia);
        var escrito = new string(respuesta.Where(char.IsLetterOrDigit).ToArray()).ToUpperInvariant();
        return CryptographicOperations.FixedTimeEquals(Encoding.UTF8.GetBytes(escrito), Encoding.UTF8.GetBytes(codigo));
    }

    private static readonly Dictionary<char, double[][]> Trazos = new()
    {
        ['A'] = new[] { new double[] { 0, 6, 2, 0, 4, 6 }, new double[] { 1, 3.6, 3, 3.6 } },
        ['B'] = new[] { new double[] { 0, 0, 0, 6, 3, 6, 4, 5, 4, 4, 3, 3, 0, 3 }, new double[] { 0, 0, 3, 0, 4, 1, 4, 2, 3, 3 } },
        ['C'] = new[] { new double[] { 4, 1, 3, 0, 1, 0, 0, 1, 0, 5, 1, 6, 3, 6, 4, 5 } },
        ['D'] = new[] { new double[] { 0, 0, 0, 6, 2.5, 6, 4, 4.5, 4, 1.5, 2.5, 0, 0, 0 } },
        ['E'] = new[] { new double[] { 4, 0, 0, 0, 0, 6, 4, 6 }, new double[] { 0, 3, 3, 3 } },
        ['F'] = new[] { new double[] { 4, 0, 0, 0, 0, 6 }, new double[] { 0, 3, 3, 3 } },
        ['G'] = new[] { new double[] { 4, 1, 3, 0, 1, 0, 0, 1, 0, 5, 1, 6, 3, 6, 4, 5, 4, 3, 2, 3 } },
        ['H'] = new[] { new double[] { 0, 0, 0, 6 }, new double[] { 4, 0, 4, 6 }, new double[] { 0, 3, 4, 3 } },
        ['J'] = new[] { new double[] { 4, 0, 4, 5, 3, 6, 1, 6, 0, 5 } },
        ['K'] = new[] { new double[] { 0, 0, 0, 6 }, new double[] { 4, 0, 0, 3.5 }, new double[] { 1.5, 2.5, 4, 6 } },
        ['M'] = new[] { new double[] { 0, 6, 0, 0, 2, 3, 4, 0, 4, 6 } },
        ['N'] = new[] { new double[] { 0, 6, 0, 0, 4, 6, 4, 0 } },
        ['P'] = new[] { new double[] { 0, 6, 0, 0, 3, 0, 4, 1, 4, 2, 3, 3, 0, 3 } },
        ['Q'] = new[] { new double[] { 1, 0, 3, 0, 4, 1, 4, 5, 3, 6, 1, 6, 0, 5, 0, 1, 1, 0 }, new double[] { 2.5, 4.5, 4.2, 6.3 } },
        ['R'] = new[] { new double[] { 0, 6, 0, 0, 3, 0, 4, 1, 4, 2, 3, 3, 0, 3 }, new double[] { 2, 3, 4, 6 } },
        ['S'] = new[] { new double[] { 4, 1, 3, 0, 1, 0, 0, 1, 0, 2, 1, 3, 3, 3, 4, 4, 4, 5, 3, 6, 1, 6, 0, 5 } },
        ['T'] = new[] { new double[] { 0, 0, 4, 0 }, new double[] { 2, 0, 2, 6 } },
        ['U'] = new[] { new double[] { 0, 0, 0, 5, 1, 6, 3, 6, 4, 5, 4, 0 } },
        ['V'] = new[] { new double[] { 0, 0, 2, 6, 4, 0 } },
        ['W'] = new[] { new double[] { 0, 0, 1, 6, 2, 3, 3, 6, 4, 0 } },
        ['X'] = new[] { new double[] { 0, 0, 4, 6 }, new double[] { 4, 0, 0, 6 } },
        ['Y'] = new[] { new double[] { 0, 0, 2, 3, 4, 0 }, new double[] { 2, 3, 2, 6 } },
        ['Z'] = new[] { new double[] { 0, 0, 4, 0, 0, 6, 4, 6 } },
        ['2'] = new[] { new double[] { 0, 1, 1, 0, 3, 0, 4, 1, 4, 2, 0, 6, 4, 6 } },
        ['3'] = new[] { new double[] { 0, 1, 1, 0, 3, 0, 4, 1, 4, 2, 3, 3, 1.5, 3 }, new double[] { 3, 3, 4, 4, 4, 5, 3, 6, 1, 6, 0, 5 } },
        ['4'] = new[] { new double[] { 3, 6, 3, 0, 0, 4, 4, 4 } },
        ['5'] = new[] { new double[] { 4, 0, 0, 0, 0, 3, 3, 3, 4, 4, 4, 5, 3, 6, 1, 6, 0, 5 } },
        ['6'] = new[] { new double[] { 3.5, 0, 1, 0, 0, 1, 0, 5, 1, 6, 3, 6, 4, 5, 4, 4, 3, 3, 0, 3 } },
        ['7'] = new[] { new double[] { 0, 0, 4, 0, 1.5, 6 } },
        ['8'] = new[] { new double[] { 1, 3, 0, 2, 0, 1, 1, 0, 3, 0, 4, 1, 4, 2, 3, 3, 1, 3, 0, 4, 0, 5, 1, 6, 3, 6, 4, 5, 4, 4, 3, 3 } },
        ['9'] = new[] { new double[] { 4, 3, 1, 3, 0, 2, 0, 1, 1, 0, 3, 0, 4, 1, 4, 5, 3, 6, 0.5, 6 } }
    };

    private static string Dibujar(string codigo)
    {
        const int ancho = 200, alto = 64;
        var cultura = System.Globalization.CultureInfo.InvariantCulture;
        var svg = new StringBuilder();
        svg.Append($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{ancho}\" height=\"{alto}\" viewBox=\"0 0 {ancho} {alto}\">");
        svg.Append($"<rect width=\"{ancho}\" height=\"{alto}\" rx=\"8\" fill=\"#f5f7fa\"/>");
        for (var i = 0; i < 40; i++)
        {
            svg.Append($"<circle cx=\"{Azar(0, ancho)}\" cy=\"{Azar(0, alto)}\" r=\"{Azar(1, 2)}\" fill=\"{Color()}\" opacity=\"0.45\"/>");
        }
        for (var i = 0; i < codigo.Length; i++)
        {
            var escala = Azar(60, 72) / 10.0;
            var angulo = Azar(-22, 22) * Math.PI / 180;
            var inclinacion = Azar(-20, 20) / 100.0;
            var centroX = 24 + i * 37 + Azar(-3, 3);
            var centroY = 32 + Azar(-4, 4);
            var color = Color();
            foreach (var trazo in Trazos[codigo[i]])
            {
                var puntos = new List<string>();
                for (var k = 0; k < trazo.Length; k += 2)
                {
                    var x = (trazo[k] - 2) * escala;
                    var y = (trazo[k + 1] - 3) * escala;
                    x += y * inclinacion;
                    var xr = x * Math.Cos(angulo) - y * Math.Sin(angulo) + centroX + Azar(-8, 8) / 10.0;
                    var yr = x * Math.Sin(angulo) + y * Math.Cos(angulo) + centroY + Azar(-8, 8) / 10.0;
                    puntos.Add(xr.ToString("0.#", cultura) + "," + yr.ToString("0.#", cultura));
                }
                svg.Append($"<polyline points=\"{string.Join(' ', puntos)}\" fill=\"none\" stroke=\"{color}\" stroke-width=\"3.4\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>");
            }
        }
        for (var i = 0; i < 5; i++)
        {
            svg.Append($"<path d=\"M{Azar(0, 40)} {Azar(5, alto - 5)} C {Azar(40, 90)} {Azar(0, alto)}, {Azar(110, 160)} {Azar(0, alto)}, {Azar(160, ancho)} {Azar(5, alto - 5)}\" stroke=\"{Color()}\" stroke-width=\"{Azar(1, 2)}\" fill=\"none\" opacity=\"0.6\"/>");
        }
        svg.Append("</svg>");
        return svg.ToString();
    }

    private static int Azar(int desde, int hasta) => RandomNumberGenerator.GetInt32(desde, hasta + 1);

    private static string Color() => new[] { "#133461", "#0e7f89", "#5a7190", "#8a5d00", "#1f2937" }[RandomNumberGenerator.GetInt32(5)];
}
