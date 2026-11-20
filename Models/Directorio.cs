namespace Workly.Models;

public static class Directorio
{
    public static EmpresasViewModel Buscar(EmpresasViewModel modelo, bool eligioProvincia, int idUsuario, bool esPersona)
    {
        modelo.Q = Validaciones.Limpiar(modelo.Q);
        modelo.Paises = BD.ObtenerPaises();
        modelo.Provincias = BD.ObtenerProvincias();

        if (!eligioProvincia && esPersona)
        {
            var perfil = BD.ObtenerPerfil(idUsuario);
            modelo.IDPais = perfil?.IDPais;
            modelo.IDProvincia = perfil?.IDProvincia;
        }
        modelo.IDPais = modelo.Paises.FirstOrDefault(p => p.ID == modelo.IDPais)?.ID ?? modelo.Paises.FirstOrDefault()?.ID;
        modelo.IDProvincia = modelo.Provincias.FirstOrDefault(p => p.ID == modelo.IDProvincia && p.IDPais == modelo.IDPais)?.ID;
        if (!Catalogos.Ordenes.Any(o => o.Valor == modelo.Orden)) modelo.Orden = "recientes";
        modelo.Empresas = BD.BuscarEmpresas(modelo.Q, null, modelo.IDPais, modelo.IDProvincia, modelo.Orden);
        return modelo;
    }

    public static (Empresa Empresa, List<Oferta> Abiertas, bool EsPropia)? Detalle(int idEmpresa, int idUsuario, bool esEmpresa)
    {
        var empresa = BD.ObtenerEmpresa(idEmpresa);
        if (empresa == null)
        {
            return null;
        }
        var abiertas = BD.ObtenerOfertasDeEmpresa(idEmpresa, idUsuario);
        return (empresa, abiertas, esEmpresa && empresa.IDUsuario == idUsuario);
    }
}
