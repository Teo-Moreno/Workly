/* ============================================================================
   Workly · Script de la base de datos (SQL Server)
   ----------------------------------------------------------------------------
   Crea la base "Workly" con las tablas del diagrama DLR y carga datos de
   ejemplo (países y provincias, empresas, ofertas, puestos, instituciones y
   una cuenta de prueba).

   Cómo usarlo en SQL Server Management Studio:
     1. Archivo › Abrir › este archivo.
     2. Ejecutar (F5).

   Se puede ejecutar más de una vez: solo crea lo que todavía no existe y
   carga los datos de ejemplo si las tablas están vacías. Si la base se creó
   con una versión anterior del script, la actualiza sin borrar los datos
   (ver "ACTUALIZAR UNA BASE ANTERIOR"). Para empezar de cero, descomentá el
   bloque "REINICIAR" de abajo.

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
   PAÍSES Y PROVINCIAS
   Se cargan siempre (solo las que faltan): son los valores de las listas
   "País" y "Provincia" del registro. Por ahora solo Argentina.
   ============================================================================ */
INSERT INTO dbo.Pais (Nombre, Codigo_Telefono)
SELECT N'Argentina', N'+54'
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
WHERE NOT EXISTS (SELECT 1 FROM dbo.Provincia pr WHERE pr.IDPais = p.ID AND pr.Nombre = x.Nombre);
GO

/* ============================================================================
   ACTUALIZAR UNA BASE ANTERIOR
   Si la base se creó con una versión anterior del script, agrega las
   columnas nuevas y pasa los datos viejos al formato nuevo. En una base
   recién creada no hace nada. (Se usa EXEC porque las columnas viejas pueden
   no existir.)
   ============================================================================ */

-- Perfil: Ubicacion (texto) pasa a IDProvincia
IF COL_LENGTH(N'dbo.Perfil', N'IDProvincia') IS NULL
    ALTER TABLE dbo.Perfil ADD IDProvincia INT NULL
        CONSTRAINT FK_Perfil_Provincia FOREIGN KEY REFERENCES dbo.Provincia (ID);
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
            END;
        ALTER TABLE dbo.Perfil DROP COLUMN Ubicacion;');
END
GO

-- OfertaLaboral: el Puesto (texto) pasa a la tabla Puesto y se agrega Cantidad_Puestos
IF COL_LENGTH(N'dbo.OfertaLaboral', N'Cantidad_Puestos') IS NULL
    ALTER TABLE dbo.OfertaLaboral ADD Cantidad_Puestos INT NOT NULL
        CONSTRAINT DF_OfertaLaboral_Cantidad_Puestos DEFAULT (1)
        CONSTRAINT CK_OfertaLaboral_Cantidad_Puestos CHECK (Cantidad_Puestos >= 1);
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

-- Postulacion: Estado
IF COL_LENGTH(N'dbo.Postulacion', N'Estado') IS NULL
    ALTER TABLE dbo.Postulacion ADD Estado NVARCHAR(20) NOT NULL
        CONSTRAINT DF_Postulacion_Estado DEFAULT (N'Enviada')
        CONSTRAINT CK_Postulacion_Estado CHECK (Estado IN (N'Enviada', N'En revisión', N'Entrevista', N'Finalizada'));
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
INSERT INTO dbo.OfertaLaboral (IDEmpresa, Titulo, Descripcion, Ubicacion, Modalidad, Tipo_Contrato, Salario, Cantidad_Puestos, Fecha_Publicacion, Fecha_Cierre)
SELECT e.ID, o.Titulo, o.Descripcion, o.Ubicacion, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad,
       DATEADD(DAY, -o.DiasPublicada, @Hoy), DATEADD(DAY, 30 - o.DiasPublicada, @Hoy)
FROM (VALUES
    (N'Globant', N'Frontend Developer React', N'Vas a sumarte al equipo de Web UI para desarrollar interfaces de una plataforma de e-commerce usada por más de 2 millones de personas en la región. Trabajarás junto a diseño de producto y equipos de backend en sprints de dos semanas.', N'Palermo, CABA', N'Híbrido', N'Relación de dependencia', 1800000, 2, 2),
    (N'Tiendanube', N'Desarrollador/a Frontend Jr', N'Vas a trabajar en el equipo de Storefront, construyendo las páginas que usan compradores de más de 100.000 tiendas online. Un equipo senior te va a acompañar de cerca durante el onboarding.', N'Remoto (Argentina)', N'Remoto', N'Relación de dependencia', 1100000, 1, 3),
    (N'Mercado Libre', N'UI Developer', N'Vas a formar parte del equipo de Design Systems, manteniendo y evolucionando la librería de componentes que usan más de 40 equipos de producto dentro de Mercado Libre.', N'Saavedra, CABA', N'Híbrido', N'Relación de dependencia', 2000000, 1, 5),
    (N'Ualá', N'Frontend Engineer (Vue)', N'Vas a desarrollar las pantallas web de la cuenta y las inversiones de Ualá, trabajando con diseño para lanzar mejoras todas las semanas.', N'Remoto (Argentina)', N'Remoto', N'Relación de dependencia', 1900000, 2, 7),
    (N'Naranja X', N'Web Developer', N'Vas a mantener y mejorar los sitios institucionales y las landings de campañas de Naranja X, trabajando junto a marketing y diseño.', N'Córdoba', N'Presencial', N'Relación de dependencia', 1000000, 1, 7),
    (N'Despegar', N'Frontend Developer', N'Vas a trabajar en el flujo de búsqueda y compra de vuelos, optimizando la performance y la experiencia en mobile web.', N'Saavedra, CABA', N'Híbrido', N'Relación de dependencia', 1700000, 1, 4),
    (N'Mercado Libre', N'Frontend Developer Jr', N'Vas a sumarte a un equipo de Shipping para construir las herramientas web que usan los vendedores para gestionar sus envíos.', N'Saavedra, CABA', N'Híbrido', N'Relación de dependencia', 1300000, 3, 6),
    (N'Globant', N'Desarrollador/a Angular', N'Vas a participar en un proyecto para un cliente de la industria aérea, desarrollando el nuevo portal de clientes con Angular.', N'Remoto (Argentina)', N'Remoto', N'Contractor', 1900000, 2, 7)
) AS o (Empresa, Titulo, Descripcion, Ubicacion, Modalidad, Tipo_Contrato, Salario, Cantidad, DiasPublicada)
JOIN dbo.Empresa AS e ON e.Nombre = o.Empresa;

-- Puestos y a qué ofertas corresponden ----------------------------------------------
IF NOT EXISTS (SELECT 1 FROM dbo.Puesto)
INSERT INTO dbo.Puesto (Nombre, Descripcion) VALUES
    (N'Frontend Developer Junior', N'Desarrollo de interfaces web con acompañamiento de perfiles senior.'),
    (N'Frontend Developer Semi Senior', N'Desarrollo de interfaces web con autonomía en tareas del día a día.'),
    (N'UI Developer Semi Senior', N'Componentes y sistemas de diseño para varios equipos de producto.'),
    (N'Frontend Engineer Semi Senior', N'Desarrollo frontend con foco en calidad, performance y testing.'),
    (N'Web Developer Junior', N'Sitios institucionales y landings junto a marketing y diseño.');

IF NOT EXISTS (SELECT 1 FROM dbo.OfertaPuesto)
INSERT INTO dbo.OfertaPuesto (IDOfertaLaboral, IDPuesto)
SELECT o.ID, p.ID
FROM (VALUES
    (N'Frontend Developer React', N'Frontend Developer Semi Senior'),
    (N'Desarrollador/a Frontend Jr', N'Frontend Developer Junior'),
    (N'UI Developer', N'UI Developer Semi Senior'),
    (N'Frontend Engineer (Vue)', N'Frontend Engineer Semi Senior'),
    (N'Web Developer', N'Web Developer Junior'),
    (N'Frontend Developer', N'Frontend Developer Semi Senior'),
    (N'Frontend Developer Jr', N'Frontend Developer Junior'),
    (N'Desarrollador/a Angular', N'Frontend Developer Semi Senior')
) AS x (Oferta, Puesto)
JOIN dbo.OfertaLaboral AS o ON o.Titulo = x.Oferta
JOIN dbo.Puesto AS p ON p.Nombre = x.Puesto;

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

    INSERT INTO dbo.Perfil (IDUsuario, IDProvincia, Foto, Descripcion, Telefono)
    SELECT @IDSofia, ID, NULL,
           N'Soy desarrolladora frontend con foco en React y TypeScript. Me gusta construir interfaces accesibles y prolijas, trabajar cerca de diseño y escribir CSS mantenible con BEM. Busco un equipo donde seguir creciendo hacia un rol Semi Senior.',
           N'+54 11 5555-1234'
    FROM dbo.Provincia WHERE Nombre = N'Ciudad Autónoma de Buenos Aires';

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

    INSERT INTO dbo.Postulacion (IDUsuario, IDOfertaLaboral, Fecha, Estado)
    SELECT @IDSofia, o.ID, DATEADD(DAY, -x.Dias, @Hoy), x.Estado
    FROM (VALUES
        (N'Frontend Developer React', 8, N'Entrevista'), (N'Desarrollador/a Frontend Jr', 24, N'Enviada'),
        (N'UI Developer', 15, N'En revisión'), (N'Frontend Engineer (Vue)', 19, N'Entrevista'),
        (N'Web Developer', 31, N'Enviada'), (N'Frontend Developer', 26, N'Finalizada')
    ) AS x (Titulo, Dias, Estado)
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
SELECT 'Pais' AS Tabla, COUNT(*) AS Filas FROM dbo.Pais
UNION ALL SELECT 'Provincia', COUNT(*) FROM dbo.Provincia
UNION ALL SELECT 'Usuario', COUNT(*) FROM dbo.Usuario
UNION ALL SELECT 'Perfil', COUNT(*) FROM dbo.Perfil
UNION ALL SELECT 'CV', COUNT(*) FROM dbo.CV
UNION ALL SELECT 'Educacion', COUNT(*) FROM dbo.Educacion
UNION ALL SELECT 'UsuarioEducacion', COUNT(*) FROM dbo.UsuarioEducacion
UNION ALL SELECT 'Empresa', COUNT(*) FROM dbo.Empresa
UNION ALL SELECT 'ExperienciaLaboral', COUNT(*) FROM dbo.ExperienciaLaboral
UNION ALL SELECT 'OfertaLaboral', COUNT(*) FROM dbo.OfertaLaboral
UNION ALL SELECT 'Puesto', COUNT(*) FROM dbo.Puesto
UNION ALL SELECT 'OfertaPuesto', COUNT(*) FROM dbo.OfertaPuesto
UNION ALL SELECT 'Favorito', COUNT(*) FROM dbo.Favorito
UNION ALL SELECT 'FavoritoOferta', COUNT(*) FROM dbo.FavoritoOferta
UNION ALL SELECT 'Postulacion', COUNT(*) FROM dbo.Postulacion;
GO
