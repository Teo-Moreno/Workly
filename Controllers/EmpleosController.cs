using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

public class EmpleosController : Controller
{
    // Buscar trabajo (Figma › Media · WF 02)
    public IActionResult Index(int? id, string? q)
    {
        var ofertas = DatosDeEjemplo.Ofertas;
        var modelo = new BuscarTrabajoViewModel
        {
            Ofertas = ofertas,
            Seleccionada = (id.HasValue ? DatosDeEjemplo.ObtenerOferta(id.Value) : null) ?? ofertas[0],
            Busqueda = string.IsNullOrWhiteSpace(q) ? "Frontend Developer" : q
        };
        return View(modelo);
    }

    // Detalle de oferta (Figma › Media · 06, 07 y 08)
    public IActionResult Detalle(int id)
    {
        var oferta = DatosDeEjemplo.ObtenerOferta(id);
        if (oferta == null)
        {
            return NotFound();
        }

        var modelo = new OfertaDetalleViewModel
        {
            Oferta = oferta,
            Empresa = DatosDeEjemplo.ObtenerEmpresa(oferta.EmpresaId) ?? new Empresa(),
            Similares = DatosDeEjemplo.Similares(oferta)
        };
        return View(modelo);
    }
}
