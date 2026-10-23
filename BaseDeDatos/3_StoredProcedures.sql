/* ============================================================================
   Workly · 3 de 3 · Stored procedures (SQL Server)
   ----------------------------------------------------------------------------
   Un procedimiento por cada consulta que hace la aplicación (Models/BD.cs),
   con el mismo nombre que el método. Ejecutar después de 1_Estructura.sql.

   Se usa CREATE OR ALTER (SQL Server 2016 SP1 o posterior), así que se puede
   ejecutar más de una vez: si el procedimiento ya existe, lo reemplaza.

   Ejemplos:
     EXEC ObtenerUsuarioPorEmail @Email = N'sofia.martinez@mail.com';
     EXEC ObtenerProvincias;
   ============================================================================ */

SET NOCOUNT ON;
GO

USE Workly;
GO

/* ============================================================================
   USUARIO
   ============================================================================ */

-- Login: busca la cuenta por email (el email se guarda en minúsculas)
CREATE OR ALTER PROCEDURE dbo.ObtenerUsuarioPorEmail
    @Email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro
    FROM dbo.Usuario
    WHERE Email = @Email;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerUsuarioPorId
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro
    FROM dbo.Usuario
    WHERE ID = @ID;
END
GO

-- Registro: 1 si ya hay una cuenta con ese email, 0 si no
CREATE OR ALTER PROCEDURE dbo.ExisteEmail
    @Email NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CASE WHEN EXISTS (SELECT 1 FROM dbo.Usuario WHERE Email = @Email) THEN 1 ELSE 0 END AS Existe;
END
GO

/* Registro: crea el usuario con su perfil y, si hay archivo o sitio web, su CV.
   Todo en una transacción: si algo falla no queda nada a medias.
   Devuelve el ID del usuario nuevo. @Contrasena es el hash, nunca la contraseña. */
CREATE OR ALTER PROCEDURE dbo.RegistrarUsuario
    @Nombre         NVARCHAR(50),
    @Apellido       NVARCHAR(50),
    @Email          NVARCHAR(100),
    @Contrasena     NVARCHAR(200),
    @IDProvincia    INT           = NULL,
    @Foto           NVARCHAR(260) = NULL,
    @Descripcion    NVARCHAR(500) = NULL,
    @Telefono       NVARCHAR(30)  = NULL,
    @Nombre_Archivo NVARCHAR(260) = NULL,
    @Sitio_Web      NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- ante cualquier error se deshace toda la transacción

    DECLARE @IDUsuario INT;

    BEGIN TRANSACTION;

    INSERT INTO dbo.Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro)
    VALUES (@Nombre, @Apellido, @Email, @Contrasena, CAST(GETDATE() AS DATE));
    SET @IDUsuario = SCOPE_IDENTITY();

    INSERT INTO dbo.Perfil (IDUsuario, IDProvincia, Foto, Descripcion, Telefono)
    VALUES (@IDUsuario, @IDProvincia, @Foto, @Descripcion, @Telefono);

    IF @Nombre_Archivo IS NOT NULL OR @Sitio_Web IS NOT NULL
        INSERT INTO dbo.CV (IDUsuario, Nombre_Archivo, Sitio_Web, Fecha_Actualizacion)
        VALUES (@IDUsuario, @Nombre_Archivo, @Sitio_Web, CAST(GETDATE() AS DATE));

    COMMIT TRANSACTION;

    SELECT @IDUsuario AS ID;
END
GO

/* ============================================================================
   PAÍSES Y PROVINCIAS (listas del registro y de Configuración)
   ============================================================================ */

CREATE OR ALTER PROCEDURE dbo.ObtenerPaises
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, Nombre, Codigo_Telefono
    FROM dbo.Pais
    ORDER BY Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerProvincias
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, IDPais, Nombre
    FROM dbo.Provincia
    ORDER BY Nombre;
END
GO

/* ============================================================================
   PERFIL, CV, EXPERIENCIA Y FORMACIÓN ("Mi perfil" y "Configuración")
   ============================================================================ */

-- Perfil con el nombre de la provincia y el país (y el prefijo del teléfono)
CREATE OR ALTER PROCEDURE dbo.ObtenerPerfil
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT pe.ID, pe.IDUsuario, pe.IDProvincia, pe.Foto, pe.Descripcion, pe.Telefono,
           pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais, pa.Codigo_Telefono
    FROM dbo.Perfil AS pe
    LEFT JOIN dbo.Provincia AS pr ON pr.ID = pe.IDProvincia
    LEFT JOIN dbo.Pais AS pa ON pa.ID = pr.IDPais
    WHERE pe.IDUsuario = @IDUsuario;
END
GO

CREATE OR ALTER PROCEDURE dbo.ObtenerCV
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, IDUsuario, Nombre_Archivo, Sitio_Web, Fecha_Actualizacion
    FROM dbo.CV
    WHERE IDUsuario = @IDUsuario;
END
GO

-- Experiencia laboral: primero el trabajo actual, después del más reciente al más viejo
CREATE OR ALTER PROCEDURE dbo.ObtenerExperiencias
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT x.ID, x.Puesto, e.Nombre AS Empresa, x.Descripcion, x.Fecha_Inicio, x.Fecha_Finalizacion
    FROM dbo.ExperienciaLaboral AS x
    JOIN dbo.Empresa AS e ON e.ID = x.IDEmpresa
    WHERE x.IDUsuario = @IDUsuario
    ORDER BY CASE WHEN x.Fecha_Finalizacion IS NULL THEN 0 ELSE 1 END, x.Fecha_Inicio DESC;
END
GO

-- Formación: de la más reciente a la más vieja
CREATE OR ALTER PROCEDURE dbo.ObtenerFormaciones
    @IDUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ue.ID, ue.Titulo, ed.Institucion, ue.Fecha_Inicio, ue.Fecha_Fin
    FROM dbo.UsuarioEducacion AS ue
    JOIN dbo.Educacion AS ed ON ed.ID = ue.IDEducacion
    WHERE ue.IDUsuario = @IDUsuario
    ORDER BY ue.Fecha_Inicio DESC;
END
GO

/* ============================================================================
   RESUMEN
   ============================================================================ */
SELECT name AS StoredProcedure
FROM sys.procedures
ORDER BY name;
GO
