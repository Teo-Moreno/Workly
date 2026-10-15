namespace Workly.Models;

/// <summary>
/// Datos de ejemplo para maquetar las vistas (los mismos que aparecen en los
/// wireframes de Figma). Cuando exista la base de datos, reemplazar estos
/// métodos por consultas reales manteniendo las mismas firmas.
/// </summary>
public static class DatosDeEjemplo
{
    public static readonly List<Empresa> Empresas = new()
    {
        new Empresa
        {
            Id = 1, Nombre = "Mercado Libre", Iniciales = "ML",
            Industria = "E-commerce y fintech", Categorias = new() { "E-commerce", "Fintech", "Tecnología" },
            Ubicacion = "Saavedra, CABA",
            Descripcion = "La plataforma de comercio electrónico y pagos más grande de Latinoamérica.",
            SobreNosotros = "Democratizamos el comercio y el dinero en América Latina. Nuestros equipos de tecnología construyen productos que usan millones de personas todos los días: marketplace, pagos, envíos y crédito. Trabajamos en células autónomas, con foco en el impacto y en el aprendizaje continuo.",
            Empleados = "+58.000", BusquedasActivas = 42, Valoracion = "4,5", RespondeEn = "~5 días",
            Fundada = "1999", SitioWeb = "mercadolibre.com.ar",
            Beneficios = new() { "Híbrido flexible", "Prepaga", "Capacitaciones" },
            Valoraciones = new() { ("Ambiente laboral", 4.6), ("Equilibrio vida-trabajo", 4.2), ("Salario y beneficios", 4.5), ("Oportunidades de crecimiento", 4.7) }
        },
        new Empresa
        {
            Id = 2, Nombre = "Globant", Iniciales = "G",
            Industria = "Tecnología y consultoría", Categorias = new() { "Tecnología", "Consultoría" },
            Ubicacion = "Palermo, CABA",
            Descripcion = "Compañía de ingeniería de software nativa digital, con equipos en más de 30 países.",
            SobreNosotros = "Creamos productos digitales para algunas de las marcas más grandes del mundo. Nuestros Studios combinan ingeniería, diseño e innovación, y acompañamos el crecimiento de cada globant con planes de carrera claros y formación permanente.",
            Empleados = "+29.000", BusquedasActivas = 35, Valoracion = "4,3", RespondeEn = "~4 días",
            Fundada = "2003", SitioWeb = "globant.com",
            Beneficios = new() { "Remoto flexible", "Clases de inglés", "Plan de carrera" },
            Valoraciones = new() { ("Ambiente laboral", 4.4), ("Equilibrio vida-trabajo", 4.1), ("Salario y beneficios", 4.0), ("Oportunidades de crecimiento", 4.6) }
        },
        new Empresa
        {
            Id = 3, Nombre = "Ualá", Iniciales = "U",
            Industria = "Fintech", Categorias = new() { "Fintech", "Tecnología" },
            Ubicacion = "Palermo, CABA",
            Descripcion = "App financiera con cuenta, tarjeta e inversiones para millones de usuarios en la región.",
            SobreNosotros = "Queremos que el dinero sea simple para todas las personas. Somos un equipo joven que trabaja con autonomía, toma decisiones basadas en datos y lanza mejoras todas las semanas.",
            Empleados = "+1.500", BusquedasActivas = 18, Valoracion = "4,4", RespondeEn = "~6 días",
            Fundada = "2017", SitioWeb = "uala.com.ar",
            Beneficios = new() { "Home office", "Stock options", "Gimnasio" },
            Valoraciones = new() { ("Ambiente laboral", 4.5), ("Equilibrio vida-trabajo", 4.3), ("Salario y beneficios", 4.4), ("Oportunidades de crecimiento", 4.3) }
        },
        new Empresa
        {
            Id = 4, Nombre = "Tiendanube", Iniciales = "TN",
            Industria = "E-commerce", Categorias = new() { "E-commerce", "Tecnología" },
            Ubicacion = "Belgrano, CABA",
            Descripcion = "Plataforma para crear tiendas online, elegida por más de 100.000 marcas en Latinoamérica.",
            SobreNosotros = "Ayudamos a marcas de todos los tamaños a vender online. Somos una empresa 100% remota, con equipos distribuidos en toda la región y una cultura basada en la confianza y el feedback.",
            Empleados = "+1.000", BusquedasActivas = 12, Valoracion = "4,6", RespondeEn = "~3 días",
            Fundada = "2011", SitioWeb = "tiendanube.com",
            Beneficios = new() { "100% remoto", "Horario flexible", "Budget de formación" },
            Valoraciones = new() { ("Ambiente laboral", 4.7), ("Equilibrio vida-trabajo", 4.6), ("Salario y beneficios", 4.3), ("Oportunidades de crecimiento", 4.5) }
        },
        new Empresa
        {
            Id = 5, Nombre = "Naranja X", Iniciales = "NX",
            Industria = "Fintech", Categorias = new() { "Fintech" },
            Ubicacion = "Córdoba",
            Descripcion = "Fintech de Grupo Galicia con billetera virtual, tarjetas y préstamos para todo el país.",
            SobreNosotros = "Nacimos en Córdoba y hoy llegamos a todo el país. Construimos soluciones financieras simples y cercanas, con equipos que combinan tecnología, negocio y experiencia de usuario.",
            Empleados = "+3.000", BusquedasActivas = 15, Valoracion = "4,2", RespondeEn = "~7 días",
            Fundada = "2019", SitioWeb = "naranjax.com",
            Beneficios = new() { "Híbrido", "Prepaga", "Día de cumpleaños libre" },
            Valoraciones = new() { ("Ambiente laboral", 4.3), ("Equilibrio vida-trabajo", 4.2), ("Salario y beneficios", 4.0), ("Oportunidades de crecimiento", 4.1) }
        },
        new Empresa
        {
            Id = 6, Nombre = "Despegar", Iniciales = "D",
            Industria = "Turismo y tecnología", Categorias = new() { "Turismo", "Tecnología" },
            Ubicacion = "Saavedra, CABA",
            Descripcion = "Agencia de viajes online líder en Latinoamérica, con producto propio y equipos de tecnología.",
            SobreNosotros = "Hacemos que viajar sea más fácil. Desarrollamos el producto completo de punta a punta: búsqueda, pagos y atención, con equipos de tecnología que trabajan en sprints cortos y con mucha autonomía.",
            Empleados = "+4.500", BusquedasActivas = 9, Valoracion = "4,1", RespondeEn = "~8 días",
            Fundada = "1999", SitioWeb = "despegar.com.ar",
            Beneficios = new() { "Descuentos en viajes", "Híbrido", "Capacitaciones" },
            Valoraciones = new() { ("Ambiente laboral", 4.2), ("Equilibrio vida-trabajo", 4.0), ("Salario y beneficios", 3.9), ("Oportunidades de crecimiento", 4.2) }
        }
    };

    public static readonly List<Oferta> Ofertas = new()
    {
        new Oferta
        {
            Id = 1, Puesto = "Frontend Developer React", EmpresaId = 2, Empresa = "Globant", Iniciales = "G",
            Ubicacion = "Palermo, CABA", UbicacionCorta = "CABA · Híbrido",
            Modalidad = "Híbrido", ModalidadDetalle = "Híbrido · 3 días en oficina", Nivel = "Semi Senior",
            Salario = "$1.800.000 – $2.300.000", Experiencia = "2 a 4 años",
            Match = 94, MatchResumen = "Cumplís 5 de 6 habilidades pedidas y tu expectativa salarial está dentro del rango.",
            Publicado = "Hace 2 días", Tecnologias = new() { "React", "TypeScript" },
            SobrePuesto = "Vas a sumarte al equipo de Web UI para desarrollar interfaces de una plataforma de e-commerce usada por más de 2 millones de personas en la región. Trabajarás junto a diseño de producto y equipos de backend en sprints de dos semanas.",
            Requisitos = new()
            {
                "2 o más años de experiencia con React y TypeScript",
                "Buen manejo de HTML semántico, CSS y metodologías como BEM",
                "Experiencia consumiendo APIs REST",
                "Uso de Git y trabajo con Pull Requests",
                "Inglés intermedio para reuniones con equipos del exterior"
            },
            Beneficios = new() { "Prepaga corporativa", "Clases de inglés", "Plan de carrera", "Días de home office" },
            HabilidadesCumplidas = new() { "React", "TypeScript", "CSS / BEM", "Git", "APIs REST" },
            HabilidadFaltante = "Testing (Jest)"
        },
        new Oferta
        {
            Id = 2, Puesto = "Desarrollador/a Frontend Jr", EmpresaId = 4, Empresa = "Tiendanube", Iniciales = "TN",
            Ubicacion = "Remoto (Argentina)", UbicacionCorta = "Remoto (AR)",
            Modalidad = "Remoto", ModalidadDetalle = "Remoto", Nivel = "Junior",
            Salario = "$1.100.000 – $1.400.000", Experiencia = "0 a 2 años",
            Match = 91, MatchResumen = "Cumplís 4 de 5 habilidades pedidas. Tu expectativa salarial está dentro del rango.",
            Publicado = "Hace 3 días", Tecnologias = new() { "JavaScript", "CSS" },
            SobrePuesto = "Vas a trabajar en el equipo de Storefront, construyendo las páginas que usan compradores de más de 100.000 tiendas online. Un equipo senior te va a acompañar de cerca durante el onboarding.",
            Requisitos = new()
            {
                "Conocimientos de JavaScript moderno (ES6+)",
                "HTML semántico y CSS, metodología BEM valorada",
                "Nociones de control de versiones con Git",
                "Ganas de aprender React en el día a día",
                "Buena comunicación escrita para trabajar 100% remoto"
            },
            Beneficios = new() { "100% remoto", "Horario flexible", "Budget de formación", "Equipamiento provisto" },
            HabilidadesCumplidas = new() { "JavaScript", "CSS / BEM", "Git" },
            HabilidadFaltante = "React (se aprende en el puesto)"
        },
        new Oferta
        {
            Id = 3, Puesto = "UI Developer", EmpresaId = 1, Empresa = "Mercado Libre", Iniciales = "ML",
            Ubicacion = "Saavedra, CABA", UbicacionCorta = "Saavedra · Híbrido",
            Modalidad = "Híbrido", ModalidadDetalle = "Híbrido", Nivel = "Semi Senior",
            Salario = "$2.000.000 – $2.600.000", Experiencia = "3 a 5 años", ExperienciaDetalle = "en desarrollo de interfaces",
            Match = 86, MatchResumen = "Cumplís 4 de 6 habilidades pedidas. Te falta experiencia formal con Design Systems a gran escala.",
            Publicado = "Hace 5 días", Tecnologias = new() { "React", "Design Systems", "Storybook" },
            SobrePuesto = "Vas a formar parte del equipo de Design Systems, manteniendo y evolucionando la librería de componentes que usan más de 40 equipos de producto dentro de Mercado Libre.",
            Requisitos = new()
            {
                "3 o más años de experiencia con React",
                "Experiencia manteniendo librerías de componentes",
                "Manejo de Storybook y documentación de componentes",
                "Buen ojo para el detalle visual y la accesibilidad",
                "Inglés intermedio para documentación técnica"
            },
            Beneficios = new() { "Prepaga premium", "Descuentos en Mercado Libre y Mercado Pago", "Capacitaciones internas", "Snacks y desayuno en oficina" },
            HabilidadesCumplidas = new() { "React", "CSS / BEM", "Git", "Storybook" },
            HabilidadFaltante = "Design Systems a gran escala"
        },
        new Oferta
        {
            Id = 4, Puesto = "Frontend Engineer (Vue)", EmpresaId = 3, Empresa = "Ualá", Iniciales = "U",
            Ubicacion = "Remoto (Argentina)", UbicacionCorta = "Remoto (AR)",
            Modalidad = "Remoto", ModalidadDetalle = "Remoto", Nivel = "Semi Senior",
            Salario = "$1.900.000 – $2.400.000", Experiencia = "2 a 4 años",
            Match = 79, MatchResumen = "Cumplís 3 de 5 habilidades pedidas. Vue.js es nuevo para vos, pero tu experiencia con React suma.",
            Publicado = "Hace 1 semana", Tecnologias = new() { "Vue.js", "Git" },
            SobrePuesto = "Vas a desarrollar las pantallas web de la cuenta y las inversiones de Ualá, trabajando con diseño para lanzar mejoras todas las semanas en un producto que usan millones de personas.",
            Requisitos = new()
            {
                "2 o más años de experiencia en desarrollo frontend",
                "Experiencia con Vue.js o con otro framework moderno",
                "Conocimientos de testing unitario",
                "Uso de Git y trabajo con Pull Requests",
                "Interés por productos financieros"
            },
            Beneficios = new() { "Home office", "Stock options", "Gimnasio", "Semana extra de vacaciones" },
            HabilidadesCumplidas = new() { "JavaScript", "Git", "APIs REST" },
            HabilidadFaltante = "Vue.js",
            Guardada = true
        },
        new Oferta
        {
            Id = 5, Puesto = "Web Developer", EmpresaId = 5, Empresa = "Naranja X", Iniciales = "NX",
            Ubicacion = "Córdoba", UbicacionCorta = "Córdoba · Presencial",
            Modalidad = "Presencial", ModalidadDetalle = "Presencial", Nivel = "Junior",
            Salario = "$1.000.000 – $1.300.000", Experiencia = "0 a 2 años",
            Match = 72, MatchResumen = "Cumplís 3 de 4 habilidades pedidas, pero la modalidad presencial en Córdoba no coincide con tus preferencias.",
            Publicado = "Hace 1 semana", Tecnologias = new() { "HTML", "JavaScript" },
            SobrePuesto = "Vas a mantener y mejorar los sitios institucionales y las landings de campañas de Naranja X, trabajando junto a marketing y diseño.",
            Requisitos = new()
            {
                "Conocimientos sólidos de HTML, CSS y JavaScript",
                "Nociones de diseño responsive y accesibilidad",
                "Experiencia con algún CMS (valorado)",
                "Disponibilidad para trabajar en la oficina de Córdoba"
            },
            Beneficios = new() { "Prepaga", "Día de cumpleaños libre", "Comedor en oficina" },
            HabilidadesCumplidas = new() { "HTML", "CSS / BEM", "JavaScript" },
            HabilidadFaltante = "CMS (WordPress)",
            Guardada = true
        },
        new Oferta
        {
            Id = 6, Puesto = "Frontend Developer", EmpresaId = 6, Empresa = "Despegar", Iniciales = "D",
            Ubicacion = "Saavedra, CABA", UbicacionCorta = "Saavedra · Híbrido",
            Modalidad = "Híbrido", ModalidadDetalle = "Híbrido · 2 días en oficina", Nivel = "Semi Senior",
            Salario = "$1.700.000 – $2.100.000", Experiencia = "2 a 4 años",
            Match = 70, MatchResumen = "Cumplís 3 de 5 habilidades pedidas. Te falta experiencia con Angular.",
            Publicado = "Hace 4 días", Tecnologias = new() { "Angular", "TypeScript" },
            SobrePuesto = "Vas a trabajar en el flujo de búsqueda y compra de vuelos, optimizando la performance y la experiencia en mobile web.",
            Requisitos = new()
            {
                "2 o más años de experiencia con Angular o React",
                "TypeScript y programación reactiva (RxJS valorado)",
                "Foco en performance web y Core Web Vitals",
                "Inglés intermedio"
            },
            Beneficios = new() { "Descuentos en viajes", "Híbrido", "Capacitaciones" },
            HabilidadesCumplidas = new() { "TypeScript", "Git", "APIs REST" },
            HabilidadFaltante = "Angular",
            Guardada = true
        },
        new Oferta
        {
            Id = 7, Puesto = "Frontend Developer Jr", EmpresaId = 1, Empresa = "Mercado Libre", Iniciales = "ML",
            Ubicacion = "Saavedra, CABA", UbicacionCorta = "Saavedra · Híbrido",
            Modalidad = "Híbrido", ModalidadDetalle = "Híbrido · 2 días en oficina", Nivel = "Junior",
            Salario = "$1.300.000 – $1.600.000", Experiencia = "0 a 2 años",
            Match = 83, MatchResumen = "Cumplís 4 de 5 habilidades pedidas y tu expectativa salarial está dentro del rango.",
            Publicado = "Hace 6 días", Tecnologias = new() { "React", "JavaScript" },
            SobrePuesto = "Vas a sumarte a un equipo de Shipping para construir las herramientas web que usan los vendedores para gestionar sus envíos.",
            Requisitos = new()
            {
                "Conocimientos de React y JavaScript moderno",
                "HTML semántico y CSS",
                "Ganas de aprender testing y buenas prácticas",
                "Uso de Git"
            },
            Beneficios = new() { "Prepaga", "Capacitaciones", "Híbrido flexible" },
            HabilidadesCumplidas = new() { "React", "JavaScript", "CSS / BEM", "Git" },
            HabilidadFaltante = "Testing (Jest)"
        },
        new Oferta
        {
            Id = 8, Puesto = "Desarrollador/a Angular", EmpresaId = 2, Empresa = "Globant", Iniciales = "G",
            Ubicacion = "Remoto (Argentina)", UbicacionCorta = "Remoto (AR)",
            Modalidad = "Remoto", ModalidadDetalle = "Remoto", Nivel = "Semi Senior",
            Salario = "$1.900.000 – $2.400.000", Experiencia = "3 a 5 años",
            Match = 68, MatchResumen = "Cumplís 2 de 4 habilidades pedidas. Te falta experiencia con Angular y RxJS.",
            Publicado = "Hace 1 semana", Tecnologias = new() { "Angular", "RxJS" },
            SobrePuesto = "Vas a participar en un proyecto para un cliente de la industria aérea, desarrollando el nuevo portal de clientes con Angular.",
            Requisitos = new()
            {
                "3 o más años con Angular",
                "RxJS y manejo de estado",
                "Inglés avanzado para trabajar con el cliente"
            },
            Beneficios = new() { "Remoto flexible", "Clases de inglés", "Plan de carrera" },
            HabilidadesCumplidas = new() { "TypeScript", "Git" },
            HabilidadFaltante = "Angular y RxJS"
        }
    };

    public static readonly List<Postulacion> Postulaciones = new()
    {
        // Enviadas
        new Postulacion { Id = 1, OfertaId = 2, Puesto = "Desarrollador/a Frontend Jr", Empresa = "Tiendanube", Iniciales = "TN", Ubicacion = "Remoto", Estado = EstadoPostulacion.Enviada, Etapa = "Enviada", Tono = "neutra", Actualizado = "Enviada el 26 sep" },
        new Postulacion { Id = 2, OfertaId = 6, Puesto = "Frontend Developer", Empresa = "Despegar", Iniciales = "D", Ubicacion = "Saavedra, CABA", Estado = EstadoPostulacion.Enviada, Etapa = "Enviada", Tono = "neutra", Actualizado = "Enviada el 24 sep" },
        new Postulacion { Id = 3, Puesto = "Desarrollador/a Web Jr", Empresa = "Santander Tecnología", Iniciales = "S", Ubicacion = "CABA", Estado = EstadoPostulacion.Enviada, Etapa = "Enviada", Tono = "neutra", Actualizado = "Enviada el 21 sep" },
        new Postulacion { Id = 4, OfertaId = 5, Puesto = "Web Developer", Empresa = "Naranja X", Iniciales = "NX", Ubicacion = "Córdoba", Estado = EstadoPostulacion.Enviada, Etapa = "Enviada", Tono = "neutra", Actualizado = "Enviada el 19 sep" },

        // En revisión
        new Postulacion { Id = 5, OfertaId = 4, Puesto = "Frontend Engineer (Vue)", Empresa = "Ualá", Iniciales = "U", Ubicacion = "Remoto", Estado = EstadoPostulacion.EnRevision, Etapa = "CV visto por RR.HH.", Tono = "info", Actualizado = "Actualizado hace 1 día" },
        new Postulacion { Id = 6, Puesto = "Desarrollador/a Frontend", Empresa = "Banco Galicia", Iniciales = "BG", Ubicacion = "CABA", Estado = EstadoPostulacion.EnRevision, Etapa = "En revisión técnica", Tono = "advertencia", Actualizado = "Actualizado hace 3 días" },
        new Postulacion { Id = 7, OfertaId = 3, Puesto = "UI Developer", Empresa = "Mercado Libre", Iniciales = "ML", Ubicacion = "Saavedra", Estado = EstadoPostulacion.EnRevision, Etapa = "Perfil preseleccionado", Tono = "exito", Actualizado = "Actualizado hace 4 días" },

        // Entrevistas
        new Postulacion { Id = 8, OfertaId = 1, Puesto = "Frontend Developer React", Empresa = "Globant", Iniciales = "G", Ubicacion = "Palermo, CABA", Estado = EstadoPostulacion.Entrevista, Etapa = "Entrevista técnica", Tono = "principal", Actualizado = "Actualizado hoy", DestacadoTitulo = "Próxima entrevista", DestacadoTexto = "Jue 1 oct · 15:00 hs · Google Meet" },
        new Postulacion { Id = 9, Puesto = "Frontend Developer Jr", Empresa = "PedidosYa", Iniciales = "PY", Ubicacion = "Remoto", Estado = EstadoPostulacion.Entrevista, Etapa = "Entrevista con RR.HH.", Tono = "principal", Actualizado = "Actualizado ayer", DestacadoTitulo = "Próxima entrevista", DestacadoTexto = "Lun 5 oct · 10:30 hs · Zoom" },

        // Finalizadas
        new Postulacion { Id = 10, Puesto = "Frontend Developer Jr", Empresa = "Etermax", Iniciales = "E", Ubicacion = "Palermo, CABA", Estado = EstadoPostulacion.Finalizada, Etapa = "Oferta recibida", Tono = "exito", Actualizado = "Actualizado hoy", DestacadoTitulo = "Oferta: $1.450.000 brutos", DestacadoTexto = "Respondé antes del vie 2 oct" },
        new Postulacion { Id = 11, Puesto = "Frontend Trainee", Empresa = "Rappi", Iniciales = "R", Ubicacion = "CABA", Estado = EstadoPostulacion.Finalizada, Etapa = "No seleccionado", Tono = "error", Actualizado = "Actualizado hace 2 semanas" },

        // Archivadas
        new Postulacion { Id = 12, Puesto = "Frontend Developer Trainee", Empresa = "Accenture", Iniciales = "A", Ubicacion = "CABA · Híbrido", Estado = EstadoPostulacion.Finalizada, Etapa = "Aceptada", Tono = "exito", Actualizado = "Cerrada el 1 mar 2025", Archivada = true },
        new Postulacion { Id = 13, Puesto = "Desarrollador/a Web", Empresa = "Belatrix", Iniciales = "B", Ubicacion = "Remoto", Estado = EstadoPostulacion.Finalizada, Etapa = "No seleccionado", Tono = "error", Actualizado = "Cerrada el 2 sep", Archivada = true },
        new Postulacion { Id = 14, Puesto = "Maquetador/a Web", Empresa = "Moove Agencia", Iniciales = "MA", Ubicacion = "CABA", Estado = EstadoPostulacion.Finalizada, Etapa = "Retiraste tu postulación", Tono = "neutra", Actualizado = "Cerrada el 28 ago", Archivada = true },
        new Postulacion { Id = 15, Puesto = "Desarrollador/a JavaScript Jr", Empresa = "Lemon Cash", Iniciales = "LC", Ubicacion = "Remoto", Estado = EstadoPostulacion.Finalizada, Etapa = "Búsqueda cerrada", Tono = "neutra", Actualizado = "Cerrada el 15 ago", Archivada = true }
    };

    public static readonly List<Notificacion> Notificaciones = new()
    {
        new Notificacion { Id = 1, Titulo = "Globant vio tu postulación a Frontend Developer React", Texto = "Te avisaremos cuando la empresa revise tu perfil.", Fecha = "Recién", Enlace = "/Postulaciones" },
        new Notificacion { Id = 2, Titulo = "Tiendanube te envió un mensaje", Texto = "Recibimos tu postulación a Desarrollador/a Frontend Jr. ¡Gracias por tu interés!", Fecha = "Hace 5 minutos", Enlace = "/Postulaciones" },
        new Notificacion { Id = 3, Titulo = "Hay 3 ofertas nuevas para vos", Texto = "Encontramos coincidencias con tu perfil de Frontend Developer.", Fecha = "Hace 2 horas", Enlace = "/Empleos" },
        new Notificacion { Id = 4, Titulo = "Actualizá tu perfil", Texto = "Completá tu perfil para recibir mejores coincidencias.", Fecha = "Hace 1 día", Leida = true, Enlace = "/Perfil" },
        new Notificacion { Id = 5, Titulo = "Mercado Libre te envió un mensaje", Texto = "Tu perfil fue preseleccionado para UI Developer.", Fecha = "6 de octubre", Leida = true, Enlace = "/Postulaciones" }
    };

    public static Oferta? ObtenerOferta(int id) => Ofertas.FirstOrDefault(o => o.Id == id);

    public static Empresa? ObtenerEmpresa(int id) => Empresas.FirstOrDefault(e => e.Id == id);

    public static List<Oferta> OfertasDeEmpresa(int empresaId) =>
        Ofertas.Where(o => o.EmpresaId == empresaId).OrderByDescending(o => o.Match).ToList();

    public static List<Oferta> Coincidencias(int cantidad = 3) =>
        Ofertas.OrderByDescending(o => o.Match).Take(cantidad).ToList();

    public static List<Oferta> Similares(Oferta oferta, int cantidad = 2) =>
        Ofertas.Where(o => o.Id != oferta.Id).OrderByDescending(o => o.Match).Take(cantidad).ToList();
}
