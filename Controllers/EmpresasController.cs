using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

// Empresas con cuenta en Workly o con búsquedas publicadas. Se puede ver sin iniciar sesión.
public class EmpresasController : Controller
{
    public IActionResult Index(EmpresasViewModel filtros)
    {
        var modelo = filtros;
        modelo.Q = Validaciones.Limpiar(modelo.Q);
        modelo.Paises = BD.ObtenerPaises();
        modelo.Provincias = BD.ObtenerProvincias();

        // Ubicación: la primera vez se usa la provincia de la persona; después, la que elija
        if (!Request.Query.ContainsKey(nameof(modelo.IDProvincia)) && User.EsPersona())
        {
            var perfil = BD.ObtenerPerfil(User.IdUsuario());
            modelo.IDPais = perfil?.IDPais;
            modelo.IDProvincia = perfil?.IDProvincia;
        }
        modelo.IDPais = modelo.Paises.FirstOrDefault(p => p.ID == modelo.IDPais)?.ID ?? modelo.Paises.FirstOrDefault()?.ID;
        modelo.IDProvincia = modelo.Provincias.FirstOrDefault(p => p.ID == modelo.IDProvincia && p.IDPais == modelo.IDPais)?.ID;
        if (!Catalogos.Ordenes.Any(o => o.Valor == modelo.Orden)) modelo.Orden = "recientes";

        modelo.Empresas = BD.BuscarEmpresas(modelo.Q, null, modelo.IDPais, modelo.IDProvincia, modelo.Orden);
        return View(modelo);
    }

    public IActionResult Detalle(int id)
    {
        var empresa = BD.ObtenerEmpresa(id);
        if (empresa == null)
        {
            return NotFound();
        }
        var esPropia = User.EsEmpresa() && empresa.IDUsuario == User.IdUsuario();
        return View(new EmpresaDetalleViewModel
        {
            Empresa = empresa,
            Ofertas = BD.ObtenerOfertasDeEmpresa(id, User.IdUsuario()),
            EsPropia = esPropia
        });
    }
}
