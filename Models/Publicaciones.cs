using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace Workly.Models;

public static class Publicaciones
{
    public static void CargarFormulario(PublicarViewModel modelo, int idUsuario, bool esEmpresa, bool esNueva)
    {
        modelo.EsEmpresa = esEmpresa;
        modelo.Paises = BD.ObtenerPaises();
        modelo.Provincias = BD.ObtenerProvincias();
        modelo.Sectores = BD.ObtenerSectores();
        if (esEmpresa)
        {
            var empresa = BD.ObtenerEmpresaDeUsuario(idUsuario);
            modelo.EmpresaFija = empresa?.Nombre;
            modelo.EmpresaLogo = empresa?.Logo;
            if (esNueva)
            {
                modelo.IDProvincia = empresa?.IDProvincia;
                modelo.Ubicacion = empresa?.Ubicacion;
            }
        }
        else if (esNueva)
        {
            modelo.IDProvincia = BD.ObtenerPerfil(idUsuario)?.IDProvincia;
        }
        var provincia = modelo.Provincias.FirstOrDefault(p => p.ID == modelo.IDProvincia);
        modelo.IDPais ??= provincia?.IDPais ?? modelo.Paises.FirstOrDefault()?.ID;
    }

    public static async Task<int?> Crear(PublicarViewModel modelo, int idUsuario, Empresa? empresa, ModelStateDictionary estado, string carpetaPublica)
    {
        var esEmpresa = empresa != null;
        modelo.Descripcion = (modelo.Descripcion ?? "").Replace("\r\n", "\n");
        estado.Remove(nameof(modelo.Descripcion));
        if (modelo.Descripcion.Trim().Length is < 40 or > 2000)
        {
            estado.AddModelError(nameof(modelo.Descripcion), "Usá entre 40 y 2000 caracteres");
        }
        if (!esEmpresa && string.IsNullOrWhiteSpace(modelo.EmpresaNombre))
        {
            estado.AddModelError(nameof(modelo.EmpresaNombre), "Escribí el nombre de la empresa o el negocio que contrata");
        }
        Validaciones.OpcionDeLista(modelo.Modalidad, Catalogos.Modalidades, nameof(modelo.Modalidad), estado);
        if (modelo.IDSector != null && modelo.Sectores.All(s => s.ID != modelo.IDSector))
        {
            estado.AddModelError(nameof(modelo.IDSector), "Elegí un sector de la lista");
        }
        Validaciones.OpcionDeLista(modelo.TipoEmpleo, Catalogos.TiposEmpleo.Select(t => t.Nombre), nameof(modelo.TipoEmpleo), estado);
        var provincia = Validaciones.Provincia(modelo.Provincias, modelo.IDPais, modelo.IDProvincia, nameof(modelo.IDProvincia), estado);
        if (modelo.FechaCierre.HasValue && modelo.FechaCierre.Value.Date < DateTime.Today)
        {
            estado.AddModelError(nameof(modelo.FechaCierre), "La fecha de cierre no puede ser anterior a hoy");
        }
        if (!esEmpresa && !string.IsNullOrWhiteSpace(modelo.EmpresaNombre) && BD.NombreEmpresaConCuenta(modelo.EmpresaNombre.Trim()))
        {
            estado.AddModelError(nameof(modelo.EmpresaNombre), "Esa empresa tiene cuenta en Workly: sus búsquedas las publica ella.");
        }
        if (Archivos.Validar(modelo.Imagen, Archivos.ExtensionesFoto) is { } errorImagen)
        {
            estado.AddModelError(nameof(modelo.Imagen), errorImagen);
        }
        if (!estado.IsValid)
        {
            return null;
        }

        var imagen = await Archivos.GuardarImagenOferta(modelo.Imagen, carpetaPublica);
        return BD.CrearOferta(new OfertaNueva
        {
            Logo = imagen,
            IDUsuario_Publicador = idUsuario,
            IDEmpresa = empresa?.ID,
            EmpresaNombre = modelo.EmpresaNombre?.Trim(),
            Titulo = modelo.Titulo.Trim(),
            Puesto = modelo.Puesto.Trim(),
            IDSector = modelo.IDSector!.Value,
            Descripcion = modelo.Descripcion.Trim(),
            Ubicacion = Validaciones.Limpiar(modelo.Ubicacion),
            IDProvincia = provincia?.ID,
            Modalidad = modelo.Modalidad!,
            Tipo_Contrato = modelo.TipoEmpleo!,
            Salario = modelo.Salario is > 0 ? modelo.Salario : null,
            Cantidad_Puestos = modelo.CantidadPuestos,
            Fecha_Cierre = modelo.FechaCierre?.Date,
            Estado_Publicacion = esEmpresa ? "Aprobada" : "Pendiente"
        });
    }

    public static string MensajeCreada(bool esEmpresa) => esEmpresa
        ? "¡Publicamos tu búsqueda! Ya aparece en Buscar trabajo."
        : "Recibimos tu búsqueda. La revisamos y, si está todo bien, la publicamos.";

    public static Oferta? OfertaPropia(int idOferta, int idUsuario)
    {
        var oferta = BD.ObtenerOferta(idOferta, idUsuario);
        return oferta?.IDUsuario_Publicador == idUsuario ? oferta : null;
    }

    public static (MiPerfilViewModel Perfil, Oferta Oferta)? Postulante(int idPostulacion, int idUsuario)
    {
        var postulacion = BD.ObtenerPostulacionDePublicador(idPostulacion, idUsuario);
        if (postulacion == null)
        {
            return null;
        }
        var perfil = BD.ObtenerMiPerfil(postulacion.Value.IDUsuario);
        var oferta = BD.ObtenerOferta(postulacion.Value.IDOferta, idUsuario);
        return perfil == null || oferta == null ? null : (perfil, oferta);
    }

    public static Descarga? CVDePostulante(int idPostulacion, int idUsuario, string carpetaRaiz)
    {
        var postulacion = BD.ObtenerPostulacionDePublicador(idPostulacion, idUsuario);
        return postulacion == null ? null : Archivos.DescargaCV(BD.ObtenerCV(postulacion.Value.IDUsuario), carpetaRaiz);
    }

    public static Resultado Cerrar(int idOferta, int idUsuario) =>
        Resultado.Segun(BD.CerrarOferta(idOferta, idUsuario),
            "Cerramos la búsqueda: ya no aparece en Buscar trabajo ni recibe postulaciones.", "No pudimos cerrar esa búsqueda.", "exito");

    public static Resultado Eliminar(int idOferta, int idUsuario, string carpetaPublica)
    {
        var imagen = OfertaPropia(idOferta, idUsuario)?.Logo;
        var eliminada = BD.EliminarOferta(idOferta, idUsuario);
        if (eliminada)
        {
            BorrarImagenPropia(imagen, carpetaPublica);
        }
        return Resultado.Segun(eliminada, "Eliminamos la búsqueda y sus postulaciones.", "No encontramos esa búsqueda.");
    }

    public static void BorrarImagenPropia(string? imagen, string carpetaPublica)
    {
        if (imagen != null && imagen.StartsWith("/uploads/ofertas/"))
        {
            Archivos.BorrarImagen(imagen, carpetaPublica);
        }
    }
}
