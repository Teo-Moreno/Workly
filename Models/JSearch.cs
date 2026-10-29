using System.Text.Json;
using Microsoft.Extensions.Caching.Memory;

namespace Workly.Models;

public class JSearch
{
    private const string Host = "jsearch.p.rapidapi.com";
    private static readonly TimeSpan DuracionBusqueda = TimeSpan.FromHours(6);
    private static readonly TimeSpan DuracionAnimacion = TimeSpan.FromHours(24);

    private readonly HttpClient _http;
    private readonly IMemoryCache _cache;
    private readonly ILogger<JSearch> _logger;
    private readonly string? _clave;

    public JSearch(HttpClient http, IMemoryCache cache, IConfiguration configuracion, ILogger<JSearch> logger)
    {
        _http = http;
        _cache = cache;
        _logger = logger;
        _clave = configuracion["JSearch:ApiKey"];
        _http.BaseAddress = new Uri($"https://{Host}/");
        _http.Timeout = TimeSpan.FromSeconds(20);
    }

    public bool Configurada => !string.IsNullOrWhiteSpace(_clave);

    public class Resultado
    {
        public List<Oferta> Ofertas { get; set; } = new();
        public string? Cursor { get; set; }

        public bool Error { get; set; }
    }

    public async Task<Resultado> Buscar(string consulta, string pais, bool soloRemoto, IEnumerable<string> tiposEmpleo,
                                        string? fecha, string? cursor)
    {
        if (!Configurada || string.IsNullOrWhiteSpace(consulta))
        {
            return new Resultado { Error = !Configurada };
        }

        var parametros = new Dictionary<string, string?>
        {
            ["query"] = consulta.Trim(),
            ["country"] = pais,
            ["num_pages"] = "1",
            ["date_posted"] = string.IsNullOrEmpty(fecha) ? "all" : fecha,
            ["work_from_home"] = soloRemoto ? "true" : null,
            ["employment_types"] = tiposEmpleo.Any() ? string.Join(",", tiposEmpleo) : null,
            ["cursor"] = cursor
        };
        var url = "search-v2?" + string.Join("&", parametros.Where(p => !string.IsNullOrEmpty(p.Value))
                                                             .Select(p => $"{p.Key}={Uri.EscapeDataString(p.Value!)}"));

        if (_cache.TryGetValue(url, out (List<OfertaExternaDatos> Ofertas, string? Cursor) enMemoria))
        {
            return new Resultado { Ofertas = BD.GuardarOfertasExternas(enMemoria.Ofertas), Cursor = enMemoria.Cursor };
        }

        try
        {
            using var pedido = new HttpRequestMessage(HttpMethod.Get, url);
            pedido.Headers.Add("x-rapidapi-key", _clave);
            pedido.Headers.Add("x-rapidapi-host", Host);
            using var respuesta = await _http.SendAsync(pedido);
            if (!respuesta.IsSuccessStatusCode)
            {
                _logger.LogWarning("JSearch respondió {Codigo} para {Url}", (int)respuesta.StatusCode, url);
                return new Resultado { Error = true };
            }

            using var json = JsonDocument.Parse(await respuesta.Content.ReadAsStreamAsync());
            var datos = json.RootElement.GetProperty("data");
            var trabajos = datos.ValueKind == JsonValueKind.Object && datos.TryGetProperty("jobs", out var lista) ? lista : datos;
            var ofertas = trabajos.ValueKind == JsonValueKind.Array
                ? trabajos.EnumerateArray().Select(Leer).Where(o => o != null).Select(o => o!).ToList()
                : new List<OfertaExternaDatos>();
            var siguiente = datos.ValueKind == JsonValueKind.Object && datos.TryGetProperty("cursor", out var c) && c.ValueKind == JsonValueKind.String
                ? c.GetString()
                : null;

            var cursorSiguiente = ofertas.Count > 0 ? siguiente : null;
            _cache.Set(url, (ofertas, cursorSiguiente), DuracionBusqueda);
            return new Resultado { Ofertas = BD.GuardarOfertasExternas(ofertas), Cursor = cursorSiguiente };
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or JsonException or KeyNotFoundException)
        {
            _logger.LogWarning(ex, "No se pudo consultar JSearch");
            return new Resultado { Error = true };
        }
    }

    public async Task<List<string>> PuestosParaAnimacion()
    {
        if (_cache.TryGetValue("animacion", out List<string>? puestos) && puestos != null)
        {
            return puestos;
        }

        var resultado = await Buscar("empleos en Argentina", "ar", false, Array.Empty<string>(), "week", null);
        puestos = resultado.Ofertas.Select(o => Textos.Recortar(o.Titulo, 48)).ToList();
        if (puestos.Count == 0)
        {
            puestos = BD.ObtenerTitulosRecientes(10);
        }
        puestos = puestos.Where(t => t.Length > 2).Distinct(StringComparer.OrdinalIgnoreCase).Take(8).ToList();
        if (puestos.Count > 0)
        {
            _cache.Set("animacion", puestos, DuracionAnimacion);
        }
        return puestos;
    }

    private static OfertaExternaDatos? Leer(JsonElement j)
    {
        var id = Texto(j, "job_id");
        var titulo = Texto(j, "job_title");
        if (string.IsNullOrWhiteSpace(id) || string.IsNullOrWhiteSpace(titulo))
        {
            return null;
        }

        var tipo = Texto(j, "job_employment_type");
        if (j.TryGetProperty("job_employment_types", out var tipos) && tipos.ValueKind == JsonValueKind.Array && tipos.GetArrayLength() > 0)
        {
            tipo = tipos[0].GetString();
        }

        var ubicacion = Texto(j, "job_location");
        if (string.IsNullOrWhiteSpace(ubicacion))
        {
            ubicacion = string.Join(", ", new[] { Texto(j, "job_city"), Texto(j, "job_state") }.Where(t => !string.IsNullOrWhiteSpace(t)));
        }
        ubicacion = System.Text.RegularExpressions.Regex.Replace(ubicacion ?? "", @"\s*[•·]\s*a través de .*$", "").Trim();

        return new OfertaExternaDatos
        {
            ID_Externo = Recortar(id, 200)!,
            Titulo = Recortar(titulo, 300)!,
            Empresa = Recortar(Texto(j, "employer_name"), 200),
            Logo = Recortar(Texto(j, "employer_logo"), 1000),
            Ubicacion = Recortar(ubicacion, 200),
            Descripcion = Texto(j, "job_description"),
            Es_Remoto = j.TryGetProperty("job_is_remote", out var remoto) && remoto.ValueKind == JsonValueKind.True,
            Tipo_Contrato = Catalogos.TiposEmpleo.FirstOrDefault(t => string.Equals(t.JSearch, tipo?.Replace("-", "").Replace(" ", ""), StringComparison.OrdinalIgnoreCase)).Nombre,
            Salario = Recortar(Texto(j, "job_salary_string") ?? Texto(j, "job_salary"), 100),
            Link_Postulacion = Recortar(Texto(j, "job_apply_link"), 2000),
            Publicador = Recortar(Texto(j, "job_publisher"), 100),
            Fecha_Publicacion = DateTime.TryParse(Texto(j, "job_posted_at_datetime_utc"), out var fecha) ? fecha : null
        };
    }

    private static string? Texto(JsonElement j, string propiedad) =>
        j.TryGetProperty(propiedad, out var valor) && valor.ValueKind == JsonValueKind.String ? valor.GetString() : null;

    private static string? Recortar(string? texto, int largo) =>
        texto == null ? null : texto.Length <= largo ? texto : texto[..largo];
}

public class OfertaExternaDatos
{
    public string ID_Externo { get; set; } = "";
    public string Titulo { get; set; } = "";
    public string? Empresa { get; set; }
    public string? Logo { get; set; }
    public string? Ubicacion { get; set; }
    public string? Descripcion { get; set; }
    public bool Es_Remoto { get; set; }
    public string? Tipo_Contrato { get; set; }
    public string? Salario { get; set; }
    public string? Link_Postulacion { get; set; }
    public string? Publicador { get; set; }
    public DateTime? Fecha_Publicacion { get; set; }
}
