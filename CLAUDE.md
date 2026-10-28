# Workly — reglas del proyecto

Workly es un proyecto real, no una maqueta. Estas reglas valen para cualquier cambio:

1. **Nada de datos inventados.** Todo lo que se muestra sale de la base de datos, de lo que cargó la persona o de una API real (JSearch). No se ponen números, nombres, empresas, ofertas, estadísticas, testimonios ni valores "de ejemplo" en las vistas.
2. **Nada a medias.** Si un botón, formulario, filtro o pop up aparece en la página, funciona y guarda de verdad. Si todavía no se puede hacer, no se muestra.
3. **Las cuentas empiezan vacías.** Los datos de la persona (perfil, preferencias, habilidades, idiomas, experiencia, formación, CV) los carga ella en el registro o en su perfil. Nunca se precargan valores.
4. **Estados vacíos claros.** Cuando no hay datos, se muestra un mensaje que explica qué falta y un botón para cargarlo.
5. **Sin notificaciones.** La página no tiene notificaciones (ni campana, ni avisos por mail de la página, ni alertas de empresas).

## Convenciones

- ASP.NET Core MVC (.NET 9) + Dapper + SQL Server. Las clases van en `Models/` (incluidos helpers, servicios y tag helpers).
- La base se define en `script.sql` (raíz). `BaseDeDatos/` tiene la misma base separada en estructura, datos y stored procedures, el DER y el DLR, y scripts para actualizar bases existentes. Si cambia una tabla, se actualizan todos.
- Textos en español rioplatense (voseo). CSS en BEM en español; íconos con `<icono nombre="..." />`.
- Claves y secretos nunca en el repositorio: se usan `dotnet user-secrets` (por ejemplo `JSearch:ApiKey`).
