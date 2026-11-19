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

    public Groq(HttpClient http, IConfiguration configuracion, ILogger<Groq> logger)
    {
        _http = http;
        _logger = logger;
        _clave = configuracion["Groq:ApiKey"];
        _modelo = string.IsNullOrWhiteSpace(configuracion["Groq:Modelo"]) ? "llama-3.3-70b-versatile" : configuracion["Groq:Modelo"]!;
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
        var cuerpo = new JsonObject
        {
            ["model"] = _modelo,
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
                return null;
            }
            return JsonNode.Parse(texto)?["choices"]?[0]?["message"]?.AsObject();
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or JsonException or InvalidOperationException)
        {
            _logger.LogWarning(ex, "No se pudo consultar Groq");
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
