USE Workly
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE ObtenerUsuarioPorEmail
    @Email NVARCHAR(100)
AS
BEGIN
    SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo, Es_Moderador
    FROM Usuario
    WHERE Email = @Email
END
GO

CREATE OR ALTER PROCEDURE ObtenerUsuarioPorId
    @ID INT
AS
BEGIN
    SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo, Es_Moderador
    FROM Usuario
    WHERE ID = @ID
END
GO

CREATE OR ALTER PROCEDURE ExisteEmail
    @Email NVARCHAR(100),
    @Excepto INT = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Usuario WHERE Email = @Email AND ID <> ISNULL(@Excepto, 0))
        SELECT CAST(1 AS BIT) AS Existe
    ELSE
        SELECT CAST(0 AS BIT) AS Existe
END
GO

CREATE OR ALTER PROCEDURE AsegurarPerfil
    @IDUsuario INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Perfil WHERE IDUsuario = @IDUsuario)
    BEGIN
        INSERT INTO Perfil (IDUsuario)
        VALUES (@IDUsuario)
    END
END
GO

CREATE OR ALTER PROCEDURE VincularLoginExterno
    @IDUsuario INT,
    @Proveedor NVARCHAR(20),
    @IDExterno NVARCHAR(200)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM LoginExterno WHERE Proveedor = @Proveedor AND ID_Externo = @IDExterno)
    BEGIN
        INSERT INTO LoginExterno (IDUsuario, Proveedor, ID_Externo)
        VALUES (@IDUsuario, @Proveedor, @IDExterno)
    END
END
GO

CREATE OR ALTER PROCEDURE RegistrarPersona
    @Nombre NVARCHAR(50),
    @Apellido NVARCHAR(50),
    @Email NVARCHAR(100),
    @Contrasena NVARCHAR(200),
    @Proveedor NVARCHAR(20) = NULL,
    @IDExterno NVARCHAR(200) = NULL
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @ID INT

    BEGIN TRANSACTION
        INSERT INTO Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
        VALUES (@Nombre, @Apellido, @Email, @Contrasena, CAST(GETDATE() AS DATE), N'Persona')
        SET @ID = SCOPE_IDENTITY()

        EXEC AsegurarPerfil @ID

        IF @Proveedor IS NOT NULL
            EXEC VincularLoginExterno @ID, @Proveedor, @IDExterno
    COMMIT TRANSACTION

    SELECT @ID AS ID
END
GO

CREATE OR ALTER PROCEDURE RegistrarEmpresa
    @Nombre NVARCHAR(50),
    @Apellido NVARCHAR(50),
    @Email NVARCHAR(100),
    @Contrasena NVARCHAR(200),
    @NombreEmpresa NVARCHAR(100),
    @Descripcion NVARCHAR(500),
    @Logo NVARCHAR(260),
    @Ubicacion NVARCHAR(100),
    @Sitio_Web NVARCHAR(200),
    @Razon_Social NVARCHAR(150),
    @CUIT CHAR(11),
    @Rubro NVARCHAR(60),
    @IDProvincia INT,
    @Telefono NVARCHAR(30),
    @Proveedor NVARCHAR(20) = NULL,
    @IDExterno NVARCHAR(200) = NULL
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @ID INT
    DECLARE @IDEmpresa INT

    BEGIN TRANSACTION
        INSERT INTO Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
        VALUES (@Nombre, @Apellido, @Email, @Contrasena, CAST(GETDATE() AS DATE), N'Empresa')
        SET @ID = SCOPE_IDENTITY()

        SELECT TOP 1 @IDEmpresa = ID
        FROM Empresa
        WHERE Nombre = @NombreEmpresa AND IDUsuario IS NULL
        ORDER BY ID

        IF @IDEmpresa IS NOT NULL
        BEGIN
            UPDATE Empresa
            SET IDUsuario = @ID, Descripcion = @Descripcion, Logo = @Logo, Ubicacion = @Ubicacion, Sitio_Web = @Sitio_Web,
                Razon_Social = @Razon_Social, CUIT = @CUIT, Rubro = @Rubro, IDProvincia = @IDProvincia, Telefono = @Telefono
            WHERE ID = @IDEmpresa
        END
        ELSE
        BEGIN
            INSERT INTO Empresa (Nombre, Descripcion, Logo, Ubicacion, Sitio_Web, IDUsuario, Razon_Social, CUIT, Rubro, IDProvincia, Telefono)
            VALUES (@NombreEmpresa, @Descripcion, @Logo, @Ubicacion, @Sitio_Web, @ID, @Razon_Social, @CUIT, @Rubro, @IDProvincia, @Telefono)
        END

        IF @Proveedor IS NOT NULL
            EXEC VincularLoginExterno @ID, @Proveedor, @IDExterno
    COMMIT TRANSACTION

    SELECT @ID AS ID
END
GO

CREATE OR ALTER PROCEDURE ObtenerUsuarioDeLoginExterno
    @Proveedor NVARCHAR(20),
    @IDExterno NVARCHAR(200)
AS
BEGIN
    SELECT IDUsuario
    FROM LoginExterno
    WHERE Proveedor = @Proveedor AND ID_Externo = @IDExterno
END
GO

CREATE OR ALTER PROCEDURE ObtenerProveedoresVinculados
    @IDUsuario INT
AS
BEGIN
    SELECT Proveedor
    FROM LoginExterno
    WHERE IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE GuardarCV
    @IDUsuario INT,
    @Archivo NVARCHAR(260),
    @CambiarArchivo BIT,
    @SitioWeb NVARCHAR(200),
    @CambiarSitio BIT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM CV WHERE IDUsuario = @IDUsuario)
    BEGIN
        INSERT INTO CV (IDUsuario, Fecha_Actualizacion)
        VALUES (@IDUsuario, CAST(GETDATE() AS DATE))
    END

    UPDATE CV
    SET Nombre_Archivo = CASE WHEN @CambiarArchivo = 1 THEN @Archivo ELSE Nombre_Archivo END,
        Sitio_Web = CASE WHEN @CambiarSitio = 1 THEN @SitioWeb ELSE Sitio_Web END,
        Fecha_Actualizacion = CAST(GETDATE() AS DATE)
    WHERE IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE ActualizarDatosPersonales
    @IDUsuario INT,
    @Nombre NVARCHAR(50),
    @Apellido NVARCHAR(50),
    @Email NVARCHAR(100),
    @IDProvincia INT,
    @Telefono NVARCHAR(30),
    @SitioWeb NVARCHAR(200)
AS
BEGIN
    SET XACT_ABORT ON

    BEGIN TRANSACTION
        UPDATE Usuario
        SET Nombre = @Nombre, Apellido = @Apellido, Email = @Email
        WHERE ID = @IDUsuario

        EXEC AsegurarPerfil @IDUsuario

        UPDATE Perfil
        SET IDProvincia = @IDProvincia, Telefono = @Telefono
        WHERE IDUsuario = @IDUsuario

        EXEC GuardarCV @IDUsuario, NULL, 0, @SitioWeb, 1
    COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE CompletarPerfil
    @IDUsuario INT,
    @IDProvincia INT,
    @Telefono NVARCHAR(30),
    @Descripcion NVARCHAR(500),
    @EstadoBusqueda NVARCHAR(30),
    @Foto NVARCHAR(260),
    @ArchivoCV NVARCHAR(260),
    @SitioWeb NVARCHAR(200)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @FotoAnterior NVARCHAR(260)
    DECLARE @CVAnterior NVARCHAR(260)
    DECLARE @CambiarArchivo BIT
    SET @CambiarArchivo = CASE WHEN @ArchivoCV IS NULL THEN 0 ELSE 1 END

    BEGIN TRANSACTION
        EXEC AsegurarPerfil @IDUsuario

        IF @Foto IS NOT NULL
            SELECT @FotoAnterior = Foto FROM Perfil WHERE IDUsuario = @IDUsuario

        IF @ArchivoCV IS NOT NULL
            SELECT @CVAnterior = Nombre_Archivo FROM CV WHERE IDUsuario = @IDUsuario

        UPDATE Perfil
        SET IDProvincia = @IDProvincia, Telefono = @Telefono, Descripcion = @Descripcion, Estado_Busqueda = @EstadoBusqueda,
            Foto = COALESCE(@Foto, Foto)
        WHERE IDUsuario = @IDUsuario

        EXEC GuardarCV @IDUsuario, @ArchivoCV, @CambiarArchivo, @SitioWeb, 1
    COMMIT TRANSACTION

    SELECT @FotoAnterior AS FotoAnterior, @CVAnterior AS CVAnterior
END
GO

CREATE OR ALTER PROCEDURE ActualizarResponsable
    @IDUsuario INT,
    @Nombre NVARCHAR(50),
    @Apellido NVARCHAR(50)
AS
BEGIN
    UPDATE Usuario
    SET Nombre = @Nombre, Apellido = @Apellido
    WHERE ID = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE CambiarContrasena
    @IDUsuario INT,
    @Hash NVARCHAR(200)
AS
BEGIN
    UPDATE Usuario
    SET [Contraseña] = @Hash
    WHERE ID = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE ActualizarFoto
    @IDUsuario INT,
    @Foto NVARCHAR(260)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @FotoAnterior NVARCHAR(260)

    BEGIN TRANSACTION
        EXEC AsegurarPerfil @IDUsuario

        SELECT @FotoAnterior = Foto FROM Perfil WHERE IDUsuario = @IDUsuario

        UPDATE Perfil
        SET Foto = @Foto
        WHERE IDUsuario = @IDUsuario
    COMMIT TRANSACTION

    SELECT @FotoAnterior AS FotoAnterior
END
GO

CREATE OR ALTER PROCEDURE ActualizarDescripcion
    @IDUsuario INT,
    @Descripcion NVARCHAR(500)
AS
BEGIN
    EXEC AsegurarPerfil @IDUsuario

    UPDATE Perfil
    SET Descripcion = @Descripcion
    WHERE IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE ActualizarEstadoBusqueda
    @IDUsuario INT,
    @EstadoBusqueda NVARCHAR(30)
AS
BEGIN
    EXEC AsegurarPerfil @IDUsuario

    UPDATE Perfil
    SET Estado_Busqueda = @EstadoBusqueda
    WHERE IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE ActualizarArchivoCV
    @IDUsuario INT,
    @Archivo NVARCHAR(260)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @CVAnterior NVARCHAR(260)

    BEGIN TRANSACTION
        SELECT @CVAnterior = Nombre_Archivo FROM CV WHERE IDUsuario = @IDUsuario

        EXEC GuardarCV @IDUsuario, @Archivo, 1, NULL, 0
    COMMIT TRANSACTION

    SELECT @CVAnterior AS CVAnterior
END
GO

CREATE OR ALTER PROCEDURE BorrarHabilidadesSinUso
AS
BEGIN
    DELETE h
    FROM Habilidad h
    WHERE h.IDSector IS NULL
      AND NOT EXISTS (SELECT 1 FROM UsuarioHabilidad uh WHERE uh.IDHabilidad = h.ID)
END
GO

CREATE OR ALTER PROCEDURE EliminarCuenta
    @IDUsuario INT
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @Foto NVARCHAR(260)
    DECLARE @CV NVARCHAR(260)
    DECLARE @Logo NVARCHAR(260)
    DECLARE @Ofertas TABLE (ID INT)

    BEGIN TRANSACTION
        SELECT @Foto = Foto FROM Perfil WHERE IDUsuario = @IDUsuario
        SELECT @CV = Nombre_Archivo FROM CV WHERE IDUsuario = @IDUsuario
        SELECT @Logo = Logo FROM Empresa WHERE IDUsuario = @IDUsuario

        INSERT INTO @Ofertas (ID)
        SELECT o.ID
        FROM OfertaLaboral o
        WHERE o.IDUsuario_Publicador = @IDUsuario
           OR o.IDEmpresa IN (SELECT ID FROM Empresa WHERE IDUsuario = @IDUsuario)

        DELETE FROM Postulacion
        WHERE IDOfertaLaboral IN (SELECT ID FROM @Ofertas)

        DELETE f
        FROM Favorito f
        JOIN FavoritoOferta fo ON fo.IDFavorito = f.ID_favorito
        WHERE fo.IDOfertaLaboral IN (SELECT ID FROM @Ofertas)

        DELETE FROM OfertaLaboral
        WHERE ID IN (SELECT ID FROM @Ofertas)

        UPDATE Empresa
        SET IDUsuario = NULL, CUIT = NULL, Razon_Social = NULL, Logo = NULL
        WHERE IDUsuario = @IDUsuario

        DELETE FROM Usuario
        WHERE ID = @IDUsuario

        EXEC BorrarHabilidadesSinUso
    COMMIT TRANSACTION

    SELECT @Foto AS Foto, @CV AS CV, @Logo AS Logo
END
GO

CREATE OR ALTER PROCEDURE ContarRecuperacionesRecientes
    @IDUsuario INT
AS
BEGIN
    SELECT COUNT(*) AS Cantidad
    FROM RecuperacionClave
    WHERE IDUsuario = @IDUsuario AND Fecha >= DATEADD(HOUR, -1, SYSUTCDATETIME())
END
GO

CREATE OR ALTER PROCEDURE GuardarRecuperacion
    @IDUsuario INT,
    @TokenHash CHAR(64),
    @Vence DATETIME2(0)
AS
BEGIN
    INSERT INTO RecuperacionClave (IDUsuario, Token_Hash, Vence)
    VALUES (@IDUsuario, @TokenHash, @Vence)
END
GO

CREATE OR ALTER PROCEDURE ObtenerUsuarioDeRecuperacion
    @TokenHash CHAR(64)
AS
BEGIN
    SELECT IDUsuario
    FROM RecuperacionClave
    WHERE Token_Hash = @TokenHash AND Usada = 0 AND Vence > SYSUTCDATETIME()
END
GO

CREATE OR ALTER PROCEDURE UsarRecuperacion
    @TokenHash CHAR(64),
    @Contrasena NVARCHAR(200)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @IDUsuario INT

    BEGIN TRANSACTION
        SELECT @IDUsuario = IDUsuario
        FROM RecuperacionClave WITH (UPDLOCK)
        WHERE Token_Hash = @TokenHash AND Usada = 0 AND Vence > SYSUTCDATETIME()

        IF @IDUsuario IS NULL
        BEGIN
            ROLLBACK TRANSACTION
            SELECT CAST(0 AS BIT) AS Usada
            RETURN
        END

        UPDATE Usuario
        SET [Contraseña] = @Contrasena
        WHERE ID = @IDUsuario

        UPDATE RecuperacionClave
        SET Usada = 1
        WHERE IDUsuario = @IDUsuario AND Usada = 0
    COMMIT TRANSACTION

    SELECT CAST(1 AS BIT) AS Usada
END
GO

CREATE OR ALTER PROCEDURE ObtenerPaises
AS
BEGIN
    SELECT ID, Nombre, Codigo_ISO, Codigo_Telefono
    FROM Pais
    ORDER BY Nombre
END
GO

CREATE OR ALTER PROCEDURE ObtenerProvincias
AS
BEGIN
    SELECT ID, IDPais, Nombre
    FROM Provincia
    ORDER BY Nombre
END
GO

CREATE OR ALTER PROCEDURE ObtenerPerfil
    @IDUsuario INT
AS
BEGIN
    SELECT pe.ID, pe.IDUsuario, pe.IDProvincia, pe.Foto, pe.Descripcion, pe.Telefono, pe.Estado_Busqueda,
           pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais, pa.Codigo_Telefono
    FROM Perfil pe
    LEFT JOIN Provincia pr ON pr.ID = pe.IDProvincia
    LEFT JOIN Pais pa ON pa.ID = pr.IDPais
    WHERE pe.IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE ObtenerCV
    @IDUsuario INT
AS
BEGIN
    SELECT ID, IDUsuario, Nombre_Archivo, Sitio_Web, Fecha_Actualizacion
    FROM CV
    WHERE IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE ObtenerPreferencia
    @IDUsuario INT
AS
BEGIN
    SELECT p.ID, p.IDUsuario, p.Puesto_Buscado, p.Niveles, p.Modalidades, p.Jornada, p.Contratacion, p.IDProvincia,
           p.Salario_Minimo, p.Salario_Maximo, p.Disponibilidad, pr.Nombre AS Provincia
    FROM Preferencia p
    LEFT JOIN Provincia pr ON pr.ID = p.IDProvincia
    WHERE p.IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE GuardarPreferencia
    @IDUsuario INT,
    @Puesto_Buscado NVARCHAR(100),
    @Niveles NVARCHAR(100),
    @Modalidades NVARCHAR(60),
    @Jornada NVARCHAR(20),
    @Contratacion NVARCHAR(40),
    @IDProvincia INT,
    @Salario_Minimo INT,
    @Salario_Maximo INT,
    @Disponibilidad NVARCHAR(20)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Preferencia WHERE IDUsuario = @IDUsuario)
    BEGIN
        INSERT INTO Preferencia (IDUsuario, Puesto_Buscado, Niveles, Modalidades, Jornada, Contratacion, IDProvincia,
                                 Salario_Minimo, Salario_Maximo, Disponibilidad)
        VALUES (@IDUsuario, @Puesto_Buscado, @Niveles, @Modalidades, @Jornada, @Contratacion, @IDProvincia,
                @Salario_Minimo, @Salario_Maximo, @Disponibilidad)
    END
    ELSE
    BEGIN
        UPDATE Preferencia
        SET Puesto_Buscado = @Puesto_Buscado, Niveles = @Niveles, Modalidades = @Modalidades, Jornada = @Jornada,
            Contratacion = @Contratacion, IDProvincia = @IDProvincia, Salario_Minimo = @Salario_Minimo,
            Salario_Maximo = @Salario_Maximo, Disponibilidad = @Disponibilidad
        WHERE IDUsuario = @IDUsuario
    END
END
GO

CREATE OR ALTER PROCEDURE ObtenerSectores
AS
BEGIN
    SELECT ID, Nombre
    FROM Sector
    ORDER BY Orden, Nombre
END
GO

CREATE OR ALTER PROCEDURE ObtenerCatalogoHabilidades
AS
BEGIN
    SELECT h.ID, h.Nombre, h.IDSector, s.Nombre AS Sector
    FROM Habilidad h
    JOIN Sector s ON s.ID = h.IDSector
    ORDER BY s.Orden, s.Nombre, h.Nombre
END
GO

CREATE OR ALTER PROCEDURE ObtenerHabilidadesUsuario
    @IDUsuario INT
AS
BEGIN
    SELECT h.Nombre
    FROM UsuarioHabilidad uh
    JOIN Habilidad h ON h.ID = uh.IDHabilidad
    WHERE uh.IDUsuario = @IDUsuario
    ORDER BY h.Nombre
END
GO

CREATE OR ALTER PROCEDURE QuitarHabilidadesUsuario
    @IDUsuario INT
AS
BEGIN
    DELETE FROM UsuarioHabilidad
    WHERE IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE AgregarHabilidadUsuario
    @IDUsuario INT,
    @Nombre NVARCHAR(60)
AS
BEGIN
    DECLARE @IDHabilidad INT

    IF NOT EXISTS (SELECT 1 FROM Habilidad WHERE Nombre = @Nombre)
    BEGIN
        INSERT INTO Habilidad (Nombre)
        VALUES (@Nombre)
    END

    SELECT TOP 1 @IDHabilidad = ID
    FROM Habilidad
    WHERE Nombre = @Nombre
    ORDER BY ID

    IF NOT EXISTS (SELECT 1 FROM UsuarioHabilidad WHERE IDUsuario = @IDUsuario AND IDHabilidad = @IDHabilidad)
    BEGIN
        INSERT INTO UsuarioHabilidad (IDUsuario, IDHabilidad)
        VALUES (@IDUsuario, @IDHabilidad)
    END
END
GO

CREATE OR ALTER PROCEDURE ObtenerCatalogoIdiomas
AS
BEGIN
    SELECT ID, Nombre
    FROM Idioma
    ORDER BY Nombre
END
GO

CREATE OR ALTER PROCEDURE ObtenerIdiomasUsuario
    @IDUsuario INT
AS
BEGIN
    SELECT ui.IDIdioma, i.Nombre AS Idioma, ui.Nivel
    FROM UsuarioIdioma ui
    JOIN Idioma i ON i.ID = ui.IDIdioma
    WHERE ui.IDUsuario = @IDUsuario
    ORDER BY i.Nombre
END
GO

CREATE OR ALTER PROCEDURE QuitarIdiomasUsuario
    @IDUsuario INT
AS
BEGIN
    DELETE FROM UsuarioIdioma
    WHERE IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE AgregarIdiomaUsuario
    @IDUsuario INT,
    @IDIdioma INT,
    @Nivel NVARCHAR(20)
AS
BEGIN
    INSERT INTO UsuarioIdioma (IDUsuario, IDIdioma, Nivel)
    VALUES (@IDUsuario, @IDIdioma, @Nivel)
END
GO

CREATE OR ALTER PROCEDURE ObtenerExperiencias
    @IDUsuario INT
AS
BEGIN
    SELECT x.ID, x.Puesto, e.Nombre AS Empresa, x.Descripcion, x.Fecha_Inicio, x.Fecha_Finalizacion
    FROM ExperienciaLaboral x
    JOIN Empresa e ON e.ID = x.IDEmpresa
    WHERE x.IDUsuario = @IDUsuario
    ORDER BY CASE WHEN x.Fecha_Finalizacion IS NULL THEN 0 ELSE 1 END, x.Fecha_Inicio DESC
END
GO

CREATE OR ALTER PROCEDURE AgregarExperiencia
    @IDUsuario INT,
    @Empresa NVARCHAR(100),
    @Puesto NVARCHAR(100),
    @Descripcion NVARCHAR(500),
    @Inicio DATE,
    @Fin DATE
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @IDEmpresa INT

    BEGIN TRANSACTION
        IF NOT EXISTS (SELECT 1 FROM Empresa WHERE Nombre = @Empresa)
        BEGIN
            INSERT INTO Empresa (Nombre)
            VALUES (@Empresa)
        END

        SELECT TOP 1 @IDEmpresa = ID
        FROM Empresa
        WHERE Nombre = @Empresa
        ORDER BY ID

        INSERT INTO ExperienciaLaboral (IDUsuario, IDEmpresa, Puesto, Descripcion, Fecha_Inicio, Fecha_Finalizacion)
        VALUES (@IDUsuario, @IDEmpresa, @Puesto, @Descripcion, @Inicio, @Fin)
    COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE EliminarExperiencia
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    DELETE FROM ExperienciaLaboral
    WHERE ID = @ID AND IDUsuario = @IDUsuario

    SELECT @@ROWCOUNT AS Filas
END
GO

CREATE OR ALTER PROCEDURE ObtenerFormaciones
    @IDUsuario INT
AS
BEGIN
    SELECT ue.ID, ue.Titulo, ed.Institucion, ue.Fecha_Inicio, ue.Fecha_Fin
    FROM UsuarioEducacion ue
    JOIN Educacion ed ON ed.ID = ue.IDEducacion
    WHERE ue.IDUsuario = @IDUsuario
    ORDER BY CASE WHEN ue.Fecha_Fin IS NULL THEN 0 ELSE 1 END, ue.Fecha_Inicio DESC
END
GO

CREATE OR ALTER PROCEDURE AgregarFormacion
    @IDUsuario INT,
    @Institucion NVARCHAR(150),
    @Titulo NVARCHAR(150),
    @Inicio DATE,
    @Fin DATE
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @IDEducacion INT

    BEGIN TRANSACTION
        IF NOT EXISTS (SELECT 1 FROM Educacion WHERE Institucion = @Institucion)
        BEGIN
            INSERT INTO Educacion (Institucion)
            VALUES (@Institucion)
        END

        SELECT TOP 1 @IDEducacion = ID
        FROM Educacion
        WHERE Institucion = @Institucion
        ORDER BY ID

        INSERT INTO UsuarioEducacion (IDUsuario, IDEducacion, Titulo, Fecha_Inicio, Fecha_Fin)
        VALUES (@IDUsuario, @IDEducacion, @Titulo, @Inicio, @Fin)
    COMMIT TRANSACTION
END
GO

CREATE OR ALTER PROCEDURE EliminarFormacion
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    DELETE FROM UsuarioEducacion
    WHERE ID = @ID AND IDUsuario = @IDUsuario

    SELECT @@ROWCOUNT AS Filas
END
GO

CREATE OR ALTER PROCEDURE ObtenerInstituciones
AS
BEGIN
    SELECT Institucion
    FROM Educacion
    ORDER BY Institucion
END
GO

CREATE OR ALTER PROCEDURE BuscarEmpresas
    @Texto NVARCHAR(200) = NULL,
    @Rubro NVARCHAR(60) = NULL,
    @IDPais INT = NULL,
    @IDProvincia INT = NULL,
    @Orden NVARCHAR(20) = NULL
AS
BEGIN
    DECLARE @Patron NVARCHAR(700)
    SET @Patron = CASE WHEN TRIM(ISNULL(@Texto, N'')) = N'' THEN NULL
                   ELSE N'%' + REPLACE(REPLACE(REPLACE(TRIM(@Texto), N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]') + N'%' END

    SELECT e.ID, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.IDUsuario, e.Razon_Social, e.CUIT,
           e.Rubro, e.IDProvincia, e.Telefono, e.Fecha_Registro, pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais,
           (SELECT COUNT(*) FROM OfertaLaboral o
            WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'
              AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))) AS BusquedasActivas
    FROM Empresa e
    LEFT JOIN Provincia pr ON pr.ID = e.IDProvincia
    LEFT JOIN Pais pa ON pa.ID = pr.IDPais
    WHERE (e.IDUsuario IS NOT NULL
           OR EXISTS (SELECT 1 FROM OfertaLaboral o WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'))
      AND (@Patron IS NULL OR e.Nombre LIKE @Patron OR e.Descripcion LIKE @Patron)
      AND (@Rubro IS NULL OR e.Rubro = @Rubro)
      AND (@IDProvincia IS NULL OR e.IDProvincia = @IDProvincia)
      AND (@IDPais IS NULL OR pa.ID = @IDPais)
    ORDER BY CASE WHEN @Orden = 'az' THEN e.Nombre END,
             CASE WHEN @Orden = 'antiguas' THEN e.Fecha_Registro END,
             CASE WHEN @Orden = 'antiguas' THEN e.ID END,
             CASE WHEN ISNULL(@Orden, '') NOT IN ('az', 'antiguas') THEN e.Fecha_Registro END DESC,
             CASE WHEN ISNULL(@Orden, '') NOT IN ('az', 'antiguas') THEN e.ID END DESC
END
GO

CREATE OR ALTER PROCEDURE ObtenerEmpresasConBusquedas
    @Cantidad INT
AS
BEGIN
    SELECT TOP (@Cantidad) *
    FROM (
    SELECT e.ID, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.IDUsuario, e.Razon_Social, e.CUIT,
           e.Rubro, e.IDProvincia, e.Telefono, e.Fecha_Registro, pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais,
           (SELECT COUNT(*) FROM OfertaLaboral o
            WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'
              AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))) AS BusquedasActivas
    FROM Empresa e
    LEFT JOIN Provincia pr ON pr.ID = e.IDProvincia
    LEFT JOIN Pais pa ON pa.ID = pr.IDPais
    ) x
    WHERE x.BusquedasActivas > 0
    ORDER BY x.BusquedasActivas DESC, x.Nombre
END
GO

CREATE OR ALTER PROCEDURE ObtenerEmpresa
    @ID INT
AS
BEGIN
    SELECT e.ID, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.IDUsuario, e.Razon_Social, e.CUIT,
           e.Rubro, e.IDProvincia, e.Telefono, e.Fecha_Registro, pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais,
           (SELECT COUNT(*) FROM OfertaLaboral o
            WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'
              AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))) AS BusquedasActivas
    FROM Empresa e
    LEFT JOIN Provincia pr ON pr.ID = e.IDProvincia
    LEFT JOIN Pais pa ON pa.ID = pr.IDPais
    WHERE e.ID = @ID
END
GO

CREATE OR ALTER PROCEDURE ObtenerEmpresaDeUsuario
    @IDUsuario INT
AS
BEGIN
    SELECT e.ID, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.IDUsuario, e.Razon_Social, e.CUIT,
           e.Rubro, e.IDProvincia, e.Telefono, e.Fecha_Registro, pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais,
           (SELECT COUNT(*) FROM OfertaLaboral o
            WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'
              AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))) AS BusquedasActivas
    FROM Empresa e
    LEFT JOIN Provincia pr ON pr.ID = e.IDProvincia
    LEFT JOIN Pais pa ON pa.ID = pr.IDPais
    WHERE e.IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE ExisteCuit
    @CUIT CHAR(11)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Empresa WHERE CUIT = @CUIT)
        SELECT CAST(1 AS BIT) AS Existe
    ELSE
        SELECT CAST(0 AS BIT) AS Existe
END
GO

CREATE OR ALTER PROCEDURE NombreEmpresaConCuenta
    @Nombre NVARCHAR(100),
    @Excepto INT = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Empresa WHERE Nombre = @Nombre AND IDUsuario IS NOT NULL AND ID <> ISNULL(@Excepto, 0))
        SELECT CAST(1 AS BIT) AS Existe
    ELSE
        SELECT CAST(0 AS BIT) AS Existe
END
GO

CREATE OR ALTER PROCEDURE ExisteNombreEmpresa
    @Nombre NVARCHAR(100),
    @Excepto INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Empresa WHERE Nombre = @Nombre AND ID <> @Excepto)
        SELECT CAST(1 AS BIT) AS Existe
    ELSE
        SELECT CAST(0 AS BIT) AS Existe
END
GO

CREATE OR ALTER PROCEDURE ActualizarEmpresa
    @ID INT,
    @IDUsuario INT,
    @Nombre NVARCHAR(100),
    @Descripcion NVARCHAR(500),
    @Ubicacion NVARCHAR(100),
    @Sitio_Web NVARCHAR(200),
    @Rubro NVARCHAR(60),
    @IDProvincia INT,
    @Telefono NVARCHAR(30)
AS
BEGIN
    UPDATE Empresa
    SET Nombre = @Nombre, Descripcion = @Descripcion, Ubicacion = @Ubicacion, Sitio_Web = @Sitio_Web,
        Rubro = @Rubro, IDProvincia = @IDProvincia, Telefono = @Telefono
    WHERE ID = @ID AND IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE ActualizarLogo
    @IDUsuario INT,
    @Logo NVARCHAR(260)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @LogoAnterior NVARCHAR(260)

    BEGIN TRANSACTION
        SELECT @LogoAnterior = Logo FROM Empresa WHERE IDUsuario = @IDUsuario

        UPDATE Empresa
        SET Logo = @Logo
        WHERE IDUsuario = @IDUsuario
    COMMIT TRANSACTION

    SELECT @LogoAnterior AS LogoAnterior
END
GO

CREATE OR ALTER PROCEDURE BuscarOfertas
    @IDUsuarioActual INT,
    @Texto NVARCHAR(200) = NULL,
    @IDProvincia INT = NULL,
    @Modalidades NVARCHAR(200) = NULL,
    @Tipos NVARCHAR(400) = NULL,
    @Dias INT = NULL
AS
BEGIN
    DECLARE @Patron NVARCHAR(700)
    SET @Patron = CASE WHEN TRIM(ISNULL(@Texto, N'')) = N'' THEN NULL
                   ELSE N'%' + REPLACE(REPLACE(REPLACE(TRIM(@Texto), N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]') + N'%' END

    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.Estado_Publicacion = N'Aprobada' AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))
      AND (@Patron IS NULL OR o.Titulo LIKE @Patron OR o.Descripcion LIKE @Patron OR e.Nombre LIKE @Patron
           OR EXISTS (SELECT 1 FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
                      WHERE op.IDOfertaLaboral = o.ID AND p.Nombre LIKE @Patron))
      AND (@IDProvincia IS NULL OR o.IDProvincia = @IDProvincia OR o.Modalidad = N'Remoto')
      AND (@Modalidades IS NULL OR o.Modalidad IN (SELECT value FROM STRING_SPLIT(@Modalidades, ',')))
      AND (@Tipos IS NULL OR o.Tipo_Contrato IN (SELECT value FROM STRING_SPLIT(@Tipos, ',')))
      AND (@Dias IS NULL OR o.Fecha_Publicacion >= DATEADD(DAY, -@Dias, CAST(GETDATE() AS DATE)))
    ORDER BY o.Fecha_Publicacion DESC, o.ID DESC
END
GO

CREATE OR ALTER PROCEDURE ObtenerOferta
    @ID INT,
    @IDUsuarioActual INT
AS
BEGIN
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.ID = @ID
END
GO

CREATE OR ALTER PROCEDURE ObtenerOfertasDeEmpresa
    @IDEmpresa INT,
    @IDUsuarioActual INT
AS
BEGIN
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.IDEmpresa = @IDEmpresa
      AND o.Estado_Publicacion = N'Aprobada' AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))
    ORDER BY o.Fecha_Publicacion DESC, o.ID DESC
END
GO

CREATE OR ALTER PROCEDURE ObtenerOfertasPublicadas
    @IDUsuario INT
AS
BEGIN
    DECLARE @IDUsuarioActual INT
    SET @IDUsuarioActual = 0

    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.IDUsuario_Publicador = @IDUsuario
    ORDER BY o.Fecha_Publicacion DESC, o.ID DESC
END
GO

CREATE OR ALTER PROCEDURE TieneOfertasPublicadas
    @IDUsuario INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM OfertaLaboral WHERE IDUsuario_Publicador = @IDUsuario)
        SELECT CAST(1 AS BIT) AS Tiene
    ELSE
        SELECT CAST(0 AS BIT) AS Tiene
END
GO

CREATE OR ALTER PROCEDURE ObtenerTitulosRecientes
    @Cantidad INT
AS
BEGIN
    SELECT TOP (@Cantidad) Titulo
    FROM (
        SELECT o.Titulo, CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha
        FROM OfertaLaboral o
        WHERE o.Estado_Publicacion = N'Aprobada'
        UNION ALL
        SELECT x.Titulo, x.Fecha_Consulta
        FROM OfertaExterna x
    ) t
    ORDER BY Fecha DESC
END
GO

CREATE OR ALTER PROCEDURE CrearOferta
    @IDUsuario_Publicador INT,
    @IDEmpresa INT = NULL,
    @EmpresaNombre NVARCHAR(100) = NULL,
    @Titulo NVARCHAR(150),
    @Puesto NVARCHAR(100),
    @IDSector INT,
    @Descripcion NVARCHAR(2000),
    @Ubicacion NVARCHAR(100),
    @IDProvincia INT,
    @Modalidad NVARCHAR(20),
    @Tipo_Contrato NVARCHAR(50),
    @Salario INT,
    @Cantidad_Puestos INT,
    @Fecha_Cierre DATE,
    @Estado_Publicacion NVARCHAR(20)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @ID INT

    BEGIN TRANSACTION
        IF @IDEmpresa IS NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Empresa WHERE Nombre = @EmpresaNombre)
            BEGIN
                INSERT INTO Empresa (Nombre)
                VALUES (@EmpresaNombre)
            END

            SELECT TOP 1 @IDEmpresa = ID
            FROM Empresa
            WHERE Nombre = @EmpresaNombre
            ORDER BY ID
        END

        INSERT INTO OfertaLaboral (IDEmpresa, Titulo, Descripcion, Ubicacion, Modalidad, Tipo_Contrato, Salario, Cantidad_Puestos,
                                   Fecha_Publicacion, Fecha_Cierre, IDUsuario_Publicador, IDProvincia, Estado_Publicacion)
        VALUES (@IDEmpresa, @Titulo, @Descripcion, @Ubicacion, @Modalidad, @Tipo_Contrato, @Salario, @Cantidad_Puestos,
                CAST(GETDATE() AS DATE), @Fecha_Cierre, @IDUsuario_Publicador, @IDProvincia, @Estado_Publicacion)
        SET @ID = SCOPE_IDENTITY()

        IF NOT EXISTS (SELECT 1 FROM Puesto WHERE Nombre = @Puesto)
        BEGIN
            INSERT INTO Puesto (Nombre, IDSector)
            VALUES (@Puesto, @IDSector)
        END

        UPDATE Puesto
        SET IDSector = @IDSector
        WHERE Nombre = @Puesto AND IDSector IS NULL

        INSERT INTO OfertaPuesto (IDOfertaLaboral, IDPuesto)
        SELECT @ID, ID
        FROM Puesto
        WHERE Nombre = @Puesto
    COMMIT TRANSACTION

    SELECT @ID AS ID
END
GO

CREATE OR ALTER PROCEDURE CerrarOferta
    @ID INT,
    @IDPublicador INT
AS
BEGIN
    UPDATE OfertaLaboral
    SET Fecha_Cierre = CAST(GETDATE() AS DATE)
    WHERE ID = @ID AND IDUsuario_Publicador = @IDPublicador
      AND (Fecha_Cierre IS NULL OR Fecha_Cierre >= CAST(GETDATE() AS DATE))

    SELECT @@ROWCOUNT AS Filas
END
GO

CREATE OR ALTER PROCEDURE EliminarOferta
    @ID INT,
    @IDPublicador INT
AS
BEGIN
    SET XACT_ABORT ON

    IF NOT EXISTS (SELECT 1 FROM OfertaLaboral WHERE ID = @ID AND IDUsuario_Publicador = @IDPublicador)
    BEGIN
        SELECT CAST(0 AS BIT) AS Eliminada
        RETURN
    END

    BEGIN TRANSACTION
        DELETE FROM Postulacion
        WHERE IDOfertaLaboral = @ID

        DELETE f
        FROM Favorito f
        JOIN FavoritoOferta fo ON fo.IDFavorito = f.ID_favorito
        WHERE fo.IDOfertaLaboral = @ID

        DELETE FROM OfertaLaboral
        WHERE ID = @ID
    COMMIT TRANSACTION

    SELECT CAST(1 AS BIT) AS Eliminada
END
GO

CREATE OR ALTER PROCEDURE ObtenerOfertasPendientes
AS
BEGIN
    DECLARE @IDUsuarioActual INT
    SET @IDUsuarioActual = 0

    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.Estado_Publicacion = N'Pendiente'
    ORDER BY o.Fecha_Publicacion, o.ID
END
GO

CREATE OR ALTER PROCEDURE ObtenerOfertasRevisadas
    @Cantidad INT
AS
BEGIN
    DECLARE @IDUsuarioActual INT
    SET @IDUsuarioActual = 0

    SELECT TOP (@Cantidad) *
    FROM (
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.Estado_Publicacion <> N'Pendiente' AND o.Fecha_Revision IS NOT NULL
    ) x
    ORDER BY x.ID DESC
END
GO

CREATE OR ALTER PROCEDURE ContarOfertasPendientes
AS
BEGIN
    SELECT COUNT(*) AS Cantidad
    FROM OfertaLaboral
    WHERE Estado_Publicacion = N'Pendiente'
END
GO

CREATE OR ALTER PROCEDURE RevisarOferta
    @ID INT,
    @Aprobada BIT,
    @Motivo NVARCHAR(500) = NULL
AS
BEGIN
    UPDATE OfertaLaboral
    SET Estado_Publicacion = CASE WHEN @Aprobada = 1 THEN N'Aprobada' ELSE N'Rechazada' END,
        Motivo_Rechazo = CASE WHEN @Aprobada = 1 THEN NULL ELSE @Motivo END,
        Fecha_Revision = CAST(GETDATE() AS DATE),
        Fecha_Publicacion = CASE WHEN @Aprobada = 1 THEN CAST(GETDATE() AS DATE) ELSE Fecha_Publicacion END
    WHERE ID = @ID AND Estado_Publicacion = N'Pendiente'

    SELECT @@ROWCOUNT AS Filas
END
GO

CREATE OR ALTER PROCEDURE GuardarOfertaExterna
    @ID_Externo NVARCHAR(200),
    @Titulo NVARCHAR(300),
    @Empresa NVARCHAR(200),
    @Logo NVARCHAR(1000),
    @Ubicacion NVARCHAR(200),
    @Descripcion NVARCHAR(MAX),
    @Es_Remoto BIT,
    @Tipo_Contrato NVARCHAR(50),
    @Salario NVARCHAR(100),
    @Link_Postulacion NVARCHAR(2000),
    @Publicador NVARCHAR(100),
    @Fecha_Publicacion DATETIME2
AS
BEGIN
    DECLARE @IDUsuarioActual INT
    SET @IDUsuarioActual = 0

    IF EXISTS (SELECT 1 FROM OfertaExterna WHERE ID_Externo = @ID_Externo)
    BEGIN
        UPDATE OfertaExterna
        SET Titulo = @Titulo, Empresa = @Empresa, Logo = @Logo, Ubicacion = @Ubicacion, Descripcion = @Descripcion,
            Es_Remoto = @Es_Remoto, Tipo_Contrato = @Tipo_Contrato, Salario = @Salario, Link_Postulacion = @Link_Postulacion,
            Publicador = @Publicador, Fecha_Publicacion = @Fecha_Publicacion, Fecha_Consulta = SYSUTCDATETIME()
        WHERE ID_Externo = @ID_Externo
    END
    ELSE
    BEGIN
        INSERT INTO OfertaExterna (ID_Externo, Titulo, Empresa, Logo, Ubicacion, Descripcion, Es_Remoto, Tipo_Contrato,
                                   Salario, Link_Postulacion, Publicador, Fecha_Publicacion)
        VALUES (@ID_Externo, @Titulo, @Empresa, @Logo, @Ubicacion, @Descripcion, @Es_Remoto, @Tipo_Contrato,
                @Salario, @Link_Postulacion, @Publicador, @Fecha_Publicacion)
    END

    SELECT CAST(1 AS BIT) AS EsExterna, x.ID, x.ID_Externo, x.Titulo, ISNULL(x.Empresa, N'Empresa sin nombre') AS Empresa,
           x.Logo, x.Ubicacion, CASE WHEN x.Es_Remoto = 1 THEN N'Remoto' ELSE NULL END AS Modalidad, x.Tipo_Contrato,
           x.Salario AS SalarioTexto, x.Descripcion, x.Fecha_Publicacion, x.Link_Postulacion, x.Publicador,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaExterna = x.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaExterna = x.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaExterna x
    WHERE x.ID_Externo = @ID_Externo
END
GO

CREATE OR ALTER PROCEDURE ObtenerOfertaExterna
    @ID INT,
    @IDUsuarioActual INT
AS
BEGIN
    SELECT CAST(1 AS BIT) AS EsExterna, x.ID, x.ID_Externo, x.Titulo, ISNULL(x.Empresa, N'Empresa sin nombre') AS Empresa,
           x.Logo, x.Ubicacion, CASE WHEN x.Es_Remoto = 1 THEN N'Remoto' ELSE NULL END AS Modalidad, x.Tipo_Contrato,
           x.Salario AS SalarioTexto, x.Descripcion, x.Fecha_Publicacion, x.Link_Postulacion, x.Publicador,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaExterna = x.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaExterna = x.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaExterna x
    WHERE x.ID = @ID
END
GO

CREATE OR ALTER PROCEDURE ObtenerMarcasExternas
    @IDUsuario INT,
    @IDs NVARCHAR(MAX)
AS
BEGIN
    SELECT x.ID,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaExterna = x.ID AND po.IDUsuario = @IDUsuario)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaExterna = x.ID AND f.IDUsuario = @IDUsuario)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaExterna x
    WHERE x.ID IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@IDs, ','))
END
GO

CREATE OR ALTER PROCEDURE GuardarOferta
    @IDUsuario INT,
    @IDOferta INT,
    @EsExterna BIT
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @Puede BIT
    DECLARE @IDFavorito INT
    SET @Puede = 0

    BEGIN TRANSACTION
        IF @EsExterna = 1
        BEGIN
            IF EXISTS (SELECT 1 FROM OfertaExterna WHERE ID = @IDOferta)
               AND NOT EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                               WHERE f.IDUsuario = @IDUsuario AND fo.IDOfertaExterna = @IDOferta)
                SET @Puede = 1
        END
        ELSE
        BEGIN
            IF EXISTS (SELECT 1 FROM OfertaLaboral WHERE ID = @IDOferta AND Estado_Publicacion = N'Aprobada')
               AND NOT EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                               WHERE f.IDUsuario = @IDUsuario AND fo.IDOfertaLaboral = @IDOferta)
                SET @Puede = 1
        END

        IF @Puede = 1
        BEGIN
            INSERT INTO Favorito (IDUsuario, fecha_guardado)
            VALUES (@IDUsuario, CAST(GETDATE() AS DATE))
            SET @IDFavorito = SCOPE_IDENTITY()

            INSERT INTO FavoritoOferta (IDFavorito, IDOfertaLaboral, IDOfertaExterna)
            VALUES (@IDFavorito,
                    CASE WHEN @EsExterna = 0 THEN @IDOferta END,
                    CASE WHEN @EsExterna = 1 THEN @IDOferta END)
        END
    COMMIT TRANSACTION

    SELECT @Puede AS Guardada
END
GO

CREATE OR ALTER PROCEDURE QuitarGuardada
    @IDUsuario INT,
    @IDOferta INT,
    @EsExterna BIT
AS
BEGIN
    DELETE f
    FROM Favorito f
    JOIN FavoritoOferta fo ON fo.IDFavorito = f.ID_favorito
    WHERE f.IDUsuario = @IDUsuario
      AND ((@EsExterna = 1 AND fo.IDOfertaExterna = @IDOferta)
           OR (@EsExterna = 0 AND fo.IDOfertaLaboral = @IDOferta))

    SELECT @@ROWCOUNT AS Filas
END
GO

CREATE OR ALTER PROCEDURE ObtenerGuardadas
    @IDUsuario INT
AS
BEGIN
    DECLARE @IDUsuarioActual INT
    SET @IDUsuarioActual = @IDUsuario

    SELECT w.*, CAST(f.fecha_guardado AS DATETIME2) AS Fecha_Guardado, f.ID_favorito AS IDFavorito
    FROM (
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    ) w
    JOIN FavoritoOferta fo ON fo.IDOfertaLaboral = w.ID
    JOIN Favorito f ON f.ID_favorito = fo.IDFavorito AND f.IDUsuario = @IDUsuario
    ORDER BY f.ID_favorito DESC

    SELECT w.*, CAST(f.fecha_guardado AS DATETIME2) AS Fecha_Guardado, f.ID_favorito AS IDFavorito
    FROM (
    SELECT CAST(1 AS BIT) AS EsExterna, x.ID, x.ID_Externo, x.Titulo, ISNULL(x.Empresa, N'Empresa sin nombre') AS Empresa,
           x.Logo, x.Ubicacion, CASE WHEN x.Es_Remoto = 1 THEN N'Remoto' ELSE NULL END AS Modalidad, x.Tipo_Contrato,
           x.Salario AS SalarioTexto, x.Descripcion, x.Fecha_Publicacion, x.Link_Postulacion, x.Publicador,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaExterna = x.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaExterna = x.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaExterna x
    ) w
    JOIN FavoritoOferta fo ON fo.IDOfertaExterna = w.ID
    JOIN Favorito f ON f.ID_favorito = fo.IDFavorito AND f.IDUsuario = @IDUsuario
    ORDER BY f.ID_favorito DESC
END
GO

CREATE OR ALTER PROCEDURE ContarGuardadas
    @IDUsuario INT
AS
BEGIN
    SELECT COUNT(*) AS Cantidad
    FROM Favorito
    WHERE IDUsuario = @IDUsuario
END
GO

CREATE OR ALTER PROCEDURE Postular
    @IDUsuario INT,
    @IDOferta INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Postulacion WHERE IDUsuario = @IDUsuario AND IDOfertaLaboral = @IDOferta)
    BEGIN
        SELECT 0 AS Filas
        RETURN
    END

    INSERT INTO Postulacion (IDUsuario, IDOfertaLaboral, Fecha, Estado)
    VALUES (@IDUsuario, @IDOferta, CAST(GETDATE() AS DATE), N'Enviada')

    SELECT @@ROWCOUNT AS Filas
END
GO

CREATE OR ALTER PROCEDURE RegistrarPostulacionExterna
    @IDUsuario INT,
    @IDOferta INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM OfertaExterna WHERE ID = @IDOferta)
       OR EXISTS (SELECT 1 FROM Postulacion WHERE IDUsuario = @IDUsuario AND IDOfertaExterna = @IDOferta)
    BEGIN
        SELECT 0 AS Filas
        RETURN
    END

    INSERT INTO Postulacion (IDUsuario, IDOfertaExterna, Fecha, Estado)
    VALUES (@IDUsuario, @IDOferta, CAST(GETDATE() AS DATE), N'Enviada')

    SELECT @@ROWCOUNT AS Filas
END
GO

CREATE OR ALTER PROCEDURE ObtenerPostulaciones
    @IDUsuario INT
AS
BEGIN
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
    WHERE po.IDUsuario = @IDUsuario
    ORDER BY po.Fecha DESC, po.ID DESC
END
GO

CREATE OR ALTER PROCEDURE CambiarEstadoPostulacion
    @IDUsuario INT,
    @ID INT,
    @Estado NVARCHAR(20)
AS
BEGIN
    UPDATE Postulacion
    SET Estado = @Estado
    WHERE ID = @ID AND IDUsuario = @IDUsuario

    SELECT @@ROWCOUNT AS Filas
END
GO

CREATE OR ALTER PROCEDURE EliminarPostulacion
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    DELETE FROM Postulacion
    WHERE ID = @ID AND IDUsuario = @IDUsuario

    SELECT @@ROWCOUNT AS Filas
END
GO

CREATE OR ALTER PROCEDURE ContarPostulacionesPorEstado
    @IDUsuario INT
AS
BEGIN
    SELECT Estado, COUNT(*) AS Cantidad
    FROM Postulacion
    WHERE IDUsuario = @IDUsuario
    GROUP BY Estado
END
GO

CREATE OR ALTER PROCEDURE ObtenerPostulantes
    @IDOferta INT
AS
BEGIN
    SELECT po.ID AS IDPostulacion, u.ID AS IDUsuario, CAST(po.Fecha AS DATETIME2) AS Fecha, u.Nombre, u.Apellido, u.Email,
           pe.Telefono, pe.Foto, pr.Nombre AS Provincia, pe.Estado_Busqueda, pf.Puesto_Buscado, cv.Nombre_Archivo
    FROM Postulacion po
    JOIN Usuario u ON u.ID = po.IDUsuario
    LEFT JOIN Perfil pe ON pe.IDUsuario = u.ID
    LEFT JOIN Provincia pr ON pr.ID = pe.IDProvincia
    LEFT JOIN Preferencia pf ON pf.IDUsuario = u.ID
    LEFT JOIN CV cv ON cv.IDUsuario = u.ID
    WHERE po.IDOfertaLaboral = @IDOferta
    ORDER BY po.Fecha DESC, po.ID DESC
END
GO

CREATE OR ALTER PROCEDURE ObtenerPostulacionDePublicador
    @ID INT,
    @IDPublicador INT
AS
BEGIN
    SELECT po.IDUsuario, o.ID AS IDOferta
    FROM Postulacion po
    JOIN OfertaLaboral o ON o.ID = po.IDOfertaLaboral
    WHERE po.ID = @ID AND o.IDUsuario_Publicador = @IDPublicador
END
GO

CREATE OR ALTER PROCEDURE EstadisticasPostulacionesEmpresa
    @IDEmpresa INT,
    @OfertasSobrePromedio INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @OfertasSobrePromedio = 0;

    IF @IDEmpresa IS NULL OR NOT EXISTS (SELECT 1 FROM Empresa WHERE ID = @IDEmpresa)
    BEGIN
        SELECT N'La empresa indicada no existe.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Empresa NVARCHAR(100) = (SELECT Nombre FROM Empresa WHERE ID = @IDEmpresa);

    IF NOT EXISTS (SELECT 1 FROM OfertaLaboral WHERE IDEmpresa = @IDEmpresa AND Estado_Publicacion = N'Aprobada')
    BEGIN
        SELECT N'La empresa ' + @Empresa + N' no tiene ofertas publicadas.' AS Mensaje;
        RETURN 2;
    END

    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @Ofertas TABLE (
        IDOferta INT PRIMARY KEY,
        Titulo NVARCHAR(150),
        Fecha_Publicacion DATE,
        Fecha_Cierre DATE,
        Postulaciones INT
    );

    INSERT INTO @Ofertas (IDOferta, Titulo, Fecha_Publicacion, Fecha_Cierre, Postulaciones)
    SELECT o.ID, o.Titulo, o.Fecha_Publicacion, o.Fecha_Cierre,
           (SELECT COUNT(*) FROM Postulacion AS p WHERE p.IDOfertaLaboral = o.ID)
    FROM OfertaLaboral AS o
    WHERE o.IDEmpresa = @IDEmpresa AND o.Estado_Publicacion = N'Aprobada';

    DECLARE @Promedio DECIMAL(10, 2) = (SELECT AVG(CAST(Postulaciones AS DECIMAL(10, 2))) FROM @Ofertas);

    SELECT @OfertasSobrePromedio = COUNT(*) FROM @Ofertas WHERE Postulaciones > @Promedio;

    SELECT
        IDOferta,
        Titulo,
        Fecha_Publicacion AS Publicada,
        CASE WHEN Fecha_Cierre IS NOT NULL AND Fecha_Cierre < @Hoy THEN N'Cerrada' ELSE N'Vigente' END AS Vigencia,
        Postulaciones,
        @Promedio AS PromedioEmpresa,
        CASE WHEN Postulaciones > @Promedio THEN N'Sí' ELSE N'No' END AS SuperaPromedio
    FROM @Ofertas
    ORDER BY Postulaciones DESC, Fecha_Publicacion DESC;

    SELECT
        @Empresa AS Empresa,
        COUNT(*) AS OfertasPublicadas,
        SUM(Postulaciones) AS PostulacionesTotales,
        @Promedio AS PromedioPorOferta,
        @OfertasSobrePromedio AS OfertasSobrePromedio
    FROM @Ofertas;

    RETURN 0;
END
GO

CREATE OR ALTER PROCEDURE RankingCandidatosPorHabilidades
    @IDOfertaLaboral INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IDOfertaLaboral IS NULL OR NOT EXISTS (SELECT 1 FROM OfertaLaboral WHERE ID = @IDOfertaLaboral)
    BEGIN
        SELECT N'La oferta indicada no existe.' AS Mensaje;
        RETURN 1;
    END

    IF NOT EXISTS (SELECT 1 FROM OfertaPuesto WHERE IDOfertaLaboral = @IDOfertaLaboral)
    BEGIN
        SELECT N'La oferta no tiene puestos asociados, así que no se puede comparar con las habilidades de los candidatos.' AS Mensaje;
        RETURN 2;
    END

    DECLARE @Sectores TABLE (IDSector INT PRIMARY KEY, Nombre NVARCHAR(60));

    INSERT INTO @Sectores (IDSector, Nombre)
    SELECT DISTINCT s.ID, s.Nombre
    FROM OfertaPuesto AS op
    JOIN Puesto AS pu ON pu.ID = op.IDPuesto
    JOIN Sector AS s ON s.ID = pu.IDSector
    WHERE op.IDOfertaLaboral = @IDOfertaLaboral;

    IF NOT EXISTS (SELECT 1 FROM @Sectores)
    BEGIN
        SELECT N'Los puestos de la oferta no tienen un sector asignado, así que no se puede comparar con las habilidades de los candidatos.' AS Mensaje;
        RETURN 2;
    END

    IF NOT EXISTS (SELECT 1 FROM Postulacion WHERE IDOfertaLaboral = @IDOfertaLaboral)
    BEGIN
        SELECT N'La oferta todavía no recibió postulaciones.' AS Mensaje;
        RETURN 2;
    END

    DECLARE @Titulo NVARCHAR(150) = (SELECT Titulo FROM OfertaLaboral WHERE ID = @IDOfertaLaboral);
    DECLARE @ListaSectores NVARCHAR(1000) = (SELECT STRING_AGG(Nombre, N', ') WITHIN GROUP (ORDER BY Nombre) FROM @Sectores);
    DECLARE @Candidatos TABLE (
        IDUsuario INT PRIMARY KEY,
        Candidato NVARCHAR(101),
        FechaPostulacion DATE,
        EstadoPostulacion NVARCHAR(20),
        HabilidadesEnSector INT,
        HabilidadesTotales INT,
        Coincidencias NVARCHAR(2000)
    );

    INSERT INTO @Candidatos
    SELECT
        u.ID,
        u.Nombre + N' ' + u.Apellido,
        p.Fecha,
        p.Estado,
        enSector.Cantidad,
        total.Cantidad,
        enSector.Lista
    FROM Postulacion AS p
    JOIN Usuario AS u ON u.ID = p.IDUsuario
    CROSS APPLY (
        SELECT COUNT(*) AS Cantidad
        FROM UsuarioHabilidad AS uh
        WHERE uh.IDUsuario = u.ID
    ) AS total
    CROSS APPLY (
        SELECT COUNT(*) AS Cantidad, STRING_AGG(h.Nombre, N', ') WITHIN GROUP (ORDER BY h.Nombre) AS Lista
        FROM UsuarioHabilidad AS uh
        JOIN Habilidad AS h ON h.ID = uh.IDHabilidad
        JOIN @Sectores AS s ON s.IDSector = h.IDSector
        WHERE uh.IDUsuario = u.ID
    ) AS enSector
    WHERE p.IDOfertaLaboral = @IDOfertaLaboral;

    SELECT
        RANK() OVER (ORDER BY HabilidadesEnSector DESC) AS Posicion,
        Candidato,
        HabilidadesEnSector,
        HabilidadesTotales,
        CASE WHEN HabilidadesTotales = 0 THEN CAST(0 AS DECIMAL(5, 2))
             ELSE CAST(HabilidadesEnSector * 100.0 / HabilidadesTotales AS DECIMAL(5, 2)) END AS PorcentajeEnSector,
        ISNULL(Coincidencias, N'-') AS HabilidadesCoincidentes,
        EstadoPostulacion,
        FechaPostulacion
    FROM @Candidatos
    ORDER BY Posicion, FechaPostulacion, Candidato;

    SELECT
        @Titulo AS Oferta,
        @ListaSectores AS SectoresDeLosPuestos,
        (SELECT COUNT(*) FROM @Candidatos) AS Candidatos,
        (SELECT COUNT(*) FROM @Candidatos WHERE HabilidadesEnSector > 0) AS ConAlgunaCoincidencia,
        N'La coincidencia por sector es una aproximación: no certifica que la persona sea apta para el puesto.' AS Aclaracion;

    RETURN 0;
END
GO

CREATE OR ALTER PROCEDURE CompararSeleccionEmpresas
    @MinimoPostulaciones INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @MinimoPostulaciones IS NULL OR @MinimoPostulaciones < 1
    BEGIN
        SELECT N'El mínimo de postulaciones tiene que ser un número mayor a 0.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Empresas TABLE (
        IDEmpresa INT PRIMARY KEY,
        Empresa NVARCHAR(100),
        Postulaciones INT,
        Pase INT
    );

    INSERT INTO @Empresas (IDEmpresa, Empresa, Postulaciones, Pase)
    SELECT e.ID, e.Nombre, COUNT(p.ID), SUM(CASE WHEN p.Estado = N'Pasé' THEN 1 ELSE 0 END)
    FROM Empresa AS e
    JOIN OfertaLaboral AS o ON o.IDEmpresa = e.ID
    JOIN Postulacion AS p ON p.IDOfertaLaboral = o.ID
    GROUP BY e.ID, e.Nombre
    HAVING COUNT(p.ID) >= @MinimoPostulaciones;

    IF NOT EXISTS (SELECT 1 FROM @Empresas)
    BEGIN
        SELECT N'Ninguna empresa llega a ' + CAST(@MinimoPostulaciones AS NVARCHAR(10)) + N' postulaciones.' AS Mensaje;
        RETURN 2;
    END

    DECLARE @PromedioGeneral DECIMAL(5, 2) = (SELECT CAST(SUM(Pase) * 100.0 / SUM(Postulaciones) AS DECIMAL(5, 2)) FROM @Empresas);

    SELECT
        RANK() OVER (ORDER BY x.Porcentaje DESC) AS Posicion,
        x.Empresa,
        x.Postulaciones AS PostulacionesTotales,
        x.Pase AS PostulacionesPase,
        x.Porcentaje AS PorcentajePase,
        @PromedioGeneral AS PromedioGeneral,
        CASE WHEN x.Porcentaje > @PromedioGeneral THEN N'Sí' ELSE N'No' END AS SuperaPromedio
    FROM (
        SELECT Empresa, Postulaciones, Pase, CAST(Pase * 100.0 / Postulaciones AS DECIMAL(5, 2)) AS Porcentaje
        FROM @Empresas
    ) AS x
    ORDER BY x.Porcentaje DESC, x.Postulaciones DESC, x.Empresa;

    SELECT
        COUNT(*) AS EmpresasAnalizadas,
        SUM(Postulaciones) AS PostulacionesTotales,
        SUM(Pase) AS PostulacionesPase,
        @PromedioGeneral AS PromedioGeneral,
        N'Se mide el avance en la selección (postulaciones con estado «Pasé»), no contrataciones confirmadas.' AS Aclaracion
    FROM @Empresas;

    RETURN 0;
END
GO

CREATE OR ALTER PROCEDURE OfertasFavoritasSinPostulacion
    @MinimoFavoritos INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @MinimoFavoritos IS NULL OR @MinimoFavoritos < 1
    BEGIN
        SELECT N'El mínimo de favoritos tiene que ser un número mayor a 0.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Resultado TABLE (
        TipoOferta NVARCHAR(10),
        IDOferta INT,
        UsuariosQueGuardaron INT,
        SinPostularse INT,
        PRIMARY KEY (TipoOferta, IDOferta)
    );

    WITH Guardados AS (
        SELECT DISTINCT
            f.IDUsuario,
            CASE WHEN fo.IDOfertaLaboral IS NOT NULL THEN N'Workly' ELSE N'Externa' END AS TipoOferta,
            COALESCE(fo.IDOfertaLaboral, fo.IDOfertaExterna) AS IDOferta
        FROM Favorito AS f
        JOIN FavoritoOferta AS fo ON fo.IDFavorito = f.ID_favorito
    ),
    ConPostulacion AS (
        SELECT
            g.TipoOferta,
            g.IDOferta,
            CASE WHEN EXISTS (
                SELECT 1 FROM Postulacion AS p
                WHERE p.IDUsuario = g.IDUsuario
                  AND ((g.TipoOferta = N'Workly' AND p.IDOfertaLaboral = g.IDOferta)
                    OR (g.TipoOferta = N'Externa' AND p.IDOfertaExterna = g.IDOferta))
            ) THEN 1 ELSE 0 END AS SePostulo
        FROM Guardados AS g
    )
    INSERT INTO @Resultado (TipoOferta, IDOferta, UsuariosQueGuardaron, SinPostularse)
    SELECT TipoOferta, IDOferta, COUNT(*), SUM(1 - SePostulo)
    FROM ConPostulacion
    GROUP BY TipoOferta, IDOferta
    HAVING COUNT(*) >= @MinimoFavoritos;

    IF NOT EXISTS (SELECT 1 FROM @Resultado)
    BEGIN
        SELECT N'No hay ofertas guardadas por al menos ' + CAST(@MinimoFavoritos AS NVARCHAR(10)) + N' personas.' AS Mensaje;
        RETURN 2;
    END

    SELECT
        r.TipoOferta,
        r.IDOferta,
        COALESCE(o.Titulo, x.Titulo) AS Oferta,
        COALESCE(e.Nombre, x.Empresa, N'-') AS Empresa,
        r.UsuariosQueGuardaron,
        r.SinPostularse,
        CAST(r.SinPostularse * 100.0 / r.UsuariosQueGuardaron AS DECIMAL(5, 2)) AS PorcentajeSinPostularse
    FROM @Resultado AS r
    LEFT JOIN OfertaLaboral AS o ON r.TipoOferta = N'Workly' AND o.ID = r.IDOferta
    LEFT JOIN Empresa AS e ON e.ID = o.IDEmpresa
    LEFT JOIN OfertaExterna AS x ON r.TipoOferta = N'Externa' AND x.ID = r.IDOferta
    ORDER BY r.UsuariosQueGuardaron DESC, PorcentajeSinPostularse DESC, Oferta;

    RETURN 0;
END
GO

CREATE OR ALTER PROCEDURE DiagnosticoOferta
    @IDOfertaLaboral INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IDOfertaLaboral IS NULL OR NOT EXISTS (SELECT 1 FROM OfertaLaboral WHERE ID = @IDOfertaLaboral)
    BEGIN
        SELECT N'La oferta indicada no existe.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @Titulo NVARCHAR(150), @Estado NVARCHAR(20), @Publicacion DATE, @Cierre DATE, @Vacantes INT;
    DECLARE @Vigencia NVARCHAR(20), @DiasPublicada INT, @DiasRestantes INT;
    DECLARE @Postulaciones INT, @Pase INT, @PorVacante DECIMAL(10, 2), @TasaPase DECIMAL(5, 2);
    DECLARE @Nivel NVARCHAR(30), @Diagnostico NVARCHAR(400);

    SELECT @Titulo = Titulo, @Estado = Estado_Publicacion, @Publicacion = Fecha_Publicacion, @Cierre = Fecha_Cierre, @Vacantes = Cantidad_Puestos
    FROM OfertaLaboral
    WHERE ID = @IDOfertaLaboral;

    SET @Vigencia = CASE
        WHEN @Estado = N'Pendiente' THEN N'En revisión'
        WHEN @Estado = N'Rechazada' THEN N'Rechazada'
        WHEN @Cierre IS NOT NULL AND @Cierre < @Hoy THEN N'Cerrada'
        ELSE N'Vigente' END;
    SET @DiasPublicada = DATEDIFF(DAY, @Publicacion, @Hoy);
    SET @DiasRestantes = CASE WHEN @Vigencia = N'Vigente' AND @Cierre IS NOT NULL THEN DATEDIFF(DAY, @Hoy, @Cierre) END;

    SELECT @Postulaciones = COUNT(*), @Pase = ISNULL(SUM(CASE WHEN Estado = N'Pasé' THEN 1 ELSE 0 END), 0)
    FROM Postulacion
    WHERE IDOfertaLaboral = @IDOfertaLaboral;

    IF @Postulaciones = 0
    BEGIN
        SELECT
            @Titulo AS Oferta,
            @Vigencia AS Vigencia,
            @DiasPublicada AS DiasPublicada,
            @DiasRestantes AS DiasRestantes,
            0 AS Postulaciones,
            CASE @Vigencia
                WHEN N'En revisión' THEN N'La oferta todavía no está publicada (la está revisando el equipo de Workly), por eso no tiene postulaciones.'
                WHEN N'Rechazada' THEN N'La oferta fue rechazada en la revisión y nunca se publicó, por eso no tiene postulaciones.'
                WHEN N'Cerrada' THEN N'La oferta cerró sin recibir postulaciones.'
                ELSE CASE WHEN @DiasPublicada < 7
                    THEN N'La oferta todavía no recibió postulaciones, pero lleva menos de una semana publicada.'
                    ELSE N'La oferta no recibió postulaciones en ' + CAST(@DiasPublicada AS NVARCHAR(10)) + N' días: conviene revisar el título, la descripción o el salario.' END
            END AS Mensaje;
        RETURN 2;
    END

    SET @PorVacante = CAST(@Postulaciones * 1.0 / @Vacantes AS DECIMAL(10, 2));
    SET @TasaPase = CAST(@Pase * 100.0 / @Postulaciones AS DECIMAL(5, 2));

    IF @PorVacante >= 5 AND @TasaPase >= 20
    BEGIN
        SET @Nivel = N'Muy bueno';
        SET @Diagnostico = N'Muchas postulaciones por vacante y buen avance en la selección.';
    END
    ELSE IF @PorVacante >= 5
    BEGIN
        SET @Nivel = N'Convocatoria alta';
        SET @Diagnostico = N'Llegan muchas postulaciones, pero pocas avanzan: conviene aclarar los requisitos en la descripción.';
    END
    ELSE IF @TasaPase >= 20
    BEGIN
        SET @Nivel = N'Convocatoria baja';
        SET @Diagnostico = N'Llegan pocas postulaciones por vacante, pero las que llegan avanzan: conviene difundir más la oferta.';
    END
    ELSE
    BEGIN
        SET @Nivel = N'Bajo';
        SET @Diagnostico = N'Pocas postulaciones por vacante y poco avance: conviene revisar el título, los requisitos y las condiciones.';
    END

    IF @Vigencia = N'Vigente' AND @DiasPublicada < 7
        SET @Diagnostico = @Diagnostico + N' Lleva menos de una semana publicada, así que el resultado todavía puede cambiar.';
    ELSE IF @Vigencia = N'Cerrada'
        SET @Diagnostico = @Diagnostico + N' La oferta ya cerró: el resultado es final.';

    SELECT
        @Titulo AS Oferta,
        @Vigencia AS Vigencia,
        @DiasPublicada AS DiasPublicada,
        @DiasRestantes AS DiasRestantes,
        @Vacantes AS Vacantes,
        @Postulaciones AS Postulaciones,
        @Pase AS PostulacionesPase,
        @PorVacante AS PostulacionesPorVacante,
        @TasaPase AS PorcentajePase,
        @Nivel AS Nivel,
        @Diagnostico AS Diagnostico;

    RETURN 0;
END
GO

CREATE OR ALTER PROCEDURE RecomendarOfertasParaUsuario
    @IDUsuario INT,
    @Cantidad INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @Cantidad IS NULL OR @Cantidad NOT BETWEEN 1 AND 50
    BEGIN
        SELECT N'La cantidad de recomendaciones tiene que estar entre 1 y 50.' AS Mensaje;
        RETURN 1;
    END

    IF @IDUsuario IS NULL OR NOT EXISTS (SELECT 1 FROM Usuario WHERE ID = @IDUsuario)
    BEGIN
        SELECT N'El usuario indicado no existe.' AS Mensaje;
        RETURN 1;
    END

    IF EXISTS (SELECT 1 FROM Usuario WHERE ID = @IDUsuario AND Tipo <> N'Persona')
    BEGIN
        SELECT N'Las recomendaciones son para cuentas de persona, no de empresa.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @TienePreferencia BIT = 0, @IDProvincia INT, @Modalidades NVARCHAR(60), @PuestoBuscado NVARCHAR(100), @Patron NVARCHAR(320);
    DECLARE @HabilidadesConSector INT;

    IF EXISTS (SELECT 1 FROM Preferencia WHERE IDUsuario = @IDUsuario)
    BEGIN
        SET @TienePreferencia = 1;
        SELECT @IDProvincia = IDProvincia, @Modalidades = Modalidades, @PuestoBuscado = NULLIF(LTRIM(RTRIM(Puesto_Buscado)), N'')
        FROM Preferencia
        WHERE IDUsuario = @IDUsuario;
    END

    SELECT @HabilidadesConSector = COUNT(*)
    FROM UsuarioHabilidad AS uh
    JOIN Habilidad AS h ON h.ID = uh.IDHabilidad
    WHERE uh.IDUsuario = @IDUsuario AND h.IDSector IS NOT NULL;

    IF @HabilidadesConSector = 0 AND @PuestoBuscado IS NULL AND @Modalidades IS NULL AND @IDProvincia IS NULL
    BEGIN
        SELECT N'Para recomendarte ofertas, cargá tus habilidades o qué buscás en tu perfil.' AS Mensaje;
        RETURN 2;
    END

    IF @PuestoBuscado IS NOT NULL
        SET @Patron = N'%' + REPLACE(REPLACE(REPLACE(@PuestoBuscado, N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]') + N'%';

    DECLARE @Candidatas TABLE (
        IDOferta INT PRIMARY KEY,
        Titulo NVARCHAR(150),
        Empresa NVARCHAR(100),
        Provincia NVARCHAR(80),
        Modalidad NVARCHAR(20),
        Publicada DATE,
        Coincidencias INT,
        PuntosHabilidades INT,
        PuntosUbicacion INT,
        PuntosModalidad INT,
        PuntosPuesto INT
    );

    INSERT INTO @Candidatas
    SELECT
        o.ID,
        o.Titulo,
        e.Nombre,
        pr.Nombre,
        o.Modalidad,
        o.Fecha_Publicacion,
        hab.Coincidencias,
        CASE WHEN hab.Coincidencias > 5 THEN 5 ELSE hab.Coincidencias END * 10,
        CASE
            WHEN o.Modalidad = N'Remoto' THEN 20
            WHEN @IDProvincia IS NOT NULL AND o.IDProvincia = @IDProvincia THEN 20
            WHEN @TienePreferencia = 1 AND @IDProvincia IS NULL THEN 10
            ELSE 0 END,
        CASE WHEN @Modalidades IS NOT NULL AND CHARINDEX(N',' + o.Modalidad + N',', N',' + @Modalidades + N',') > 0 THEN 15 ELSE 0 END,
        CASE WHEN @Patron IS NOT NULL AND (o.Titulo LIKE @Patron OR ISNULL(pu.Puestos, N'') LIKE @Patron) THEN 15 ELSE 0 END
    FROM OfertaLaboral AS o
    JOIN Empresa AS e ON e.ID = o.IDEmpresa
    LEFT JOIN Provincia AS pr ON pr.ID = o.IDProvincia
    OUTER APPLY (
        SELECT COUNT(DISTINCT uh.IDHabilidad) AS Coincidencias
        FROM OfertaPuesto AS op
        JOIN Puesto AS p ON p.ID = op.IDPuesto
        JOIN Habilidad AS h ON h.IDSector = p.IDSector
        JOIN UsuarioHabilidad AS uh ON uh.IDHabilidad = h.ID AND uh.IDUsuario = @IDUsuario
        WHERE op.IDOfertaLaboral = o.ID
    ) AS hab
    OUTER APPLY (
        SELECT STRING_AGG(p.Nombre, N', ') AS Puestos
        FROM OfertaPuesto AS op
        JOIN Puesto AS p ON p.ID = op.IDPuesto
        WHERE op.IDOfertaLaboral = o.ID
    ) AS pu
    WHERE o.Estado_Publicacion = N'Aprobada'
      AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= @Hoy)
      AND ISNULL(o.IDUsuario_Publicador, 0) <> @IDUsuario
      AND NOT EXISTS (SELECT 1 FROM Postulacion AS p WHERE p.IDUsuario = @IDUsuario AND p.IDOfertaLaboral = o.ID);

    IF NOT EXISTS (SELECT 1 FROM @Candidatas)
    BEGIN
        SELECT N'No hay ofertas vigentes en Workly a las que todavía no te hayas postulado.' AS Mensaje;
        RETURN 2;
    END

    IF NOT EXISTS (SELECT 1 FROM @Candidatas WHERE PuntosHabilidades + PuntosUbicacion + PuntosModalidad + PuntosPuesto > 0)
    BEGIN
        SELECT N'Hay ofertas vigentes, pero ninguna coincide todavía con tu perfil.' AS Mensaje;
        RETURN 2;
    END

    SELECT TOP (@Cantidad)
        IDOferta,
        Titulo,
        Empresa,
        ISNULL(Provincia, N'Todo el país') AS Provincia,
        Modalidad,
        PuntosHabilidades + PuntosUbicacion + PuntosModalidad + PuntosPuesto AS Puntaje,
        CONCAT_WS(N' · ',
            CASE WHEN Coincidencias = 1 THEN N'1 habilidad del sector' WHEN Coincidencias > 1 THEN CAST(Coincidencias AS NVARCHAR(10)) + N' habilidades del sector' END,
            CASE WHEN PuntosUbicacion = 20 AND Modalidad = N'Remoto' THEN N'remoto' WHEN PuntosUbicacion = 20 THEN N'en tu provincia' WHEN PuntosUbicacion = 10 THEN N'buscás en todo el país' END,
            CASE WHEN PuntosModalidad > 0 THEN N'modalidad que buscás' END,
            CASE WHEN PuntosPuesto > 0 THEN N'coincide con el puesto que buscás' END) AS Motivos
    FROM @Candidatas
    WHERE PuntosHabilidades + PuntosUbicacion + PuntosModalidad + PuntosPuesto > 0
    ORDER BY Puntaje DESC, Publicada DESC, IDOferta DESC;

    RETURN 0;
END
GO
