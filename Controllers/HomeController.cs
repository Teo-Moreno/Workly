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

    // Landing pública (Figma › Alta · Landing)
    public IActionResult Index()
    {
        ViewBag.Coincidencias = DatosDeEjemplo.Coincidencias();
        ViewBag.Empresas = DatosDeEjemplo.Empresas;
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

    // Guía visual del UI Kit (Figma › Guidelines) implementado en HTML/CSS
    public IActionResult UiKit()
    {
        ViewBag.Ofertas = DatosDeEjemplo.Coincidencias(1);
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
