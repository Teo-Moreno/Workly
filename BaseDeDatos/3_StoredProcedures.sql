SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE Workly;
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerUsuarioPorEmail
    @Email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo, Es_Moderador FROM dbo.Usuario WHERE Email = @Email;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerUsuarioPorId
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo, Es_Moderador FROM dbo.Usuario WHERE ID = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.ExisteEmail
    @Email NVARCHAR(100),
    @Excepto INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CASE WHEN EXISTS (SELECT 1 FROM dbo.Usuario WHERE Email = @Email AND ID <> ISNULL(@Excepto, 0)) THEN 1 ELSE 0 END AS Existe;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerUsuarioDeLoginExterno
    @Proveedor NVARCHAR(20),
    @IDExterno NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IDUsuario FROM dbo.LoginExterno WHERE Proveedor = @Proveedor AND ID_Externo = @IDExterno;
END
GO

CREATE OR ALTER PROCEDURE dbo.CambiarContrasena
    @IDUsuario INT,
    @Hash NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Usuario SET [Contraseña] = @Hash WHERE ID = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerPaises
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre, Codigo_ISO, Codigo_Telefono FROM dbo.Pais ORDER BY Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerProvincias
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, IDPais, Nombre FROM dbo.Provincia ORDER BY Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerCatalogoHabilidades
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre FROM dbo.Habilidad ORDER BY Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerCatalogoIdiomas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre FROM dbo.Idioma ORDER BY Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerPerfil
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pe.ID, pe.IDUsuario, pe.IDProvincia, pe.Foto, pe.Descripcion, pe.Telefono, pe.Estado_Busqueda,
           pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais, pa.Codigo_Telefono
    FROM dbo.Perfil pe
    LEFT JOIN dbo.Provincia pr ON pr.ID = pe.IDProvincia
    LEFT JOIN dbo.Pais pa ON pa.ID = pr.IDPais
    WHERE pe.IDUsuario = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerCV
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, IDUsuario, Nombre_Archivo, Sitio_Web, Fecha_Actualizacion FROM dbo.CV WHERE IDUsuario = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerPreferencia
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.*, pr.Nombre AS Provincia
    FROM dbo.Preferencia p
    LEFT JOIN dbo.Provincia pr ON pr.ID = p.IDProvincia
    WHERE p.IDUsuario = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerHabilidadesUsuario
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT h.Nombre FROM dbo.UsuarioHabilidad uh JOIN dbo.Habilidad h ON h.ID = uh.IDHabilidad
    WHERE uh.IDUsuario = @IDUsuario ORDER BY h.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerIdiomasUsuario
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ui.IDIdioma, i.Nombre AS Idioma, ui.Nivel FROM dbo.UsuarioIdioma ui
    JOIN dbo.Idioma i ON i.ID = ui.IDIdioma WHERE ui.IDUsuario = @IDUsuario ORDER BY i.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.ActualizarDescripcion
    @IDUsuario INT,
    @Descripcion NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Perfil SET Descripcion = @Descripcion WHERE IDUsuario = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.ActualizarEstadoBusqueda
    @IDUsuario INT,
    @Estado NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Perfil SET Estado_Busqueda = @Estado WHERE IDUsuario = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerExperiencias
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT x.ID, x.Puesto, e.Nombre AS Empresa, x.Descripcion, x.Fecha_Inicio, x.Fecha_Finalizacion
    FROM dbo.ExperienciaLaboral x
    JOIN dbo.Empresa e ON e.ID = x.IDEmpresa
    WHERE x.IDUsuario = @IDUsuario
    ORDER BY CASE WHEN x.Fecha_Finalizacion IS NULL THEN 0 ELSE 1 END, x.Fecha_Inicio DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.AgregarExperiencia
    @IDUsuario INT,
    @Empresa NVARCHAR(100),
    @Puesto NVARCHAR(100),
    @Descripcion NVARCHAR(500) = NULL,
    @Inicio DATE,
    @Fin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Empresa WHERE Nombre = @Empresa)
        INSERT INTO dbo.Empresa (Nombre) VALUES (@Empresa);
    INSERT INTO dbo.ExperienciaLaboral (IDUsuario, IDEmpresa, Puesto, Descripcion, Fecha_Inicio, Fecha_Finalizacion)
    SELECT @IDUsuario, ID, @Puesto, @Descripcion, @Inicio, @Fin FROM dbo.Empresa WHERE Nombre = @Empresa;
END
GO

CREATE OR ALTER PROCEDURE dbo.EliminarExperiencia
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.ExperienciaLaboral WHERE ID = @ID AND IDUsuario = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerFormaciones
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ue.ID, ue.Titulo, ed.Institucion, ue.Fecha_Inicio, ue.Fecha_Fin
    FROM dbo.UsuarioEducacion ue
    JOIN dbo.Educacion ed ON ed.ID = ue.IDEducacion
    WHERE ue.IDUsuario = @IDUsuario
    ORDER BY CASE WHEN ue.Fecha_Fin IS NULL THEN 0 ELSE 1 END, ue.Fecha_Inicio DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.AgregarFormacion
    @IDUsuario INT,
    @Institucion NVARCHAR(150),
    @Titulo NVARCHAR(150),
    @Inicio DATE,
    @Fin DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Educacion WHERE Institucion = @Institucion)
        INSERT INTO dbo.Educacion (Institucion) VALUES (@Institucion);
    INSERT INTO dbo.UsuarioEducacion (IDUsuario, IDEducacion, Titulo, Fecha_Inicio, Fecha_Fin)
    SELECT @IDUsuario, ID, @Titulo, @Inicio, @Fin FROM dbo.Educacion WHERE Institucion = @Institucion;
END
GO

CREATE OR ALTER PROCEDURE dbo.EliminarFormacion
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.UsuarioEducacion WHERE ID = @ID AND IDUsuario = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerEmpresa
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.ID, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.IDUsuario, e.Razon_Social, e.CUIT,
           e.Rubro, e.IDProvincia, e.Telefono, e.Fecha_Registro, pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais,
           (SELECT COUNT(*) FROM dbo.OfertaLaboral o
            WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'
              AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))) AS BusquedasActivas
    FROM dbo.Empresa e
    LEFT JOIN dbo.Provincia pr ON pr.ID = e.IDProvincia
    LEFT JOIN dbo.Pais pa ON pa.ID = pr.IDPais
    WHERE e.ID = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerEmpresaDeUsuario
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.ID, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.IDUsuario, e.Razon_Social, e.CUIT,
           e.Rubro, e.IDProvincia, e.Telefono, e.Fecha_Registro, pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais,
           (SELECT COUNT(*) FROM dbo.OfertaLaboral o
            WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'
              AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))) AS BusquedasActivas
    FROM dbo.Empresa e
    LEFT JOIN dbo.Provincia pr ON pr.ID = e.IDProvincia
    LEFT JOIN dbo.Pais pa ON pa.ID = pr.IDPais
    WHERE e.IDUsuario = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.ExisteCuit
    @CUIT CHAR(11)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CASE WHEN EXISTS (SELECT 1 FROM dbo.Empresa WHERE CUIT = @CUIT) THEN 1 ELSE 0 END AS Existe;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerOferta
    @ID INT,
    @IDUsuarioActual INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           o.Fecha_Publicacion, o.Fecha_Cierre, o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM dbo.OfertaPuesto op JOIN dbo.Puesto p ON p.ID = op.IDPuesto WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado
    FROM dbo.OfertaLaboral o
    JOIN dbo.Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN dbo.Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN dbo.Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.ID = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerOfertasPublicadas
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IDUsuarioActual INT = 0;
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           o.Fecha_Publicacion, o.Fecha_Cierre, o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM dbo.OfertaPuesto op JOIN dbo.Puesto p ON p.ID = op.IDPuesto WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado
    FROM dbo.OfertaLaboral o
    JOIN dbo.Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN dbo.Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN dbo.Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.IDUsuario_Publicador = @IDUsuario
    ORDER BY o.Fecha_Publicacion DESC, o.ID DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.CerrarOferta
    @ID INT,
    @IDPublicador INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.OfertaLaboral SET Fecha_Cierre = CAST(GETDATE() AS DATE)
    WHERE ID = @ID AND IDUsuario_Publicador = @IDPublicador
      AND (Fecha_Cierre IS NULL OR Fecha_Cierre >= CAST(GETDATE() AS DATE));
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerOfertasPendientes
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IDUsuarioActual INT = 0;
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           o.Fecha_Publicacion, o.Fecha_Cierre, o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM dbo.OfertaPuesto op JOIN dbo.Puesto p ON p.ID = op.IDPuesto WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado
    FROM dbo.OfertaLaboral o
    JOIN dbo.Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN dbo.Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN dbo.Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.Estado_Publicacion = N'Pendiente'
    ORDER BY o.Fecha_Publicacion, o.ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.ContarOfertasPendientes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS Pendientes FROM dbo.OfertaLaboral WHERE Estado_Publicacion = N'Pendiente';
END
GO

CREATE OR ALTER PROCEDURE dbo.RevisarOferta
    @ID INT,
    @Aprobada BIT,
    @Motivo NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.OfertaLaboral
    SET Estado_Publicacion = CASE WHEN @Aprobada = 1 THEN N'Aprobada' ELSE N'Rechazada' END,
        Motivo_Rechazo = CASE WHEN @Aprobada = 1 THEN NULL ELSE @Motivo END,
        Fecha_Revision = CAST(GETDATE() AS DATE),
        Fecha_Publicacion = CASE WHEN @Aprobada = 1 THEN CAST(GETDATE() AS DATE) ELSE Fecha_Publicacion END
    WHERE ID = @ID AND Estado_Publicacion = N'Pendiente';
END
GO

CREATE OR ALTER PROCEDURE dbo.GuardarOferta
    @IDUsuario INT,
    @IDOfertaLaboral INT = NULL,
    @IDOfertaExterna INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF (@IDOfertaLaboral IS NULL AND @IDOfertaExterna IS NULL) OR (@IDOfertaLaboral IS NOT NULL AND @IDOfertaExterna IS NOT NULL)
        RETURN;
    IF @IDOfertaLaboral IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.OfertaLaboral WHERE ID = @IDOfertaLaboral AND Estado_Publicacion = N'Aprobada')
        RETURN;
    IF @IDOfertaExterna IS NOT NULL AND NOT EXISTS (SELECT 1 FROM dbo.OfertaExterna WHERE ID = @IDOfertaExterna)
        RETURN;
    IF EXISTS (SELECT 1 FROM dbo.FavoritoOferta fo JOIN dbo.Favorito f ON f.ID_favorito = fo.IDFavorito
               WHERE f.IDUsuario = @IDUsuario AND (fo.IDOfertaLaboral = @IDOfertaLaboral OR fo.IDOfertaExterna = @IDOfertaExterna))
        RETURN;
    BEGIN TRANSACTION;
    INSERT INTO dbo.Favorito (IDUsuario, fecha_guardado) VALUES (@IDUsuario, CAST(GETDATE() AS DATE));
    INSERT INTO dbo.FavoritoOferta (IDFavorito, IDOfertaLaboral, IDOfertaExterna) VALUES (SCOPE_IDENTITY(), @IDOfertaLaboral, @IDOfertaExterna);
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE dbo.QuitarGuardada
    @IDUsuario INT,
    @IDOfertaLaboral INT = NULL,
    @IDOfertaExterna INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DELETE f FROM dbo.Favorito f
    JOIN dbo.FavoritoOferta fo ON fo.IDFavorito = f.ID_favorito
    WHERE f.IDUsuario = @IDUsuario AND (fo.IDOfertaLaboral = @IDOfertaLaboral OR fo.IDOfertaExterna = @IDOfertaExterna);
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerGuardadas
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT f.ID_favorito AS IDFavorito, f.fecha_guardado AS Fecha_Guardado,
           CASE WHEN fo.IDOfertaExterna IS NULL THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS EsExterna,
           COALESCE(o.ID, x.ID) AS ID, COALESCE(o.Titulo, x.Titulo) AS Titulo,
           COALESCE(e.Nombre, x.Empresa) AS Empresa, COALESCE(o.Ubicacion, pr.Nombre, x.Ubicacion) AS Ubicacion,
           o.Estado_Publicacion, o.Fecha_Cierre, x.Link_Postulacion, x.Publicador
    FROM dbo.Favorito f
    JOIN dbo.FavoritoOferta fo ON fo.IDFavorito = f.ID_favorito
    LEFT JOIN dbo.OfertaLaboral o ON o.ID = fo.IDOfertaLaboral
    LEFT JOIN dbo.Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN dbo.Provincia pr ON pr.ID = o.IDProvincia
    LEFT JOIN dbo.OfertaExterna x ON x.ID = fo.IDOfertaExterna
    WHERE f.IDUsuario = @IDUsuario
    ORDER BY f.ID_favorito DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.Postular
    @IDUsuario INT,
    @IDOferta INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Postulacion (IDUsuario, IDOfertaLaboral, Fecha, Estado)
    SELECT @IDUsuario, @IDOferta, CAST(GETDATE() AS DATE), N'Enviada'
    WHERE NOT EXISTS (SELECT 1 FROM dbo.Postulacion WHERE IDUsuario = @IDUsuario AND IDOfertaLaboral = @IDOferta);
END
GO

CREATE OR ALTER PROCEDURE dbo.RegistrarPostulacionExterna
    @IDUsuario INT,
    @IDOfertaExterna INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Postulacion (IDUsuario, IDOfertaExterna, Fecha, Estado)
    SELECT @IDUsuario, @IDOfertaExterna, CAST(GETDATE() AS DATE), N'Enviada'
    WHERE EXISTS (SELECT 1 FROM dbo.OfertaExterna WHERE ID = @IDOfertaExterna)
      AND NOT EXISTS (SELECT 1 FROM dbo.Postulacion WHERE IDUsuario = @IDUsuario AND IDOfertaExterna = @IDOfertaExterna);
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerPostulaciones
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT po.ID, po.Estado, po.Fecha, po.IDOfertaLaboral, po.IDOfertaExterna,
           COALESCE(o.Titulo, x.Titulo) AS Titulo,
           COALESCE(e.Nombre, x.Empresa, N'Empresa sin nombre') AS Empresa,
           COALESCE(o.Ubicacion, pr.Nombre, x.Ubicacion) AS Ubicacion,
           CASE WHEN x.ID IS NULL THEN N'Workly' ELSE x.Publicador END AS Publicador,
           x.Link_Postulacion
    FROM dbo.Postulacion po
    LEFT JOIN dbo.OfertaLaboral o ON o.ID = po.IDOfertaLaboral
    LEFT JOIN dbo.Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN dbo.Provincia pr ON pr.ID = o.IDProvincia
    LEFT JOIN dbo.OfertaExterna x ON x.ID = po.IDOfertaExterna
    WHERE po.IDUsuario = @IDUsuario
    ORDER BY po.Fecha DESC, po.ID DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.CambiarEstadoPostulacion
    @IDUsuario INT,
    @ID INT,
    @Estado NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Postulacion SET Estado = @Estado WHERE ID = @ID AND IDUsuario = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.EliminarPostulacion
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Postulacion WHERE ID = @ID AND IDUsuario = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.ContarPostulacionesPorEstado
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Estado, COUNT(*) AS Cantidad FROM dbo.Postulacion WHERE IDUsuario = @IDUsuario GROUP BY Estado;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerPostulantes
    @IDOferta INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT po.ID AS IDPostulacion, u.ID AS IDUsuario, po.Fecha, u.Nombre, u.Apellido, u.Email,
           pe.Telefono, pe.Foto, pr.Nombre AS Provincia, pe.Estado_Busqueda, pf.Puesto_Buscado, cv.Nombre_Archivo
    FROM dbo.Postulacion po
    JOIN dbo.Usuario u ON u.ID = po.IDUsuario
    LEFT JOIN dbo.Perfil pe ON pe.IDUsuario = u.ID
    LEFT JOIN dbo.Provincia pr ON pr.ID = pe.IDProvincia
    LEFT JOIN dbo.Preferencia pf ON pf.IDUsuario = u.ID
    LEFT JOIN dbo.CV cv ON cv.IDUsuario = u.ID
    WHERE po.IDOfertaLaboral = @IDOferta
    ORDER BY po.Fecha DESC, po.ID DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerPostulacionDePublicador
    @ID INT,
    @IDPublicador INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT po.IDUsuario, o.ID AS IDOferta
    FROM dbo.Postulacion po
    JOIN dbo.OfertaLaboral o ON o.ID = po.IDOfertaLaboral
    WHERE po.ID = @ID AND o.IDUsuario_Publicador = @IDPublicador;
END
GO
