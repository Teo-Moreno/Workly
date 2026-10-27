/* ============================================================================
   Workly · 2 de 3 · Datos de prueba (SQL Server)
   ----------------------------------------------------------------------------
   Carga los datos: países y provincias (las listas del registro) y los datos
   de ejemplo de los wireframes (empresas, ofertas, puestos, instituciones y
   la cuenta de prueba). Ejecutar después de 1_Estructura.sql.

   Se puede ejecutar más de una vez: países y provincias se cargan solo si
   faltan, y los datos de ejemplo solo si la tabla está vacía.

   Cuenta de prueba:  sofia.martinez@mail.com  /  Workly2026
   ============================================================================ */

SET NOCOUNT ON;
GO

USE Workly;
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
