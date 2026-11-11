using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

public class EmpresasController : Controller
{
    public IActionResult Index(EmpresasViewModel filtros)
    {
        var modelo = filtros;
        modelo.Q = Validaciones.Limpiar(modelo.Q);
        modelo.Paises = BD.ObtenerPaises();
        modelo.Provincias = BD.ObtenerProvincias();

        if (!Request.Query.ContainsKey(nameof(modelo.IDProvincia)) && User.EsPersona())
        {
            var perfil = BD.ObtenerPerfil(User.IdUsuario());
            modelo.IDPais = perfil?.IDPais;
            modelo.IDProvincia = perfil?.IDProvincia;
        }
        modelo.IDPais = modelo.Paises.FirstOrDefault(p => p.ID == modelo.IDPais)?.ID ?? modelo.Paises.FirstOrDefault()?.ID;
        modelo.IDProvincia = modelo.Provincias.FirstOrDefault(p => p.ID == modelo.IDProvincia && p.IDPais == modelo.IDPais)?.ID;
        if (!Catalogos.Ordenes.Any(o => o.Valor == modelo.Orden)) modelo.Orden = "recientes";

        ViewBag.Q = modelo.Q;
        ViewBag.IDPais = modelo.IDPais;
        ViewBag.IDProvincia = modelo.IDProvincia;
        ViewBag.Orden = modelo.Orden;
        ViewBag.Paises = modelo.Paises;
        ViewBag.Provincias = modelo.Provincias;
        ViewBag.Filtrando = modelo.Q != null || modelo.IDProvincia != null;
        ViewBag.Empresas = BD.BuscarEmpresas(modelo.Q, null, modelo.IDPais, modelo.IDProvincia, modelo.Orden);
        return View();
    }

    public IActionResult Detalle(int id)
    {
        var empresa = BD.ObtenerEmpresa(id);
        if (empresa == null)
        {
            return NotFound();
        }
        var esPropia = User.EsEmpresa() && empresa.IDUsuario == User.IdUsuario();
        ViewBag.Empresa = empresa;
        ViewBag.Abiertas = BD.ObtenerOfertasDeEmpresa(id, User.IdUsuario()).Where(o => !o.EstaCerrada).ToList();
        ViewBag.EsPropia = esPropia;
        return View();
    }
}
