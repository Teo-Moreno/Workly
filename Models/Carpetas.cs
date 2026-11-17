namespace Workly.Models;

public class Carpetas
{
    public string Publica { get; set; } = "";
    public string Raiz { get; set; } = "";

    public static Carpetas Desde(IWebHostEnvironment entorno) => new() { Publica = entorno.WebRootPath, Raiz = entorno.ContentRootPath };
}
