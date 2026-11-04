USE [Workly]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF COL_LENGTH(N'dbo.Puesto', N'IDSector') IS NULL
    ALTER TABLE [dbo].[Puesto] ADD [IDSector] [int] NULL CONSTRAINT [FK_Puesto_Sector] FOREIGN KEY REFERENCES [dbo].[Sector] ([ID]);
GO
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Puesto_IDSector' AND object_id = OBJECT_ID(N'dbo.Puesto'))
    CREATE NONCLUSTERED INDEX [IX_Puesto_IDSector] ON [dbo].[Puesto] ([IDSector] ASC);
GO

CREATE OR ALTER PROCEDURE dbo.EstadisticasPostulacionesEmpresa
    @IDEmpresa INT,
    @OfertasSobrePromedio INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @OfertasSobrePromedio = 0;

    IF @IDEmpresa IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.Empresa WHERE ID = @IDEmpresa)
    BEGIN
        SELECT N'La empresa indicada no existe.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Empresa NVARCHAR(100) = (SELECT Nombre FROM dbo.Empresa WHERE ID = @IDEmpresa);

    IF NOT EXISTS (SELECT 1 FROM dbo.OfertaLaboral WHERE IDEmpresa = @IDEmpresa AND Estado_Publicacion = N'Aprobada')
    BEGIN
        SELECT N'La empresa ' + @Empresa + N' no tiene ofertas publicadas.' AS Mensaje;
        RETURN 2;
    END

    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @Ofertas TABLE (
        IDOferta INT PRIMARY KEY,
        Titulo NVARCHAR(150),
        Fecha_Publicacion DATE,
        Fecha_Cierre DATE,
        Postulaciones INT
    );

    INSERT INTO @Ofertas (IDOferta, Titulo, Fecha_Publicacion, Fecha_Cierre, Postulaciones)
    SELECT o.ID, o.Titulo, o.Fecha_Publicacion, o.Fecha_Cierre,
           (SELECT COUNT(*) FROM dbo.Postulacion AS p WHERE p.IDOfertaLaboral = o.ID)
    FROM dbo.OfertaLaboral AS o
    WHERE o.IDEmpresa = @IDEmpresa AND o.Estado_Publicacion = N'Aprobada';

    DECLARE @Promedio DECIMAL(10, 2) = (SELECT AVG(CAST(Postulaciones AS DECIMAL(10, 2))) FROM @Ofertas);

    SELECT @OfertasSobrePromedio = COUNT(*) FROM @Ofertas WHERE Postulaciones > @Promedio;

    SELECT
        IDOferta,
        Titulo,
        Fecha_Publicacion AS Publicada,
        CASE WHEN Fecha_Cierre IS NOT NULL AND Fecha_Cierre < @Hoy THEN N'Cerrada' ELSE N'Vigente' END AS Vigencia,
        Postulaciones,
        @Promedio AS PromedioEmpresa,
        CASE WHEN Postulaciones > @Promedio THEN N'Sí' ELSE N'No' END AS SuperaPromedio
    FROM @Ofertas
    ORDER BY Postulaciones DESC, Fecha_Publicacion DESC;

    SELECT
        @Empresa AS Empresa,
        COUNT(*) AS OfertasPublicadas,
        SUM(Postulaciones) AS PostulacionesTotales,
        @Promedio AS PromedioPorOferta,
        @OfertasSobrePromedio AS OfertasSobrePromedio
    FROM @Ofertas;

    RETURN 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.RankingCandidatosPorHabilidades
    @IDOfertaLaboral INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IDOfertaLaboral IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.OfertaLaboral WHERE ID = @IDOfertaLaboral)
    BEGIN
        SELECT N'La oferta indicada no existe.' AS Mensaje;
        RETURN 1;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.OfertaPuesto WHERE IDOfertaLaboral = @IDOfertaLaboral)
    BEGIN
        SELECT N'La oferta no tiene puestos asociados, así que no se puede comparar con las habilidades de los candidatos.' AS Mensaje;
        RETURN 2;
    END

    DECLARE @Sectores TABLE (IDSector INT PRIMARY KEY, Nombre NVARCHAR(60));

    INSERT INTO @Sectores (IDSector, Nombre)
    SELECT DISTINCT s.ID, s.Nombre
    FROM dbo.OfertaPuesto AS op
    JOIN dbo.Puesto AS pu ON pu.ID = op.IDPuesto
    JOIN dbo.Sector AS s ON s.ID = pu.IDSector
    WHERE op.IDOfertaLaboral = @IDOfertaLaboral;

    IF NOT EXISTS (SELECT 1 FROM @Sectores)
    BEGIN
        SELECT N'Los puestos de la oferta no tienen un sector asignado, así que no se puede comparar con las habilidades de los candidatos.' AS Mensaje;
        RETURN 2;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.Postulacion WHERE IDOfertaLaboral = @IDOfertaLaboral)
    BEGIN
        SELECT N'La oferta todavía no recibió postulaciones.' AS Mensaje;
        RETURN 2;
    END

    DECLARE @Titulo NVARCHAR(150) = (SELECT Titulo FROM dbo.OfertaLaboral WHERE ID = @IDOfertaLaboral);
    DECLARE @ListaSectores NVARCHAR(1000) = (SELECT STRING_AGG(Nombre, N', ') WITHIN GROUP (ORDER BY Nombre) FROM @Sectores);
    DECLARE @Candidatos TABLE (
        IDUsuario INT PRIMARY KEY,
        Candidato NVARCHAR(101),
        FechaPostulacion DATE,
        EstadoPostulacion NVARCHAR(20),
        HabilidadesEnSector INT,
        HabilidadesTotales INT,
        Coincidencias NVARCHAR(2000)
    );

    INSERT INTO @Candidatos
    SELECT
        u.ID,
        u.Nombre + N' ' + u.Apellido,
        p.Fecha,
        p.Estado,
        enSector.Cantidad,
        total.Cantidad,
        enSector.Lista
    FROM dbo.Postulacion AS p
    JOIN dbo.Usuario AS u ON u.ID = p.IDUsuario
    CROSS APPLY (
        SELECT COUNT(*) AS Cantidad
        FROM dbo.UsuarioHabilidad AS uh
        WHERE uh.IDUsuario = u.ID
    ) AS total
    CROSS APPLY (
        SELECT COUNT(*) AS Cantidad, STRING_AGG(h.Nombre, N', ') WITHIN GROUP (ORDER BY h.Nombre) AS Lista
        FROM dbo.UsuarioHabilidad AS uh
        JOIN dbo.Habilidad AS h ON h.ID = uh.IDHabilidad
        JOIN @Sectores AS s ON s.IDSector = h.IDSector
        WHERE uh.IDUsuario = u.ID
    ) AS enSector
    WHERE p.IDOfertaLaboral = @IDOfertaLaboral;

    SELECT
        RANK() OVER (ORDER BY HabilidadesEnSector DESC) AS Posicion,
        Candidato,
        HabilidadesEnSector,
        HabilidadesTotales,
        CASE WHEN HabilidadesTotales = 0 THEN CAST(0 AS DECIMAL(5, 2))
             ELSE CAST(HabilidadesEnSector * 100.0 / HabilidadesTotales AS DECIMAL(5, 2)) END AS PorcentajeEnSector,
        ISNULL(Coincidencias, N'-') AS HabilidadesCoincidentes,
        EstadoPostulacion,
        FechaPostulacion
    FROM @Candidatos
    ORDER BY Posicion, FechaPostulacion, Candidato;

    SELECT
        @Titulo AS Oferta,
        @ListaSectores AS SectoresDeLosPuestos,
        (SELECT COUNT(*) FROM @Candidatos) AS Candidatos,
        (SELECT COUNT(*) FROM @Candidatos WHERE HabilidadesEnSector > 0) AS ConAlgunaCoincidencia,
        N'La coincidencia por sector es una aproximación: no certifica que la persona sea apta para el puesto.' AS Aclaracion;

    RETURN 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.CompararSeleccionEmpresas
    @MinimoPostulaciones INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @MinimoPostulaciones IS NULL OR @MinimoPostulaciones < 1
    BEGIN
        SELECT N'El mínimo de postulaciones tiene que ser un número mayor a 0.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Empresas TABLE (
        IDEmpresa INT PRIMARY KEY,
        Empresa NVARCHAR(100),
        Postulaciones INT,
        Pase INT
    );

    INSERT INTO @Empresas (IDEmpresa, Empresa, Postulaciones, Pase)
    SELECT e.ID, e.Nombre, COUNT(p.ID), SUM(CASE WHEN p.Estado = N'Pasé' THEN 1 ELSE 0 END)
    FROM dbo.Empresa AS e
    JOIN dbo.OfertaLaboral AS o ON o.IDEmpresa = e.ID
    JOIN dbo.Postulacion AS p ON p.IDOfertaLaboral = o.ID
    GROUP BY e.ID, e.Nombre
    HAVING COUNT(p.ID) >= @MinimoPostulaciones;

    IF NOT EXISTS (SELECT 1 FROM @Empresas)
    BEGIN
        SELECT N'Ninguna empresa llega a ' + CAST(@MinimoPostulaciones AS NVARCHAR(10)) + N' postulaciones.' AS Mensaje;
        RETURN 2;
    END

    DECLARE @PromedioGeneral DECIMAL(5, 2) = (SELECT CAST(SUM(Pase) * 100.0 / SUM(Postulaciones) AS DECIMAL(5, 2)) FROM @Empresas);

    SELECT
        RANK() OVER (ORDER BY x.Porcentaje DESC) AS Posicion,
        x.Empresa,
        x.Postulaciones AS PostulacionesTotales,
        x.Pase AS PostulacionesPase,
        x.Porcentaje AS PorcentajePase,
        @PromedioGeneral AS PromedioGeneral,
        CASE WHEN x.Porcentaje > @PromedioGeneral THEN N'Sí' ELSE N'No' END AS SuperaPromedio
    FROM (
        SELECT Empresa, Postulaciones, Pase, CAST(Pase * 100.0 / Postulaciones AS DECIMAL(5, 2)) AS Porcentaje
        FROM @Empresas
    ) AS x
    ORDER BY x.Porcentaje DESC, x.Postulaciones DESC, x.Empresa;

    SELECT
        COUNT(*) AS EmpresasAnalizadas,
        SUM(Postulaciones) AS PostulacionesTotales,
        SUM(Pase) AS PostulacionesPase,
        @PromedioGeneral AS PromedioGeneral,
        N'Se mide el avance en la selección (postulaciones con estado «Pasé»), no contrataciones confirmadas.' AS Aclaracion
    FROM @Empresas;

    RETURN 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.OfertasFavoritasSinPostulacion
    @MinimoFavoritos INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @MinimoFavoritos IS NULL OR @MinimoFavoritos < 1
    BEGIN
        SELECT N'El mínimo de favoritos tiene que ser un número mayor a 0.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Resultado TABLE (
        TipoOferta NVARCHAR(10),
        IDOferta INT,
        UsuariosQueGuardaron INT,
        SinPostularse INT,
        PRIMARY KEY (TipoOferta, IDOferta)
    );

    WITH Guardados AS (
        SELECT DISTINCT
            f.IDUsuario,
            CASE WHEN fo.IDOfertaLaboral IS NOT NULL THEN N'Workly' ELSE N'Externa' END AS TipoOferta,
            COALESCE(fo.IDOfertaLaboral, fo.IDOfertaExterna) AS IDOferta
        FROM dbo.Favorito AS f
        JOIN dbo.FavoritoOferta AS fo ON fo.IDFavorito = f.ID_favorito
    ),
    ConPostulacion AS (
        SELECT
            g.TipoOferta,
            g.IDOferta,
            CASE WHEN EXISTS (
                SELECT 1 FROM dbo.Postulacion AS p
                WHERE p.IDUsuario = g.IDUsuario
                  AND ((g.TipoOferta = N'Workly' AND p.IDOfertaLaboral = g.IDOferta)
                    OR (g.TipoOferta = N'Externa' AND p.IDOfertaExterna = g.IDOferta))
            ) THEN 1 ELSE 0 END AS SePostulo
        FROM Guardados AS g
    )
    INSERT INTO @Resultado (TipoOferta, IDOferta, UsuariosQueGuardaron, SinPostularse)
    SELECT TipoOferta, IDOferta, COUNT(*), SUM(1 - SePostulo)
    FROM ConPostulacion
    GROUP BY TipoOferta, IDOferta
    HAVING COUNT(*) >= @MinimoFavoritos;

    IF NOT EXISTS (SELECT 1 FROM @Resultado)
    BEGIN
        SELECT N'No hay ofertas guardadas por al menos ' + CAST(@MinimoFavoritos AS NVARCHAR(10)) + N' personas.' AS Mensaje;
        RETURN 2;
    END

    SELECT
        r.TipoOferta,
        r.IDOferta,
        COALESCE(o.Titulo, x.Titulo) AS Oferta,
        COALESCE(e.Nombre, x.Empresa, N'-') AS Empresa,
        r.UsuariosQueGuardaron,
        r.SinPostularse,
        CAST(r.SinPostularse * 100.0 / r.UsuariosQueGuardaron AS DECIMAL(5, 2)) AS PorcentajeSinPostularse
    FROM @Resultado AS r
    LEFT JOIN dbo.OfertaLaboral AS o ON r.TipoOferta = N'Workly' AND o.ID = r.IDOferta
    LEFT JOIN dbo.Empresa AS e ON e.ID = o.IDEmpresa
    LEFT JOIN dbo.OfertaExterna AS x ON r.TipoOferta = N'Externa' AND x.ID = r.IDOferta
    ORDER BY r.UsuariosQueGuardaron DESC, PorcentajeSinPostularse DESC, Oferta;

    RETURN 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.DiagnosticoOferta
    @IDOfertaLaboral INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IDOfertaLaboral IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.OfertaLaboral WHERE ID = @IDOfertaLaboral)
    BEGIN
        SELECT N'La oferta indicada no existe.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @Titulo NVARCHAR(150), @Estado NVARCHAR(20), @Publicacion DATE, @Cierre DATE, @Vacantes INT;
    DECLARE @Vigencia NVARCHAR(20), @DiasPublicada INT, @DiasRestantes INT;
    DECLARE @Postulaciones INT, @Pase INT, @PorVacante DECIMAL(10, 2), @TasaPase DECIMAL(5, 2);
    DECLARE @Nivel NVARCHAR(30), @Diagnostico NVARCHAR(400);

    SELECT @Titulo = Titulo, @Estado = Estado_Publicacion, @Publicacion = Fecha_Publicacion, @Cierre = Fecha_Cierre, @Vacantes = Cantidad_Puestos
    FROM dbo.OfertaLaboral
    WHERE ID = @IDOfertaLaboral;

    SET @Vigencia = CASE
        WHEN @Estado = N'Pendiente' THEN N'En revisión'
        WHEN @Estado = N'Rechazada' THEN N'Rechazada'
        WHEN @Cierre IS NOT NULL AND @Cierre < @Hoy THEN N'Cerrada'
        ELSE N'Vigente' END;
    SET @DiasPublicada = DATEDIFF(DAY, @Publicacion, @Hoy);
    SET @DiasRestantes = CASE WHEN @Vigencia = N'Vigente' AND @Cierre IS NOT NULL THEN DATEDIFF(DAY, @Hoy, @Cierre) END;

    SELECT @Postulaciones = COUNT(*), @Pase = ISNULL(SUM(CASE WHEN Estado = N'Pasé' THEN 1 ELSE 0 END), 0)
    FROM dbo.Postulacion
    WHERE IDOfertaLaboral = @IDOfertaLaboral;

    IF @Postulaciones = 0
    BEGIN
        SELECT
            @Titulo AS Oferta,
            @Vigencia AS Vigencia,
            @DiasPublicada AS DiasPublicada,
            @DiasRestantes AS DiasRestantes,
            0 AS Postulaciones,
            CASE @Vigencia
                WHEN N'En revisión' THEN N'La oferta todavía no está publicada (la está revisando el equipo de Workly), por eso no tiene postulaciones.'
                WHEN N'Rechazada' THEN N'La oferta fue rechazada en la revisión y nunca se publicó, por eso no tiene postulaciones.'
                WHEN N'Cerrada' THEN N'La oferta cerró sin recibir postulaciones.'
                ELSE CASE WHEN @DiasPublicada < 7
                    THEN N'La oferta todavía no recibió postulaciones, pero lleva menos de una semana publicada.'
                    ELSE N'La oferta no recibió postulaciones en ' + CAST(@DiasPublicada AS NVARCHAR(10)) + N' días: conviene revisar el título, la descripción o el salario.' END
            END AS Mensaje;
        RETURN 2;
    END

    SET @PorVacante = CAST(@Postulaciones * 1.0 / @Vacantes AS DECIMAL(10, 2));
    SET @TasaPase = CAST(@Pase * 100.0 / @Postulaciones AS DECIMAL(5, 2));

    IF @PorVacante >= 5 AND @TasaPase >= 20
    BEGIN
        SET @Nivel = N'Muy bueno';
        SET @Diagnostico = N'Muchas postulaciones por vacante y buen avance en la selección.';
    END
    ELSE IF @PorVacante >= 5
    BEGIN
        SET @Nivel = N'Convocatoria alta';
        SET @Diagnostico = N'Llegan muchas postulaciones, pero pocas avanzan: conviene aclarar los requisitos en la descripción.';
    END
    ELSE IF @TasaPase >= 20
    BEGIN
        SET @Nivel = N'Convocatoria baja';
        SET @Diagnostico = N'Llegan pocas postulaciones por vacante, pero las que llegan avanzan: conviene difundir más la oferta.';
    END
    ELSE
    BEGIN
        SET @Nivel = N'Bajo';
        SET @Diagnostico = N'Pocas postulaciones por vacante y poco avance: conviene revisar el título, los requisitos y las condiciones.';
    END

    IF @Vigencia = N'Vigente' AND @DiasPublicada < 7
        SET @Diagnostico = @Diagnostico + N' Lleva menos de una semana publicada, así que el resultado todavía puede cambiar.';
    ELSE IF @Vigencia = N'Cerrada'
        SET @Diagnostico = @Diagnostico + N' La oferta ya cerró: el resultado es final.';

    SELECT
        @Titulo AS Oferta,
        @Vigencia AS Vigencia,
        @DiasPublicada AS DiasPublicada,
        @DiasRestantes AS DiasRestantes,
        @Vacantes AS Vacantes,
        @Postulaciones AS Postulaciones,
        @Pase AS PostulacionesPase,
        @PorVacante AS PostulacionesPorVacante,
        @TasaPase AS PorcentajePase,
        @Nivel AS Nivel,
        @Diagnostico AS Diagnostico;

    RETURN 0;
END
GO

CREATE OR ALTER PROCEDURE dbo.RecomendarOfertasParaUsuario
    @IDUsuario INT,
    @Cantidad INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @Cantidad IS NULL OR @Cantidad NOT BETWEEN 1 AND 50
    BEGIN
        SELECT N'La cantidad de recomendaciones tiene que estar entre 1 y 50.' AS Mensaje;
        RETURN 1;
    END

    IF @IDUsuario IS NULL OR NOT EXISTS (SELECT 1 FROM dbo.Usuario WHERE ID = @IDUsuario)
    BEGIN
        SELECT N'El usuario indicado no existe.' AS Mensaje;
        RETURN 1;
    END

    IF EXISTS (SELECT 1 FROM dbo.Usuario WHERE ID = @IDUsuario AND Tipo <> N'Persona')
    BEGIN
        SELECT N'Las recomendaciones son para cuentas de persona, no de empresa.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @TienePreferencia BIT = 0, @IDProvincia INT, @Modalidades NVARCHAR(60), @PuestoBuscado NVARCHAR(100), @Patron NVARCHAR(320);
    DECLARE @HabilidadesConSector INT;

    IF EXISTS (SELECT 1 FROM dbo.Preferencia WHERE IDUsuario = @IDUsuario)
    BEGIN
        SET @TienePreferencia = 1;
        SELECT @IDProvincia = IDProvincia, @Modalidades = Modalidades, @PuestoBuscado = NULLIF(LTRIM(RTRIM(Puesto_Buscado)), N'')
        FROM dbo.Preferencia
        WHERE IDUsuario = @IDUsuario;
    END

    SELECT @HabilidadesConSector = COUNT(*)
    FROM dbo.UsuarioHabilidad AS uh
    JOIN dbo.Habilidad AS h ON h.ID = uh.IDHabilidad
    WHERE uh.IDUsuario = @IDUsuario AND h.IDSector IS NOT NULL;

    IF @HabilidadesConSector = 0 AND @PuestoBuscado IS NULL AND @Modalidades IS NULL AND @IDProvincia IS NULL
    BEGIN
        SELECT N'Para recomendarte ofertas, cargá tus habilidades o qué buscás en tu perfil.' AS Mensaje;
        RETURN 2;
    END

    IF @PuestoBuscado IS NOT NULL
        SET @Patron = N'%' + REPLACE(REPLACE(REPLACE(@PuestoBuscado, N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]') + N'%';

    DECLARE @Candidatas TABLE (
        IDOferta INT PRIMARY KEY,
        Titulo NVARCHAR(150),
        Empresa NVARCHAR(100),
        Provincia NVARCHAR(80),
        Modalidad NVARCHAR(20),
        Publicada DATE,
        Coincidencias INT,
        PuntosHabilidades INT,
        PuntosUbicacion INT,
        PuntosModalidad INT,
        PuntosPuesto INT
    );

    INSERT INTO @Candidatas
    SELECT
        o.ID,
        o.Titulo,
        e.Nombre,
        pr.Nombre,
        o.Modalidad,
        o.Fecha_Publicacion,
        hab.Coincidencias,
        CASE WHEN hab.Coincidencias > 5 THEN 5 ELSE hab.Coincidencias END * 10,
        CASE
            WHEN o.Modalidad = N'Remoto' THEN 20
            WHEN @IDProvincia IS NOT NULL AND o.IDProvincia = @IDProvincia THEN 20
            WHEN @TienePreferencia = 1 AND @IDProvincia IS NULL THEN 10
            ELSE 0 END,
        CASE WHEN @Modalidades IS NOT NULL AND CHARINDEX(N',' + o.Modalidad + N',', N',' + @Modalidades + N',') > 0 THEN 15 ELSE 0 END,
        CASE WHEN @Patron IS NOT NULL AND (o.Titulo LIKE @Patron OR ISNULL(pu.Puestos, N'') LIKE @Patron) THEN 15 ELSE 0 END
    FROM dbo.OfertaLaboral AS o
    JOIN dbo.Empresa AS e ON e.ID = o.IDEmpresa
    LEFT JOIN dbo.Provincia AS pr ON pr.ID = o.IDProvincia
    OUTER APPLY (
        SELECT COUNT(DISTINCT uh.IDHabilidad) AS Coincidencias
        FROM dbo.OfertaPuesto AS op
        JOIN dbo.Puesto AS p ON p.ID = op.IDPuesto
        JOIN dbo.Habilidad AS h ON h.IDSector = p.IDSector
        JOIN dbo.UsuarioHabilidad AS uh ON uh.IDHabilidad = h.ID AND uh.IDUsuario = @IDUsuario
        WHERE op.IDOfertaLaboral = o.ID
    ) AS hab
    OUTER APPLY (
        SELECT STRING_AGG(p.Nombre, N', ') AS Puestos
        FROM dbo.OfertaPuesto AS op
        JOIN dbo.Puesto AS p ON p.ID = op.IDPuesto
        WHERE op.IDOfertaLaboral = o.ID
    ) AS pu
    WHERE o.Estado_Publicacion = N'Aprobada'
      AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= @Hoy)
      AND ISNULL(o.IDUsuario_Publicador, 0) <> @IDUsuario
      AND NOT EXISTS (SELECT 1 FROM dbo.Postulacion AS p WHERE p.IDUsuario = @IDUsuario AND p.IDOfertaLaboral = o.ID);

    IF NOT EXISTS (SELECT 1 FROM @Candidatas)
    BEGIN
        SELECT N'No hay ofertas vigentes en Workly a las que todavía no te hayas postulado.' AS Mensaje;
        RETURN 2;
    END

    IF NOT EXISTS (SELECT 1 FROM @Candidatas WHERE PuntosHabilidades + PuntosUbicacion + PuntosModalidad + PuntosPuesto > 0)
    BEGIN
        SELECT N'Hay ofertas vigentes, pero ninguna coincide todavía con tu perfil.' AS Mensaje;
        RETURN 2;
    END

    SELECT TOP (@Cantidad)
        IDOferta,
        Titulo,
        Empresa,
        ISNULL(Provincia, N'Todo el país') AS Provincia,
        Modalidad,
        PuntosHabilidades + PuntosUbicacion + PuntosModalidad + PuntosPuesto AS Puntaje,
        CONCAT_WS(N' · ',
            CASE WHEN Coincidencias = 1 THEN N'1 habilidad del sector' WHEN Coincidencias > 1 THEN CAST(Coincidencias AS NVARCHAR(10)) + N' habilidades del sector' END,
            CASE WHEN PuntosUbicacion = 20 AND Modalidad = N'Remoto' THEN N'remoto' WHEN PuntosUbicacion = 20 THEN N'en tu provincia' WHEN PuntosUbicacion = 10 THEN N'buscás en todo el país' END,
            CASE WHEN PuntosModalidad > 0 THEN N'modalidad que buscás' END,
            CASE WHEN PuntosPuesto > 0 THEN N'coincide con el puesto que buscás' END) AS Motivos
    FROM @Candidatas
    WHERE PuntosHabilidades + PuntosUbicacion + PuntosModalidad + PuntosPuesto > 0
    ORDER BY Puntaje DESC, Publicada DESC, IDOferta DESC;

    RETURN 0;
END
GO
