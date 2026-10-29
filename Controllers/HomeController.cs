using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

public class HomeController : Controller
{
    private readonly ILogger<HomeController> _logger;
    private readonly JSearch _jsearch;

    public HomeController(ILogger<HomeController> logger, JSearch jsearch)
    {
        _logger = logger;
        _jsearch = jsearch;
    }

    public async Task<IActionResult> Index()
    {
        return View(new LandingViewModel
        {
            Puestos = await _jsearch.PuestosParaAnimacion(),
            Empresas = BD.ObtenerEmpresasConBusquedas(12)
        });
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

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
