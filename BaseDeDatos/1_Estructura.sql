/* ============================================================================
   Workly · 1 de 3 · Estructura (SQL Server)
   ----------------------------------------------------------------------------
   Crea la base "Workly" con todas las tablas del DLR, sus claves, controles
   (CHECK) e índices. No carga datos.

   Orden para armar la base con los archivos separados:
     1_Estructura.sql  →  2_DatosDePrueba.sql  →  3_StoredProcedures.sql

   script.sql sigue siendo el script completo (hace lo mismo que estos tres
   archivos juntos, salvo los stored procedures) y además actualiza una base
   creada con una versión anterior. Si cambia algo acá, cambiarlo también ahí.

   Se puede ejecutar más de una vez: solo crea lo que todavía no existe.
   ============================================================================ */

SET NOCOUNT ON;
GO

USE master;
GO

/* ---- REINICIAR (borra la base y todos sus datos) ---------------------------
IF DB_ID(N'Workly') IS NOT NULL
BEGIN
    ALTER DATABASE Workly SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Workly;
END
GO
---------------------------------------------------------------------------- */

IF DB_ID(N'Workly') IS NULL
    CREATE DATABASE Workly;
GO

USE Workly;
GO

/* ============================================================================
   TABLAS
   Los tipos "string" del diagrama se crean como NVARCHAR (aceptan acentos y ñ)
   y los "date" como DATE.
   ============================================================================ */

-- Usuario ---------------------------------------------------------------------
IF OBJECT_ID(N'dbo.Usuario', N'U') IS NULL
CREATE TABLE dbo.Usuario
(
    ID              INT IDENTITY(1, 1) NOT NULL,
    Nombre          NVARCHAR(50)  NOT NULL,
    Apellido        NVARCHAR(50)  NOT NULL,
    Email           NVARCHAR(100) NOT NULL,
    [Contraseña]    NVARCHAR(200) NOT NULL, -- Hash PBKDF2, nunca la contraseña en texto plano
    Fecha_Registro  DATE NOT NULL CONSTRAINT DF_Usuario_Fecha_Registro DEFAULT (CAST(GETDATE() AS DATE)),
    CONSTRAINT PK_Usuario PRIMARY KEY (ID),
    CONSTRAINT UQ_Usuario_Email UNIQUE (Email)
);
GO

-- Pais --------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.Pais', N'U') IS NULL
CREATE TABLE dbo.Pais
(
    ID              INT IDENTITY(1, 1) NOT NULL,
    Nombre          NVARCHAR(60) NOT NULL,
    Codigo_Telefono NVARCHAR(5)  NOT NULL, -- Prefijo internacional, por ejemplo "+54"
    CONSTRAINT PK_Pais PRIMARY KEY (ID),
    CONSTRAINT UQ_Pais_Nombre UNIQUE (Nombre)
);
GO

-- Provincia (cada provincia pertenece a un país) ---------------------------------
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

-- Perfil (1 a 1 con Usuario) --------------------------------------------------
IF OBJECT_ID(N'dbo.Perfil', N'U') IS NULL
CREATE TABLE dbo.Perfil
(
    ID          INT IDENTITY(1, 1) NOT NULL,
    IDUsuario   INT NOT NULL,
    IDProvincia INT NULL, -- Dónde vive (el país sale de la provincia)
    Foto        NVARCHAR(260) NULL,
    Descripcion NVARCHAR(500) NULL,
    Telefono    NVARCHAR(30)  NULL, -- Con el prefijo del país, por ejemplo "+54 11 5555-1234"
    CONSTRAINT PK_Perfil PRIMARY KEY (ID),
    CONSTRAINT UQ_Perfil_IDUsuario UNIQUE (IDUsuario),
    CONSTRAINT FK_Perfil_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_Perfil_Provincia FOREIGN KEY (IDProvincia) REFERENCES dbo.Provincia (ID)
);
GO

-- CV (1 a 1 con Usuario) ------------------------------------------------------
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

-- Educacion -------------------------------------------------------------------
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

-- UsuarioEducacion (N a N entre Usuario y Educacion) --------------------------
IF OBJECT_ID(N'dbo.UsuarioEducacion', N'U') IS NULL
CREATE TABLE dbo.UsuarioEducacion
(
    ID           INT IDENTITY(1, 1) NOT NULL,
    IDUsuario    INT NOT NULL,
    IDEducacion  INT NOT NULL,
    Titulo       NVARCHAR(150) NOT NULL,
    Fecha_Inicio DATE NOT NULL,
    Fecha_Fin    DATE NULL, -- NULL = en curso
    CONSTRAINT PK_UsuarioEducacion PRIMARY KEY (ID),
    CONSTRAINT FK_UsuarioEducacion_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_UsuarioEducacion_Educacion FOREIGN KEY (IDEducacion) REFERENCES dbo.Educacion (ID),
    CONSTRAINT CK_UsuarioEducacion_Fechas CHECK (Fecha_Fin IS NULL OR Fecha_Fin >= Fecha_Inicio)
);
GO

-- Empresa ---------------------------------------------------------------------
IF OBJECT_ID(N'dbo.Empresa', N'U') IS NULL
CREATE TABLE dbo.Empresa
(
    ID          INT IDENTITY(1, 1) NOT NULL,
    Nombre      NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500) NULL,
    Logo        NVARCHAR(260) NULL,
    Ubicacion   NVARCHAR(100) NULL,
    Sitio_Web   NVARCHAR(200) NULL,
    CONSTRAINT PK_Empresa PRIMARY KEY (ID),
    CONSTRAINT UQ_Empresa_Nombre UNIQUE (Nombre)
);
GO

-- ExperienciaLaboral ----------------------------------------------------------
IF OBJECT_ID(N'dbo.ExperienciaLaboral', N'U') IS NULL
CREATE TABLE dbo.ExperienciaLaboral
(
    ID                 INT IDENTITY(1, 1) NOT NULL,
    IDUsuario          INT NOT NULL,
    IDEmpresa          INT NOT NULL,
    Puesto             NVARCHAR(100) NOT NULL,
    Descripcion        NVARCHAR(500) NULL,
    Fecha_Inicio       DATE NOT NULL,
    Fecha_Finalizacion DATE NULL, -- NULL = trabajo actual
    CONSTRAINT PK_ExperienciaLaboral PRIMARY KEY (ID),
    CONSTRAINT FK_ExperienciaLaboral_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_ExperienciaLaboral_Empresa FOREIGN KEY (IDEmpresa) REFERENCES dbo.Empresa (ID),
    CONSTRAINT CK_ExperienciaLaboral_Fechas CHECK (Fecha_Finalizacion IS NULL OR Fecha_Finalizacion >= Fecha_Inicio)
);
GO

-- OfertaLaboral ---------------------------------------------------------------
IF OBJECT_ID(N'dbo.OfertaLaboral', N'U') IS NULL
CREATE TABLE dbo.OfertaLaboral
(
    ID                INT IDENTITY(1, 1) NOT NULL,
    IDEmpresa         INT NOT NULL,
    Titulo            NVARCHAR(150)  NOT NULL,
    Descripcion       NVARCHAR(2000) NULL,
    Ubicacion         NVARCHAR(100)  NULL,
    Modalidad         NVARCHAR(20)   NOT NULL,
    Tipo_Contrato     NVARCHAR(50)   NOT NULL,
    Salario           INT NULL, -- Bruto mensual en pesos
    Cantidad_Puestos  INT NOT NULL CONSTRAINT DF_OfertaLaboral_Cantidad_Puestos DEFAULT (1), -- Vacantes
    Fecha_Publicacion DATE NOT NULL CONSTRAINT DF_OfertaLaboral_Fecha_Publicacion DEFAULT (CAST(GETDATE() AS DATE)),
    Fecha_Cierre      DATE NULL,
    CONSTRAINT PK_OfertaLaboral PRIMARY KEY (ID),
    CONSTRAINT FK_OfertaLaboral_Empresa FOREIGN KEY (IDEmpresa) REFERENCES dbo.Empresa (ID),
    CONSTRAINT CK_OfertaLaboral_Modalidad CHECK (Modalidad IN (N'Remoto', N'Híbrido', N'Presencial')),
    CONSTRAINT CK_OfertaLaboral_Salario CHECK (Salario IS NULL OR Salario >= 0),
    CONSTRAINT CK_OfertaLaboral_Cantidad_Puestos CHECK (Cantidad_Puestos >= 1),
    CONSTRAINT CK_OfertaLaboral_Fechas CHECK (Fecha_Cierre IS NULL OR Fecha_Cierre >= Fecha_Publicacion)
);
GO

-- Puesto ------------------------------------------------------------------------
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

-- OfertaPuesto (N a N entre OfertaLaboral y Puesto) -------------------------------
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

-- Favorito --------------------------------------------------------------------
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

-- FavoritoOferta (N a N entre Favorito y OfertaLaboral) -----------------------
IF OBJECT_ID(N'dbo.FavoritoOferta', N'U') IS NULL
CREATE TABLE dbo.FavoritoOferta
(
    ID              INT IDENTITY(1, 1) NOT NULL,
    IDFavorito      INT NOT NULL,
    IDOfertaLaboral INT NOT NULL,
    CONSTRAINT PK_FavoritoOferta PRIMARY KEY (ID),
    CONSTRAINT UQ_FavoritoOferta UNIQUE (IDFavorito, IDOfertaLaboral),
    CONSTRAINT FK_FavoritoOferta_Favorito FOREIGN KEY (IDFavorito) REFERENCES dbo.Favorito (ID_favorito) ON DELETE CASCADE,
    CONSTRAINT FK_FavoritoOferta_OfertaLaboral FOREIGN KEY (IDOfertaLaboral) REFERENCES dbo.OfertaLaboral (ID)
);
GO

-- Postulacion -----------------------------------------------------------------
IF OBJECT_ID(N'dbo.Postulacion', N'U') IS NULL
CREATE TABLE dbo.Postulacion
(
    ID              INT IDENTITY(1, 1) NOT NULL,
    IDUsuario       INT NOT NULL,
    IDOfertaLaboral INT NOT NULL,
    Fecha           DATE NOT NULL CONSTRAINT DF_Postulacion_Fecha DEFAULT (CAST(GETDATE() AS DATE)),
    Estado          NVARCHAR(20) NOT NULL CONSTRAINT DF_Postulacion_Estado DEFAULT (N'Enviada'),
    CONSTRAINT PK_Postulacion PRIMARY KEY (ID),
    CONSTRAINT CK_Postulacion_Estado CHECK (Estado IN (N'Enviada', N'En revisión', N'Entrevista', N'Finalizada')),
    CONSTRAINT UQ_Postulacion_Usuario_Oferta UNIQUE (IDUsuario, IDOfertaLaboral), -- Una postulación por oferta
    CONSTRAINT FK_Postulacion_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_Postulacion_OfertaLaboral FOREIGN KEY (IDOfertaLaboral) REFERENCES dbo.OfertaLaboral (ID)
);
GO

/* ============================================================================
   ÍNDICES para las claves foráneas que más se consultan
   ============================================================================ */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_UsuarioEducacion_IDUsuario')
    CREATE INDEX IX_UsuarioEducacion_IDUsuario ON dbo.UsuarioEducacion (IDUsuario);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_ExperienciaLaboral_IDUsuario')
    CREATE INDEX IX_ExperienciaLaboral_IDUsuario ON dbo.ExperienciaLaboral (IDUsuario);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OfertaLaboral_IDEmpresa')
    CREATE INDEX IX_OfertaLaboral_IDEmpresa ON dbo.OfertaLaboral (IDEmpresa);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Favorito_IDUsuario')
    CREATE INDEX IX_Favorito_IDUsuario ON dbo.Favorito (IDUsuario);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Postulacion_IDOfertaLaboral')
    CREATE INDEX IX_Postulacion_IDOfertaLaboral ON dbo.Postulacion (IDOfertaLaboral);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Perfil_IDProvincia')
    CREATE INDEX IX_Perfil_IDProvincia ON dbo.Perfil (IDProvincia);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_OfertaPuesto_IDPuesto')
    CREATE INDEX IX_OfertaPuesto_IDPuesto ON dbo.OfertaPuesto (IDPuesto);
GO
