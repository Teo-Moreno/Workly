/* ============================================================================
   Workly · 2 de 3 · Datos (SQL Server)
   ----------------------------------------------------------------------------
   Los INSERT de script.sql: países, provincias, catálogos de habilidades e
   idiomas, y la cuenta moderadora (50291929@est.ort.edu.ar / 12345678a).
   No hay datos inventados: las cuentas, perfiles y ofertas los cargan las
   personas y las empresas desde la página. Ejecutar después de 1_Estructura.sql.
   ============================================================================ */

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE Workly;
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
