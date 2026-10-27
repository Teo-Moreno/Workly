# Workly

Plataforma para encontrar y postularse a ofertas laborales que encajan con tu perfil, y seguir todo el proceso en un solo lugar.

Proyecto ASP.NET Core MVC (.NET 9). Las vistas están maquetadas con HTML, CSS y JavaScript propios (sin Bootstrap), siguiendo el Figma del proyecto:

- **Guidelines**: UI Kit (tipografía, colores, íconos, campos, botones, cargas, notificaciones y selectores).
- **Media**: wireframes de cada pantalla.
- **Alta**: landing a color, usada como referencia visual para todas las vistas.

## Cómo correrlo

1. **Crear la base de datos.** Abrir `script.sql` (en la raíz del repositorio) en SQL Server Management Studio y ejecutarlo (F5). Crea la base `Workly`, todas las tablas del diagrama, datos de ejemplo y una cuenta de prueba. Se puede volver a ejecutar sin romper nada: solo crea lo que falta. Para empezar de cero, al principio del script hay un bloque comentado que borra la base.
2. **Revisar la cadena de conexión** en `appsettings.json` (`ConnectionStrings › Workly`). Por defecto usa la instancia local con autenticación de Windows:
   ```json
   "Workly": "Server=localhost;Database=Workly;Trusted_Connection=True;TrustServerCertificate=True;"
   ```
   - Con SQL Server Express: `Server=localhost\\SQLEXPRESS;...` (en el JSON la barra va doble).
   - Con usuario y contraseña de SQL Server: `Server=localhost;Database=Workly;User Id=sa;Password=...;TrustServerCertificate=True;`
3. **Correr el proyecto** (`dotnet run` o F5 en Visual Studio). Los paquetes `Dapper` y `Microsoft.Data.SqlClient` se descargan solos.

4. **Clave de JSearch** (ofertas de LinkedIn y otros sitios, vía RapidAPI). No está en el repositorio: cada integrante la guarda una vez en su compu desde la carpeta del proyecto:
   ```
   dotnet user-secrets set "JSearch:ApiKey" "<la clave del equipo>"
   ```
   Queda guardada fuera del proyecto y la app la lee como `JSearch:ApiKey`. En el servidor se usa la variable de entorno `JSearch__ApiKey`. El endpoint de búsqueda es `https://jsearch.p.rapidapi.com/search-v2`.

**Cuenta de prueba:** `sofia.martinez@mail.com` / `Workly2026`

### Qué funciona con la base

- **Crear cuenta** (`/Cuenta/CrearCuenta`): registro en 3 pasos que guarda en las tablas `Usuario`, `Perfil` y `CV` dentro de una transacción. Se elige país y provincia (la lista de provincias depende del país) y el teléfono se escribe solo con números: el prefijo del país (+54) aparece solo y los espacios y el guion se ponen automáticamente. Valida en el navegador y en el servidor (email repetido, contraseña de 8+ caracteres con letras y números, formatos y tamaño de archivos). Al terminar inicia la sesión.
- **Iniciar sesión** (`/Cuenta/IniciarSesion`) con "Recordarme" (sesión de 14 días) y vuelta a la página que se quería ver.
- **Cerrar sesión** desde el menú de usuario.
- **Páginas protegidas:** todo lo que está dentro de la app (panel, empleos, postulaciones, empresas, notificaciones, perfil) pide iniciar sesión.
- **Mi perfil** y la pestaña **Cuenta** de Configuración muestran los datos reales: nombre, email, ubicación, teléfono, descripción, foto, sitio web, CV (descarga privada en `/Perfil/DescargarCV`), experiencia y formación.
- La navbar muestra el nombre, la ubicación y la foto (o las iniciales) de quien inició sesión.

Las contraseñas se guardan con hash PBKDF2-SHA256 (600.000 iteraciones y sal aleatoria), nunca en texto plano. Las fotos se guardan en `wwwroot/uploads/fotos` y los CV en `ArchivosPrivados/cv`, fuera de `wwwroot`, así solo los descarga su dueño. Las dos carpetas están en `.gitignore`.

### Qué sigue siendo visual

Ofertas, postulaciones, empresas, notificaciones, preferencias, habilidades, idiomas y la edición del perfil todavía usan `Models/DatosDeEjemplo.cs`. Las tablas `OfertaLaboral`, `Empresa`, `Postulacion`, `Favorito` y `FavoritoOferta` ya existen en la base y tienen datos de ejemplo para conectarlas en la próxima etapa.

## Base de datos

`script.sql` (en la raíz) sigue el diagrama de la base (DLR):

| Tabla | Para qué |
| --- | --- |
| `Pais` / `Provincia` | Países (con su prefijo telefónico, por ejemplo +54) y sus provincias. Por ahora, Argentina y sus 24 jurisdicciones |
| `Usuario` | Nombre, apellido, email (único), contraseña (hash) y fecha de registro |
| `Perfil` | Foto, descripción, provincia donde vive y teléfono con prefijo (uno por usuario) |
| `CV` | Archivo del CV y sitio web (uno por usuario) |
| `Educacion` / `UsuarioEducacion` | Instituciones y la formación de cada usuario |
| `Empresa` / `ExperienciaLaboral` | Empresas y la experiencia de cada usuario |
| `OfertaLaboral` | Ofertas publicadas por las empresas, con la cantidad de puestos |
| `Puesto` / `OfertaPuesto` | Puestos y a qué ofertas corresponden (N a N) |
| `Favorito` / `FavoritoOferta` | Ofertas guardadas |
| `Postulacion` | Postulaciones de cada usuario (una por oferta) y su estado |

Para tenerlo más ordenado, el mismo script también está separado en tres archivos (se ejecutan en este orden):

| Archivo | Contenido |
| --- | --- |
| `BaseDeDatos/1_Estructura.sql` | Crea la base, las tablas, sus claves, controles e índices |
| `BaseDeDatos/2_DatosDePrueba.sql` | Países y provincias, y los datos de ejemplo con la cuenta de prueba |
| `BaseDeDatos/3_StoredProcedures.sql` | Un stored procedure por cada consulta de `Models/BD.cs`, con el mismo nombre |

`script.sql` sigue siendo el que se usa para crear y actualizar la base. Si se cambia algo en la estructura o en los datos, hay que cambiarlo en los dos lados.

Los diagramas están en `BaseDeDatos/DER.drawio` y `BaseDeDatos/DLR.drawio` (se abren con draw.io). Si la base se creó con una versión anterior del script, volver a ejecutarlo la actualiza sin perder datos.

## Vistas

| Ruta | Vista | Referencia |
| --- | --- | --- |
| `/` | Landing pública | Figma › Alta · Landing |
| `/Cuenta/IniciarSesion` | Iniciar sesión | User flow (Miro) |
| `/Cuenta/CrearCuenta` | Registro en 3 pasos | Barra de progreso del UI Kit |
| `/Cuenta/RecuperarClave` | Recuperar contraseña | — |
| `/Panel` | Inicio de la persona logueada | Componentes de Alta |
| `/Empleos` | Buscar trabajo (filtros, resultados y vista previa) | Media · WF 02 |
| `/Empleos/Detalle/{id}` | Detalle de oferta | Media · 06, 07 y 08 |
| `/Postulaciones` | Tablero, lista, guardadas y archivadas | Media · WF 03 |
| `/Empresas` | Listado de empresas | Media · WF 04 |
| `/Empresas/Detalle/{id}` | Perfil de empresa y ofertas disponibles | Mapa de sitio (Miro) |
| `/Perfil` | Mi perfil | Media · WF 05 |
| `/Perfil/Configuracion` | Cuenta, preferencias, notificaciones y privacidad | Mapa de sitio (Miro) |
| `/Perfil/Ayuda` | Ayuda y soporte | Mapa de sitio (Miro) |
| `/Notificaciones` | Todas las notificaciones | UI Kit › 07 |
| `/Home/UiKit` | Guía visual con todos los componentes | Figma › Guidelines |
| `/Home/Privacy`, `/Home/Terminos` | Legales | — |

## Estructura

- `Models/BD.cs`: acceso a SQL Server con Dapper (consultas con parámetros).
- `Models/Usuario.cs`, `Perfil.cs`, `CV.cs`: una clase por tabla. `Models/CuentaViewModels.cs`: modelos de los formularios y de "Mi perfil".
- `Models/Contrasenas.cs`: hash y verificación de contraseñas. `Models/Archivos.cs`: validación y guardado de la foto y el CV.
- `Models/UsuarioActual.cs`: datos de quien inició sesión en las vistas (`User.Nombre()`, `User.Iniciales()`…). `Models/ValidacionHtml.cs`: errores del servidor con el estilo del UI Kit.
- `Models/DatosDeEjemplo.cs`: datos de ejemplo (ofertas, empresas, postulaciones y notificaciones) tomados de los wireframes. Reemplazar por la base de datos manteniendo los mismos métodos.
- `Views/Shared/_Layout.cshtml`: layout público (landing y legales).
- `Views/Shared/_LayoutApp.cshtml`: layout de la app (navbar con notificaciones y menú de usuario).
- `Views/Shared/_LayoutCuenta.cshtml`: layout de iniciar sesión y registro.
- `Views/Shared/_*.cshtml`: componentes reutilizables (tarjetas de oferta, empresa y postulación, panel de notificaciones, pop up de postulación).
- `wwwroot/css/tokens.css`: colores, tipografía, radios y sombras del UI Kit.
- `wwwroot/css/componentes.css`: componentes del UI Kit (botones, campos, casillas, pestañas, snackbars, pop ups…).
- `wwwroot/css/paginas.css`: estilos de cada pantalla.
- `wwwroot/js/site.js`: interacciones visuales (desplegables, pestañas, filtros, guardar, postularse, tablero con arrastrar y soltar, registro en pasos). Se activan con atributos `data-*`.
- `wwwroot/img/iconos.svg`: sprite de íconos (24 px, trazo de 2 px).

## Íconos

```cshtml
<icono nombre="alarm" />
<icono nombre="near-me" tamano="14" class="texto-acento" />
<icono nombre="close-big" etiqueta="Cerrar" />  @* con etiqueta se anuncia a lectores de pantalla *@
```

La lista completa de nombres está en `/Home/UiKit`.

## Tipografía

El UI Kit define **Cardo** (lectura) y **The Seasons** (principal). Cardo se carga desde Google Fonts. The Seasons es una fuente comercial: si se suma el kit de Adobe Fonts, alcanza con cambiar `--fuente-titulos` en `wwwroot/css/tokens.css`.
