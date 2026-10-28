using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Workly.Models;

namespace Workly.Controllers;

// Inicio de la persona logueada: qué le falta al perfil, sus postulaciones y ofertas
// según lo que contó que busca. Las empresas van directo a sus publicaciones.
[Authorize]
public class PanelController : Controller
{
    private readonly JSearch _jsearch;

    public PanelController(JSearch jsearch)
    {
        _jsearch = jsearch;
    }

    public async Task<IActionResult> Index()
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

        var modelo = new PanelViewModel { Perfil = perfil };
        var puesto = perfil.Preferencia.Puesto_Buscado;
        if (!string.IsNullOrWhiteSpace(puesto))
        {
            // Lo que pidió: puesto, dónde quiere trabajar (o donde vive) y modalidad
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
                modelo.ErrorExternas = resultado.Error;
                BD.MarcarPostuladas(resultado.Ofertas, User.IdUsuario());
                ofertas.AddRange(resultado.Ofertas);
            }
            modelo.ParaVos = ofertas.Where(o => !o.YaPostulado).Take(6).ToList();
        }
        return View(modelo);
    }
}
