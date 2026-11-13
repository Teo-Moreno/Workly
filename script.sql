USE [master]
GO
CREATE DATABASE [Workly]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'Workly', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Workly.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'Workly_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\Workly_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [Workly] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [Workly].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [Workly] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [Workly] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [Workly] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [Workly] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [Workly] SET ARITHABORT OFF 
GO
ALTER DATABASE [Workly] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [Workly] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [Workly] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [Workly] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [Workly] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [Workly] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [Workly] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [Workly] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [Workly] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [Workly] SET  ENABLE_BROKER 
GO
ALTER DATABASE [Workly] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [Workly] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [Workly] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [Workly] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [Workly] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [Workly] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [Workly] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [Workly] SET RECOVERY FULL 
GO
ALTER DATABASE [Workly] SET  MULTI_USER 
GO
ALTER DATABASE [Workly] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [Workly] SET DB_CHAINING OFF 
GO
ALTER DATABASE [Workly] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [Workly] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [Workly] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'Workly', N'ON'
GO
ALTER DATABASE [Workly] SET QUERY_STORE = OFF
GO
USE [Workly]
GO
CREATE USER [alumno] FOR LOGIN [alumno] WITH DEFAULT_SCHEMA=[dbo]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CV](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Nombre_Archivo] [nvarchar](260) NULL,
	[Sitio_Web] [nvarchar](200) NULL,
	[Fecha_Actualizacion] [date] NOT NULL,
 CONSTRAINT [PK_CV] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Educacion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Institucion] [nvarchar](150) NOT NULL,
	[Descripcion] [nvarchar](300) NULL,
 CONSTRAINT [PK_Educacion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Empresa](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](100) NOT NULL,
	[Descripcion] [nvarchar](500) NULL,
	[Logo] [nvarchar](260) NULL,
	[Ubicacion] [nvarchar](100) NULL,
	[Sitio_Web] [nvarchar](200) NULL,
	[IDUsuario] [int] NULL,
	[Razon_Social] [nvarchar](150) NULL,
	[CUIT] [char](11) NULL,
	[Rubro] [nvarchar](60) NULL,
	[IDProvincia] [int] NULL,
	[Telefono] [nvarchar](30) NULL,
	[Fecha_Registro] [date] NOT NULL,
 CONSTRAINT [PK_Empresa] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ExperienciaLaboral](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDEmpresa] [int] NOT NULL,
	[Puesto] [nvarchar](100) NOT NULL,
	[Descripcion] [nvarchar](500) NULL,
	[Fecha_Inicio] [date] NOT NULL,
	[Fecha_Finalizacion] [date] NULL,
 CONSTRAINT [PK_ExperienciaLaboral] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Favorito](
	[ID_favorito] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[fecha_guardado] [date] NOT NULL,
 CONSTRAINT [PK_Favorito] PRIMARY KEY CLUSTERED 
(
	[ID_favorito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FavoritoOferta](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDFavorito] [int] NOT NULL,
	[IDOfertaLaboral] [int] NULL,
	[IDOfertaExterna] [int] NULL,
 CONSTRAINT [PK_FavoritoOferta] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Habilidad](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](60) NOT NULL,
	[IDSector] [int] NULL,
 CONSTRAINT [PK_Habilidad] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Idioma](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_Idioma] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoginExterno](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Proveedor] [nvarchar](20) NOT NULL,
	[ID_Externo] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_LoginExterno] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OfertaExterna](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ID_Externo] [nvarchar](200) NOT NULL,
	[Titulo] [nvarchar](300) NOT NULL,
	[Empresa] [nvarchar](200) NULL,
	[Logo] [nvarchar](1000) NULL,
	[Ubicacion] [nvarchar](200) NULL,
	[Descripcion] [nvarchar](max) NULL,
	[Es_Remoto] [bit] NOT NULL,
	[Tipo_Contrato] [nvarchar](50) NULL,
	[Salario] [nvarchar](100) NULL,
	[Link_Postulacion] [nvarchar](2000) NULL,
	[Publicador] [nvarchar](100) NULL,
	[Fecha_Publicacion] [datetime2](7) NULL,
	[Fecha_Consulta] [datetime2](7) NOT NULL,
 CONSTRAINT [PK_OfertaExterna] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OfertaLaboral](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDEmpresa] [int] NOT NULL,
	[Titulo] [nvarchar](150) NOT NULL,
	[Descripcion] [nvarchar](2000) NULL,
	[Ubicacion] [nvarchar](100) NULL,
	[Modalidad] [nvarchar](20) NOT NULL,
	[Tipo_Contrato] [nvarchar](50) NOT NULL,
	[Salario] [int] NULL,
	[Cantidad_Puestos] [int] NOT NULL,
	[Fecha_Publicacion] [date] NOT NULL,
	[Fecha_Cierre] [date] NULL,
	[IDUsuario_Publicador] [int] NULL,
	[IDProvincia] [int] NULL,
	[Estado_Publicacion] [nvarchar](20) NOT NULL,
	[Motivo_Rechazo] [nvarchar](500) NULL,
	[Fecha_Revision] [date] NULL,
 CONSTRAINT [PK_OfertaLaboral] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OfertaPuesto](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDOfertaLaboral] [int] NOT NULL,
	[IDPuesto] [int] NOT NULL,
 CONSTRAINT [PK_OfertaPuesto] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Pais](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](60) NOT NULL,
	[Codigo_ISO] [char](2) NOT NULL,
	[Codigo_Telefono] [nvarchar](5) NOT NULL,
 CONSTRAINT [PK_Pais] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Perfil](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDProvincia] [int] NULL,
	[Foto] [nvarchar](260) NULL,
	[Descripcion] [nvarchar](500) NULL,
	[Telefono] [nvarchar](30) NULL,
	[Estado_Busqueda] [nvarchar](30) NULL,
 CONSTRAINT [PK_Perfil] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Postulacion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDOfertaLaboral] [int] NULL,
	[IDOfertaExterna] [int] NULL,
	[Fecha] [date] NOT NULL,
	[Estado] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_Postulacion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Preferencia](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Puesto_Buscado] [nvarchar](100) NULL,
	[Niveles] [nvarchar](100) NULL,
	[Modalidades] [nvarchar](60) NULL,
	[Jornada] [nvarchar](20) NULL,
	[Contratacion] [nvarchar](40) NULL,
	[IDProvincia] [int] NULL,
	[Salario_Minimo] [int] NULL,
	[Salario_Maximo] [int] NULL,
	[Disponibilidad] [nvarchar](20) NULL,
 CONSTRAINT [PK_Preferencia] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Provincia](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDPais] [int] NOT NULL,
	[Nombre] [nvarchar](80) NOT NULL,
 CONSTRAINT [PK_Provincia] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Puesto](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](100) NOT NULL,
	[Descripcion] [nvarchar](300) NULL,
	[IDSector] [int] NULL,
 CONSTRAINT [PK_Puesto] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RecuperacionClave](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[Token_Hash] [char](64) NOT NULL,
	[Fecha] [datetime2](0) NOT NULL,
	[Vence] [datetime2](0) NOT NULL,
	[Usada] [bit] NOT NULL,
 CONSTRAINT [PK_RecuperacionClave] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sector](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](60) NOT NULL,
	[Orden] [int] NOT NULL,
 CONSTRAINT [PK_Sector] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Usuario](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [nvarchar](50) NOT NULL,
	[Apellido] [nvarchar](50) NOT NULL,
	[Email] [nvarchar](100) NOT NULL,
	[Contraseña] [nvarchar](200) NULL,
	[Fecha_Registro] [date] NOT NULL,
	[Tipo] [nvarchar](10) NOT NULL,
	[Es_Moderador] [bit] NOT NULL,
 CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsuarioEducacion](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDEducacion] [int] NOT NULL,
	[Titulo] [nvarchar](150) NOT NULL,
	[Fecha_Inicio] [date] NOT NULL,
	[Fecha_Fin] [date] NULL,
 CONSTRAINT [PK_UsuarioEducacion] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsuarioHabilidad](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDHabilidad] [int] NOT NULL,
 CONSTRAINT [PK_UsuarioHabilidad] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UsuarioIdioma](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[IDUsuario] [int] NOT NULL,
	[IDIdioma] [int] NOT NULL,
	[Nivel] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_UsuarioIdioma] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Habilidad] ON 

INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (1, N'Comunicación', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (2, N'Trabajo en equipo', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (3, N'Liderazgo', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (4, N'Organización', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (5, N'Resolución de problemas', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (6, N'Gestión de proyectos', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (7, N'Gestión del tiempo', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (8, N'Adaptabilidad', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (9, N'Pensamiento crítico', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (10, N'Atención al detalle', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (11, N'Programación', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (12, N'HTML', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (13, N'CSS', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (14, N'JavaScript', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (15, N'TypeScript', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (16, N'React', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (17, N'C#', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (18, N'.NET', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (19, N'Java', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (20, N'Python', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (21, N'SQL', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (22, N'Git', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (23, N'Soporte técnico', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (24, N'Redes informáticas', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (25, N'Ciberseguridad', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (26, N'Testing de software', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (27, N'Análisis de datos', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (28, N'Power BI', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (29, N'Tableau', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (30, N'Estadística', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (31, N'Machine learning', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (32, N'Excel avanzado', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (33, N'Administración', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (34, N'Contabilidad', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (35, N'Excel', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (36, N'Microsoft Office', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (37, N'Google Workspace', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (38, N'Facturación', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (39, N'Liquidación de sueldos', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (40, N'Tesorería', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (41, N'Impuestos', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (42, N'Cuentas a pagar y cobrar', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (43, N'Ventas', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (44, N'Atención al cliente', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (45, N'Negociación', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (46, N'Venta telefónica', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (47, N'Caja', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (48, N'Postventa', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (49, N'Manejo de CRM', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (50, N'Marketing digital', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (51, N'Redes sociales', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (52, N'Redacción', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (53, N'SEO', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (54, N'Publicidad', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (55, N'Comunicación institucional', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (56, N'Fotografía', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (57, N'Diseño gráfico', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (58, N'Figma', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (59, N'Photoshop', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (60, N'Illustrator', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (61, N'Diseño UX/UI', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (62, N'Edición de video', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (63, N'Logística', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (64, N'Manejo de stock', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (65, N'Depósito', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (66, N'Compras', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (67, N'Comercio exterior', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (68, N'Manejo de autoelevador', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (69, N'Distribución', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (70, N'Cocina', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (71, N'Atención en salón', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (72, N'Barista', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (73, N'Pastelería', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (74, N'Manipulación de alimentos', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (75, N'Recepción hotelera', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (76, N'Housekeeping', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (77, N'Enfermería', 10)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (78, N'Primeros auxilios', 10)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (79, N'Cuidado de adultos mayores', 10)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (80, N'Atención en farmacia', 10)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (81, N'Administración de turnos médicos', 10)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (82, N'Docencia', 11)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (83, N'Clases particulares', 11)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (84, N'Planificación educativa', 11)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (85, N'Acompañamiento terapéutico', 11)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (86, N'Cuidado de niños', 11)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (87, N'Electricidad', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (88, N'Plomería', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (89, N'Albañilería', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (90, N'Carpintería', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (91, N'Pintura', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (92, N'Soldadura', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (93, N'Mecánica', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (94, N'Lectura de planos', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (95, N'Recursos humanos', 13)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (96, N'Selección de personal', 13)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (97, N'Capacitación', 13)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (98, N'Relaciones laborales', 13)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (99, N'Administración de personal', 13)
GO
SET IDENTITY_INSERT [dbo].[Habilidad] OFF
GO
SET IDENTITY_INSERT [dbo].[Idioma] ON 

INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (6, N'Alemán')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (7, N'Chino mandarín')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (1, N'Español')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (4, N'Francés')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (2, N'Inglés')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (5, N'Italiano')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (8, N'Japonés')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (9, N'Lengua de señas argentina')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (3, N'Portugués')
SET IDENTITY_INSERT [dbo].[Idioma] OFF
GO
SET IDENTITY_INSERT [dbo].[OfertaExterna] ON 

INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (1, N'ejhkcDhESVBDLWY3a0pldkFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXa2x1VEZsNU5sOTRUR3RwVW1oU2NXUnBlRVJWVG1kdE5XTnliWGRIUlc1SExVVTFZVmt6VUVwNk9GcGlhak5LYUZCWVRVOHhSSFJ6Yms1bFEyVmFRa1pmWW1sME5FTnlTVEl0U25kU1VXbzNk', N'Administrativo/a de Logística', N'TRANSENER', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSXllHSy346PnyDKXDVKYOOGcWuq5BK1-_vQLOj&s=0', N'Marcos Paz, Provincia de Buenos Aires', N'Transener busca una persona para administrar el almacén de indumentaria y elementos de protección personal: control de stock, entregas al personal, envíos a las regionales e imputación contable. Requisitos: más de 5 años de experiencia en logística o inventarios, formación en Logística o Administración, manejo de SAP MM y Google Workspace, y licencia de conducir.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/administrativo-a-de-log%C3%ADstica-at-transener-4484361618', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.0932226' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (2, N'eFNxT3lDTkhhWjR0VHFnaEFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZa3d3WjJFd2VXTnplR1V5YW5od1ZtRlpjVU5uYzFSR05FeE9SVGhoVDNScU9YZFlPVGhhY0U0eFRFNTJXRVV4ZUc5WE1WQmFPR2g2VWxGeFVuaFpiVVpJUVV0c1ZVRjZPRXBqVjFsdWQxODNR', N'Recepcionista Eventual por 4 días URGENTE', N'ADECCO RECURSOS HUMANOS ARGENTINA SA', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQh8_Rq6W3dV5r8ujCZVWMA9egqYSIsod-X5dgx&s=0', N'Cdad. Autónoma de Buenos Aires', N'Cobertura de una licencia en la recepción de una empresa multinacional del Microcentro, los días 4, 5, 6, 12 y 13 de noviembre. Tareas: atender llamadas y visitas, organizar pedidos para reuniones y dar apoyo administrativo. De lunes a viernes de 8:30 a 17:30, presencial, con almuerzo y reintegro de transporte.', 0, NULL, NULL, N'https://www.bumeran.com.ar/empleos/recepcionista-eventual-por-4-dias-urgente-adecco-recursos-humanos-argentina-sa-1118503440.html', N'Bumeran', NULL, CAST(N'2026-11-02T18:54:49.0957020' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (3, N'NjNwQi1JRmV2SmRtSjY0NUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZbUZRV0ZwSWJ6WlBaV1JJZEdoM01FSmlabXhUWHpCRU0wWnNVMVZCU21ObkxVcG9ZbTlhTm5KbWMwMUpSSEZzZEdkR00zWnZSRWRUU2pKcFJ6Wm9lR0pCZWpWbVpURnNNRWQyTWxSTFlXMW5V', N'Analista de cuentas a pagar', N'Importante Empresa de Servicios', NULL, N'Vicente López, Provincia de Buenos Aires', N'Empresa de servicios busca analista para conciliar cuentas corrientes, registrar comprobantes, controlar vencimientos y pagos, y mantener el contacto con proveedores. Requisitos: estudiante o graduado de Ciencias Económicas, al menos 2 años de experiencia en puestos similares y Excel avanzado.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/analista-de-cuentas-a-pagar-at-importante-empresa-de-servicios-4485427678', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.0961974' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (4, N'b3NIeWk2TzdncWdiR0pzX0FBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZV3hOU0dsTWJqWnRiWGRZWjA5Vk1qSkpkekp4TkV3eFVFdFNUVFUxY25WQ2R5MHhkRXRFZVVGelZUQkRTbGxLYlZrMFZWVnBUekJ3UW14a2FVVlBYMHRYT1hWbVNYWXdVbW8yUTIxS2JYUTJk', N'Ejecutivo Comercial Senior (Mendoza)', N'Aprile - International Freight Forwarding', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFAsS7XQwE4nx2GDHGZFcHHt9CkSOH3wh4YJ7i&s=0', N'Mendoza, Capital, Mendoza', N'Aprile, empresa de logística internacional, busca un ejecutivo comercial en Mendoza para vender servicios de transporte marítimo y aéreo, conseguir clientes nuevos y atender la cartera actual. Requisitos: 3 años de experiencia en ventas de freight forwarding, inglés avanzado, licencia de conducir y vivir en Mendoza o cerca. Presencial, tiempo completo.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/ejecutivo-comercial-senior-mendoza-at-aprile-international-freight-forwarding-4486422288', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.0961974' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (5, N'SlNUMG55VFFOU2EtNFdTaUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZVEpxVUdGMVgzVm1ZWEJxZFVSMldXWkVkMWhHYlc5bFozVkhTMGxZTjNWTlFsVkVTamh6TVZnNVh6TkxiSFpuT0ZWRFEzcERURkozVFRWcGRHNUdSV3QyVkRSbFpERTNaMlpCVlZkRlYwUnpl', N'Gerente de desarrollo de productos electrónicos (Oil and Gas)', N'DG Consultores en Recursos Humanos', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxFXIYFknMiu5jj9hE-wOchxI0dJsxUmfnBwxe&s=0', N'Vicente López, Provincia de Buenos Aires', N'Grupo vinculado al Oil & Gas busca un gerente para liderar el área de ingeniería electrónica: definir el hardware y el firmware de los productos nuevos, coordinar al equipo y supervisar el diseño, las pruebas y la certificación. Requisitos: ingeniería electrónica, más de 10 años desarrollando productos electrónicos, 3 años liderando equipos e inglés técnico avanzado.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/gerente-de-desarrollo-de-productos-electr%C3%B3nicos-oil-and-gas-at-dg-consultores-en-recursos-humanos-4485426369', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.0996740' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (6, N'R1E1SllPNENMb3VKY1BzTkFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXWEJ1UTFaUGEzRmZjMGhhU1MxclZVZ3lWSFF5T1U5Rk5YSTNhMHRJZVZsdU5GaDRURXByUWkwM2FXTndTMUJRTmpnM1ZYaERVbU15UW1KZlMwSnFNRGxQWlRKT2EzZGxkVFJWZFdwd1R6bDFX', N'Personal Gastronómico - (Eventual)', N'ManpowerGroup', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRiyJmq5O0fdRv1Fr-yBokGHiL-IgAunmtGXJI1&s=0', N'Argentina', N'ManpowerGroup busca ayudantes y peones de cocina, camareros y bacheros para eventos y servicios gastronómicos en CABA y GBA. Tareas: preparar alimentos, lavar vajilla y mantener la limpieza. Requisitos: experiencia en gastronomía y disponibilidad los fines de semana y feriados. Trabajo eventual por convocatoria, con incorporación inmediata.', 0, N'Tiempo completo', NULL, N'https://ar.computrabajo.com/ofertas-de-trabajo/oferta-de-trabajo-de-personal-gastronomico-eventual-en-gral-pacheco-6E834741E18252C461373E686DCF3405', N'Computrabajo', NULL, CAST(N'2026-11-02T18:54:49.0996740' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (7, N'VnNNMHRyemVtemU1aFBla0FBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXamR0VDJnM1FrYzRNbVZ0YTJGVmFGRnJja3BtU25kTFYxQkthVE40UjBwTFFWVkljSFZvVUhWSWVrRXdaRE41TTNabmNVMDVaSEY0Y2pZM1RHVXRkVmg0WlhWQlNXMXRRVWh2YmpsT1RWVXhU', N'Analista de créditos y cobranzas (villa ballester)', N'ADECCO RECURSOS HUMANOS ARGENTINA SA', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQh8_Rq6W3dV5r8ujCZVWMA9egqYSIsod-X5dgx&s=0', N'Villa Ballester, Provincia de Buenos Aires', N'Empresa multinacional de codificadoras industriales busca analista para evaluar clientes, definir límites de crédito, seguir la cobranza y coordinar con Ventas y Finanzas. Requisitos: formación en Finanzas, Contabilidad o afines, 2 a 3 años de experiencia en créditos y cobranzas, manejo de SAP u Oracle y Excel avanzado. Modalidad híbrida en Villa Ballester.', 0, NULL, NULL, N'https://www.bumeran.com.ar/empleos/analista-de-creditos-y-cobranzas-villa-ballester-adecco-recursos-humanos-argentina-sa-1118504144.html', N'Bumeran', NULL, CAST(N'2026-11-02T18:54:49.1001667' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (8, N'bHJidTVlbzM4V0ZMVExUZUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZbEF3U25GemJHeFJiMUowUlRGQldHTXdhMUpIUW5nemNrbEJTVWxGZEd4VGIwOTJURlZ1VDNKZlJucEJkR00wYkVKaE1tWjRORUZFYlRoVk0zSnFWVTEwTkU1RE9GaHdVWGxZY25SYVQwUnJT', N'Especialista de Negocio Regional - Fintech', N'Mercado Libre', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwDeXMJxI8Yx6rEIMJMwhqmxMe6Qu40Zefb9il&s=0', N'Argentina', N'Mercado Libre busca un especialista para mejorar la propuesta de Mercado Pago para grandes clientes de la región: definir funciones nuevas, simplificar procesos, armar la estrategia para vendedores globales y coordinar proyectos con otras áreas. Requisitos: título en Ingeniería Industrial, Ciencias Económicas o afines y 5 años de experiencia en desarrollo de negocio, consultoría o producto.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/especialista-de-negocio-regional-fintech-at-mercado-libre-4483487916', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.1001667' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (9, N'MUlkdGxDNkxFM2VGMnE0OUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZWGhLZWxwd1dIcHpTRjlDYkRWNldtRmtjamR4UzJkT1JISkdXa0YwY1dOWWNVd3phR2hNU0ZjNVJuRnNiRmRoTm5OWVIyZHlaMjVLYkU5dVNISjZWMlZuUm1aalgzaHhhWGRSUVd0MFlXWkpM', N'Comercial ganadería (balanceado) / Córdoba interior', N'Adecco', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKw7I3cUDxV8G7zkgfWA6kVY5ONY2PQGtCCEQo&s=0', N'Argentina', N'Se busca vendedor de alimentos balanceados para ganado que recorra el interior de Córdoba, atienda la cartera de clientes y sume productores nuevos. Requisitos: experiencia en nutrición animal o venta de balanceados, conocimiento del sector ganadero y movilidad propia. De lunes a viernes de 8 a 17, por monotributo, con sueldo asegurado los primeros 3 meses y después comisiones.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/comercial-ganader%C3%ADa-balanceado-c%C3%B3rdoba-interior-at-adecco-4483993951', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.1001667' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (10, N'Rk1feXpudjVqV2I0V3VzOUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZUzB0U1ZWM1EySnBWa0kxU21NeVNIcFVWSFZNWmpaSGJYSk9Wa1V3TFdsRWJXeFpWSGRuYkZWdFRYSjJZa0psTm5KNFMzUnVSbmhQV0dOSFJWSTVVMnAyVVhGa1VtZEpVRGxCYVVzd1VWQlhV', N'EJECUTIVO/A DE VENTAS TERRITORIALES (Corrientes)', N'ADECCO RECURSOS HUMANOS ARGENTINA SA', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQh8_Rq6W3dV5r8ujCZVWMA9egqYSIsod-X5dgx&s=0', N'Posadas, Misiones', N'Adecco busca ejecutivos de ventas para Mercado Pago en Corrientes: sumar comercios que cobren con QR y Point, capacitarlos y atender su cartera con llamadas y visitas. Requisitos: experiencia en ventas de campo y secundario completo. Modalidad híbrida, de lunes a viernes de 9 a 18, con sueldo, comisiones, viáticos y cobertura médica.', 0, N'Tiempo completo', NULL, N'https://www.bumeran.com.ar/empleos/ejecutivo-a-de-ventas-territoriales-corrientes-adecco-recursos-humanos-argentina-sa-1118502690.html', N'Bumeran', NULL, CAST(N'2026-11-02T18:54:49.1006623' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (11, N'eFpHSWpkNDl1U0NRbS1ULUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZbUV4WDB4UlFqWldOV293UVdWTWFXdEJWa2d0WlhKTk16RmhhVWgzYmxoMGQxSnVhelkwVVRoMVUzRnlVbUpKZVd0aWExUkVRVkF3T0VWcGVYSnBZMnBRYmpGdFdGQnlaa3hzTkdwbWEwd3hi', N'Asesor Comercial Rosario : Sueldo fijo + comisiones sin tope + beneficios - Sueldo fijo + comisiones sin tope + beneficios', N'Verisure Argentina', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGQVHCl0Fn59Ff-wM9v1hqz-P633PN9D6bC83G&s=0', N'Rosario, Santa Fe', N'Verisure, empresa de alarmas monitoreadas, busca asesores comerciales en Rosario para visitar a los clientes que agenda el call center y cerrar las ventas. Requisitos: secundario completo y movilidad propia. Ofrece sueldo fijo más comisiones sin tope, combustible y capacitación en ventas.', 0, N'Tiempo completo', NULL, N'https://ar.computrabajo.com/ofertas-de-trabajo/oferta-de-trabajo-de-asesor-comercial-rosario-sueldo-fijo-comisiones-sin-tope-beneficios-sueldo-fijo-comisiones-sin-tope-beneficios-en-rosario-AFC6D80D7BDE807C61373E686DCF3405', N'Computrabajo', NULL, CAST(N'2026-11-02T18:55:51.0073695' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (12, N'NUloMk5UT3pfOFluMlVBYkFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXbEZ6YkU0MFVUTmFORzVrVEROM05tZGZkRTFYUkVwV2NtTnRTemt4VURGb1JrRTVWblkzUzJweFNFeEJSMmxoWjA0NU1sWjBTMHRvYlhFMGQwcEhXbVEzZFhGamFFZE9hMHBzVmxoRE4xRlhT', N'Enfermera titulada', N'Centro Médico Zona Norte Córdoba', N'https://t0.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=https://centromedico.com&size=128', N'Córdoba', N'Centro médico de la zona norte de Córdoba capital busca enfermero o enfermera para atender pacientes, colocar vías y acompañar tratamientos en cámara hiperbárica. Requisitos: título de técnico o licenciado en Enfermería y experiencia en instituciones de salud. Jornada de 8 horas, presencial, con ingreso inmediato.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/enfermera-titulada-at-centro-m%C3%A9dico-zona-norte-c%C3%B3rdoba-4484360219', N'LinkedIn', NULL, CAST(N'2026-11-02T18:55:51.0078660' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (13, N'VHBJTE1XVEs5VHZ6Yi1rM0FBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXbEJVV25RMldFVlJZbVpQYTJGaFREUnplWEl0WW5Gb2N5MXVTMkZFVW14WmIyUnhiVFJ6YWpsdVpVUTBkVzA1TjB4Qk5YWXlTblUxV0hkbVZsbHhUWEJZT1VFdGFsbzVObFpIVUdweFpqRkJY', N'AI Editor', N'WPP Production', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1hUeR0WJwVpazb9dNqJYfa7_MZbwGw9wAr8cJ&s=0', N'Cdad. Autónoma de Buenos Aires', N'WPP Production busca un editor audiovisual para crear y adaptar piezas publicitarias con herramientas de inteligencia artificial, motion graphics y efectos visuales. Requisitos: experiencia como editor, manejo de Premiere, After Effects y Photoshop, uso de herramientas como Runway o MidJourney, y español e inglés. Modalidad híbrida, unos 4 días por semana en la oficina de CABA.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/ai-editor-at-wpp-production-4485247357', N'LinkedIn', NULL, CAST(N'2026-11-02T18:55:51.0083609' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (14, N'ZXFjMnplWmEwSzBtdVVzVkFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZVXRST1hOc05GTkdlRzV2WVVFdFJuSk1SRmRWTlZSSWFITTNTR3RCYTBGVVZtSXRhMFp1UldGeVdHcHlOWHBsY2w5aU1qTjVkR3BKTjI5ME1FUndUVUpWU2t4V1NERlVNbkJGUVhjMGVtZDJW', N'Operario/a logístico, acompañante de chofer eventual / Zona Norte', N'Adecco Argentina S.A.', N'https://t0.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=https://adecco.com&size=128', N'Argentina', N'Centro de distribución en Pacheco busca operarios para carga y descarga y para acompañar al chofer en los repartos. Requisitos: secundario completo con analítico, experiencia en depósito, disponibilidad full time y vivir en zona norte del Gran Buenos Aires. Contrato eventual por 6 meses, con sueldo según convenio.', 0, N'Tiempo completo', NULL, N'https://ar.computrabajo.com/ofertas-de-trabajo/oferta-de-trabajo-de-operarioa-logistico-acompanante-de-chofer-eventual-zona-norte-en-gral-pacheco-AADF96461C0CEA1261373E686DCF3405', N'Computrabajo', NULL, CAST(N'2026-11-02T18:55:51.0083609' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (15, N'Z2ZETHJMOXhCeHVVbjR4T0FBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXVUZxVTFaMlR6aEhablpVVW1SdWQyWnVSMWhwTUZKSmNteGZWRVJ6YlVwMFpFODNUekZNVDBocU9FRXlPVTF6YlhjdGNtcEZiVWhJUlc1clkySlZVREZ0ZVV4V2RESnpiWFZGYUROaVZqTXlS', N'Operarios/as de depósito (empresa líder)', N'Randstad AR', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnGi2f4uoxgnabfk515UOSB5L5BbLT5Hq0qaii&s=0', N'Cdad. Autónoma de Buenos Aires', N'Randstad busca operarios de depósito para una empresa del rubro: carga y descarga, armado de pedidos y control de stock. No hace falta experiencia; se pide secundario completo y disponibilidad full time en turnos rotativos. Trabajo por convocatoria, con incorporación inmediata.', 0, N'Tiempo completo', NULL, N'https://www.randstad.com.ar/trabajos/operariosas-de-deposito-empresa-lider_capital-federal_46243125/', N'Randstad Argentina', NULL, CAST(N'2026-11-02T18:55:51.0088578' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (16, N'V0RsSUoxNmxYR2pDLTNYdUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXUzFtZWxWblJWSTRURWhzUlZWRFdsZHlSamRpWmpKclJUVmxNVlphYWtjeWFVWm5URGxWWVd3dE5VVktNWFl6ZEhVdGR6SnljMkZhVEZKSU9FRjJPRGR3V25SMVdWbGpOM0pOZERGc2FGSkli', N'Jefe/a de Producción Gastronómica', N'ADECCO RECURSOS HUMANOS ARGENTINA SA', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQh8_Rq6W3dV5r8ujCZVWMA9egqYSIsod-X5dgx&s=0', N'Río Cuarto, Córdoba', N'Empresa de Río Cuarto busca un jefe de cocina para planificar la producción diaria, liderar al equipo, gestionar los insumos y cuidar la calidad y la higiene de los alimentos. Requisitos: experiencia liderando cocinas industriales o de gran volumen y formación en gastronomía o afines. Horario de 4:00 a 12:45.', 0, N'Tiempo completo', NULL, N'https://www.bumeran.com.ar/empleos/jefe-a-de-produccion-gastronomica-adecco-recursos-humanos-argentina-sa-1118499421.html', N'Bumeran', NULL, CAST(N'2026-11-02T18:55:51.0088578' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (17, N'SEtiX3hUSlhobnJ2T2F0dUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZVEo2YjJscllqUTNhRmhSYlhsbFNYcFFTVk5yYmpoblNYaENSSFJrVFUxMFNuRk5XV1pmTkV4UU0zSjBWMFpCWXpkQ1FWcEJlVEpaUkRSS1JITklaWEF5ZGtSMU5rODRNMWxxVEdsMldrZFBU', N'Coordinador de Payroll & HR Operations', N'Confidential Careers', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSa-gwOMoVWUUuQbEQNJKW8tkb7ItOUetY-OqEI&s=0', N'Argentina', N'Empresa de servicios busca un líder para el área de liquidación de sueldos y administración de personal: coordinar al equipo, cumplir con las obligaciones laborales e impositivas y mejorar los procesos. Requisitos: título en Relaciones Laborales, Contador o afines, 5 años coordinando liquidaciones de más de 500 personas con varios convenios y Excel avanzado. Híbrido en CABA.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/coordinador-de-payroll-hr-operations-at-confidential-careers-4484105999', N'LinkedIn', NULL, CAST(N'2026-11-02T18:55:51.0093539' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (18, N'TEFSWkdUNWlheGNOdnZqZkFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZWFJhUmtVeGJEVnNVVk5DUldaMFRGYzBXWFExUjJaQk5Ga3dSekZsTW5JMU1FbGhiSGx2Vm1sSWVEVmxUM1JXVUVsNVFVcExNMmRyWjJacldFdExRVnA0Vmt0cGRrTnlabTlpVGtGV2VYaG1O', N'Gerente/a de Prestaciones', N'Confidential Careers', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSa-gwOMoVWUUuQbEQNJKW8tkb7ItOUetY-OqEI&s=0', N'Argentina', N'Organización del sector salud de Capital Federal busca un gerente para supervisar las prestaciones, negociar tarifas y convenios con los financiadores, analizar indicadores y liderar equipos. Requisitos: 10 años de experiencia en puestos similares, preferentemente en salud. De lunes a viernes de 9 a 18, con 3 días presenciales, almuerzo y prepaga.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/gerente-a-de-prestaciones-at-confidential-careers-4484577039', N'LinkedIn', NULL, CAST(N'2026-11-02T18:55:51.0093539' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (19, N'SG5MTk9pdXUtQVVOdlh1RUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXV3QyWkdWSmVUZ3hORjlpV25OM2IyMVpjMWhGYUZWb1owTkRaRzVqVEMxa2VWQmFjV05rZVU5SlpEaElORWx4UzJ0TWJrVTRXVEV6VUY5SWFWUndiSE53YzI5b1YzTlhjVUZPYkRSSFZtaDJU', N'GERENTE COMERCIAL', N'MANNOL ARGENTINA', N'https://t0.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=https://bumeran.com.ar&size=128', N'Villa Maipú, Provincia de Buenos Aires', N'RS Lubricantes, representante de MANNOL en Argentina, busca un gerente comercial para armar la estrategia de ventas, liderar al equipo y ampliar la red de distribuidores en todo el país. Requisitos: 5 años como gerente comercial en lubricantes o autopartes, experiencia liderando vendedores y disponibilidad para viajar.', 0, N'Tiempo completo', NULL, N'https://www.bumeran.com.ar/empleos/gerente-comercial-mannol-argentina-1118498411.html', N'Bumeran', NULL, CAST(N'2026-11-02T18:55:51.0098489' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (20, N'emlhM0VwMlBRaUx0TDl0TUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXbGhJWWtaWFNWUnBNVUl5YVZkeGJYSk5NekJWUzJneGRFTXdjekJoWlY5WFJrSnFTbWxOWkhaQ1lYbEVOREF5Vkhob1VUQkhVbWR5Wmt4TWNXSm5VWFJST1dRMFdqUk9MVFpSVUY5dVFVUnRT', N'Operador/a de digitalización documental', N'Grupo Ceta Argentina', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT84Ba2jMsOP5u9B7cxH_t2QkG2huT-O6jp85eb&s=0', N'Vicente López, Provincia de Buenos Aires', N'Ceta Capital Humano busca operadores para digitalizar y clasificar documentación de archivo en una empresa de San Martín, zona norte. Requisitos: secundario completo con analítico y vivir en la zona; la experiencia en digitalización suma. Contrato eventual, jornada completa.', 0, N'Tiempo completo', NULL, N'https://ar.computrabajo.com/ofertas-de-trabajo/oferta-de-trabajo-de-operadora-de-digitalizacion-documental-en-vicente-lopez-B1A052AC8CC3A6B361373E686DCF3405', N'Computrabajo', NULL, CAST(N'2026-11-02T18:55:51.0098489' AS DateTime2))
SET IDENTITY_INSERT [dbo].[OfertaExterna] OFF
GO
SET IDENTITY_INSERT [dbo].[Pais] ON 

INSERT [dbo].[Pais] ([ID], [Nombre], [Codigo_ISO], [Codigo_Telefono]) VALUES (1, N'Argentina', N'ar', N'+54')
SET IDENTITY_INSERT [dbo].[Pais] OFF
GO
SET IDENTITY_INSERT [dbo].[Perfil] ON 

INSERT [dbo].[Perfil] ([ID], [IDUsuario], [IDProvincia], [Foto], [Descripcion], [Telefono], [Estado_Busqueda]) VALUES (1, 1, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Perfil] OFF
GO
SET IDENTITY_INSERT [dbo].[Provincia] ON 

INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (1, 1, N'Buenos Aires')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (2, 1, N'Catamarca')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (3, 1, N'Chaco')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (4, 1, N'Chubut')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (5, 1, N'Ciudad Autónoma de Buenos Aires')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (6, 1, N'Córdoba')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (7, 1, N'Corrientes')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (8, 1, N'Entre Ríos')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (9, 1, N'Formosa')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (10, 1, N'Jujuy')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (11, 1, N'La Pampa')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (12, 1, N'La Rioja')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (13, 1, N'Mendoza')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (14, 1, N'Misiones')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (15, 1, N'Neuquén')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (16, 1, N'Río Negro')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (17, 1, N'Salta')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (18, 1, N'San Juan')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (19, 1, N'San Luis')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (20, 1, N'Santa Cruz')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (21, 1, N'Santa Fe')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (22, 1, N'Santiago del Estero')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (23, 1, N'Tierra del Fuego')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (24, 1, N'Tucumán')
SET IDENTITY_INSERT [dbo].[Provincia] OFF
GO
SET IDENTITY_INSERT [dbo].[Sector] ON 

INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (1, N'Habilidades generales', 1)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (2, N'Tecnología y sistemas', 2)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (3, N'Datos y análisis', 3)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (4, N'Administración y finanzas', 4)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (5, N'Ventas y atención al cliente', 5)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (6, N'Marketing y comunicación', 6)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (7, N'Diseño', 7)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (8, N'Logística y operaciones', 8)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (9, N'Gastronomía y hotelería', 9)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (10, N'Salud', 10)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (11, N'Educación', 11)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (12, N'Construcción y oficios', 12)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (13, N'Recursos humanos', 13)
SET IDENTITY_INSERT [dbo].[Sector] OFF
GO
SET IDENTITY_INSERT [dbo].[Usuario] ON 

INSERT [dbo].[Usuario] ([ID], [Nombre], [Apellido], [Email], [Contraseña], [Fecha_Registro], [Tipo], [Es_Moderador]) VALUES (1, N'Teo', N'Moreno', N'50291929@est.ort.edu.ar', N'PBKDF2$600000$5PeX0WMGc2StUFT8LB6ytQ==$bp2ZHrIULGDmEzGP+cwo8mLhDEHzqmbNUIJe8GM19lE=', CAST(N'2026-11-02' AS Date), N'Persona', 1)
SET IDENTITY_INSERT [dbo].[Usuario] OFF
GO
ALTER TABLE [dbo].[CV] ADD  CONSTRAINT [UQ_CV_IDUsuario] UNIQUE NONCLUSTERED 
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Educacion] ADD  CONSTRAINT [UQ_Educacion_Institucion] UNIQUE NONCLUSTERED 
(
	[Institucion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Empresa] ADD  CONSTRAINT [UQ_Empresa_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Empresa_CUIT] ON [dbo].[Empresa]
(
	[CUIT] ASC
)
WHERE ([CUIT] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Empresa_IDUsuario] ON [dbo].[Empresa]
(
	[IDUsuario] ASC
)
WHERE ([IDUsuario] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExperienciaLaboral_IDUsuario] ON [dbo].[ExperienciaLaboral]
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Favorito_IDUsuario] ON [dbo].[Favorito]
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FavoritoOferta] ADD  CONSTRAINT [UQ_FavoritoOferta_IDFavorito] UNIQUE NONCLUSTERED 
(
	[IDFavorito] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FavoritoOferta_IDOfertaExterna] ON [dbo].[FavoritoOferta]
(
	[IDOfertaExterna] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FavoritoOferta_IDOfertaLaboral] ON [dbo].[FavoritoOferta]
(
	[IDOfertaLaboral] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Habilidad] ADD  CONSTRAINT [UQ_Habilidad_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Habilidad_IDSector] ON [dbo].[Habilidad]
(
	[IDSector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Idioma] ADD  CONSTRAINT [UQ_Idioma_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[LoginExterno] ADD  CONSTRAINT [UQ_LoginExterno] UNIQUE NONCLUSTERED 
(
	[Proveedor] ASC,
	[ID_Externo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[OfertaExterna] ADD  CONSTRAINT [UQ_OfertaExterna_ID_Externo] UNIQUE NONCLUSTERED 
(
	[ID_Externo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
CREATE NONCLUSTERED INDEX [IX_OfertaLaboral_Estado_Publicacion] ON [dbo].[OfertaLaboral]
(
	[Estado_Publicacion] ASC,
	[Fecha_Publicacion] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OfertaLaboral_IDEmpresa] ON [dbo].[OfertaLaboral]
(
	[IDEmpresa] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OfertaLaboral_IDUsuario_Publicador] ON [dbo].[OfertaLaboral]
(
	[IDUsuario_Publicador] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OfertaPuesto] ADD  CONSTRAINT [UQ_OfertaPuesto] UNIQUE NONCLUSTERED 
(
	[IDOfertaLaboral] ASC,
	[IDPuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_OfertaPuesto_IDPuesto] ON [dbo].[OfertaPuesto]
(
	[IDPuesto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Pais] ADD  CONSTRAINT [UQ_Pais_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Perfil] ADD  CONSTRAINT [UQ_Perfil_IDUsuario] UNIQUE NONCLUSTERED 
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Perfil_IDProvincia] ON [dbo].[Perfil]
(
	[IDProvincia] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Postulacion_IDOfertaLaboral] ON [dbo].[Postulacion]
(
	[IDOfertaLaboral] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Postulacion_Usuario_OfertaExterna] ON [dbo].[Postulacion]
(
	[IDUsuario] ASC,
	[IDOfertaExterna] ASC
)
WHERE ([IDOfertaExterna] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Postulacion_Usuario_OfertaLaboral] ON [dbo].[Postulacion]
(
	[IDUsuario] ASC,
	[IDOfertaLaboral] ASC
)
WHERE ([IDOfertaLaboral] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Preferencia] ADD  CONSTRAINT [UQ_Preferencia_IDUsuario] UNIQUE NONCLUSTERED 
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Provincia] ADD  CONSTRAINT [UQ_Provincia_Pais_Nombre] UNIQUE NONCLUSTERED 
(
	[IDPais] ASC,
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Puesto] ADD  CONSTRAINT [UQ_Puesto_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Puesto_IDSector] ON [dbo].[Puesto]
(
	[IDSector] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[RecuperacionClave] ADD  CONSTRAINT [UQ_RecuperacionClave_Token_Hash] UNIQUE NONCLUSTERED 
(
	[Token_Hash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_RecuperacionClave_IDUsuario] ON [dbo].[RecuperacionClave]
(
	[IDUsuario] ASC,
	[Fecha] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Sector] ADD  CONSTRAINT [UQ_Sector_Nombre] UNIQUE NONCLUSTERED 
(
	[Nombre] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
ALTER TABLE [dbo].[Usuario] ADD  CONSTRAINT [UQ_Usuario_Email] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UsuarioEducacion_IDUsuario] ON [dbo].[UsuarioEducacion]
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UsuarioHabilidad] ADD  CONSTRAINT [UQ_UsuarioHabilidad] UNIQUE NONCLUSTERED 
(
	[IDUsuario] ASC,
	[IDHabilidad] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UsuarioHabilidad_IDUsuario] ON [dbo].[UsuarioHabilidad]
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[UsuarioIdioma] ADD  CONSTRAINT [UQ_UsuarioIdioma] UNIQUE NONCLUSTERED 
(
	[IDUsuario] ASC,
	[IDIdioma] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_UsuarioIdioma_IDUsuario] ON [dbo].[UsuarioIdioma]
(
	[IDUsuario] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CV] ADD  CONSTRAINT [DF_CV_Fecha_Actualizacion]  DEFAULT (CONVERT([date],getdate())) FOR [Fecha_Actualizacion]
GO
ALTER TABLE [dbo].[Empresa] ADD  CONSTRAINT [DF_Empresa_Fecha_Registro]  DEFAULT (CONVERT([date],getdate())) FOR [Fecha_Registro]
GO
ALTER TABLE [dbo].[Favorito] ADD  CONSTRAINT [DF_Favorito_fecha_guardado]  DEFAULT (CONVERT([date],getdate())) FOR [fecha_guardado]
GO
ALTER TABLE [dbo].[OfertaExterna] ADD  CONSTRAINT [DF_OfertaExterna_Es_Remoto]  DEFAULT ((0)) FOR [Es_Remoto]
GO
ALTER TABLE [dbo].[OfertaExterna] ADD  CONSTRAINT [DF_OfertaExterna_Fecha_Consulta]  DEFAULT (sysutcdatetime()) FOR [Fecha_Consulta]
GO
ALTER TABLE [dbo].[OfertaLaboral] ADD  CONSTRAINT [DF_OfertaLaboral_Cantidad_Puestos]  DEFAULT ((1)) FOR [Cantidad_Puestos]
GO
ALTER TABLE [dbo].[OfertaLaboral] ADD  CONSTRAINT [DF_OfertaLaboral_Fecha_Publicacion]  DEFAULT (CONVERT([date],getdate())) FOR [Fecha_Publicacion]
GO
ALTER TABLE [dbo].[OfertaLaboral] ADD  CONSTRAINT [DF_OfertaLaboral_Estado_Publicacion]  DEFAULT (N'Aprobada') FOR [Estado_Publicacion]
GO
ALTER TABLE [dbo].[Postulacion] ADD  CONSTRAINT [DF_Postulacion_Fecha]  DEFAULT (CONVERT([date],getdate())) FOR [Fecha]
GO
ALTER TABLE [dbo].[Postulacion] ADD  CONSTRAINT [DF_Postulacion_Estado]  DEFAULT (N'Enviada') FOR [Estado]
GO
ALTER TABLE [dbo].[RecuperacionClave] ADD  CONSTRAINT [DF_RecuperacionClave_Fecha]  DEFAULT (sysutcdatetime()) FOR [Fecha]
GO
ALTER TABLE [dbo].[RecuperacionClave] ADD  CONSTRAINT [DF_RecuperacionClave_Usada]  DEFAULT ((0)) FOR [Usada]
GO
ALTER TABLE [dbo].[Sector] ADD  CONSTRAINT [DF_Sector_Orden]  DEFAULT ((0)) FOR [Orden]
GO
ALTER TABLE [dbo].[Usuario] ADD  CONSTRAINT [DF_Usuario_Fecha_Registro]  DEFAULT (CONVERT([date],getdate())) FOR [Fecha_Registro]
GO
ALTER TABLE [dbo].[Usuario] ADD  CONSTRAINT [DF_Usuario_Tipo]  DEFAULT (N'Persona') FOR [Tipo]
GO
ALTER TABLE [dbo].[Usuario] ADD  CONSTRAINT [DF_Usuario_Es_Moderador]  DEFAULT ((0)) FOR [Es_Moderador]
GO
ALTER TABLE [dbo].[CV]  WITH CHECK ADD  CONSTRAINT [FK_CV_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CV] CHECK CONSTRAINT [FK_CV_Usuario]
GO
ALTER TABLE [dbo].[Empresa]  WITH CHECK ADD  CONSTRAINT [FK_Empresa_Provincia] FOREIGN KEY([IDProvincia])
REFERENCES [dbo].[Provincia] ([ID])
GO
ALTER TABLE [dbo].[Empresa] CHECK CONSTRAINT [FK_Empresa_Provincia]
GO
ALTER TABLE [dbo].[Empresa]  WITH CHECK ADD  CONSTRAINT [FK_Empresa_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Empresa] CHECK CONSTRAINT [FK_Empresa_Usuario]
GO
ALTER TABLE [dbo].[ExperienciaLaboral]  WITH CHECK ADD  CONSTRAINT [FK_ExperienciaLaboral_Empresa] FOREIGN KEY([IDEmpresa])
REFERENCES [dbo].[Empresa] ([ID])
GO
ALTER TABLE [dbo].[ExperienciaLaboral] CHECK CONSTRAINT [FK_ExperienciaLaboral_Empresa]
GO
ALTER TABLE [dbo].[ExperienciaLaboral]  WITH CHECK ADD  CONSTRAINT [FK_ExperienciaLaboral_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ExperienciaLaboral] CHECK CONSTRAINT [FK_ExperienciaLaboral_Usuario]
GO
ALTER TABLE [dbo].[Favorito]  WITH CHECK ADD  CONSTRAINT [FK_Favorito_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Favorito] CHECK CONSTRAINT [FK_Favorito_Usuario]
GO
ALTER TABLE [dbo].[FavoritoOferta]  WITH CHECK ADD  CONSTRAINT [FK_FavoritoOferta_Favorito] FOREIGN KEY([IDFavorito])
REFERENCES [dbo].[Favorito] ([ID_favorito])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FavoritoOferta] CHECK CONSTRAINT [FK_FavoritoOferta_Favorito]
GO
ALTER TABLE [dbo].[FavoritoOferta]  WITH CHECK ADD  CONSTRAINT [FK_FavoritoOferta_OfertaExterna] FOREIGN KEY([IDOfertaExterna])
REFERENCES [dbo].[OfertaExterna] ([ID])
GO
ALTER TABLE [dbo].[FavoritoOferta] CHECK CONSTRAINT [FK_FavoritoOferta_OfertaExterna]
GO
ALTER TABLE [dbo].[FavoritoOferta]  WITH CHECK ADD  CONSTRAINT [FK_FavoritoOferta_OfertaLaboral] FOREIGN KEY([IDOfertaLaboral])
REFERENCES [dbo].[OfertaLaboral] ([ID])
GO
ALTER TABLE [dbo].[FavoritoOferta] CHECK CONSTRAINT [FK_FavoritoOferta_OfertaLaboral]
GO
ALTER TABLE [dbo].[Habilidad]  WITH CHECK ADD  CONSTRAINT [FK_Habilidad_Sector] FOREIGN KEY([IDSector])
REFERENCES [dbo].[Sector] ([ID])
GO
ALTER TABLE [dbo].[Habilidad] CHECK CONSTRAINT [FK_Habilidad_Sector]
GO
ALTER TABLE [dbo].[LoginExterno]  WITH CHECK ADD  CONSTRAINT [FK_LoginExterno_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[LoginExterno] CHECK CONSTRAINT [FK_LoginExterno_Usuario]
GO
ALTER TABLE [dbo].[OfertaLaboral]  WITH CHECK ADD  CONSTRAINT [FK_OfertaLaboral_Empresa] FOREIGN KEY([IDEmpresa])
REFERENCES [dbo].[Empresa] ([ID])
GO
ALTER TABLE [dbo].[OfertaLaboral] CHECK CONSTRAINT [FK_OfertaLaboral_Empresa]
GO
ALTER TABLE [dbo].[OfertaLaboral]  WITH CHECK ADD  CONSTRAINT [FK_OfertaLaboral_Provincia] FOREIGN KEY([IDProvincia])
REFERENCES [dbo].[Provincia] ([ID])
GO
ALTER TABLE [dbo].[OfertaLaboral] CHECK CONSTRAINT [FK_OfertaLaboral_Provincia]
GO
ALTER TABLE [dbo].[OfertaLaboral]  WITH CHECK ADD  CONSTRAINT [FK_OfertaLaboral_Usuario] FOREIGN KEY([IDUsuario_Publicador])
REFERENCES [dbo].[Usuario] ([ID])
GO
ALTER TABLE [dbo].[OfertaLaboral] CHECK CONSTRAINT [FK_OfertaLaboral_Usuario]
GO
ALTER TABLE [dbo].[OfertaPuesto]  WITH CHECK ADD  CONSTRAINT [FK_OfertaPuesto_OfertaLaboral] FOREIGN KEY([IDOfertaLaboral])
REFERENCES [dbo].[OfertaLaboral] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[OfertaPuesto] CHECK CONSTRAINT [FK_OfertaPuesto_OfertaLaboral]
GO
ALTER TABLE [dbo].[OfertaPuesto]  WITH CHECK ADD  CONSTRAINT [FK_OfertaPuesto_Puesto] FOREIGN KEY([IDPuesto])
REFERENCES [dbo].[Puesto] ([ID])
GO
ALTER TABLE [dbo].[OfertaPuesto] CHECK CONSTRAINT [FK_OfertaPuesto_Puesto]
GO
ALTER TABLE [dbo].[Perfil]  WITH CHECK ADD  CONSTRAINT [FK_Perfil_Provincia] FOREIGN KEY([IDProvincia])
REFERENCES [dbo].[Provincia] ([ID])
GO
ALTER TABLE [dbo].[Perfil] CHECK CONSTRAINT [FK_Perfil_Provincia]
GO
ALTER TABLE [dbo].[Perfil]  WITH CHECK ADD  CONSTRAINT [FK_Perfil_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Perfil] CHECK CONSTRAINT [FK_Perfil_Usuario]
GO
ALTER TABLE [dbo].[Postulacion]  WITH CHECK ADD  CONSTRAINT [FK_Postulacion_OfertaExterna] FOREIGN KEY([IDOfertaExterna])
REFERENCES [dbo].[OfertaExterna] ([ID])
GO
ALTER TABLE [dbo].[Postulacion] CHECK CONSTRAINT [FK_Postulacion_OfertaExterna]
GO
ALTER TABLE [dbo].[Postulacion]  WITH CHECK ADD  CONSTRAINT [FK_Postulacion_OfertaLaboral] FOREIGN KEY([IDOfertaLaboral])
REFERENCES [dbo].[OfertaLaboral] ([ID])
GO
ALTER TABLE [dbo].[Postulacion] CHECK CONSTRAINT [FK_Postulacion_OfertaLaboral]
GO
ALTER TABLE [dbo].[Postulacion]  WITH CHECK ADD  CONSTRAINT [FK_Postulacion_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Postulacion] CHECK CONSTRAINT [FK_Postulacion_Usuario]
GO
ALTER TABLE [dbo].[Preferencia]  WITH CHECK ADD  CONSTRAINT [FK_Preferencia_Provincia] FOREIGN KEY([IDProvincia])
REFERENCES [dbo].[Provincia] ([ID])
GO
ALTER TABLE [dbo].[Preferencia] CHECK CONSTRAINT [FK_Preferencia_Provincia]
GO
ALTER TABLE [dbo].[Preferencia]  WITH CHECK ADD  CONSTRAINT [FK_Preferencia_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Preferencia] CHECK CONSTRAINT [FK_Preferencia_Usuario]
GO
ALTER TABLE [dbo].[Provincia]  WITH CHECK ADD  CONSTRAINT [FK_Provincia_Pais] FOREIGN KEY([IDPais])
REFERENCES [dbo].[Pais] ([ID])
GO
ALTER TABLE [dbo].[Provincia] CHECK CONSTRAINT [FK_Provincia_Pais]
GO
ALTER TABLE [dbo].[Puesto]  WITH CHECK ADD  CONSTRAINT [FK_Puesto_Sector] FOREIGN KEY([IDSector])
REFERENCES [dbo].[Sector] ([ID])
GO
ALTER TABLE [dbo].[Puesto] CHECK CONSTRAINT [FK_Puesto_Sector]
GO
ALTER TABLE [dbo].[RecuperacionClave]  WITH CHECK ADD  CONSTRAINT [FK_RecuperacionClave_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[RecuperacionClave] CHECK CONSTRAINT [FK_RecuperacionClave_Usuario]
GO
ALTER TABLE [dbo].[UsuarioEducacion]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioEducacion_Educacion] FOREIGN KEY([IDEducacion])
REFERENCES [dbo].[Educacion] ([ID])
GO
ALTER TABLE [dbo].[UsuarioEducacion] CHECK CONSTRAINT [FK_UsuarioEducacion_Educacion]
GO
ALTER TABLE [dbo].[UsuarioEducacion]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioEducacion_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UsuarioEducacion] CHECK CONSTRAINT [FK_UsuarioEducacion_Usuario]
GO
ALTER TABLE [dbo].[UsuarioHabilidad]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioHabilidad_Habilidad] FOREIGN KEY([IDHabilidad])
REFERENCES [dbo].[Habilidad] ([ID])
GO
ALTER TABLE [dbo].[UsuarioHabilidad] CHECK CONSTRAINT [FK_UsuarioHabilidad_Habilidad]
GO
ALTER TABLE [dbo].[UsuarioHabilidad]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioHabilidad_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UsuarioHabilidad] CHECK CONSTRAINT [FK_UsuarioHabilidad_Usuario]
GO
ALTER TABLE [dbo].[UsuarioIdioma]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioIdioma_Idioma] FOREIGN KEY([IDIdioma])
REFERENCES [dbo].[Idioma] ([ID])
GO
ALTER TABLE [dbo].[UsuarioIdioma] CHECK CONSTRAINT [FK_UsuarioIdioma_Idioma]
GO
ALTER TABLE [dbo].[UsuarioIdioma]  WITH CHECK ADD  CONSTRAINT [FK_UsuarioIdioma_Usuario] FOREIGN KEY([IDUsuario])
REFERENCES [dbo].[Usuario] ([ID])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UsuarioIdioma] CHECK CONSTRAINT [FK_UsuarioIdioma_Usuario]
GO
ALTER TABLE [dbo].[ExperienciaLaboral]  WITH CHECK ADD  CONSTRAINT [CK_ExperienciaLaboral_Fechas] CHECK  (([Fecha_Finalizacion] IS NULL OR [Fecha_Finalizacion]>=[Fecha_Inicio]))
GO
ALTER TABLE [dbo].[ExperienciaLaboral] CHECK CONSTRAINT [CK_ExperienciaLaboral_Fechas]
GO
ALTER TABLE [dbo].[FavoritoOferta]  WITH CHECK ADD  CONSTRAINT [CK_FavoritoOferta_Oferta] CHECK  (([IDOfertaLaboral] IS NULL AND [IDOfertaExterna] IS NOT NULL OR [IDOfertaLaboral] IS NOT NULL AND [IDOfertaExterna] IS NULL))
GO
ALTER TABLE [dbo].[FavoritoOferta] CHECK CONSTRAINT [CK_FavoritoOferta_Oferta]
GO
ALTER TABLE [dbo].[OfertaLaboral]  WITH CHECK ADD  CONSTRAINT [CK_OfertaLaboral_Cantidad_Puestos] CHECK  (([Cantidad_Puestos]>=(1)))
GO
ALTER TABLE [dbo].[OfertaLaboral] CHECK CONSTRAINT [CK_OfertaLaboral_Cantidad_Puestos]
GO
ALTER TABLE [dbo].[OfertaLaboral]  WITH CHECK ADD  CONSTRAINT [CK_OfertaLaboral_Estado_Publicacion] CHECK  (([Estado_Publicacion]=N'Rechazada' OR [Estado_Publicacion]=N'Aprobada' OR [Estado_Publicacion]=N'Pendiente'))
GO
ALTER TABLE [dbo].[OfertaLaboral] CHECK CONSTRAINT [CK_OfertaLaboral_Estado_Publicacion]
GO
ALTER TABLE [dbo].[OfertaLaboral]  WITH CHECK ADD  CONSTRAINT [CK_OfertaLaboral_Fechas] CHECK  (([Fecha_Cierre] IS NULL OR [Fecha_Cierre]>=[Fecha_Publicacion]))
GO
ALTER TABLE [dbo].[OfertaLaboral] CHECK CONSTRAINT [CK_OfertaLaboral_Fechas]
GO
ALTER TABLE [dbo].[OfertaLaboral]  WITH CHECK ADD  CONSTRAINT [CK_OfertaLaboral_Modalidad] CHECK  (([Modalidad]=N'Presencial' OR [Modalidad]=N'Híbrido' OR [Modalidad]=N'Remoto'))
GO
ALTER TABLE [dbo].[OfertaLaboral] CHECK CONSTRAINT [CK_OfertaLaboral_Modalidad]
GO
ALTER TABLE [dbo].[OfertaLaboral]  WITH CHECK ADD  CONSTRAINT [CK_OfertaLaboral_Salario] CHECK  (([Salario] IS NULL OR [Salario]>=(0)))
GO
ALTER TABLE [dbo].[OfertaLaboral] CHECK CONSTRAINT [CK_OfertaLaboral_Salario]
GO
ALTER TABLE [dbo].[Perfil]  WITH CHECK ADD  CONSTRAINT [CK_Perfil_Estado_Busqueda] CHECK  (([Estado_Busqueda]=N'No estoy buscando' OR [Estado_Busqueda]=N'Abierto a propuestas' OR [Estado_Busqueda]=N'Buscando activamente'))
GO
ALTER TABLE [dbo].[Perfil] CHECK CONSTRAINT [CK_Perfil_Estado_Busqueda]
GO
ALTER TABLE [dbo].[Postulacion]  WITH CHECK ADD  CONSTRAINT [CK_Postulacion_Estado] CHECK  (([Estado]=N'No pasé' OR [Estado]=N'Pasé' OR [Estado]=N'En revisión' OR [Estado]=N'Enviada'))
GO
ALTER TABLE [dbo].[Postulacion] CHECK CONSTRAINT [CK_Postulacion_Estado]
GO
ALTER TABLE [dbo].[Postulacion]  WITH CHECK ADD  CONSTRAINT [CK_Postulacion_Oferta] CHECK  (([IDOfertaLaboral] IS NULL AND [IDOfertaExterna] IS NOT NULL OR [IDOfertaLaboral] IS NOT NULL AND [IDOfertaExterna] IS NULL))
GO
ALTER TABLE [dbo].[Postulacion] CHECK CONSTRAINT [CK_Postulacion_Oferta]
GO
ALTER TABLE [dbo].[Preferencia]  WITH CHECK ADD  CONSTRAINT [CK_Preferencia_Salario] CHECK  ((([Salario_Minimo] IS NULL OR [Salario_Minimo]>=(0)) AND ([Salario_Maximo] IS NULL OR [Salario_Minimo] IS NULL OR [Salario_Maximo]>=[Salario_Minimo])))
GO
ALTER TABLE [dbo].[Preferencia] CHECK CONSTRAINT [CK_Preferencia_Salario]
GO
ALTER TABLE [dbo].[Usuario]  WITH CHECK ADD  CONSTRAINT [CK_Usuario_Tipo] CHECK  (([Tipo]=N'Empresa' OR [Tipo]=N'Persona'))
GO
ALTER TABLE [dbo].[Usuario] CHECK CONSTRAINT [CK_Usuario_Tipo]
GO
ALTER TABLE [dbo].[UsuarioEducacion]  WITH CHECK ADD  CONSTRAINT [CK_UsuarioEducacion_Fechas] CHECK  (([Fecha_Fin] IS NULL OR [Fecha_Fin]>=[Fecha_Inicio]))
GO
ALTER TABLE [dbo].[UsuarioEducacion] CHECK CONSTRAINT [CK_UsuarioEducacion_Fechas]
GO
ALTER TABLE [dbo].[UsuarioIdioma]  WITH CHECK ADD  CONSTRAINT [CK_UsuarioIdioma_Nivel] CHECK  (([Nivel]=N'Nativo' OR [Nivel]=N'Avanzado' OR [Nivel]=N'Intermedio' OR [Nivel]=N'Básico'))
GO
ALTER TABLE [dbo].[UsuarioIdioma] CHECK CONSTRAINT [CK_UsuarioIdioma_Nivel]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerUsuarioPorEmail
    @Email NVARCHAR(100)
AS
BEGIN
    SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo, Es_Moderador
    FROM Usuario
    WHERE Email = @Email
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerUsuarioPorId
    @ID INT
AS
BEGIN
    SELECT ID, Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo, Es_Moderador
    FROM Usuario
    WHERE ID = @ID
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ExisteEmail
    @Email NVARCHAR(100),
    @Excepto INT = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Usuario WHERE Email = @Email AND ID <> ISNULL(@Excepto, 0))
        SELECT CAST(1 AS BIT) AS Existe
    ELSE
        SELECT CAST(0 AS BIT) AS Existe
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AsegurarPerfil
    @IDUsuario INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Perfil WHERE IDUsuario = @IDUsuario)
    BEGIN
        INSERT INTO Perfil (IDUsuario)
        VALUES (@IDUsuario)
    END
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE VincularLoginExterno
    @IDUsuario INT,
    @Proveedor NVARCHAR(20),
    @IDExterno NVARCHAR(200)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM LoginExterno WHERE Proveedor = @Proveedor AND ID_Externo = @IDExterno)
    BEGIN
        INSERT INTO LoginExterno (IDUsuario, Proveedor, ID_Externo)
        VALUES (@IDUsuario, @Proveedor, @IDExterno)
    END
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE RegistrarPersona
    @Nombre NVARCHAR(50),
    @Apellido NVARCHAR(50),
    @Email NVARCHAR(100),
    @Contrasena NVARCHAR(200),
    @Proveedor NVARCHAR(20) = NULL,
    @IDExterno NVARCHAR(200) = NULL
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @ID INT

    BEGIN TRANSACTION
        INSERT INTO Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
        VALUES (@Nombre, @Apellido, @Email, @Contrasena, CAST(GETDATE() AS DATE), N'Persona')
        SET @ID = SCOPE_IDENTITY()

        EXEC AsegurarPerfil @ID

        IF @Proveedor IS NOT NULL
            EXEC VincularLoginExterno @ID, @Proveedor, @IDExterno
    COMMIT TRANSACTION

    SELECT @ID AS ID
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE RegistrarEmpresa
    @Nombre NVARCHAR(50),
    @Apellido NVARCHAR(50),
    @Email NVARCHAR(100),
    @Contrasena NVARCHAR(200),
    @NombreEmpresa NVARCHAR(100),
    @Descripcion NVARCHAR(500),
    @Logo NVARCHAR(260),
    @Ubicacion NVARCHAR(100),
    @Sitio_Web NVARCHAR(200),
    @Razon_Social NVARCHAR(150),
    @CUIT CHAR(11),
    @Rubro NVARCHAR(60),
    @IDProvincia INT,
    @Telefono NVARCHAR(30),
    @Proveedor NVARCHAR(20) = NULL,
    @IDExterno NVARCHAR(200) = NULL
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @ID INT
    DECLARE @IDEmpresa INT

    BEGIN TRANSACTION
        INSERT INTO Usuario (Nombre, Apellido, Email, [Contraseña], Fecha_Registro, Tipo)
        VALUES (@Nombre, @Apellido, @Email, @Contrasena, CAST(GETDATE() AS DATE), N'Empresa')
        SET @ID = SCOPE_IDENTITY()

        SELECT TOP 1 @IDEmpresa = ID
        FROM Empresa
        WHERE Nombre = @NombreEmpresa AND IDUsuario IS NULL
        ORDER BY ID

        IF @IDEmpresa IS NOT NULL
        BEGIN
            UPDATE Empresa
            SET IDUsuario = @ID, Descripcion = @Descripcion, Logo = @Logo, Ubicacion = @Ubicacion, Sitio_Web = @Sitio_Web,
                Razon_Social = @Razon_Social, CUIT = @CUIT, Rubro = @Rubro, IDProvincia = @IDProvincia, Telefono = @Telefono
            WHERE ID = @IDEmpresa
        END
        ELSE
        BEGIN
            INSERT INTO Empresa (Nombre, Descripcion, Logo, Ubicacion, Sitio_Web, IDUsuario, Razon_Social, CUIT, Rubro, IDProvincia, Telefono)
            VALUES (@NombreEmpresa, @Descripcion, @Logo, @Ubicacion, @Sitio_Web, @ID, @Razon_Social, @CUIT, @Rubro, @IDProvincia, @Telefono)
        END

        IF @Proveedor IS NOT NULL
            EXEC VincularLoginExterno @ID, @Proveedor, @IDExterno
    COMMIT TRANSACTION

    SELECT @ID AS ID
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerUsuarioDeLoginExterno
    @Proveedor NVARCHAR(20),
    @IDExterno NVARCHAR(200)
AS
BEGIN
    SELECT IDUsuario
    FROM LoginExterno
    WHERE Proveedor = @Proveedor AND ID_Externo = @IDExterno
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerProveedoresVinculados
    @IDUsuario INT
AS
BEGIN
    SELECT Proveedor
    FROM LoginExterno
    WHERE IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GuardarCV
    @IDUsuario INT,
    @Archivo NVARCHAR(260),
    @CambiarArchivo BIT,
    @SitioWeb NVARCHAR(200),
    @CambiarSitio BIT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM CV WHERE IDUsuario = @IDUsuario)
    BEGIN
        INSERT INTO CV (IDUsuario, Fecha_Actualizacion)
        VALUES (@IDUsuario, CAST(GETDATE() AS DATE))
    END

    UPDATE CV
    SET Nombre_Archivo = CASE WHEN @CambiarArchivo = 1 THEN @Archivo ELSE Nombre_Archivo END,
        Sitio_Web = CASE WHEN @CambiarSitio = 1 THEN @SitioWeb ELSE Sitio_Web END,
        Fecha_Actualizacion = CAST(GETDATE() AS DATE)
    WHERE IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ActualizarDatosPersonales
    @IDUsuario INT,
    @Nombre NVARCHAR(50),
    @Apellido NVARCHAR(50),
    @Email NVARCHAR(100),
    @IDProvincia INT,
    @Telefono NVARCHAR(30),
    @SitioWeb NVARCHAR(200)
AS
BEGIN
    SET XACT_ABORT ON

    BEGIN TRANSACTION
        UPDATE Usuario
        SET Nombre = @Nombre, Apellido = @Apellido, Email = @Email
        WHERE ID = @IDUsuario

        EXEC AsegurarPerfil @IDUsuario

        UPDATE Perfil
        SET IDProvincia = @IDProvincia, Telefono = @Telefono
        WHERE IDUsuario = @IDUsuario

        EXEC GuardarCV @IDUsuario, NULL, 0, @SitioWeb, 1
    COMMIT TRANSACTION
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE CompletarPerfil
    @IDUsuario INT,
    @IDProvincia INT,
    @Telefono NVARCHAR(30),
    @Descripcion NVARCHAR(500),
    @EstadoBusqueda NVARCHAR(30),
    @Foto NVARCHAR(260),
    @ArchivoCV NVARCHAR(260),
    @SitioWeb NVARCHAR(200)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @FotoAnterior NVARCHAR(260)
    DECLARE @CVAnterior NVARCHAR(260)
    DECLARE @CambiarArchivo BIT
    SET @CambiarArchivo = CASE WHEN @ArchivoCV IS NULL THEN 0 ELSE 1 END

    BEGIN TRANSACTION
        EXEC AsegurarPerfil @IDUsuario

        IF @Foto IS NOT NULL
            SELECT @FotoAnterior = Foto FROM Perfil WHERE IDUsuario = @IDUsuario

        IF @ArchivoCV IS NOT NULL
            SELECT @CVAnterior = Nombre_Archivo FROM CV WHERE IDUsuario = @IDUsuario

        UPDATE Perfil
        SET IDProvincia = @IDProvincia, Telefono = @Telefono, Descripcion = @Descripcion, Estado_Busqueda = @EstadoBusqueda,
            Foto = COALESCE(@Foto, Foto)
        WHERE IDUsuario = @IDUsuario

        EXEC GuardarCV @IDUsuario, @ArchivoCV, @CambiarArchivo, @SitioWeb, 1
    COMMIT TRANSACTION

    SELECT @FotoAnterior AS FotoAnterior, @CVAnterior AS CVAnterior
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ActualizarResponsable
    @IDUsuario INT,
    @Nombre NVARCHAR(50),
    @Apellido NVARCHAR(50)
AS
BEGIN
    UPDATE Usuario
    SET Nombre = @Nombre, Apellido = @Apellido
    WHERE ID = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE CambiarContrasena
    @IDUsuario INT,
    @Hash NVARCHAR(200)
AS
BEGIN
    UPDATE Usuario
    SET [Contraseña] = @Hash
    WHERE ID = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ActualizarFoto
    @IDUsuario INT,
    @Foto NVARCHAR(260)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @FotoAnterior NVARCHAR(260)

    BEGIN TRANSACTION
        EXEC AsegurarPerfil @IDUsuario

        SELECT @FotoAnterior = Foto FROM Perfil WHERE IDUsuario = @IDUsuario

        UPDATE Perfil
        SET Foto = @Foto
        WHERE IDUsuario = @IDUsuario
    COMMIT TRANSACTION

    SELECT @FotoAnterior AS FotoAnterior
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ActualizarDescripcion
    @IDUsuario INT,
    @Descripcion NVARCHAR(500)
AS
BEGIN
    EXEC AsegurarPerfil @IDUsuario

    UPDATE Perfil
    SET Descripcion = @Descripcion
    WHERE IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ActualizarEstadoBusqueda
    @IDUsuario INT,
    @EstadoBusqueda NVARCHAR(30)
AS
BEGIN
    EXEC AsegurarPerfil @IDUsuario

    UPDATE Perfil
    SET Estado_Busqueda = @EstadoBusqueda
    WHERE IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ActualizarArchivoCV
    @IDUsuario INT,
    @Archivo NVARCHAR(260)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @CVAnterior NVARCHAR(260)

    BEGIN TRANSACTION
        SELECT @CVAnterior = Nombre_Archivo FROM CV WHERE IDUsuario = @IDUsuario

        EXEC GuardarCV @IDUsuario, @Archivo, 1, NULL, 0
    COMMIT TRANSACTION

    SELECT @CVAnterior AS CVAnterior
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE BorrarHabilidadesSinUso
AS
BEGIN
    DELETE h
    FROM Habilidad h
    WHERE h.IDSector IS NULL
      AND NOT EXISTS (SELECT 1 FROM UsuarioHabilidad uh WHERE uh.IDHabilidad = h.ID)
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE EliminarCuenta
    @IDUsuario INT
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @Foto NVARCHAR(260)
    DECLARE @CV NVARCHAR(260)
    DECLARE @Logo NVARCHAR(260)
    DECLARE @Ofertas TABLE (ID INT)

    BEGIN TRANSACTION
        SELECT @Foto = Foto FROM Perfil WHERE IDUsuario = @IDUsuario
        SELECT @CV = Nombre_Archivo FROM CV WHERE IDUsuario = @IDUsuario
        SELECT @Logo = Logo FROM Empresa WHERE IDUsuario = @IDUsuario

        INSERT INTO @Ofertas (ID)
        SELECT o.ID
        FROM OfertaLaboral o
        WHERE o.IDUsuario_Publicador = @IDUsuario
           OR o.IDEmpresa IN (SELECT ID FROM Empresa WHERE IDUsuario = @IDUsuario)

        DELETE FROM Postulacion
        WHERE IDOfertaLaboral IN (SELECT ID FROM @Ofertas)

        DELETE f
        FROM Favorito f
        JOIN FavoritoOferta fo ON fo.IDFavorito = f.ID_favorito
        WHERE fo.IDOfertaLaboral IN (SELECT ID FROM @Ofertas)

        DELETE FROM OfertaLaboral
        WHERE ID IN (SELECT ID FROM @Ofertas)

        UPDATE Empresa
        SET IDUsuario = NULL, CUIT = NULL, Razon_Social = NULL, Logo = NULL
        WHERE IDUsuario = @IDUsuario

        DELETE FROM Usuario
        WHERE ID = @IDUsuario

        EXEC BorrarHabilidadesSinUso
    COMMIT TRANSACTION

    SELECT @Foto AS Foto, @CV AS CV, @Logo AS Logo
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ContarRecuperacionesRecientes
    @IDUsuario INT
AS
BEGIN
    SELECT COUNT(*) AS Cantidad
    FROM RecuperacionClave
    WHERE IDUsuario = @IDUsuario AND Fecha >= DATEADD(HOUR, -1, SYSUTCDATETIME())
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GuardarRecuperacion
    @IDUsuario INT,
    @TokenHash CHAR(64),
    @Vence DATETIME2(0)
AS
BEGIN
    INSERT INTO RecuperacionClave (IDUsuario, Token_Hash, Vence)
    VALUES (@IDUsuario, @TokenHash, @Vence)
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerUsuarioDeRecuperacion
    @TokenHash CHAR(64)
AS
BEGIN
    SELECT IDUsuario
    FROM RecuperacionClave
    WHERE Token_Hash = @TokenHash AND Usada = 0 AND Vence > SYSUTCDATETIME()
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE UsarRecuperacion
    @TokenHash CHAR(64),
    @Contrasena NVARCHAR(200)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @IDUsuario INT

    BEGIN TRANSACTION
        SELECT @IDUsuario = IDUsuario
        FROM RecuperacionClave WITH (UPDLOCK)
        WHERE Token_Hash = @TokenHash AND Usada = 0 AND Vence > SYSUTCDATETIME()

        IF @IDUsuario IS NULL
        BEGIN
            ROLLBACK TRANSACTION
            SELECT CAST(0 AS BIT) AS Usada
            RETURN
        END

        UPDATE Usuario
        SET [Contraseña] = @Contrasena
        WHERE ID = @IDUsuario

        UPDATE RecuperacionClave
        SET Usada = 1
        WHERE IDUsuario = @IDUsuario AND Usada = 0
    COMMIT TRANSACTION

    SELECT CAST(1 AS BIT) AS Usada
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerPaises
AS
BEGIN
    SELECT ID, Nombre, Codigo_ISO, Codigo_Telefono
    FROM Pais
    ORDER BY Nombre
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerProvincias
AS
BEGIN
    SELECT ID, IDPais, Nombre
    FROM Provincia
    ORDER BY Nombre
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerPerfil
    @IDUsuario INT
AS
BEGIN
    SELECT pe.ID, pe.IDUsuario, pe.IDProvincia, pe.Foto, pe.Descripcion, pe.Telefono, pe.Estado_Busqueda,
           pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais, pa.Codigo_Telefono
    FROM Perfil pe
    LEFT JOIN Provincia pr ON pr.ID = pe.IDProvincia
    LEFT JOIN Pais pa ON pa.ID = pr.IDPais
    WHERE pe.IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerCV
    @IDUsuario INT
AS
BEGIN
    SELECT ID, IDUsuario, Nombre_Archivo, Sitio_Web, Fecha_Actualizacion
    FROM CV
    WHERE IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerPreferencia
    @IDUsuario INT
AS
BEGIN
    SELECT p.ID, p.IDUsuario, p.Puesto_Buscado, p.Niveles, p.Modalidades, p.Jornada, p.Contratacion, p.IDProvincia,
           p.Salario_Minimo, p.Salario_Maximo, p.Disponibilidad, pr.Nombre AS Provincia
    FROM Preferencia p
    LEFT JOIN Provincia pr ON pr.ID = p.IDProvincia
    WHERE p.IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GuardarPreferencia
    @IDUsuario INT,
    @Puesto_Buscado NVARCHAR(100),
    @Niveles NVARCHAR(100),
    @Modalidades NVARCHAR(60),
    @Jornada NVARCHAR(20),
    @Contratacion NVARCHAR(40),
    @IDProvincia INT,
    @Salario_Minimo INT,
    @Salario_Maximo INT,
    @Disponibilidad NVARCHAR(20)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Preferencia WHERE IDUsuario = @IDUsuario)
    BEGIN
        INSERT INTO Preferencia (IDUsuario, Puesto_Buscado, Niveles, Modalidades, Jornada, Contratacion, IDProvincia,
                                 Salario_Minimo, Salario_Maximo, Disponibilidad)
        VALUES (@IDUsuario, @Puesto_Buscado, @Niveles, @Modalidades, @Jornada, @Contratacion, @IDProvincia,
                @Salario_Minimo, @Salario_Maximo, @Disponibilidad)
    END
    ELSE
    BEGIN
        UPDATE Preferencia
        SET Puesto_Buscado = @Puesto_Buscado, Niveles = @Niveles, Modalidades = @Modalidades, Jornada = @Jornada,
            Contratacion = @Contratacion, IDProvincia = @IDProvincia, Salario_Minimo = @Salario_Minimo,
            Salario_Maximo = @Salario_Maximo, Disponibilidad = @Disponibilidad
        WHERE IDUsuario = @IDUsuario
    END
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerSectores
AS
BEGIN
    SELECT ID, Nombre
    FROM Sector
    ORDER BY Orden, Nombre
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerCatalogoHabilidades
AS
BEGIN
    SELECT h.ID, h.Nombre, h.IDSector, s.Nombre AS Sector
    FROM Habilidad h
    JOIN Sector s ON s.ID = h.IDSector
    ORDER BY s.Orden, s.Nombre, h.Nombre
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerHabilidadesUsuario
    @IDUsuario INT
AS
BEGIN
    SELECT h.Nombre
    FROM UsuarioHabilidad uh
    JOIN Habilidad h ON h.ID = uh.IDHabilidad
    WHERE uh.IDUsuario = @IDUsuario
    ORDER BY h.Nombre
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE QuitarHabilidadesUsuario
    @IDUsuario INT
AS
BEGIN
    DELETE FROM UsuarioHabilidad
    WHERE IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AgregarHabilidadUsuario
    @IDUsuario INT,
    @Nombre NVARCHAR(60)
AS
BEGIN
    DECLARE @IDHabilidad INT

    IF NOT EXISTS (SELECT 1 FROM Habilidad WHERE Nombre = @Nombre)
    BEGIN
        INSERT INTO Habilidad (Nombre)
        VALUES (@Nombre)
    END

    SELECT TOP 1 @IDHabilidad = ID
    FROM Habilidad
    WHERE Nombre = @Nombre
    ORDER BY ID

    IF NOT EXISTS (SELECT 1 FROM UsuarioHabilidad WHERE IDUsuario = @IDUsuario AND IDHabilidad = @IDHabilidad)
    BEGIN
        INSERT INTO UsuarioHabilidad (IDUsuario, IDHabilidad)
        VALUES (@IDUsuario, @IDHabilidad)
    END
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerCatalogoIdiomas
AS
BEGIN
    SELECT ID, Nombre
    FROM Idioma
    ORDER BY Nombre
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerIdiomasUsuario
    @IDUsuario INT
AS
BEGIN
    SELECT ui.IDIdioma, i.Nombre AS Idioma, ui.Nivel
    FROM UsuarioIdioma ui
    JOIN Idioma i ON i.ID = ui.IDIdioma
    WHERE ui.IDUsuario = @IDUsuario
    ORDER BY i.Nombre
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE QuitarIdiomasUsuario
    @IDUsuario INT
AS
BEGIN
    DELETE FROM UsuarioIdioma
    WHERE IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AgregarIdiomaUsuario
    @IDUsuario INT,
    @IDIdioma INT,
    @Nivel NVARCHAR(20)
AS
BEGIN
    INSERT INTO UsuarioIdioma (IDUsuario, IDIdioma, Nivel)
    VALUES (@IDUsuario, @IDIdioma, @Nivel)
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerExperiencias
    @IDUsuario INT
AS
BEGIN
    SELECT x.ID, x.Puesto, e.Nombre AS Empresa, x.Descripcion, x.Fecha_Inicio, x.Fecha_Finalizacion
    FROM ExperienciaLaboral x
    JOIN Empresa e ON e.ID = x.IDEmpresa
    WHERE x.IDUsuario = @IDUsuario
    ORDER BY CASE WHEN x.Fecha_Finalizacion IS NULL THEN 0 ELSE 1 END, x.Fecha_Inicio DESC
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AgregarExperiencia
    @IDUsuario INT,
    @Empresa NVARCHAR(100),
    @Puesto NVARCHAR(100),
    @Descripcion NVARCHAR(500),
    @Inicio DATE,
    @Fin DATE
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @IDEmpresa INT

    BEGIN TRANSACTION
        IF NOT EXISTS (SELECT 1 FROM Empresa WHERE Nombre = @Empresa)
        BEGIN
            INSERT INTO Empresa (Nombre)
            VALUES (@Empresa)
        END

        SELECT TOP 1 @IDEmpresa = ID
        FROM Empresa
        WHERE Nombre = @Empresa
        ORDER BY ID

        INSERT INTO ExperienciaLaboral (IDUsuario, IDEmpresa, Puesto, Descripcion, Fecha_Inicio, Fecha_Finalizacion)
        VALUES (@IDUsuario, @IDEmpresa, @Puesto, @Descripcion, @Inicio, @Fin)
    COMMIT TRANSACTION
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE EliminarExperiencia
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    DELETE FROM ExperienciaLaboral
    WHERE ID = @ID AND IDUsuario = @IDUsuario

    SELECT @@ROWCOUNT AS Filas
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerFormaciones
    @IDUsuario INT
AS
BEGIN
    SELECT ue.ID, ue.Titulo, ed.Institucion, ue.Fecha_Inicio, ue.Fecha_Fin
    FROM UsuarioEducacion ue
    JOIN Educacion ed ON ed.ID = ue.IDEducacion
    WHERE ue.IDUsuario = @IDUsuario
    ORDER BY CASE WHEN ue.Fecha_Fin IS NULL THEN 0 ELSE 1 END, ue.Fecha_Inicio DESC
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE AgregarFormacion
    @IDUsuario INT,
    @Institucion NVARCHAR(150),
    @Titulo NVARCHAR(150),
    @Inicio DATE,
    @Fin DATE
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @IDEducacion INT

    BEGIN TRANSACTION
        IF NOT EXISTS (SELECT 1 FROM Educacion WHERE Institucion = @Institucion)
        BEGIN
            INSERT INTO Educacion (Institucion)
            VALUES (@Institucion)
        END

        SELECT TOP 1 @IDEducacion = ID
        FROM Educacion
        WHERE Institucion = @Institucion
        ORDER BY ID

        INSERT INTO UsuarioEducacion (IDUsuario, IDEducacion, Titulo, Fecha_Inicio, Fecha_Fin)
        VALUES (@IDUsuario, @IDEducacion, @Titulo, @Inicio, @Fin)
    COMMIT TRANSACTION
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE EliminarFormacion
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    DELETE FROM UsuarioEducacion
    WHERE ID = @ID AND IDUsuario = @IDUsuario

    SELECT @@ROWCOUNT AS Filas
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerInstituciones
AS
BEGIN
    SELECT Institucion
    FROM Educacion
    ORDER BY Institucion
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE BuscarEmpresas
    @Texto NVARCHAR(200) = NULL,
    @Rubro NVARCHAR(60) = NULL,
    @IDPais INT = NULL,
    @IDProvincia INT = NULL,
    @Orden NVARCHAR(20) = NULL
AS
BEGIN
    DECLARE @Patron NVARCHAR(700)
    SET @Patron = CASE WHEN TRIM(ISNULL(@Texto, N'')) = N'' THEN NULL
                   ELSE N'%' + REPLACE(REPLACE(REPLACE(TRIM(@Texto), N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]') + N'%' END

    SELECT e.ID, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.IDUsuario, e.Razon_Social, e.CUIT,
           e.Rubro, e.IDProvincia, e.Telefono, e.Fecha_Registro, pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais,
           (SELECT COUNT(*) FROM OfertaLaboral o
            WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'
              AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))) AS BusquedasActivas
    FROM Empresa e
    LEFT JOIN Provincia pr ON pr.ID = e.IDProvincia
    LEFT JOIN Pais pa ON pa.ID = pr.IDPais
    WHERE (e.IDUsuario IS NOT NULL
           OR EXISTS (SELECT 1 FROM OfertaLaboral o WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'))
      AND (@Patron IS NULL OR e.Nombre LIKE @Patron OR e.Descripcion LIKE @Patron)
      AND (@Rubro IS NULL OR e.Rubro = @Rubro)
      AND (@IDProvincia IS NULL OR e.IDProvincia = @IDProvincia)
      AND (@IDPais IS NULL OR pa.ID = @IDPais)
    ORDER BY CASE WHEN @Orden = 'az' THEN e.Nombre END,
             CASE WHEN @Orden = 'antiguas' THEN e.Fecha_Registro END,
             CASE WHEN @Orden = 'antiguas' THEN e.ID END,
             CASE WHEN ISNULL(@Orden, '') NOT IN ('az', 'antiguas') THEN e.Fecha_Registro END DESC,
             CASE WHEN ISNULL(@Orden, '') NOT IN ('az', 'antiguas') THEN e.ID END DESC
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerEmpresasConBusquedas
    @Cantidad INT
AS
BEGIN
    SELECT TOP (@Cantidad) *
    FROM (
    SELECT e.ID, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.IDUsuario, e.Razon_Social, e.CUIT,
           e.Rubro, e.IDProvincia, e.Telefono, e.Fecha_Registro, pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais,
           (SELECT COUNT(*) FROM OfertaLaboral o
            WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'
              AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))) AS BusquedasActivas
    FROM Empresa e
    LEFT JOIN Provincia pr ON pr.ID = e.IDProvincia
    LEFT JOIN Pais pa ON pa.ID = pr.IDPais
    ) x
    WHERE x.BusquedasActivas > 0
    ORDER BY x.BusquedasActivas DESC, x.Nombre
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerEmpresa
    @ID INT
AS
BEGIN
    SELECT e.ID, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.IDUsuario, e.Razon_Social, e.CUIT,
           e.Rubro, e.IDProvincia, e.Telefono, e.Fecha_Registro, pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais,
           (SELECT COUNT(*) FROM OfertaLaboral o
            WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'
              AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))) AS BusquedasActivas
    FROM Empresa e
    LEFT JOIN Provincia pr ON pr.ID = e.IDProvincia
    LEFT JOIN Pais pa ON pa.ID = pr.IDPais
    WHERE e.ID = @ID
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerEmpresaDeUsuario
    @IDUsuario INT
AS
BEGIN
    SELECT e.ID, e.Nombre, e.Descripcion, e.Logo, e.Ubicacion, e.Sitio_Web, e.IDUsuario, e.Razon_Social, e.CUIT,
           e.Rubro, e.IDProvincia, e.Telefono, e.Fecha_Registro, pr.Nombre AS Provincia, pa.ID AS IDPais, pa.Nombre AS Pais,
           (SELECT COUNT(*) FROM OfertaLaboral o
            WHERE o.IDEmpresa = e.ID AND o.Estado_Publicacion = N'Aprobada'
              AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))) AS BusquedasActivas
    FROM Empresa e
    LEFT JOIN Provincia pr ON pr.ID = e.IDProvincia
    LEFT JOIN Pais pa ON pa.ID = pr.IDPais
    WHERE e.IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ExisteCuit
    @CUIT CHAR(11)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Empresa WHERE CUIT = @CUIT)
        SELECT CAST(1 AS BIT) AS Existe
    ELSE
        SELECT CAST(0 AS BIT) AS Existe
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE NombreEmpresaConCuenta
    @Nombre NVARCHAR(100),
    @Excepto INT = NULL
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Empresa WHERE Nombre = @Nombre AND IDUsuario IS NOT NULL AND ID <> ISNULL(@Excepto, 0))
        SELECT CAST(1 AS BIT) AS Existe
    ELSE
        SELECT CAST(0 AS BIT) AS Existe
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ExisteNombreEmpresa
    @Nombre NVARCHAR(100),
    @Excepto INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Empresa WHERE Nombre = @Nombre AND ID <> @Excepto)
        SELECT CAST(1 AS BIT) AS Existe
    ELSE
        SELECT CAST(0 AS BIT) AS Existe
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ActualizarEmpresa
    @ID INT,
    @IDUsuario INT,
    @Nombre NVARCHAR(100),
    @Descripcion NVARCHAR(500),
    @Ubicacion NVARCHAR(100),
    @Sitio_Web NVARCHAR(200),
    @Rubro NVARCHAR(60),
    @IDProvincia INT,
    @Telefono NVARCHAR(30)
AS
BEGIN
    UPDATE Empresa
    SET Nombre = @Nombre, Descripcion = @Descripcion, Ubicacion = @Ubicacion, Sitio_Web = @Sitio_Web,
        Rubro = @Rubro, IDProvincia = @IDProvincia, Telefono = @Telefono
    WHERE ID = @ID AND IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ActualizarLogo
    @IDUsuario INT,
    @Logo NVARCHAR(260)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @LogoAnterior NVARCHAR(260)

    BEGIN TRANSACTION
        SELECT @LogoAnterior = Logo FROM Empresa WHERE IDUsuario = @IDUsuario

        UPDATE Empresa
        SET Logo = @Logo
        WHERE IDUsuario = @IDUsuario
    COMMIT TRANSACTION

    SELECT @LogoAnterior AS LogoAnterior
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE BuscarOfertas
    @IDUsuarioActual INT,
    @Texto NVARCHAR(200) = NULL,
    @IDProvincia INT = NULL,
    @Modalidades NVARCHAR(200) = NULL,
    @Tipos NVARCHAR(400) = NULL,
    @Dias INT = NULL
AS
BEGIN
    DECLARE @Patron NVARCHAR(700)
    SET @Patron = CASE WHEN TRIM(ISNULL(@Texto, N'')) = N'' THEN NULL
                   ELSE N'%' + REPLACE(REPLACE(REPLACE(TRIM(@Texto), N'[', N'[[]'), N'%', N'[%]'), N'_', N'[_]') + N'%' END

    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.Estado_Publicacion = N'Aprobada' AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))
      AND (@Patron IS NULL OR o.Titulo LIKE @Patron OR o.Descripcion LIKE @Patron OR e.Nombre LIKE @Patron
           OR EXISTS (SELECT 1 FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
                      WHERE op.IDOfertaLaboral = o.ID AND p.Nombre LIKE @Patron))
      AND (@IDProvincia IS NULL OR o.IDProvincia = @IDProvincia OR o.Modalidad = N'Remoto')
      AND (@Modalidades IS NULL OR o.Modalidad IN (SELECT value FROM STRING_SPLIT(@Modalidades, ',')))
      AND (@Tipos IS NULL OR o.Tipo_Contrato IN (SELECT value FROM STRING_SPLIT(@Tipos, ',')))
      AND (@Dias IS NULL OR o.Fecha_Publicacion >= DATEADD(DAY, -@Dias, CAST(GETDATE() AS DATE)))
    ORDER BY o.Fecha_Publicacion DESC, o.ID DESC
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerOferta
    @ID INT,
    @IDUsuarioActual INT
AS
BEGIN
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.ID = @ID
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerOfertasDeEmpresa
    @IDEmpresa INT,
    @IDUsuarioActual INT
AS
BEGIN
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.IDEmpresa = @IDEmpresa
      AND o.Estado_Publicacion = N'Aprobada' AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= CAST(GETDATE() AS DATE))
    ORDER BY o.Fecha_Publicacion DESC, o.ID DESC
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerOfertasPublicadas
    @IDUsuario INT
AS
BEGIN
    DECLARE @IDUsuarioActual INT
    SET @IDUsuarioActual = 0

    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.IDUsuario_Publicador = @IDUsuario
    ORDER BY o.Fecha_Publicacion DESC, o.ID DESC
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE TieneOfertasPublicadas
    @IDUsuario INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM OfertaLaboral WHERE IDUsuario_Publicador = @IDUsuario)
        SELECT CAST(1 AS BIT) AS Tiene
    ELSE
        SELECT CAST(0 AS BIT) AS Tiene
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerTitulosRecientes
    @Cantidad INT
AS
BEGIN
    SELECT TOP (@Cantidad) Titulo
    FROM (
        SELECT o.Titulo, CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha
        FROM OfertaLaboral o
        WHERE o.Estado_Publicacion = N'Aprobada'
        UNION ALL
        SELECT x.Titulo, x.Fecha_Consulta
        FROM OfertaExterna x
    ) t
    ORDER BY Fecha DESC
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE CrearOferta
    @IDUsuario_Publicador INT,
    @IDEmpresa INT = NULL,
    @EmpresaNombre NVARCHAR(100) = NULL,
    @Titulo NVARCHAR(150),
    @Puesto NVARCHAR(100),
    @IDSector INT,
    @Descripcion NVARCHAR(2000),
    @Ubicacion NVARCHAR(100),
    @IDProvincia INT,
    @Modalidad NVARCHAR(20),
    @Tipo_Contrato NVARCHAR(50),
    @Salario INT,
    @Cantidad_Puestos INT,
    @Fecha_Cierre DATE,
    @Estado_Publicacion NVARCHAR(20)
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @ID INT

    BEGIN TRANSACTION
        IF @IDEmpresa IS NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM Empresa WHERE Nombre = @EmpresaNombre)
            BEGIN
                INSERT INTO Empresa (Nombre)
                VALUES (@EmpresaNombre)
            END

            SELECT TOP 1 @IDEmpresa = ID
            FROM Empresa
            WHERE Nombre = @EmpresaNombre
            ORDER BY ID
        END

        INSERT INTO OfertaLaboral (IDEmpresa, Titulo, Descripcion, Ubicacion, Modalidad, Tipo_Contrato, Salario, Cantidad_Puestos,
                                   Fecha_Publicacion, Fecha_Cierre, IDUsuario_Publicador, IDProvincia, Estado_Publicacion)
        VALUES (@IDEmpresa, @Titulo, @Descripcion, @Ubicacion, @Modalidad, @Tipo_Contrato, @Salario, @Cantidad_Puestos,
                CAST(GETDATE() AS DATE), @Fecha_Cierre, @IDUsuario_Publicador, @IDProvincia, @Estado_Publicacion)
        SET @ID = SCOPE_IDENTITY()

        IF NOT EXISTS (SELECT 1 FROM Puesto WHERE Nombre = @Puesto)
        BEGIN
            INSERT INTO Puesto (Nombre, IDSector)
            VALUES (@Puesto, @IDSector)
        END

        UPDATE Puesto
        SET IDSector = @IDSector
        WHERE Nombre = @Puesto AND IDSector IS NULL

        INSERT INTO OfertaPuesto (IDOfertaLaboral, IDPuesto)
        SELECT @ID, ID
        FROM Puesto
        WHERE Nombre = @Puesto
    COMMIT TRANSACTION

    SELECT @ID AS ID
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE CerrarOferta
    @ID INT,
    @IDPublicador INT
AS
BEGIN
    UPDATE OfertaLaboral
    SET Fecha_Cierre = CAST(GETDATE() AS DATE)
    WHERE ID = @ID AND IDUsuario_Publicador = @IDPublicador
      AND (Fecha_Cierre IS NULL OR Fecha_Cierre >= CAST(GETDATE() AS DATE))

    SELECT @@ROWCOUNT AS Filas
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE EliminarOferta
    @ID INT,
    @IDPublicador INT
AS
BEGIN
    SET XACT_ABORT ON

    IF NOT EXISTS (SELECT 1 FROM OfertaLaboral WHERE ID = @ID AND IDUsuario_Publicador = @IDPublicador)
    BEGIN
        SELECT CAST(0 AS BIT) AS Eliminada
        RETURN
    END

    BEGIN TRANSACTION
        DELETE FROM Postulacion
        WHERE IDOfertaLaboral = @ID

        DELETE f
        FROM Favorito f
        JOIN FavoritoOferta fo ON fo.IDFavorito = f.ID_favorito
        WHERE fo.IDOfertaLaboral = @ID

        DELETE FROM OfertaLaboral
        WHERE ID = @ID
    COMMIT TRANSACTION

    SELECT CAST(1 AS BIT) AS Eliminada
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerOfertasPendientes
AS
BEGIN
    DECLARE @IDUsuarioActual INT
    SET @IDUsuarioActual = 0

    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.Estado_Publicacion = N'Pendiente'
    ORDER BY o.Fecha_Publicacion, o.ID
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerOfertasRevisadas
    @Cantidad INT
AS
BEGIN
    DECLARE @IDUsuarioActual INT
    SET @IDUsuarioActual = 0

    SELECT TOP (@Cantidad) *
    FROM (
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    WHERE o.Estado_Publicacion <> N'Pendiente' AND o.Fecha_Revision IS NOT NULL
    ) x
    ORDER BY x.ID DESC
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ContarOfertasPendientes
AS
BEGIN
    SELECT COUNT(*) AS Cantidad
    FROM OfertaLaboral
    WHERE Estado_Publicacion = N'Pendiente'
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE RevisarOferta
    @ID INT,
    @Aprobada BIT,
    @Motivo NVARCHAR(500) = NULL
AS
BEGIN
    UPDATE OfertaLaboral
    SET Estado_Publicacion = CASE WHEN @Aprobada = 1 THEN N'Aprobada' ELSE N'Rechazada' END,
        Motivo_Rechazo = CASE WHEN @Aprobada = 1 THEN NULL ELSE @Motivo END,
        Fecha_Revision = CAST(GETDATE() AS DATE),
        Fecha_Publicacion = CASE WHEN @Aprobada = 1 THEN CAST(GETDATE() AS DATE) ELSE Fecha_Publicacion END
    WHERE ID = @ID AND Estado_Publicacion = N'Pendiente'

    SELECT @@ROWCOUNT AS Filas
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GuardarOfertaExterna
    @ID_Externo NVARCHAR(200),
    @Titulo NVARCHAR(300),
    @Empresa NVARCHAR(200),
    @Logo NVARCHAR(1000),
    @Ubicacion NVARCHAR(200),
    @Descripcion NVARCHAR(MAX),
    @Es_Remoto BIT,
    @Tipo_Contrato NVARCHAR(50),
    @Salario NVARCHAR(100),
    @Link_Postulacion NVARCHAR(2000),
    @Publicador NVARCHAR(100),
    @Fecha_Publicacion DATETIME2
AS
BEGIN
    DECLARE @IDUsuarioActual INT
    SET @IDUsuarioActual = 0

    IF EXISTS (SELECT 1 FROM OfertaExterna WHERE ID_Externo = @ID_Externo)
    BEGIN
        UPDATE OfertaExterna
        SET Titulo = @Titulo, Empresa = @Empresa, Logo = @Logo, Ubicacion = @Ubicacion, Descripcion = @Descripcion,
            Es_Remoto = @Es_Remoto, Tipo_Contrato = @Tipo_Contrato, Salario = @Salario, Link_Postulacion = @Link_Postulacion,
            Publicador = @Publicador, Fecha_Publicacion = @Fecha_Publicacion, Fecha_Consulta = SYSUTCDATETIME()
        WHERE ID_Externo = @ID_Externo
    END
    ELSE
    BEGIN
        INSERT INTO OfertaExterna (ID_Externo, Titulo, Empresa, Logo, Ubicacion, Descripcion, Es_Remoto, Tipo_Contrato,
                                   Salario, Link_Postulacion, Publicador, Fecha_Publicacion)
        VALUES (@ID_Externo, @Titulo, @Empresa, @Logo, @Ubicacion, @Descripcion, @Es_Remoto, @Tipo_Contrato,
                @Salario, @Link_Postulacion, @Publicador, @Fecha_Publicacion)
    END

    SELECT CAST(1 AS BIT) AS EsExterna, x.ID, x.ID_Externo, x.Titulo, ISNULL(x.Empresa, N'Empresa sin nombre') AS Empresa,
           x.Logo, x.Ubicacion, CASE WHEN x.Es_Remoto = 1 THEN N'Remoto' ELSE NULL END AS Modalidad, x.Tipo_Contrato,
           x.Salario AS SalarioTexto, x.Descripcion, x.Fecha_Publicacion, x.Link_Postulacion, x.Publicador,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaExterna = x.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaExterna = x.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaExterna x
    WHERE x.ID_Externo = @ID_Externo
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerOfertaExterna
    @ID INT,
    @IDUsuarioActual INT
AS
BEGIN
    SELECT CAST(1 AS BIT) AS EsExterna, x.ID, x.ID_Externo, x.Titulo, ISNULL(x.Empresa, N'Empresa sin nombre') AS Empresa,
           x.Logo, x.Ubicacion, CASE WHEN x.Es_Remoto = 1 THEN N'Remoto' ELSE NULL END AS Modalidad, x.Tipo_Contrato,
           x.Salario AS SalarioTexto, x.Descripcion, x.Fecha_Publicacion, x.Link_Postulacion, x.Publicador,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaExterna = x.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaExterna = x.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaExterna x
    WHERE x.ID = @ID
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerMarcasExternas
    @IDUsuario INT,
    @IDs NVARCHAR(MAX)
AS
BEGIN
    SELECT x.ID,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaExterna = x.ID AND po.IDUsuario = @IDUsuario)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaExterna = x.ID AND f.IDUsuario = @IDUsuario)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaExterna x
    WHERE x.ID IN (SELECT CAST(value AS INT) FROM STRING_SPLIT(@IDs, ','))
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE GuardarOferta
    @IDUsuario INT,
    @IDOferta INT,
    @EsExterna BIT
AS
BEGIN
    SET XACT_ABORT ON
    DECLARE @Puede BIT
    DECLARE @IDFavorito INT
    SET @Puede = 0

    BEGIN TRANSACTION
        IF @EsExterna = 1
        BEGIN
            IF EXISTS (SELECT 1 FROM OfertaExterna WHERE ID = @IDOferta)
               AND NOT EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                               WHERE f.IDUsuario = @IDUsuario AND fo.IDOfertaExterna = @IDOferta)
                SET @Puede = 1
        END
        ELSE
        BEGIN
            IF EXISTS (SELECT 1 FROM OfertaLaboral WHERE ID = @IDOferta AND Estado_Publicacion = N'Aprobada')
               AND NOT EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                               WHERE f.IDUsuario = @IDUsuario AND fo.IDOfertaLaboral = @IDOferta)
                SET @Puede = 1
        END

        IF @Puede = 1
        BEGIN
            INSERT INTO Favorito (IDUsuario, fecha_guardado)
            VALUES (@IDUsuario, CAST(GETDATE() AS DATE))
            SET @IDFavorito = SCOPE_IDENTITY()

            INSERT INTO FavoritoOferta (IDFavorito, IDOfertaLaboral, IDOfertaExterna)
            VALUES (@IDFavorito,
                    CASE WHEN @EsExterna = 0 THEN @IDOferta END,
                    CASE WHEN @EsExterna = 1 THEN @IDOferta END)
        END
    COMMIT TRANSACTION

    SELECT @Puede AS Guardada
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE QuitarGuardada
    @IDUsuario INT,
    @IDOferta INT,
    @EsExterna BIT
AS
BEGIN
    DELETE f
    FROM Favorito f
    JOIN FavoritoOferta fo ON fo.IDFavorito = f.ID_favorito
    WHERE f.IDUsuario = @IDUsuario
      AND ((@EsExterna = 1 AND fo.IDOfertaExterna = @IDOferta)
           OR (@EsExterna = 0 AND fo.IDOfertaLaboral = @IDOferta))

    SELECT @@ROWCOUNT AS Filas
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerGuardadas
    @IDUsuario INT
AS
BEGIN
    DECLARE @IDUsuarioActual INT
    SET @IDUsuarioActual = @IDUsuario

    SELECT w.*, CAST(f.fecha_guardado AS DATETIME2) AS Fecha_Guardado, f.ID_favorito AS IDFavorito
    FROM (
    SELECT CAST(0 AS BIT) AS EsExterna, o.ID, o.Titulo, e.Nombre AS Empresa, e.ID AS IDEmpresa, e.Logo, o.Ubicacion,
           pr.Nombre AS Provincia, o.IDProvincia, o.Modalidad, o.Tipo_Contrato, o.Salario, o.Cantidad_Puestos, o.Descripcion,
           CAST(o.Fecha_Publicacion AS DATETIME2) AS Fecha_Publicacion, CAST(o.Fecha_Cierre AS DATETIME2) AS Fecha_Cierre,
           o.IDUsuario_Publicador, pu.Tipo AS TipoPublicador, o.Estado_Publicacion, o.Motivo_Rechazo,
           (SELECT STRING_AGG(p.Nombre, ', ') FROM OfertaPuesto op JOIN Puesto p ON p.ID = op.IDPuesto
            WHERE op.IDOfertaLaboral = o.ID) AS Puestos,
           (SELECT COUNT(*) FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID) AS CantidadPostulantes,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaLaboral = o.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaLaboral = o.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaLaboral o
    JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Usuario pu ON pu.ID = o.IDUsuario_Publicador
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    ) w
    JOIN FavoritoOferta fo ON fo.IDOfertaLaboral = w.ID
    JOIN Favorito f ON f.ID_favorito = fo.IDFavorito AND f.IDUsuario = @IDUsuario
    ORDER BY f.ID_favorito DESC

    SELECT w.*, CAST(f.fecha_guardado AS DATETIME2) AS Fecha_Guardado, f.ID_favorito AS IDFavorito
    FROM (
    SELECT CAST(1 AS BIT) AS EsExterna, x.ID, x.ID_Externo, x.Titulo, ISNULL(x.Empresa, N'Empresa sin nombre') AS Empresa,
           x.Logo, x.Ubicacion, CASE WHEN x.Es_Remoto = 1 THEN N'Remoto' ELSE NULL END AS Modalidad, x.Tipo_Contrato,
           x.Salario AS SalarioTexto, x.Descripcion, x.Fecha_Publicacion, x.Link_Postulacion, x.Publicador,
           CASE WHEN EXISTS (SELECT 1 FROM Postulacion po WHERE po.IDOfertaExterna = x.ID AND po.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS YaPostulado,
           CASE WHEN EXISTS (SELECT 1 FROM FavoritoOferta fo JOIN Favorito f ON f.ID_favorito = fo.IDFavorito
                             WHERE fo.IDOfertaExterna = x.ID AND f.IDUsuario = @IDUsuarioActual)
                THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS Guardada
    FROM OfertaExterna x
    ) w
    JOIN FavoritoOferta fo ON fo.IDOfertaExterna = w.ID
    JOIN Favorito f ON f.ID_favorito = fo.IDFavorito AND f.IDUsuario = @IDUsuario
    ORDER BY f.ID_favorito DESC
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ContarGuardadas
    @IDUsuario INT
AS
BEGIN
    SELECT COUNT(*) AS Cantidad
    FROM Favorito
    WHERE IDUsuario = @IDUsuario
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE Postular
    @IDUsuario INT,
    @IDOferta INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Postulacion WHERE IDUsuario = @IDUsuario AND IDOfertaLaboral = @IDOferta)
    BEGIN
        SELECT 0 AS Filas
        RETURN
    END

    INSERT INTO Postulacion (IDUsuario, IDOfertaLaboral, Fecha, Estado)
    VALUES (@IDUsuario, @IDOferta, CAST(GETDATE() AS DATE), N'Enviada')

    SELECT @@ROWCOUNT AS Filas
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE RegistrarPostulacionExterna
    @IDUsuario INT,
    @IDOferta INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM OfertaExterna WHERE ID = @IDOferta)
       OR EXISTS (SELECT 1 FROM Postulacion WHERE IDUsuario = @IDUsuario AND IDOfertaExterna = @IDOferta)
    BEGIN
        SELECT 0 AS Filas
        RETURN
    END

    INSERT INTO Postulacion (IDUsuario, IDOfertaExterna, Fecha, Estado)
    VALUES (@IDUsuario, @IDOferta, CAST(GETDATE() AS DATE), N'Enviada')

    SELECT @@ROWCOUNT AS Filas
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerPostulaciones
    @IDUsuario INT
AS
BEGIN
    SELECT po.ID, po.Estado, CAST(po.Fecha AS DATETIME2) AS Fecha, po.IDOfertaLaboral, po.IDOfertaExterna,
           COALESCE(o.Titulo, x.Titulo) AS Titulo,
           COALESCE(e.Nombre, x.Empresa, N'Empresa sin nombre') AS Empresa,
           COALESCE(o.Ubicacion, pr.Nombre, x.Ubicacion) AS Ubicacion,
           CASE WHEN x.ID IS NULL THEN N'Workly' ELSE x.Publicador END AS Publicador,
           x.Link_Postulacion
    FROM Postulacion po
    LEFT JOIN OfertaLaboral o ON o.ID = po.IDOfertaLaboral
    LEFT JOIN Empresa e ON e.ID = o.IDEmpresa
    LEFT JOIN Provincia pr ON pr.ID = o.IDProvincia
    LEFT JOIN OfertaExterna x ON x.ID = po.IDOfertaExterna
    WHERE po.IDUsuario = @IDUsuario
    ORDER BY po.Fecha DESC, po.ID DESC
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE CambiarEstadoPostulacion
    @IDUsuario INT,
    @ID INT,
    @Estado NVARCHAR(20)
AS
BEGIN
    UPDATE Postulacion
    SET Estado = @Estado
    WHERE ID = @ID AND IDUsuario = @IDUsuario

    SELECT @@ROWCOUNT AS Filas
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE EliminarPostulacion
    @IDUsuario INT,
    @ID INT
AS
BEGIN
    DELETE FROM Postulacion
    WHERE ID = @ID AND IDUsuario = @IDUsuario

    SELECT @@ROWCOUNT AS Filas
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ContarPostulacionesPorEstado
    @IDUsuario INT
AS
BEGIN
    SELECT Estado, COUNT(*) AS Cantidad
    FROM Postulacion
    WHERE IDUsuario = @IDUsuario
    GROUP BY Estado
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerPostulantes
    @IDOferta INT
AS
BEGIN
    SELECT po.ID AS IDPostulacion, u.ID AS IDUsuario, CAST(po.Fecha AS DATETIME2) AS Fecha, u.Nombre, u.Apellido, u.Email,
           pe.Telefono, pe.Foto, pr.Nombre AS Provincia, pe.Estado_Busqueda, pf.Puesto_Buscado, cv.Nombre_Archivo
    FROM Postulacion po
    JOIN Usuario u ON u.ID = po.IDUsuario
    LEFT JOIN Perfil pe ON pe.IDUsuario = u.ID
    LEFT JOIN Provincia pr ON pr.ID = pe.IDProvincia
    LEFT JOIN Preferencia pf ON pf.IDUsuario = u.ID
    LEFT JOIN CV cv ON cv.IDUsuario = u.ID
    WHERE po.IDOfertaLaboral = @IDOferta
    ORDER BY po.Fecha DESC, po.ID DESC
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE ObtenerPostulacionDePublicador
    @ID INT,
    @IDPublicador INT
AS
BEGIN
    SELECT po.IDUsuario, o.ID AS IDOferta
    FROM Postulacion po
    JOIN OfertaLaboral o ON o.ID = po.IDOfertaLaboral
    WHERE po.ID = @ID AND o.IDUsuario_Publicador = @IDPublicador
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE EstadisticasPostulacionesEmpresa
    @IDEmpresa INT,
    @OfertasSobrePromedio INT = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @OfertasSobrePromedio = 0;

    IF @IDEmpresa IS NULL OR NOT EXISTS (SELECT 1 FROM Empresa WHERE ID = @IDEmpresa)
    BEGIN
        SELECT N'La empresa indicada no existe.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Empresa NVARCHAR(100) = (SELECT Nombre FROM Empresa WHERE ID = @IDEmpresa);

    IF NOT EXISTS (SELECT 1 FROM OfertaLaboral WHERE IDEmpresa = @IDEmpresa AND Estado_Publicacion = N'Aprobada')
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
           (SELECT COUNT(*) FROM Postulacion AS p WHERE p.IDOfertaLaboral = o.ID)
    FROM OfertaLaboral AS o
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE RankingCandidatosPorHabilidades
    @IDOfertaLaboral INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IDOfertaLaboral IS NULL OR NOT EXISTS (SELECT 1 FROM OfertaLaboral WHERE ID = @IDOfertaLaboral)
    BEGIN
        SELECT N'La oferta indicada no existe.' AS Mensaje;
        RETURN 1;
    END

    IF NOT EXISTS (SELECT 1 FROM OfertaPuesto WHERE IDOfertaLaboral = @IDOfertaLaboral)
    BEGIN
        SELECT N'La oferta no tiene puestos asociados, así que no se puede comparar con las habilidades de los candidatos.' AS Mensaje;
        RETURN 2;
    END

    DECLARE @Sectores TABLE (IDSector INT PRIMARY KEY, Nombre NVARCHAR(60));

    INSERT INTO @Sectores (IDSector, Nombre)
    SELECT DISTINCT s.ID, s.Nombre
    FROM OfertaPuesto AS op
    JOIN Puesto AS pu ON pu.ID = op.IDPuesto
    JOIN Sector AS s ON s.ID = pu.IDSector
    WHERE op.IDOfertaLaboral = @IDOfertaLaboral;

    IF NOT EXISTS (SELECT 1 FROM @Sectores)
    BEGIN
        SELECT N'Los puestos de la oferta no tienen un sector asignado, así que no se puede comparar con las habilidades de los candidatos.' AS Mensaje;
        RETURN 2;
    END

    IF NOT EXISTS (SELECT 1 FROM Postulacion WHERE IDOfertaLaboral = @IDOfertaLaboral)
    BEGIN
        SELECT N'La oferta todavía no recibió postulaciones.' AS Mensaje;
        RETURN 2;
    END

    DECLARE @Titulo NVARCHAR(150) = (SELECT Titulo FROM OfertaLaboral WHERE ID = @IDOfertaLaboral);
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
    FROM Postulacion AS p
    JOIN Usuario AS u ON u.ID = p.IDUsuario
    CROSS APPLY (
        SELECT COUNT(*) AS Cantidad
        FROM UsuarioHabilidad AS uh
        WHERE uh.IDUsuario = u.ID
    ) AS total
    CROSS APPLY (
        SELECT COUNT(*) AS Cantidad, STRING_AGG(h.Nombre, N', ') WITHIN GROUP (ORDER BY h.Nombre) AS Lista
        FROM UsuarioHabilidad AS uh
        JOIN Habilidad AS h ON h.ID = uh.IDHabilidad
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE CompararSeleccionEmpresas
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
    FROM Empresa AS e
    JOIN OfertaLaboral AS o ON o.IDEmpresa = e.ID
    JOIN Postulacion AS p ON p.IDOfertaLaboral = o.ID
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE OfertasFavoritasSinPostulacion
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
        FROM Favorito AS f
        JOIN FavoritoOferta AS fo ON fo.IDFavorito = f.ID_favorito
    ),
    ConPostulacion AS (
        SELECT
            g.TipoOferta,
            g.IDOferta,
            CASE WHEN EXISTS (
                SELECT 1 FROM Postulacion AS p
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
    LEFT JOIN OfertaLaboral AS o ON r.TipoOferta = N'Workly' AND o.ID = r.IDOferta
    LEFT JOIN Empresa AS e ON e.ID = o.IDEmpresa
    LEFT JOIN OfertaExterna AS x ON r.TipoOferta = N'Externa' AND x.ID = r.IDOferta
    ORDER BY r.UsuariosQueGuardaron DESC, PorcentajeSinPostularse DESC, Oferta;

    RETURN 0;
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE DiagnosticoOferta
    @IDOfertaLaboral INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @IDOfertaLaboral IS NULL OR NOT EXISTS (SELECT 1 FROM OfertaLaboral WHERE ID = @IDOfertaLaboral)
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
    FROM OfertaLaboral
    WHERE ID = @IDOfertaLaboral;

    SET @Vigencia = CASE
        WHEN @Estado = N'Pendiente' THEN N'En revisión'
        WHEN @Estado = N'Rechazada' THEN N'Rechazada'
        WHEN @Cierre IS NOT NULL AND @Cierre < @Hoy THEN N'Cerrada'
        ELSE N'Vigente' END;
    SET @DiasPublicada = DATEDIFF(DAY, @Publicacion, @Hoy);
    SET @DiasRestantes = CASE WHEN @Vigencia = N'Vigente' AND @Cierre IS NOT NULL THEN DATEDIFF(DAY, @Hoy, @Cierre) END;

    SELECT @Postulaciones = COUNT(*), @Pase = ISNULL(SUM(CASE WHEN Estado = N'Pasé' THEN 1 ELSE 0 END), 0)
    FROM Postulacion
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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE RecomendarOfertasParaUsuario
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

    IF @IDUsuario IS NULL OR NOT EXISTS (SELECT 1 FROM Usuario WHERE ID = @IDUsuario)
    BEGIN
        SELECT N'El usuario indicado no existe.' AS Mensaje;
        RETURN 1;
    END

    IF EXISTS (SELECT 1 FROM Usuario WHERE ID = @IDUsuario AND Tipo <> N'Persona')
    BEGIN
        SELECT N'Las recomendaciones son para cuentas de persona, no de empresa.' AS Mensaje;
        RETURN 1;
    END

    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @TienePreferencia BIT = 0, @IDProvincia INT, @Modalidades NVARCHAR(60), @PuestoBuscado NVARCHAR(100), @Patron NVARCHAR(320);
    DECLARE @HabilidadesConSector INT;

    IF EXISTS (SELECT 1 FROM Preferencia WHERE IDUsuario = @IDUsuario)
    BEGIN
        SET @TienePreferencia = 1;
        SELECT @IDProvincia = IDProvincia, @Modalidades = Modalidades, @PuestoBuscado = NULLIF(LTRIM(RTRIM(Puesto_Buscado)), N'')
        FROM Preferencia
        WHERE IDUsuario = @IDUsuario;
    END

    SELECT @HabilidadesConSector = COUNT(*)
    FROM UsuarioHabilidad AS uh
    JOIN Habilidad AS h ON h.ID = uh.IDHabilidad
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
    FROM OfertaLaboral AS o
    JOIN Empresa AS e ON e.ID = o.IDEmpresa
    LEFT JOIN Provincia AS pr ON pr.ID = o.IDProvincia
    OUTER APPLY (
        SELECT COUNT(DISTINCT uh.IDHabilidad) AS Coincidencias
        FROM OfertaPuesto AS op
        JOIN Puesto AS p ON p.ID = op.IDPuesto
        JOIN Habilidad AS h ON h.IDSector = p.IDSector
        JOIN UsuarioHabilidad AS uh ON uh.IDHabilidad = h.ID AND uh.IDUsuario = @IDUsuario
        WHERE op.IDOfertaLaboral = o.ID
    ) AS hab
    OUTER APPLY (
        SELECT STRING_AGG(p.Nombre, N', ') AS Puestos
        FROM OfertaPuesto AS op
        JOIN Puesto AS p ON p.ID = op.IDPuesto
        WHERE op.IDOfertaLaboral = o.ID
    ) AS pu
    WHERE o.Estado_Publicacion = N'Aprobada'
      AND (o.Fecha_Cierre IS NULL OR o.Fecha_Cierre >= @Hoy)
      AND ISNULL(o.IDUsuario_Publicador, 0) <> @IDUsuario
      AND NOT EXISTS (SELECT 1 FROM Postulacion AS p WHERE p.IDUsuario = @IDUsuario AND p.IDOfertaLaboral = o.ID);

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

USE [master]
GO
ALTER DATABASE [Workly] SET  READ_WRITE 
GO
