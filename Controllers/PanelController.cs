using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

[Authorize]
public class PanelController : Controller
{
    private readonly JSearch _jsearch;

    public PanelController(JSearch jsearch)
    {
        _jsearch = jsearch;
    }

    public IActionResult Index()
    {
        if (User.EsEmpresa())
        {
            return RedirectToAction("Index", "Publicaciones");
        }

        var perfil = BD.ObtenerMiPerfil(User.IdUsuario());
        if (perfil == null)
        {
            return RedirectToAction("IniciarSesion", "Cuenta");
        }

        ViewBag.Perfil = perfil;
        ViewBag.Puesto = perfil.Preferencia.Puesto_Buscado;
        ViewBag.UrlParaVos = Url.Action(nameof(ParaVos));
        return View();
    }

    public async Task<IActionResult> ParaVos()
    {
        var perfil = User.EsPersona() ? BD.ObtenerMiPerfil(User.IdUsuario()) : null;
        var puesto = perfil?.Preferencia.Puesto_Buscado;
        ViewBag.Puesto = puesto;
        ViewBag.ErrorExternas = false;
        ViewBag.ParaVos = new List<Oferta>();
        if (perfil != null && !string.IsNullOrWhiteSpace(puesto))
        {
            var idProvincia = perfil.Preferencia.IDProvincia ?? perfil.Perfil.IDProvincia;
            var provincias = BD.ObtenerProvincias();
            var provincia = provincias.FirstOrDefault(p => p.ID == idProvincia);
            var pais = BD.ObtenerPaises().FirstOrDefault(p => p.ID == (provincia?.IDPais ?? perfil.Perfil.IDPais)) ?? BD.ObtenerPaises().FirstOrDefault();
            var modalidades = perfil.Preferencia.ListaModalidades;

            var ofertas = BD.BuscarOfertas(new FiltrosOfertas { Texto = puesto, IDProvincia = provincia?.ID, Modalidades = modalidades }, User.IdUsuario());
            if (pais != null)
            {
                var soloRemoto = modalidades.Count == 1 && modalidades[0] == "Remoto";
                var resultado = await _jsearch.Buscar($"{puesto} en {provincia?.Nombre ?? pais.Nombre}", pais.Codigo_ISO, soloRemoto,
                                                      Array.Empty<string>(), "month", null);
                ViewBag.ErrorExternas = resultado.Error;
                BD.MarcarPostuladas(resultado.Ofertas, User.IdUsuario());
                ofertas.AddRange(resultado.Ofertas);
            }
            ViewBag.ParaVos = ofertas.Where(o => !o.YaPostulado).Take(6).ToList();
        }
        return PartialView("_ParaVos");
    }
}
