using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class NotificacionesController : Controller
{
    public IActionResult Index()
    {
        return View(DatosDeEjemplo.Notificaciones);
    }
}
