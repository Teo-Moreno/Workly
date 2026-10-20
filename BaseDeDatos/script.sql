/* ============================================================================
   Workly · Script de la base de datos (SQL Server)
   ----------------------------------------------------------------------------
   Crea la base "Workly" con las tablas del diagrama DLR y carga datos de
   ejemplo (empresas, ofertas, instituciones y una cuenta de prueba).

   Cómo usarlo en SQL Server Management Studio:
     1. Archivo › Abrir › este archivo.
     2. Ejecutar (F5).

   Se puede ejecutar más de una vez: solo crea lo que todavía no existe y
   carga los datos de ejemplo si las tablas están vacías. Para empezar de
   cero, descomentá el bloque "REINICIAR" de abajo.

   Cuenta de prueba:  sofia.martinez@mail.com  /  Workly2026
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

-- Perfil (1 a 1 con Usuario) --------------------------------------------------
IF OBJECT_ID(N'dbo.Perfil', N'U') IS NULL
CREATE TABLE dbo.Perfil
(
    ID          INT IDENTITY(1, 1) NOT NULL,
    IDUsuario   INT NOT NULL,
    Foto        NVARCHAR(260) NULL,
    Descripcion NVARCHAR(500) NULL,
    Ubicacion   NVARCHAR(100) NULL,
    Telefono    NVARCHAR(30)  NULL,
    CONSTRAINT PK_Perfil PRIMARY KEY (ID),
    CONSTRAINT UQ_Perfil_IDUsuario UNIQUE (IDUsuario),
    CONSTRAINT FK_Perfil_Usuario FOREIGN KEY (IDUsuario) REFERENCES dbo.Usuario (ID) ON DELETE CASCADE
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
    Puesto            NVARCHAR(100)  NOT NULL,
    Ubicacion         NVARCHAR(100)  NULL,
    Modalidad         NVARCHAR(20)   NOT NULL,
    Tipo_Contrato     NVARCHAR(50)   NOT NULL,
    Salario           INT NULL, -- Bruto mensual en pesos
    Fecha_Publicacion DATE NOT NULL CONSTRAINT DF_OfertaLaboral_Fecha_Publicacion DEFAULT (CAST(GETDATE() AS DATE)),
    Fecha_Cierre      DATE NULL,
    CONSTRAINT PK_OfertaLaboral PRIMARY KEY (ID),
    CONSTRAINT FK_OfertaLaboral_Empresa FOREIGN KEY (IDEmpresa) REFERENCES dbo.Empresa (ID),
    CONSTRAINT CK_OfertaLaboral_Modalidad CHECK (Modalidad IN (N'Remoto', N'Híbrido', N'Presencial')),
    CONSTRAINT CK_OfertaLaboral_Salario CHECK (Salario IS NULL OR Salario >= 0),
    CONSTRAINT CK_OfertaLaboral_Fechas CHECK (Fecha_Cierre IS NULL OR Fecha_Cierre >= Fecha_Publicacion)
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
    CONSTRAINT PK_Postulacion PRIMARY KEY (ID),
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
GO

/* ============================================================================
   DATOS DE EJEMPLO
   Son los mismos de los wireframes de Figma. Solo se cargan si la tabla
   correspondiente está vacía.
   ============================================================================ */
DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

-- Empresas ----------------------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Empresa)
INSERT INTO dbo.Empresa (Nombre, Descripcion, Logo, Ubicacion, Sitio_Web) VALUES
    (N'Mercado Libre', N'La plataforma de comercio electrónico y pagos más grande de Latinoamérica.', NULL, N'Saavedra, CABA', N'mercadolibre.com.ar'),
    (N'Globant', N'Compañía de ingeniería de software nativa digital, con equipos en más de 30 países.', NULL, N'Palermo, CABA', N'globant.com'),
    (N'Ualá', N'App financiera con cuenta, tarjeta e inversiones para millones de usuarios en la región.', NULL, N'Palermo, CABA', N'uala.com.ar'),
    (N'Tiendanube', N'Plataforma para crear tiendas online, elegida por más de 100.000 marcas en Latinoamérica.', NULL, N'Belgrano, CABA', N'tiendanube.com'),
    (N'Naranja X', N'Fintech de Grupo Galicia con billetera virtual, tarjetas y préstamos para todo el país.', NULL, N'Córdoba', N'naranjax.com'),
    (N'Despegar', N'Agencia de viajes online líder en Latinoamérica, con producto propio y equipos de tecnología.', NULL, N'Saavedra, CABA', N'despegar.com.ar'),
    (N'Accenture Argentina', N'Consultora global de tecnología y servicios profesionales.', NULL, N'Retiro, CABA', N'accenture.com/ar');

-- Ofertas laborales (Salario = piso del rango, bruto mensual) ---------------------
IF NOT EXISTS (SELECT 1 FROM dbo.OfertaLaboral)
INSERT INTO dbo.OfertaLaboral (IDEmpresa, Titulo, Descripcion, Puesto, Ubicacion, Modalidad, Tipo_Contrato, Salario, Fecha_Publicacion, Fecha_Cierre)
SELECT e.ID, o.Titulo, o.Descripcion, o.Puesto, o.Ubicacion, o.Modalidad, o.Tipo_Contrato, o.Salario,
       DATEADD(DAY, -o.DiasPublicada, @Hoy), DATEADD(DAY, 30 - o.DiasPublicada, @Hoy)
FROM (VALUES
    (N'Globant', N'Frontend Developer React', N'Vas a sumarte al equipo de Web UI para desarrollar interfaces de una plataforma de e-commerce usada por más de 2 millones de personas en la región. Trabajarás junto a diseño de producto y equipos de backend en sprints de dos semanas.', N'Frontend Developer Semi Senior', N'Palermo, CABA', N'Híbrido', N'Relación de dependencia', 1800000, 2),
    (N'Tiendanube', N'Desarrollador/a Frontend Jr', N'Vas a trabajar en el equipo de Storefront, construyendo las páginas que usan compradores de más de 100.000 tiendas online. Un equipo senior te va a acompañar de cerca durante el onboarding.', N'Frontend Developer Junior', N'Remoto (Argentina)', N'Remoto', N'Relación de dependencia', 1100000, 3),
    (N'Mercado Libre', N'UI Developer', N'Vas a formar parte del equipo de Design Systems, manteniendo y evolucionando la librería de componentes que usan más de 40 equipos de producto dentro de Mercado Libre.', N'UI Developer Semi Senior', N'Saavedra, CABA', N'Híbrido', N'Relación de dependencia', 2000000, 5),
    (N'Ualá', N'Frontend Engineer (Vue)', N'Vas a desarrollar las pantallas web de la cuenta y las inversiones de Ualá, trabajando con diseño para lanzar mejoras todas las semanas.', N'Frontend Engineer Semi Senior', N'Remoto (Argentina)', N'Remoto', N'Relación de dependencia', 1900000, 7),
    (N'Naranja X', N'Web Developer', N'Vas a mantener y mejorar los sitios institucionales y las landings de campañas de Naranja X, trabajando junto a marketing y diseño.', N'Web Developer Junior', N'Córdoba', N'Presencial', N'Relación de dependencia', 1000000, 7),
    (N'Despegar', N'Frontend Developer', N'Vas a trabajar en el flujo de búsqueda y compra de vuelos, optimizando la performance y la experiencia en mobile web.', N'Frontend Developer Semi Senior', N'Saavedra, CABA', N'Híbrido', N'Relación de dependencia', 1700000, 4),
    (N'Mercado Libre', N'Frontend Developer Jr', N'Vas a sumarte a un equipo de Shipping para construir las herramientas web que usan los vendedores para gestionar sus envíos.', N'Frontend Developer Junior', N'Saavedra, CABA', N'Híbrido', N'Relación de dependencia', 1300000, 6),
    (N'Globant', N'Desarrollador/a Angular', N'Vas a participar en un proyecto para un cliente de la industria aérea, desarrollando el nuevo portal de clientes con Angular.', N'Frontend Developer Semi Senior', N'Remoto (Argentina)', N'Remoto', N'Contractor', 1900000, 7)
) AS o (Empresa, Titulo, Descripcion, Puesto, Ubicacion, Modalidad, Tipo_Contrato, Salario, DiasPublicada)
JOIN dbo.Empresa AS e ON e.Nombre = o.Empresa;

-- Instituciones educativas ------------------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Educacion)
INSERT INTO dbo.Educacion (Institucion, Descripcion) VALUES
    (N'UTN — Facultad Regional Buenos Aires', N'Universidad Tecnológica Nacional'),
    (N'Coderhouse', N'Cursos online de programación, diseño y marketing'),
    (N'Escuela ORT', N'Educación técnica secundaria y terciaria'),
    (N'Universidad de Buenos Aires', N'Universidad pública'),
    (N'Digital House', N'Carreras cortas de tecnología');

-- Cuenta de prueba: sofia.martinez@mail.com / Workly2026 --------------------------
-- La contraseña se guarda como hash PBKDF2-SHA256 (600.000 iteraciones), igual
-- que lo hace la aplicación al registrarse.
IF NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE Email = N'sofia.martinez@mail.com')
BEGIN
    DECLARE @IDSofia INT;

    INSERT INTO dbo.Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro)
    VALUES (N'Sofía', N'Martínez', N'sofia.martinez@mail.com',
            N'PBKDF2$600000$XxyaPnsg1EhsDpHyp7PYVQ==$2sPE7CUBzmTvEQrqy44I6RDkwVvHrLYWX9Q2jkhiTmU=',
            DATEADD(MONTH, -2, @Hoy));
    SET @IDSofia = SCOPE_IDENTITY();

    INSERT INTO dbo.Perfil (IDUsuario, Foto, Descripcion, Ubicacion, Telefono)
    VALUES (@IDSofia, NULL,
            N'Soy desarrolladora frontend con foco en React y TypeScript. Me gusta construir interfaces accesibles y prolijas, trabajar cerca de diseño y escribir CSS mantenible con BEM. Busco un equipo donde seguir creciendo hacia un rol Semi Senior.',
            N'Palermo, CABA', N'+54 11 5555-1234');

    INSERT INTO dbo.CV (IDUsuario, Nombre_Archivo, Sitio_Web, Fecha_Actualizacion)
    VALUES (@IDSofia, NULL, N'sofiamartinez.dev', @Hoy);

    INSERT INTO dbo.UsuarioEducacion (IDUsuario, IDEducacion, Titulo, Fecha_Inicio, Fecha_Fin)
    SELECT @IDSofia, ed.ID, x.Titulo, x.Inicio, x.Fin
    FROM (VALUES
        (N'UTN — Facultad Regional Buenos Aires', N'Tecnicatura Superior en Programación', CAST('2023-03-01' AS DATE), CAST('2025-12-15' AS DATE)),
        (N'Coderhouse', N'Desarrollo Web y JavaScript', CAST('2023-04-01' AS DATE), CAST('2023-11-30' AS DATE))
    ) AS x (Institucion, Titulo, Inicio, Fin)
    JOIN dbo.Educacion AS ed ON ed.Institucion = x.Institucion;

    INSERT INTO dbo.ExperienciaLaboral (IDUsuario, IDEmpresa, Puesto, Descripcion, Fecha_Inicio, Fecha_Finalizacion)
    SELECT @IDSofia, ID, N'Frontend Developer Trainee',
           N'Desarrollo de componentes en React y TypeScript para un portal de clientes de un banco. Mantenimiento de la librería de componentes en Storybook junto al equipo de diseño.',
           CAST('2025-03-01' AS DATE), NULL
    FROM dbo.Empresa WHERE Nombre = N'Accenture Argentina';

    INSERT INTO dbo.Postulacion (IDUsuario, IDOfertaLaboral, Fecha)
    SELECT @IDSofia, o.ID, DATEADD(DAY, -x.Dias, @Hoy)
    FROM (VALUES
        (N'Frontend Developer React', 8), (N'Desarrollador/a Frontend Jr', 24), (N'UI Developer', 15),
        (N'Frontend Engineer (Vue)', 19), (N'Web Developer', 31), (N'Frontend Developer', 26)
    ) AS x (Titulo, Dias)
    JOIN dbo.OfertaLaboral AS o ON o.Titulo = x.Titulo;

    DECLARE @IDFavorito INT;
    INSERT INTO dbo.Favorito (IDUsuario, fecha_guardado) VALUES (@IDSofia, @Hoy);
    SET @IDFavorito = SCOPE_IDENTITY();

    INSERT INTO dbo.FavoritoOferta (IDFavorito, IDOfertaLaboral)
    SELECT @IDFavorito, ID FROM dbo.OfertaLaboral
    WHERE Titulo IN (N'Frontend Engineer (Vue)', N'Web Developer', N'Desarrollador/a Angular');
END
GO

/* ============================================================================
   RESUMEN
   ============================================================================ */
SELECT 'Usuario' AS Tabla, COUNT(*) AS Filas FROM dbo.Usuario
UNION ALL SELECT 'Perfil', COUNT(*) FROM dbo.Perfil
UNION ALL SELECT 'CV', COUNT(*) FROM dbo.CV
UNION ALL SELECT 'Educacion', COUNT(*) FROM dbo.Educacion
UNION ALL SELECT 'UsuarioEducacion', COUNT(*) FROM dbo.UsuarioEducacion
UNION ALL SELECT 'Empresa', COUNT(*) FROM dbo.Empresa
UNION ALL SELECT 'ExperienciaLaboral', COUNT(*) FROM dbo.ExperienciaLaboral
UNION ALL SELECT 'OfertaLaboral', COUNT(*) FROM dbo.OfertaLaboral
UNION ALL SELECT 'Favorito', COUNT(*) FROM dbo.Favorito
UNION ALL SELECT 'FavoritoOferta', COUNT(*) FROM dbo.FavoritoOferta
UNION ALL SELECT 'Postulacion', COUNT(*) FROM dbo.Postulacion;
GO
