/* ============================================================================
   Workly · Países y provincias (SQL Server)
   ----------------------------------------------------------------------------
   Para una base Workly que ya existe (por ejemplo, la creada con el export
   de SSMS). Agrega lo que necesita la app para elegir país, provincia y el
   prefijo del teléfono:
     1. Tablas Pais y Provincia.
     2. Argentina (+54) y sus 24 provincias.
     3. Perfil.IDProvincia. Si Perfil todavía tiene la columna Ubicacion
        (texto), pasa cada valor a su provincia y después la borra.

   Se puede ejecutar más de una vez: solo crea y carga lo que falta.
   ============================================================================ */

SET NOCOUNT ON;
GO

USE Workly;
GO

/* ---- 1. Tablas ------------------------------------------------------------- */
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

/* ---- 2. Datos -------------------------------------------------------------- */
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
WHERE NOT EXISTS (SELECT 1 FROM dbo.Provincia AS pr WHERE pr.IDPais = p.ID AND pr.Nombre = x.Nombre);
GO

/* ---- 3. Perfil: Ubicacion (texto) pasa a IDProvincia ------------------------ */
IF COL_LENGTH(N'dbo.Perfil', N'IDProvincia') IS NULL
    ALTER TABLE dbo.Perfil ADD IDProvincia INT NULL
        CONSTRAINT FK_Perfil_Provincia FOREIGN KEY REFERENCES dbo.Provincia (ID);
GO

-- Se usa EXEC porque la columna Ubicacion puede no existir
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

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Perfil_IDProvincia')
    CREATE INDEX IX_Perfil_IDProvincia ON dbo.Perfil (IDProvincia);
GO

/* ---- Resumen --------------------------------------------------------------- */
SELECT pa.Nombre AS Pais, pa.Codigo_Telefono, COUNT(pr.ID) AS Provincias
FROM dbo.Pais AS pa
LEFT JOIN dbo.Provincia AS pr ON pr.IDPais = pa.ID
GROUP BY pa.Nombre, pa.Codigo_Telefono;

SELECT u.Email, pr.Nombre AS Provincia
FROM dbo.Usuario AS u
JOIN dbo.Perfil AS pe ON pe.IDUsuario = u.ID
LEFT JOIN dbo.Provincia AS pr ON pr.ID = pe.IDProvincia;
GO
