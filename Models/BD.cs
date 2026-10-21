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

    // ---------------------------------------------------------------- Usuario

    public static Usuario? ObtenerUsuarioPorEmail(string email)
    {
        const string sql = @"SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro
                             FROM Usuario WHERE Email = @Email";
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<Usuario>(sql, new { Email = email });
    }

    public static Usuario? ObtenerUsuarioPorId(int id)
    {
        const string sql = @"SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro
                             FROM Usuario WHERE ID = @ID";
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<Usuario>(sql, new { ID = id });
    }

    public static bool ExisteEmail(string email)
    {
        const string sql = "SELECT CASE WHEN EXISTS (SELECT 1 FROM Usuario WHERE Email = @Email) THEN 1 ELSE 0 END";
        using var conexion = Conectar();
        return conexion.ExecuteScalar<int>(sql, new { Email = email }) == 1;
    }

    /// <summary>
    /// Registra un usuario con su perfil y (si hay datos) su CV, todo en una transacción:
    /// si algo falla no queda nada a medias. Devuelve el ID del usuario nuevo.
    /// </summary>
    public static int RegistrarUsuario(Usuario usuario, Perfil perfil, CV? cv)
    {
        using var conexion = Conectar();
        conexion.Open();
        using var transaccion = conexion.BeginTransaction();

        const string sqlUsuario = @"INSERT INTO Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro)
                                    OUTPUT INSERTED.ID
                                    VALUES (@Nombre, @Apellido, @Email, @Contrasena, CAST(GETDATE() AS DATE))";
        var idUsuario = conexion.ExecuteScalar<int>(sqlUsuario, new
        {
            usuario.Nombre,
            usuario.Apellido,
            usuario.Email,
            Contrasena = usuario.Contraseña
        }, transaccion);

        const string sqlPerfil = @"INSERT INTO Perfil (IDUsuario, IDProvincia, Foto, Descripcion, Telefono)
                                   VALUES (@IDUsuario, @IDProvincia, @Foto, @Descripcion, @Telefono)";
        conexion.Execute(sqlPerfil, new
        {
            IDUsuario = idUsuario,
            perfil.Foto,
            perfil.Descripcion,
            perfil.IDProvincia,
            perfil.Telefono
        }, transaccion);

        if (cv != null)
        {
            const string sqlCV = @"INSERT INTO CV (IDUsuario, Nombre_Archivo, Sitio_Web, Fecha_Actualizacion)
                                   VALUES (@IDUsuario, @Nombre_Archivo, @Sitio_Web, CAST(GETDATE() AS DATE))";
            conexion.Execute(sqlCV, new { IDUsuario = idUsuario, cv.Nombre_Archivo, cv.Sitio_Web }, transaccion);
        }

        transaccion.Commit();
        return idUsuario;
    }

    // ------------------------------------------------------------ Países y provincias

    public static List<Pais> ObtenerPaises()
    {
        const string sql = "SELECT ID, Nombre, Codigo_Telefono FROM Pais ORDER BY Nombre";
        using var conexion = Conectar();
        return conexion.Query<Pais>(sql).ToList();
    }

    public static List<Provincia> ObtenerProvincias()
    {
        const string sql = "SELECT ID, IDPais, Nombre FROM Provincia ORDER BY Nombre";
        using var conexion = Conectar();
        return conexion.Query<Provincia>(sql).ToList();
    }

    // ------------------------------------------------------------ Perfil y CV

    public static Perfil? ObtenerPerfil(int idUsuario)
    {
        const string sql = @"SELECT pe.ID, pe.IDUsuario, pe.IDProvincia, pe.Foto, pe.Descripcion, pe.Telefono,
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
        const string sql = @"SELECT ID, IDUsuario, Nombre_Archivo, Sitio_Web, Fecha_Actualizacion
                             FROM CV WHERE IDUsuario = @IDUsuario";
        using var conexion = Conectar();
        return conexion.QueryFirstOrDefault<CV>(sql, new { IDUsuario = idUsuario });
    }

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

    public static List<FormacionItem> ObtenerFormaciones(int idUsuario)
    {
        const string sql = @"SELECT ue.ID, ue.Titulo, ed.Institucion, ue.Fecha_Inicio, ue.Fecha_Fin
                             FROM UsuarioEducacion ue
                             JOIN Educacion ed ON ed.ID = ue.IDEducacion
                             WHERE ue.IDUsuario = @IDUsuario
                             ORDER BY ue.Fecha_Inicio DESC";
        using var conexion = Conectar();
        return conexion.Query<FormacionItem>(sql, new { IDUsuario = idUsuario }).ToList();
    }

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
            Experiencias = ObtenerExperiencias(idUsuario),
            Formaciones = ObtenerFormaciones(idUsuario)
        };
    }
}
