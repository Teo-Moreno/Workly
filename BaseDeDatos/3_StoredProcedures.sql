/* ============================================================================
   Workly · 3 de 3 · Stored procedures (SQL Server)
   ----------------------------------------------------------------------------
   Las consultas principales de la aplicación (Models/BD.cs) como
   procedimientos, con el mismo nombre que el método. La aplicación hace estas
   mismas consultas desde BD.cs con Dapper; las que arman el SQL según los
   filtros (buscar ofertas y empresas) y las que usan transacciones de varios
   pasos (registro, guardar qué busca, eliminar cuenta) quedan solo en BD.cs.
   Ejecutar después de 1_Estructura.sql.

   Se usa CREATE OR ALTER (SQL Server 2016 SP1 o posterior): se puede ejecutar
   más de una vez.

   Ejemplos:
     EXEC dbo.ObtenerUsuarioPorEmail @Email = N'50291929@est.ort.edu.ar';
     EXEC dbo.ObtenerPostulaciones @IDUsuario = 1;
   ============================================================================ */

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE Workly;
GO

/* ============================================================================
   USUARIO Y CUENTA
   ============================================================================ */

-- Iniciar sesión: la cuenta por email (se guarda en minúsculas)
CREATE OR ALTER PROCEDURE dbo.ObtenerUsuarioPorEmail
    @Email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo, Es_Moderador FROM dbo.Usuario WHERE Email = @Email;
END
GO

-- Cuenta por ID
CREATE OR ALTER PROCEDURE dbo.ObtenerUsuarioPorId
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo, Es_Moderador FROM dbo.Usuario WHERE ID = @ID;
END
GO

-- Hay otra cuenta con ese email (registro y Configuración)
CREATE OR ALTER PROCEDURE dbo.ExisteEmail
    @Email NVARCHAR(100),
    @Excepto INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CASE WHEN EXISTS (SELECT 1 FROM dbo.Usuario WHERE Email = @Email AND ID <> ISNULL(@Excepto, 0)) THEN 1 ELSE 0 END AS Existe;
END
GO

-- Entrar con Google o LinkedIn
CREATE OR ALTER PROCEDURE dbo.ObtenerUsuarioDeLoginExterno
    @Proveedor NVARCHAR(20),
    @IDExterno NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IDUsuario FROM dbo.LoginExterno WHERE Proveedor = @Proveedor AND ID_Externo = @IDExterno;
END
GO

-- Configuración › Seguridad (el hash PBKDF2 lo arma la aplicación)
CREATE OR ALTER PROCEDURE dbo.CambiarContrasena
    @IDUsuario INT,
    @Hash NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Usuario SET [Contraseña] = @Hash WHERE ID = @IDUsuario;
END
GO

/* ============================================================================
   CATÁLOGOS
   ============================================================================ */

-- Países del registro
CREATE OR ALTER PROCEDURE dbo.ObtenerPaises
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre, Codigo_ISO, Codigo_Telefono FROM dbo.Pais ORDER BY Nombre;
END
GO

-- Provincias (cada una con su país)
CREATE OR ALTER PROCEDURE dbo.ObtenerProvincias
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, IDPais, Nombre FROM dbo.Provincia ORDER BY Nombre;
END
GO

-- Habilidades para elegir
CREATE OR ALTER PROCEDURE dbo.ObtenerCatalogoHabilidades
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre FROM dbo.Habilidad ORDER BY Nombre;
END
GO

-- Idiomas para elegir
CREATE OR ALTER PROCEDURE dbo.ObtenerCatalogoIdiomas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre FROM dbo.Idioma ORDER BY Nombre;
END
GO

/* ============================================================================
   PERFIL
   ============================================================================ */

-- Perfil con su provincia y país
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

-- CV de la persona
CREATE OR ALTER PROCEDURE dbo.ObtenerCV
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, IDUsuario, Nombre_Archivo, Sitio_Web, Fecha_Actualizacion FROM dbo.CV WHERE IDUsuario = @IDUsuario;
END
GO

-- Qué busca la persona
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

-- Habilidades de la persona
CREATE OR ALTER PROCEDURE dbo.ObtenerHabilidadesUsuario
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT h.Nombre FROM dbo.UsuarioHabilidad uh JOIN dbo.Habilidad h ON h.ID = uh.IDHabilidad
    WHERE uh.IDUsuario = @IDUsuario ORDER BY h.Nombre;
END
GO

-- Idiomas de la persona con su nivel
CREATE OR ALTER PROCEDURE dbo.ObtenerIdiomasUsuario
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ui.IDIdioma, i.Nombre AS Idioma, ui.Nivel FROM dbo.UsuarioIdioma ui
    JOIN dbo.Idioma i ON i.ID = ui.IDIdioma WHERE ui.IDUsuario = @IDUsuario ORDER BY i.Nombre;
END
GO

-- Sobre mí
CREATE OR ALTER PROCEDURE dbo.ActualizarDescripcion
    @IDUsuario INT,
    @Descripcion NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Perfil SET Descripcion = @Descripcion WHERE IDUsuario = @IDUsuario;
END
GO

-- Buscando activamente / Abierto a propuestas / No estoy buscando
CREATE OR ALTER PROCEDURE dbo.ActualizarEstadoBusqueda
    @IDUsuario INT,
    @Estado NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Perfil SET Estado_Busqueda = @Estado WHERE IDUsuario = @IDUsuario;
END
GO

-- Experiencia laboral (primero la actual)
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

-- Agregar una experiencia (Fin NULL = trabaja ahí actualmente)
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
    -- La empresa se busca por nombre y, si no existe, se crea sin cuenta
    IF NOT EXISTS (SELECT 1 FROM dbo.Empresa WHERE Nombre = @Empresa)
        INSERT INTO dbo.Empresa (Nombre) VALUES (@Empresa);
    INSERT INTO dbo.ExperienciaLaboral (IDUsuario, IDEmpresa, Puesto, Descripcion, Fecha_Inicio, Fecha_Finalizacion)
    SELECT @IDUsuario, ID, @Puesto, @Descripcion, @Inicio, @Fin FROM dbo.Empresa WHERE Nombre = @Empresa;
END
GO

-- Borrar una experiencia propia
CREATE OR ALTER PROCEDURE dbo.EliminarExperiencia
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.ExperienciaLaboral WHERE ID = @ID AND IDUsuario = @IDUsuario;
END
GO

-- Formación (primero la que está en curso)
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

-- Agregar una formación (Fin NULL = en curso)
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

-- Borrar una formación propia
CREATE OR ALTER PROCEDURE dbo.EliminarFormacion
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.UsuarioEducacion WHERE ID = @ID AND IDUsuario = @IDUsuario;
END
GO

/* ============================================================================
   EMPRESAS
   ============================================================================ */

-- Página de una empresa
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

-- La empresa de una cuenta de empresa
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

-- Registro de empresa: el CUIT no puede repetirse
CREATE OR ALTER PROCEDURE dbo.ExisteCuit
    @CUIT CHAR(11)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CASE WHEN EXISTS (SELECT 1 FROM dbo.Empresa WHERE CUIT = @CUIT) THEN 1 ELSE 0 END AS Existe;
END
GO

/* ============================================================================
   BÚSQUEDAS DE WORKLY Y MODERACIÓN
   ============================================================================ */

-- Detalle de una búsqueda (YaPostulado según quien la mira)
CREATE OR ALTER PROCEDURE dbo.ObtenerOferta
    @ID INT,
    @IDUsuarioActual INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           o.Fecha_Publicacion, o.Fecha_Cierre, o.IDUsuario_Publicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM dbo.OfertaPuesto op JOIN dbo.Puesto p ON p.ID = op.IDPuesto WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado
    FROM dbo.OfertaLaboral o
    JOIN dbo.Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN dbo.Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.ID = @ID;
END
GO

-- Mis publicaciones, con la cantidad de postulantes
CREATE OR ALTER PROCEDURE dbo.ObtenerOfertasPublicadas
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IDUsuarioActual INT = 0;
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           o.Fecha_Publicacion, o.Fecha_Cierre, o.IDUsuario_Publicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM dbo.OfertaPuesto op JOIN dbo.Puesto p ON p.ID = op.IDPuesto WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado
    FROM dbo.OfertaLaboral o
    JOIN dbo.Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN dbo.Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.IDUsuario_Publicador = @IDUsuario
    ORDER BY o.Fecha_Publicacion DESC, o.ID DESC;
END
GO

-- Cerrar una búsqueda propia
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

-- Moderación: búsquedas de personas que esperan revisión
CREATE OR ALTER PROCEDURE dbo.ObtenerOfertasPendientes
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IDUsuarioActual INT = 0;
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           o.Fecha_Publicacion, o.Fecha_Cierre, o.IDUsuario_Publicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM dbo.OfertaPuesto op JOIN dbo.Puesto p ON p.ID = op.IDPuesto WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM dbo.Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado
    FROM dbo.OfertaLaboral o
    JOIN dbo.Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN dbo.Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.Estado_Publicacion = N'Pendiente'
    ORDER BY o.Fecha_Publicacion, o.ID;
END
GO

-- Contador de la navbar de moderación
CREATE OR ALTER PROCEDURE dbo.ContarOfertasPendientes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) AS Pendientes FROM dbo.OfertaLaboral WHERE Estado_Publicacion = N'Pendiente';
END
GO

-- Aceptar (se publica) o rechazar (queda el motivo) una búsqueda
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

/* ============================================================================
   POSTULACIONES
   ============================================================================ */

-- Postularse a una búsqueda de Workly (una vez por búsqueda)
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

-- "Ya me postulé" en una oferta de otro sitio
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

-- Tablero de postulaciones
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

-- La persona mueve la tarjeta: Enviada, En revisión, Pasé o No pasé
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

-- Quitar una postulación del tablero
CREATE OR ALTER PROCEDURE dbo.EliminarPostulacion
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Postulacion WHERE ID = @ID AND IDUsuario = @IDUsuario;
END
GO

-- Resumen del perfil y del inicio
CREATE OR ALTER PROCEDURE dbo.ContarPostulacionesPorEstado
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Estado, COUNT(*) AS Cantidad FROM dbo.Postulacion WHERE IDUsuario = @IDUsuario GROUP BY Estado;
END
GO

-- Personas que se postularon a una búsqueda
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

-- Solo quien publicó la búsqueda puede ver el perfil y el CV de quien se postuló
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
