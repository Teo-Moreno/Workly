using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

public class EmpresasController : Controlador
{
    public EmpresasController() : base("_LayoutApp")
    {
    }

    public IActionResult Index(EmpresasViewModel filtros)
    {
        var modelo = Directorio.Buscar(filtros, Request.Query.ContainsKey(nameof(filtros.IDProvincia)), User.IdUsuario(), User.EsPersona());
        ViewBag.Q = modelo.Q;
        ViewBag.IDPais = modelo.IDPais;
        ViewBag.IDProvincia = modelo.IDProvincia;
        ViewBag.Orden = modelo.Orden;
        ViewBag.Paises = modelo.Paises;
        ViewBag.Provincias = modelo.Provincias;
        ViewBag.Filtrando = modelo.Q != null || modelo.IDProvincia != null;
        ViewBag.Empresas = modelo.Empresas;
        ViewBag.TextoCargando = "Buscando empresas…";
        return View();
    }

    public IActionResult Detalle(int id)
    {
        var detalle = Directorio.Detalle(id, User.IdUsuario(), User.EsEmpresa());
        if (detalle == null)
        {
            return NotFound();
        }
        ViewBag.Empresa = detalle.Value.Empresa;
        ViewBag.Abiertas = detalle.Value.Abiertas;
        ViewBag.EsPropia = detalle.Value.EsPropia;
        return View();
    }
}
