using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

// Mis postulaciones (Figma › Media · WF 03)
public class PostulacionesController : Controller
{
    public IActionResult Index()
    {
        var modelo = new PostulacionesViewModel
        {
            Activas = DatosDeEjemplo.Postulaciones.Where(p => !p.Archivada).ToList(),
            Archivadas = DatosDeEjemplo.Postulaciones.Where(p => p.Archivada).ToList(),
            Guardadas = DatosDeEjemplo.Ofertas.Where(o => o.Guardada).ToList()
        };
        return View(modelo);
    }
}
