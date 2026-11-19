# Workly

![Logo de Workly](wwwroot/img/favicon.svg)

## 📌 Descripción y objetivos del proyecto

**Workly** es una plataforma web de búsqueda de empleo hecha con **ASP.NET Core MVC**. Conecta a personas que buscan trabajo con empresas que publican búsquedas, y además muestra ofertas externas de otros sitios para que todo esté en un solo lugar.

### 🎯 Objetivos

- Que una persona pueda armar su perfil y su CV, buscar trabajo y seguir sus postulaciones.
- Que una empresa pueda crear su cuenta, publicar búsquedas y ver a quienes se postularon.
- Guardar y consultar toda la información en **SQL Server** usando **stored procedures** llamados con **Dapper**.

---

## 🧩 Funcionalidades implementadas

- **Cuentas de persona y de empresa**, con verificación del email por código, recuperación de contraseña e inicio de sesión con Google o LinkedIn.
- **Validaciones de empresa**: CUIT válido, email del dominio de la empresa y sin repetir nombre ni CUIT.
- **Perfil y CV**: foto, "Sobre mí", experiencia laboral, formación, habilidades, idiomas, preferencias de búsqueda y CV en PDF o Word. Al subir el CV, la app lo lee con IA y completa el perfil con los datos que encuentra.
- **Buscar trabajo** con filtros por texto, provincia, modalidad, tipo de empleo y fecha, ordenando por fecha o de la A a la Z. Los resultados se muestran de a 42 ofertas por página, con botones "Anterior" y "Ver más".
- **Ofertas externas** de otros sitios guardadas en la base, junto con las ofertas publicadas en Workly. La app las actualiza sola desde la API JSearch una vez por semana, y cuando una búsqueda da menos de 42 resultados trae más en ese momento y las guarda.
- **Postulaciones** a ofertas de Workly y registro de postulaciones externas, en un tablero donde cada tarjeta se mueve de etapa con un formulario.
- **Ofertas guardadas** y recomendaciones **"Para vos"** según lo que busca cada persona.
- **Publicaciones**: las empresas publican directo y las personas mandan su búsqueda a moderación. Quien publica ve a los postulantes en tres grupos (en revisión, pasaron y no pasaron), ordenados por cuánto coinciden con lo que pidió, y recibe un mail cada 15 días con un resumen.
- **Asistente**: un chat que recomienda trabajos de la base según lo que la persona cuenta y su perfil.
- **Moderación**: aprobar o rechazar búsquedas con un motivo, que le llega a quien publicó.
- **Directorio de empresas** con buscador y página de cada empresa.

---

## 🛠 Tecnologías

| Parte | Tecnología |
|-------|------------|
| Backend | ASP.NET Core MVC (.NET 9) |
| Base de datos | SQL Server |
| Acceso a datos | Dapper 2.1.89 + Microsoft.Data.SqlClient 7.1.1 |
| Frontend | HTML, CSS y Bootstrap 6 (sin JavaScript propio) |
| Ofertas externas | API JSearch |
| Inteligencia artificial | API de Groq (asistente y lectura del CV) |
| Lectura de CV | PdfPig y DocumentFormat.OpenXml |

## 📂 Estructura del proyecto

| Carpeta | Qué tiene |
|---------|-----------|
| `Controllers/` | Reciben el pedido, llaman al Model y devuelven la vista |
| `Models/` | Clases del proyecto, validaciones y la clase `BD.cs` |
| `Views/` | Vistas Razor que leen los datos desde `ViewBag` |
| `wwwroot/` | La hoja de estilos `css/style.css` e imágenes |
| `SQL/` | Scripts de la base: estructura, datos de prueba y stored procedures |
| `script.sql` | Script completo para crear la base con datos y procedures |

Toda la base se usa desde `Models/BD.cs`. Cada método llama a un stored procedure con Dapper:

```c#
public static Usuario? ObtenerUsuarioPorEmail(string email) =>
    Uno<Usuario>("ObtenerUsuarioPorEmail", new { Email = email });
```

---

## ▶ Instrucciones para ejecutar

1. Clonar el repositorio:
```bash
git clone https://github.com/Teo-Moreno/Workly.git
```
2. Entrar en la carpeta del proyecto:
```bash
cd Workly
```
3. Crear la base de datos: abrir `script.sql` en SQL Server Management Studio y ejecutarlo. También se pueden ejecutar en orden `SQL/1_Estructura.sql`, `SQL/2_DatosDePrueba.sql` y `SQL/3_StoredProcedures.sql`.

> El script crea el usuario de base `alumno`, que usa el login `alumno` del servidor. Si tu SQL Server no tiene ese login, crealo antes de ejecutar el script.

4. Revisar la cadena de conexión en `appsettings.json`. Por defecto usa `Server=localhost;Database=Workly;Trusted_Connection=True;`.
5. *(Opcional)* Cargar las claves con `dotnet user-secrets`, nunca en el código:
```bash
dotnet user-secrets set "JSearch:ApiKey" "TU_CLAVE"
dotnet user-secrets set "Groq:ApiKey" "TU_CLAVE_DE_GROQ"
dotnet user-secrets set "Correo:Contrasena" "TU_CONTRASEÑA"
dotnet user-secrets set "Authentication:Google:ClientId" "TU_CLIENT_ID"
dotnet user-secrets set "Authentication:Google:ClientSecret" "TU_CLIENT_SECRET"
```
Sin estas claves la app funciona igual: muestra las ofertas que ya están en la base pero no las actualiza, no manda mails, el asistente y la lectura del CV no están disponibles, y en desarrollo el código de verificación aparece en la consola. La clave de Groq es gratis y se saca en console.groq.com. Para que los mails de resumen tengan el link a los postulantes, poné la dirección del sitio en `Sitio:Url` de `appsettings.json`.

6. Ejecutar el programa:
```bash
dotnet watch run
```

---

## 👥 Integrantes

- Teo Moreno
- Gabi Papini
- Dante Bruschetti
- Lucas Ducatenzeiler
