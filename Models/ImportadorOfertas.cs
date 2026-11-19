using System.Globalization;
using System.Text;

namespace Workly.Models;

public class ImportadorOfertas : BackgroundService
{
    private static readonly string[] AliasCiudad =
    {
        "ciudad autonoma de buenos aires", "cdad. autonoma de buenos aires", "cdad autonoma de buenos aires",
        "capital federal", "ciudad de buenos aires", "caba", "buenos aires"
    };

    private readonly IServiceScopeFactory _servicios;
    private readonly ILogger<ImportadorOfertas> _logger;
    private readonly TimeSpan _cadaCuanto;
    private readonly int _paginasPorPais;
    private readonly int _paginasPorProvincia;
    private readonly int _diasParaBorrar;
    private DateTime _proximoIntento = DateTime.MinValue;

    public ImportadorOfertas(IServiceScopeFactory servicios, IConfiguration configuracion, ILogger<ImportadorOfertas> logger)
    {
        _servicios = servicios;
        _logger = logger;
        var seccion = configuracion.GetSection("Importacion");
        _cadaCuanto = TimeSpan.FromHours(seccion.GetValue("HorasEntreImportaciones", 168));
        _paginasPorPais = seccion.GetValue("PaginasPorPais", 3);
        _paginasPorProvincia = seccion.GetValue("PaginasPorProvincia", 1);
        _diasParaBorrar = seccion.GetValue("DiasParaBorrar", 30);
    }

    protected override async Task ExecuteAsync(CancellationToken cancelar)
    {
        try
        {
            await Task.Delay(TimeSpan.FromSeconds(5), cancelar);
            while (!cancelar.IsCancellationRequested)
            {
                await Revisar(cancelar);
                await Task.Delay(TimeSpan.FromHours(1), cancelar);
            }
        }
        catch (OperationCanceledException)
        {
        }
    }

    private async Task Revisar(CancellationToken cancelar)
    {
        if (DateTime.UtcNow < _proximoIntento)
        {
            return;
        }
        try
        {
            using var alcance = _servicios.CreateScope();
            var jsearch = alcance.ServiceProvider.GetRequiredService<JSearch>();
            if (!jsearch.Configurada)
            {
                return;
            }
            var ultima = BD.ObtenerUltimaImportacion();
            if (ultima.HasValue && DateTime.UtcNow - ultima.Value < _cadaCuanto)
            {
                return;
            }
            var guardadas = await Importar(jsearch, cancelar);
            if (guardadas == 0)
            {
                _proximoIntento = DateTime.UtcNow.AddHours(24);
            }
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            _logger.LogWarning(ex, "No se pudieron importar las ofertas de otros sitios");
            _proximoIntento = DateTime.UtcNow.AddHours(24);
        }
    }

    public async Task<int> Importar(JSearch jsearch, CancellationToken cancelar)
    {
        var provincias = BD.ObtenerProvincias();
        var guardadas = 0;
        foreach (var pais in BD.ObtenerPaises())
        {
            var delPais = provincias.Where(p => p.IDPais == pais.ID).ToList();
            var busquedas = new List<(string Lugar, int? IDProvincia, int Paginas)> { (pais.Nombre, null, _paginasPorPais) };
            busquedas.AddRange(delPais.Select(p => (p.Nombre, (int?)p.ID, _paginasPorProvincia)));

            foreach (var (lugar, idProvincia, paginas) in busquedas)
            {
                string? cursor = null;
                for (var pagina = 0; pagina < paginas; pagina++)
                {
                    var resultado = await jsearch.Buscar($"empleos en {lugar}", pais.Codigo_ISO, "month", cursor, cancelar);
                    if (resultado.Error)
                    {
                        if (guardadas == 0)
                        {
                            return 0;
                        }
                        break;
                    }
                    foreach (var oferta in resultado.Ofertas)
                    {
                        oferta.IDPais = pais.ID;
                        oferta.IDProvincia = DetectarProvincia(oferta.Ubicacion, delPais)
                                             ?? (string.IsNullOrWhiteSpace(oferta.Ubicacion) ? idProvincia : null);
                    }
                    BD.GuardarOfertasExternas(resultado.Ofertas);
                    guardadas += resultado.Ofertas.Count;
                    cursor = resultado.Cursor;
                    if (cursor == null)
                    {
                        break;
                    }
                }
            }
        }

        if (guardadas > 0)
        {
            BD.RegistrarImportacion(guardadas);
            var borradas = BD.BorrarOfertasExternasViejas(_diasParaBorrar);
            _logger.LogInformation("Importamos {Guardadas} ofertas de otros sitios y borramos {Borradas} viejas", guardadas, borradas);
        }
        return guardadas;
    }

    public static int? DetectarProvincia(string? ubicacion, List<Provincia> provincias)
    {
        if (string.IsNullOrWhiteSpace(ubicacion))
        {
            return null;
        }
        var ciudad = provincias.FirstOrDefault(p => Normalizar(p.Nombre) == "ciudad autonoma de buenos aires");
        var partes = ubicacion.Split(',').Select(Normalizar).Where(p => p.Length > 0).Reverse().ToList();
        foreach (var parte in partes)
        {
            var sinPrefijo = parte.StartsWith("provincia de ") ? parte["provincia de ".Length..] : parte;
            if (parte.StartsWith("provincia de ") || parte.StartsWith("pcia. de "))
            {
                var nombre = parte[(parte.IndexOf(" de ") + 4)..];
                var deLaProvincia = provincias.FirstOrDefault(p => Normalizar(p.Nombre) == nombre);
                if (deLaProvincia != null)
                {
                    return deLaProvincia.ID;
                }
            }
            if (ciudad != null && AliasCiudad.Contains(sinPrefijo))
            {
                return ciudad.ID;
            }
            var exacta = provincias.FirstOrDefault(p => Normalizar(p.Nombre) == sinPrefijo);
            if (exacta != null)
            {
                return exacta.ID;
            }
        }
        return null;
    }

    private static string Normalizar(string texto)
    {
        var descompuesto = texto.Trim().ToLowerInvariant().Normalize(NormalizationForm.FormD);
        var limpio = new StringBuilder();
        foreach (var letra in descompuesto)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(letra) != UnicodeCategory.NonSpacingMark)
            {
                limpio.Append(letra);
            }
        }
        return limpio.ToString().Normalize(NormalizationForm.FormC);
    }
}
