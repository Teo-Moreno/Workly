using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;

namespace Workly.Models;

/// <summary>
/// Acceso a la base de datos Workly (SQL Server) con Dapper.
/// La cadena de conexión se configura en appsettings.json › ConnectionStrings › Workly.
/// Todas las consultas usan parámetros (@Nombre, @Email...) para evitar inyección SQL.
/// </summary>
public static class BD
{
    private static string _connectionString = "";

    public static void Configurar(string connectionString)
    {
        _connectionString = connectionString;
    }

    private static SqlConnection Conectar() => new(_connectionString);

    // Para buscar con LIKE sin que %, _ o [ que escribió la persona funcionen como comodines
    private static string? Like(string? texto) =>
        string.IsNullOrWhiteSpace(texto)
            ? null
            : "%" + texto.Trim().Replace("[", "[[]").Replace("%", "[%]").Replace("_", "[_]") + "%";

    // =====================================================================
    // Usuario y cuenta
    // =====================================================================

    private const string ColumnasUsuario = "ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo, Es_Moderador";

    public static Usuario? ObtenerUsuarioPorEmail(string email)
    {
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<Usuario>($"SELECT {ColumnasUsuario} FROM Usuario WHERE Email = @Email", new { Email = email });
    }

    public static Usuario? ObtenerUsuarioPorId(int id)
    {
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<Usuario>($"SELECT {ColumnasUsuario} FROM Usuario WHERE ID = @ID", new { ID = id });
    }

    public static bool ExisteEmail(string email, int? exceptoIdUsuario = null)
    {
        const string sql = "SELECT CASE WHEN EXISTS (SELECT 1 FROM Usuario WHERE Email = @Email AND ID <> ISNULL(@Excepto, 0)) THEN 1 ELSE 0 END";
        using var conexion = Conectar();
        return conexion.ExecuteScalar<int>(sql, new { Email = email, Excepto = exceptoIdUsuario }) == 1;
    }

    /// <summary>
    /// Registra una persona con todo lo que cargó: perfil, CV, preferencias, habilidades,
    /// idiomas, experiencia y formación. Todo en una transacción. Devuelve el ID nuevo.
    /// </summary>
    public static int RegistrarPersona(PersonaNueva datos)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();

        var id = InsertarUsuario(conexion, tx, datos.Usuario, Usuario.TipoPersona);

        conexion.Execute(@"INSERT INTO Perfil (IDUsuario, IDProvincia, Foto, Descripcion, Telefono, Estado_Busqueda)
                           VALUES (@IDUsuario, @IDProvincia, @Foto, @Descripcion, @Telefono, @Estado_Busqueda)",
            new { IDUsuario = id, datos.Perfil.IDProvincia, datos.Perfil.Foto, datos.Perfil.Descripcion, datos.Perfil.Telefono, datos.Perfil.Estado_Busqueda }, tx);

        if (datos.CV != null)
        {
            conexion.Execute(@"INSERT INTO CV (IDUsuario, Nombre_Archivo, Sitio_Web, Fecha_Actualizacion)
                               VALUES (@IDUsuario, @Nombre_Archivo, @Sitio_Web, CAST(GETDATE() AS DATE))",
                new { IDUsuario = id, datos.CV.Nombre_Archivo, datos.CV.Sitio_Web }, tx);
        }

        if (datos.Preferencia != null)
        {
            datos.Preferencia.IDUsuario = id;
            GuardarPreferencia(conexion, tx, datos.Preferencia);
        }

        GuardarHabilidades(conexion, tx, id, datos.Habilidades);
        GuardarIdiomas(conexion, tx, id, datos.Idiomas);
        foreach (var experiencia in datos.Experiencias)
        {
            AgregarExperiencia(conexion, tx, id, experiencia);
        }
        foreach (var formacion in datos.Formaciones)
        {
            AgregarFormacion(conexion, tx, id, formacion);
        }
        if (datos.LoginExterno != null)
        {
            VincularLoginExterno(conexion, tx, id, datos.LoginExterno);
        }

        tx.Commit();
        return id;
    }

    /// <summary>
    /// Registra una cuenta de empresa. Si la empresa ya existía sin cuenta (porque alguien la
    /// cargó en su experiencia), se le asigna esta cuenta. Devuelve el ID del usuario nuevo.
    /// </summary>
    public static int RegistrarEmpresa(EmpresaNueva datos)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();

        var id = InsertarUsuario(conexion, tx, datos.Usuario, Usuario.TipoEmpresa);
        var e = datos.Empresa;
        var existente = conexion.QueryFirstOrDefault<int?>("SELECT ID FROM Empresa WHERE Nombre = @Nombre AND IDUsuario IS NULL", new { e.Nombre }, tx);
        var parametros = new { IDEmpresa = existente, IDUsuario = id, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.Razon_Social, e.CUIT, e.Rubro, e.IDProvincia, e.Telefono };
        if (existente.HasValue)
        {
            conexion.Execute(@"UPDATE Empresa SET IDUsuario = @IDUsuario, Descripcion = @Descripcion, Logo = @Logo, Ubicacion = @Ubicacion,
                                   Sitio_Web = @Sitio_Web, Razon_Social = @Razon_Social, CUIT = @CUIT, Rubro = @Rubro,
                                   IDProvincia = @IDProvincia, Telefono = @Telefono
                               WHERE ID = @IDEmpresa", parametros, tx);
        }
        else
        {
            conexion.Execute(@"INSERT INTO Empresa (Nombre, Descripcion, Logo, Ubicacion, Sitio_Web, IDUsuario, Razon_Social, CUIT, Rubro, IDProvincia, Telefono)
                               VALUES (@Nombre, @Descripcion, @Logo, @Ubicacion, @Sitio_Web, @IDUsuario, @Razon_Social, @CUIT, @Rubro, @IDProvincia, @Telefono)",
                parametros, tx);
        }

        if (datos.LoginExterno != null)
        {
            VincularLoginExterno(conexion, tx, id, datos.LoginExterno);
        }

        tx.Commit();
        return id;
    }

    private static int InsertarUsuario(IDbConnection conexion, IDbTransaction tx, Usuario u, string tipo) =>
        conexion.ExecuteScalar<int>(@"INSERT INTO Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
                                      OUTPUT INSERTED.ID
                                      VALUES (@Nombre, @Apellido, @Email, @Contrasena, CAST(GETDATE() AS DATE), @Tipo)",
            new { u.Nombre, u.Apellido, u.Email, Contrasena = u.Contraseña, Tipo = tipo }, tx);

    // ---------------------------------------------------- Google y LinkedIn

    public static int? ObtenerUsuarioDeLoginExterno(string proveedor, string idExterno)
    {
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<int?>("SELECT IDUsuario FROM LoginExterno WHERE Proveedor = @Proveedor AND ID_Externo = @ID",
            new { Proveedor = proveedor, ID = idExterno });
    }

    public static void VincularLoginExterno(int idUsuario, LoginExternoNuevo login)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        VincularLoginExterno(conexion, tx, idUsuario, login);
        tx.Commit();
    }

    private static void VincularLoginExterno(IDbConnection conexion, IDbTransaction tx, int idUsuario, LoginExternoNuevo login) =>
        conexion.Execute(@"IF NOT EXISTS (SELECT 1 FROM LoginExterno WHERE Proveedor = @Proveedor AND ID_Externo = @ID_Externo)
                           INSERT INTO LoginExterno (IDUsuario, Proveedor, ID_Externo) VALUES (@IDUsuario, @Proveedor, @ID_Externo)",
            new { IDUsuario = idUsuario, login.Proveedor, login.ID_Externo }, tx);

    public static List<string> ObtenerProveedoresVinculados(int idUsuario)
    {
        using var conexion = Conectar();
        return conexion.Query<string>("SELECT Proveedor FROM LoginExterno WHERE IDUsuario = @ID", new { ID = idUsuario }).ToList();
    }

    // ---------------------------------------------------- Datos de la cuenta

    public static void ActualizarDatosPersonales(int idUsuario, string nombre, string apellido, string email, int? idProvincia, string? telefono, string? sitioWeb)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        conexion.Execute("UPDATE Usuario SET Nombre = @Nombre, Apellido = @Apellido, Email = @Email WHERE ID = @ID",
            new { ID = idUsuario, Nombre = nombre, Apellido = apellido, Email = email }, tx);
        AsegurarPerfil(conexion, tx, idUsuario);
        conexion.Execute("UPDATE Perfil SET IDProvincia = @IDProvincia, Telefono = @Telefono WHERE IDUsuario = @ID",
            new { ID = idUsuario, IDProvincia = idProvincia, Telefono = telefono }, tx);
        GuardarCV(conexion, tx, idUsuario, sitioWeb: sitioWeb, cambiarSitio: true);
        tx.Commit();
    }

    public static void ActualizarResponsable(int idUsuario, string nombre, string apellido)
    {
        using var conexion = Conectar();
        conexion.Execute("UPDATE Usuario SET Nombre = @Nombre, Apellido = @Apellido WHERE ID = @ID",
            new { ID = idUsuario, Nombre = nombre, Apellido = apellido });
    }

    public static void CambiarContrasena(int idUsuario, string hash)
    {
        using var conexion = Conectar();
        conexion.Execute("UPDATE Usuario SET [Contraseña] = @Hash WHERE ID = @ID", new { ID = idUsuario, Hash = hash });
    }

    private static void AsegurarPerfil(IDbConnection conexion, IDbTransaction? tx, int idUsuario) =>
        conexion.Execute("IF NOT EXISTS (SELECT 1 FROM Perfil WHERE IDUsuario = @ID) INSERT INTO Perfil (IDUsuario) VALUES (@ID)",
            new { ID = idUsuario }, tx);

    /// <summary>Cambia la foto y devuelve la anterior (para borrar el archivo).</summary>
    public static string? ActualizarFoto(int idUsuario, string? ruta)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        AsegurarPerfil(conexion, tx, idUsuario);
        var anterior = conexion.ExecuteScalar<string?>("SELECT Foto FROM Perfil WHERE IDUsuario = @ID", new { ID = idUsuario }, tx);
        conexion.Execute("UPDATE Perfil SET Foto = @Foto WHERE IDUsuario = @ID", new { ID = idUsuario, Foto = ruta }, tx);
        tx.Commit();
        return anterior;
    }

    public static void ActualizarDescripcion(int idUsuario, string? descripcion)
    {
        using var conexion = Conectar();
        AsegurarPerfil(conexion, null, idUsuario);
        conexion.Execute("UPDATE Perfil SET Descripcion = @Descripcion WHERE IDUsuario = @ID", new { ID = idUsuario, Descripcion = descripcion });
    }

    public static void ActualizarEstadoBusqueda(int idUsuario, string? estado)
    {
        using var conexion = Conectar();
        AsegurarPerfil(conexion, null, idUsuario);
        conexion.Execute("UPDATE Perfil SET Estado_Busqueda = @Estado WHERE IDUsuario = @ID", new { ID = idUsuario, Estado = estado });
    }

    /// <summary>Cambia el archivo del CV y devuelve el anterior (para borrarlo del disco).</summary>
    public static string? ActualizarArchivoCV(int idUsuario, string? nombreArchivo)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        var anterior = conexion.ExecuteScalar<string?>("SELECT Nombre_Archivo FROM CV WHERE IDUsuario = @ID", new { ID = idUsuario }, tx);
        GuardarCV(conexion, tx, idUsuario, nombreArchivo: nombreArchivo, cambiarArchivo: true);
        tx.Commit();
        return anterior;
    }

    private static void GuardarCV(IDbConnection conexion, IDbTransaction tx, int idUsuario,
                                  string? nombreArchivo = null, bool cambiarArchivo = false, string? sitioWeb = null, bool cambiarSitio = false)
    {
        conexion.Execute(@"IF NOT EXISTS (SELECT 1 FROM CV WHERE IDUsuario = @ID)
                               INSERT INTO CV (IDUsuario, Fecha_Actualizacion) VALUES (@ID, CAST(GETDATE() AS DATE));
                           UPDATE CV SET
                               Nombre_Archivo = CASE WHEN @CambiarArchivo = 1 THEN @Archivo ELSE Nombre_Archivo END,
                               Sitio_Web = CASE WHEN @CambiarSitio = 1 THEN @Sitio ELSE Sitio_Web END,
                               Fecha_Actualizacion = CAST(GETDATE() AS DATE)
                           WHERE IDUsuario = @ID",
            new { ID = idUsuario, Archivo = nombreArchivo, CambiarArchivo = cambiarArchivo, Sitio = sitioWeb, CambiarSitio = cambiarSitio }, tx);
    }

    /// <summary>
    /// Borra la cuenta y todo lo suyo. Las búsquedas que publicó se borran con sus postulaciones.
    /// Devuelve los archivos (foto, CV, logo) que hay que borrar del disco.
    /// </summary>
    public static (string? Foto, string? CV, string? Logo) EliminarCuenta(int idUsuario)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();

        var foto = conexion.ExecuteScalar<string?>("SELECT Foto FROM Perfil WHERE IDUsuario = @ID", new { ID = idUsuario }, tx);
        var cv = conexion.ExecuteScalar<string?>("SELECT Nombre_Archivo FROM CV WHERE IDUsuario = @ID", new { ID = idUsuario }, tx);
        var logo = conexion.ExecuteScalar<string?>("SELECT Logo FROM Empresa WHERE IDUsuario = @ID", new { ID = idUsuario }, tx);

        conexion.Execute(@"
            DECLARE @Ofertas TABLE (ID INT);
            INSERT INTO @Ofertas
            SELECT o.ID FROM OfertaLaboral o
            WHERE o.IDUsuario_Publicador = @ID OR o.IDEmpresa IN (SELECT ID FROM Empresa WHERE IDUsuario = @ID);

            DELETE FROM Postulacion WHERE IDOfertaLaboral IN (SELECT ID FROM @Ofertas);
            DELETE FROM FavoritoOferta WHERE IDOfertaLaboral IN (SELECT ID FROM @Ofertas);
            DELETE FROM OfertaLaboral WHERE ID IN (SELECT ID FROM @Ofertas);

            -- La empresa queda (puede figurar en experiencias de otras personas) pero sin cuenta ni CUIT
            UPDATE Empresa SET IDUsuario = NULL, CUIT = NULL, Razon_Social = NULL, Logo = NULL WHERE IDUsuario = @ID;

            DELETE FROM Usuario WHERE ID = @ID;", new { ID = idUsuario }, tx);

        tx.Commit();
        return (foto, cv, logo);
    }

    // =====================================================================
    // Países y provincias
    // =====================================================================

    public static List<Pais> ObtenerPaises()
    {
        using var conexion = Conectar();
        return conexion.Query<Pais>("SELECT ID, Nombre, Codigo_ISO, Codigo_Telefono FROM Pais ORDER BY Nombre").ToList();
    }

    public static List<Provincia> ObtenerProvincias()
    {
        using var conexion = Conectar();
        return conexion.Query<Provincia>("SELECT ID, IDPais, Nombre FROM Provincia ORDER BY Nombre").ToList();
    }

    // =====================================================================
    // Perfil, preferencias, habilidades e idiomas
    // =====================================================================

    public static Perfil? ObtenerPerfil(int idUsuario)
    {
        const string sql = @"SELECT pe.ID, pe.IDUsuario, pe.IDProvincia, pe.Foto, pe.Descripcion, pe.Telefono, pe.Estado_Busqueda,
                                    pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais, pa.Codigo_Telefono
                             FROM Perfil pe
                             LEFT JOIN Provincia pr ON pr.ID = pe.IDProvincia
                             LEFT JOIN Pais pa ON pa.ID = pr.IDPais
                             WHERE pe.IDUsuario = @IDUsuario";
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<Perfil>(sql, new { IDUsuario = idUsuario });
    }

    public static CV? ObtenerCV(int idUsuario)
    {
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<CV>("SELECT ID, IDUsuario, Nombre_Archivo, Sitio_Web, Fecha_Actualizacion FROM CV WHERE IDUsuario = @ID",
            new { ID = idUsuario });
    }

    public static Preferencia? ObtenerPreferencia(int idUsuario)
    {
        const string sql = @"SELECT p.*, pr.Nombre AS Provincia FROM Preferencia p
                             LEFT JOIN Provincia pr ON pr.ID = p.IDProvincia
                             WHERE p.IDUsuario = @ID";
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<Preferencia>(sql, new { ID = idUsuario });
    }

    /// <summary>Guarda las preferencias, las habilidades, los idiomas y el estado de búsqueda juntos.</summary>
    public static void GuardarBusqueda(int idUsuario, Preferencia preferencia, string? estadoBusqueda, List<string> habilidades, List<(int, string)> idiomas)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        preferencia.IDUsuario = idUsuario;
        GuardarPreferencia(conexion, tx, preferencia);
        AsegurarPerfil(conexion, tx, idUsuario);
        conexion.Execute("UPDATE Perfil SET Estado_Busqueda = @Estado WHERE IDUsuario = @ID", new { ID = idUsuario, Estado = estadoBusqueda }, tx);
        GuardarHabilidades(conexion, tx, idUsuario, habilidades);
        GuardarIdiomas(conexion, tx, idUsuario, idiomas);
        tx.Commit();
    }

    private static void GuardarPreferencia(IDbConnection conexion, IDbTransaction tx, Preferencia p) =>
        conexion.Execute(@"IF NOT EXISTS (SELECT 1 FROM Preferencia WHERE IDUsuario = @IDUsuario)
                               INSERT INTO Preferencia (IDUsuario) VALUES (@IDUsuario);
                           UPDATE Preferencia SET Puesto_Buscado = @Puesto_Buscado, Niveles = @Niveles, Modalidades = @Modalidades,
                               Jornada = @Jornada, Contratacion = @Contratacion, IDProvincia = @IDProvincia,
                               Salario_Minimo = @Salario_Minimo, Salario_Maximo = @Salario_Maximo, Disponibilidad = @Disponibilidad
                           WHERE IDUsuario = @IDUsuario",
            new { p.IDUsuario, p.Puesto_Buscado, p.Niveles, p.Modalidades, p.Jornada, p.Contratacion, p.IDProvincia, p.Salario_Minimo, p.Salario_Maximo, p.Disponibilidad }, tx);

    public static List<Habilidad> ObtenerCatalogoHabilidades()
    {
        using var conexion = Conectar();
        return conexion.Query<Habilidad>("SELECT ID, Nombre FROM Habilidad ORDER BY Nombre").ToList();
    }

    public static List<string> ObtenerHabilidadesUsuario(int idUsuario)
    {
        using var conexion = Conectar();
        return conexion.Query<string>(@"SELECT h.Nombre FROM UsuarioHabilidad uh JOIN Habilidad h ON h.ID = uh.IDHabilidad
                                         WHERE uh.IDUsuario = @ID ORDER BY h.Nombre", new { ID = idUsuario }).ToList();
    }

    // Reemplaza las habilidades de la persona. Las que no están en el catálogo se agregan.
    private static void GuardarHabilidades(IDbConnection conexion, IDbTransaction tx, int idUsuario, List<string> nombres)
    {
        conexion.Execute("DELETE FROM UsuarioHabilidad WHERE IDUsuario = @ID", new { ID = idUsuario }, tx);
        foreach (var nombre in nombres.Select(n => n.Trim()).Where(n => n.Length > 0).Distinct(StringComparer.OrdinalIgnoreCase))
        {
            conexion.Execute(@"IF NOT EXISTS (SELECT 1 FROM Habilidad WHERE Nombre = @Nombre) INSERT INTO Habilidad (Nombre) VALUES (@Nombre);
                               INSERT INTO UsuarioHabilidad (IDUsuario, IDHabilidad)
                               SELECT @ID, h.ID FROM Habilidad h WHERE h.Nombre = @Nombre
                                 AND NOT EXISTS (SELECT 1 FROM UsuarioHabilidad WHERE IDUsuario = @ID AND IDHabilidad = h.ID)",
                new { ID = idUsuario, Nombre = nombre }, tx);
        }
    }

    public static List<Idioma> ObtenerCatalogoIdiomas()
    {
        using var conexion = Conectar();
        return conexion.Query<Idioma>("SELECT ID, Nombre FROM Idioma ORDER BY Nombre").ToList();
    }

    public static List<IdiomaElegido> ObtenerIdiomasUsuario(int idUsuario)
    {
        using var conexion = Conectar();
        return conexion.Query<IdiomaElegido>(@"SELECT ui.IDIdioma, i.Nombre AS Idioma, ui.Nivel FROM UsuarioIdioma ui
                                                JOIN Idioma i ON i.ID = ui.IDIdioma WHERE ui.IDUsuario = @ID ORDER BY i.Nombre",
            new { ID = idUsuario }).ToList();
    }

    private static void GuardarIdiomas(IDbConnection conexion, IDbTransaction tx, int idUsuario, List<(int IDIdioma, string Nivel)> idiomas)
    {
        conexion.Execute("DELETE FROM UsuarioIdioma WHERE IDUsuario = @ID", new { ID = idUsuario }, tx);
        foreach (var (idIdioma, nivel) in idiomas.GroupBy(i => i.IDIdioma).Select(g => g.Last()))
        {
            conexion.Execute("INSERT INTO UsuarioIdioma (IDUsuario, IDIdioma, Nivel) VALUES (@ID, @IDIdioma, @Nivel)",
                new { ID = idUsuario, IDIdioma = idIdioma, Nivel = nivel }, tx);
        }
    }

    // =====================================================================
    // Experiencia laboral y formación
    // =====================================================================

    public static List<ExperienciaItem> ObtenerExperiencias(int idUsuario)
    {
        const string sql = @"SELECT x.ID, x.Puesto, e.Nombre AS Empresa, x.Descripcion, x.Fecha_Inicio, x.Fecha_Finalizacion
                             FROM ExperienciaLaboral x
                             JOIN Empresa e ON e.ID = x.IDEmpresa
                             WHERE x.IDUsuario = @IDUsuario
                             ORDER BY CASE WHEN x.Fecha_Finalizacion IS NULL THEN 0 ELSE 1 END, x.Fecha_Inicio DESC";
        using var conexion = Conectar();
        return conexion.Query<ExperienciaItem>(sql, new { IDUsuario = idUsuario }).ToList();
    }

    public static void AgregarExperiencia(int idUsuario, ExperienciaNueva experiencia)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        AgregarExperiencia(conexion, tx, idUsuario, experiencia);
        tx.Commit();
    }

    private static void AgregarExperiencia(IDbConnection conexion, IDbTransaction tx, int idUsuario, ExperienciaNueva x)
    {
        var idEmpresa = ObtenerOCrearEmpresa(conexion, tx, x.Empresa);
        conexion.Execute(@"INSERT INTO ExperienciaLaboral (IDUsuario, IDEmpresa, Puesto, Descripcion, Fecha_Inicio, Fecha_Finalizacion)
                           VALUES (@IDUsuario, @IDEmpresa, @Puesto, @Descripcion, @Inicio, @Fin)",
            new { IDUsuario = idUsuario, IDEmpresa = idEmpresa, x.Puesto, x.Descripcion, x.Inicio, x.Fin }, tx);
    }

    public static bool EliminarExperiencia(int idUsuario, int idExperiencia)
    {
        using var conexion = Conectar();
        return conexion.Execute("DELETE FROM ExperienciaLaboral WHERE ID = @ID AND IDUsuario = @IDUsuario",
            new { ID = idExperiencia, IDUsuario = idUsuario }) > 0;
    }

    public static List<FormacionItem> ObtenerFormaciones(int idUsuario)
    {
        const string sql = @"SELECT ue.ID, ue.Titulo, ed.Institucion, ue.Fecha_Inicio, ue.Fecha_Fin
                             FROM UsuarioEducacion ue
                             JOIN Educacion ed ON ed.ID = ue.IDEducacion
                             WHERE ue.IDUsuario = @IDUsuario
                             ORDER BY CASE WHEN ue.Fecha_Fin IS NULL THEN 0 ELSE 1 END, ue.Fecha_Inicio DESC";
        using var conexion = Conectar();
        return conexion.Query<FormacionItem>(sql, new { IDUsuario = idUsuario }).ToList();
    }

    public static void AgregarFormacion(int idUsuario, FormacionNueva formacion)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        AgregarFormacion(conexion, tx, idUsuario, formacion);
        tx.Commit();
    }

    private static void AgregarFormacion(IDbConnection conexion, IDbTransaction tx, int idUsuario, FormacionNueva f)
    {
        var idEducacion = conexion.ExecuteScalar<int>(@"
            IF NOT EXISTS (SELECT 1 FROM Educacion WHERE Institucion = @Institucion)
                INSERT INTO Educacion (Institucion) VALUES (@Institucion);
            SELECT ID FROM Educacion WHERE Institucion = @Institucion;", new { f.Institucion }, tx);
        conexion.Execute(@"INSERT INTO UsuarioEducacion (IDUsuario, IDEducacion, Titulo, Fecha_Inicio, Fecha_Fin)
                           VALUES (@IDUsuario, @IDEducacion, @Titulo, @Inicio, @Fin)",
            new { IDUsuario = idUsuario, IDEducacion = idEducacion, f.Titulo, f.Inicio, f.Fin }, tx);
    }

    public static bool EliminarFormacion(int idUsuario, int idFormacion)
    {
        using var conexion = Conectar();
        return conexion.Execute("DELETE FROM UsuarioEducacion WHERE ID = @ID AND IDUsuario = @IDUsuario",
            new { ID = idFormacion, IDUsuario = idUsuario }) > 0;
    }

    public static List<string> ObtenerInstituciones()
    {
        using var conexion = Conectar();
        return conexion.Query<string>("SELECT Institucion FROM Educacion ORDER BY Institucion").ToList();
    }

    // Empresa por nombre (se crea sin cuenta si no existe)
    private static int ObtenerOCrearEmpresa(IDbConnection conexion, IDbTransaction tx, string nombre) =>
        conexion.ExecuteScalar<int>(@"
            IF NOT EXISTS (SELECT 1 FROM Empresa WHERE Nombre = @Nombre)
                INSERT INTO Empresa (Nombre) VALUES (@Nombre);
            SELECT ID FROM Empresa WHERE Nombre = @Nombre;", new { Nombre = nombre }, tx);

    /// <summary>Junta todo lo que necesitan "Mi perfil" y "Configuración".</summary>
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

    // =====================================================================
    // Empresas
    // =====================================================================

    private const string SelectEmpresa = @"
        SELECT e.ID, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.IDUsuario, e.Razon_Social, e.CUIT,
               e.Rubro, e.IDProvincia, e.Telefono, e.Fecha_Registro, pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais,
               (SELECT COUNT(*) FROM OfertaLaboral o
                WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'
                  AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))) AS BusquedasActivas
        FROM Empresa e
        LEFT JOIN Provincia pr ON pr.ID = e.IDProvincia
        LEFT JOIN Pais pa ON pa.ID = pr.IDPais";

    // Se muestran las empresas con cuenta y las que tienen búsquedas publicadas
    private const string EmpresaVisible = @"(e.IDUsuario IS NOT NULL OR EXISTS (SELECT 1 FROM OfertaLaboral o
                                              WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'))";

    public static List<Empresa> BuscarEmpresas(string? texto, string? rubro, int? idPais, int? idProvincia, string? orden)
    {
        var ordenSql = orden switch
        {
            "az" => "e.Nombre",
            "antiguas" => "e.Fecha_Registro, e.ID",
            _ => "e.Fecha_Registro DESC, e.ID DESC"
        };
        var sql = $@"{SelectEmpresa}
                     WHERE {EmpresaVisible}
                       AND (@Texto IS NULL OR e.Nombre LIKE @Texto OR e.Descripcion LIKE @Texto)
                       AND (@Rubro IS NULL OR e.Rubro = @Rubro)
                       AND (@IDProvincia IS NULL OR e.IDProvincia = @IDProvincia)
                       AND (@IDPais IS NULL OR pa.ID = @IDPais)
                     ORDER BY {ordenSql}";
        using var conexion = Conectar();
        return conexion.Query<Empresa>(sql, new { Texto = Like(texto), Rubro = rubro, IDPais = idPais, IDProvincia = idProvincia }).ToList();
    }

    public static List<Empresa> ObtenerEmpresasConBusquedas(int cantidad)
    {
        using var conexion = Conectar();
        return conexion.Query<Empresa>($@"SELECT TOP (@Cantidad) * FROM ({SelectEmpresa}) x WHERE x.BusquedasActivas > 0 ORDER BY x.BusquedasActivas DESC, x.Nombre",
            new { Cantidad = cantidad }).ToList();
    }

    public static Empresa? ObtenerEmpresa(int idEmpresa)
    {
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<Empresa>($"{SelectEmpresa} WHERE e.ID = @ID", new { ID = idEmpresa });
    }

    public static Empresa? ObtenerEmpresaDeUsuario(int idUsuario)
    {
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<Empresa>($"{SelectEmpresa} WHERE e.IDUsuario = @ID", new { ID = idUsuario });
    }

    public static bool ExisteCuit(string cuit)
    {
        using var conexion = Conectar();
        return conexion.ExecuteScalar<int>("SELECT COUNT(*) FROM Empresa WHERE CUIT = @CUIT", new { CUIT = cuit }) > 0;
    }

    /// <summary>Hay una empresa con ese nombre que ya tiene cuenta (otra que la indicada).</summary>
    public static bool NombreEmpresaConCuenta(string nombre, int? exceptoIdEmpresa = null)
    {
        using var conexion = Conectar();
        return conexion.ExecuteScalar<int>("SELECT COUNT(*) FROM Empresa WHERE Nombre = @Nombre AND IDUsuario IS NOT NULL AND ID <> ISNULL(@Excepto, 0)",
            new { Nombre = nombre, Excepto = exceptoIdEmpresa }) > 0;
    }

    /// <summary>Hay otra empresa (con o sin cuenta) con ese nombre.</summary>
    public static bool ExisteNombreEmpresa(string nombre, int exceptoIdEmpresa)
    {
        using var conexion = Conectar();
        return conexion.ExecuteScalar<int>("SELECT COUNT(*) FROM Empresa WHERE Nombre = @Nombre AND ID <> @Excepto",
            new { Nombre = nombre, Excepto = exceptoIdEmpresa }) > 0;
    }

    public static void ActualizarEmpresa(Empresa e)
    {
        using var conexion = Conectar();
        conexion.Execute(@"UPDATE Empresa SET Nombre = @Nombre, Descripcion = @Descripcion, Ubicacion = @Ubicacion, Sitio_Web = @Sitio_Web,
                               Rubro = @Rubro, IDProvincia = @IDProvincia, Telefono = @Telefono
                           WHERE ID = @ID AND IDUsuario = @IDUsuario", e);
    }

    /// <summary>Cambia el logo y devuelve el anterior (para borrar el archivo).</summary>
    public static string? ActualizarLogo(int idUsuario, string? ruta)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        var anterior = conexion.ExecuteScalar<string?>("SELECT Logo FROM Empresa WHERE IDUsuario = @ID", new { ID = idUsuario }, tx);
        conexion.Execute("UPDATE Empresa SET Logo = @Logo WHERE IDUsuario = @ID", new { ID = idUsuario, Logo = ruta }, tx);
        tx.Commit();
        return anterior;
    }

    // =====================================================================
    // Ofertas de Workly
    // =====================================================================

    private const string SelectOferta = @"
        SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
               pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
               CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
               o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
               (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
               (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
               CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                    THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado
        FROM OfertaLaboral o
        JOIN Empresa e ON e.ID = o.IDEmpresa
        LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
        LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia";

    private const string OfertaPublica = @"o.Estado_Publicacion = N'Aprobada' AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))";

    /// <summary>Ofertas publicadas y abiertas que cumplen los filtros (las remotas valen para cualquier provincia).</summary>
    public static List<Oferta> BuscarOfertas(FiltrosOfertas f, int idUsuarioActual)
    {
        var sql = $@"{SelectOferta}
                     WHERE {OfertaPublica}
                       AND (@Texto IS NULL OR o.Titulo LIKE @Texto OR o.Descripcion LIKE @Texto OR e.Nombre LIKE @Texto
                            OR EXISTS (SELECT 1 FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
                                       WHERE op.IDOfertaLaboral = o.ID AND p.Nombre LIKE @Texto))
                       AND (@IDProvincia IS NULL OR o.IDProvincia = @IDProvincia OR o.Modalidad = N'Remoto')
                       AND (@SinModalidades = 1 OR o.Modalidad IN @Modalidades)
                       AND (@SinTipos = 1 OR o.Tipo_Contrato IN @Tipos)
                       AND (@Dias IS NULL OR o.Fecha_Publicacion >= DATEADD(DAY, -@Dias, CAST(GETDATE() AS DATE)))
                     ORDER BY o.Fecha_Publicacion DESC, o.ID DESC";
        using var conexion = Conectar();
        return conexion.Query<Oferta>(sql, new
        {
            IDUsuarioActual = idUsuarioActual,
            Texto = Like(f.Texto),
            f.IDProvincia,
            SinModalidades = f.Modalidades.Count == 0,
            Modalidades = f.Modalidades.DefaultIfEmpty("").ToList(),
            SinTipos = f.TiposEmpleo.Count == 0,
            Tipos = f.TiposEmpleo.DefaultIfEmpty("").ToList(),
            f.Dias
        }).ToList();
    }

    public static Oferta? ObtenerOferta(int idOferta, int idUsuarioActual)
    {
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<Oferta>($"{SelectOferta} WHERE o.ID = @ID", new { ID = idOferta, IDUsuarioActual = idUsuarioActual });
    }

    public static List<Oferta> ObtenerOfertasDeEmpresa(int idEmpresa, int idUsuarioActual)
    {
        using var conexion = Conectar();
        return conexion.Query<Oferta>($"{SelectOferta} WHERE o.IDEmpresa = @ID AND {OfertaPublica} ORDER BY o.Fecha_Publicacion DESC, o.ID DESC",
            new { ID = idEmpresa, IDUsuarioActual = idUsuarioActual }).ToList();
    }

    /// <summary>Las búsquedas que publicó una cuenta (cualquier estado), con su cantidad de postulantes.</summary>
    public static List<Oferta> ObtenerOfertasPublicadas(int idUsuario)
    {
        using var conexion = Conectar();
        return conexion.Query<Oferta>($"{SelectOferta} WHERE o.IDUsuario_Publicador = @ID ORDER BY o.Fecha_Publicacion DESC, o.ID DESC",
            new { ID = idUsuario, IDUsuarioActual = 0 }).ToList();
    }

    public static bool TieneOfertasPublicadas(int idUsuario)
    {
        using var conexion = Conectar();
        return conexion.ExecuteScalar<int>("SELECT COUNT(*) FROM OfertaLaboral WHERE IDUsuario_Publicador = @ID", new { ID = idUsuario }) > 0;
    }

    public static List<string> ObtenerTitulosRecientes(int cantidad)
    {
        using var conexion = Conectar();
        return conexion.Query<string>(@"SELECT TOP (@Cantidad) Titulo FROM (
                                            SELECT o.Titulo, CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha FROM OfertaLaboral o
                                            WHERE o.Estado_Publicacion = N'Aprobada'
                                            UNION ALL
                                            SELECT x.Titulo, x.Fecha_Consulta FROM OfertaExterna x) t
                                        ORDER BY Fecha DESC", new { Cantidad = cantidad }).ToList();
    }

    /// <summary>Publica una búsqueda. Devuelve su ID.</summary>
    public static int CrearOferta(OfertaNueva o)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        var idEmpresa = o.IDEmpresa ?? ObtenerOCrearEmpresa(conexion, tx, o.EmpresaNombre!);
        var id = conexion.ExecuteScalar<int>(@"
            INSERT INTO OfertaLaboral (IDEmpresa, Titulo, Descripcion, Ubicacion, Modalidad, Tipo_Contrato, Salario, Cantidad_Puestos,
                                       Fecha_Publicacion, Fecha_Cierre, IDUsuario_Publicador, IDProvincia, Estado_Publicacion)
            OUTPUT INSERTED.ID
            VALUES (@IDEmpresa, @Titulo, @Descripcion, @Ubicacion, @Modalidad, @Tipo_Contrato, @Salario, @Cantidad_Puestos,
                    CAST(GETDATE() AS DATE), @Fecha_Cierre, @IDUsuario_Publicador, @IDProvincia, @Estado_Publicacion)",
            new { IDEmpresa = idEmpresa, o.Titulo, o.Descripcion, o.Ubicacion, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos,
                  o.Fecha_Cierre, o.IDUsuario_Publicador, o.IDProvincia, o.Estado_Publicacion }, tx);
        conexion.Execute(@"IF NOT EXISTS (SELECT 1 FROM Puesto WHERE Nombre = @Puesto) INSERT INTO Puesto (Nombre) VALUES (@Puesto);
                           INSERT INTO OfertaPuesto (IDOfertaLaboral, IDPuesto) SELECT @ID, ID FROM Puesto WHERE Nombre = @Puesto;",
            new { ID = id, o.Puesto }, tx);
        tx.Commit();
        return id;
    }

    /// <summary>Cierra una búsqueda propia (deja de aparecer en Buscar trabajo).</summary>
    public static bool CerrarOferta(int idOferta, int idPublicador)
    {
        using var conexion = Conectar();
        return conexion.Execute(@"UPDATE OfertaLaboral SET Fecha_Cierre = CAST(GETDATE() AS DATE)
                                  WHERE ID = @ID AND IDUsuario_Publicador = @Publicador
                                    AND (Fecha_Cierre IS NULL OR Fecha_Cierre >= CAST(GETDATE() AS DATE))",
            new { ID = idOferta, Publicador = idPublicador }) > 0;
    }

    /// <summary>Borra una búsqueda propia junto con sus postulaciones.</summary>
    public static bool EliminarOferta(int idOferta, int idPublicador)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        var esSuya = conexion.ExecuteScalar<int>("SELECT COUNT(*) FROM OfertaLaboral WHERE ID = @ID AND IDUsuario_Publicador = @Publicador",
            new { ID = idOferta, Publicador = idPublicador }, tx) > 0;
        if (esSuya)
        {
            conexion.Execute(@"DELETE FROM Postulacion WHERE IDOfertaLaboral = @ID;
                               DELETE FROM FavoritoOferta WHERE IDOfertaLaboral = @ID;
                               DELETE FROM OfertaLaboral WHERE ID = @ID;", new { ID = idOferta }, tx);
        }
        tx.Commit();
        return esSuya;
    }

    // ---------------------------------------------------- Moderación

    public static List<Oferta> ObtenerOfertasPendientes()
    {
        using var conexion = Conectar();
        return conexion.Query<Oferta>($"{SelectOferta} WHERE o.Estado_Publicacion = N'Pendiente' ORDER BY o.Fecha_Publicacion, o.ID",
            new { IDUsuarioActual = 0 }).ToList();
    }

    public static List<Oferta> ObtenerOfertasRevisadas(int cantidad)
    {
        using var conexion = Conectar();
        return conexion.Query<Oferta>($@"SELECT TOP (@Cantidad) * FROM ({SelectOferta}
                                          WHERE o.Estado_Publicacion <> N'Pendiente' AND o.Fecha_Revision IS NOT NULL) x
                                          ORDER BY x.ID DESC",
            new { IDUsuarioActual = 0, Cantidad = cantidad }).ToList();
    }

    public static int ContarOfertasPendientes()
    {
        using var conexion = Conectar();
        return conexion.ExecuteScalar<int>("SELECT COUNT(*) FROM OfertaLaboral WHERE Estado_Publicacion = N'Pendiente'");
    }

    public static bool RevisarOferta(int idOferta, bool aprobada, string? motivo)
    {
        using var conexion = Conectar();
        return conexion.Execute(@"UPDATE OfertaLaboral SET Estado_Publicacion = @Estado, Motivo_Rechazo = @Motivo,
                                      Fecha_Revision = CAST(GETDATE() AS DATE),
                                      Fecha_Publicacion = CASE WHEN @Estado = N'Aprobada' THEN CAST(GETDATE() AS DATE) ELSE Fecha_Publicacion END
                                  WHERE ID = @ID AND Estado_Publicacion = N'Pendiente'",
            new { ID = idOferta, Estado = aprobada ? "Aprobada" : "Rechazada", Motivo = aprobada ? null : motivo }) > 0;
    }

    // =====================================================================
    // Ofertas externas (JSearch)
    // =====================================================================

    /// <summary>Guarda (o actualiza) las ofertas que trajo JSearch y las devuelve con su ID de Workly.</summary>
    public static List<Oferta> GuardarOfertasExternas(List<OfertaExternaDatos> ofertas)
    {
        if (ofertas.Count == 0)
        {
            return new List<Oferta>();
        }

        using var conexion = Conectar();
        conexion.Open();
        using var tx = conexion.BeginTransaction();
        foreach (var o in ofertas)
        {
            conexion.Execute(@"
                IF EXISTS (SELECT 1 FROM OfertaExterna WHERE ID_Externo = @ID_Externo)
                    UPDATE OfertaExterna SET Titulo = @Titulo, Empresa = @Empresa, Logo = @Logo, Ubicacion = @Ubicacion,
                        Descripcion = @Descripcion, Es_Remoto = @Es_Remoto, Tipo_Contrato = @Tipo_Contrato, Salario = @Salario,
                        Link_Postulacion = @Link_Postulacion, Publicador = @Publicador, Fecha_Publicacion = @Fecha_Publicacion,
                        Fecha_Consulta = SYSUTCDATETIME()
                    WHERE ID_Externo = @ID_Externo;
                ELSE
                    INSERT INTO OfertaExterna (ID_Externo, Titulo, Empresa, Logo, Ubicacion, Descripcion, Es_Remoto, Tipo_Contrato,
                                               Salario, Link_Postulacion, Publicador, Fecha_Publicacion)
                    VALUES (@ID_Externo, @Titulo, @Empresa, @Logo, @Ubicacion, @Descripcion, @Es_Remoto, @Tipo_Contrato,
                            @Salario, @Link_Postulacion, @Publicador, @Fecha_Publicacion);", o, tx);
        }
        tx.Commit();

        var guardadas = conexion.Query<Oferta>($"{SelectExterna} WHERE x.ID_Externo IN @IDs",
            new { IDs = ofertas.Select(o => o.ID_Externo).ToList(), IDUsuarioActual = 0 })
            .ToDictionary(g => g.ID_Externo!);
        // Mismo orden que devolvió la API
        return ofertas.Select(o => o.ID_Externo).Distinct().Where(guardadas.ContainsKey).Select(id => guardadas[id]).ToList();
    }

    private const string SelectExterna = @"
        SELECT CAST(1 AS BIT) AS EsExterna, x.ID, x.ID_Externo, x.Titulo, ISNULL(x.Empresa, N'Empresa sin nombre') AS Empresa, x.Logo, x.Ubicacion,
               CASE WHEN x.Es_Remoto = 1 THEN N'Remoto' ELSE NULL END AS Modalidad, x.Tipo_Contrato, x.Salario AS SalarioTexto,
               x.Descripcion, x.Fecha_Publicacion, x.Link_Postulacion, x.Publicador,
               CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaExterna = x.ID AND po.IDUsuario = @IDUsuarioActual)
                    THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado
        FROM OfertaExterna x";

    public static Oferta? ObtenerOfertaExterna(int id, int idUsuarioActual)
    {
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<Oferta>($"{SelectExterna} WHERE x.ID = @ID", new { ID = id, IDUsuarioActual = idUsuarioActual });
    }

    /// <summary>Marca cuáles ofertas externas ya registró la persona como postulaciones.</summary>
    public static void MarcarPostuladas(List<Oferta> ofertas, int idUsuario)
    {
        var externas = ofertas.Where(o => o.EsExterna).Select(o => o.ID).ToList();
        if (externas.Count == 0 || idUsuario == 0)
        {
            return;
        }
        using var conexion = Conectar();
        var postuladas = conexion.Query<int>("SELECT IDOfertaExterna FROM Postulacion WHERE IDUsuario = @ID AND IDOfertaExterna IN @IDs",
            new { ID = idUsuario, IDs = externas }).ToHashSet();
        foreach (var oferta in ofertas.Where(o => o.EsExterna))
        {
            oferta.YaPostulado = postuladas.Contains(oferta.ID);
        }
    }

    // =====================================================================
    // Postulaciones
    // =====================================================================

    /// <summary>Postulación a una oferta de Workly. Devuelve false si ya estaba postulada.</summary>
    public static bool Postular(int idUsuario, int idOferta)
    {
        using var conexion = Conectar();
        return conexion.Execute(@"INSERT INTO Postulacion (IDUsuario, IDOfertaLaboral, Fecha, Estado)
                                  SELECT @IDUsuario, @IDOferta, CAST(GETDATE() AS DATE), N'Enviada'
                                  WHERE NOT EXISTS (SELECT 1 FROM Postulacion WHERE IDUsuario = @IDUsuario AND IDOfertaLaboral = @IDOferta)",
            new { IDUsuario = idUsuario, IDOferta = idOferta }) > 0;
    }

    /// <summary>La persona avisa que se postuló a una oferta externa (para seguirla en su tablero).</summary>
    public static bool RegistrarPostulacionExterna(int idUsuario, int idOfertaExterna)
    {
        using var conexion = Conectar();
        return conexion.Execute(@"INSERT INTO Postulacion (IDUsuario, IDOfertaExterna, Fecha, Estado)
                                  SELECT @IDUsuario, @IDOferta, CAST(GETDATE() AS DATE), N'Enviada'
                                  WHERE EXISTS (SELECT 1 FROM OfertaExterna WHERE ID = @IDOferta)
                                    AND NOT EXISTS (SELECT 1 FROM Postulacion WHERE IDUsuario = @IDUsuario AND IDOfertaExterna = @IDOferta)",
            new { IDUsuario = idUsuario, IDOferta = idOfertaExterna }) > 0;
    }

    public static List<PostulacionItem> ObtenerPostulaciones(int idUsuario)
    {
        const string sql = @"
            SELECT po.ID, po.Estado, CAST(po.Fecha AS DATETIME2) AS Fecha, po.IDOfertaLaboral, po.IDOfertaExterna,
                   COALESCE(o.Titulo, x.Titulo) AS Titulo,
                   COALESCE(e.Nombre, x.Empresa, N'Empresa sin nombre') AS Empresa,
                   COALESCE(o.Ubicacion, pr.Nombre, x.Ubicacion) AS Ubicacion,
                   CASE WHEN x.ID IS NULL THEN N'Workly' ELSE x.Publicador END AS Publicador,
                   x.Link_Postulacion
            FROM Postulacion po
            LEFT JOIN OfertaLaboral o ON o.ID = po.IDOfertaLaboral
            LEFT JOIN Empresa e ON e.ID = o.IDEmpresa
            LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
            LEFT JOIN OfertaExterna x ON x.ID = po.IDOfertaExterna
            WHERE po.IDUsuario = @ID
            ORDER BY po.Fecha DESC, po.ID DESC";
        using var conexion = Conectar();
        return conexion.Query<PostulacionItem>(sql, new { ID = idUsuario }).ToList();
    }

    public static bool CambiarEstadoPostulacion(int idUsuario, int idPostulacion, string estado)
    {
        using var conexion = Conectar();
        return conexion.Execute("UPDATE Postulacion SET Estado = @Estado WHERE ID = @ID AND IDUsuario = @IDUsuario",
            new { ID = idPostulacion, IDUsuario = idUsuario, Estado = estado }) > 0;
    }

    public static bool EliminarPostulacion(int idUsuario, int idPostulacion)
    {
        using var conexion = Conectar();
        return conexion.Execute("DELETE FROM Postulacion WHERE ID = @ID AND IDUsuario = @IDUsuario",
            new { ID = idPostulacion, IDUsuario = idUsuario }) > 0;
    }

    public static Dictionary<string, int> ContarPostulacionesPorEstado(int idUsuario)
    {
        using var conexion = Conectar();
        var cuentas = conexion.Query<(string Estado, int Cantidad)>("SELECT Estado, COUNT(*) FROM Postulacion WHERE IDUsuario = @ID GROUP BY Estado",
            new { ID = idUsuario }).ToDictionary(c => c.Estado, c => c.Cantidad);
        return Catalogos.EstadosPostulacion.ToDictionary(e => e.Estado, e => cuentas.GetValueOrDefault(e.Estado));
    }

    // ---------------------------------------------------- Postulantes (para quien publicó)

    public static List<Postulante> ObtenerPostulantes(int idOferta)
    {
        const string sql = @"
            SELECT po.ID AS IDPostulacion, u.ID AS IDUsuario, CAST(po.Fecha AS DATETIME2) AS Fecha, u.Nombre, u.Apellido, u.Email,
                   pe.Telefono, pe.Foto, pr.Nombre AS Provincia, pe.Estado_Busqueda, pf.Puesto_Buscado, cv.Nombre_Archivo
            FROM Postulacion po
            JOIN Usuario u ON u.ID = po.IDUsuario
            LEFT JOIN Perfil pe ON pe.IDUsuario = u.ID
            LEFT JOIN Provincia pr ON pr.ID = pe.IDProvincia
            LEFT JOIN Preferencia pf ON pf.IDUsuario = u.ID
            LEFT JOIN CV cv ON cv.IDUsuario = u.ID
            WHERE po.IDOfertaLaboral = @ID
            ORDER BY po.Fecha DESC, po.ID DESC";
        using var conexion = Conectar();
        return conexion.Query<Postulante>(sql, new { ID = idOferta }).ToList();
    }

    /// <summary>
    /// Devuelve la postulación (persona y oferta) solo si la oferta la publicó esa cuenta.
    /// Así una empresa ve el perfil y el CV únicamente de quien se postuló a sus búsquedas.
    /// </summary>
    public static (int IDUsuario, int IDOferta)? ObtenerPostulacionDePublicador(int idPostulacion, int idPublicador)
    {
        using var conexion = Conectar();
        var filas = conexion.Query<(int IDUsuario, int IDOferta)>(@"
            SELECT po.IDUsuario, o.ID FROM Postulacion po
            JOIN OfertaLaboral o ON o.ID = po.IDOfertaLaboral
            WHERE po.ID = @ID AND o.IDUsuario_Publicador = @Publicador",
            new { ID = idPostulacion, Publicador = idPublicador }).ToList();
        return filas.Count == 0 ? null : filas[0];
    }
}
