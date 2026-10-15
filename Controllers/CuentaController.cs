using Microsoft.AspNetCore.Mvc;

namespace Workly.Controllers;

public class CuentaController : Controller
{
    public IActionResult IniciarSesion()
    {
        return View();
    }

    public IActionResult CrearCuenta()
    {
        return View();
    }

    public IActionResult RecuperarClave()
    {
        return View();
    }
}
