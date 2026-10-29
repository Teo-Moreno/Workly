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

  document.addEventListener("click", (evento) => {
    const cerrar = evento.target.closest("[data-cerrar-aviso]");
    if (cerrar) cerrar.closest(".snackbar")?.remove();
  });

  $$("[data-menu-movil]").forEach((boton) => {
    boton.addEventListener("click", () => {
      const navbar = boton.closest("[data-navbar]");
      const abierto = navbar.classList.toggle("esta-abierta");
      boton.setAttribute("aria-expanded", String(abierto));
      cambiarIcono(boton, abierto ? "close-big" : "menu");
    });
  });

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

    if (contenedor.hasAttribute("data-pestanas-hash") && location.hash) {
      activarPestana(contenedor, decodeURIComponent(location.hash.slice(1)));
    }
  });

  window.addEventListener("hashchange", () => {
    $$("[data-pestanas][data-pestanas-hash]").forEach((contenedor) =>
      activarPestana(contenedor, decodeURIComponent(location.hash.slice(1)))
    );
  });

  $$("[data-alternar]").forEach((boton) => {
    boton.addEventListener("click", () => {
      const panel = document.getElementById(boton.dataset.alternar);
      const abierto = panel.classList.toggle("esta-abierto");
      boton.setAttribute("aria-expanded", String(abierto));
    });
  });

  const panelDetalles = $("[data-detalles]");

  if (panelDetalles) {
    $("[data-resultados]")?.addEventListener("click", (evento) => {
      const tarjeta = evento.target.closest("[data-oferta]");
      if (!tarjeta) return;
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

  $$("[data-zona-archivo]").forEach((zona) => {
    const input = $("input[type=file]", zona);
    const nombre = $("[data-zona-archivo-nombre]", zona);
    const textoInicial = nombre?.textContent;
    const teniaArchivo = zona.classList.contains("tiene-archivo");
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
      if (input) input.files = archivos;
      mostrar(archivos[0]);
    });
    input?.addEventListener("change", () => mostrar(input.files[0]));
  });

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

    const pasoConError = pasos.findIndex((paso) => paso.querySelector(".campo--error"));
    mostrar(Math.max(pasoConError, 0), pasoConError >= 0);
  });

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
      formulario.addEventListener("submit", (e) => e.preventDefault(), { once: true });
    });
  });

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

    const formatear = (digitos) => {
      const largoArea = digitos.startsWith("11") ? 2 : areas3.includes(digitos.slice(0, 3)) ? 3 : digitos.length >= 4 ? 4 : 0;
      if (!largoArea || digitos.length <= largoArea) return digitos;
      const area = digitos.slice(0, largoArea);
      const numero = digitos.slice(largoArea);
      const corte = DIGITOS - largoArea - 4;
      return numero.length > corte ? `${area} ${numero.slice(0, corte)}-${numero.slice(corte)}` : `${area} ${numero}`;
    };

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
      let posicion = 0;
      for (let vistos = 0; posicion < nuevo.length && vistos < digitosAntes; posicion++) {
        if (/\d/.test(nuevo[posicion])) vistos++;
      }
      entrada.setSelectionRange(posicion, posicion);
    };

    entrada.addEventListener("beforeinput", (evento) => {
      if (evento.inputType === "insertText" && /\D/.test(evento.data || "")) {
        evento.preventDefault();
        return;
      }
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
    if (evento.target.tagName === "DIALOG" && evento.target.open) {
      const caja = evento.target.getBoundingClientRect();
      const fuera =
        evento.clientX < caja.left || evento.clientX > caja.right || evento.clientY < caja.top || evento.clientY > caja.bottom;
      if (fuera) evento.target.close();
    }
  });

  $$('dialog[data-abrir-al-cargar="true"]').forEach((dialogo) => dialogo.showModal());

  document.addEventListener("submit", (evento) => {
    const formulario = evento.target;
    if (formulario.dataset.confirmar && !confirm(formulario.dataset.confirmar)) evento.preventDefault();
  }, true);

  document.addEventListener("change", (evento) => {
    const control = evento.target.closest?.("[data-enviar-al-cambiar], [data-enviar-al-cambiar] select");
    if (!control || control.closest("[data-tablero]")) return;
    const formulario = control.form || control.closest("form");
    if (formulario) formulario.requestSubmit ? formulario.requestSubmit() : formulario.submit();
  });

  $$("[data-igual-a]").forEach((repetir) => {
    const original = document.getElementById(repetir.dataset.igualA);
    const revisar = () => repetir.setCustomValidity(repetir.value && original && repetir.value !== original.value ? "No coinciden" : "");
    repetir.addEventListener("input", revisar);
    original?.addEventListener("input", revisar);
  });

  $$("[data-cuit]").forEach((entrada) => {
    const formatear = () => {
      const d = entrada.value.replace(/\D/g, "").slice(0, 11);
      entrada.value = d.length > 10 ? `${d.slice(0, 2)}-${d.slice(2, 10)}-${d.slice(10)}` : d.length > 2 ? `${d.slice(0, 2)}-${d.slice(2)}` : d;
    };
    entrada.addEventListener("input", formatear);
    formatear();
  });

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

    entrada.addEventListener("input", (evento) => {
      if (evento.isTrusted === false) return;
      const d = entrada.value.replace(/\D/g, "").slice(0, 6);
      entrada.value = d.length > 2 ? `${d.slice(0, 2)}/${d.slice(2)}` : d;
    });
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

  $$("[data-captcha]").forEach((caja) => {
    const imagen = $("[data-captcha-imagen]", caja);
    const token = $("[data-captcha-token]", caja);
    const entrada = $("input[name=CaptchaRespuesta]", caja);
    $("[data-captcha-otra]", caja)?.addEventListener("click", async () => {
      try {
        const respuesta = await fetch(caja.dataset.captchaUrl, { headers: { Accept: "application/json" } });
        if (!respuesta.ok) throw new Error(String(respuesta.status));
        const datos = await respuesta.json();
        imagen.src = datos.imagen;
        token.value = datos.token;
        entrada.value = "";
        entrada.focus();
      } catch {
        snackbar("No pudimos cargar otra imagen. Probá de nuevo.", "error");
      }
    });
  });

  $$("[data-aceptar-cookies]").forEach((boton) => {
    boton.addEventListener("click", () => {
      document.cookie = `Workly.Cookies=ok; max-age=${60 * 60 * 24 * 365}; path=/; SameSite=Lax${location.protocol === "https:" ? "; Secure" : ""}`;
      boton.closest("[data-aviso-cookies]")?.remove();
    });
  });

  $$("[data-snackbars][data-mensaje]").forEach((contenedor) => {
    if (contenedor.dataset.mensaje) snackbar(contenedor.dataset.mensaje, contenedor.dataset.mensajeTipo || "exito");
  });

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
      $$("[data-acordeon-grupo]").forEach((grupo) => {
        grupo.hidden = !items.some((item) => !item.hidden && item.dataset.grupo === grupo.id);
      });
    });
  });

  window.Workly = { snackbar };
})();
