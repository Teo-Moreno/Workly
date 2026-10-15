/* ==========================================================================
   Workly · Interacciones visuales
   JavaScript sin dependencias. Cada comportamiento se activa con atributos
   data-* en el HTML, así las vistas no necesitan scripts propios.
   Todo es visual: no se envían datos al servidor.
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
  const iconosSnackbar = { exito: "circle-check", advertencia: "warning", error: "error", "": "notification" };

  function snackbar(texto, tipo = "") {
    const contenedor = $("[data-snackbars]");
    if (!contenedor) return;
    const elemento = document.createElement("div");
    elemento.className = `snackbar ${tipo ? `snackbar--${tipo}` : ""}`;
    elemento.setAttribute("role", tipo === "error" ? "alert" : "status");
    elemento.innerHTML = `${icono(iconosSnackbar[tipo] || "notification", 22)}
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
     Desplegables: notificaciones, menú de usuario, ordenar por
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

  // "Ordenar por": actualiza el texto del botón
  $$("[data-ordenar]").forEach((menu) => {
    menu.addEventListener("click", (evento) => {
      const opcion = evento.target.closest(".menu__item");
      if (!opcion) return;
      $$(".menu__item", menu).forEach((item) => item.classList.toggle("esta-activo", item === opcion));
      const desplegable = menu.closest("[data-desplegable]");
      const valor = $("[data-ordenar-valor]", desplegable);
      if (valor) valor.textContent = opcion.textContent.trim();
      cerrarDesplegables();
    });
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

    // Abrir la pestaña indicada en la URL (#preferencias, #guardadas...)
    if (contenedor.hasAttribute("data-pestanas-hash") && location.hash) {
      activarPestana(contenedor, decodeURIComponent(location.hash.slice(1)));
    }
  });

  window.addEventListener("hashchange", () => {
    $$("[data-pestanas][data-pestanas-hash]").forEach((contenedor) =>
      activarPestana(contenedor, decodeURIComponent(location.hash.slice(1)))
    );
  });

  /* ------------------------------------------------------------------------
     Notificaciones: marcar todas como leídas
     ---------------------------------------------------------------------- */
  $$("[data-marcar-leidas]").forEach((boton) => {
    boton.addEventListener("click", () => {
      $$("[data-notificacion].es-no-leida").forEach((n) => n.classList.remove("es-no-leida"));
      $$("[data-contador-notificaciones]").forEach((contador) => {
        contador.textContent = "0";
        contador.dataset.cantidad = "0";
      });
      snackbar("Marcaste todas las notificaciones como leídas.", "exito");
    });
  });

  /* ------------------------------------------------------------------------
     Buscar trabajo: filtros, chips de filtros activos, rango salarial
     ---------------------------------------------------------------------- */
  const listaChips = $("[data-filtros-activos-lista]");

  function dibujarChips() {
    if (!listaChips) return;
    const marcadas = $$("[data-filtro-casilla]:checked");
    listaChips.innerHTML = "";
    marcadas.forEach((casilla) => {
      const chip = document.createElement("span");
      chip.className = "chip";
      chip.dataset.chip = casilla.value;
      chip.textContent = casilla.value;
      chip.insertAdjacentHTML(
        "beforeend",
        `<button class="chip__quitar" type="button" aria-label="Quitar filtro ${casilla.value}" data-chip-quitar>${icono("close-big", 14)}</button>`
      );
      listaChips.appendChild(chip);
    });
    $("[data-filtros-activos]")?.classList.toggle("esta-vacio", marcadas.length === 0);
  }

  $$("[data-filtro-casilla]").forEach((casilla) => casilla.addEventListener("change", dibujarChips));

  document.addEventListener("click", (evento) => {
    const quitar = evento.target.closest("[data-chip-quitar]");
    if (quitar) {
      const valor = quitar.closest("[data-chip]").dataset.chip;
      const casilla = $$("[data-filtro-casilla]").find((c) => c.value === valor);
      if (casilla) casilla.checked = false;
      quitar.closest("[data-chip]").remove();
      dibujarChips();
    }

    if (evento.target.closest("[data-limpiar-filtros]")) {
      $$("[data-filtro-casilla]").forEach((casilla) => (casilla.checked = false));
      dibujarChips();
    }
  });

  const formatoPesos = new Intl.NumberFormat("es-AR", { style: "currency", currency: "ARS", maximumFractionDigits: 0 });

  $$("[data-rango]").forEach((rango) => {
    const minimo = $("[data-rango-min]", rango);
    const maximo = $("[data-rango-max]", rango);
    const contenedor = rango.parentElement;
    const actualizar = (evento) => {
      let a = Number(minimo.value);
      let b = Number(maximo.value);
      if (a > b) {
        if (evento?.target === minimo) minimo.value = a = b;
        else maximo.value = b = a;
      }
      const total = Number(minimo.max) - Number(minimo.min);
      rango.style.setProperty("--min", `${((a - minimo.min) / total) * 100}%`);
      rango.style.setProperty("--max", `${((b - minimo.min) / total) * 100}%`);
      const textoMin = $("[data-rango-texto-min]", contenedor);
      const textoMax = $("[data-rango-texto-max]", contenedor);
      if (textoMin) textoMin.textContent = formatoPesos.format(a).replace(/\s/g, "");
      if (textoMax) textoMax.textContent = formatoPesos.format(b).replace(/\s/g, "");
    };
    minimo.addEventListener("input", actualizar);
    maximo.addEventListener("input", actualizar);
    actualizar();
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

  // Cargar más ofertas (muestra las tarjetas ocultas con un spinner)
  $$("[data-cargar-mas]").forEach((boton) => {
    boton.addEventListener("click", () => {
      const ocultas = $$("[data-resultados] [data-oferta][hidden]");
      const spinner = $("[data-cargar-mas-spinner]", boton);
      boton.classList.add("esta-cargando");
      if (spinner) spinner.hidden = false;
      setTimeout(() => {
        boton.classList.remove("esta-cargando");
        if (spinner) spinner.hidden = true;
        if (!ocultas.length) {
          snackbar("Ya viste todas las ofertas compatibles por hoy.");
          return;
        }
        ocultas.slice(0, 3).forEach((tarjeta) => {
          tarjeta.hidden = false;
          tarjeta.classList.add("es-nueva");
        });
        if ($$("[data-resultados] [data-oferta][hidden]").length === 0) {
          boton.disabled = true;
          boton.lastChild.textContent = "No hay más ofertas";
        }
      }, 900);
    });
  });

  /* ------------------------------------------------------------------------
     Guardar oferta / Seguir empresa / Compartir
     ---------------------------------------------------------------------- */
  document.addEventListener("click", (evento) => {
    const guardar = evento.target.closest("[data-guardar]");
    if (guardar) {
      const activo = !guardar.classList.contains("esta-activo");
      guardar.classList.toggle("esta-activo", activo);
      guardar.setAttribute("aria-pressed", String(activo));
      cambiarIcono(guardar, activo ? "bookmark-fill" : "bookmark");
      const texto = $("[data-guardar-texto]", guardar);
      if (texto) texto.textContent = activo ? "Guardada" : "Guardar";
      snackbar(activo ? "Guardaste la oferta en tus postulaciones." : "Quitaste la oferta de guardadas.", activo ? "exito" : "");
      return;
    }

    const seguir = evento.target.closest("[data-seguir]");
    if (seguir) {
      const activo = !seguir.classList.contains("esta-activo");
      seguir.classList.toggle("esta-activo", activo);
      seguir.setAttribute("aria-pressed", String(activo));
      cambiarIcono(seguir, activo ? "check" : "plus");
      const texto = $("[data-seguir-texto]", seguir);
      if (texto) texto.textContent = activo ? "Siguiendo" : "Seguir";
      return;
    }

    const compartir = evento.target.closest("[data-compartir]");
    if (compartir) {
      const enlace = compartir.dataset.compartir || location.href;
      navigator.clipboard?.writeText(new URL(enlace, location.origin).href).catch(() => {});
      snackbar("Copiamos el enlace de la oferta.", "exito");
      return;
    }

    const sinDetalle = evento.target.closest("[data-sin-detalle]");
    if (sinDetalle) {
      evento.preventDefault();
      snackbar("Esta búsqueda ya no está publicada en Workly.", "advertencia");
    }
  });

  /* ------------------------------------------------------------------------
     Modales (<dialog> nativo)
     ---------------------------------------------------------------------- */
  document.addEventListener("click", (evento) => {
    const abrir = evento.target.closest("[data-modal-abrir]");
    if (abrir) {
      document.getElementById(abrir.dataset.modalAbrir)?.showModal();
      return;
    }
    // Clic sobre el fondo oscuro
    if (evento.target.tagName === "DIALOG" && evento.target.open) {
      const caja = evento.target.getBoundingClientRect();
      const fuera =
        evento.clientX < caja.left || evento.clientX > caja.right || evento.clientY < caja.top || evento.clientY > caja.bottom;
      if (fuera) evento.target.close("cancelar");
    }
  });

  /* Postularme ahora → pop up de confirmación → snackbar de éxito */
  const modalPostular = document.getElementById("modal-postular");
  let botonPostular = null;

  document.addEventListener("click", (evento) => {
    const boton = evento.target.closest("[data-postular]");
    if (!boton || !modalPostular) return;
    botonPostular = boton;
    $("[data-modal-puesto]", modalPostular).textContent = boton.dataset.puesto || "este puesto";
    $("[data-modal-empresa]", modalPostular).textContent = boton.dataset.empresa || "la empresa";
    modalPostular.showModal();
  });

  modalPostular?.addEventListener("close", () => {
    if (modalPostular.returnValue !== "confirmar" || !botonPostular) return;
    const puesto = botonPostular.dataset.puesto;
    $$(`[data-postular][data-puesto="${CSS.escape(puesto)}"]`).forEach((b) => {
      b.disabled = true;
      b.innerHTML = `${icono("check", 20)}Postulación enviada`;
    });
    snackbar("¡Postulación enviada con éxito!", "exito");
  });

  /* Recorte de la foto de perfil: el slider controla el zoom */
  $$("[data-zoom-foto]").forEach((slider) => {
    const imagen = document.getElementById(slider.dataset.zoomFoto);
    const actualizar = () => {
      imagen?.style.setProperty("--zoom", String(slider.value / 100));
      const avance = ((slider.value - slider.min) / (slider.max - slider.min)) * 100;
      slider.style.setProperty("--avance", `${avance}%`);
    };
    slider.addEventListener("input", actualizar);
    actualizar();
  });

  $$("dialog[data-snackbar-al-confirmar]").forEach((dialogo) => {
    dialogo.addEventListener("close", () => {
      if (dialogo.returnValue === "confirmar") snackbar(dialogo.dataset.snackbarAlConfirmar, "exito");
    });
  });

  /* ------------------------------------------------------------------------
     Postulaciones: tablero con arrastrar y soltar entre columnas
     ---------------------------------------------------------------------- */
  let arrastrando = null;

  const actualizarContadores = () => {
    $$("[data-columna]").forEach((columna) => {
      const cantidad = $$("[data-postulacion]", columna).length;
      const contador = $("[data-columna-contador]", columna);
      if (contador) contador.textContent = String(cantidad);
      columna.classList.toggle("esta-vacia", cantidad === 0);
    });
  };

  document.addEventListener("dragstart", (evento) => {
    const tarjeta = evento.target.closest?.("[data-postulacion]");
    if (!tarjeta) return;
    arrastrando = tarjeta;
    tarjeta.classList.add("esta-arrastrando");
    evento.dataTransfer.effectAllowed = "move";
    evento.dataTransfer.setData("text/plain", tarjeta.dataset.postulacion);
  });

  document.addEventListener("dragend", () => {
    arrastrando?.classList.remove("esta-arrastrando");
    arrastrando = null;
    $$("[data-columna]").forEach((c) => c.classList.remove("es-destino"));
  });

  $$("[data-columna]").forEach((columna) => {
    const lista = $("[data-columna-lista]", columna) || columna;
    columna.addEventListener("dragover", (evento) => {
      if (!arrastrando) return;
      evento.preventDefault();
      columna.classList.add("es-destino");
      const despues = $$("[data-postulacion]:not(.esta-arrastrando)", lista).find((tarjeta) => {
        const caja = tarjeta.getBoundingClientRect();
        return evento.clientY < caja.top + caja.height / 2;
      });
      if (despues) lista.insertBefore(arrastrando, despues);
      else lista.appendChild(arrastrando);
    });
    columna.addEventListener("dragleave", (evento) => {
      if (!columna.contains(evento.relatedTarget)) columna.classList.remove("es-destino");
    });
    columna.addEventListener("drop", (evento) => {
      evento.preventDefault();
      columna.classList.remove("es-destino");
      actualizarContadores();
      const nombre = $("[data-columna-nombre]", columna)?.textContent.trim();
      if (nombre) snackbar(`Moviste la postulación a "${nombre}".`);
    });
  });

  /* ------------------------------------------------------------------------
     Empresas: filtro por industria y búsqueda por nombre
     ---------------------------------------------------------------------- */
  const grillaEmpresas = $("[data-grilla-empresas]");
  if (grillaEmpresas) {
    let industria = "Todas";
    const buscador = $("[data-buscar-empresa]");
    const vacio = $("[data-empresas-vacio]");

    const filtrar = () => {
      const texto = (buscador?.value || "").trim().toLowerCase();
      let visibles = 0;
      $$("[data-empresa]", grillaEmpresas).forEach((tarjeta) => {
        const coincideIndustria = industria === "Todas" || tarjeta.dataset.categorias.split("|").includes(industria);
        const coincideTexto = !texto || tarjeta.dataset.nombre.includes(texto);
        tarjeta.hidden = !(coincideIndustria && coincideTexto);
        if (!tarjeta.hidden) visibles++;
      });
      if (vacio) vacio.hidden = visibles > 0;
    };

    $$("[data-industria]").forEach((chip) => {
      chip.addEventListener("click", () => {
        industria = chip.dataset.industria;
        $$("[data-industria]").forEach((c) => c.setAttribute("aria-pressed", String(c === chip)));
        filtrar();
      });
    });
    buscador?.addEventListener("input", filtrar);
    buscador?.form?.addEventListener("submit", (evento) => {
      evento.preventDefault();
      filtrar();
    });
  }

  /* ------------------------------------------------------------------------
     Formularios de demostración
     data-demo-form="Mensaje"            → muestra un snackbar al enviar
     data-redirigir="/Panel"            → navega luego de "enviar"
     ---------------------------------------------------------------------- */
  function validar(formulario) {
    let valido = true;
    $$("[required]", formulario).forEach((control) => {
      if (control.closest("[hidden]")) return;
      const campo = control.closest(".campo");
      const ok = control.type === "checkbox" ? control.checked : control.value.trim() !== "" && control.checkValidity();
      campo?.classList.toggle("campo--error", !ok);
      if (!ok && valido) {
        control.focus();
        valido = false;
      }
    });
    return valido;
  }

  $$("form [required]").forEach((control) => {
    control.addEventListener("input", () => {
      const campo = control.closest(".campo");
      if (campo?.classList.contains("campo--error") && control.value.trim() !== "") campo.classList.remove("campo--error");
    });
  });

  $$("form[data-demo-form]").forEach((formulario) => {
    formulario.addEventListener("submit", (evento) => {
      evento.preventDefault();
      if (!validar(formulario)) {
        snackbar("Revisá los campos marcados en rojo.", "error");
        return;
      }
      const boton = $("button[type=submit]", formulario);
      const mensaje = formulario.dataset.demoForm;
      const destino = formulario.dataset.redirigir;
      if (boton) {
        boton.classList.add("esta-cargando");
        boton.insertAdjacentHTML("afterbegin", '<span class="spinner spinner--sm spinner--claro" data-temporal></span>');
      }
      setTimeout(() => {
        if (boton) {
          boton.classList.remove("esta-cargando");
          $("[data-temporal]", boton)?.remove();
        }
        if (mensaje) snackbar(mensaje, "exito");
        if (destino) setTimeout(() => (location.href = destino), mensaje ? 700 : 0);
        else if (formulario.hasAttribute("data-limpiar")) formulario.reset();
      }, 700);
    });
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

  // Zona de arrastrar y soltar archivos (CV)
  $$("[data-zona-archivo]").forEach((zona) => {
    const input = $("input[type=file]", zona);
    const nombre = $("[data-zona-archivo-nombre]", zona);
    const mostrar = (archivo) => {
      if (!archivo) return;
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
      mostrar(evento.dataTransfer.files[0]);
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

    const mostrar = (indice) => {
      actual = indice;
      pasos.forEach((paso, i) => (paso.hidden = i !== indice));
      indicadores.forEach((indicador, i) => {
        indicador.classList.toggle("esta-completo", i < indice);
        indicador.classList.toggle("esta-actual", i === indice);
        if (i === indice) indicador.setAttribute("aria-current", "step");
        else indicador.removeAttribute("aria-current");
      });
      $("[data-paso-actual]")?.replaceChildren(String(indice + 1));
      pasos[indice].querySelector("input, select, textarea")?.focus({ preventScroll: true });
      window.scrollTo({ top: 0, behavior: "smooth" });
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

    mostrar(0);
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
    });
  });

  // Botones que solo muestran un aviso (Exportar, Descargar CV, etc.)
  $$("[data-confirmar-accion]").forEach((boton) => {
    boton.addEventListener("click", () => snackbar(boton.dataset.confirmarAccion, boton.dataset.tipo || "exito"));
  });

  // API pública mínima para usar desde las vistas o la consola
  window.Workly = { snackbar };
})();
