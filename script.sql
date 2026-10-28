/* ============================================================================
   Workly · Script de la base de datos (SQL Server)
   ----------------------------------------------------------------------------
   Crea la base "Workly" con todas las tablas del DLR, o actualiza una base
   Workly que ya existe (creada con una versión anterior de este script o con
   un export de SSMS) sin borrar los datos.

   Cómo usarlo en SQL Server Management Studio:
     1. Archivo › Abrir › este archivo.
     2. Ejecutar (F5).

   Se puede ejecutar más de una vez: solo crea lo que falta.

   No carga datos inventados. Solo carga:
     - Países y provincias (las listas del registro).
     - Catálogos de habilidades e idiomas (la persona elige o agrega los suyos).
     - La cuenta moderadora: 50291929@est.ort.edu.ar / 12345678a

   Para empezar de cero, descomentá el bloque "REINICIAR" de abajo.
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

-- Favorito y FavoritoOferta (del DLR; la página todavía no los usa) --------------------------
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
    IDOfertaLaboral INT NOT NULL,
    CONSTRAINT PK_FavoritoOferta PRIMARY KEY (ID),
    CONSTRAINT UQ_FavoritoOferta UNIQUE (IDFavorito, IDOfertaLaboral),
    CONSTRAINT FK_FavoritoOferta_Favorito FOREIGN KEY (IDFavorito) REFERENCES dbo.Favorito (ID_favorito) ON DELETE CASCADE,
    CONSTRAINT FK_FavoritoOferta_OfertaLaboral FOREIGN KEY (IDOfertaLaboral) REFERENCES dbo.OfertaLaboral (ID)
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
   ACTUALIZAR UNA BASE ANTERIOR
   Agrega lo que le falta a una base creada con una versión anterior (o con un
   export de SSMS) y pasa los datos viejos al formato nuevo. En una base
   recién creada no hace nada. Se usa EXEC cuando una columna puede no existir.
   ============================================================================ */

-- Pais.Codigo_ISO
IF COL_LENGTH(N'dbo.Pais', N'Codigo_ISO') IS NULL
    ALTER TABLE dbo.Pais ADD Codigo_ISO CHAR(2) NOT NULL CONSTRAINT DF_Pais_Codigo_ISO DEFAULT ('ar');
GO

-- Usuario: Tipo, Es_Moderador y contraseña opcional (para Google y LinkedIn)
IF COL_LENGTH(N'dbo.Usuario', N'Tipo') IS NULL
    ALTER TABLE dbo.Usuario ADD Tipo NVARCHAR(10) NOT NULL CONSTRAINT DF_Usuario_Tipo DEFAULT (N'Persona')
        CONSTRAINT CK_Usuario_Tipo CHECK (Tipo IN (N'Persona', N'Empresa'));
IF COL_LENGTH(N'dbo.Usuario', N'Es_Moderador') IS NULL
    ALTER TABLE dbo.Usuario ADD Es_Moderador BIT NOT NULL CONSTRAINT DF_Usuario_Es_Moderador DEFAULT (0);
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Usuario') AND name = N'Contraseña' AND is_nullable = 0)
    ALTER TABLE dbo.Usuario ALTER COLUMN [Contraseña] NVARCHAR(200) NULL;
GO

-- Perfil: Ubicacion (texto) pasa a IDProvincia; se agrega Estado_Busqueda
IF COL_LENGTH(N'dbo.Perfil', N'IDProvincia') IS NULL
    ALTER TABLE dbo.Perfil ADD IDProvincia INT NULL CONSTRAINT FK_Perfil_Provincia FOREIGN KEY REFERENCES dbo.Provincia (ID);
IF COL_LENGTH(N'dbo.Perfil', N'Estado_Busqueda') IS NULL
    ALTER TABLE dbo.Perfil ADD Estado_Busqueda NVARCHAR(30) NULL
        CONSTRAINT CK_Perfil_Estado_Busqueda CHECK (Estado_Busqueda IN (N'Buscando activamente', N'Abierto a propuestas', N'No estoy buscando'));
GO

-- Empresa: datos de las cuentas de empresa
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

-- OfertaLaboral: cantidad de puestos, quién la publicó y la moderación
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

-- OfertaLaboral.Puesto (texto) pasa a la tabla Puesto
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

-- Postulacion: estado, ofertas externas y una postulación por oferta
IF COL_LENGTH(N'dbo.Postulacion', N'Estado') IS NULL
    ALTER TABLE dbo.Postulacion ADD Estado NVARCHAR(20) NOT NULL CONSTRAINT DF_Postulacion_Estado DEFAULT (N'Enviada');
GO
IF COL_LENGTH(N'dbo.Postulacion', N'IDOfertaExterna') IS NULL
    ALTER TABLE dbo.Postulacion ADD IDOfertaExterna INT NULL
        CONSTRAINT FK_Postulacion_OfertaExterna FOREIGN KEY REFERENCES dbo.OfertaExterna (ID);
GO
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'dbo.Postulacion') AND name = N'IDOfertaLaboral' AND is_nullable = 0)
    ALTER TABLE dbo.Postulacion ALTER COLUMN IDOfertaLaboral INT NULL;
-- La restricción UNIQUE vieja no deja dos postulaciones externas (IDOfertaLaboral NULL):
-- se reemplaza por índices filtrados (más abajo).
IF OBJECT_ID(N'dbo.UQ_Postulacion_Usuario_Oferta', N'UQ') IS NOT NULL
    ALTER TABLE dbo.Postulacion DROP CONSTRAINT UQ_Postulacion_Usuario_Oferta;
-- Estados nuevos: Enviada, En revisión, Pasé, No pasé
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

/* ============================================================================
   DATOS: países, provincias y catálogos
   Se cargan solo los que faltan.
   ============================================================================ */
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

-- Habilidades sugeridas en el registro (la persona también puede agregar otras)
INSERT INTO dbo.Habilidad (Nombre)
SELECT x.Nombre
FROM (VALUES
    (N'Atención al cliente'), (N'Ventas'), (N'Comunicación'), (N'Trabajo en equipo'), (N'Liderazgo'),
    (N'Organización'), (N'Resolución de problemas'), (N'Negociación'), (N'Excel'), (N'Google Workspace'),
    (N'Microsoft Office'), (N'Análisis de datos'), (N'SQL'), (N'Power BI'), (N'Contabilidad'),
    (N'Administración'), (N'Recursos humanos'), (N'Marketing digital'), (N'Redes sociales'), (N'Diseño gráfico'),
    (N'Figma'), (N'Photoshop'), (N'Redacción'), (N'Logística'), (N'Gestión de proyectos'),
    (N'HTML'), (N'CSS'), (N'JavaScript'), (N'TypeScript'), (N'React'), (N'C#'), (N'.NET'),
    (N'Java'), (N'Python'), (N'Git'), (N'Soporte técnico'), (N'Programación')
) AS x (Nombre)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Habilidad AS h WHERE h.Nombre = x.Nombre);

INSERT INTO dbo.Idioma (Nombre)
SELECT x.Nombre
FROM (VALUES
    (N'Español'), (N'Inglés'), (N'Portugués'), (N'Francés'), (N'Italiano'), (N'Alemán'),
    (N'Chino mandarín'), (N'Japonés'), (N'Lengua de señas argentina')
) AS x (Nombre)
WHERE NOT EXISTS (SELECT 1 FROM dbo.Idioma AS i WHERE i.Nombre = x.Nombre);
GO

-- Bases anteriores: Perfil.Ubicacion (texto) pasa a su provincia (necesita las provincias cargadas)
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

-- Cuenta moderadora: revisa las búsquedas que publican las personas.
-- 50291929@est.ort.edu.ar / 12345678a (la contraseña se guarda como hash PBKDF2)
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

/* ============================================================================
   RESUMEN
   ============================================================================ */
SELECT t.name AS Tabla, SUM(p.rows) AS Filas
FROM sys.tables AS t
JOIN sys.partitions AS p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;
GO
