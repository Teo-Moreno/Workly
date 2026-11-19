namespace Workly.Models;

public class OfertaParaResumen
{
    public int ID { get; set; }
    public string Titulo { get; set; } = "";
    public string Email { get; set; } = "";
    public string Nombre { get; set; } = "";
    public DateTime Desde { get; set; }
    public int Total { get; set; }
}

public class ResumenPostulaciones : BackgroundService
{
    public const int DiasEntreResumenes = 15;

    private readonly Correo _correo;
    private readonly ILogger<ResumenPostulaciones> _logger;
    private readonly string? _sitio;

    public ResumenPostulaciones(Correo correo, IConfiguration configuracion, ILogger<ResumenPostulaciones> logger)
    {
        _correo = correo;
        _logger = logger;
        _sitio = configuracion["Sitio:Url"]?.TrimEnd('/');
    }

    protected override async Task ExecuteAsync(CancellationToken cancelar)
    {
        try
        {
            await Task.Delay(TimeSpan.FromSeconds(10), cancelar);
            while (!cancelar.IsCancellationRequested)
            {
                await Enviar(cancelar);
                await Task.Delay(TimeSpan.FromHours(1), cancelar);
            }
        }
        catch (OperationCanceledException)
        {
        }
    }

    private async Task Enviar(CancellationToken cancelar)
    {
        if (!_correo.Configurado)
        {
            return;
        }
        try
        {
            foreach (var oferta in BD.ObtenerOfertasParaResumen(DiasEntreResumenes))
            {
                cancelar.ThrowIfCancellationRequested();
                var nuevos = BD.ObtenerPostulantes(oferta.ID, oferta.Desde.Date);
                var mejor = nuevos.OrderByDescending(p => p.Puntaje).ThenBy(p => p.Fecha).FirstOrDefault();
                var enlace = string.IsNullOrEmpty(_sitio) ? null : $"{_sitio}/Publicaciones/Detalle/{oferta.ID}";
                if (await _correo.EnviarResumen(oferta, nuevos.Count, mejor, enlace))
                {
                    BD.MarcarResumenEnviado(oferta.ID);
                }
            }
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            _logger.LogWarning(ex, "No se pudieron enviar los resúmenes de postulaciones");
        }
    }
}
