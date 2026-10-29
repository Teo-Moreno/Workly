SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE master;
GO

IF DB_ID(N'Workly') IS NULL
    CREATE DATABASE Workly;
GO

USE Workly;
GO

IF OBJECT_ID(N'dbo.Pais', N'U') IS NULL
CREATE TABLE dbo.Pais
(
    ID              INT IDENTITY(1, 1) NOT NULL,
    Nombre          NVARCHAR(60) NOT NULL,
    Codigo_ISO      CHAR(2)      NOT NULL,
    Codigo_Telefono NVARCHAR(5)  NOT NULL,
    CONSTRAINT PK_Pais PRIMARY KEY (ID),
    CONSTRAINT UQ_Pais_Nombre UNIQUE (Nombre)
);
GO

IF OBJECT_ID(N'dbo.Provincia', N'U') IS NULL
CREATE TABLE dbo.Provincia
(
    ID     INT IDENTITY(1, 1) NOT NULL,
    IDPais INT NOT NULL,
    Nombre NVARCHAR(80) NOT NULL,
    CONSTRAINT PK_Provincia PRIMARY KEY (ID),
    CONSTRAINT UQ_Provincia_Pais_Nombre UNIQUE (IDPais, Nombre),
    CONSTRAINT FK_Provincia_Pais FOREIGN KEY (IDPais) REFERENCES dbo.Pais (ID)
);
GO

IF OBJECT_ID(N'dbo.Usuario', N'U') IS NULL
CREATE TABLE dbo.Usuario
(
    ID             INT IDENTITY(1, 1) NOT NULL,
    Nombre         NVARCHAR(50)  NOT NULL,
    Apellido       NVARCHAR(50)  NOT NULL,
    Email          NVARCHAR(100) NOT NULL,
    [Contraseña]   NVARCHAR(200) NULL,
    Fecha_Registro DATE NOT NULL CONSTRAINT DF_Usuario_Fecha_Registro DEFAULT (CAST(GETDATE() AS DATE)),
    Tipo           NVARCHAR(10) NOT NULL CONSTRAINT DF_Usuario_Tipo DEFAULT (N'Persona'),
    Es_Moderador   BIT NOT NULL CONSTRAINT DF_Usuario_Es_Moderador DEFAULT (0),
    CONSTRAINT PK_Usuario PRIMARY KEY (ID),
    CONSTRAINT UQ_Usuario_Email UNIQUE (Email),
    CONSTRAINT CK_Usuario_Tipo CHECK (Tipo IN (N'Persona', N'Empresa'))
);
GO

IF OBJECT_ID(N'dbo.LoginExterno', N'U') IS NULL
CREATE TABLE dbo.LoginExterno
(
    ID         INT IDENTITY(1, 1) NOT NULL,
    IDUsuario  INT NOT NULL,
    Proveedor  NVARCHAR(20)  NOT NULL,
    ID_Externo NVARCHAR(200) NOT NULL,
    CONSTRAINT PK_LoginExterno PRIMARY KEY (ID),
    CONSTRAINT UQ_LoginExterno UNIQUE (Proveedor, ID_Externo),
    CONSTRAINT FK_LoginExterno_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE
);
GO

IF OBJECT_ID(N'dbo.Perfil', N'U') IS NULL
CREATE TABLE dbo.Perfil
(
    ID              INT IDENTITY(1, 1) NOT NULL,
    IDUsuario       INT NOT NULL,
    IDProvincia     INT NULL,
    Foto            NVARCHAR(260) NULL,
    Descripcion     NVARCHAR(500) NULL,
    Telefono        NVARCHAR(30)  NULL,
    Estado_Busqueda NVARCHAR(30)  NULL,
    CONSTRAINT PK_Perfil PRIMARY KEY (ID),
    CONSTRAINT UQ_Perfil_IDUsuario UNIQUE (IDUsuario),
    CONSTRAINT FK_Perfil_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_Perfil_Provincia FOREIGN KEY (IDProvincia) REFERENCES dbo.Provincia (ID),
    CONSTRAINT CK_Perfil_Estado_Busqueda CHECK (Estado_Busqueda IN (N'Buscando activamente', N'Abierto a propuestas', N'No estoy buscando'))
);
GO

IF OBJECT_ID(N'dbo.CV', N'U') IS NULL
CREATE TABLE dbo.CV
(
    ID                  INT IDENTITY(1, 1) NOT NULL,
    IDUsuario           INT NOT NULL,
    Nombre_Archivo      NVARCHAR(260) NULL,
    Sitio_Web           NVARCHAR(200) NULL,
    Fecha_Actualizacion DATE NOT NULL CONSTRAINT DF_CV_Fecha_Actualizacion DEFAULT (CAST(GETDATE() AS DATE)),
    CONSTRAINT PK_CV PRIMARY KEY (ID),
    CONSTRAINT UQ_CV_IDUsuario UNIQUE (IDUsuario),
    CONSTRAINT FK_CV_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE
);
GO

IF OBJECT_ID(N'dbo.Preferencia', N'U') IS NULL
CREATE TABLE dbo.Preferencia
(
    ID             INT IDENTITY(1, 1) NOT NULL,
    IDUsuario      INT NOT NULL,
    Puesto_Buscado NVARCHAR(100) NULL,
    Niveles        NVARCHAR(100) NULL,
    Modalidades    NVARCHAR(60)  NULL,
    Jornada        NVARCHAR(20)  NULL,
    Contratacion   NVARCHAR(40)  NULL,
    IDProvincia    INT NULL,
    Salario_Minimo INT NULL,
    Salario_Maximo INT NULL,
    Disponibilidad NVARCHAR(20)  NULL,
    CONSTRAINT PK_Preferencia PRIMARY KEY (ID),
    CONSTRAINT UQ_Preferencia_IDUsuario UNIQUE (IDUsuario),
    CONSTRAINT FK_Preferencia_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_Preferencia_Provincia FOREIGN KEY (IDProvincia) REFERENCES dbo.Provincia (ID),
    CONSTRAINT CK_Preferencia_Salario CHECK ((Salario_Minimo IS NULL OR Salario_Minimo >= 0)
                                         AND (Salario_Maximo IS NULL OR Salario_Minimo IS NULL OR Salario_Maximo >= Salario_Minimo))
);
GO

IF OBJECT_ID(N'dbo.Sector', N'U') IS NULL
CREATE TABLE dbo.Sector
(
    ID     INT IDENTITY(1, 1) NOT NULL,
    Nombre NVARCHAR(60) NOT NULL,
    Orden  INT NOT NULL CONSTRAINT DF_Sector_Orden DEFAULT (0),
    CONSTRAINT PK_Sector PRIMARY KEY (ID),
    CONSTRAINT UQ_Sector_Nombre UNIQUE (Nombre)
);
GO

IF OBJECT_ID(N'dbo.Habilidad', N'U') IS NULL
CREATE TABLE dbo.Habilidad
(
    ID       INT IDENTITY(1, 1) NOT NULL,
    Nombre   NVARCHAR(60) NOT NULL,
    IDSector INT NULL,
    CONSTRAINT PK_Habilidad PRIMARY KEY (ID),
    CONSTRAINT UQ_Habilidad_Nombre UNIQUE (Nombre),
    CONSTRAINT FK_Habilidad_Sector FOREIGN KEY (IDSector) REFERENCES dbo.Sector (ID)
);
GO

IF OBJECT_ID(N'dbo.UsuarioHabilidad', N'U') IS NULL
CREATE TABLE dbo.UsuarioHabilidad
(
    ID          INT IDENTITY(1, 1) NOT NULL,
    IDUsuario   INT NOT NULL,
    IDHabilidad INT NOT NULL,
    CONSTRAINT PK_UsuarioHabilidad PRIMARY KEY (ID),
    CONSTRAINT UQ_UsuarioHabilidad UNIQUE (IDUsuario, IDHabilidad),
    CONSTRAINT FK_UsuarioHabilidad_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_UsuarioHabilidad_Habilidad FOREIGN KEY (IDHabilidad) REFERENCES dbo.Habilidad (ID)
);
GO

IF OBJECT_ID(N'dbo.Idioma', N'U') IS NULL
CREATE TABLE dbo.Idioma
(
    ID     INT IDENTITY(1, 1) NOT NULL,
    Nombre NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Idioma PRIMARY KEY (ID),
    CONSTRAINT UQ_Idioma_Nombre UNIQUE (Nombre)
);
GO

IF OBJECT_ID(N'dbo.UsuarioIdioma', N'U') IS NULL
CREATE TABLE dbo.UsuarioIdioma
(
    ID        INT IDENTITY(1, 1) NOT NULL,
    IDUsuario INT NOT NULL,
    IDIdioma  INT NOT NULL,
    Nivel     NVARCHAR(20) NOT NULL,
    CONSTRAINT PK_UsuarioIdioma PRIMARY KEY (ID),
    CONSTRAINT UQ_UsuarioIdioma UNIQUE (IDUsuario, IDIdioma),
    CONSTRAINT FK_UsuarioIdioma_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_UsuarioIdioma_Idioma FOREIGN KEY (IDIdioma) REFERENCES dbo.Idioma (ID),
    CONSTRAINT CK_UsuarioIdioma_Nivel CHECK (Nivel IN (N'Básico', N'Intermedio', N'Avanzado', N'Nativo'))
);
GO

IF OBJECT_ID(N'dbo.Educacion', N'U') IS NULL
CREATE TABLE dbo.Educacion
(
    ID          INT IDENTITY(1, 1) NOT NULL,
    Institucion NVARCHAR(150) NOT NULL,
    Descripcion NVARCHAR(300) NULL,
    CONSTRAINT PK_Educacion PRIMARY KEY (ID),
    CONSTRAINT UQ_Educacion_Institucion UNIQUE (Institucion)
);
GO

IF OBJECT_ID(N'dbo.UsuarioEducacion', N'U') IS NULL
CREATE TABLE dbo.UsuarioEducacion
(
    ID           INT IDENTITY(1, 1) NOT NULL,
    IDUsuario    INT NOT NULL,
    IDEducacion  INT NOT NULL,
    Titulo       NVARCHAR(150) NOT NULL,
    Fecha_Inicio DATE NOT NULL,
    Fecha_Fin    DATE NULL,
    CONSTRAINT PK_UsuarioEducacion PRIMARY KEY (ID),
    CONSTRAINT FK_UsuarioEducacion_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_UsuarioEducacion_Educacion FOREIGN KEY (IDEducacion) REFERENCES dbo.Educacion (ID),
    CONSTRAINT CK_UsuarioEducacion_Fechas CHECK (Fecha_Fin IS NULL OR Fecha_Fin >= Fecha_Inicio)
);
GO

IF OBJECT_ID(N'dbo.Empresa', N'U') IS NULL
CREATE TABLE dbo.Empresa
(
    ID             INT IDENTITY(1, 1) NOT NULL,
    Nombre         NVARCHAR(100) NOT NULL,
    Descripcion    NVARCHAR(500) NULL,
    Logo           NVARCHAR(260) NULL,
    Ubicacion      NVARCHAR(100) NULL,
    Sitio_Web      NVARCHAR(200) NULL,
    IDUsuario      INT NULL,
    Razon_Social   NVARCHAR(150) NULL,
    CUIT           CHAR(11) NULL,
    Rubro          NVARCHAR(60) NULL,
    IDProvincia    INT NULL,
    Telefono       NVARCHAR(30) NULL,
    Fecha_Registro DATE NOT NULL CONSTRAINT DF_Empresa_Fecha_Registro DEFAULT (CAST(GETDATE() AS DATE)),
    CONSTRAINT PK_Empresa PRIMARY KEY (ID),
    CONSTRAINT UQ_Empresa_Nombre UNIQUE (Nombre),
    CONSTRAINT FK_Empresa_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE SET NULL,
    CONSTRAINT FK_Empresa_Provincia FOREIGN KEY (IDProvincia) REFERENCES dbo.Provincia (ID)
);
GO

IF OBJECT_ID(N'dbo.ExperienciaLaboral', N'U') IS NULL
CREATE TABLE dbo.ExperienciaLaboral
(
    ID                 INT IDENTITY(1, 1) NOT NULL,
    IDUsuario          INT NOT NULL,
    IDEmpresa          INT NOT NULL,
    Puesto             NVARCHAR(100) NOT NULL,
    Descripcion        NVARCHAR(500) NULL,
    Fecha_Inicio       DATE NOT NULL,
    Fecha_Finalizacion DATE NULL,
    CONSTRAINT PK_ExperienciaLaboral PRIMARY KEY (ID),
    CONSTRAINT FK_ExperienciaLaboral_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_ExperienciaLaboral_Empresa FOREIGN KEY (IDEmpresa) REFERENCES dbo.Empresa (ID),
    CONSTRAINT CK_ExperienciaLaboral_Fechas CHECK (Fecha_Finalizacion IS NULL OR Fecha_Finalizacion >= Fecha_Inicio)
);
GO

IF OBJECT_ID(N'dbo.OfertaLaboral', N'U') IS NULL
CREATE TABLE dbo.OfertaLaboral
(
    ID                   INT IDENTITY(1, 1) NOT NULL,
    IDEmpresa            INT NOT NULL,
    Titulo               NVARCHAR(150)  NOT NULL,
    Descripcion          NVARCHAR(2000) NULL,
    Ubicacion            NVARCHAR(100)  NULL,
    Modalidad            NVARCHAR(20)   NOT NULL,
    Tipo_Contrato        NVARCHAR(50)   NOT NULL,
    Salario              INT NULL,
    Cantidad_Puestos     INT NOT NULL CONSTRAINT DF_OfertaLaboral_Cantidad_Puestos DEFAULT (1),
    Fecha_Publicacion    DATE NOT NULL CONSTRAINT DF_OfertaLaboral_Fecha_Publicacion DEFAULT (CAST(GETDATE() AS DATE)),
    Fecha_Cierre         DATE NULL,
    IDUsuario_Publicador INT NULL,
    IDProvincia          INT NULL,
    Estado_Publicacion   NVARCHAR(20) NOT NULL CONSTRAINT DF_OfertaLaboral_Estado_Publicacion DEFAULT (N'Aprobada'),
    Motivo_Rechazo       NVARCHAR(500) NULL,
    Fecha_Revision       DATE NULL,
    CONSTRAINT PK_OfertaLaboral PRIMARY KEY (ID),
    CONSTRAINT FK_OfertaLaboral_Empresa FOREIGN KEY (IDEmpresa) REFERENCES dbo.Empresa (ID),
    CONSTRAINT FK_OfertaLaboral_Usuario FOREIGN KEY (IDUsuario_Publicador) REFERENCES dbo.Usuario (ID),
    CONSTRAINT FK_OfertaLaboral_Provincia FOREIGN KEY (IDProvincia) REFERENCES dbo.Provincia (ID),
    CONSTRAINT CK_OfertaLaboral_Modalidad CHECK (Modalidad IN (N'Remoto', N'Híbrido', N'Presencial')),
    CONSTRAINT CK_OfertaLaboral_Salario CHECK (Salario IS NULL OR Salario >= 0),
    CONSTRAINT CK_OfertaLaboral_Cantidad_Puestos CHECK (Cantidad_Puestos >= 1),
    CONSTRAINT CK_OfertaLaboral_Fechas CHECK (Fecha_Cierre IS NULL OR Fecha_Cierre >= Fecha_Publicacion),
    CONSTRAINT CK_OfertaLaboral_Estado_Publicacion CHECK (Estado_Publicacion IN (N'Pendiente', N'Aprobada', N'Rechazada'))
);
GO

IF OBJECT_ID(N'dbo.Puesto', N'U') IS NULL
CREATE TABLE dbo.Puesto
(
    ID          INT IDENTITY(1, 1) NOT NULL,
    Nombre      NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(300) NULL,
    CONSTRAINT PK_Puesto PRIMARY KEY (ID),
    CONSTRAINT UQ_Puesto_Nombre UNIQUE (Nombre)
);
GO

IF OBJECT_ID(N'dbo.OfertaPuesto', N'U') IS NULL
CREATE TABLE dbo.OfertaPuesto
(
    ID              INT IDENTITY(1, 1) NOT NULL,
    IDOfertaLaboral INT NOT NULL,
    IDPuesto        INT NOT NULL,
    CONSTRAINT PK_OfertaPuesto PRIMARY KEY (ID),
    CONSTRAINT UQ_OfertaPuesto UNIQUE (IDOfertaLaboral, IDPuesto),
    CONSTRAINT FK_OfertaPuesto_OfertaLaboral FOREIGN KEY (IDOfertaLaboral) REFERENCES dbo.OfertaLaboral (ID) ON DELETE CASCADE,
    CONSTRAINT FK_OfertaPuesto_Puesto FOREIGN KEY (IDPuesto) REFERENCES dbo.Puesto (ID)
);
GO

IF OBJECT_ID(N'dbo.OfertaExterna', N'U') IS NULL
CREATE TABLE dbo.OfertaExterna
(
    ID                INT IDENTITY(1, 1) NOT NULL,
    ID_Externo        NVARCHAR(200)  NOT NULL,
    Titulo            NVARCHAR(300)  NOT NULL,
    Empresa           NVARCHAR(200)  NULL,
    Logo              NVARCHAR(1000) NULL,
    Ubicacion         NVARCHAR(200)  NULL,
    Descripcion       NVARCHAR(MAX)  NULL,
    Es_Remoto         BIT NOT NULL CONSTRAINT DF_OfertaExterna_Es_Remoto DEFAULT (0),
    Tipo_Contrato     NVARCHAR(50)   NULL,
    Salario           NVARCHAR(100)  NULL,
    Link_Postulacion  NVARCHAR(2000) NULL,
    Publicador        NVARCHAR(100)  NULL,
    Fecha_Publicacion DATETIME2 NULL,
    Fecha_Consulta    DATETIME2 NOT NULL CONSTRAINT DF_OfertaExterna_Fecha_Consulta DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_OfertaExterna PRIMARY KEY (ID),
    CONSTRAINT UQ_OfertaExterna_ID_Externo UNIQUE (ID_Externo)
);
GO

IF OBJECT_ID(N'dbo.Favorito', N'U') IS NULL
CREATE TABLE dbo.Favorito
(
    ID_favorito    INT IDENTITY(1, 1) NOT NULL,
    IDUsuario      INT NOT NULL,
    fecha_guardado DATE NOT NULL CONSTRAINT DF_Favorito_fecha_guardado DEFAULT (CAST(GETDATE() AS DATE)),
    CONSTRAINT PK_Favorito PRIMARY KEY (ID_favorito),
    CONSTRAINT FK_Favorito_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE
);
GO

IF OBJECT_ID(N'dbo.FavoritoOferta', N'U') IS NULL
CREATE TABLE dbo.FavoritoOferta
(
    ID              INT IDENTITY(1, 1) NOT NULL,
    IDFavorito      INT NOT NULL,
    IDOfertaLaboral INT NULL,
    IDOfertaExterna INT NULL,
    CONSTRAINT PK_FavoritoOferta PRIMARY KEY (ID),
    CONSTRAINT UQ_FavoritoOferta_IDFavorito UNIQUE (IDFavorito),
    CONSTRAINT FK_FavoritoOferta_Favorito FOREIGN KEY (IDFavorito) REFERENCES dbo.Favorito (ID_favorito) ON DELETE CASCADE,
    CONSTRAINT FK_FavoritoOferta_OfertaLaboral FOREIGN KEY (IDOfertaLaboral) REFERENCES dbo.OfertaLaboral (ID),
    CONSTRAINT FK_FavoritoOferta_OfertaExterna FOREIGN KEY (IDOfertaExterna) REFERENCES dbo.OfertaExterna (ID),
    CONSTRAINT CK_FavoritoOferta_Oferta CHECK ((IDOfertaLaboral IS NULL AND IDOfertaExterna IS NOT NULL)
                                            OR (IDOfertaLaboral IS NOT NULL AND IDOfertaExterna IS NULL))
);
GO

IF OBJECT_ID(N'dbo.RecuperacionClave', N'U') IS NULL
CREATE TABLE dbo.RecuperacionClave
(
    ID          INT IDENTITY(1, 1) NOT NULL,
    IDUsuario   INT NOT NULL,
    Token_Hash  CHAR(64) NOT NULL,
    Fecha       DATETIME2(0) NOT NULL CONSTRAINT DF_RecuperacionClave_Fecha DEFAULT (SYSUTCDATETIME()),
    Vence       DATETIME2(0) NOT NULL,
    Usada       BIT NOT NULL CONSTRAINT DF_RecuperacionClave_Usada DEFAULT (0),
    CONSTRAINT PK_RecuperacionClave PRIMARY KEY (ID),
    CONSTRAINT UQ_RecuperacionClave_Token_Hash UNIQUE (Token_Hash),
    CONSTRAINT FK_RecuperacionClave_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE
);
GO

IF OBJECT_ID(N'dbo.Postulacion', N'U') IS NULL
CREATE TABLE dbo.Postulacion
(
    ID              INT IDENTITY(1, 1) NOT NULL,
    IDUsuario       INT NOT NULL,
    IDOfertaLaboral INT NULL,
    IDOfertaExterna INT NULL,
    Fecha           DATE NOT NULL CONSTRAINT DF_Postulacion_Fecha DEFAULT (CAST(GETDATE() AS DATE)),
    Estado          NVARCHAR(20) NOT NULL CONSTRAINT DF_Postulacion_Estado DEFAULT (N'Enviada'),
    CONSTRAINT PK_Postulacion PRIMARY KEY (ID),
    CONSTRAINT FK_Postulacion_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_Postulacion_OfertaLaboral FOREIGN KEY (IDOfertaLaboral) REFERENCES dbo.OfertaLaboral (ID),
    CONSTRAINT FK_Postulacion_OfertaExterna FOREIGN KEY (IDOfertaExterna) REFERENCES dbo.OfertaExterna (ID),
    CONSTRAINT CK_Postulacion_Estado CHECK (Estado IN (N'Enviada', N'En revisión', N'Pasé', N'No pasé')),
    CONSTRAINT CK_Postulacion_Oferta CHECK ((IDOfertaLaboral IS NULL AND IDOfertaExterna IS NOT NULL)
                                         OR (IDOfertaLaboral IS NOT NULL AND IDOfertaExterna IS NULL))
);
GO

IF COL_LENGTH(N'dbo.Habilidad', N'IDSector') IS NULL
    ALTER TABLE dbo.Habilidad ADD IDSector INT NULL CONSTRAINT FK_Habilidad_Sector REFERENCES dbo.Sector (ID);
GO

IF COL_LENGTH(N'dbo.Pais', N'Codigo_ISO') IS NULL
    ALTER TABLE dbo.Pais ADD Codigo_ISO CHAR(2) NOT NULL CONSTRAINT DF_Pais_Codigo_ISO DEFAULT ('ar');
GO

IF COL_LENGTH(N'dbo.Usuario', N'Tipo') IS NULL
    ALTER TABLE dbo.Usuario ADD Tipo NVARCHAR(10) NOT NULL CONSTRAINT DF_Usuario_Tipo DEFAULT (N'Persona')
        CONSTRAINT CK_Usuario_Tipo CHECK (Tipo IN (N'Persona', N'Empresa'));
IF COL_LENGTH(N'dbo.Usuario', N'Es_Moderador') IS NULL
    ALTER TABLE dbo.Usuario ADD Es_Moderador BIT NOT NULL CONSTRAINT DF_Usuario_Es_Moderador DEFAULT (0);
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Usuario') AND name = N'Contraseña' AND is_nullable = 0)
    ALTER TABLE dbo.Usuario ALTER COLUMN [Contraseña] NVARCHAR(200) NULL;
GO

IF COL_LENGTH(N'dbo.Perfil', N'IDProvincia') IS NULL
    ALTER TABLE dbo.Perfil ADD IDProvincia INT NULL CONSTRAINT FK_Perfil_Provincia FOREIGN KEY REFERENCES dbo.Provincia (ID);
IF COL_LENGTH(N'dbo.Perfil', N'Estado_Busqueda') IS NULL
    ALTER TABLE dbo.Perfil ADD Estado_Busqueda NVARCHAR(30) NULL
        CONSTRAINT CK_Perfil_Estado_Busqueda CHECK (Estado_Busqueda IN (N'Buscando activamente', N'Abierto a propuestas', N'No estoy buscando'));
GO

IF COL_LENGTH(N'dbo.Empresa', N'IDUsuario') IS NULL
    ALTER TABLE dbo.Empresa ADD
        IDUsuario      INT NULL CONSTRAINT FK_Empresa_Usuario FOREIGN KEY REFERENCES dbo.Usuario (ID) ON DELETE SET NULL,
        Razon_Social   NVARCHAR(150) NULL,
        CUIT           CHAR(11) NULL,
        Rubro          NVARCHAR(60) NULL,
        IDProvincia    INT NULL CONSTRAINT FK_Empresa_Provincia FOREIGN KEY REFERENCES dbo.Provincia (ID),
        Telefono       NVARCHAR(30) NULL,
        Fecha_Registro DATE NOT NULL CONSTRAINT DF_Empresa_Fecha_Registro DEFAULT (CAST(GETDATE() AS DATE));
GO

IF COL_LENGTH(N'dbo.OfertaLaboral', N'Cantidad_Puestos') IS NULL
    ALTER TABLE dbo.OfertaLaboral ADD Cantidad_Puestos INT NOT NULL
        CONSTRAINT DF_OfertaLaboral_Cantidad_Puestos DEFAULT (1)
        CONSTRAINT CK_OfertaLaboral_Cantidad_Puestos CHECK (Cantidad_Puestos >= 1);
IF COL_LENGTH(N'dbo.OfertaLaboral', N'Estado_Publicacion') IS NULL
    ALTER TABLE dbo.OfertaLaboral ADD
        IDUsuario_Publicador INT NULL CONSTRAINT FK_OfertaLaboral_Usuario FOREIGN KEY REFERENCES dbo.Usuario (ID),
        IDProvincia          INT NULL CONSTRAINT FK_OfertaLaboral_Provincia FOREIGN KEY REFERENCES dbo.Provincia (ID),
        Estado_Publicacion   NVARCHAR(20) NOT NULL CONSTRAINT DF_OfertaLaboral_Estado_Publicacion DEFAULT (N'Aprobada')
            CONSTRAINT CK_OfertaLaboral_Estado_Publicacion CHECK (Estado_Publicacion IN (N'Pendiente', N'Aprobada', N'Rechazada')),
        Motivo_Rechazo       NVARCHAR(500) NULL,
        Fecha_Revision       DATE NULL;
GO

IF COL_LENGTH(N'dbo.OfertaLaboral', N'Puesto') IS NOT NULL
BEGIN
    EXEC (N'
        INSERT INTO dbo.Puesto (Nombre)
        SELECT DISTINCT o.Puesto FROM dbo.OfertaLaboral AS o
        WHERE NOT EXISTS (SELECT 1 FROM dbo.Puesto AS p WHERE p.Nombre = o.Puesto);

        INSERT INTO dbo.OfertaPuesto (IDOfertaLaboral, IDPuesto)
        SELECT o.ID, p.ID FROM dbo.OfertaLaboral AS o JOIN dbo.Puesto AS p ON p.Nombre = o.Puesto
        WHERE NOT EXISTS (SELECT 1 FROM dbo.OfertaPuesto AS op WHERE op.IDOfertaLaboral = o.ID AND op.IDPuesto = p.ID);

        ALTER TABLE dbo.OfertaLaboral DROP COLUMN Puesto;');
END
GO

IF COL_LENGTH(N'dbo.FavoritoOferta', N'IDOfertaExterna') IS NULL
BEGIN
    IF OBJECT_ID(N'dbo.UQ_FavoritoOferta', N'UQ') IS NOT NULL
        ALTER TABLE dbo.FavoritoOferta DROP CONSTRAINT UQ_FavoritoOferta;
    ALTER TABLE dbo.FavoritoOferta ALTER COLUMN IDOfertaLaboral INT NULL;
    ALTER TABLE dbo.FavoritoOferta ADD IDOfertaExterna INT NULL
        CONSTRAINT FK_FavoritoOferta_OfertaExterna REFERENCES dbo.OfertaExterna (ID);
END
GO
IF OBJECT_ID(N'dbo.CK_FavoritoOferta_Oferta', N'C') IS NULL
    ALTER TABLE dbo.FavoritoOferta ADD CONSTRAINT CK_FavoritoOferta_Oferta
        CHECK ((IDOfertaLaboral IS NULL AND IDOfertaExterna IS NOT NULL) OR (IDOfertaLaboral IS NOT NULL AND IDOfertaExterna IS NULL));
IF OBJECT_ID(N'dbo.UQ_FavoritoOferta_IDFavorito', N'UQ') IS NULL
BEGIN
    EXEC(N'
        DECLARE @Pasar TABLE (ID INT, IDUsuario INT, Fecha DATE);
        INSERT INTO @Pasar
        SELECT fo.ID, f.IDUsuario, f.fecha_guardado
        FROM dbo.FavoritoOferta fo JOIN dbo.Favorito f ON f.ID_favorito = fo.IDFavorito
        WHERE fo.ID <> (SELECT MIN(x.ID) FROM dbo.FavoritoOferta x WHERE x.IDFavorito = fo.IDFavorito);
        DECLARE @ID INT, @IDUsuario INT, @Fecha DATE;
        WHILE EXISTS (SELECT 1 FROM @Pasar)
        BEGIN
            SELECT TOP (1) @ID = ID, @IDUsuario = IDUsuario, @Fecha = Fecha FROM @Pasar;
            INSERT INTO dbo.Favorito (IDUsuario, fecha_guardado) VALUES (@IDUsuario, @Fecha);
            UPDATE dbo.FavoritoOferta SET IDFavorito = SCOPE_IDENTITY() WHERE ID = @ID;
            DELETE FROM @Pasar WHERE ID = @ID;
        END
        DELETE f FROM dbo.Favorito f WHERE NOT EXISTS (SELECT 1 FROM dbo.FavoritoOferta fo WHERE fo.IDFavorito = f.ID_favorito);
        ALTER TABLE dbo.FavoritoOferta ADD CONSTRAINT UQ_FavoritoOferta_IDFavorito UNIQUE (IDFavorito);');
END
GO

IF COL_LENGTH(N'dbo.Postulacion', N'Estado') IS NULL
    ALTER TABLE dbo.Postulacion ADD Estado NVARCHAR(20) NOT NULL CONSTRAINT DF_Postulacion_Estado DEFAULT (N'Enviada');
GO
IF COL_LENGTH(N'dbo.Postulacion', N'IDOfertaExterna') IS NULL
    ALTER TABLE dbo.Postulacion ADD IDOfertaExterna INT NULL
        CONSTRAINT FK_Postulacion_OfertaExterna FOREIGN KEY REFERENCES dbo.OfertaExterna (ID);
GO
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Postulacion') AND name = N'IDOfertaLaboral' AND is_nullable = 0)
    ALTER TABLE dbo.Postulacion ALTER COLUMN IDOfertaLaboral INT NULL;
IF OBJECT_ID(N'dbo.UQ_Postulacion_Usuario_Oferta', N'UQ') IS NOT NULL
    ALTER TABLE dbo.Postulacion DROP CONSTRAINT UQ_Postulacion_Usuario_Oferta;
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Postulacion_Estado'
           AND definition NOT LIKE N'%Pasé%')
    ALTER TABLE dbo.Postulacion DROP CONSTRAINT CK_Postulacion_Estado;
GO
UPDATE dbo.Postulacion SET Estado = N'En revisión' WHERE Estado = N'Entrevista';
UPDATE dbo.Postulacion SET Estado = N'No pasé' WHERE Estado = N'Finalizada';
IF OBJECT_ID(N'dbo.CK_Postulacion_Estado', N'C') IS NULL
    ALTER TABLE dbo.Postulacion ADD CONSTRAINT CK_Postulacion_Estado CHECK (Estado IN (N'Enviada', N'En revisión', N'Pasé', N'No pasé'));
IF OBJECT_ID(N'dbo.CK_Postulacion_Oferta', N'C') IS NULL
    ALTER TABLE dbo.Postulacion ADD CONSTRAINT CK_Postulacion_Oferta CHECK ((IDOfertaLaboral IS NULL AND IDOfertaExterna IS NOT NULL)
                                                                        OR (IDOfertaLaboral IS NOT NULL AND IDOfertaExterna IS NULL));
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Postulacion_Usuario_OfertaLaboral')
    CREATE UNIQUE INDEX UX_Postulacion_Usuario_OfertaLaboral ON dbo.Postulacion (IDUsuario, IDOfertaLaboral) WHERE IDOfertaLaboral IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Postulacion_Usuario_OfertaExterna')
    CREATE UNIQUE INDEX UX_Postulacion_Usuario_OfertaExterna ON dbo.Postulacion (IDUsuario, IDOfertaExterna) WHERE IDOfertaExterna IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Empresa_CUIT')
    CREATE UNIQUE INDEX UX_Empresa_CUIT ON dbo.Empresa (CUIT) WHERE CUIT IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'UX_Empresa_IDUsuario')
    CREATE UNIQUE INDEX UX_Empresa_IDUsuario ON dbo.Empresa (IDUsuario) WHERE IDUsuario IS NOT NULL;
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UsuarioEducacion_IDUsuario')
    CREATE INDEX IX_UsuarioEducacion_IDUsuario ON dbo.UsuarioEducacion (IDUsuario);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ExperienciaLaboral_IDUsuario')
    CREATE INDEX IX_ExperienciaLaboral_IDUsuario ON dbo.ExperienciaLaboral (IDUsuario);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OfertaLaboral_IDEmpresa')
    CREATE INDEX IX_OfertaLaboral_IDEmpresa ON dbo.OfertaLaboral (IDEmpresa);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OfertaLaboral_Estado_Publicacion')
    CREATE INDEX IX_OfertaLaboral_Estado_Publicacion ON dbo.OfertaLaboral (Estado_Publicacion, Fecha_Publicacion);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OfertaLaboral_IDUsuario_Publicador')
    CREATE INDEX IX_OfertaLaboral_IDUsuario_Publicador ON dbo.OfertaLaboral (IDUsuario_Publicador);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Favorito_IDUsuario')
    CREATE INDEX IX_Favorito_IDUsuario ON dbo.Favorito (IDUsuario);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Habilidad_IDSector')
    CREATE INDEX IX_Habilidad_IDSector ON dbo.Habilidad (IDSector);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_RecuperacionClave_IDUsuario')
    CREATE INDEX IX_RecuperacionClave_IDUsuario ON dbo.RecuperacionClave (IDUsuario, Fecha);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_FavoritoOferta_IDOfertaLaboral')
    CREATE INDEX IX_FavoritoOferta_IDOfertaLaboral ON dbo.FavoritoOferta (IDOfertaLaboral);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_FavoritoOferta_IDOfertaExterna')
    CREATE INDEX IX_FavoritoOferta_IDOfertaExterna ON dbo.FavoritoOferta (IDOfertaExterna);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Postulacion_IDOfertaLaboral')
    CREATE INDEX IX_Postulacion_IDOfertaLaboral ON dbo.Postulacion (IDOfertaLaboral);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Perfil_IDProvincia')
    CREATE INDEX IX_Perfil_IDProvincia ON dbo.Perfil (IDProvincia);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OfertaPuesto_IDPuesto')
    CREATE INDEX IX_OfertaPuesto_IDPuesto ON dbo.OfertaPuesto (IDPuesto);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UsuarioHabilidad_IDUsuario')
    CREATE INDEX IX_UsuarioHabilidad_IDUsuario ON dbo.UsuarioHabilidad (IDUsuario);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UsuarioIdioma_IDUsuario')
    CREATE INDEX IX_UsuarioIdioma_IDUsuario ON dbo.UsuarioIdioma (IDUsuario);
GO

INSERT INTO dbo.Pais (Nombre, Codigo_ISO, Codigo_Telefono)
SELECT N'Argentina', 'ar', N'+54'
WHERE NOT EXISTS (SELECT 1 FROM dbo.Pais WHERE Nombre = N'Argentina');

INSERT INTO dbo.Provincia (IDPais, Nombre)
SELECT p.ID, x.Nombre
FROM (VALUES
    (N'Buenos Aires'), (N'Catamarca'), (N'Chaco'), (N'Chubut'), (N'Ciudad Autónoma de Buenos Aires'),
    (N'Córdoba'), (N'Corrientes'), (N'Entre Ríos'), (N'Formosa'), (N'Jujuy'), (N'La Pampa'),
    (N'La Rioja'), (N'Mendoza'), (N'Misiones'), (N'Neuquén'), (N'Río Negro'), (N'Salta'),
    (N'San Juan'), (N'San Luis'), (N'Santa Cruz'), (N'Santa Fe'), (N'Santiago del Estero'),
    (N'Tierra del Fuego'), (N'Tucumán')
) AS x (Nombre)
JOIN dbo.Pais AS p ON p.Nombre = N'Argentina'
WHERE NOT EXISTS (SELECT 1 FROM dbo.Provincia AS pr WHERE pr.IDPais = p.ID AND pr.Nombre = x.Nombre);

INSERT INTO dbo.Sector (Nombre, Orden)
SELECT x.Nombre, x.Orden
FROM (VALUES
    (N'Habilidades generales', 1),
    (N'Tecnología y sistemas', 2),
    (N'Datos y análisis', 3),
    (N'Administración y finanzas', 4),
    (N'Ventas y atención al cliente', 5),
    (N'Marketing y comunicación', 6),
    (N'Diseño', 7),
    (N'Logística y operaciones', 8),
    (N'Gastronomía y hotelería', 9),
    (N'Salud', 10),
    (N'Educación', 11),
    (N'Construcción y oficios', 12),
    (N'Recursos humanos', 13)
) AS x (Nombre, Orden)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Sector AS s WHERE s.Nombre = x.Nombre);

DECLARE @Catalogo TABLE (Sector NVARCHAR(60), Nombre NVARCHAR(60));
INSERT INTO @Catalogo (Sector, Nombre) VALUES
    (N'Habilidades generales', N'Comunicación'),
    (N'Habilidades generales', N'Trabajo en equipo'),
    (N'Habilidades generales', N'Liderazgo'),
    (N'Habilidades generales', N'Organización'),
    (N'Habilidades generales', N'Resolución de problemas'),
    (N'Habilidades generales', N'Gestión de proyectos'),
    (N'Habilidades generales', N'Gestión del tiempo'),
    (N'Habilidades generales', N'Adaptabilidad'),
    (N'Habilidades generales', N'Pensamiento crítico'),
    (N'Habilidades generales', N'Atención al detalle'),
    (N'Tecnología y sistemas', N'Programación'),
    (N'Tecnología y sistemas', N'HTML'),
    (N'Tecnología y sistemas', N'CSS'),
    (N'Tecnología y sistemas', N'JavaScript'),
    (N'Tecnología y sistemas', N'TypeScript'),
    (N'Tecnología y sistemas', N'React'),
    (N'Tecnología y sistemas', N'C#'),
    (N'Tecnología y sistemas', N'.NET'),
    (N'Tecnología y sistemas', N'Java'),
    (N'Tecnología y sistemas', N'Python'),
    (N'Tecnología y sistemas', N'SQL'),
    (N'Tecnología y sistemas', N'Git'),
    (N'Tecnología y sistemas', N'Soporte técnico'),
    (N'Tecnología y sistemas', N'Redes informáticas'),
    (N'Tecnología y sistemas', N'Ciberseguridad'),
    (N'Tecnología y sistemas', N'Testing de software'),
    (N'Datos y análisis', N'Análisis de datos'),
    (N'Datos y análisis', N'Power BI'),
    (N'Datos y análisis', N'Tableau'),
    (N'Datos y análisis', N'Estadística'),
    (N'Datos y análisis', N'Machine learning'),
    (N'Datos y análisis', N'Excel avanzado'),
    (N'Administración y finanzas', N'Administración'),
    (N'Administración y finanzas', N'Contabilidad'),
    (N'Administración y finanzas', N'Excel'),
    (N'Administración y finanzas', N'Microsoft Office'),
    (N'Administración y finanzas', N'Google Workspace'),
    (N'Administración y finanzas', N'Facturación'),
    (N'Administración y finanzas', N'Liquidación de sueldos'),
    (N'Administración y finanzas', N'Tesorería'),
    (N'Administración y finanzas', N'Impuestos'),
    (N'Administración y finanzas', N'Cuentas a pagar y cobrar'),
    (N'Ventas y atención al cliente', N'Ventas'),
    (N'Ventas y atención al cliente', N'Atención al cliente'),
    (N'Ventas y atención al cliente', N'Negociación'),
    (N'Ventas y atención al cliente', N'Venta telefónica'),
    (N'Ventas y atención al cliente', N'Caja'),
    (N'Ventas y atención al cliente', N'Postventa'),
    (N'Ventas y atención al cliente', N'Manejo de CRM'),
    (N'Marketing y comunicación', N'Marketing digital'),
    (N'Marketing y comunicación', N'Redes sociales'),
    (N'Marketing y comunicación', N'Redacción'),
    (N'Marketing y comunicación', N'SEO'),
    (N'Marketing y comunicación', N'Publicidad'),
    (N'Marketing y comunicación', N'Comunicación institucional'),
    (N'Marketing y comunicación', N'Fotografía'),
    (N'Diseño', N'Diseño gráfico'),
    (N'Diseño', N'Figma'),
    (N'Diseño', N'Photoshop'),
    (N'Diseño', N'Illustrator'),
    (N'Diseño', N'Diseño UX/UI'),
    (N'Diseño', N'Edición de video'),
    (N'Logística y operaciones', N'Logística'),
    (N'Logística y operaciones', N'Manejo de stock'),
    (N'Logística y operaciones', N'Depósito'),
    (N'Logística y operaciones', N'Compras'),
    (N'Logística y operaciones', N'Comercio exterior'),
    (N'Logística y operaciones', N'Manejo de autoelevador'),
    (N'Logística y operaciones', N'Distribución'),
    (N'Gastronomía y hotelería', N'Cocina'),
    (N'Gastronomía y hotelería', N'Atención en salón'),
    (N'Gastronomía y hotelería', N'Barista'),
    (N'Gastronomía y hotelería', N'Pastelería'),
    (N'Gastronomía y hotelería', N'Manipulación de alimentos'),
    (N'Gastronomía y hotelería', N'Recepción hotelera'),
    (N'Gastronomía y hotelería', N'Housekeeping'),
    (N'Salud', N'Enfermería'),
    (N'Salud', N'Primeros auxilios'),
    (N'Salud', N'Cuidado de adultos mayores'),
    (N'Salud', N'Atención en farmacia'),
    (N'Salud', N'Administración de turnos médicos'),
    (N'Educación', N'Docencia'),
    (N'Educación', N'Clases particulares'),
    (N'Educación', N'Planificación educativa'),
    (N'Educación', N'Acompañamiento terapéutico'),
    (N'Educación', N'Cuidado de niños'),
    (N'Construcción y oficios', N'Electricidad'),
    (N'Construcción y oficios', N'Plomería'),
    (N'Construcción y oficios', N'Albañilería'),
    (N'Construcción y oficios', N'Carpintería'),
    (N'Construcción y oficios', N'Pintura'),
    (N'Construcción y oficios', N'Soldadura'),
    (N'Construcción y oficios', N'Mecánica'),
    (N'Construcción y oficios', N'Lectura de planos'),
    (N'Recursos humanos', N'Recursos humanos'),
    (N'Recursos humanos', N'Selección de personal'),
    (N'Recursos humanos', N'Capacitación'),
    (N'Recursos humanos', N'Relaciones laborales'),
    (N'Recursos humanos', N'Administración de personal');

UPDATE h SET IDSector = s.ID
FROM dbo.Habilidad AS h
JOIN @Catalogo AS c ON c.Nombre = h.Nombre
JOIN dbo.Sector AS s ON s.Nombre = c.Sector
WHERE h.IDSector IS NULL OR h.IDSector <> s.ID;

INSERT INTO dbo.Habilidad (Nombre, IDSector)
SELECT c.Nombre, s.ID
FROM @Catalogo AS c
JOIN dbo.Sector AS s ON s.Nombre = c.Sector
WHERE NOT EXISTS (SELECT 1 FROM dbo.Habilidad AS h WHERE h.Nombre = c.Nombre);

DELETE h FROM dbo.Habilidad AS h
WHERE h.IDSector IS NULL AND NOT EXISTS (SELECT 1 FROM dbo.UsuarioHabilidad AS uh WHERE uh.IDHabilidad = h.ID);

INSERT INTO dbo.Idioma (Nombre)
SELECT x.Nombre
FROM (VALUES
    (N'Español'), (N'Inglés'), (N'Portugués'), (N'Francés'), (N'Italiano'), (N'Alemán'),
    (N'Chino mandarín'), (N'Japonés'), (N'Lengua de señas argentina')
) AS x (Nombre)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Idioma AS i WHERE i.Nombre = x.Nombre);
GO

IF COL_LENGTH(N'dbo.Perfil', N'Ubicacion') IS NOT NULL
BEGIN
    EXEC (N'
        UPDATE pe SET IDProvincia = pr.ID
        FROM dbo.Perfil AS pe
        JOIN dbo.Provincia AS pr ON pr.Nombre =
            CASE
                WHEN pe.Ubicacion LIKE N''%CABA%'' THEN N''Ciudad Autónoma de Buenos Aires''
                WHEN pe.Ubicacion LIKE N''GBA%'' OR pe.Ubicacion IN (N''La Plata'', N''Mar del Plata'') THEN N''Buenos Aires''
                WHEN pe.Ubicacion = N''Rosario'' THEN N''Santa Fe''
                ELSE pe.Ubicacion
            END
        WHERE pe.IDProvincia IS NULL;
        ALTER TABLE dbo.Perfil DROP COLUMN Ubicacion;');
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE Email = N'50291929@est.ort.edu.ar')
BEGIN
    INSERT INTO dbo.Usuario (Nombre, Apellido, Email, [Contraseña], Tipo, Es_Moderador)
    VALUES (N'Teo', N'Moreno', N'50291929@est.ort.edu.ar',
            N'PBKDF2$600000$5PeX0WMGc2StUFT8LB6ytQ==$bp2ZHrIULGDmEzGP+cwo8mLhDEHzqmbNUIJe8GM19lE=',
            N'Persona', 1);
    INSERT INTO dbo.Perfil (IDUsuario) VALUES (SCOPE_IDENTITY());
END
ELSE
    UPDATE dbo.Usuario SET Es_Moderador = 1 WHERE Email = N'50291929@est.ort.edu.ar';
GO

SELECT t.name AS Tabla, SUM(p.rows) AS Filas
FROM sys.tables AS t
JOIN sys.partitions AS p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;
GO
