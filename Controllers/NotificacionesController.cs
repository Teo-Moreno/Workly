using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

public class NotificacionesController : Controller
{
    public IActionResult Index()
    {
        return View(DatosDeEjemplo.Notificaciones);
    }
}
