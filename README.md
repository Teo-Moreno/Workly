# Workly

Plataforma para encontrar y postularse a ofertas laborales que encajan con tu perfil, y seguir todo el proceso en un solo lugar.

Proyecto ASP.NET Core MVC (.NET 9). Las vistas están maquetadas con HTML, CSS y JavaScript propios (sin Bootstrap), siguiendo el Figma del proyecto:

- **Guidelines**: UI Kit (tipografía, colores, íconos, campos, botones, cargas, notificaciones y selectores).
- **Media**: wireframes de cada pantalla.
- **Alta**: landing a color, usada como referencia visual para todas las vistas.

## Cómo correrlo

1. **Crear la base de datos.** Abrir `script.sql` (en la raíz del repositorio) en SQL Server Management Studio y ejecutarlo (F5). Crea la base `Workly` con todas sus tablas, o actualiza una base anterior sin perder datos. Se puede volver a ejecutar sin romper nada: solo crea lo que falta. Para empezar de cero, al principio del script hay un bloque comentado que borra la base.
   - No carga datos inventados: solo países y provincias, los catálogos de habilidades e idiomas y la cuenta moderadora.
   - Si la base tiene los datos de ejemplo de versiones anteriores (Sofía Martínez y las ofertas de ejemplo), `BaseDeDatos/BorrarDatosDeEjemplo.sql` los borra.
2. **Revisar la cadena de conexión** en `appsettings.json` (`ConnectionStrings › Workly`). Por defecto usa la instancia local con autenticación de Windows:
   ```json
   "Workly": "Server=localhost;Database=Workly;Trusted_Connection=True;TrustServerCertificate=True;"
   ```
   - Con SQL Server Express: `Server=localhost\\SQLEXPRESS;...` (en el JSON la barra va doble).
   - Con usuario y contraseña de SQL Server: `Server=localhost;Database=Workly;User Id=sa;Password=...;TrustServerCertificate=True;`
3. **Clave de JSearch** (ofertas de LinkedIn, Bumeran, Computrabajo y otros sitios, vía RapidAPI). No está en el repositorio: cada integrante la guarda una vez en su compu desde la carpeta del proyecto:
   ```
   dotnet user-secrets set "JSearch:ApiKey" "<la clave del equipo>"
   ```
   En el servidor se usa la variable de entorno `JSearch__ApiKey`. El endpoint es `https://jsearch.p.rapidapi.com/search-v2`. Cada búsqueda se guarda 6 horas en memoria para no gastar pedidos de más.
4. **Google y LinkedIn (opcional).** Los botones "con Google" y "con LinkedIn" aparecen solo si están sus claves:
   ```
   dotnet user-secrets set "Authentication:Google:ClientId" "..."
   dotnet user-secrets set "Authentication:Google:ClientSecret" "..."
   dotnet user-secrets set "Authentication:LinkedIn:ClientId" "..."
   dotnet user-secrets set "Authentication:LinkedIn:ClientSecret" "..."
   ```
   - Google: en Google Cloud Console › APIs y servicios › Credenciales, crear un "ID de cliente de OAuth" de tipo aplicación web con los URI de redirección autorizados `https://localhost:7108/signin-google` y `http://localhost:5128/signin-google` (los puertos de `Properties/launchSettings.json`).
   - LinkedIn: en linkedin.com/developers crear una app, agregarle el producto "Sign In with LinkedIn using OpenID Connect" y cargar los URL de redirección `https://localhost:7108/signin-linkedin` y `http://localhost:5128/signin-linkedin`.
5. **Correr el proyecto** (`dotnet run` o F5 en Visual Studio).

**Cuenta moderadora:** `50291929@est.ort.edu.ar` / `12345678a` (la crea `script.sql`). Las demás cuentas se crean desde la página y empiezan vacías.

## Qué hace la página

Todo lo que se muestra sale de la base, de lo que carga cada persona o empresa, o de JSearch. No hay datos de ejemplo ni notificaciones.

- **Crear cuenta** (`/Cuenta/CrearCuenta`): se elige **Persona** o **Empresa**.
  - Persona, en 5 pasos: datos y contraseña; foto, provincia, teléfono, estado de búsqueda y "sobre mí"; qué busca (puesto, nivel, modalidad, jornada, contratación, dónde, salario, disponibilidad, habilidades e idiomas); experiencia y formación (con pop ups distintos y selector de mes y año); CV y sitio web. Todo es opcional salvo los datos de la cuenta.
  - Empresa: quien la maneja y los datos que la verifican: CUIT válido (dígito verificador) y no repetido, razón social, rubro, sitio web y un email del mismo dominio que el sitio (no se aceptan Gmail, Hotmail, etc.).
  - También con Google o LinkedIn (si están configurados).
- **Mi perfil** (`/Perfil`): llamado a completar el perfil con el próximo paso, estado de búsqueda (se cambia ahí mismo), foto, sobre mí, experiencia y formación (agregar y borrar), qué busca, habilidades, idiomas, CV y resumen de postulaciones.
- **Configuración** (`/Perfil/Configuracion`): datos de la cuenta (o de la empresa), qué busco y seguridad (cambiar o crear la contraseña y eliminar la cuenta).
- **Buscar trabajo** (`/Empleos`): busca a la vez en Workly y en otros sitios (JSearch). Filtros de país, provincia, modalidad, tipo de empleo y fecha, y orden (más nuevas, más viejas, A-Z). Sin valores precargados. Si no hay resultados: "No encontramos ningún puesto con ese nombre".
- **Oficial / No oficial**: cada oferta muestra si es oficial (la publicó una empresa registrada o viene de otro sitio) o no oficial (la publicó una persona).
- **Postularse**: en las búsquedas de Workly con el perfil y el CV; en las de otros sitios se va al sitio original y con "Ya me postulé" se suma al tablero.
- **Mis postulaciones** (`/Postulaciones`): tablero con Enviadas, En revisión, Pasé y No pasé. La persona mueve cada tarjeta (arrastrándola o con el selector) y se guarda.
- **Publicar búsqueda** (`/Publicaciones/Nueva`): las empresas publican al instante; las personas también pueden publicar, pero antes pasa por moderación.
- **Mis publicaciones** (`/Publicaciones`): cada búsqueda con su estado y la cantidad de postulantes; adentro, la lista de postulantes con su perfil completo y su CV.
- **Moderación** (`/Moderacion`, solo cuentas moderadoras): vista previa de la búsqueda tal como la verían las personas; aceptar la publica y rechazar guarda el motivo, que la persona ve en Mis publicaciones. (El aviso por mail queda para cuando esté el envío de mails.)
- **Empresas** (`/Empresas`): las empresas con cuenta o con búsquedas publicadas, con buscador, país y provincia (empieza en la provincia de la persona) y orden.
- **Inicio** (`/Panel`): ofertas según el puesto que busca la persona, sus postulaciones y qué le falta al perfil.
- **Landing** (`/`): el buscador escribe solo puestos reales de JSearch (o de Workly), espera 5 segundos y los borra letra por letra.

Las contraseñas se guardan con hash PBKDF2-SHA256 (600.000 iteraciones y sal aleatoria). Las fotos y logos se guardan en `wwwroot/uploads` y los CV en `ArchivosPrivados/cv`, fuera de `wwwroot`: solo los descarga su dueño o quien publicó una búsqueda a la que esa persona se postuló. Las dos carpetas están en `.gitignore`.

## Base de datos

`script.sql` (en la raíz) sigue el diagrama de la base (DLR):

| Tabla | Para qué |
| --- | --- |
| `Pais` / `Provincia` | Países (código ISO y prefijo telefónico) y sus provincias. Por ahora, Argentina y sus 24 jurisdicciones |
| `Usuario` | Persona o empresa, email único, contraseña (hash, opcional si entra con Google o LinkedIn) y si es moderadora |
| `LoginExterno` | Cuentas de Google o LinkedIn vinculadas |
| `Perfil` | Foto, descripción, provincia, teléfono y estado de búsqueda (uno por usuario) |
| `CV` | Archivo del CV y sitio web (uno por usuario) |
| `Preferencia` | Qué busca la persona: puesto, niveles, modalidades, jornada, contratación, provincia, salario y disponibilidad |
| `Habilidad` / `UsuarioHabilidad` | Habilidades (catálogo + las que agrega cada persona) |
| `Idioma` / `UsuarioIdioma` | Idiomas y el nivel de cada persona |
| `Educacion` / `UsuarioEducacion` | Instituciones y la formación de cada persona |
| `Empresa` / `ExperienciaLaboral` | Empresas (las de cuenta propia con CUIT, razón social y rubro) y la experiencia de cada persona |
| `OfertaLaboral` | Búsquedas publicadas en Workly, con quién la publicó y su estado de moderación |
| `Puesto` / `OfertaPuesto` | Puestos y a qué búsquedas corresponden (N a N) |
| `OfertaExterna` | Ofertas de otros sitios que trajo JSearch |
| `Postulacion` | Postulaciones a una oferta de Workly o externa, con su estado en el tablero |
| `Favorito` / `FavoritoOferta` | Del diagrama original; la página todavía no las usa |

El mismo script también está separado en tres archivos (se ejecutan en este orden y crean exactamente la misma base):

| Archivo | Contenido |
| --- | --- |
| `BaseDeDatos/1_Estructura.sql` | Crea la base, las tablas, sus claves, controles e índices |
| `BaseDeDatos/2_DatosDePrueba.sql` | Los INSERT: países, provincias, catálogos y la cuenta moderadora |
| `BaseDeDatos/3_StoredProcedures.sql` | Las consultas principales de `Models/BD.cs` como stored procedures, con el mismo nombre |

`script.sql` sigue siendo el que se usa para crear y actualizar la base. Si se cambia algo en la estructura o en los datos, hay que cambiarlo en todos lados.

Los diagramas están en `BaseDeDatos/DER.drawio` y `BaseDeDatos/DLR.drawio` (se abren con draw.io).

## Vistas

| Ruta | Vista | Referencia |
| --- | --- | --- |
| `/` | Landing pública | Figma › Alta · Landing |
| `/Cuenta/IniciarSesion` | Iniciar sesión | User flow (Miro) |
| `/Cuenta/CrearCuenta?tipo=persona\|empresa` | Registro de persona (5 pasos) o de empresa (2 pasos) | Barra de progreso del UI Kit |
| `/Panel` | Inicio de la persona | Componentes de Alta |
| `/Empleos` | Buscar trabajo (filtros, resultados y vista previa) | Media · WF 02 |
| `/Empleos/Detalle/{id}`, `/Empleos/Externa/{id}` | Detalle de oferta de Workly o de otro sitio | Media · 06, 07 y 08 |
| `/Postulaciones` | Tablero de postulaciones | Media · WF 03 |
| `/Empresas`, `/Empresas/Detalle/{id}` | Empresas y su página | Media · WF 04 |
| `/Publicaciones`, `/Publicaciones/Nueva`, `/Publicaciones/Detalle/{id}`, `/Publicaciones/Postulante/{id}` | Publicar búsquedas y ver postulantes | — |
| `/Moderacion`, `/Moderacion/Revisar/{id}` | Moderación de búsquedas | — |
| `/Perfil` | Mi perfil | Media · WF 05 |
| `/Perfil/Configuracion` | Cuenta, qué busco y seguridad | Mapa de sitio (Miro) |
| `/Perfil/Ayuda` | Ayuda (preguntas frecuentes) | Mapa de sitio (Miro) |
| `/Home/Privacy`, `/Home/Terminos` | Legales | — |

## Estructura

- `Models/BD.cs`: acceso a SQL Server con Dapper (consultas con parámetros).
- `Models/JSearch.cs`: búsqueda de ofertas de otros sitios.
- `Models/*.cs`: una clase por tabla, los modelos de los formularios y de las vistas, catálogos, validaciones y helpers (todo en `Models`).
- `Views/Shared/_LayoutApp.cshtml`: layout de la app (navbar según el tipo de cuenta y menú de usuario).
- `Views/Shared/_*.cshtml`: componentes reutilizables (tarjetas, pop ups de experiencia y formación, selector de mes, ubicación, teléfono, qué busco…).
- `wwwroot/css/`: tokens, componentes del UI Kit y estilos de cada pantalla.
- `wwwroot/js/site.js`: interacciones (pop ups, selector de mes, registro en pasos, tablero, animación del buscador…). Se activan con atributos `data-*`.
- `wwwroot/img/iconos.svg`: sprite de íconos (24 px, trazo de 2 px).

## Íconos

```cshtml
<icono nombre="alarm" />
<icono nombre="near-me" tamano="14" class="texto-acento" />
<icono nombre="close-big" etiqueta="Cerrar" />  @* con etiqueta se anuncia a lectores de pantalla *@
```

La lista completa de nombres está en `wwwroot/img/iconos.svg`.

## Tipografía

El UI Kit define **Cardo** (lectura) y **The Seasons** (principal). Cardo se carga desde Google Fonts. The Seasons es una fuente comercial: si se suma el kit de Adobe Fonts, alcanza con cambiar `--fuente-titulos` en `wwwroot/css/tokens.css`.
