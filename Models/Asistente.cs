using System.Globalization;
using System.Text;
using System.Text.Json.Nodes;
using Microsoft.Extensions.Caching.Memory;

namespace Workly.Models;

public class MensajeAsistente
{
    public bool EsDelUsuario { get; set; }
    public string Texto { get; set; } = "";
    public List<Oferta> Ofertas { get; set; } = new();
}

public class Asistente
{
    public const int MaximoMensajes = 20;
    public const int LargoMaximo = 500;

    private static readonly string[] ModalidadesValidas = Catalogos.Modalidades;

    private readonly Groq _groq;
    private readonly IMemoryCache _cache;

    public Asistente(Groq groq, IMemoryCache cache)
    {
        _groq = groq;
        _cache = cache;
    }

    public bool Disponible => _groq.Configurada;

    public static string NuevaConversacion() => Guid.NewGuid().ToString("N");

    public List<MensajeAsistente> Conversacion(string? id, int idUsuario) =>
        id != null && _cache.TryGetValue(Clave(id, idUsuario), out List<MensajeAsistente>? mensajes) && mensajes != null
            ? mensajes
            : new List<MensajeAsistente>();

    public async Task<Resultado> Enviar(string id, int idUsuario, string? texto)
    {
        texto = (texto ?? "").Trim();
        if (texto.Length == 0)
        {
            return Resultado.Mal("Escribí qué trabajo buscás.");
        }
        if (texto.Length > LargoMaximo)
        {
            return Resultado.Mal($"Usá hasta {LargoMaximo} caracteres.");
        }
        if (!Disponible)
        {
            return Resultado.Mal("El asistente no está disponible en este momento.");
        }
        var mensajes = Conversacion(id, idUsuario);
        if (mensajes.Count >= MaximoMensajes)
        {
            return Resultado.Mal("Esta conversación ya es muy larga. Empezá una nueva.", "advertencia");
        }

        var pedido = new JsonArray { new JsonObject { ["role"] = "system", ["content"] = Instrucciones(idUsuario) } };
        foreach (var m in mensajes)
        {
            pedido.Add(new JsonObject { ["role"] = m.EsDelUsuario ? "user" : "assistant", ["content"] = m.Texto });
        }
        pedido.Add(new JsonObject { ["role"] = "user", ["content"] = texto });

        var encontradas = new List<Oferta>();
        string? respuesta = null;
        using var limite = new CancellationTokenSource(TimeSpan.FromSeconds(60));
        for (var vuelta = 0; vuelta < 3 && respuesta == null; vuelta++)
        {
            var mensaje = await _groq.Responder(pedido, Herramientas(), false, limite.Token);
            if (mensaje == null)
            {
                return Resultado.Mal("No pudimos contestarte en este momento. Probá de nuevo en un rato.");
            }
            if (mensaje["tool_calls"] is JsonArray llamadas && llamadas.Count > 0)
            {
                pedido.Add(new JsonObject
                {
                    ["role"] = "assistant",
                    ["content"] = mensaje["content"]?.DeepClone(),
                    ["tool_calls"] = llamadas.DeepClone()
                });
                foreach (var llamada in llamadas.OfType<JsonObject>())
                {
                    var ofertas = Buscar(llamada["function"]?["arguments"]?.GetValue<string>(), idUsuario);
                    encontradas.AddRange(ofertas.Where(o => encontradas.All(e => e.Clave != o.Clave)));
                    pedido.Add(new JsonObject
                    {
                        ["role"] = "tool",
                        ["tool_call_id"] = llamada["id"]?.GetValue<string>(),
                        ["content"] = new JsonArray(ofertas.Select(o => (JsonNode)new JsonObject
                        {
                            ["codigo"] = o.Clave,
                            ["titulo"] = o.Titulo,
                            ["empresa"] = o.Empresa,
                            ["ubicacion"] = o.UbicacionVisible,
                            ["modalidad"] = o.Modalidad,
                            ["tipo"] = o.Tipo_Contrato,
                            ["fuente"] = o.Fuente
                        }).ToArray()).ToJsonString()
                    });
                }
            }
            else
            {
                respuesta = mensaje["content"]?.GetValue<string>()?.Trim();
            }
        }
        if (string.IsNullOrEmpty(respuesta))
        {
            return Resultado.Mal("No pudimos contestarte en este momento. Probá de nuevo en un rato.");
        }

        var mencionadas = encontradas.Where(o => respuesta.Contains(o.Titulo, StringComparison.OrdinalIgnoreCase) || respuesta.Contains(o.Clave)).ToList();
        mensajes.Add(new MensajeAsistente { EsDelUsuario = true, Texto = texto });
        mensajes.Add(new MensajeAsistente
        {
            Texto = QuitarCodigos(respuesta),
            Ofertas = (mencionadas.Count > 0 ? mencionadas : encontradas).Take(5).ToList()
        });
        _cache.Set(Clave(id, idUsuario), mensajes, TimeSpan.FromHours(2));
        return Resultado.Bien("");
    }

    private static string Clave(string id, int idUsuario) => $"asistente:{idUsuario}:{id}";

    private static string Instrucciones(int idUsuario)
    {
        var texto = new StringBuilder(
            "Sos el asistente de Workly, una página de empleo de Argentina. Tu tarea es recomendar trabajos. " +
            "Respondé en español rioplatense (usando vos), en pocas oraciones y sin formato markdown. " +
            "Para recomendar trabajos usá siempre la herramienta buscar_ofertas; podés llamarla más de una vez con palabras distintas. " +
            "Recomendá solo ofertas que haya devuelto la herramienta y nombralas con su título exacto. Nunca inventes ofertas, empresas ni datos. " +
            "Si no encontrás nada, decilo y sugerí otra forma de buscar. Si te preguntan algo que no tiene que ver con buscar trabajo, " +
            "explicá amablemente que solo ayudás con eso. ");
        var perfil = idUsuario == 0 ? null : BD.ObtenerMiPerfil(idUsuario);
        if (perfil != null && perfil.Usuario.Tipo == Usuario.TipoPersona)
        {
            var provincia = BD.ObtenerProvincias().FirstOrDefault(p => p.ID == (perfil.Preferencia.IDProvincia ?? perfil.Perfil.IDProvincia));
            var datos = new List<string>();
            if (!string.IsNullOrWhiteSpace(perfil.Preferencia.Puesto_Buscado)) datos.Add($"busca trabajo de {perfil.Preferencia.Puesto_Buscado}");
            if (provincia != null) datos.Add($"vive o busca en {provincia.Nombre}");
            if (perfil.Preferencia.ListaModalidades.Count > 0) datos.Add($"prefiere modalidad {string.Join(" o ", perfil.Preferencia.ListaModalidades)}");
            if (perfil.Habilidades.Count > 0) datos.Add($"sus habilidades son {string.Join(", ", perfil.Habilidades.Take(15))}");
            if (perfil.Experiencias.Count > 0) datos.Add($"trabajó de {string.Join(", ", perfil.Experiencias.Take(5).Select(e => e.Puesto))}");
            if (datos.Count > 0)
            {
                texto.Append($"Datos del perfil de la persona, {perfil.Usuario.Nombre}: {string.Join("; ", datos)}. Usalos si no te dice otra cosa.");
            }
        }
        return texto.ToString();
    }

    private static JsonArray Herramientas() => new()
    {
        new JsonObject
        {
            ["type"] = "function",
            ["function"] = new JsonObject
            {
                ["name"] = "buscar_ofertas",
                ["description"] = "Busca ofertas de trabajo vigentes en la base de Workly. Devuelve hasta 8 ofertas.",
                ["parameters"] = new JsonObject
                {
                    ["type"] = "object",
                    ["properties"] = new JsonObject
                    {
                        ["texto"] = new JsonObject { ["type"] = "string", ["description"] = "Puesto o palabra clave, por ejemplo \"vendedor\" o \"programador\". Una o dos palabras." },
                        ["provincia"] = new JsonObject { ["type"] = "string", ["description"] = "Provincia argentina, por ejemplo \"Córdoba\". Vacío para todo el país." },
                        ["modalidad"] = new JsonObject { ["type"] = "string", ["enum"] = new JsonArray(ModalidadesValidas.Select(m => (JsonNode)m).ToArray()) }
                    },
                    ["required"] = new JsonArray("texto")
                }
            }
        }
    };

    private static List<Oferta> Buscar(string? argumentos, int idUsuario)
    {
        JsonObject? datos = null;
        try
        {
            datos = string.IsNullOrWhiteSpace(argumentos) ? null : JsonNode.Parse(argumentos) as JsonObject;
        }
        catch (System.Text.Json.JsonException)
        {
        }
        var texto = Valor(datos?["texto"]);
        var nombreProvincia = Valor(datos?["provincia"]);
        var modalidad = ModalidadesValidas.FirstOrDefault(m => Igual(m, Valor(datos?["modalidad"]) ?? ""));
        var provincia = nombreProvincia == null ? null : BD.ObtenerProvincias().FirstOrDefault(p => Igual(p.Nombre, nombreProvincia));
        return BD.BuscarOfertas(new FiltrosOfertas
        {
            Texto = texto,
            IDPais = provincia?.IDPais,
            IDProvincia = provincia?.ID,
            Modalidades = modalidad == null ? new List<string>() : new List<string> { modalidad },
            Cantidad = 8
        }, idUsuario);
    }

    private static string? Valor(JsonNode? nodo) =>
        nodo is JsonValue v && v.TryGetValue<string>(out var s) && !string.IsNullOrWhiteSpace(s) ? s.Trim() : null;

    private static bool Igual(string a, string b) =>
        string.Compare(a.Trim(), b.Trim(), CultureInfo.GetCultureInfo("es-AR"), CompareOptions.IgnoreCase | CompareOptions.IgnoreNonSpace) == 0;

    private static string QuitarCodigos(string texto) =>
        System.Text.RegularExpressions.Regex.Replace(texto, @"\s*\((?:código\s*)?[wx]\d+\)", "").Trim();
}
