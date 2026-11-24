using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;

namespace Workly.Models;

public class Groq
{
    private readonly HttpClient _http;
    private readonly ILogger<Groq> _logger;
    private readonly string? _clave;
    private readonly string _modelo;

    private static readonly string[] ModelosPreferidos = { "openai/gpt-oss-120b", "qwen/qwen3.6-27b", "openai/gpt-oss-20b", "llama-3.1-8b-instant" };
    private static readonly string[] ModelosQueNoSirven = { "whisper", "guard", "tts", "orpheus", "compound", "embed" };
    private static string? _modeloDeReemplazo;

    public Groq(HttpClient http, IConfiguration configuracion, ILogger<Groq> logger)
    {
        _http = http;
        _logger = logger;
        _clave = configuracion["Groq:ApiKey"];
        _modelo = string.IsNullOrWhiteSpace(configuracion["Groq:Modelo"]) ? ModelosPreferidos[0] : configuracion["Groq:Modelo"]!.Trim();
        var direccion = configuracion["Groq:Url"];
        _http.BaseAddress = new Uri(string.IsNullOrWhiteSpace(direccion) ? "https://api.groq.com/openai/v1/" : direccion.TrimEnd('/') + "/");
        _http.Timeout = TimeSpan.FromSeconds(40);
    }

    public bool Configurada => !string.IsNullOrWhiteSpace(_clave);

    public async Task<JsonObject?> Responder(JsonArray mensajes, JsonArray? herramientas, bool soloJson, CancellationToken cancelar)
    {
        if (!Configurada)
        {
            return null;
        }
        var modelo = _modeloDeReemplazo ?? _modelo;
        var respuesta = await Pedir(modelo, mensajes, herramientas, soloJson, cancelar);
        if (respuesta.ModeloNoExiste && await BuscarReemplazo(modelo, cancelar) is { } reemplazo)
        {
            respuesta = await Pedir(reemplazo, mensajes, herramientas, soloJson, cancelar);
        }
        return respuesta.Mensaje;
    }

    private async Task<(JsonObject? Mensaje, bool ModeloNoExiste)> Pedir(string modelo, JsonArray mensajes, JsonArray? herramientas, bool soloJson,
                                                                       CancellationToken cancelar)
    {
        var cuerpo = new JsonObject
        {
            ["model"] = modelo,
            ["messages"] = mensajes.DeepClone(),
            ["temperature"] = 0.2
        };
        if (herramientas != null)
        {
            cuerpo["tools"] = herramientas.DeepClone();
        }
        if (soloJson)
        {
            cuerpo["response_format"] = new JsonObject { ["type"] = "json_object" };
        }
        try
        {
            using var pedido = new HttpRequestMessage(HttpMethod.Post, "chat/completions")
            {
                Content = new StringContent(cuerpo.ToJsonString(), Encoding.UTF8, "application/json")
            };
            pedido.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _clave);
            using var respuesta = await _http.SendAsync(pedido, cancelar);
            var texto = await respuesta.Content.ReadAsStringAsync(cancelar);
            if (!respuesta.IsSuccessStatusCode)
            {
                _logger.LogWarning("Groq respondió {Codigo}: {Texto}", (int)respuesta.StatusCode, texto.Length > 300 ? texto[..300] : texto);
                var noExiste = texto.Contains("model_not_found") || texto.Contains("model_decommissioned") || texto.Contains("decommissioned");
                return (null, noExiste);
            }
            return (JsonNode.Parse(texto)?["choices"]?[0]?["message"]?.AsObject(), false);
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or JsonException or InvalidOperationException)
        {
            _logger.LogWarning(ex, "No se pudo consultar Groq");
            return (null, false);
        }
    }

    private async Task<string?> BuscarReemplazo(string modeloQueFallo, CancellationToken cancelar)
    {
        try
        {
            using var pedido = new HttpRequestMessage(HttpMethod.Get, "models");
            pedido.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _clave);
            using var respuesta = await _http.SendAsync(pedido, cancelar);
            if (!respuesta.IsSuccessStatusCode)
            {
                return null;
            }
            var datos = JsonNode.Parse(await respuesta.Content.ReadAsStringAsync(cancelar))?["data"] as JsonArray;
            var disponibles = datos?.OfType<JsonObject>()
                .Where(m => m["active"]?.GetValue<bool>() != false)
                .Select(m => m["id"]?.GetValue<string>())
                .OfType<string>()
                .Where(id => id != modeloQueFallo && !ModelosQueNoSirven.Any(id.Contains))
                .ToList() ?? new List<string>();
            var elegido = ModelosPreferidos.FirstOrDefault(disponibles.Contains) ?? disponibles.FirstOrDefault();
            if (elegido != null)
            {
                _logger.LogWarning("El modelo {Modelo} de Groq no está disponible. Usamos {Reemplazo}. Conviene cambiar Groq:Modelo.", modeloQueFallo, elegido);
                _modeloDeReemplazo = elegido;
            }
            return elegido;
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or JsonException or InvalidOperationException)
        {
            _logger.LogWarning(ex, "No se pudo consultar la lista de modelos de Groq");
            return null;
        }
    }

    public async Task<JsonObject?> ResponderJson(string instrucciones, string contenido, CancellationToken cancelar)
    {
        var mensajes = new JsonArray
        {
            new JsonObject { ["role"] = "system", ["content"] = instrucciones },
            new JsonObject { ["role"] = "user", ["content"] = contenido }
        };
        var mensaje = await Responder(mensajes, null, true, cancelar);
        var texto = mensaje?["content"]?.GetValue<string>();
        if (string.IsNullOrWhiteSpace(texto))
        {
            return null;
        }
        try
        {
            return JsonNode.Parse(texto) as JsonObject;
        }
        catch (JsonException)
        {
            return null;
        }
    }
}
