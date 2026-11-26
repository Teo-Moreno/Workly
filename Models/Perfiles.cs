using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace Workly.Models;

public static class Perfiles
{
    public static bool EsUsuarioDeLaSesion(Usuario? usuario, string emailSesion) =>
        usuario != null && string.Equals(usuario.Email, emailSesion, StringComparison.OrdinalIgnoreCase);

    public static MiPerfilViewModel? MiPerfil(int idUsuario, string emailSesion)
    {
        var modelo = BD.ObtenerMiPerfil(idUsuario);
        return EsUsuarioDeLaSesion(modelo?.Usuario, emailSesion) ? modelo : null;
    }

    public static MiPerfilViewModel? PerfilParaMostrar(int idUsuario, string emailSesion)
    {
        var modelo = MiPerfil(idUsuario, emailSesion);
        if (modelo != null)
        {
            modelo.Instituciones = BD.ObtenerInstituciones();
        }
        return modelo;
    }

    public static Resultado GuardarSobreMi(int idUsuario, string? descripcion)
    {
        var texto = (descripcion ?? "").Replace("\r\n", "\n").Trim();
        if (texto.Length > 500)
        {
            return Resultado.Mal("Usá hasta 500 caracteres en \"Sobre mí\".");
        }
        BD.ActualizarDescripcion(idUsuario, texto.Length == 0 ? null : texto);
        return Resultado.Bien(texto.Length == 0 ? "Borramos el texto de \"Sobre mí\"." : "Guardamos tu \"Sobre mí\".");
    }

    public static Resultado GuardarEstado(int idUsuario, string? estado)
    {
        if (estado != null && !Catalogos.EstadosBusqueda.Contains(estado))
        {
            return Resultado.Mal("Elegí una opción de la lista.");
        }
        BD.ActualizarEstadoBusqueda(idUsuario, estado);
        return Resultado.Bien("Actualizamos tu estado de búsqueda.");
    }

    public static async Task<Resultado> CambiarImagen(int idUsuario, bool esEmpresa, IFormFile? foto, Carpetas carpetas)
    {
        if (foto == null || foto.Length == 0)
        {
            return Resultado.Mal("Elegí una foto para subir.");
        }
        if (Archivos.Validar(foto, Archivos.ExtensionesFoto) is { } error)
        {
            return Resultado.Mal(error + ".");
        }
        var ruta = await Archivos.GuardarFoto(foto, carpetas.Publica);
        var anterior = esEmpresa ? BD.ActualizarLogo(idUsuario, ruta) : BD.ActualizarFoto(idUsuario, ruta);
        Archivos.BorrarImagen(anterior, carpetas.Publica);
        return Resultado.Bien(esEmpresa ? "Actualizamos el logo." : "Actualizamos tu foto de perfil.");
    }

    public static Resultado QuitarImagen(int idUsuario, bool esEmpresa, Carpetas carpetas)
    {
        var anterior = esEmpresa ? BD.ActualizarLogo(idUsuario, null) : BD.ActualizarFoto(idUsuario, null);
        Archivos.BorrarImagen(anterior, carpetas.Publica);
        return Resultado.Bien(esEmpresa ? "Quitamos el logo." : "Quitamos tu foto de perfil.");
    }

    public static async Task<string?> CompletarDesdeCV(int idUsuario, LectorCV lector, Carpetas carpetas)
    {
        var nombre = BD.ObtenerCV(idUsuario)?.Nombre_Archivo;
        if (!lector.Disponible || string.IsNullOrEmpty(nombre))
        {
            return null;
        }
        return await lector.CompletarPerfil(idUsuario, Path.Combine(Archivos.CarpetaCV(carpetas.Raiz), nombre));
    }

    public static async Task<Resultado> CambiarCV(int idUsuario, IFormFile? archivo, Carpetas carpetas, LectorCV lector)
    {
        if (archivo == null || archivo.Length == 0)
        {
            return Resultado.Mal("Elegí tu CV para subirlo.");
        }
        if (Archivos.Validar(archivo, Archivos.ExtensionesCV) is { } error)
        {
            return Resultado.Mal(error + ".");
        }
        var nombre = await Archivos.GuardarCV(archivo, carpetas.Raiz);
        Archivos.BorrarCV(BD.ActualizarArchivoCV(idUsuario, nombre), carpetas.Raiz);
        var completado = await CompletarDesdeCV(idUsuario, lector, carpetas);
        return Resultado.Bien(completado == null ? "Subimos tu CV." : $"Subimos tu CV. {completado}");
    }

    public static Resultado QuitarCV(int idUsuario, Carpetas carpetas)
    {
        Archivos.BorrarCV(BD.ActualizarArchivoCV(idUsuario, null), carpetas.Raiz);
        return Resultado.Bien("Quitamos tu CV.");
    }

    public static bool AgregarExperiencia(int idUsuario, ExperienciaFormulario formulario, ModelStateDictionary estado)
    {
        formulario.Descripcion = Validaciones.TextoLargo(formulario.Descripcion, nameof(formulario.Descripcion), 500, estado);
        if (!Validaciones.Periodo(formulario.Inicio, formulario.Actual ? null : formulario.Fin, false, out var inicio, out var fin, out var error))
        {
            estado.AddModelError(error!.Contains("de inicio") ? nameof(formulario.Inicio) : nameof(formulario.Fin), error);
        }
        else if (!formulario.Actual && fin == null)
        {
            estado.AddModelError(nameof(formulario.Fin), "Elegí el mes y el año de finalización, o marcá que trabajás actualmente acá");
        }
        if (!estado.IsValid)
        {
            return false;
        }

        BD.AgregarExperiencia(idUsuario, new ExperienciaNueva
        {
            Puesto = formulario.Puesto.Trim(),
            Empresa = formulario.Empresa.Trim(),
            Descripcion = Validaciones.Limpiar(formulario.Descripcion),
            Inicio = inicio,
            Fin = formulario.Actual ? null : fin
        });
        return true;
    }

    public static bool AgregarFormacion(int idUsuario, FormacionFormulario formulario, ModelStateDictionary estado)
    {
        if (!Validaciones.Periodo(formulario.Inicio, formulario.EnCurso ? null : formulario.Fin, true, out var inicio, out var fin, out var error))
        {
            estado.AddModelError(error!.Contains("de inicio") ? nameof(formulario.Inicio) : nameof(formulario.Fin), error);
        }
        else if (!formulario.EnCurso && fin == null)
        {
            estado.AddModelError(nameof(formulario.Fin), "Elegí el mes y el año de finalización, o marcá que la estás cursando");
        }
        if (!estado.IsValid)
        {
            return false;
        }

        BD.AgregarFormacion(idUsuario, new FormacionNueva
        {
            Titulo = formulario.Titulo.Trim(),
            Institucion = formulario.Institucion.Trim(),
            Inicio = inicio,
            Fin = formulario.EnCurso ? null : fin
        });
        return true;
    }

    public static Resultado EliminarExperiencia(int idUsuario, int id) =>
        Resultado.Segun(BD.EliminarExperiencia(idUsuario, id), "Borramos la experiencia.", "No encontramos esa experiencia.", "exito");

    public static Resultado EliminarFormacion(int idUsuario, int id) =>
        Resultado.Segun(BD.EliminarFormacion(idUsuario, id), "Borramos la formación.", "No encontramos esa formación.", "exito");

    public static CompletarPerfilViewModel FormularioCompletar(MiPerfilViewModel perfil)
    {
        var p = perfil.Preferencia;
        var modelo = new CompletarPerfilViewModel
        {
            IDPais = perfil.Perfil.IDPais,
            IDProvincia = perfil.Perfil.IDProvincia,
            Telefono = Telefonos.ParteLocal(perfil.Perfil.Telefono, perfil.Perfil.Codigo_Telefono),
            Descripcion = perfil.Perfil.Descripcion,
            EstadoBusqueda = perfil.Perfil.Estado_Busqueda,
            PuestoBuscado = p.Puesto_Buscado,
            Niveles = p.ListaNiveles,
            Modalidades = p.ListaModalidades,
            Jornada = p.Jornada,
            Contratacion = p.Contratacion,
            IDProvinciaPreferida = p.IDProvincia,
            SalarioMinimo = p.Salario_Minimo,
            SalarioMaximo = p.Salario_Maximo,
            Disponibilidad = p.Disponibilidad,
            Habilidades = perfil.Habilidades,
            IdiomaIds = perfil.Idiomas.Select(i => i.IDIdioma).ToList(),
            IdiomaNiveles = perfil.Idiomas.Select(i => i.Nivel).ToList(),
            SitioWeb = perfil.CV?.Sitio_Web
        };
        CargarCompletar(modelo, perfil);
        return modelo;
    }

    public static void CargarCompletar(CompletarPerfilViewModel modelo, MiPerfilViewModel perfil)
    {
        modelo.Paises = BD.ObtenerPaises();
        modelo.Provincias = BD.ObtenerProvincias();
        modelo.IDPais ??= modelo.Paises.Count == 1 ? modelo.Paises[0].ID : null;
        modelo.CatalogoHabilidades = BD.ObtenerCatalogoHabilidades();
        modelo.CatalogoIdiomas = BD.ObtenerCatalogoIdiomas();
        modelo.Instituciones = BD.ObtenerInstituciones();
        modelo.FotoActual = perfil.Perfil.Foto;
        modelo.CVActual = perfil.CV?.NombreOriginal ?? (perfil.TieneCV ? "CV" : null);
        modelo.ExperienciasCargadas = perfil.Experiencias;
        modelo.FormacionesCargadas = perfil.Formaciones;
    }

    public static async Task<bool> Completar(int idUsuario, CompletarPerfilViewModel modelo, MiPerfilViewModel perfil, ModelStateDictionary estado,
                                             Carpetas carpetas)
    {
        CargarCompletar(modelo, perfil);
        modelo.Descripcion = Validaciones.TextoLargo(modelo.Descripcion, nameof(modelo.Descripcion), 500, estado);
        var (provincia, telefono) = Validaciones.Ubicacion(modelo.Paises, modelo.Provincias, modelo.IDPais, modelo.IDProvincia, modelo.Telefono,
                                                           nameof(modelo.IDProvincia), nameof(modelo.Telefono), estado);
        Validaciones.OpcionDeLista(modelo.EstadoBusqueda, Catalogos.EstadosBusqueda, nameof(modelo.EstadoBusqueda), estado);
        var preferencia = Validaciones.Preferencia(modelo.PuestoBuscado, modelo.Niveles, modelo.Modalidades, modelo.Jornada, modelo.Contratacion,
                                                   modelo.IDProvinciaPreferida, modelo.SalarioMinimo, modelo.SalarioMaximo, modelo.Disponibilidad,
                                                   modelo.Provincias, nameof(modelo.SalarioMaximo), estado);
        var habilidades = Validaciones.Habilidades(modelo.Habilidades, nameof(modelo.Habilidades), estado);
        var idiomas = Validaciones.Idiomas(modelo.IdiomaIds, modelo.IdiomaNiveles, modelo.CatalogoIdiomas, "Idiomas", estado);
        var experiencias = ArmarExperiencias(modelo, estado);
        var formaciones = ArmarFormaciones(modelo, estado);
        Validaciones.Archivo(modelo.Foto, Archivos.ExtensionesFoto, nameof(modelo.Foto), estado);
        Validaciones.Archivo(modelo.ArchivoCV, Archivos.ExtensionesCV, nameof(modelo.ArchivoCV), estado);
        if (!estado.IsValid)
        {
            return false;
        }

        var rutaFoto = await Archivos.GuardarFoto(modelo.Foto, carpetas.Publica);
        var nombreCV = await Archivos.GuardarCV(modelo.ArchivoCV, carpetas.Raiz);
        var (fotoAnterior, cvAnterior) = BD.CompletarPerfil(idUsuario, new PerfilCompletado
        {
            IDProvincia = provincia?.ID,
            Telefono = telefono,
            Descripcion = Validaciones.Limpiar(modelo.Descripcion),
            EstadoBusqueda = modelo.EstadoBusqueda,
            Foto = rutaFoto,
            ArchivoCV = nombreCV,
            SitioWeb = Validaciones.Limpiar(modelo.SitioWeb),
            Preferencia = preferencia,
            Habilidades = habilidades,
            Idiomas = idiomas,
            Experiencias = experiencias,
            Formaciones = formaciones
        });
        if (rutaFoto != null) Archivos.BorrarImagen(fotoAnterior, carpetas.Publica);
        if (nombreCV != null) Archivos.BorrarCV(cvAnterior, carpetas.Raiz);
        return true;
    }

    private static List<ExperienciaNueva> ArmarExperiencias(CompletarPerfilViewModel m, ModelStateDictionary estado)
    {
        var lista = new List<ExperienciaNueva>();
        for (var i = 0; i < m.ExpPuesto.Count; i++)
        {
            var puesto = Valor(m.ExpPuesto, i);
            var empresa = Valor(m.ExpEmpresa, i);
            var inicio = Fechas.ParsearMesAnio(Valor(m.ExpInicio, i));
            var finTexto = Valor(m.ExpFin, i);
            var fin = Fechas.ParsearMesAnio(finTexto);
            var descripcion = Valor(m.ExpDescripcion, i);
            if ((puesto + empresa + Valor(m.ExpInicio, i) + finTexto + descripcion).Length == 0)
            {
                continue;
            }
            if (puesto.Length is 0 or > 100 || empresa.Length is 0 or > 100 || inicio == null || inicio > Fechas.MesActual ||
                (finTexto.Length > 0 && (fin == null || fin < inicio || fin > Fechas.MesActual)) || descripcion.Length > 500)
            {
                estado.AddModelError("Experiencias", "Revisá las experiencias: cada una necesita puesto, empresa y fechas válidas.");
                continue;
            }
            lista.Add(new ExperienciaNueva { Puesto = puesto, Empresa = empresa, Inicio = inicio.Value, Fin = fin, Descripcion = Validaciones.Limpiar(descripcion) });
        }
        return lista;
    }

    private static List<FormacionNueva> ArmarFormaciones(CompletarPerfilViewModel m, ModelStateDictionary estado)
    {
        var lista = new List<FormacionNueva>();
        for (var i = 0; i < m.ForTitulo.Count; i++)
        {
            var titulo = Valor(m.ForTitulo, i);
            var institucion = Valor(m.ForInstitucion, i);
            var inicio = Fechas.ParsearMesAnio(Valor(m.ForInicio, i));
            var finTexto = Valor(m.ForFin, i);
            var fin = Fechas.ParsearMesAnio(finTexto);
            if ((titulo + institucion + Valor(m.ForInicio, i) + finTexto).Length == 0)
            {
                continue;
            }
            if (titulo.Length is 0 or > 150 || institucion.Length is 0 or > 150 || inicio == null || inicio > Fechas.MesActual ||
                (finTexto.Length > 0 && (fin == null || fin < inicio)))
            {
                estado.AddModelError("Formaciones", "Revisá la formación: cada una necesita título, institución y fechas válidas.");
                continue;
            }
            lista.Add(new FormacionNueva { Titulo = titulo, Institucion = institucion, Inicio = inicio.Value, Fin = fin });
        }
        return lista;
    }

    private static string Valor(List<string> lista, int i) => i < lista.Count ? (lista[i] ?? "").Trim() : "";

    public static void CargarConfiguracion(MiPerfilViewModel modelo)
    {
        modelo.Paises = BD.ObtenerPaises();
        modelo.Provincias = BD.ObtenerProvincias();
        modelo.CatalogoHabilidades = BD.ObtenerCatalogoHabilidades();
        modelo.CatalogoIdiomas = BD.ObtenerCatalogoIdiomas();
        modelo.ProveedoresVinculados = BD.ObtenerProveedoresVinculados(modelo.Usuario.ID);
        if (modelo.Usuario.EsEmpresa)
        {
            modelo.Empresa = BD.ObtenerEmpresaDeUsuario(modelo.Usuario.ID);
        }
    }

    public static PantallaConfiguracion Configuracion(MiPerfilViewModel modelo, string? pestana, object? formulario)
    {
        CargarConfiguracion(modelo);
        var esEmpresa = modelo.Usuario.EsEmpresa;
        var pestanas = esEmpresa ? new[] { "cuenta", "seguridad" } : new[] { "cuenta", "busqueda", "seguridad" };
        var cuenta = formulario as CuentaFormulario;
        var empresa = formulario as EmpresaFormulario;
        var idPais = cuenta?.IDPais ?? empresa?.IDPais ?? (esEmpresa ? modelo.Empresa?.IDPais : modelo.Perfil.IDPais) ?? modelo.Paises.FirstOrDefault()?.ID;
        var codigoPais = modelo.Paises.FirstOrDefault(p => p.ID == idPais)?.Codigo_Telefono ?? "+54";
        var codigoGuardado = modelo.Paises.FirstOrDefault(p => p.ID == (esEmpresa ? modelo.Empresa?.IDPais : modelo.Perfil.IDPais))?.Codigo_Telefono;
        return new PantallaConfiguracion
        {
            Perfil = modelo,
            EsEmpresa = esEmpresa,
            Activa = pestanas.Contains(pestana) ? pestana! : "cuenta",
            FormularioCuenta = cuenta,
            FormularioEmpresa = empresa,
            CamposBusqueda = esEmpresa ? null : CamposBusqueda.Desde(modelo, formulario as BusquedaFormulario),
            Telefono = new CampoTelefono
            {
                Id = "cfg-telefono",
                Valor = esEmpresa
                    ? empresa?.Telefono ?? Telefonos.ParteLocal(modelo.Empresa?.Telefono, codigoGuardado)
                    : cuenta?.Telefono ?? Telefonos.ParteLocal(modelo.Perfil.Telefono, modelo.Perfil.Codigo_Telefono),
                Prefijo = codigoPais
            },
            Ubicacion = new CampoUbicacion
            {
                Prefijo = "cfg-",
                Paises = modelo.Paises,
                Provincias = modelo.Provincias,
                IDPais = idPais,
                IDProvincia = esEmpresa ? empresa?.IDProvincia ?? modelo.Empresa?.IDProvincia : cuenta?.IDProvincia ?? modelo.Perfil.IDProvincia,
                EtiquetaProvincia = esEmpresa ? "Provincia de la sede" : "Provincia donde vivís"
            }
        };
    }

    public static async Task<bool> GuardarCuenta(int idUsuario, CuentaFormulario formulario, ModelStateDictionary estado, Carpetas carpetas)
    {
        formulario.Email = Cuentas.NormalizarEmail(formulario.Email);
        var (provincia, telefono) = Validaciones.Ubicacion(BD.ObtenerPaises(), BD.ObtenerProvincias(), formulario.IDPais, formulario.IDProvincia,
                                                           formulario.Telefono, nameof(formulario.IDProvincia), nameof(formulario.Telefono), estado);
        if (estado[nameof(formulario.Email)]?.Errors.Count is null or 0 && BD.ExisteEmail(formulario.Email, idUsuario))
        {
            estado.AddModelError(nameof(formulario.Email), "Ya hay otra cuenta con ese email");
        }
        Validaciones.Archivo(formulario.Foto, Archivos.ExtensionesFoto, nameof(formulario.Foto), estado);
        Validaciones.Archivo(formulario.ArchivoCV, Archivos.ExtensionesCV, nameof(formulario.ArchivoCV), estado);
        if (!estado.IsValid)
        {
            return false;
        }

        BD.ActualizarDatosPersonales(idUsuario, formulario.Nombre.Trim(), formulario.Apellido.Trim(), formulario.Email, provincia?.ID, telefono,
                                     Validaciones.Limpiar(formulario.SitioWeb));
        if (formulario.Foto is { Length: > 0 })
        {
            var ruta = await Archivos.GuardarFoto(formulario.Foto, carpetas.Publica);
            Archivos.BorrarImagen(BD.ActualizarFoto(idUsuario, ruta), carpetas.Publica);
        }
        if (formulario.ArchivoCV is { Length: > 0 })
        {
            var nombre = await Archivos.GuardarCV(formulario.ArchivoCV, carpetas.Raiz);
            Archivos.BorrarCV(BD.ActualizarArchivoCV(idUsuario, nombre), carpetas.Raiz);
        }
        return true;
    }

    public static async Task<bool> GuardarEmpresa(int idUsuario, Empresa empresa, string emailSesion, EmpresaFormulario formulario,
                                                  ModelStateDictionary estado, Carpetas carpetas)
    {
        formulario.NombreEmpresa = (formulario.NombreEmpresa ?? "").Trim();
        formulario.Descripcion = Validaciones.TextoLargo(formulario.Descripcion, nameof(formulario.Descripcion), 500, estado);
        if (string.IsNullOrWhiteSpace(formulario.Descripcion))
        {
            estado.AddModelError(nameof(formulario.Descripcion), "Contá en pocas líneas qué hace la empresa");
        }
        var (provincia, telefono) = Validaciones.Ubicacion(BD.ObtenerPaises(), BD.ObtenerProvincias(), formulario.IDPais, formulario.IDProvincia,
                                                           formulario.Telefono, nameof(formulario.IDProvincia), nameof(formulario.Telefono), estado);
        Validaciones.OpcionDeLista(formulario.Rubro, Catalogos.Rubros, nameof(formulario.Rubro), estado, "Elegí un rubro de la lista");
        if (!string.IsNullOrEmpty(formulario.SitioWeb) && !VerificacionEmpresa.EmailCoincideConSitio(emailSesion, formulario.SitioWeb))
        {
            estado.AddModelError(nameof(formulario.SitioWeb), $"El sitio tiene que ser del mismo dominio que tu email ({VerificacionEmpresa.DominioDelEmail(emailSesion)})");
        }
        if (formulario.NombreEmpresa.Length > 0 && BD.ExisteNombreEmpresa(formulario.NombreEmpresa, empresa.ID))
        {
            estado.AddModelError(nameof(formulario.NombreEmpresa), "Ya hay otra empresa con ese nombre");
        }
        Validaciones.Archivo(formulario.Logo, Archivos.ExtensionesFoto, nameof(formulario.Logo), estado);
        if (!estado.IsValid)
        {
            return false;
        }

        BD.ActualizarResponsable(idUsuario, formulario.Nombre.Trim(), formulario.Apellido.Trim());
        BD.ActualizarEmpresa(new Empresa
        {
            ID = empresa.ID,
            IDUsuario = idUsuario,
            Nombre = formulario.NombreEmpresa,
            Descripcion = formulario.Descripcion!.Trim(),
            Ubicacion = Validaciones.Limpiar(formulario.Ubicacion),
            Sitio_Web = formulario.SitioWeb.Trim(),
            Rubro = formulario.Rubro,
            IDProvincia = provincia?.ID,
            Telefono = telefono
        });
        if (formulario.Logo is { Length: > 0 })
        {
            var ruta = await Archivos.GuardarLogo(formulario.Logo, carpetas.Publica);
            Archivos.BorrarImagen(BD.ActualizarLogo(idUsuario, ruta), carpetas.Publica);
        }
        return true;
    }

    public static bool GuardarBusqueda(int idUsuario, BusquedaFormulario formulario, ModelStateDictionary estado)
    {
        Validaciones.OpcionDeLista(formulario.EstadoBusqueda, Catalogos.EstadosBusqueda, nameof(formulario.EstadoBusqueda), estado);
        var preferencia = Validaciones.Preferencia(formulario.PuestoBuscado, formulario.Niveles, formulario.Modalidades, formulario.Jornada,
                                                   formulario.Contratacion, formulario.IDProvinciaPreferida, formulario.SalarioMinimo,
                                                   formulario.SalarioMaximo, formulario.Disponibilidad, BD.ObtenerProvincias(),
                                                   nameof(formulario.SalarioMaximo), estado);
        var habilidades = Validaciones.Habilidades(formulario.Habilidades, nameof(formulario.Habilidades), estado);
        var idiomas = Validaciones.Idiomas(formulario.IdiomaIds, formulario.IdiomaNiveles, BD.ObtenerCatalogoIdiomas(), "Idiomas", estado);
        if (!estado.IsValid)
        {
            return false;
        }
        BD.GuardarBusqueda(idUsuario, preferencia, formulario.EstadoBusqueda, habilidades, idiomas);
        return true;
    }

    public static Resultado? CambiarClave(Usuario usuario, ClaveFormulario formulario, ModelStateDictionary estado)
    {
        if (usuario.TieneContrasena && !Contrasenas.Verificar(formulario.Actual ?? "", usuario.Contraseña))
        {
            estado.AddModelError(nameof(formulario.Actual), "La contraseña actual no es correcta");
        }
        if (!estado.IsValid)
        {
            return null;
        }
        BD.CambiarContrasena(usuario.ID, Contrasenas.Hashear(formulario.Nueva));
        return Resultado.Bien(usuario.TieneContrasena ? "Cambiamos tu contraseña." : "Creamos tu contraseña: ya podés entrar también con tu email.");
    }

    public static Resultado EliminarCuenta(int idUsuario, string? confirmacion, Carpetas carpetas)
    {
        if (!string.Equals(confirmacion?.Trim(), "ELIMINAR", StringComparison.Ordinal))
        {
            return Resultado.Mal("Para eliminar la cuenta escribí ELIMINAR en mayúsculas.");
        }
        var imagenesDeOfertas = BD.ObtenerOfertasPublicadas(idUsuario).Select(o => o.Logo).ToList();
        var (foto, cv, logo) = BD.EliminarCuenta(idUsuario);
        imagenesDeOfertas.ForEach(imagen => Publicaciones.BorrarImagenPropia(imagen, carpetas.Publica));
        Archivos.BorrarImagen(foto, carpetas.Publica);
        Archivos.BorrarImagen(logo, carpetas.Publica);
        Archivos.BorrarCV(cv, carpetas.Raiz);
        return Resultado.Bien("Eliminamos tu cuenta y todos sus datos.");
    }
}

public class PantallaConfiguracion
{
    public MiPerfilViewModel Perfil { get; set; } = new();
    public bool EsEmpresa { get; set; }
    public string Activa { get; set; } = "cuenta";
    public CuentaFormulario? FormularioCuenta { get; set; }
    public EmpresaFormulario? FormularioEmpresa { get; set; }
    public CamposBusqueda? CamposBusqueda { get; set; }
    public CampoTelefono Telefono { get; set; } = new();
    public CampoUbicacion Ubicacion { get; set; } = new();
}
