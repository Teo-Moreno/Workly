using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

public class HomeController : Controlador
{
    private readonly ILogger<HomeController> _logger;
    public HomeController(ILogger<HomeController> logger) : base("_Layout")
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

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        ViewBag.CodigoSolicitud = Activity.Current?.Id ?? HttpContext.TraceIdentifier;
        return View();
    }
}
