USE [Workly]
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRANSACTION;

DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
DECLARE @Usuarios TABLE (Clave NVARCHAR(20) PRIMARY KEY, ID INT);

INSERT INTO dbo.Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
OUTPUT N'lucia', INSERTED.ID INTO @Usuarios
VALUES (N'Lucía', N'Fernández', N'lucia.prueba-sp@workly.test', NULL, @Hoy, N'Persona');
INSERT INTO dbo.Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
OUTPUT N'martin', INSERTED.ID INTO @Usuarios
VALUES (N'Martín', N'Gómez', N'martin.prueba-sp@workly.test', NULL, @Hoy, N'Persona');
INSERT INTO dbo.Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
OUTPUT N'sofia', INSERTED.ID INTO @Usuarios
VALUES (N'Sofía', N'Ruiz', N'sofia.prueba-sp@workly.test', NULL, @Hoy, N'Persona');
INSERT INTO dbo.Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
OUTPUT N'diego', INSERTED.ID INTO @Usuarios
VALUES (N'Diego', N'Pérez', N'diego.prueba-sp@workly.test', NULL, @Hoy, N'Persona');
INSERT INTO dbo.Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
OUTPUT N'valentina', INSERTED.ID INTO @Usuarios
VALUES (N'Valentina', N'Díaz', N'valentina.prueba-sp@workly.test', NULL, @Hoy, N'Persona');
INSERT INTO dbo.Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
OUTPUT N'tomas', INSERTED.ID INTO @Usuarios
VALUES (N'Tomás', N'López', N'tomas.prueba-sp@workly.test', NULL, @Hoy, N'Persona');
INSERT INTO dbo.Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
OUTPUT N'vacio', INSERTED.ID INTO @Usuarios
VALUES (N'Camila', N'Sosa', N'camila.prueba-sp@workly.test', NULL, @Hoy, N'Persona');
INSERT INTO dbo.Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
OUTPUT N'empresa', INSERTED.ID INTO @Usuarios
VALUES (N'Laura', N'Méndez', N'rrhh.prueba-sp@sistemasdelta.test', NULL, @Hoy, N'Empresa');

DECLARE @Lucia INT = (SELECT ID FROM @Usuarios WHERE Clave = N'lucia');
DECLARE @Martin INT = (SELECT ID FROM @Usuarios WHERE Clave = N'martin');
DECLARE @Sofia INT = (SELECT ID FROM @Usuarios WHERE Clave = N'sofia');
DECLARE @Diego INT = (SELECT ID FROM @Usuarios WHERE Clave = N'diego');
DECLARE @Valentina INT = (SELECT ID FROM @Usuarios WHERE Clave = N'valentina');
DECLARE @Tomas INT = (SELECT ID FROM @Usuarios WHERE Clave = N'tomas');
DECLARE @Vacio INT = (SELECT ID FROM @Usuarios WHERE Clave = N'vacio');
DECLARE @UsuarioEmpresa INT = (SELECT ID FROM @Usuarios WHERE Clave = N'empresa');

INSERT INTO dbo.UsuarioHabilidad (IDUsuario, IDHabilidad)
SELECT u.ID, h.ID
FROM (VALUES
    (N'lucia', N'Barista'), (N'lucia', N'Cocina'), (N'lucia', N'Atención en salón'), (N'lucia', N'Excel'),
    (N'martin', N'Manejo de stock'), (N'martin', N'Logística'), (N'martin', N'Barista'),
    (N'sofia', N'Atención al cliente'),
    (N'diego', N'Depósito'), (N'diego', N'Manejo de autoelevador'), (N'diego', N'Logística'),
    (N'valentina', N'Pastelería'), (N'valentina', N'Barista'), (N'valentina', N'Manipulación de alimentos'), (N'valentina', N'C#'),
    (N'tomas', N'C#'), (N'tomas', N'.NET'), (N'tomas', N'SQL'), (N'tomas', N'Git')
) AS d (Clave, Habilidad)
JOIN @Usuarios AS u ON u.Clave = d.Clave
JOIN dbo.Habilidad AS h ON h.Nombre = d.Habilidad;

INSERT INTO dbo.Preferencia (IDUsuario, Puesto_Buscado, Modalidades, IDProvincia)
VALUES (@Lucia, N'Barista', N'Presencial', (SELECT ID FROM dbo.Provincia WHERE Nombre = N'Córdoba'));

DECLARE @Empresas TABLE (Clave NVARCHAR(20) PRIMARY KEY, ID INT);
INSERT INTO dbo.Empresa (Nombre, Descripcion, Rubro, IDProvincia)
OUTPUT N'cafe', INSERTED.ID INTO @Empresas
VALUES (N'Café del Centro (prueba SP)', N'Cafetería de Córdoba.', N'Gastronomía', (SELECT ID FROM dbo.Provincia WHERE Nombre = N'Córdoba'));
INSERT INTO dbo.Empresa (Nombre, Descripcion, Rubro, IDProvincia)
OUTPUT N'logistica', INSERTED.ID INTO @Empresas
VALUES (N'Logística Norte (prueba SP)', N'Distribución de mercadería.', N'Logística', (SELECT ID FROM dbo.Provincia WHERE Nombre = N'Buenos Aires'));
INSERT INTO dbo.Empresa (Nombre, Descripcion, Rubro, IDProvincia, IDUsuario)
OUTPUT N'sistemas', INSERTED.ID INTO @Empresas
VALUES (N'Sistemas Delta (prueba SP)', N'Desarrollo de software.', N'Tecnología', (SELECT ID FROM dbo.Provincia WHERE Nombre = N'Ciudad Autónoma de Buenos Aires'), @UsuarioEmpresa);
INSERT INTO dbo.Empresa (Nombre, Descripcion, Rubro)
OUTPUT N'sinofertas', INSERTED.ID INTO @Empresas
VALUES (N'Comercio Sin Ofertas (prueba SP)', N'Empresa sin búsquedas publicadas.', N'Comercio');

DECLARE @Cafe INT = (SELECT ID FROM @Empresas WHERE Clave = N'cafe');
DECLARE @Logistica INT = (SELECT ID FROM @Empresas WHERE Clave = N'logistica');
DECLARE @Sistemas INT = (SELECT ID FROM @Empresas WHERE Clave = N'sistemas');
DECLARE @SinOfertas INT = (SELECT ID FROM @Empresas WHERE Clave = N'sinofertas');

DECLARE @Puestos TABLE (Clave NVARCHAR(20) PRIMARY KEY, ID INT);
INSERT INTO dbo.Puesto (Nombre, IDSector)
OUTPUT N'barista', INSERTED.ID INTO @Puestos
VALUES (N'Barista (prueba SP)', (SELECT ID FROM dbo.Sector WHERE Nombre = N'Gastronomía y hotelería'));
INSERT INTO dbo.Puesto (Nombre, IDSector)
OUTPUT N'deposito', INSERTED.ID INTO @Puestos
VALUES (N'Operario de depósito (prueba SP)', (SELECT ID FROM dbo.Sector WHERE Nombre = N'Logística y operaciones'));
INSERT INTO dbo.Puesto (Nombre, IDSector)
OUTPUT N'dotnet', INSERTED.ID INTO @Puestos
VALUES (N'Desarrollador/a .NET (prueba SP)', (SELECT ID FROM dbo.Sector WHERE Nombre = N'Tecnología y sistemas'));
INSERT INTO dbo.Puesto (Nombre, IDSector)
OUTPUT N'sinsector', INSERTED.ID INTO @Puestos
VALUES (N'Mozo/a (prueba SP)', NULL);

DECLARE @Ofertas TABLE (Clave NVARCHAR(20) PRIMARY KEY, ID INT);
INSERT INTO dbo.OfertaLaboral (IDEmpresa, Titulo, Descripcion, Modalidad, Tipo_Contrato, Cantidad_Puestos, Fecha_Publicacion, Fecha_Cierre, IDProvincia, Estado_Publicacion)
OUTPUT N'barista', INSERTED.ID INTO @Ofertas
VALUES (@Cafe, N'Barista para cafetería', N'Preparación de café y atención en barra.', N'Presencial', N'Tiempo completo', 1, DATEADD(DAY, -20, @Hoy), NULL, (SELECT ID FROM dbo.Provincia WHERE Nombre = N'Córdoba'), N'Aprobada');
INSERT INTO dbo.OfertaLaboral (IDEmpresa, Titulo, Descripcion, Modalidad, Tipo_Contrato, Cantidad_Puestos, Fecha_Publicacion, Fecha_Cierre, IDProvincia, Estado_Publicacion)
OUTPUT N'mozo', INSERTED.ID INTO @Ofertas
VALUES (@Cafe, N'Mozo/a de salón', N'Atención de mesas en el salón.', N'Presencial', N'Medio tiempo', 1, DATEADD(DAY, -10, @Hoy), NULL, (SELECT ID FROM dbo.Provincia WHERE Nombre = N'Córdoba'), N'Aprobada');
INSERT INTO dbo.OfertaLaboral (IDEmpresa, Titulo, Descripcion, Modalidad, Tipo_Contrato, Cantidad_Puestos, Fecha_Publicacion, Fecha_Cierre, IDProvincia, Estado_Publicacion)
OUTPUT N'cocina', INSERTED.ID INTO @Ofertas
VALUES (@Cafe, N'Ayudante de cocina', N'Preparación de platos y limpieza de la cocina.', N'Presencial', N'Tiempo completo', 1, DATEADD(DAY, -3, @Hoy), NULL, (SELECT ID FROM dbo.Provincia WHERE Nombre = N'Córdoba'), N'Aprobada');
INSERT INTO dbo.OfertaLaboral (IDEmpresa, Titulo, Descripcion, Modalidad, Tipo_Contrato, Cantidad_Puestos, Fecha_Publicacion, Fecha_Cierre, IDProvincia, Estado_Publicacion)
OUTPUT N'deposito', INSERTED.ID INTO @Ofertas
VALUES (@Logistica, N'Operario de depósito turno mañana', N'Carga, descarga y control de stock.', N'Presencial', N'Tiempo completo', 3, DATEADD(DAY, -40, @Hoy), DATEADD(DAY, -5, @Hoy), (SELECT ID FROM dbo.Provincia WHERE Nombre = N'Buenos Aires'), N'Aprobada');
INSERT INTO dbo.OfertaLaboral (IDEmpresa, Titulo, Descripcion, Modalidad, Tipo_Contrato, Cantidad_Puestos, Fecha_Publicacion, Fecha_Cierre, IDProvincia, Estado_Publicacion)
OUTPUT N'chofer', INSERTED.ID INTO @Ofertas
VALUES (@Logistica, N'Chofer de reparto', N'Reparto de mercadería en zona norte.', N'Presencial', N'Tiempo completo', 1, DATEADD(DAY, -12, @Hoy), NULL, (SELECT ID FROM dbo.Provincia WHERE Nombre = N'Buenos Aires'), N'Aprobada');
INSERT INTO dbo.OfertaLaboral (IDEmpresa, Titulo, Descripcion, Modalidad, Tipo_Contrato, Cantidad_Puestos, Fecha_Publicacion, Fecha_Cierre, IDProvincia, Estado_Publicacion)
OUTPUT N'dotnet', INSERTED.ID INTO @Ofertas
VALUES (@Sistemas, N'Desarrollador/a .NET Jr', N'Desarrollo de aplicaciones web con C# y SQL Server.', N'Remoto', N'Tiempo completo', 1, DATEADD(DAY, -15, @Hoy), DATEADD(DAY, 15, @Hoy), (SELECT ID FROM dbo.Provincia WHERE Nombre = N'Ciudad Autónoma de Buenos Aires'), N'Aprobada');
INSERT INTO dbo.OfertaLaboral (IDEmpresa, Titulo, Descripcion, Modalidad, Tipo_Contrato, Cantidad_Puestos, Fecha_Publicacion, Fecha_Cierre, IDProvincia, Estado_Publicacion, IDUsuario_Publicador)
OUTPUT N'soporte', INSERTED.ID INTO @Ofertas
VALUES (@Sistemas, N'Soporte técnico', N'Atención de incidentes de usuarios.', N'Híbrido', N'Tiempo completo', 1, DATEADD(DAY, -1, @Hoy), NULL, (SELECT ID FROM dbo.Provincia WHERE Nombre = N'Ciudad Autónoma de Buenos Aires'), N'Pendiente', @UsuarioEmpresa);

DECLARE @OBarista INT = (SELECT ID FROM @Ofertas WHERE Clave = N'barista');
DECLARE @OMozo INT = (SELECT ID FROM @Ofertas WHERE Clave = N'mozo');
DECLARE @OCocina INT = (SELECT ID FROM @Ofertas WHERE Clave = N'cocina');
DECLARE @ODeposito INT = (SELECT ID FROM @Ofertas WHERE Clave = N'deposito');
DECLARE @OChofer INT = (SELECT ID FROM @Ofertas WHERE Clave = N'chofer');
DECLARE @ODotnet INT = (SELECT ID FROM @Ofertas WHERE Clave = N'dotnet');
DECLARE @OSoporte INT = (SELECT ID FROM @Ofertas WHERE Clave = N'soporte');

INSERT INTO dbo.OfertaPuesto (IDOfertaLaboral, IDPuesto)
SELECT o.ID, p.ID
FROM (VALUES (N'barista', N'barista'), (N'mozo', N'sinsector'), (N'cocina', N'barista'), (N'deposito', N'deposito'), (N'dotnet', N'dotnet'), (N'soporte', N'dotnet')) AS d (Oferta, Puesto)
JOIN @Ofertas AS o ON o.Clave = d.Oferta
JOIN @Puestos AS p ON p.Clave = d.Puesto;

INSERT INTO dbo.Postulacion (IDUsuario, IDOfertaLaboral, Fecha, Estado)
SELECT u.ID, o.ID, DATEADD(DAY, -d.Dias, @Hoy), d.Estado
FROM (VALUES
    (N'lucia', N'barista', 18, N'Pasé'), (N'martin', N'barista', 17, N'En revisión'), (N'sofia', N'barista', 15, N'Enviada'),
    (N'diego', N'barista', 14, N'No pasé'), (N'valentina', N'barista', 12, N'Pasé'),
    (N'lucia', N'mozo', 8, N'Enviada'),
    (N'martin', N'deposito', 35, N'Pasé'), (N'diego', N'deposito', 33, N'Pasé'), (N'tomas', N'deposito', 30, N'No pasé'), (N'sofia', N'deposito', 28, N'Enviada'),
    (N'diego', N'chofer', 10, N'Enviada'),
    (N'valentina', N'dotnet', 12, N'Pasé'), (N'tomas', N'dotnet', 11, N'En revisión'), (N'lucia', N'dotnet', 9, N'No pasé')
) AS d (Usuario, Oferta, Dias, Estado)
JOIN @Usuarios AS u ON u.Clave = d.Usuario
JOIN @Ofertas AS o ON o.Clave = d.Oferta;

DECLARE @Externa INT = (SELECT TOP (1) ID FROM dbo.OfertaExterna ORDER BY ID);
DECLARE @Guardados TABLE (Usuario INT, OfertaLaboral INT NULL, OfertaExterna INT NULL);
INSERT INTO @Guardados (Usuario, OfertaLaboral, OfertaExterna) VALUES
    (@Lucia, @OBarista, NULL), (@Martin, @OBarista, NULL), (@Tomas, @OBarista, NULL), (@Sofia, @OBarista, NULL),
    (@Lucia, @ODotnet, NULL), (@Martin, @ODotnet, NULL), (@Martin, @ODotnet, NULL), (@Sofia, @ODotnet, NULL),
    (@Diego, NULL, @Externa), (@Valentina, NULL, @Externa), (@Tomas, NULL, @Externa);

DECLARE @Usuario INT, @OfertaLaboral INT, @OfertaExterna INT;
DECLARE guardados CURSOR LOCAL FAST_FORWARD FOR
    SELECT Usuario, OfertaLaboral, OfertaExterna FROM @Guardados WHERE OfertaLaboral IS NOT NULL OR OfertaExterna IS NOT NULL;
OPEN guardados;
FETCH NEXT FROM guardados INTO @Usuario, @OfertaLaboral, @OfertaExterna;
WHILE @@FETCH_STATUS = 0
BEGIN
    INSERT INTO dbo.Favorito (IDUsuario, fecha_guardado) VALUES (@Usuario, @Hoy);
    INSERT INTO dbo.FavoritoOferta (IDFavorito, IDOfertaLaboral, IDOfertaExterna) VALUES (SCOPE_IDENTITY(), @OfertaLaboral, @OfertaExterna);
    FETCH NEXT FROM guardados INTO @Usuario, @OfertaLaboral, @OfertaExterna;
END
CLOSE guardados;
DEALLOCATE guardados;

IF @Externa IS NOT NULL
    INSERT INTO dbo.Postulacion (IDUsuario, IDOfertaExterna, Fecha, Estado) VALUES (@Diego, @Externa, @Hoy, N'Enviada');

DECLARE @OfertasSobrePromedio INT;

PRINT N'===== Consigna 1: empresa con ofertas =====';
EXEC dbo.EstadisticasPostulacionesEmpresa @IDEmpresa = @Cafe, @OfertasSobrePromedio = @OfertasSobrePromedio OUTPUT;
SELECT @OfertasSobrePromedio AS ValorDelParametroDeSalida;
PRINT N'===== Consigna 1: empresa sin ofertas =====';
EXEC dbo.EstadisticasPostulacionesEmpresa @IDEmpresa = @SinOfertas;
PRINT N'===== Consigna 1: empresa inexistente =====';
EXEC dbo.EstadisticasPostulacionesEmpresa @IDEmpresa = -1;

PRINT N'===== Consigna 2: oferta con postulaciones =====';
EXEC dbo.RankingCandidatosPorHabilidades @IDOfertaLaboral = @OBarista;
PRINT N'===== Consigna 2: oferta con un puesto sin sector =====';
EXEC dbo.RankingCandidatosPorHabilidades @IDOfertaLaboral = @OMozo;
PRINT N'===== Consigna 2: oferta sin puestos =====';
EXEC dbo.RankingCandidatosPorHabilidades @IDOfertaLaboral = @OChofer;
PRINT N'===== Consigna 2: oferta inexistente =====';
EXEC dbo.RankingCandidatosPorHabilidades @IDOfertaLaboral = -1;

PRINT N'===== Consigna 3: mínimo de 4 postulaciones =====';
EXEC dbo.CompararSeleccionEmpresas @MinimoPostulaciones = 4;
PRINT N'===== Consigna 3: mínimo de 50 postulaciones =====';
EXEC dbo.CompararSeleccionEmpresas @MinimoPostulaciones = 50;
PRINT N'===== Consigna 3: mínimo inválido =====';
EXEC dbo.CompararSeleccionEmpresas @MinimoPostulaciones = 0;

PRINT N'===== Consigna 4: mínimo de 3 favoritos =====';
EXEC dbo.OfertasFavoritasSinPostulacion @MinimoFavoritos = 3;
PRINT N'===== Consigna 4: mínimo de 10 favoritos =====';
EXEC dbo.OfertasFavoritasSinPostulacion @MinimoFavoritos = 10;
PRINT N'===== Consigna 4: mínimo inválido =====';
EXEC dbo.OfertasFavoritasSinPostulacion @MinimoFavoritos = 0;

PRINT N'===== Consigna 5: oferta vigente con postulaciones =====';
EXEC dbo.DiagnosticoOferta @IDOfertaLaboral = @OBarista;
PRINT N'===== Consigna 5: oferta cerrada con postulaciones =====';
EXEC dbo.DiagnosticoOferta @IDOfertaLaboral = @ODeposito;
PRINT N'===== Consigna 5: oferta sin postulaciones =====';
EXEC dbo.DiagnosticoOferta @IDOfertaLaboral = @OCocina;
PRINT N'===== Consigna 5: oferta en revisión =====';
EXEC dbo.DiagnosticoOferta @IDOfertaLaboral = @OSoporte;
PRINT N'===== Consigna 5: oferta inexistente =====';
EXEC dbo.DiagnosticoOferta @IDOfertaLaboral = -1;

PRINT N'===== Consigna adicional: persona con perfil completo =====';
EXEC dbo.RecomendarOfertasParaUsuario @IDUsuario = @Lucia, @Cantidad = 5;
PRINT N'===== Consigna adicional: persona sin coincidencias =====';
EXEC dbo.RecomendarOfertasParaUsuario @IDUsuario = @Tomas;
PRINT N'===== Consigna adicional: persona sin datos en el perfil =====';
EXEC dbo.RecomendarOfertasParaUsuario @IDUsuario = @Vacio;
PRINT N'===== Consigna adicional: cuenta de empresa =====';
EXEC dbo.RecomendarOfertasParaUsuario @IDUsuario = @UsuarioEmpresa;
PRINT N'===== Consigna adicional: cantidad inválida =====';
EXEC dbo.RecomendarOfertasParaUsuario @IDUsuario = @Lucia, @Cantidad = 0;

ROLLBACK TRANSACTION;
GO
