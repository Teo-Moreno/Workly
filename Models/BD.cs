using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;

namespace Workly.Models;

public static class BD
{
    private static string _connectionString = "";

    private const CommandType SP = CommandType.StoredProcedure;

    public static void Configurar(string connectionString)
    {
        _connectionString = connectionString;
    }

    private static SqlConnection Conectar() => new(_connectionString);

    private static List<T> Lista<T>(string procedimiento, object? parametros = null)
    {
        using var conexion = Conectar();
        return conexion.Query<T>(procedimiento, parametros, commandType: SP).ToList();
    }

    private static T? Uno<T>(string procedimiento, object? parametros = null)
    {
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<T>(procedimiento, parametros, commandType: SP);
    }

    private static T Valor<T>(string procedimiento, object? parametros = null)
    {
        using var conexion = Conectar();
        return conexion.ExecuteScalar<T>(procedimiento, parametros, commandType: SP);
    }

    private static void Ejecutar(string procedimiento, object? parametros = null)
    {
        using var conexion = Conectar();
        conexion.Execute(procedimiento, parametros, commandType: SP);
    }

    private static bool Cambio(string procedimiento, object parametros) => Valor<int>(procedimiento, parametros) > 0;

    public static Usuario? ObtenerUsuarioPorEmail(string email) =>
        Uno<Usuario>("ObtenerUsuarioPorEmail", new { Email = email });

    public static Usuario? ObtenerUsuarioPorId(int id) =>
        Uno<Usuario>("ObtenerUsuarioPorId", new { ID = id });

    public static bool ExisteEmail(string email, int? exceptoIdUsuario = null) =>
        Valor<bool>("ExisteEmail", new { Email = email, Excepto = exceptoIdUsuario });

    public static int RegistrarPersona(PersonaNueva datos)
    {
        var u = datos.Usuario;
        return Valor<int>("RegistrarPersona", new
        {
            u.Nombre,
            u.Apellido,
            u.Email,
            Contrasena = u.Contraseña,
            datos.LoginExterno?.Proveedor,
            IDExterno = datos.LoginExterno?.ID_Externo
        });
    }

    public static int RegistrarEmpresa(EmpresaNueva datos)
    {
        var u = datos.Usuario;
        var e = datos.Empresa;
        return Valor<int>("RegistrarEmpresa", new
        {
            u.Nombre,
            u.Apellido,
            u.Email,
            Contrasena = u.Contraseña,
            NombreEmpresa = e.Nombre,
            e.Descripcion,
            e.Logo,
            e.Ubicacion,
            e.Sitio_Web,
            e.Razon_Social,
            e.CUIT,
            e.Rubro,
            e.IDProvincia,
            e.Telefono,
            datos.LoginExterno?.Proveedor,
            IDExterno = datos.LoginExterno?.ID_Externo
        });
    }

    public static int? ObtenerUsuarioDeLoginExterno(string proveedor, string idExterno) =>
        Valor<int?>("ObtenerUsuarioDeLoginExterno", new { Proveedor = proveedor, IDExterno = idExterno });

    public static void VincularLoginExterno(int idUsuario, LoginExternoNuevo login) =>
        Ejecutar("VincularLoginExterno", new { IDUsuario = idUsuario, login.Proveedor, IDExterno = login.ID_Externo });

    public static List<string> ObtenerProveedoresVinculados(int idUsuario) =>
        Lista<string>("ObtenerProveedoresVinculados", new { IDUsuario = idUsuario });

    public static void ActualizarDatosPersonales(int idUsuario, string nombre, string apellido, string email, int? idProvincia, string? telefono, string? sitioWeb) =>
        Ejecutar("ActualizarDatosPersonales", new
        {
            IDUsuario = idUsuario,
            Nombre = nombre,
            Apellido = apellido,
            Email = email,
            IDProvincia = idProvincia,
            Telefono = telefono,
            SitioWeb = sitioWeb
        });

    public static (string? FotoAnterior, string? CVAnterior) CompletarPerfil(int idUsuario, PerfilCompletado d)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        var anteriores = conexion.QueryFirst<(string? FotoAnterior, string? CVAnterior)>("CompletarPerfil", new
        {
            IDUsuario = idUsuario,
            d.IDProvincia,
            d.Telefono,
            d.Descripcion,
            d.EstadoBusqueda,
            d.Foto,
            d.ArchivoCV,
            d.SitioWeb
        }, tx, commandType: SP);
        GuardarPreferencia(conexion, tx, idUsuario, d.Preferencia);
        GuardarHabilidades(conexion, tx, idUsuario, d.Habilidades);
        GuardarIdiomas(conexion, tx, idUsuario, d.Idiomas);
        foreach (var experiencia in d.Experiencias)
        {
            AgregarExperiencia(conexion, tx, idUsuario, experiencia);
        }
        foreach (var formacion in d.Formaciones)
        {
            AgregarFormacion(conexion, tx, idUsuario, formacion);
        }
        tx.Commit();
        return anteriores;
    }

    public static void ActualizarResponsable(int idUsuario, string nombre, string apellido) =>
        Ejecutar("ActualizarResponsable", new { IDUsuario = idUsuario, Nombre = nombre, Apellido = apellido });

    public static void CambiarContrasena(int idUsuario, string hash) =>
        Ejecutar("CambiarContrasena", new { IDUsuario = idUsuario, Hash = hash });

    public static string? ActualizarFoto(int idUsuario, string? ruta) =>
        Valor<string?>("ActualizarFoto", new { IDUsuario = idUsuario, Foto = ruta });

    public static void ActualizarDescripcion(int idUsuario, string? descripcion) =>
        Ejecutar("ActualizarDescripcion", new { IDUsuario = idUsuario, Descripcion = descripcion });

    public static void ActualizarEstadoBusqueda(int idUsuario, string? estado) =>
        Ejecutar("ActualizarEstadoBusqueda", new { IDUsuario = idUsuario, EstadoBusqueda = estado });

    public static string? ActualizarArchivoCV(int idUsuario, string? nombreArchivo) =>
        Valor<string?>("ActualizarArchivoCV", new { IDUsuario = idUsuario, Archivo = nombreArchivo });

    public static (string? Foto, string? CV, string? Logo) EliminarCuenta(int idUsuario) =>
        Uno<(string? Foto, string? CV, string? Logo)>("EliminarCuenta", new { IDUsuario = idUsuario });

    public static int ContarRecuperacionesRecientes(int idUsuario) =>
        Valor<int>("ContarRecuperacionesRecientes", new { IDUsuario = idUsuario });

    public static void GuardarRecuperacion(int idUsuario, string tokenHash, DateTime venceUtc) =>
        Ejecutar("GuardarRecuperacion", new { IDUsuario = idUsuario, TokenHash = tokenHash, Vence = venceUtc });

    public static int? ObtenerUsuarioDeRecuperacion(string tokenHash) =>
        Valor<int?>("ObtenerUsuarioDeRecuperacion", new { TokenHash = tokenHash });

    public static bool UsarRecuperacion(string tokenHash, string hashContrasena) =>
        Valor<bool>("UsarRecuperacion", new { TokenHash = tokenHash, Contrasena = hashContrasena });

    public static List<Pais> ObtenerPaises() => Lista<Pais>("ObtenerPaises");

    public static List<Provincia> ObtenerProvincias() => Lista<Provincia>("ObtenerProvincias");

    public static Perfil? ObtenerPerfil(int idUsuario) =>
        Uno<Perfil>("ObtenerPerfil", new { IDUsuario = idUsuario });

    public static CV? ObtenerCV(int idUsuario) =>
        Uno<CV>("ObtenerCV", new { IDUsuario = idUsuario });

    public static Preferencia? ObtenerPreferencia(int idUsuario) =>
        Uno<Preferencia>("ObtenerPreferencia", new { IDUsuario = idUsuario });

    public static void GuardarBusqueda(int idUsuario, Preferencia preferencia, string? estadoBusqueda, List<string> habilidades, List<(int, string)> idiomas)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        GuardarPreferencia(conexion, tx, idUsuario, preferencia);
        conexion.Execute("ActualizarEstadoBusqueda", new { IDUsuario = idUsuario, EstadoBusqueda = estadoBusqueda }, tx, commandType: SP);
        GuardarHabilidades(conexion, tx, idUsuario, habilidades);
        GuardarIdiomas(conexion, tx, idUsuario, idiomas);
        tx.Commit();
    }

    private static void GuardarPreferencia(IDbConnection conexion, IDbTransaction tx, int idUsuario, Preferencia p)
    {
        p.IDUsuario = idUsuario;
        conexion.Execute("GuardarPreferencia", new
        {
            p.IDUsuario,
            p.Puesto_Buscado,
            p.Niveles,
            p.Modalidades,
            p.Jornada,
            p.Contratacion,
            p.IDProvincia,
            p.Salario_Minimo,
            p.Salario_Maximo,
            p.Disponibilidad
        }, tx, commandType: SP);
    }

    public static List<Sector> ObtenerSectores() => Lista<Sector>("ObtenerSectores");

    public static List<Habilidad> ObtenerCatalogoHabilidades() => Lista<Habilidad>("ObtenerCatalogoHabilidades");

    public static List<string> ObtenerHabilidadesUsuario(int idUsuario) =>
        Lista<string>("ObtenerHabilidadesUsuario", new { IDUsuario = idUsuario });

    private static void GuardarHabilidades(IDbConnection conexion, IDbTransaction tx, int idUsuario, List<string> nombres)
    {
        conexion.Execute("QuitarHabilidadesUsuario", new { IDUsuario = idUsuario }, tx, commandType: SP);
        foreach (var nombre in nombres.Select(n => n.Trim()).Where(n => n.Length > 0).Distinct(StringComparer.OrdinalIgnoreCase))
        {
            conexion.Execute("AgregarHabilidadUsuario", new { IDUsuario = idUsuario, Nombre = nombre }, tx, commandType: SP);
        }
        conexion.Execute("BorrarHabilidadesSinUso", transaction: tx, commandType: SP);
    }

    public static List<Idioma> ObtenerCatalogoIdiomas() => Lista<Idioma>("ObtenerCatalogoIdiomas");

    public static List<IdiomaElegido> ObtenerIdiomasUsuario(int idUsuario) =>
        Lista<IdiomaElegido>("ObtenerIdiomasUsuario", new { IDUsuario = idUsuario });

    private static void GuardarIdiomas(IDbConnection conexion, IDbTransaction tx, int idUsuario, List<(int IDIdioma, string Nivel)> idiomas)
    {
        conexion.Execute("QuitarIdiomasUsuario", new { IDUsuario = idUsuario }, tx, commandType: SP);
        foreach (var (idIdioma, nivel) in idiomas.GroupBy(i => i.IDIdioma).Select(g => g.Last()))
        {
            conexion.Execute("AgregarIdiomaUsuario", new { IDUsuario = idUsuario, IDIdioma = idIdioma, Nivel = nivel }, tx, commandType: SP);
        }
    }

    public static List<ExperienciaItem> ObtenerExperiencias(int idUsuario) =>
        Lista<ExperienciaItem>("ObtenerExperiencias", new { IDUsuario = idUsuario });

    public static void AgregarExperiencia(int idUsuario, ExperienciaNueva experiencia)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        AgregarExperiencia(conexion, tx, idUsuario, experiencia);
        tx.Commit();
    }

    private static void AgregarExperiencia(IDbConnection conexion, IDbTransaction tx, int idUsuario, ExperienciaNueva x) =>
        conexion.Execute("AgregarExperiencia", new { IDUsuario = idUsuario, x.Empresa, x.Puesto, x.Descripcion, x.Inicio, x.Fin }, tx, commandType: SP);

    public static bool EliminarExperiencia(int idUsuario, int idExperiencia) =>
        Cambio("EliminarExperiencia", new { IDUsuario = idUsuario, ID = idExperiencia });

    public static List<FormacionItem> ObtenerFormaciones(int idUsuario) =>
        Lista<FormacionItem>("ObtenerFormaciones", new { IDUsuario = idUsuario });

    public static void AgregarFormacion(int idUsuario, FormacionNueva formacion)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        AgregarFormacion(conexion, tx, idUsuario, formacion);
        tx.Commit();
    }

    private static void AgregarFormacion(IDbConnection conexion, IDbTransaction tx, int idUsuario, FormacionNueva f) =>
        conexion.Execute("AgregarFormacion", new { IDUsuario = idUsuario, f.Institucion, f.Titulo, f.Inicio, f.Fin }, tx, commandType: SP);

    public static bool EliminarFormacion(int idUsuario, int idFormacion) =>
        Cambio("EliminarFormacion", new { IDUsuario = idUsuario, ID = idFormacion });

    public static List<string> ObtenerInstituciones() => Lista<string>("ObtenerInstituciones");

    public static MiPerfilViewModel? ObtenerMiPerfil(int idUsuario)
    {
        var usuario = ObtenerUsuarioPorId(idUsuario);
        if (usuario == null)
        {
            return null;
        }

        return new MiPerfilViewModel
        {
            Usuario = usuario,
            Perfil = ObtenerPerfil(idUsuario) ?? new Perfil { IDUsuario = idUsuario },
            CV = ObtenerCV(idUsuario),
            Preferencia = ObtenerPreferencia(idUsuario) ?? new Preferencia { IDUsuario = idUsuario },
            Habilidades = ObtenerHabilidadesUsuario(idUsuario),
            Idiomas = ObtenerIdiomasUsuario(idUsuario),
            Experiencias = ObtenerExperiencias(idUsuario),
            Formaciones = ObtenerFormaciones(idUsuario),
            PostulacionesPorEstado = ContarPostulacionesPorEstado(idUsuario)
        };
    }

    public static List<Empresa> BuscarEmpresas(string? texto, string? rubro, int? idPais, int? idProvincia, string? orden) =>
        Lista<Empresa>("BuscarEmpresas", new { Texto = texto, Rubro = rubro, IDPais = idPais, IDProvincia = idProvincia, Orden = orden });

    public static List<Empresa> ObtenerEmpresasConBusquedas(int cantidad) =>
        Lista<Empresa>("ObtenerEmpresasConBusquedas", new { Cantidad = cantidad });

    public static Empresa? ObtenerEmpresa(int idEmpresa) =>
        Uno<Empresa>("ObtenerEmpresa", new { ID = idEmpresa });

    public static Empresa? ObtenerEmpresaDeUsuario(int idUsuario) =>
        Uno<Empresa>("ObtenerEmpresaDeUsuario", new { IDUsuario = idUsuario });

    public static bool ExisteCuit(string cuit) =>
        Valor<bool>("ExisteCuit", new { CUIT = cuit });

    public static bool NombreEmpresaConCuenta(string nombre, int? exceptoIdEmpresa = null) =>
        Valor<bool>("NombreEmpresaConCuenta", new { Nombre = nombre, Excepto = exceptoIdEmpresa });

    public static bool ExisteNombreEmpresa(string nombre, int exceptoIdEmpresa) =>
        Valor<bool>("ExisteNombreEmpresa", new { Nombre = nombre, Excepto = exceptoIdEmpresa });

    public static void ActualizarEmpresa(Empresa e) =>
        Ejecutar("ActualizarEmpresa", new { e.ID, e.IDUsuario, e.Nombre, e.Descripcion, e.Ubicacion, e.Sitio_Web, e.Rubro, e.IDProvincia, e.Telefono });

    public static string? ActualizarLogo(int idUsuario, string? ruta) =>
        Valor<string?>("ActualizarLogo", new { IDUsuario = idUsuario, Logo = ruta });

    public static List<Oferta> BuscarOfertas(FiltrosOfertas f, int idUsuarioActual) =>
        Lista<Oferta>("BuscarOfertas", new
        {
            IDUsuarioActual = idUsuarioActual,
            f.Texto,
            f.IDProvincia,
            Modalidades = f.Modalidades.Count == 0 ? null : string.Join(",", f.Modalidades),
            Tipos = f.TiposEmpleo.Count == 0 ? null : string.Join(",", f.TiposEmpleo),
            f.Dias
        });

    public static Oferta? ObtenerOferta(int idOferta, int idUsuarioActual) =>
        Uno<Oferta>("ObtenerOferta", new { ID = idOferta, IDUsuarioActual = idUsuarioActual });

    public static List<Oferta> ObtenerOfertasDeEmpresa(int idEmpresa, int idUsuarioActual) =>
        Lista<Oferta>("ObtenerOfertasDeEmpresa", new { IDEmpresa = idEmpresa, IDUsuarioActual = idUsuarioActual });

    public static List<Oferta> ObtenerOfertasPublicadas(int idUsuario) =>
        Lista<Oferta>("ObtenerOfertasPublicadas", new { IDUsuario = idUsuario });

    public static bool TieneOfertasPublicadas(int idUsuario) =>
        Valor<bool>("TieneOfertasPublicadas", new { IDUsuario = idUsuario });

    public static List<string> ObtenerTitulosRecientes(int cantidad) =>
        Lista<string>("ObtenerTitulosRecientes", new { Cantidad = cantidad });

    public static int CrearOferta(OfertaNueva o) =>
        Valor<int>("CrearOferta", new
        {
            o.IDUsuario_Publicador,
            o.IDEmpresa,
            o.EmpresaNombre,
            o.Titulo,
            o.Puesto,
            o.IDSector,
            o.Descripcion,
            o.Ubicacion,
            o.IDProvincia,
            o.Modalidad,
            o.Tipo_Contrato,
            o.Salario,
            o.Cantidad_Puestos,
            o.Fecha_Cierre,
            o.Estado_Publicacion
        });

    public static bool CerrarOferta(int idOferta, int idPublicador) =>
        Cambio("CerrarOferta", new { ID = idOferta, IDPublicador = idPublicador });

    public static bool EliminarOferta(int idOferta, int idPublicador) =>
        Valor<bool>("EliminarOferta", new { ID = idOferta, IDPublicador = idPublicador });

    public static List<Oferta> ObtenerOfertasPendientes() => Lista<Oferta>("ObtenerOfertasPendientes");

    public static List<Oferta> ObtenerOfertasRevisadas(int cantidad) =>
        Lista<Oferta>("ObtenerOfertasRevisadas", new { Cantidad = cantidad });

    public static int ContarOfertasPendientes() => Valor<int>("ContarOfertasPendientes");

    public static bool RevisarOferta(int idOferta, bool aprobada, string? motivo) =>
        Cambio("RevisarOferta", new { ID = idOferta, Aprobada = aprobada, Motivo = motivo });

    public static List<Oferta> GuardarOfertasExternas(List<OfertaExternaDatos> ofertas)
    {
        if (ofertas.Count == 0)
        {
            return new List<Oferta>();
        }

        var guardadas = new Dictionary<string, Oferta>();
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        foreach (var o in ofertas)
        {
            var guardada = conexion.QueryFirstOrDefault<Oferta>("GuardarOfertaExterna", new
            {
                o.ID_Externo,
                o.Titulo,
                o.Empresa,
                o.Logo,
                o.Ubicacion,
                o.Descripcion,
                o.Es_Remoto,
                o.Tipo_Contrato,
                o.Salario,
                o.Link_Postulacion,
                o.Publicador,
                o.Fecha_Publicacion
            }, tx, commandType: SP);
            if (guardada != null)
            {
                guardadas[o.ID_Externo] = guardada;
            }
        }
        tx.Commit();

        return ofertas.Select(o => o.ID_Externo).Distinct().Where(guardadas.ContainsKey).Select(id => guardadas[id]).ToList();
    }

    public static Oferta? ObtenerOfertaExterna(int id, int idUsuarioActual) =>
        Uno<Oferta>("ObtenerOfertaExterna", new { ID = id, IDUsuarioActual = idUsuarioActual });

    public static void MarcarPostuladas(List<Oferta> ofertas, int idUsuario)
    {
        var externas = ofertas.Where(o => o.EsExterna).Select(o => o.ID).ToList();
        if (externas.Count == 0 || idUsuario == 0)
        {
            return;
        }
        var marcas = Lista<(int ID, bool YaPostulado, bool Guardada)>("ObtenerMarcasExternas",
            new { IDUsuario = idUsuario, IDs = string.Join(",", externas) }).ToDictionary(m => m.ID);
        foreach (var oferta in ofertas.Where(o => o.EsExterna))
        {
            var marca = marcas.GetValueOrDefault(oferta.ID);
            oferta.YaPostulado = marca.YaPostulado;
            oferta.Guardada = marca.Guardada;
        }
    }

    public static bool GuardarOferta(int idUsuario, int idOferta, bool esExterna) =>
        Valor<bool>("GuardarOferta", new { IDUsuario = idUsuario, IDOferta = idOferta, EsExterna = esExterna });

    public static bool QuitarGuardada(int idUsuario, int idOferta, bool esExterna) =>
        Cambio("QuitarGuardada", new { IDUsuario = idUsuario, IDOferta = idOferta, EsExterna = esExterna });

    public static List<Oferta> ObtenerGuardadas(int idUsuario)
    {
        using var conexion = Conectar();
        using var lectura = conexion.QueryMultiple("ObtenerGuardadas", new { IDUsuario = idUsuario }, commandType: SP);
        var workly = lectura.Read<Oferta>().ToList();
        var externas = lectura.Read<Oferta>().ToList();
        return workly.Concat(externas).OrderByDescending(o => o.IDFavorito).ToList();
    }

    public static int ContarGuardadas(int idUsuario) =>
        Valor<int>("ContarGuardadas", new { IDUsuario = idUsuario });

    public static bool Postular(int idUsuario, int idOferta) =>
        Cambio("Postular", new { IDUsuario = idUsuario, IDOferta = idOferta });

    public static bool RegistrarPostulacionExterna(int idUsuario, int idOfertaExterna) =>
        Cambio("RegistrarPostulacionExterna", new { IDUsuario = idUsuario, IDOferta = idOfertaExterna });

    public static List<PostulacionItem> ObtenerPostulaciones(int idUsuario) =>
        Lista<PostulacionItem>("ObtenerPostulaciones", new { IDUsuario = idUsuario });

    public static bool CambiarEstadoPostulacion(int idUsuario, int idPostulacion, string estado) =>
        Cambio("CambiarEstadoPostulacion", new { IDUsuario = idUsuario, ID = idPostulacion, Estado = estado });

    public static bool EliminarPostulacion(int idUsuario, int idPostulacion) =>
        Cambio("EliminarPostulacion", new { IDUsuario = idUsuario, ID = idPostulacion });

    public static Dictionary<string, int> ContarPostulacionesPorEstado(int idUsuario)
    {
        var cuentas = Lista<(string Estado, int Cantidad)>("ContarPostulacionesPorEstado", new { IDUsuario = idUsuario })
            .ToDictionary(c => c.Estado, c => c.Cantidad);
        return Catalogos.EstadosPostulacion.ToDictionary(e => e.Estado, e => cuentas.GetValueOrDefault(e.Estado));
    }

    public static List<Postulante> ObtenerPostulantes(int idOferta) =>
        Lista<Postulante>("ObtenerPostulantes", new { IDOferta = idOferta });

    public static (int IDUsuario, int IDOferta)? ObtenerPostulacionDePublicador(int idPostulacion, int idPublicador)
    {
        var filas = Lista<(int IDUsuario, int IDOferta)>("ObtenerPostulacionDePublicador", new { ID = idPostulacion, IDPublicador = idPublicador });
        return filas.Count == 0 ? null : filas[0];
    }
}
