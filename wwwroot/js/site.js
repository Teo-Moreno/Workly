/* ==========================================================================
   Workly · Interacciones visuales
   JavaScript sin dependencias. Cada comportamiento se activa con atributos
   data-* en el HTML, así las vistas no necesitan scripts propios.
   Los formularios guardan en el servidor; acá solo se valida y se mejora la interacción.
   ========================================================================== */
(() => {
  "use strict";

  const $ = (selector, raiz = document) => raiz.querySelector(selector);
  const $$ = (selector, raiz = document) => Array.from(raiz.querySelectorAll(selector));
  const rutaIconos = "/img/iconos.svg";

  const icono = (nombre, tamano = 24) =>
    `<svg class="icono" width="${tamano}" height="${tamano}" aria-hidden="true" focusable="false"><use href="${rutaIconos}#${nombre}"></use></svg>`;

  const cambiarIcono = (boton, nombre) => {
    const uso = boton.querySelector(".icono use");
    if (uso) uso.setAttribute("href", `${rutaIconos}#${nombre}`);
  };

  /* ------------------------------------------------------------------------
     Snackbar (07. Notificaciones › Snackbar)
     Uso: Workly.snackbar("Texto", "exito" | "advertencia" | "error" | "")
     ---------------------------------------------------------------------- */
  const iconosSnackbar = { exito: "circle-check", advertencia: "warning", error: "error", "": "info" };

  function snackbar(texto, tipo = "") {
    const contenedor = $("[data-snackbars]");
    if (!contenedor) return;
    const elemento = document.createElement("div");
    elemento.className = `snackbar ${tipo ? `snackbar--${tipo}` : ""}`;
    elemento.setAttribute("role", tipo === "error" ? "alert" : "status");
    elemento.innerHTML = `${icono(iconosSnackbar[tipo] || "info", 22)}
      <span class="snackbar__texto"></span>
      <button class="snackbar__cerrar" type="button" aria-label="Cerrar aviso">${icono("close-big", 20)}</button>`;
    elemento.querySelector(".snackbar__texto").textContent = texto;
    contenedor.appendChild(elemento);

    const cerrar = () => {
      elemento.classList.add("esta-saliendo");
      elemento.addEventListener("animationend", () => elemento.remove(), { once: true });
    };
    elemento.querySelector(".snackbar__cerrar").addEventListener("click", cerrar);
    setTimeout(cerrar, 4200);
  }

  // Botones de cierre de snackbars estáticos (UI Kit, avisos en línea)
  document.addEventListener("click", (evento) => {
    const cerrar = evento.target.closest("[data-cerrar-aviso]");
    if (cerrar) cerrar.closest(".snackbar")?.remove();
  });

  /* ------------------------------------------------------------------------
     Menú móvil
     ---------------------------------------------------------------------- */
  $$("[data-menu-movil]").forEach((boton) => {
    boton.addEventListener("click", () => {
      const navbar = boton.closest("[data-navbar]");
      const abierto = navbar.classList.toggle("esta-abierta");
      boton.setAttribute("aria-expanded", String(abierto));
      cambiarIcono(boton, abierto ? "close-big" : "menu");
    });
  });

  /* ------------------------------------------------------------------------
     Desplegables: menú de usuario
     ---------------------------------------------------------------------- */
  const cerrarDesplegables = (excepto) => {
    $$("[data-desplegable].esta-abierto").forEach((desplegable) => {
      if (desplegable === excepto) return;
      desplegable.classList.remove("esta-abierto");
      $("[data-desplegable-boton]", desplegable)?.setAttribute("aria-expanded", "false");
    });
  };

  $$("[data-desplegable]").forEach((desplegable) => {
    const boton = $("[data-desplegable-boton]", desplegable);
    boton?.addEventListener("click", (evento) => {
      evento.stopPropagation();
      const abierto = !desplegable.classList.contains("esta-abierto");
      cerrarDesplegables(desplegable);
      desplegable.classList.toggle("esta-abierto", abierto);
      boton.setAttribute("aria-expanded", String(abierto));
    });
    $$("[data-desplegable-cerrar]", desplegable).forEach((cerrar) =>
      cerrar.addEventListener("click", () => cerrarDesplegables())
    );
  });

  document.addEventListener("click", (evento) => {
    if (!evento.target.closest("[data-desplegable-panel]")) cerrarDesplegables();
  });

  document.addEventListener("keydown", (evento) => {
    if (evento.key === "Escape") cerrarDesplegables();
  });

  /* ------------------------------------------------------------------------
     Pestañas (subrayadas, segmentadas y navegación lateral)
     Estructura: [data-pestanas] > [data-pestana="id"] + [data-panel="id"]
     ---------------------------------------------------------------------- */
  function activarPestana(contenedor, id, actualizarHash = false) {
    const botones = $$("[data-pestana]", contenedor).filter((b) => b.closest("[data-pestanas]") === contenedor);
    const paneles = $$("[data-panel]", contenedor).filter((p) => p.closest("[data-pestanas]") === contenedor);
    if (!paneles.some((panel) => panel.dataset.panel === id)) return false;

    botones.forEach((boton) => {
      const activa = boton.dataset.pestana === id;
      boton.classList.toggle("esta-activa", activa);
      boton.classList.toggle("esta-activo", activa);
      if (boton.getAttribute("role") === "tab") boton.setAttribute("aria-selected", String(activa));
      else if (activa) boton.setAttribute("aria-current", "true");
      else boton.removeAttribute("aria-current");
    });
    paneles.forEach((panel) => (panel.hidden = panel.dataset.panel !== id));
    if (actualizarHash && contenedor.hasAttribute("data-pestanas-hash")) history.replaceState(null, "", `#${id}`);
    return true;
  }

  $$("[data-pestanas]").forEach((contenedor) => {
    contenedor.addEventListener("click", (evento) => {
      const boton = evento.target.closest("[data-pestana]");
      if (!boton || boton.closest("[data-pestanas]") !== contenedor) return;
      evento.preventDefault();
      activarPestana(contenedor, boton.dataset.pestana, true);
    });

    // Abrir la pestaña indicada en la URL (#busqueda, #seguridad...)
    if (contenedor.hasAttribute("data-pestanas-hash") && location.hash) {
      activarPestana(contenedor, decodeURIComponent(location.hash.slice(1)));
    }
  });

  window.addEventListener("hashchange", () => {
    $$("[data-pestanas][data-pestanas-hash]").forEach((contenedor) =>
      activarPestana(contenedor, decodeURIComponent(location.hash.slice(1)))
    );
  });

  // Mostrar u ocultar un panel (filtros en mobile)
  $$("[data-alternar]").forEach((boton) => {
    boton.addEventListener("click", () => {
      const panel = document.getElementById(boton.dataset.alternar);
      const abierto = panel.classList.toggle("esta-abierto");
      boton.setAttribute("aria-expanded", String(abierto));
    });
  });

  /* ------------------------------------------------------------------------
     Buscar trabajo: seleccionar una oferta muestra su vista previa
     ---------------------------------------------------------------------- */
  const panelDetalles = $("[data-detalles]");

  if (panelDetalles) {
    $("[data-resultados]")?.addEventListener("click", (evento) => {
      const tarjeta = evento.target.closest("[data-oferta]");
      if (!tarjeta) return;
      // En pantallas chicas no hay vista previa: se navega al detalle.
      if (getComputedStyle(panelDetalles).display === "none") return;
      evento.preventDefault();
      const id = tarjeta.dataset.oferta;
      $$("[data-oferta]").forEach((t) => t.classList.toggle("es-seleccionada", t === tarjeta));
      $$("[data-detalle-oferta]", panelDetalles).forEach((detalle) => {
        detalle.hidden = detalle.dataset.detalleOferta !== id;
        detalle.classList.toggle("es-nueva", !detalle.hidden);
        if (!detalle.hidden) detalle.scrollTop = 0;
      });
      const url = new URL(location.href);
      url.searchParams.set("id", id);
      history.replaceState(null, "", url);
    });
  }

  // Valida los campos visibles: obligatorios vacíos y valores con formato inválido
  // (email, patrón, largo). Marca cada campo con .campo--error del UI Kit.
  // El contenedor puede estar oculto (un paso del registro que no se está viendo).
  function validar(formulario) {
    let valido = true;
    $$("input, select, textarea", formulario).forEach((control) => {
      const oculto = control.closest("[hidden]");
      if ((oculto && oculto !== formulario) || ["hidden", "submit", "button"].includes(control.type)) return;
      const campo = control.closest(".campo");
      let ok;
      if (control.type === "file") {
        if (!control.required) return;
        ok = control.files.length > 0;
      } else if (control.type === "radio") {
        if (!control.required) return;
        ok = $$(`input[type=radio][name="${CSS.escape(control.name)}"]`, control.form || formulario).some((r) => r.checked);
      } else if (control.type === "checkbox") {
        if (!control.required) return;
        ok = control.checked;
      } else if (control.value.trim() === "") {
        if (!control.required) {
          campo?.classList.remove("campo--error");
          return;
        }
        ok = false;
      } else {
        ok = control.checkValidity();
      }
      campo?.classList.toggle("campo--error", !ok);
      if (!ok) campo?.classList.remove("campo--sin-mensaje");
      if (!ok && valido) {
        control.focus();
        valido = false;
      }
    });
    return valido;
  }

  // Al corregir un campo marcado en rojo, se quita el error
  $$("form .campo input, form .campo select, form .campo textarea").forEach((control) => {
    const quitarError = () => {
      const campo = control.closest(".campo");
      if (!campo?.classList.contains("campo--error")) return;
      campo.classList.remove("campo--sin-mensaje");
      const ok = control.type === "radio" ? true : control.type === "checkbox" ? control.checked : control.value.trim() !== "" && control.checkValidity();
      if (ok) campo.classList.remove("campo--error");
    };
    control.addEventListener("input", quitarError);
    control.addEventListener("change", quitarError);
  });

  // Mostrar / ocultar contraseña
  $$("[data-ver-clave]").forEach((boton) => {
    boton.addEventListener("click", () => {
      const input = boton.parentElement.querySelector("input");
      const visible = input.type === "text";
      input.type = visible ? "password" : "text";
      boton.setAttribute("aria-pressed", String(!visible));
      boton.setAttribute("aria-label", visible ? "Mostrar contraseña" : "Ocultar contraseña");
      cambiarIcono(boton, visible ? "eye" : "eye-off");
    });
  });

  // Revisa tamaño y formato de un archivo elegido antes de enviarlo (el servidor también lo valida).
  // Si no sirve, vacía el input y marca el campo con el error del UI Kit.
  // Usa accept="…" del input y data-tamano-maximo / data-error-formato.
  function archivoValido(input, archivo) {
    const campo = input.closest(".campo");
    const extensiones = input.accept.split(",").map((e) => e.trim().toLowerCase()).filter((e) => e.startsWith("."));
    const extension = archivo.name.includes(".") ? archivo.name.slice(archivo.name.lastIndexOf(".")).toLowerCase() : "";
    const maximo = Number(input.dataset.tamanoMaximo) || Infinity;
    let error = "";
    if (extensiones.length && !extensiones.includes(extension)) error = input.dataset.errorFormato || "Formato no permitido";
    else if (archivo.size > maximo) error = `El archivo pesa más de ${Math.round(maximo / 1024 / 1024)} MB`;

    campo?.classList.toggle("campo--error", Boolean(error));
    campo?.classList.remove("campo--sin-mensaje");
    if (!error) return true;

    input.value = "";
    const mensaje = campo && $(".campo__mensaje--error", campo);
    if (mensaje) {
      [...mensaje.childNodes].filter((nodo) => nodo.nodeType === Node.TEXT_NODE).forEach((nodo) => nodo.remove());
      mensaje.append(error);
    }
    return false;
  }

  // Zona de arrastrar y soltar archivos (CV)
  $$("[data-zona-archivo]").forEach((zona) => {
    const input = $("input[type=file]", zona);
    const nombre = $("[data-zona-archivo-nombre]", zona);
    const textoInicial = nombre?.textContent;
    const teniaArchivo = zona.classList.contains("tiene-archivo"); // p. ej. el CV ya guardado
    const mostrar = (archivo) => {
      if (!archivo) return;
      if (input && !archivoValido(input, archivo)) {
        zona.classList.toggle("tiene-archivo", teniaArchivo);
        if (nombre) nombre.textContent = textoInicial;
        return;
      }
      zona.classList.add("tiene-archivo");
      if (nombre) nombre.textContent = archivo.name;
    };
    ["dragenter", "dragover"].forEach((tipo) =>
      zona.addEventListener(tipo, (evento) => {
        evento.preventDefault();
        zona.classList.add("esta-arrastrando");
      })
    );
    ["dragleave", "drop"].forEach((tipo) =>
      zona.addEventListener(tipo, () => zona.classList.remove("esta-arrastrando"))
    );
    zona.addEventListener("drop", (evento) => {
      evento.preventDefault();
      const archivos = evento.dataTransfer.files;
      if (!archivos.length) return;
      // El archivo soltado se pasa al input para que se envíe con el formulario.
      if (input) input.files = archivos;
      mostrar(archivos[0]);
    });
    input?.addEventListener("change", () => mostrar(input.files[0]));
  });

  /* ------------------------------------------------------------------------
     Registro en pasos (08. Selectores › Barra de progreso)
     ---------------------------------------------------------------------- */
  $$("[data-pasos-form]").forEach((formulario) => {
    const pasos = $$("[data-paso]", formulario);
    const indicadores = $$("[data-paso-indicador]");
    let actual = 0;

    const mostrar = (indice, enfocar = true) => {
      actual = indice;
      pasos.forEach((paso, i) => (paso.hidden = i !== indice));
      indicadores.forEach((indicador, i) => {
        indicador.classList.toggle("esta-completo", i < indice);
        indicador.classList.toggle("esta-actual", i === indice);
        if (i === indice) indicador.setAttribute("aria-current", "step");
        else indicador.removeAttribute("aria-current");
      });
      $("[data-paso-actual]")?.replaceChildren(String(indice + 1));
      if (enfocar) {
        const primerCampo = $(".campo--error .campo__control, .campo--error input", pasos[indice]) ||
          pasos[indice].querySelector("input:not([type=hidden]), select, textarea");
        primerCampo?.focus({ preventScroll: true });
        window.scrollTo({ top: 0, behavior: "smooth" });
      }
    };

    formulario.addEventListener("click", (evento) => {
      if (evento.target.closest("[data-paso-siguiente]")) {
        evento.preventDefault();
        if (validar(pasos[actual])) mostrar(Math.min(actual + 1, pasos.length - 1));
      }
      if (evento.target.closest("[data-paso-anterior]")) {
        evento.preventDefault();
        mostrar(Math.max(actual - 1, 0));
      }
    });

    // Enter en un paso intermedio funciona como "Siguiente". Desde el último paso se revisan
    // todos los pasos (no solo el visible) y, si alguno tiene errores, se abre el primero.
    formulario.addEventListener("submit", (evento) => {
      if (actual < pasos.length - 1) {
        evento.preventDefault();
        evento.stopImmediatePropagation();
        if (validar(pasos[actual])) mostrar(actual + 1);
        return;
      }
      const pasoInvalido = pasos.findIndex((paso) => !validar(paso));
      if (pasoInvalido === -1) return;
      evento.preventDefault();
      evento.stopImmediatePropagation();
      mostrar(pasoInvalido);
      snackbar("Revisá los campos marcados en rojo.", "error");
    });

    // Si el servidor devolvió errores, se abre el primer paso que tiene alguno.
    const pasoConError = pasos.findIndex((paso) => paso.querySelector(".campo--error"));
    mostrar(Math.max(pasoConError, 0), pasoConError >= 0);
  });

  /* ------------------------------------------------------------------------
     Formularios que se envían al servidor (iniciar sesión, crear cuenta)
     Se validan en el navegador antes de enviar y se evita el doble envío.
     ---------------------------------------------------------------------- */
  $$("form[data-formulario-real]").forEach((formulario) => {
    formulario.addEventListener("submit", (evento) => {
      const pasoVisible = $$("[data-paso]", formulario).find((paso) => !paso.hidden);
      if (!validar(pasoVisible || formulario)) {
        evento.preventDefault();
        snackbar("Revisá los campos marcados en rojo.", "error");
        return;
      }
      const boton = evento.submitter || $("button[type=submit]", formulario);
      if (boton) {
        boton.classList.add("esta-cargando");
        boton.setAttribute("aria-disabled", "true");
        boton.insertAdjacentHTML("afterbegin", '<span class="spinner spinner--sm spinner--claro" aria-hidden="true"></span>');
      }
      // Un segundo envío mientras se procesa el primero se ignora.
      formulario.addEventListener("submit", (e) => e.preventDefault(), { once: true });
    });
  });

  /* ------------------------------------------------------------------------
     País, provincia y teléfono (registro y configuración)
     data-selector-pais      → al cambiar, muestra solo sus provincias y
                               cambia el prefijo del teléfono (data-codigo)
     data-selector-provincia → opciones con data-pais
     data-telefono           → solo números; los espacios y el guion se
                               ponen solos (data-codigos-area = áreas de 3)
     ---------------------------------------------------------------------- */
  $$("[data-selector-pais]").forEach((selectorPais) => {
    const contenedor = selectorPais.closest("form") || document;
    const selectorProvincia = $("[data-selector-provincia]", contenedor);
    const prefijo = $("[data-prefijo-telefono]", contenedor);
    const actualizar = () => {
      const codigo = selectorPais.selectedOptions[0]?.dataset.codigo;
      if (prefijo && codigo) prefijo.textContent = codigo;
      if (!selectorProvincia) return;
      [...selectorProvincia.options].forEach((opcion) => {
        if (!opcion.value) return;
        const esDelPais = opcion.dataset.pais === selectorPais.value;
        opcion.hidden = !esDelPais;
        opcion.disabled = !esDelPais;
      });
      if (selectorProvincia.selectedOptions[0]?.disabled) selectorProvincia.value = "";
    };
    selectorPais.addEventListener("change", actualizar);
    actualizar();
  });

  $$("[data-telefono]").forEach((entrada) => {
    const DIGITOS = 10;
    const areas3 = (entrada.dataset.codigosArea || "").split(",");

    // Mismo formato que Models/Telefonos.cs: "11 5555-1234", "351 555-1234", "2982 55-1234"
    const formatear = (digitos) => {
      const largoArea = digitos.startsWith("11") ? 2 : areas3.includes(digitos.slice(0, 3)) ? 3 : digitos.length >= 4 ? 4 : 0;
      if (!largoArea || digitos.length <= largoArea) return digitos;
      const area = digitos.slice(0, largoArea);
      const numero = digitos.slice(largoArea);
      const corte = DIGITOS - largoArea - 4;
      return numero.length > corte ? `${area} ${numero.slice(0, corte)}-${numero.slice(corte)}` : `${area} ${numero}`;
    };

    // Si se pega un número completo ("+54 9 11 ...", "011 ..."), se quitan el país, el 9 y el 0.
    const limpiar = (texto) => {
      let digitos = texto.replace(/\D/g, "");
      if (digitos.length > DIGITOS && digitos.startsWith("54")) digitos = digitos.slice(2);
      if (digitos.length > DIGITOS && digitos.startsWith("9")) digitos = digitos.slice(1);
      return digitos.replace(/^0+/, "").slice(0, DIGITOS);
    };

    const aplicar = (valor = entrada.value, cursor = entrada.selectionStart ?? valor.length) => {
      const digitosAntes = limpiar(valor.slice(0, cursor)).length;
      const nuevo = formatear(limpiar(valor));
      entrada.value = nuevo;
      if (document.activeElement !== entrada) return;
      // El cursor queda después de la misma cantidad de números que antes
      let posicion = 0;
      for (let vistos = 0; posicion < nuevo.length && vistos < digitosAntes; posicion++) {
        if (/\d/.test(nuevo[posicion])) vistos++;
      }
      entrada.setSelectionRange(posicion, posicion);
    };

    entrada.addEventListener("beforeinput", (evento) => {
      // Solo números al escribir (pegar se limpia en "input")
      if (evento.inputType === "insertText" && /\D/.test(evento.data || "")) {
        evento.preventDefault();
        return;
      }
      // Borrar sobre un espacio o el guion borra también el número anterior
      const { selectionStart: inicio, selectionEnd: fin, value } = entrada;
      if (evento.inputType === "deleteContentBackward" && inicio === fin && inicio > 0 && /\D/.test(value[inicio - 1])) {
        evento.preventDefault();
        aplicar(value.slice(0, inicio - 2) + value.slice(inicio), Math.max(inicio - 2, 0));
        entrada.dispatchEvent(new Event("change", { bubbles: true }));
      }
    });
    entrada.addEventListener("input", () => aplicar());
    aplicar();
  });

  // Vista previa de la foto de perfil elegida
  $$("[data-foto-entrada]").forEach((entrada) => {
    const vista = $("[data-vista-foto]", entrada.closest("form") || document);
    const vistaInicial = vista?.innerHTML;
    entrada.addEventListener("change", () => {
      const archivo = entrada.files?.[0];
      if (!vista || !archivo) return;
      if (!archivoValido(entrada, archivo) || !archivo.type.startsWith("image/")) {
        vista.innerHTML = vistaInicial;
        return;
      }
      const imagen = document.createElement("img");
      imagen.alt = "";
      imagen.src = URL.createObjectURL(archivo);
      vista.replaceChildren(imagen);
    });
  });


  /* ------------------------------------------------------------------------
     Pop ups (<dialog> nativo)
     data-modal-abrir="id"   → abre el pop up
     data-modal-cerrar       → cierra el pop up en el que está
     data-abrir-al-cargar    → se abre solo (el servidor devolvió errores)
     ---------------------------------------------------------------------- */
  document.addEventListener("click", (evento) => {
    const abrir = evento.target.closest("[data-modal-abrir]");
    if (abrir) {
      evento.preventDefault();
      document.getElementById(abrir.dataset.modalAbrir)?.showModal();
      return;
    }
    const cerrar = evento.target.closest("[data-modal-cerrar]");
    if (cerrar) {
      evento.preventDefault();
      cerrar.closest("dialog")?.close();
      return;
    }
    // Clic sobre el fondo oscuro
    if (evento.target.tagName === "DIALOG" && evento.target.open) {
      const caja = evento.target.getBoundingClientRect();
      const fuera =
        evento.clientX < caja.left || evento.clientX > caja.right || evento.clientY < caja.top || evento.clientY > caja.bottom;
      if (fuera) evento.target.close();
    }
  });

  $$('dialog[data-abrir-al-cargar="true"]').forEach((dialogo) => dialogo.showModal());

  // Pedir confirmación antes de enviar (borrar, quitar, cerrar una búsqueda)
  document.addEventListener("submit", (evento) => {
    const formulario = evento.target;
    if (formulario.dataset.confirmar && !confirm(formulario.dataset.confirmar)) evento.preventDefault();
  }, true);

  // Enviar el formulario al cambiar un filtro o una opción (estado de búsqueda, filtros, orden)
  document.addEventListener("change", (evento) => {
    const control = evento.target.closest?.("[data-enviar-al-cambiar], [data-enviar-al-cambiar] select");
    if (!control || control.closest("[data-tablero]")) return;
    const formulario = control.form || control.closest("form");
    if (formulario) formulario.requestSubmit ? formulario.requestSubmit() : formulario.submit();
  });

  // "Repetí la contraseña": tiene que ser igual a la otra
  $$("[data-igual-a]").forEach((repetir) => {
    const original = document.getElementById(repetir.dataset.igualA);
    const revisar = () => repetir.setCustomValidity(repetir.value && original && repetir.value !== original.value ? "No coinciden" : "");
    repetir.addEventListener("input", revisar);
    original?.addEventListener("input", revisar);
  });

  // CUIT: solo números, con los guiones en su lugar (30-12345678-9)
  $$("[data-cuit]").forEach((entrada) => {
    const formatear = () => {
      const d = entrada.value.replace(/\D/g, "").slice(0, 11);
      entrada.value = d.length > 10 ? `${d.slice(0, 2)}-${d.slice(2, 10)}-${d.slice(10)}` : d.length > 2 ? `${d.slice(0, 2)}-${d.slice(2)}` : d;
    };
    entrada.addEventListener("input", formatear);
    formatear();
  });

  /* ------------------------------------------------------------------------
     Selector de mes y año (MM/AAAA) con calendario de meses
     ---------------------------------------------------------------------- */
  const hoy = new Date();
  const mesActual = hoy.getFullYear() * 12 + hoy.getMonth();

  $$("[data-selector-mes]").forEach((selector) => {
    const entrada = $("[data-selector-mes-entrada]", selector);
    const abrir = $("[data-selector-mes-abrir]", selector);
    const panel = $("[data-selector-mes-panel]", selector);
    const textoAnio = $("[data-selector-mes-anio]", selector);
    const botonesMes = $$("[data-mes]", selector);
    const siguiente = $("[data-selector-mes-siguiente]", selector);
    const permitirFuturo = selector.dataset.permitirFuturo === "true";
    const anioMaximo = permitirFuturo ? hoy.getFullYear() + 10 : hoy.getFullYear();
    let anio = hoy.getFullYear();

    const leer = () => {
      const partes = /^(\d{2})\/(\d{4})$/.exec(entrada.value);
      return partes ? { mes: Number(partes[1]), anio: Number(partes[2]) } : null;
    };

    const dibujar = () => {
      const elegido = leer();
      textoAnio.textContent = String(anio);
      siguiente.disabled = anio >= anioMaximo;
      botonesMes.forEach((boton) => {
        const mes = Number(boton.dataset.mes);
        const indice = anio * 12 + mes - 1;
        boton.disabled = !permitirFuturo && indice > mesActual;
        const esElegido = elegido && elegido.mes === mes && elegido.anio === anio;
        boton.classList.toggle("esta-elegido", Boolean(esElegido));
        boton.setAttribute("aria-pressed", String(Boolean(esElegido)));
        boton.classList.toggle("es-actual", indice === mesActual);
      });
    };

    const cerrar = () => {
      panel.hidden = true;
      abrir.setAttribute("aria-expanded", "false");
    };

    abrir.addEventListener("click", () => {
      if (!panel.hidden) return cerrar();
      anio = leer()?.anio || hoy.getFullYear();
      dibujar();
      panel.hidden = false;
      abrir.setAttribute("aria-expanded", "true");
      (botonesMes.find((b) => b.classList.contains("esta-elegido")) || botonesMes.find((b) => !b.disabled))?.focus();
    });
    $("[data-selector-mes-anterior]", selector).addEventListener("click", () => { anio--; dibujar(); });
    siguiente.addEventListener("click", () => { if (anio < anioMaximo) { anio++; dibujar(); } });
    botonesMes.forEach((boton) =>
      boton.addEventListener("click", () => {
        entrada.value = `${boton.dataset.mes.padStart(2, "0")}/${anio}`;
        entrada.dispatchEvent(new Event("input", { bubbles: true }));
        entrada.dispatchEvent(new Event("change", { bubbles: true }));
        cerrar();
        entrada.focus();
      })
    );

    // Escribir a mano: solo números y la barra se pone sola
    entrada.addEventListener("input", (evento) => {
      if (evento.isTrusted === false) return;
      const d = entrada.value.replace(/\D/g, "").slice(0, 6);
      entrada.value = d.length > 2 ? `${d.slice(0, 2)}/${d.slice(2)}` : d;
    });
    // No puede ser un mes futuro (salvo la finalización de una formación en curso)
    const revisar = () => {
      const valor = leer();
      const futuro = valor && !permitirFuturo && valor.anio * 12 + valor.mes - 1 > mesActual;
      entrada.setCustomValidity(futuro ? "No puede ser un mes futuro" : "");
    };
    entrada.addEventListener("change", revisar);
    entrada.addEventListener("input", revisar);

    document.addEventListener("click", (evento) => { if (!selector.contains(evento.target)) cerrar(); });
    selector.addEventListener("keydown", (evento) => {
      if (evento.key === "Escape" && !panel.hidden) {
        evento.stopPropagation();
        evento.preventDefault();
        cerrar();
        abrir.focus();
      }
    });
  });

  // "Trabajo actualmente acá" / "Lo estoy cursando": oculta la fecha de finalización
  $$("[data-alternar-fin]").forEach((casilla) => {
    const contenedor = document.querySelector(`[data-fin-de="${casilla.id}"]`);
    const actualizar = () => {
      if (!contenedor) return;
      contenedor.hidden = casilla.checked;
      $$("input", contenedor).forEach((entrada) => {
        entrada.required = !casilla.checked;
        if (casilla.checked) {
          entrada.value = "";
          entrada.closest(".campo")?.classList.remove("campo--error");
        }
      });
    };
    casilla.addEventListener("change", actualizar);
    actualizar();
  });

  /* ------------------------------------------------------------------------
     Registro: experiencias y estudios que se agregan con un pop up y se
     mandan junto con el formulario (inputs ocultos ExpPuesto, ForTitulo, …)
     ---------------------------------------------------------------------- */
  const actualizarVacio = (lista) => {
    let vacio = $("[data-lista-vacia]", lista);
    const hayItems = $$("[data-item-local]", lista).length > 0;
    if (!hayItems && !vacio && lista.dataset.vacio) {
      vacio = document.createElement("li");
      vacio.className = "lista-local__vacio";
      vacio.setAttribute("data-lista-vacia", "");
      vacio.textContent = lista.dataset.vacio;
      lista.appendChild(vacio);
    }
    if (hayItems) vacio?.remove();
  };
  $$("[data-lista-local]").forEach(actualizarVacio);

  document.addEventListener("click", (evento) => {
    const quitar = evento.target.closest("[data-quitar-item]");
    if (!quitar) return;
    const lista = quitar.closest("[data-lista-local]");
    quitar.closest("[data-item-local]")?.remove();
    if (lista) actualizarVacio(lista);
  });

  const camposLocales = {
    experiencia: {
      campos: { Puesto: "ExpPuesto", Empresa: "ExpEmpresa", Inicio: "ExpInicio", Fin: "ExpFin", Descripcion: "ExpDescripcion" },
      actual: "Actual",
      texto: (v) => [v.Puesto, `${v.Empresa} · ${v.Inicio} – ${v.Fin || "Actualidad"}`]
    },
    formacion: {
      campos: { Titulo: "ForTitulo", Institucion: "ForInstitucion", Inicio: "ForInicio", Fin: "ForFin" },
      actual: "EnCurso",
      texto: (v) => [v.Titulo, `${v.Institucion} · ${v.Inicio} – ${v.Fin || "En curso"}`]
    }
  };

  const aMes = (texto) => {
    const p = /^(\d{2})\/(\d{4})$/.exec(texto || "");
    return p ? Number(p[2]) * 12 + Number(p[1]) - 1 : null;
  };

  $$("form[data-modal-local]").forEach((formulario) => {
    const tipo = formulario.dataset.modalLocal;
    const config = camposLocales[tipo];
    const lista = document.querySelector(`[data-lista-local="${tipo}"]`);
    if (!config || !lista) return;

    formulario.addEventListener("submit", (evento) => {
      evento.preventDefault();
      if (!validar(formulario)) return;
      const valores = {};
      Object.keys(config.campos).forEach((nombre) => (valores[nombre] = (formulario.elements[nombre]?.value || "").trim()));
      if (formulario.elements[config.actual]?.checked) valores.Fin = "";

      // La finalización no puede ser anterior al inicio
      const inicio = aMes(valores.Inicio);
      const fin = aMes(valores.Fin);
      const campoFin = formulario.elements.Fin?.closest(".campo");
      if (fin !== null && inicio !== null && fin < inicio) {
        campoFin?.classList.add("campo--error");
        const mensaje = campoFin && $(".campo__mensaje--error", campoFin);
        if (mensaje) {
          [...mensaje.childNodes].filter((n) => n.nodeType === Node.TEXT_NODE).forEach((n) => n.remove());
          mensaje.append("La finalización no puede ser anterior al inicio");
        }
        return;
      }

      const item = document.createElement("li");
      item.className = "item-local";
      item.setAttribute("data-item-local", "");
      const [titulo, detalle] = config.texto(valores);
      const textos = document.createElement("div");
      const fuerte = document.createElement("strong");
      fuerte.textContent = titulo;
      const linea = document.createElement("span");
      linea.textContent = detalle;
      textos.append(fuerte, linea);
      item.appendChild(textos);
      Object.entries(config.campos).forEach(([nombre, oculto]) => {
        const entrada = document.createElement("input");
        entrada.type = "hidden";
        entrada.name = oculto;
        entrada.value = valores[nombre];
        item.appendChild(entrada);
      });
      const quitar = document.createElement("button");
      quitar.type = "button";
      quitar.className = "boton boton--texto";
      quitar.setAttribute("data-quitar-item", "");
      quitar.textContent = "Quitar";
      item.appendChild(quitar);
      lista.appendChild(item);
      actualizarVacio(lista);

      formulario.reset();
      $$("[data-alternar-fin]", formulario).forEach((c) => c.dispatchEvent(new Event("change")));
      formulario.closest("dialog")?.close();
      snackbar(tipo === "experiencia" ? "Sumamos la experiencia." : "Sumamos la formación.", "exito");
    });
  });

  /* ------------------------------------------------------------------------
     Qué busco: agregar habilidades propias y filas de idiomas
     ---------------------------------------------------------------------- */
  $$("[data-habilidades]").forEach((grupo) => {
    const lista = $("[data-habilidades-lista]", grupo);
    const entrada = $("[data-habilidad-nueva]", grupo);
    const agregar = () => {
      const nombre = entrada.value.trim().replace(/\s+/g, " ");
      if (!nombre) return;
      const existente = $$("input[name=Habilidades]", lista).find((c) => c.value.toLowerCase() === nombre.toLowerCase());
      if (existente) {
        existente.checked = true;
      } else {
        const chip = document.createElement("label");
        chip.className = "chip-seleccion";
        const casilla = document.createElement("input");
        casilla.type = "checkbox";
        casilla.name = "Habilidades";
        casilla.value = nombre.slice(0, 60);
        casilla.checked = true;
        const texto = document.createElement("span");
        texto.textContent = casilla.value;
        chip.append(casilla, texto);
        lista.appendChild(chip);
      }
      entrada.value = "";
      entrada.focus();
    };
    $("[data-habilidad-agregar]", grupo)?.addEventListener("click", agregar);
    entrada?.addEventListener("keydown", (evento) => {
      if (evento.key === "Enter") {
        evento.preventDefault();
        agregar();
      }
    });
  });

  $$("[data-idiomas]").forEach((grupo) => {
    const lista = $("[data-idiomas-lista]", grupo);
    const plantilla = $("[data-idioma-plantilla]", grupo);
    $("[data-idioma-agregar]", grupo)?.addEventListener("click", () => {
      const fila = plantilla.content.firstElementChild.cloneNode(true);
      // Se propone el primer idioma que todavía no está elegido
      const elegidos = $$("select[name=IdiomaIds]", lista).map((s) => s.value);
      const selector = $("select[name=IdiomaIds]", fila);
      const libre = [...selector.options].find((o) => !elegidos.includes(o.value));
      if (libre) selector.value = libre.value;
      lista.appendChild(fila);
      selector.focus();
    });
    grupo.addEventListener("click", (evento) => {
      const quitar = evento.target.closest("[data-idioma-quitar]");
      if (quitar) quitar.closest("[data-idioma-fila]")?.remove();
    });
  });

  /* ------------------------------------------------------------------------
     Mis postulaciones: la persona mueve cada tarjeta (arrastrando o con el
     selector) y el cambio se guarda en el servidor
     ---------------------------------------------------------------------- */
  const tablero = $("[data-tablero]");
  if (tablero) {
    const token = $("input[name=__RequestVerificationToken]", tablero)?.value || "";
    let arrastrando = null;

    const actualizarContadores = () => {
      $$("[data-columna]", tablero).forEach((columna) => {
        const cantidad = $$("[data-postulacion]", columna).length;
        $("[data-columna-contador]", columna).textContent = String(cantidad);
        columna.classList.toggle("esta-vacia", cantidad === 0);
      });
    };

    // Guarda el estado. Si falla, la tarjeta vuelve a donde estaba.
    const guardar = async (tarjeta, columnaAnterior, siguienteAnterior) => {
      const columna = tarjeta.closest("[data-columna]");
      const estado = columna.dataset.columna;
      const selector = $("[data-estado-postulacion]", tarjeta);
      try {
        const cuerpo = new URLSearchParams({ estado, __RequestVerificationToken: token });
        const respuesta = await fetch(`${tablero.dataset.urlEstado}/${tarjeta.dataset.postulacion}`, {
          method: "POST",
          headers: { Accept: "application/json", "Content-Type": "application/x-www-form-urlencoded" },
          body: cuerpo
        });
        if (!respuesta.ok) throw new Error(String(respuesta.status));
        if (selector) selector.value = estado;
        snackbar(`Moviste la postulación a "${$("[data-columna-nombre]", columna).textContent.trim()}".`, "exito");
      } catch {
        $("[data-columna-lista]", columnaAnterior).insertBefore(tarjeta, siguienteAnterior);
        if (selector) selector.value = columnaAnterior.dataset.columna;
        snackbar("No pudimos guardar el cambio. Probá de nuevo.", "error");
      }
      actualizarContadores();
    };

    const mover = (tarjeta, estado) => {
      const anterior = tarjeta.closest("[data-columna]");
      const siguiente = tarjeta.nextElementSibling;
      const destino = $$("[data-columna]", tablero).find((c) => c.dataset.columna === estado);
      if (!destino || destino === anterior) return;
      $("[data-columna-lista]", destino).prepend(tarjeta);
      actualizarContadores();
      guardar(tarjeta, anterior, siguiente);
    };

    tablero.addEventListener("change", (evento) => {
      const selector = evento.target.closest("[data-estado-postulacion]");
      if (selector) mover(selector.closest("[data-postulacion]"), selector.value);
    });

    let origen = null;
    tablero.addEventListener("dragstart", (evento) => {
      const tarjeta = evento.target.closest?.("[data-postulacion]");
      if (!tarjeta) return;
      arrastrando = tarjeta;
      origen = { columna: tarjeta.closest("[data-columna]"), siguiente: tarjeta.nextElementSibling };
      tarjeta.classList.add("esta-arrastrando");
      evento.dataTransfer.effectAllowed = "move";
      evento.dataTransfer.setData("text/plain", tarjeta.dataset.postulacion);
    });
    tablero.addEventListener("dragend", () => {
      arrastrando?.classList.remove("esta-arrastrando");
      arrastrando = null;
      $$("[data-columna]", tablero).forEach((c) => c.classList.remove("es-destino"));
    });

    $$("[data-columna]", tablero).forEach((columna) => {
      const lista = $("[data-columna-lista]", columna);
      columna.addEventListener("dragover", (evento) => {
        if (!arrastrando) return;
        evento.preventDefault();
        columna.classList.add("es-destino");
        const despues = $$("[data-postulacion]:not(.esta-arrastrando)", lista).find((tarjeta) => {
          const caja = tarjeta.getBoundingClientRect();
          return evento.clientY < caja.top + caja.height / 2;
        });
        if (despues) lista.insertBefore(arrastrando, despues);
        else lista.insertBefore(arrastrando, $(".tablero__vacio", lista));
      });
      columna.addEventListener("dragleave", (evento) => {
        if (!columna.contains(evento.relatedTarget)) columna.classList.remove("es-destino");
      });
      columna.addEventListener("drop", (evento) => {
        evento.preventDefault();
        columna.classList.remove("es-destino");
        if (!arrastrando || !origen) return;
        actualizarContadores();
        if (origen.columna !== columna) guardar(arrastrando, origen.columna, origen.siguiente);
      });
    });
  }

  /* ------------------------------------------------------------------------
     Landing: el buscador "escribe" puestos reales (de JSearch o de Workly),
     espera 5 segundos y los borra letra por letra. Es solo el texto de
     ayuda: no busca nada ni muestra resultados.
     ---------------------------------------------------------------------- */
  $$("[data-animar-puestos]").forEach((entrada) => {
    const puestos = entrada.dataset.animarPuestos.split("|").map((p) => p.trim()).filter(Boolean);
    if (!puestos.length) return;
    const textoOriginal = entrada.placeholder;
    if (matchMedia("(prefers-reduced-motion: reduce)").matches) {
      entrada.placeholder = puestos[0];
      return;
    }
    let indice = 0;
    let temporizador = null;
    const esperar = (ms) => new Promise((resolver) => (temporizador = setTimeout(resolver, ms)));
    const enPausa = () => document.activeElement === entrada || entrada.value !== "";

    const animar = async () => {
      for (;;) {
        if (enPausa()) {
          entrada.placeholder = textoOriginal;
          await esperar(600);
          continue;
        }
        const puesto = puestos[indice % puestos.length];
        indice++;
        for (let i = 1; i <= puesto.length && !enPausa(); i++) {
          entrada.placeholder = puesto.slice(0, i);
          await esperar(70 + Math.random() * 60);
        }
        if (enPausa()) continue;
        await esperar(5000);
        for (let i = puesto.length - 1; i >= 0 && !enPausa(); i--) {
          entrada.placeholder = puesto.slice(0, i);
          await esperar(40);
        }
        await esperar(400);
      }
    };
    entrada.addEventListener("focus", () => (entrada.placeholder = textoOriginal));
    animar();
  });

  // Aviso que deja el servidor después de una acción (TempData["Mensaje"])
  $$("[data-snackbars][data-mensaje]").forEach((contenedor) => {
    if (contenedor.dataset.mensaje) snackbar(contenedor.dataset.mensaje, contenedor.dataset.mensajeTipo || "exito");
  });

  /* ------------------------------------------------------------------------
     Ayuda: filtrar preguntas frecuentes mientras se escribe
     ---------------------------------------------------------------------- */
  $$("[data-filtrar-preguntas]").forEach((input) => {
    const items = $$("[data-acordeon] .acordeon__item");
    const vacio = $("[data-acordeon-vacio]");
    input.form?.addEventListener("submit", (evento) => evento.preventDefault());
    input.addEventListener("input", () => {
      const texto = input.value.trim().toLowerCase();
      let visibles = 0;
      items.forEach((item) => {
        const coincide = !texto || item.textContent.toLowerCase().includes(texto);
        item.hidden = !coincide;
        if (coincide) visibles++;
        if (texto && coincide) item.open = true;
      });
      if (vacio) vacio.hidden = visibles > 0;
      // Los títulos de cada grupo se ocultan si no quedó ninguna pregunta del grupo
      $$("[data-acordeon-grupo]").forEach((grupo) => {
        grupo.hidden = !items.some((item) => !item.hidden && item.dataset.grupo === grupo.id);
      });
    });
  });

  // API pública mínima para usar desde las vistas o la consola
  window.Workly = { snackbar };
})();
