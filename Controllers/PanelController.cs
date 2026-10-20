using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

// "Inicio" de la persona logueada
[Authorize]
public class PanelController : Controller
{
    public IActionResult Index()
    {
        var modelo = new PanelViewModel
        {
            Coincidencias = DatosDeEjemplo.Coincidencias(),
            Entrevistas = DatosDeEjemplo.Postulaciones
                .Where(p => p.Estado == EstadoPostulacion.Entrevista && !p.Archivada)
                .ToList(),
            EmpresasSugeridas = DatosDeEjemplo.Empresas.Take(3).ToList()
        };
        return View(modelo);
    }
}
