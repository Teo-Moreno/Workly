using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

public class EmpresasController : Controller
{
    // Empresas (Figma › Media · WF 04)
    public IActionResult Index()
    {
        return View(DatosDeEjemplo.Empresas);
    }

    // Perfil de empresa + ofertas disponibles (mapa de sitio en Miro)
    public IActionResult Detalle(int id)
    {
        var empresa = DatosDeEjemplo.ObtenerEmpresa(id);
        if (empresa == null)
        {
            return NotFound();
        }

        var modelo = new EmpresaDetalleViewModel
        {
            Empresa = empresa,
            Ofertas = DatosDeEjemplo.OfertasDeEmpresa(id)
        };
        return View(modelo);
    }
}
