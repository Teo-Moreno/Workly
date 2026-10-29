/* ============================================================================
   Workly · 1 de 3 · Estructura (SQL Server)
   ----------------------------------------------------------------------------
   Crea la base "Workly", sus tablas, restricciones e índices.
   Es la misma estructura que crea script.sql (raíz del proyecto), que es el
   que se usa para crear o actualizar la base. Este archivo es para leerla
   ordenada; después se ejecuta 2_DatosDePrueba.sql y 3_StoredProcedures.sql.
   ============================================================================ */

SET NOCOUNT ON;
-- Necesarios para los índices filtrados (SSMS ya los trae así; sqlcmd no)
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
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
   Los "string" del diagrama se crean como NVARCHAR (aceptan acentos y ñ).
   ============================================================================ */

-- Pais ------------------------------------------------------------------------
IF OBJECT_ID(N'dbo.Pais', N'U') IS NULL
CREATE TABLE dbo.Pais
(
    ID              INT IDENTITY(1, 1) NOT NULL,
    Nombre          NVARCHAR(60) NOT NULL,
    Codigo_ISO      CHAR(2)      NOT NULL, -- "ar": lo usa la búsqueda de trabajos (JSearch)
    Codigo_Telefono NVARCHAR(5)  NOT NULL, -- Prefijo internacional, por ejemplo "+54"
    CONSTRAINT PK_Pais PRIMARY KEY (ID),
    CONSTRAINT UQ_Pais_Nombre UNIQUE (Nombre)
);
GO

-- Provincia (cada provincia pertenece a un país) ------------------------------
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

-- Usuario: persona o empresa ----------------------------------------------------
IF OBJECT_ID(N'dbo.Usuario', N'U') IS NULL
CREATE TABLE dbo.Usuario
(
    ID             INT IDENTITY(1, 1) NOT NULL,
    Nombre         NVARCHAR(50)  NOT NULL,
    Apellido       NVARCHAR(50)  NOT NULL,
    Email          NVARCHAR(100) NOT NULL,
    [Contraseña]   NVARCHAR(200) NULL, -- Hash PBKDF2. NULL si entra solo con Google o LinkedIn
    Fecha_Registro DATE NOT NULL CONSTRAINT DF_Usuario_Fecha_Registro DEFAULT (CAST(GETDATE() AS DATE)),
    Tipo           NVARCHAR(10) NOT NULL CONSTRAINT DF_Usuario_Tipo DEFAULT (N'Persona'),
    Es_Moderador   BIT NOT NULL CONSTRAINT DF_Usuario_Es_Moderador DEFAULT (0), -- Revisa las búsquedas que publican las personas
    CONSTRAINT PK_Usuario PRIMARY KEY (ID),
    CONSTRAINT UQ_Usuario_Email UNIQUE (Email),
    CONSTRAINT CK_Usuario_Tipo CHECK (Tipo IN (N'Persona', N'Empresa'))
);
GO

-- LoginExterno: cuentas vinculadas con Google o LinkedIn ---------------------------
IF OBJECT_ID(N'dbo.LoginExterno', N'U') IS NULL
CREATE TABLE dbo.LoginExterno
(
    ID         INT IDENTITY(1, 1) NOT NULL,
    IDUsuario  INT NOT NULL,
    Proveedor  NVARCHAR(20)  NOT NULL, -- "Google" o "LinkedIn"
    ID_Externo NVARCHAR(200) NOT NULL, -- Identificador de la persona en ese proveedor
    CONSTRAINT PK_LoginExterno PRIMARY KEY (ID),
    CONSTRAINT UQ_LoginExterno UNIQUE (Proveedor, ID_Externo),
    CONSTRAINT FK_LoginExterno_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE
);
GO

-- Perfil (1 a 1 con Usuario) ------------------------------------------------------
IF OBJECT_ID(N'dbo.Perfil', N'U') IS NULL
CREATE TABLE dbo.Perfil
(
    ID              INT IDENTITY(1, 1) NOT NULL,
    IDUsuario       INT NOT NULL,
    IDProvincia     INT NULL, -- Dónde vive (el país sale de la provincia)
    Foto            NVARCHAR(260) NULL,
    Descripcion     NVARCHAR(500) NULL,
    Telefono        NVARCHAR(30)  NULL, -- Con el prefijo del país, por ejemplo "+54 11 5555-1234"
    Estado_Busqueda NVARCHAR(30)  NULL,
    CONSTRAINT PK_Perfil PRIMARY KEY (ID),
    CONSTRAINT UQ_Perfil_IDUsuario UNIQUE (IDUsuario),
    CONSTRAINT FK_Perfil_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_Perfil_Provincia FOREIGN KEY (IDProvincia) REFERENCES dbo.Provincia (ID),
    CONSTRAINT CK_Perfil_Estado_Busqueda CHECK (Estado_Busqueda IN (N'Buscando activamente', N'Abierto a propuestas', N'No estoy buscando'))
);
GO

-- CV (1 a 1 con Usuario) ------------------------------------------------------------
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

-- Preferencia: lo que busca la persona (1 a 1 con Usuario) ----------------------------
IF OBJECT_ID(N'dbo.Preferencia', N'U') IS NULL
CREATE TABLE dbo.Preferencia
(
    ID             INT IDENTITY(1, 1) NOT NULL,
    IDUsuario      INT NOT NULL,
    Puesto_Buscado NVARCHAR(100) NULL,
    Niveles        NVARCHAR(100) NULL, -- Separados por coma: "Junior,Semi Senior"
    Modalidades    NVARCHAR(60)  NULL, -- Separadas por coma: "Remoto,Híbrido"
    Jornada        NVARCHAR(20)  NULL,
    Contratacion   NVARCHAR(40)  NULL,
    IDProvincia    INT NULL, -- Dónde quiere trabajar; NULL = todo el país
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

-- Habilidad y UsuarioHabilidad (N a N) ------------------------------------------------
IF OBJECT_ID(N'dbo.Habilidad', N'U') IS NULL
CREATE TABLE dbo.Habilidad
(
    ID     INT IDENTITY(1, 1) NOT NULL,
    Nombre NVARCHAR(60) NOT NULL,
    CONSTRAINT PK_Habilidad PRIMARY KEY (ID),
    CONSTRAINT UQ_Habilidad_Nombre UNIQUE (Nombre)
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

-- Idioma y UsuarioIdioma (N a N, con el nivel) --------------------------------------------
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

-- Educacion y UsuarioEducacion (N a N) ---------------------------------------------------
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
    Fecha_Fin    DATE NULL, -- NULL = en curso
    CONSTRAINT PK_UsuarioEducacion PRIMARY KEY (ID),
    CONSTRAINT FK_UsuarioEducacion_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_UsuarioEducacion_Educacion FOREIGN KEY (IDEducacion) REFERENCES dbo.Educacion (ID),
    CONSTRAINT CK_UsuarioEducacion_Fechas CHECK (Fecha_Fin IS NULL OR Fecha_Fin >= Fecha_Inicio)
);
GO

-- Empresa: las de cuenta propia tienen IDUsuario y CUIT; el resto se crea al cargar
-- una experiencia laboral o una búsqueda de una persona ------------------------------------
IF OBJECT_ID(N'dbo.Empresa', N'U') IS NULL
CREATE TABLE dbo.Empresa
(
    ID             INT IDENTITY(1, 1) NOT NULL,
    Nombre         NVARCHAR(100) NOT NULL,
    Descripcion    NVARCHAR(500) NULL,
    Logo           NVARCHAR(260) NULL,
    Ubicacion      NVARCHAR(100) NULL, -- Barrio o dirección
    Sitio_Web      NVARCHAR(200) NULL,
    IDUsuario      INT NULL,           -- Cuenta de empresa que la administra
    Razon_Social   NVARCHAR(150) NULL,
    CUIT           CHAR(11) NULL,      -- Solo números
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
    Fecha_Finalizacion DATE NULL, -- NULL = trabajo actual
    CONSTRAINT PK_ExperienciaLaboral PRIMARY KEY (ID),
    CONSTRAINT FK_ExperienciaLaboral_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE,
    CONSTRAINT FK_ExperienciaLaboral_Empresa FOREIGN KEY (IDEmpresa) REFERENCES dbo.Empresa (ID),
    CONSTRAINT CK_ExperienciaLaboral_Fechas CHECK (Fecha_Finalizacion IS NULL OR Fecha_Finalizacion >= Fecha_Inicio)
);
GO

-- OfertaLaboral: búsquedas publicadas en Workly por empresas o personas -----------------
-- Las de empresas se publican al toque; las de personas quedan "Pendiente" hasta que
-- una cuenta moderadora las acepta o las rechaza.
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
    Salario              INT NULL, -- Bruto mensual en pesos
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

-- Puesto y OfertaPuesto (N a N) ----------------------------------------------------------
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

-- OfertaExterna: ofertas de otros sitios (LinkedIn, Bumeran...) que trae JSearch -------------
-- Se guardan para mostrar su detalle y para que la persona registre que se postuló.
IF OBJECT_ID(N'dbo.OfertaExterna', N'U') IS NULL
CREATE TABLE dbo.OfertaExterna
(
    ID                INT IDENTITY(1, 1) NOT NULL,
    ID_Externo        NVARCHAR(200)  NOT NULL, -- job_id de JSearch
    Titulo            NVARCHAR(300)  NOT NULL,
    Empresa           NVARCHAR(200)  NULL,
    Logo              NVARCHAR(1000) NULL,
    Ubicacion         NVARCHAR(200)  NULL,
    Descripcion       NVARCHAR(MAX)  NULL,
    Es_Remoto         BIT NOT NULL CONSTRAINT DF_OfertaExterna_Es_Remoto DEFAULT (0),
    Tipo_Contrato     NVARCHAR(50)   NULL,
    Salario           NVARCHAR(100)  NULL,
    Link_Postulacion  NVARCHAR(2000) NULL,
    Publicador        NVARCHAR(100)  NULL, -- Sitio donde está publicada (LinkedIn, Bumeran...)
    Fecha_Publicacion DATETIME2 NULL,
    Fecha_Consulta    DATETIME2 NOT NULL CONSTRAINT DF_OfertaExterna_Fecha_Consulta DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_OfertaExterna PRIMARY KEY (ID),
    CONSTRAINT UQ_OfertaExterna_ID_Externo UNIQUE (ID_Externo)
);
GO

-- Favorito y FavoritoOferta: ofertas guardadas -------------------------------------------
-- Cada Favorito es una oferta que guardó la persona (con la fecha); FavoritoOferta dice cuál:
-- una de Workly o una de otro sitio (una de las dos).
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

-- Postulacion: a una oferta de Workly o a una externa (una de las dos) --------------------
-- El estado lo mueve la persona en su tablero.
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

/* ============================================================================
   ÍNDICES
   ============================================================================ */
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

