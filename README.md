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
- **Perfil y CV**: foto, "Sobre mí", experiencia laboral, formación, habilidades, idiomas, preferencias de búsqueda y CV en PDF o Word.
- **Buscar trabajo** con filtros por texto, provincia, modalidad, tipo de empleo y fecha, ordenando por fecha o de la A a la Z.
- **Ofertas externas** traídas de la API JSearch, junto con las ofertas publicadas en Workly.
- **Postulaciones** a ofertas de Workly y registro de postulaciones externas, en un tablero que cambia de estado sin recargar la página (`fetch`).
- **Ofertas guardadas** y recomendaciones **"Para vos"** según lo que busca cada persona.
- **Publicaciones**: las empresas publican directo y las personas mandan su búsqueda a moderación.
- **Moderación**: aprobar o rechazar búsquedas con un motivo, que le llega a quien publicó.
- **Directorio de empresas** con buscador y página de cada empresa.

---

## 🛠 Tecnologías

| Parte | Tecnología |
|-------|------------|
| Backend | ASP.NET Core MVC (.NET 9) |
| Base de datos | SQL Server |
| Acceso a datos | Dapper 2.1.89 + Microsoft.Data.SqlClient 7.1.1 |
| Frontend | HTML, CSS y JavaScript |
| Ofertas externas | API JSearch |

## 📂 Estructura del proyecto

| Carpeta | Qué tiene |
|---------|-----------|
| `Controllers/` | Reciben el pedido, llaman al Model y devuelven la vista |
| `Models/` | Clases del proyecto, validaciones y la clase `BD.cs` |
| `Views/` | Vistas Razor que leen los datos desde `ViewBag` |
| `wwwroot/` | CSS, JavaScript e imágenes |
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
dotnet user-secrets set "Correo:Contrasena" "TU_CONTRASEÑA"
dotnet user-secrets set "Authentication:Google:ClientId" "TU_CLIENT_ID"
dotnet user-secrets set "Authentication:Google:ClientSecret" "TU_CLIENT_SECRET"
```
Sin estas claves la app funciona igual: no muestra ofertas externas ni manda mails, y en desarrollo el código de verificación aparece en la consola.

6. Ejecutar el programa:
```bash
dotnet watch run
```

---

## 👥 Integrantes

- Dante
- Gabi
- Teo Moreno
- Lucas
