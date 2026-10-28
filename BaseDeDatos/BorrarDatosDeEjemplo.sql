/* ============================================================================
   Workly · Borrar los datos de ejemplo (SQL Server)
   ----------------------------------------------------------------------------
   La primera versión del script cargaba datos inventados para probar:
   la cuenta de Sofía Martínez, 7 empresas, 8 ofertas y sus puestos.
   Este script los borra. No toca las cuentas ni los datos reales.

   Ejecutar una sola vez, después de script.sql.
   ============================================================================ */

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

USE Workly;
GO

BEGIN TRANSACTION;

-- 1. La cuenta de prueba (se borran en cascada su perfil, CV, experiencia,
--    formación, postulaciones y favoritos)
DELETE FROM dbo.Usuario WHERE Email = N'sofia.martinez@mail.com';

-- 2. Las ofertas de ejemplo: las de esas empresas que no publicó ninguna cuenta
DECLARE @Ejemplo TABLE (Nombre NVARCHAR(100));
INSERT INTO @Ejemplo VALUES
    (N'Mercado Libre'), (N'Globant'), (N'Ualá'), (N'Tiendanube'),
    (N'Naranja X'), (N'Despegar'), (N'Accenture Argentina');

DECLARE @Ofertas TABLE (ID INT);
INSERT INTO @Ofertas
SELECT o.ID
FROM dbo.OfertaLaboral AS o
JOIN dbo.Empresa AS e ON e.ID = o.IDEmpresa
WHERE e.Nombre IN (SELECT Nombre FROM @Ejemplo)
  AND e.IDUsuario IS NULL
  AND o.IDUsuario_Publicador IS NULL;

DELETE FROM dbo.Postulacion WHERE IDOfertaLaboral IN (SELECT ID FROM @Ofertas);
DELETE FROM dbo.FavoritoOferta WHERE IDOfertaLaboral IN (SELECT ID FROM @Ofertas);
DELETE FROM dbo.OfertaLaboral WHERE ID IN (SELECT ID FROM @Ofertas); -- OfertaPuesto se borra en cascada

-- 3. Esas empresas, si no las usa nadie (ni una cuenta, ni una oferta, ni una experiencia)
DELETE e
FROM dbo.Empresa AS e
WHERE e.Nombre IN (SELECT Nombre FROM @Ejemplo)
  AND e.IDUsuario IS NULL
  AND NOT EXISTS (SELECT 1 FROM dbo.OfertaLaboral AS o WHERE o.IDEmpresa = e.ID)
  AND NOT EXISTS (SELECT 1 FROM dbo.ExperienciaLaboral AS x WHERE x.IDEmpresa = e.ID);

-- 4. Los puestos que quedaron sin ninguna oferta
DELETE p
FROM dbo.Puesto AS p
WHERE NOT EXISTS (SELECT 1 FROM dbo.OfertaPuesto AS op WHERE op.IDPuesto = p.ID);

COMMIT TRANSACTION;
GO

SELECT 'Usuario' AS Tabla, COUNT(*) AS Filas FROM dbo.Usuario
UNION ALL SELECT 'Empresa', COUNT(*) FROM dbo.Empresa
UNION ALL SELECT 'OfertaLaboral', COUNT(*) FROM dbo.OfertaLaboral
UNION ALL SELECT 'Puesto', COUNT(*) FROM dbo.Puesto
UNION ALL SELECT 'Postulacion', COUNT(*) FROM dbo.Postulacion;
GO
