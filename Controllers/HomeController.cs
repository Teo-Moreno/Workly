using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    public HomeController(ILogger<HomeController> logger)
    {
        _logger = logger;
    }

    public IActionResult Index()
    {
        ViewBag.Puestos = Empleos.PuestosParaAnimacion();
        ViewBag.Empresas = BD.ObtenerEmpresasConBusquedas(12);
        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    public IActionResult Terminos()
    {
        return View();
    }

    public IActionResult Cookies()
    {
        return View();
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public IActionResult AceptarCookies(string? volver)
    {
        Response.Cookies.Append("Workly.Cookies", "ok", new CookieOptions
        {
            MaxAge = TimeSpan.FromDays(365),
            IsEssential = true,
            SameSite = SameSiteMode.Lax,
            Secure = Request.IsHttps
        });
        return !string.IsNullOrEmpty(volver) && Url.IsLocalUrl(volver) ? LocalRedirect(volver) : RedirectToAction(nameof(Index));
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        ViewBag.CodigoSolicitud = Activity.Current?.Id ?? HttpContext.TraceIdentifier;
        return View();
    }
}
