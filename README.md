# Workly

Plataforma para encontrar y postularse a ofertas laborales que encajan con tu perfil, y seguir todo el proceso en un solo lugar.

Proyecto ASP.NET Core MVC (.NET 9). Las vistas están maquetadas con HTML, CSS y JavaScript propios (sin Bootstrap), siguiendo el Figma del proyecto:

- **Guidelines**: UI Kit (tipografía, colores, íconos, campos, botones, cargas, notificaciones y selectores).
- **Media**: wireframes de cada pantalla.
- **Alta**: landing a color, usada como referencia visual para todas las vistas.

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
