USE [Workly]
GO
SET IDENTITY_INSERT [dbo].[Pais] ON 

INSERT [dbo].[Pais] ([ID], [Nombre], [Codigo_ISO], [Codigo_Telefono]) VALUES (1, N'Argentina', N'ar', N'+54')
SET IDENTITY_INSERT [dbo].[Pais] OFF
GO
SET IDENTITY_INSERT [dbo].[Provincia] ON 

INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (1, 1, N'Buenos Aires')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (2, 1, N'Catamarca')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (3, 1, N'Chaco')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (4, 1, N'Chubut')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (5, 1, N'Ciudad Autónoma de Buenos Aires')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (6, 1, N'Córdoba')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (7, 1, N'Corrientes')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (8, 1, N'Entre Ríos')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (9, 1, N'Formosa')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (10, 1, N'Jujuy')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (11, 1, N'La Pampa')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (12, 1, N'La Rioja')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (13, 1, N'Mendoza')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (14, 1, N'Misiones')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (15, 1, N'Neuquén')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (16, 1, N'Río Negro')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (17, 1, N'Salta')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (18, 1, N'San Juan')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (19, 1, N'San Luis')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (20, 1, N'Santa Cruz')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (21, 1, N'Santa Fe')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (22, 1, N'Santiago del Estero')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (23, 1, N'Tierra del Fuego')
INSERT [dbo].[Provincia] ([ID], [IDPais], [Nombre]) VALUES (24, 1, N'Tucumán')
SET IDENTITY_INSERT [dbo].[Provincia] OFF
GO
SET IDENTITY_INSERT [dbo].[Sector] ON 

INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (1, N'Habilidades generales', 1)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (2, N'Tecnología y sistemas', 2)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (3, N'Datos y análisis', 3)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (4, N'Administración y finanzas', 4)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (5, N'Ventas y atención al cliente', 5)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (6, N'Marketing y comunicación', 6)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (7, N'Diseño', 7)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (8, N'Logística y operaciones', 8)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (9, N'Gastronomía y hotelería', 9)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (10, N'Salud', 10)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (11, N'Educación', 11)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (12, N'Construcción y oficios', 12)
INSERT [dbo].[Sector] ([ID], [Nombre], [Orden]) VALUES (13, N'Recursos humanos', 13)
SET IDENTITY_INSERT [dbo].[Sector] OFF
GO
SET IDENTITY_INSERT [dbo].[Habilidad] ON 

INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (1, N'Comunicación', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (2, N'Trabajo en equipo', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (3, N'Liderazgo', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (4, N'Organización', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (5, N'Resolución de problemas', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (6, N'Gestión de proyectos', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (7, N'Gestión del tiempo', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (8, N'Adaptabilidad', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (9, N'Pensamiento crítico', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (10, N'Atención al detalle', 1)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (11, N'Programación', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (12, N'HTML', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (13, N'CSS', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (14, N'JavaScript', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (15, N'TypeScript', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (16, N'React', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (17, N'C#', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (18, N'.NET', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (19, N'Java', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (20, N'Python', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (21, N'SQL', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (22, N'Git', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (23, N'Soporte técnico', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (24, N'Redes informáticas', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (25, N'Ciberseguridad', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (26, N'Testing de software', 2)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (27, N'Análisis de datos', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (28, N'Power BI', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (29, N'Tableau', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (30, N'Estadística', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (31, N'Machine learning', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (32, N'Excel avanzado', 3)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (33, N'Administración', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (34, N'Contabilidad', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (35, N'Excel', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (36, N'Microsoft Office', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (37, N'Google Workspace', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (38, N'Facturación', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (39, N'Liquidación de sueldos', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (40, N'Tesorería', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (41, N'Impuestos', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (42, N'Cuentas a pagar y cobrar', 4)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (43, N'Ventas', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (44, N'Atención al cliente', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (45, N'Negociación', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (46, N'Venta telefónica', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (47, N'Caja', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (48, N'Postventa', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (49, N'Manejo de CRM', 5)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (50, N'Marketing digital', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (51, N'Redes sociales', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (52, N'Redacción', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (53, N'SEO', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (54, N'Publicidad', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (55, N'Comunicación institucional', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (56, N'Fotografía', 6)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (57, N'Diseño gráfico', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (58, N'Figma', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (59, N'Photoshop', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (60, N'Illustrator', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (61, N'Diseño UX/UI', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (62, N'Edición de video', 7)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (63, N'Logística', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (64, N'Manejo de stock', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (65, N'Depósito', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (66, N'Compras', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (67, N'Comercio exterior', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (68, N'Manejo de autoelevador', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (69, N'Distribución', 8)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (70, N'Cocina', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (71, N'Atención en salón', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (72, N'Barista', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (73, N'Pastelería', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (74, N'Manipulación de alimentos', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (75, N'Recepción hotelera', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (76, N'Housekeeping', 9)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (77, N'Enfermería', 10)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (78, N'Primeros auxilios', 10)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (79, N'Cuidado de adultos mayores', 10)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (80, N'Atención en farmacia', 10)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (81, N'Administración de turnos médicos', 10)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (82, N'Docencia', 11)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (83, N'Clases particulares', 11)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (84, N'Planificación educativa', 11)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (85, N'Acompañamiento terapéutico', 11)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (86, N'Cuidado de niños', 11)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (87, N'Electricidad', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (88, N'Plomería', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (89, N'Albañilería', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (90, N'Carpintería', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (91, N'Pintura', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (92, N'Soldadura', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (93, N'Mecánica', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (94, N'Lectura de planos', 12)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (95, N'Recursos humanos', 13)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (96, N'Selección de personal', 13)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (97, N'Capacitación', 13)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (98, N'Relaciones laborales', 13)
INSERT [dbo].[Habilidad] ([ID], [Nombre], [IDSector]) VALUES (99, N'Administración de personal', 13)
GO
SET IDENTITY_INSERT [dbo].[Habilidad] OFF
GO
SET IDENTITY_INSERT [dbo].[Idioma] ON 

INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (6, N'Alemán')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (7, N'Chino mandarín')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (1, N'Español')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (4, N'Francés')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (2, N'Inglés')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (5, N'Italiano')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (8, N'Japonés')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (9, N'Lengua de señas argentina')
INSERT [dbo].[Idioma] ([ID], [Nombre]) VALUES (3, N'Portugués')
SET IDENTITY_INSERT [dbo].[Idioma] OFF
GO
SET IDENTITY_INSERT [dbo].[Usuario] ON 

INSERT [dbo].[Usuario] ([ID], [Nombre], [Apellido], [Email], [Contraseña], [Fecha_Registro], [Tipo], [Es_Moderador]) VALUES (1, N'Teo', N'Moreno', N'50291929@est.ort.edu.ar', N'PBKDF2$600000$5PeX0WMGc2StUFT8LB6ytQ==$bp2ZHrIULGDmEzGP+cwo8mLhDEHzqmbNUIJe8GM19lE=', CAST(N'2026-11-02' AS Date), N'Persona', 1)
SET IDENTITY_INSERT [dbo].[Usuario] OFF
GO
SET IDENTITY_INSERT [dbo].[Perfil] ON 

INSERT [dbo].[Perfil] ([ID], [IDUsuario], [IDProvincia], [Foto], [Descripcion], [Telefono], [Estado_Busqueda]) VALUES (1, 1, NULL, NULL, NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[Perfil] OFF
GO
SET IDENTITY_INSERT [dbo].[OfertaExterna] ON 

INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (1, N'ejhkcDhESVBDLWY3a0pldkFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXa2x1VEZsNU5sOTRUR3RwVW1oU2NXUnBlRVJWVG1kdE5XTnliWGRIUlc1SExVVTFZVmt6VUVwNk9GcGlhak5LYUZCWVRVOHhSSFJ6Yms1bFEyVmFRa1pmWW1sME5FTnlTVEl0U25kU1VXbzNk', N'Administrativo/a de Logística', N'TRANSENER', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSXllHSy346PnyDKXDVKYOOGcWuq5BK1-_vQLOj&s=0', N'Marcos Paz, Provincia de Buenos Aires', N'¡Incorpórate a nuestro equipo como Analista Administrativo/a de Logística en Transener / Transba!

Como Analista Administrativo/a de Logística serás un pilar fundamental para garantizar la eficiencia y el control estricto de nuestro almacén de indumentaria y Elementos de Protección Personal (EPP). Tu rol será clave para asegurar el abastecimiento eficiente a todo el personal de la compañía.

Principales responsabilidades
• Gestión de inventario y operaciones: Coordinar el orden físico y lógico del almacén, realizando recuentos periódicos, conciliaciones contra el sistema y análisis preventivo de abastecimiento (consumos, stock mínimo y proyecciones).
• Cumplimiento y digitalización: Administrar el sistema integral de indumentaria y EPP, garantizando la correcta emisión y firma de los formularios de entrega según la Resolución SRT 299/2011, además de generar reportes de cumplimiento.
• Logística de distribución: Liderar la provisión interna a las distintas gerencias regionales, desde la preparación de los pedidos y el seguimiento del envío, hasta la recepción conforme.
• Administración y control contable: Realizar la imputación contable directa (Centro de Costos / Orden de Mantenimiento) de los materiales gestionados.

Requisitos Excluyentes

● Experiencia: Más de 5 años de trayectoria sólida comprobable en logística,

administración de inventarios o gestión de almacenes.

● Formación: Estudiantes avanzados, graduados universitarios o Técnicos en Logística, Administración de Empresas o carreras afines.

● Herramientas Técnicas: Dominio avanzado de sistemas de gestión de stock (SAP MM excluyente) y del entorno Google Workspace.

● Movilidad: Licencia de conducir clase B vigente y disponibilidad para viajar y

trasladarse.

¿Qué beneficios te esperan?

🤸🏻 Descuento en Sport Club

🏝 Vacaciones Adicionales (+ días hábiles)

👌 Día de cumpleaños libre

🎁 Regalo de cumpleaños

🥇 Bono por posición

🍼 Licencias de Paternidad y Maternidad extendida. Regreso “soft landing” de maternidad

💰 Ayuda para Guardería

❤️️ Medicina prepaga para vos y tu familia

👨 🎓 Plan de carrera

💪 Excelente clima laboral

¡Y mucho más!

⚡Sumate a la empresa líder en el servicio público de transporte de energía eléctrica y construí tu carrera profesional generando valor en cada paso.

⚡La diversidad de talento potencia nuestra cultura y nuestra organización, por eso promovemos la creación de equipos diversos e inclusivos que puedan aportar diferentes perspectivas. Nuestras oportunidades laborales están abiertas a todas las personas, independientemente de su identidad de género, orientación sexual, origen étnico, religión, edad, discapacidad y otras características individuales.

En caso de necesitar alguna modificación o accesibilidad particular para tener la entrevista, por favor no dejes de aclararlo en tu postulación.

TRANSENER | TRANSBA

🔷Unimos Argentina con Energía🔷', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/administrativo-a-de-log%C3%ADstica-at-transener-4484361618', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.0932226' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (2, N'eFNxT3lDTkhhWjR0VHFnaEFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZa3d3WjJFd2VXTnplR1V5YW5od1ZtRlpjVU5uYzFSR05FeE9SVGhoVDNScU9YZFlPVGhhY0U0eFRFNTJXRVV4ZUc5WE1WQmFPR2g2VWxGeFVuaFpiVVpJUVV0c1ZVRjZPRXBqVjFsdWQxODNR', N'Recepcionista Eventual por 4 días URGENTE', N'ADECCO RECURSOS HUMANOS ARGENTINA SA', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQh8_Rq6W3dV5r8ujCZVWMA9egqYSIsod-X5dgx&s=0', N'Cdad. Autónoma de Buenos Aires', N'BUSCAMOS TALENTOS,

¡EN ADECCO TE ESTAMOS BUSCANDO!

Si te interesa ser RECEPCION ADMINISTRATIVO por 4 días completos (4, 5, 6, 12 y 13 de Noviembre) y ser parte de Adecco prestando servicios en nuestro cliente IMPORTANTE EMPRESA MULTINACIONAL, ¡desafíate a vos mismo y crea tu futuro!

¿QUÉ DESAFÍOS TE ESPERAN?
• Atención y derivación de llamadas telefónicas.
• Recepción y atención de visitas, proveedores y clientes.
• Coordinación de la agenda del cadete y seguimiento de tareas.
• Soporte administrativo general a distintas áreas.
• Actualización y mantenimiento del organigrama de la compañía.
• Gestión y actualización del manual de ingresos y documentación interna.
• Coordinación de pedidos de frutas, almuerzos, agua, gaseosas e insumos para reuniones.
• Gestión de necesidades operativas de la oficina.
• Seguimiento de proveedores y asistencia en tareas administrativas varias.

¿QUÉ VALORAMOS DE TU PERFIL?
• Experiencia previa en posiciones de recepción, administración o asistencia.
• Perfil multitasking, proactivo y orientado al servicio.
• Excelente organización y habilidades interpersonales.

¿QUE TE OFRECEMOS?
• Ubicación: Microcentro, CABA
• Jornada: Lunes a viernes de 8:30 a 17:30 hs (1 hora de almuerzo)
• Modalidad: 100% presencial
• Almuerzo cubierto
• Reintegro de transporte mediante tarjeta SUBE
• Contratación: Necesidad de cubrir una licencia los días 4, 5, 6, 12 y 13 de Noviembre

¡REGÍSTRATE EN ADECCO EMPLEO Y DA EL PASO QUE NECESITAS!

Somos Adecco Argentina una compañía con más de 30 años de experiencia que conecta empresas con talentos, brindando soluciones integrales de Recursos Humanos y buscamos talentos, ¡COMO VOS!

Nuestro compromiso, es la #diversidad e #igualdad de oportunidades somos una empresa inclusiva. Cuando sos parte de nuestros procesos, solo cuentan tus méritos, logros y capacidades, lo hacemos pensando en vos como persona.

Participar de nuestros procesos de selección no tiene ningún costo para vos candidato/a, trabajar con vos es parte de nuestro compromiso y tarea con la comunidad. Postulate y participa en una oferta de empleo nuestra.

El empleador sólo podrá solicitarle la información estrictamente necesaria para el desempeño en el trabajo que se ofrece.

Ciudad de Buenos Aires: ley de búsqueda laboral equitativa - Ley 6471', 0, NULL, NULL, N'https://www.bumeran.com.ar/empleos/recepcionista-eventual-por-4-dias-urgente-adecco-recursos-humanos-argentina-sa-1118503440.html', N'Bumeran', NULL, CAST(N'2026-11-02T18:54:49.0957020' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (3, N'NjNwQi1JRmV2SmRtSjY0NUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZbUZRV0ZwSWJ6WlBaV1JJZEdoM01FSmlabXhUWHpCRU0wWnNVMVZCU21ObkxVcG9ZbTlhTm5KbWMwMUpSSEZzZEdkR00zWnZSRWRUU2pKcFJ6Wm9lR0pCZWpWbVpURnNNRWQyTWxSTFlXMW5V', N'Analista de cuentas a pagar', N'Importante Empresa de Servicios', NULL, N'Vicente López, Provincia de Buenos Aires', N'Importante empresa de servicios líderes en su rubro se encuentra en la búsqueda de un/a Analista de cuentas a pagar.

Tareas y Responsabilidades:

• Análisis y conciliación de cuentas corrientes.
• Registrar los comprobantes, y participar en el control de plazos de vencimientos y pagos.
• Mantener contacto y relación con proveedores.
• Realizar tareas administrativas y archivos del sector.

Requisitos:

• Estudiante o graduado de Cs. Económicas o afines.
• Contar con al menos 2 años de experiencia en posiciones similares (Excluyente).
• Tener nivel de Excel avanzado (Excluyente).

Beneficios:

• Importantes beneficios.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/analista-de-cuentas-a-pagar-at-importante-empresa-de-servicios-4485427678', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.0961974' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (4, N'b3NIeWk2TzdncWdiR0pzX0FBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZV3hOU0dsTWJqWnRiWGRZWjA5Vk1qSkpkekp4TkV3eFVFdFNUVFUxY25WQ2R5MHhkRXRFZVVGelZUQkRTbGxLYlZrMFZWVnBUekJ3UW14a2FVVlBYMHRYT1hWbVNYWXdVbW8yUTIxS2JYUTJk', N'Ejecutivo Comercial Senior (Mendoza)', N'Aprile - International Freight Forwarding', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQFAsS7XQwE4nx2GDHGZFcHHt9CkSOH3wh4YJ7i&s=0', N'Mendoza, Capital, Mendoza', N'Ejecutivo Comercial Senior (Mendoza)

Ubicación: Mendoza, Argentina (Presencial)

Tipo: Tiempo completo

Sector: Freight Forwarding y Logística Internacional

Sitio web: https://www.linkedin.com/redir/suspicious-page?url=www%2eaprilenet%2ecom

Aprile está buscando un Ejecutivo Comercial Senior para incorporarse a nuestro equipo en Mendoza.

Buscamos un profesional con sólida experiencia comercial en el sector del freight forwarding, orientado al desarrollo de nuevos negocios y al fortalecimiento de relaciones comerciales a largo plazo.

NOTA: Por favor, no vuelvas a postularte si ya has enviado una candidatura para esta posición. Tu candidatura ya está siendo evaluada. Las postulaciones múltiples pueden dar lugar a la exclusión del proceso de selección.

Responsabilidades
• Comercializar servicios de transporte internacional marítimo, aéreo y soluciones logísticas asociadas.
• Desarrollar nuevas oportunidades de negocio.
• Gestionar y fidelizar la cartera de clientes.
• Elaborar y presentar propuestas comerciales.
• Planificar actividades comerciales y apoyar el análisis de mercado.
• Brindar asistencia al cliente antes y después de la venta.
• Elaborar reportes comerciales.
• Utilizar el CRM corporativo.

Perfil requerido
• Mínimo 3 años de experiencia como Ejecutivo Comercial externo en empresas de freight forwarding o transporte internacional.
• Excelente nivel de inglés.
• Fuertes habilidades comerciales y de negociación.
• Proactividad y orientación a resultados.
• Buen manejo de Microsoft Office.
• Licencia de conducir vigente.
• Residir en Mendoza, o zonas cercanas.

Qué ofrecemos
• Salario competitivo acorde con la experiencia.
• Crecimiento y desarrollo profesional.
• Entorno de trabajo internacional y dinámico.
• Equipo colaborativo.

Aprile promueve la igualdad de oportunidades.

-----

Senior Sales Executive (Mendoza)

Location: Mendoza, Argentina (On-site)

Type: Full-time

Industry: Freight Forwarding and International Logistics

Website: https://www.linkedin.com/redir/suspicious-page?url=www%2eaprilenet%2ecom

Aprile is looking for a Senior Sales Executive to join our team in Mendoza.

We are looking for an experienced sales professional with a strong background in freight forwarding, focused on developing new business opportunities and building long-term customer relationships.

NOTE: Please do not apply again if you have already submitted an application for this position. Your application is already under review. Multiple applications may result in exclusion from the selection process.

Key responsibilities
• Sell international ocean, air and related logistics services.
• Develop new business opportunities.
• Manage and grow the existing customer portfolio.
• Prepare and present commercial proposals.
• Plan commercial activities and support market analysis.
• Provide pre-sales and post-sales customer support.
• Prepare commercial reports.
• Maintain and update the company CRM.

Candidate profile
• Minimum 3 years of experience as an external Sales Executive within freight forwarding or international transport companies.
• Fluent in English.
• Strong sales and negotiation skills.
• Proactive and results-driven mindset.
• Proficiency in Microsoft Office.
• Valid driver’s license.
• Must be local to Mendoza, or surrounding areas.

What we offer
• Competitive salary aligned with experience.
• Professional growth and development.
• International and dynamic working environment.
• Collaborative team.
• Aprile promotes equal opportunities.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/ejecutivo-comercial-senior-mendoza-at-aprile-international-freight-forwarding-4486422288', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.0961974' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (5, N'SlNUMG55VFFOU2EtNFdTaUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZVEpxVUdGMVgzVm1ZWEJxZFVSMldXWkVkMWhHYlc5bFozVkhTMGxZTjNWTlFsVkVTamh6TVZnNVh6TkxiSFpuT0ZWRFEzcERURkozVFRWcGRHNUdSV3QyVkRSbFpERTNaMlpCVlZkRlYwUnpl', N'Gerente de desarrollo de productos electrónicos (Oil and Gas)', N'DG Consultores en Recursos Humanos', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxFXIYFknMiu5jj9hE-wOchxI0dJsxUmfnBwxe&s=0', N'Vicente López, Provincia de Buenos Aires', N'Importante grupo económico, vinculado a la industria del Oil & Gas y otras áreas, especializado en el desarrollo de soluciones tecnológicas innovadoras, se encuentra en la búsqueda de un/a Gerente de desarrollo de productos electrónicos, para incorporarse a su equipo de trabajo.

La posición tendrá como objetivo liderar el desarrollo tecnológico de productos electrónicos, definiendo soluciones de hardware y firmware, coordinando equipos de ingeniería y participando activamente en el diseño de nuevas plataformas y productos.

Buscamos un perfil con sólida trayectoria técnica, visión estratégica, capacidad de liderazgo y orientación a la innovación, que pueda transformar las necesidades de los clientes en soluciones tecnológicas concretas, robustas y escalables.

Principales responsabilidades
• Liderar el área de Ingeniería Electrónica, coordinando y desarrollando al equipo técnico a cargo.
• Definir la arquitectura y las especificaciones de hardware y firmware para nuevos productos y desarrollos tecnológicos.
• Liderar el desarrollo de soluciones electrónicas, software embebido y sistemas de automatización y control industrial.
• Participar en las definiciones estratégicas de producto, evaluando tecnologías y proponiendo soluciones innovadoras que aporten valor al cliente.
• Supervisar los procesos de diseño, prototipado, validación, ensayos y certificación de productos electrónicos.
• Garantizar el cumplimiento de las normas técnicas y estándares de calidad, seguridad y confiabilidad aplicables.
• Gestionar proyectos, presupuestos y proveedores tecnológicos, asegurando el cumplimiento de objetivos, costos y plazos.
• Actuar como referente técnico ante clientes, proveedores y equipos interdisciplinarios.

Requisitos

La persona que ocupe la posición deberá contar con experiencia y/o conocimientos en los siguientes aspectos:
• Formación universitaria en Ingeniería Electrónica o carreras afines.
• Experiencia sólida en desarrollo de productos electrónicos (experiencia mayor a 10 años).
• Experiencia mínima de 3 años liderando equipos de ingeniería y/o proyectos de desarrollo tecnológico.
• Conocimientos avanzados en diseño y arquitectura de hardware electrónico, incluyendo electrónica analógica, digital, potencia y adquisición de señales.
• Experiencia en desarrollo de firmware y software embebido, microcontroladores y programación en lenguaje C.
• Conocimientos en plataformas de automatización industrial, PLC, instrumentación y sistemas de control.
• Experiencia en diseño de PCB y manejo de herramientas como Altium, OrCAD o similares.
• Conocimientos de protocolos de comunicación industrial: Modbus, RS-485, CAN, HART y otros.
• Conocimientos en sistemas IoT, telemetría y tecnologías de comunicación industrial.
• Experiencia en desarrollo de productos desde su concepción hasta la validación, certificación y puesta en producción.
• Conocimientos de normas IEC 61508, IEC 61511, IEC 60079, IEC 62443, IEC 61000 y/o certificaciones ATEX/IECEx.
• Experiencia en gestión de proyectos, coordinación de proveedores y liderazgo de equipos técnicos.
• Dominio avanzado de inglés técnico.

Se valorará:
• Experiencia en industrias tecnológicas, automatización industrial, energía, Oil & Gas, aeroespacial y/o sectores con altos estándares de calidad y certificación.
• Experiencia en desarrollo de productos con hardware de terceros y plataformas PLC.
• Certificación en seguridad funcional.

Competencias requeridas
• Liderazgo técnico y capacidad de desarrollo de equipos.
• Visión estratégica y orientación al desarrollo de producto.
• Innovación, proactividad y pensamiento analítico.
• Capacidad para evaluar tecnologías y tomar decisiones técnicas.
• Orientación al cliente y resolución de problemas complejos.
• Planificación, organización y gestión de proyectos.

Se ofrece
• Incorporación a una empresa tecnológica con proyectos de desarrollo e innovación.
• Participación activa en decisiones estratégicas de producto.
• Posibilidad de liderar desarrollos tecnológicos de alcance internacional.
• Desarrollo profesional en un entorno de crecimiento y expansión.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/gerente-de-desarrollo-de-productos-electr%C3%B3nicos-oil-and-gas-at-dg-consultores-en-recursos-humanos-4485426369', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.0996740' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (6, N'R1E1SllPNENMb3VKY1BzTkFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXWEJ1UTFaUGEzRmZjMGhhU1MxclZVZ3lWSFF5T1U5Rk5YSTNhMHRJZVZsdU5GaDRURXByUWkwM2FXTndTMUJRTmpnM1ZYaERVbU15UW1KZlMwSnFNRGxQWlRKT2EzZGxkVFJWZFdwd1R6bDFX', N'Personal Gastronómico - (Eventual)', N'ManpowerGroup', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRiyJmq5O0fdRv1Fr-yBokGHiL-IgAunmtGXJI1&s=0', N'Argentina', N'Nos encontramos en la búsqueda de Ayudantes de Cocina, Peones de Cocina, Camareros y Bacheros Eventuales para incorporarse a importantes servicios gastronómicos y eventos corporativos, sociales y masivos.
¿Cuáles serán tus tareas?
Asistencia en la elaboración y preparación de alimentos.
Colaboración en la producción y despacho de comidas.
Lavado de vajilla, utensilios y elementos de cocina.
Orden y limpieza del sector de trabajo.
Cumplimiento de normas de higiene y seguridad alimentaria.
Requisitos
Experiencia previa en gastronomía, comedores, hoteles, catering o eventos.
Disponibilidad horaria, especialmente fines de semana y feriados.
Dinamismo, compromiso y predisposición para el trabajo en equipo.
Libreta sanitaria vigente o Carnet manipulacion alimentos (deseable).
Ofrecemos
Incorporación inmediata.
Trabajo eventual por convocatoria.
Pago acorde al convenio.
Posibilidad de continuidad en futuros eventos.
Zona de trabajo: CABA y GBA
Al postularte o avanzar en este proceso, aceptás el tratamiento de tus datos personales conforme a nuestra Política de Privacidad, en cumplimiento de la Ley 25.326. ManpowerGroup Argentina tratará tu información exclusivamente con fines de evaluación y contacto en relación con oportunidades laborales. Podés ejercer tus derechos de acceso, rectificación o supresión cuando lo desees.
En ManpowerGroup promovemos una cultura inclusiva y diversa basada en el respeto y en la igualdad de oportunidades.-Requerimientos- Educación mínima: Secundaria
años de experiencia
Palabras clave: staff, empleado, trabajador, worker, employee, personal', 0, N'Tiempo completo', NULL, N'https://ar.computrabajo.com/ofertas-de-trabajo/oferta-de-trabajo-de-personal-gastronomico-eventual-en-gral-pacheco-6E834741E18252C461373E686DCF3405', N'Computrabajo', NULL, CAST(N'2026-11-02T18:54:49.0996740' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (7, N'VnNNMHRyemVtemU1aFBla0FBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXamR0VDJnM1FrYzRNbVZ0YTJGVmFGRnJja3BtU25kTFYxQkthVE40UjBwTFFWVkljSFZvVUhWSWVrRXdaRE41TTNabmNVMDVaSEY0Y2pZM1RHVXRkVmg0WlhWQlNXMXRRVWh2YmpsT1RWVXhU', N'Analista de créditos y cobranzas (villa ballester)', N'ADECCO RECURSOS HUMANOS ARGENTINA SA', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQh8_Rq6W3dV5r8ujCZVWMA9egqYSIsod-X5dgx&s=0', N'Villa Ballester, Provincia de Buenos Aires', N'BUSCAMOS TALENTOS, ¡EN ADECCO TE ESTAMOS BUSCANDO!

Si te interesa ser Analista de Créditos y Cobranzas y ser parte de Adecco prestando servicios en nuestro cliente importante multinacional de codificadoras industriales, ¡desafíate a vos mismo y crea tu futuro!

¿QUÉ DESAFÍOS TE ESPERAN?
• Evaluar la solvencia de clientes nuevos y existentes.
• Definir y revisar límites de crédito.
• Analizar estados financieros y reportes crediticios.
• Asegurar el cumplimiento de las políticas internas de crédito.
• Monitorear el aging de cuentas por cobrar.
• Implementar estrategias de cobranza preventiva y correctiva.
• Gestionar el seguimiento de pagos y negociar planes de pago cuando sea necesario.
• Escalar cuentas vencidas críticas.
• Coordinar acciones con las áreas de Ventas, Finanzas, Contabilidad y Customer Service.
• Brindar soporte en la resolución de disputas de facturación.
• Asegurar el cumplimiento de las regulaciones financieras y políticas internas vinculadas a cobranzas y crédito.

¿QUÉ VALORAMOS DE TU PERFIL?
• Formación universitaria o terciaria en Finanzas, Contabilidad, Economía o carreras afines.
• Experiencia mínima de 2 a 3 años en posiciones de Créditos, Cobranzas o Cuentas por Cobrar.
• Experiencia en entornos regionales o multinacionales (deseable).
• Conocimientos avanzados en gestión de cuentas por cobrar y sistemas ERP, como SAP u Oracle.
• Manejo avanzado de Excel.
• Capacidad de análisis, negociación y orientación a resultados.
• Excelentes habilidades de comunicación para interactuar con clientes internos y externos.
• Inglés intermedio/avanzado será valorado.

¿QUÉ TE OFRECEMOS?
• Lugar de trabajo: Villa Ballester, Provincia de Buenos Aires.
• Jornada laboral: full time
• Modalidad: Híbrida
• Beneficios: Comedor en planta.
• Modalidad de contratación: eventual a través de adecco

Somos Adecco Argentina, una compañía con más de 30 años de experiencia que conecta empresas con talentos, brindando soluciones integrales de Recursos Humanos y buscamos talentos, ¡COMO VOS!

Nuestro compromiso es la diversidad e igualdad de oportunidades. Somos una empresa inclusiva. Cuando participas de nuestros procesos, solo cuentan tus méritos, logros y capacidades.

Participar de nuestros procesos de selección no tiene ningún costo para vos. El empleador solo podrá solicitar la información estrictamente necesaria para el desempeño en el trabajo que se ofrece.

Ciudad de Buenos Aires: Ley de Búsqueda Laboral Equitativa N.º 6471.', 0, NULL, NULL, N'https://www.bumeran.com.ar/empleos/analista-de-creditos-y-cobranzas-villa-ballester-adecco-recursos-humanos-argentina-sa-1118504144.html', N'Bumeran', NULL, CAST(N'2026-11-02T18:54:49.1001667' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (8, N'bHJidTVlbzM4V0ZMVExUZUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZbEF3U25GemJHeFJiMUowUlRGQldHTXdhMUpIUW5nemNrbEJTVWxGZEd4VGIwOTJURlZ1VDNKZlJucEJkR00wYkVKaE1tWjRORUZFYlRoVk0zSnFWVTEwTkU1RE9GaHdVWGxZY25SYVQwUnJT', N'Especialista de Negocio Regional - Fintech', N'Mercado Libre', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwDeXMJxI8Yx6rEIMJMwhqmxMe6Qu40Zefb9il&s=0', N'Argentina', N'En Mercado Libre estamos democratizando el comercio y los servicios financieros para transformar la vida de las personas de América Latina. ¡Sumate a este propósito!

Nuestro negocio Fintech ofrece, a escala regional, una propuesta de valor integral que busca democratizar los servicios financieros y satisfacer las necesidades de las más de 60 millones de personas que utilizan nuestras soluciones. Brindamos una plataforma online que permite cobrar ventas electrónicas realizadas tanto dentro como fuera de Mercado Libre, y un sistema de códigos QR y dispositivos Point para cobrar ventas realizadas en el mundo físico. Así, damos la posibilidad a millones de comerciantes, emprendimientos y profesionales de procesar de manera segura sus operaciones, a través de más de 50 medios de pago en América Latina. También, otorgamos acceso gratuito a una cuenta digital, que permite pagar, enviar y recibir dinero, generar rendimientos y operar con tarjetas para hacer compras o extracciones. A través de Mercado Crédito, ofrecemos créditos para satisfacer las necesidades de las personas que utilizan nuestros servicios y para ayudar a potenciar el negocio a quienes venden a través de nuestra plataforma.

Tenemos un desafío para quienes:
• Vibran energía emprendedora: se mueven por la curiosidad, nunca se rinden y se enfocan en superar sus propios límites.
• Dan el máximo porque les gusta trabajar con compromiso y dedicación.
• Viven los cambios como oportunidades y aprenden de sus errores.
• La excelencia y la ejecución son claves en su forma de hacer las cosas.
• Promueven el buen clima, aportan alegría y diversión.
• Saben cómo construir con otras personas y disfrutan trabajando en equipo.

Imaginate emprendiendo proyectos desafiantes, dinámicos e innovadores y siendo responsable de:
• Definir y evolucionar la propuesta de valor regional de nuestras soluciones para grandes clientes, priorizando qué desarrollar y liderando el lanzamiento de nuevas capacidades.
• Rediseñar y optimizar de punta a punta los procesos y flujos del ciclo de vida de nuestros clientes, reduciendo tiempos y fricción.
• Desarrollar la estrategia de crecimiento y posicionamiento para sellers globales trabajando en conjunto con marketing
• Liderar la coordinación cross áreas para la ejecución de los proyectos priorizados, articulando con los equipos locales de cada país y regionales como Producto, Tecnología, Legales y Tax, y asegurando alineamiento en objetivos, tiempos y entregables.
• Ser referente del negocio para los equipos de producto, garantizando el cumplimiento del roadmap, y diseñar y monitorear los KPIs del negocio.

Requisitos:
• Ser profesional en Ingeniería Industrial, Ciencias Económicas, Administración de Empresas o afines
• Poseer 5 años de experiencia en desarrollo de negocio, consultoría estratégica, producto, estrategia o proyectos de innovación con enfoque transversal.
• Tener experiencia en herramientas analíticas y/o lenguajes de programación como SQL, Tableau o Excel, es deseble.

Te proponemos:
• Ser parte de una compañía con espíritu emprendedor en la que nos encanta pensar en grande y a largo plazo.
• Ser protagonista de tu desarrollo en un ambiente de oportunidades, aprendizaje, crecimiento, expansión y proyectos desafiantes.
• Compartir y aprender en equipo junto a grandes profesionales y especialistas.
• Un excelente clima de trabajo, con todo lo necesario para que vivas una gran experiencia. :)', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/especialista-de-negocio-regional-fintech-at-mercado-libre-4483487916', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.1001667' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (9, N'MUlkdGxDNkxFM2VGMnE0OUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZWGhLZWxwd1dIcHpTRjlDYkRWNldtRmtjamR4UzJkT1JISkdXa0YwY1dOWWNVd3phR2hNU0ZjNVJuRnNiRmRoTm5OWVIyZHlaMjVLYkU5dVNISjZWMlZuUm1aalgzaHhhWGRSUVd0MFlXWkpM', N'Comercial ganadería (balanceado) / Córdoba interior', N'Adecco', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRKw7I3cUDxV8G7zkgfWA6kVY5ONY2PQGtCCEQo&s=0', N'Argentina', N'Si te interesa ser Vendedor/a de Alimentos Balanceados para ganado | Córdoba Interior, para trabajar en importante empresa. ¡desafíate a vos mismo y crea tu futuro!

¿QUÉ DESAFÍOS TE ESPERAN?
• Atención y desarrollo de cartera de clientes activa.
• Generación de nuevos negocios en el sector agropecuario.
• Seguimiento comercial y asesoramiento a productores.
• Gestión de oportunidades en distintas zonas del interior provincial.

¿QUÉ VALORAMOS DE TU PERFIL?
• Experiencia en nutrición animal, alimentación animal o comercialización de balanceados.
• Conocimiento del sector ganadero, lechero o avícola.
• Perfil comercial con orientación al cliente y resultados.
• Movilidad propia (excluyente)

¿QUE TE OFRECEMOS?
• Lugar de trabajo :Córdoba interior. Necesitamos que esta persona viaje por el interior de Córdoba
• Horario laboral: L a V 8hs a 17hs
• Por Monotributo.
• Primeros 3 meses salario asegurado, luego por esquema de comisiones.

Nuestro compromiso, es la #diversidad e #igualdad de oportunidades somos una empresa inclusiva. Cuando sos parte de nuestros procesos, solo cuentan tus méritos, logros y capacidades, lo hacemos pensando en vos como persona.

Participar de nuestros procesos de selección no tiene ningún costo para vos candidato/a, trabajar con vos es parte de nuestro compromiso y tarea con la comunidad. Postulate y participa en una oferta de empleo nuestra.El empleador sólo podrá solicitarle la información estrictamente necesaria para el desempeño en el trabajo que se ofrece.

Ciudad de Buenos Aires: ley de búsqueda laboral equitativa - Ley 6471', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/comercial-ganader%C3%ADa-balanceado-c%C3%B3rdoba-interior-at-adecco-4483993951', N'LinkedIn', NULL, CAST(N'2026-11-02T18:54:49.1001667' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (10, N'Rk1feXpudjVqV2I0V3VzOUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZUzB0U1ZWM1EySnBWa0kxU21NeVNIcFVWSFZNWmpaSGJYSk9Wa1V3TFdsRWJXeFpWSGRuYkZWdFRYSjJZa0psTm5KNFMzUnVSbmhQV0dOSFJWSTVVMnAyVVhGa1VtZEpVRGxCYVVzd1VWQlhV', N'EJECUTIVO/A DE VENTAS TERRITORIALES (Corrientes)', N'ADECCO RECURSOS HUMANOS ARGENTINA SA', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQh8_Rq6W3dV5r8ujCZVWMA9egqYSIsod-X5dgx&s=0', N'Posadas, Misiones', N'BUSCAMOS TALENTOS,

¡EN ADECCO TE ESTAMOS BUSCANDO!

Desde Adecco estamos buscando Ejecutivos/as de Ventas Territoriales para incorporarse al equipo que brinda servicios a Mercado Pago, la plataforma líder en soluciones de cobro y servicios financieros digitales en nuestro país.

¡Desafíate a vos mismo y crea tu futuro!

¿QUÉ DESAFÍOS TE ESPERAN?
• Detectar oportunidades de negocio para soluciones de cobro presenciales (QR y Point).
• Incorporar nuevos comercios y gestionar una cartera propia de clientes.
• Capacitar y acompañar a los nuevos usuarios en la implementación de las herramientas de cobro.
• Gestionar base de potenciales clientes mediante llamadas, reuniones online y visitas presenciales.
• Planificar la agenda territorial para optimizar resultados y crecimiento de ventas.
• Analizar métricas de desempeño y elaborar reportes de gestión comercial.

¿QUÉ VALORAMOS DE TU PERFIL?
• Experiencia previa en ventas territoriales o comerciales de campo (excluyente).
• Experiencia en análisis de datos o métricas comerciales.
• Secundario completo.
• Deseable formación terciaria o universitaria en Comercialización, Administración, Marketing o Ingeniería Industrial.
• Marcado perfil comercial, capacidad de comunicación, negociación y persuasión.
• Orientación a resultados, autonomía y buena organización del tiempo.

¿QUE TE OFRECEMOS?
• Zona de trabajo: Corrientes
• Modalidad: Hibrido.
• Horario: Lunes a Viernes de 9 a 18hs.
• Ofrecemos: Sueldo + Comisiones por Venta + Viáticos + PC + Herramientas de Trabajo.
• Cobertura Médica.

Somos Adecco Argentina una compañía con más de 30 años de experiencia que conecta empresas con talentos, brindando soluciones integrales de Recursos Humanos y buscamos talentos, ¡COMO VOS!

Nuestro compromiso, es la diversidad e igualdad de oportunidades somos una empresa inclusiva. Cuando sos parte de nuestros procesos, solo cuentan tus méritos, logros y capacidades, lo hacemos pensando en vos como persona.

Participar de nuestros procesos de selección no tiene ningún costo para vos candidato/a, trabajar con vos es parte de nuestro compromiso y tarea con la comunidad. Postulate y participa en una oferta de empleo nuestra.

El empleador sólo podrá solicitarle la información estrictamente necesaria para el desempeño en el trabajo que se ofrece.

Ciudad de Buenos Aires: ley de búsqueda laboral equitativa - Ley 6.471', 0, N'Tiempo completo', NULL, N'https://www.bumeran.com.ar/empleos/ejecutivo-a-de-ventas-territoriales-corrientes-adecco-recursos-humanos-argentina-sa-1118502690.html', N'Bumeran', NULL, CAST(N'2026-11-02T18:54:49.1006623' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (11, N'eFpHSWpkNDl1U0NRbS1ULUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZbUV4WDB4UlFqWldOV293UVdWTWFXdEJWa2d0WlhKTk16RmhhVWgzYmxoMGQxSnVhelkwVVRoMVUzRnlVbUpKZVd0aWExUkVRVkF3T0VWcGVYSnBZMnBRYmpGdFdGQnlaa3hzTkdwbWEwd3hi', N'Asesor Comercial Rosario : Sueldo fijo + comisiones sin tope + beneficios - Sueldo fijo + comisiones sin tope + beneficios', N'Verisure Argentina', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRGQVHCl0Fn59Ff-wM9v1hqz-P633PN9D6bC83G&s=0', N'Rosario, Santa Fe', N'Sumate a Verisure Argentina y viví la experiencia de trabajar en un GreatPlaceToWork
Somos líderes en servicios de seguridad monitoreada para hogares y pequeños negocios. Formamos parte de un grupo internacional presente en 18 países y con más de 6.4 millones de clientes, lo que nos convierte en la Alarma Monitoreada N1 en el mundo. Combinamos tecnología de vanguardia, innovación constante y el compromiso de miles de personas que trabajan cada día para hacer realidad nuestra misión: proteger lo que más importa.
Si buscás desarrollarte en una empresa global, con propósito, oportunidades de crecimiento y una cultura centrada en las personas, ¡esta es tu oportunidad!
Sumamos al equipo Asesores/as Comerciales para el área de Ventas.
Principales desafíos:
Generación de nuevos y potenciales clientes.
· Convertir en ventas las visitas generadas por el área de Contact Center.
· Garantizar la adecuada disposición de los productos y servicios de la empresa.
· Seguimiento de tareas asociadas a la venta.
·
¿Qué buscamos?
Contar con título secundario completo (Excluyente)
· Contar con movilidad propia (Excluyente)
· Residencia en el país con una antigüedad no menor a 2 años
·
¿Qué ofrecemos?
Excelentes condiciones de contratación: Sueldo fijo y comisiones sin tope.
· Saldo mensual en combustible.
· Plan de carrera dentro del área Comercial propio de una compañía en plena expansión.
· Formación continua en técnicas de venta.
·
¿Qué nos convierte en una de las mejores empresas para trabajar del país? Los valores que compartimos en nuestro ADN, que nos representan y nos hacen únicos/as:
Le ponemos pasión a todo lo que hacemos.
Nos comprometemos para marcar la diferencia.
Innovamos siempre.
Ganamos en equipo.
Todo lo hacemos con confianza y responsabilidad.
· En Verisure tenemos un compromiso: fomentar un entorno de trabajo diverso e inclusivo, reconociendo que la diversidad de pensamiento y origen fortalece a nuestros equipos y potencia la innovación.-Requerimientos- Educación mínima: Secundaria
años de experiencia
Edad: entre 20 y 56 años
Licencias de conducir: B1 ,B2
Palabras clave: advisor, asesor, salesman, saleswoman, seller, vendedor, comercial, salesperson, nominas, sueldo, paga, retribucion, salary, payslip, payroll, wage, pay, payment, nominista, permanent, fijo', 0, N'Tiempo completo', NULL, N'https://ar.computrabajo.com/ofertas-de-trabajo/oferta-de-trabajo-de-asesor-comercial-rosario-sueldo-fijo-comisiones-sin-tope-beneficios-sueldo-fijo-comisiones-sin-tope-beneficios-en-rosario-AFC6D80D7BDE807C61373E686DCF3405', N'Computrabajo', NULL, CAST(N'2026-11-02T18:55:51.0073695' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (12, N'NUloMk5UT3pfOFluMlVBYkFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXbEZ6YkU0MFVUTmFORzVrVEROM05tZGZkRTFYUkVwV2NtTnRTemt4VURGb1JrRTVWblkzUzJweFNFeEJSMmxoWjA0NU1sWjBTMHRvYlhFMGQwcEhXbVEzZFhGamFFZE9hMHBzVmxoRE4xRlhT', N'Enfermera titulada', N'Centro Médico Zona Norte Córdoba', N'https://t0.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=https://centromedico.com&size=128', N'Córdoba', N'📢 *BÚSQUEDA ACTIVA: ENFERMERO/A*
📍 *Ubicación:* Centro Médico en Zona Norte (Córdoba Capital)

*Requisitos:*

* Título habilitante (Técnico/a o Licenciado/a en Enfermería).
* Experiencia previa en instituciones de salud.
* Referencias comprobables.

*Principales tareas y condiciones:*

* Canalización, asistencia directa a pacientes / Manejo de tratamientos en Cámara Hiperbárica.
* Soporte general al equipo médico.
* *Jornada:* 8hs presencial
* *Incorporación:* Inmediata.

📩 Interesados/as, enviar CV actualizado y copia de matrícula habilitante a:

• Seleccion@eugeniapacetti.com', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/enfermera-titulada-at-centro-m%C3%A9dico-zona-norte-c%C3%B3rdoba-4484360219', N'LinkedIn', NULL, CAST(N'2026-11-02T18:55:51.0078660' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (13, N'VHBJTE1XVEs5VHZ6Yi1rM0FBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXbEJVV25RMldFVlJZbVpQYTJGaFREUnplWEl0WW5Gb2N5MXVTMkZFVW14WmIyUnhiVFJ6YWpsdVpVUTBkVzA1TjB4Qk5YWXlTblUxV0hkbVZsbHhUWEJZT1VFdGFsbzVObFpIVUdweFpqRkJY', N'AI Editor', N'WPP Production', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1hUeR0WJwVpazb9dNqJYfa7_MZbwGw9wAr8cJ&s=0', N'Cdad. Autónoma de Buenos Aires', N'About WPP Production

We are WPP Production - the unified global production company that brings together all of WPP''s content producers, studios and craft experts into one connected organisation. We combine world-class human craft with next generation technology to originate, design, and deliver multi-channel content systems at scale. Built for borderless collaboration and powered by deep craft expertise, we are the production engine designed for today''s always on, AI driven marketing world.

About WPP

WPP is the trusted growth partner for the world’s leading brands. We unite cutting-edge media intelligence and data solutions, world-class creativity, next-generation production, transformative enterprise solutions and expert strategic counsel in a single company – powered by exceptional talent and our agentic marketing platform, WPP Open, to help our clients navigate change, capture opportunity and deliver transformational growth. For more information, visit WPP.com.

A Hybrid working model

We believe the best work happens when we''re together, fostering creativity, collaboration, and connection. That''s why we’ve adopted a hybrid approach, with teams in the office around four days a week. If you require accommodations or flexibility, please discuss this with the hiring team during the interview process.

What does a AI Editor do at WPP Production?

This role requires a highly skilled audiovisual editor with expertise in motion graphics, AI-generated content creation, and the ability to deliver polished advertising pieces across multiple formats and durations. The ideal candidate will be passionate about storytelling, have a strong command of cutting-edge AI tools, and possess advanced technical skills in editing.

You will be responsible for creating, adapting, and enhancing advertising materials such as animatics, using AI-driven image and video generation techniques, motion graphics, and VFX. You will collaborate closely with creative teams, directors, producers, and clients to ensure high-quality deliverables that meet brand guidelines and project objectives.

Key Responsibilities:

Content Creation & Editing:

• Create and animate AI images and videos
• Edit audiovisual advertising pieces using standard tools, AI tools and motion graphics.
• Adapt existing content to various durations, formats, and platforms (e.g., social media, TV, digital).
• Develop visually compelling narratives that align with client goals and brand identity.

AI Integration:

• Leverage generative AI tools (e.g., Runway, MidJourney, LTX, ComfyUI) to produce images, videos, and animations.
• Experiment with AI technologies to push creative boundaries and innovate within the post-production process.

Motion Graphics & VFX:

• Design and animate motion graphics for advertising campaigns.
• Perform tracking, compositing, and VFX integration to enhance visual storytelling.
• Execute color correction and grading to ensure consistent visual quality.

Pre-Production & Storyboarding:

• Collaborate with creative teams to develop storyboards, animatics, and audiovisual narrative direction.

Project Management:

• Manage multiple projects simultaneously while meeting tight deadlines.
• Ensure all deliverables adhere to technical specifications and quality standards.

Role Requirements:

• Bachelor’s degree in Film, Media Production, Animation, or a related field (or equivalent experience).
• Proven experience as an audiovisual editor, preferably in advertising or corporate content.
• Strong portfolio showcasing expertise in editing, AI-generated content, and motion graphics.
• Advanced proficiency in Adobe Creative Suite (Premiere Pro, After Effects, Photoshop, Illustrator).
• Experience with AI tools such as Runway, LTX, MidJourney, ComfyUI or similar platforms.
• Understanding of VFX workflows, including tracking, compositing, and color correction.
• Knowledge of audiovisual narrative direction, storyboarding, and animatics.
• Ability to adapt content to different formats and durations for diverse platforms.
• Familiarity with industry trends and emerging technologies in AI and post-production.
• Strong organizational and time-management skills, with the ability to work under pressure.
• Excellent communication and collaboration skills, with a proactive and solution-oriented mindset.

Desired Skills and Experiences:

• Expertise in storytelling and crafting engaging audiovisual narratives.
• Experience in both advertising and corporate editing environments.
• Passion for exploring new creative possibilities through AI and technology.
• Attention to detail and commitment to delivering high-quality work.
• Multilingual capabilities (e.g., Spanish and English) are required.

Software Proficiency:

Essential:

• Adobe Premiere Pro
• Adobe After Effects
• Adobe Photoshop
• Runway
• MidJourney
• LTX
• ComfyUI

Additional Tools (Preferred):

• DaVinci Resolve (for color correction and grading)
• Cinema 4D or Blender (for advanced motion graphics and 3D animation)
• Other generative AI platforms

Why work here:

At WPP Production, you’ll help shape the future of content production at a truly global scale. We bring together world-class talent, cutting-edge studios, and advanced technology to solve some of the most complex creative and production challenges in the industry. You’ll work in a collaborative, borderless environment where craft excellence is valued, innovation is encouraged, and AI and next-generation tools are used to amplify not replace human creativity. With access to diverse projects, global career opportunities, and the backing of WPP’s unmatched network, this is a place where you can grow your skills, make real impact, and create work that performs for every audience, across every channel, at every moment.

Inclusion and Impact

WPP is an equal opportunity employer and considers applicants for all positions without discrimination or regard to particular characteristics. We are committed to fostering a culture of respect in which everyone feels they belong and has the same opportunities to progress in their careers.

Data

We rely on legitimate interest as a legal basis for processing personal information under the GDPR for purposes of recruitment and applications for employment. When you click the "Submit Application" button at the bottom of this page, this will send all the information you have added to WPP Production. Before you do this, we think it''s a good idea to read through our Privacy statement. This explains what we do with your personal data when you apply for a role with us, and, how you can update the information you have provided us with or how to remove it.

Please contact careers@wppproduction.com if you need the job advert or form in another format.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/ai-editor-at-wpp-production-4485247357', N'LinkedIn', NULL, CAST(N'2026-11-02T18:55:51.0083609' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (14, N'ZXFjMnplWmEwSzBtdVVzVkFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZVXRST1hOc05GTkdlRzV2WVVFdFJuSk1SRmRWTlZSSWFITTNTR3RCYTBGVVZtSXRhMFp1UldGeVdHcHlOWHBsY2w5aU1qTjVkR3BKTjI5ME1FUndUVUpWU2t4V1NERlVNbkJGUVhjMGVtZDJW', N'Operario/a logístico, acompañante de chofer eventual / Zona Norte', N'Adecco Argentina S.A.', N'https://t0.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=https://adecco.com&size=128', N'Argentina', N'Adecco Industrial está especializada en el reclutamiento, selección, evaluación y puesta a disposición de profesionales en el área industrial y de producción en todos los sectores de actividad.
Adecco Industrial cuenta con consultores especializados con conocimientos específicos y experiencia contrastada en la selección de perfiles industriales, asegurando un proceso ágil, eficiente y de calidad tanto para las empresas como para los candidatos.
Si te gustan los desafíos y sos una persona comprometida,
¡Tenemos una oportunidad para vos!
· Estamos buscando OPERARIO/A LOGÍSTICO, ACOMPAÑANTE DE CHOFER EVENTUAL para trabajar a través de Adecco para nuestro cliente importante centro de distribución ubicado en PACHECO, ZONA NORTE, BUENOS AIRES.
Principales responsabilidades: Tareas generales de mantenimiento
Los requisitos son:
Estudios secundarios finalizados, con analítico en mano (EXCLUYENTE)
Contar con experiencia en tareas de carga y descarga en depósito/logística.
Disponibilidad full time.
Disponibilidad de ingreso inmediato.
Zona de residencia en localidades de ZONA NORTE, GRAN BUENOS AIRES.
Área laboral: Depósito/logística.
Zona de Trabajo: ZONA NORTE, GRAN BUENOS AIRES
Modalidad: por convocatoria, de lunes a viernes, horarios de ingreso a confirmar.
Horario: a confirmar
Sueldo: Según CCT
Tipo de contrato: eventual por 6 meses.
· ¡TRANSFORMÁ TU TALENTO EN EXPERIENCIA!
APOSTÁ AL CAMBIO, NOSOTROS APOSTAMOS POR VOS
El compromiso de Adecco, es promover y mantener la cultura del respeto e igualdad de oportunidades. No discriminamos en función del género, religión, etnia, nacionalidad, cultura, grupo social, discapacidad o enfermedad, orientación sexual, estado civil, edad u opinión política. Cuando elegimos el personal para un cliente, la decisión se basa única y exclusivamente en los méritos y capacidades de esa persona.
Adecco no solicita dinero a cambio de sus servicios. Participar de una búsqueda con nosotros es parte de nuestro compromiso y tarea. Por ello, postularte y participar en una oferta de empleo, es GRATIS.-Requerimientos- Educación mínima: Secundaria
1 año de experiencia
Palabras clave: operator, operario, operator, conductor, driver, choferes, chofer, area', 0, N'Tiempo completo', NULL, N'https://ar.computrabajo.com/ofertas-de-trabajo/oferta-de-trabajo-de-operarioa-logistico-acompanante-de-chofer-eventual-zona-norte-en-gral-pacheco-AADF96461C0CEA1261373E686DCF3405', N'Computrabajo', NULL, CAST(N'2026-11-02T18:55:51.0083609' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (15, N'Z2ZETHJMOXhCeHVVbjR4T0FBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXVUZxVTFaMlR6aEhablpVVW1SdWQyWnVSMWhwTUZKSmNteGZWRVJ6YlVwMFpFODNUekZNVDBocU9FRXlPVTF6YlhjdGNtcEZiVWhJUlc1clkySlZVREZ0ZVV4V2RESnpiWFZGYUROaVZqTXlS', N'Operarios/as de depósito (empresa líder)', N'Randstad AR', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQnGi2f4uoxgnabfk515UOSB5L5BbLT5Hq0qaii&s=0', N'Cdad. Autónoma de Buenos Aires', N'Operarios/as de Depósito (por convocatoria)

En Randstad nos encontramos en la búsqueda de Operarios u Operarias de Depósito para desempeñarse en tareas logísticas en una Importante Empresa del sector.

Modalidad de trabajo: convocatoria discontinua, según necesidad operativa.

Tareas principales:
• Carga y descarga de mercadería.
• Armado de pedidos.
• Movimiento y acondicionamiento de productos.
• Control de stock y tareas generales de depósito.

Requisitos:
• No se requiere experiencia previa.
• Disponibilidad horaria full time y para trabajar en turnos rotativos.
• Compromiso, responsabilidad y predisposición para el trabajo en equipo.

Ofrecemos:
• Posibilidad de incorporación inmediata.
• Experiencia en una empresa líder del rubro.

Si considerás que reunís los requisitos para el puesto y te gustan los desafíos, no lo dudes…. ¡Postulate!

En Randstad nos moviliza ayudar a las personas y a las organizaciones a desarrollar todo su potencial. Ese es el compromiso que asumimos como compañía en todo el mundo, un compromiso que nos impulsa a ir más allá para lograr que nuestros clientes y candidatos alcancen el éxito. ¿Cómo lo hacemos?, combinando nuestra pasión por las personas con el poder de la tecnología, creando experiencias más humanas, que nos permitan ser una fuente de inspiración y apoyo para quienes nos eligen. Porque estamos convencidos de que mejores personas hacen mejores empresas.

Nos esforzamos todos los días en crear un entorno diverso y nos enorgullece ser una empresa con igualdad de oportunidades para todas las personas, independientemente de su raza, color, religión, sexo, identidad sexual u orientación sexual, país de origen, genética, discapacidad o edad.

educación

Secundario completo', 0, N'Tiempo completo', NULL, N'https://www.randstad.com.ar/trabajos/operariosas-de-deposito-empresa-lider_capital-federal_46243125/', N'Randstad Argentina', NULL, CAST(N'2026-11-02T18:55:51.0088578' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (16, N'V0RsSUoxNmxYR2pDLTNYdUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXUzFtZWxWblJWSTRURWhzUlZWRFdsZHlSamRpWmpKclJUVmxNVlphYWtjeWFVWm5URGxWWVd3dE5VVktNWFl6ZEhVdGR6SnljMkZhVEZKSU9FRjJPRGR3V25SMVdWbGpOM0pOZERGc2FGSkli', N'Jefe/a de Producción Gastronómica', N'ADECCO RECURSOS HUMANOS ARGENTINA SA', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQh8_Rq6W3dV5r8ujCZVWMA9egqYSIsod-X5dgx&s=0', N'Río Cuarto, Córdoba', N'Si te interesa ser Jefe/a de Higiene y Producción Alimentaria para trabajar en importante empresa de Río Cuarto.¡desafíate a vos mismo y crea tu futuro!

¿QUÉ DESAFÍOS TE ESPERAN?
• Planificar y coordinar la producción diaria.
• Liderar el equipo de cocina.
• Gestionar pedidos y abastecimiento de insumos.
• Participar en la planificación de menús junto a la jefatura de planta.
• Garantizar el cumplimiento de estándares de calidad e inocuidad alimentaria.
• Optimizar tiempos, recursos y procesos productivos.

¿QUÉ VALORAMOS DE TU PERFIL?
• Experiencia previa liderando cocinas industriales o servicios de alimentación.
• Capacidad de organización y planificación.
• Conocimiento de procesos gastronómicos de gran volumen.
• Manejo de costos, cantidades e insumos.
• Experiencia en empresas alimenticias, hotelería, hospitales, minería o gastronomía corporativa.
• Formación gastronómica, Administración Gastronómica, Bromatología o carreras afines.
• Experiencia en producción masiva de alimentos.
• Consideramos candidatos/as de otras localidades. La empresa no acompaña económicamente a la relocalización

¿QUE TE OFRECEMOS?
• Lugar de trabajo :Río Cuarto
• Horario laboral: 04:00 a 12:45 hs.

Nuestro compromiso, es la #diversidad e #igualdad de oportunidades somos una empresa inclusiva. Cuando sos parte de nuestros procesos, solo cuentan tus méritos, logros y capacidades, lo hacemos pensando en vos como persona.

Participar de nuestros procesos de selección no tiene ningún costo para vos candidato/a, trabajar con vos es parte de nuestro compromiso y tarea con la comunidad. Postulate y participa en una oferta de empleo nuestra.El empleador sólo podrá solicitarle la información estrictamente necesaria para el desempeño en el trabajo que se ofrece.

Ciudad de Buenos Aires: ley de búsqueda laboral equitativa - Ley 6471', 0, N'Tiempo completo', NULL, N'https://www.bumeran.com.ar/empleos/jefe-a-de-produccion-gastronomica-adecco-recursos-humanos-argentina-sa-1118499421.html', N'Bumeran', NULL, CAST(N'2026-11-02T18:55:51.0088578' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (17, N'SEtiX3hUSlhobnJ2T2F0dUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZVEo2YjJscllqUTNhRmhSYlhsbFNYcFFTVk5yYmpoblNYaENSSFJrVFUxMFNuRk5XV1pmTkV4UU0zSjBWMFpCWXpkQ1FWcEJlVEpaUkRSS1JITklaWEF5ZGtSMU5rODRNMWxxVEdsMldrZFBU', N'Coordinador de Payroll & HR Operations', N'Confidential Careers', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSa-gwOMoVWUUuQbEQNJKW8tkb7ItOUetY-OqEI&s=0', N'Argentina', N'Coordinador de Payroll & HR Operations

Ubicación: CABA (Esquema Híbrido - 3 o 4 días presencial)

Jornada: Full-time

Sobre la oportunidad

Importante empresa de servicios y outsourcing se encuentra en la búsqueda de un/a Líder de Payroll & HR Operations para sumarse a su estructura de Recursos Humanos.

Buscamos un perfil estratégico y operativo, con marcada experiencia en la gestión integral del área hard de Recursos Humanos, liderazgo de equipos y administración de nóminas de volumen.

Principales Desafíos:
• Liderar la operación integral del área de Payroll y Administración de Personal.
• Coordinar y potenciar al equipo de trabajo a cargo.
• Garantizar el cumplimiento normativo, previsional e impositivo (LSD, Cargas Sociales, Libro Sueldos Digital, Impuesto a las Ganancias 4ta Categoría, embargos y certificaciones).
• Supervisar la gestión de contrataciones, legajos, licencias y control documental.
• Garantizar la correcta aplicación de normativas laborales y la gestión operativa multi-convenio.
• Impulsar la mejora continua de procesos, parametrización de fórmulas y proyectos de implementación/migración de sistemas de liquidación.
• Generar reportes de gestión, análisis de costos laborales y simulaciones de nómina para la toma de decisiones.

¿Qué buscamos?
• Graduados o estudiantes avanzados de Relaciones Laborales / RRHH, Contador Público, Lic. en Administración o carreras afines.
• Experiencia mínima de 5 años coordinando o liderando áreas de liquidación de sueldos y administración de personal en estructuras de mediano/gran volumen (+500 colaboradores).
• Sólida experiencia en gestión y liquidación multi-convenio (ej. Comercio, Petróleo, Camioneros u otros de complejidad operativa).
• Dominio de sistemas ERP/liquidación de haberes de mercado y plataformas AFIP.
• Nivel avanzado de Excel.
• Fuertes habilidades directivas, visión analítica y orientación a resultados.', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/coordinador-de-payroll-hr-operations-at-confidential-careers-4484105999', N'LinkedIn', NULL, CAST(N'2026-11-02T18:55:51.0093539' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (18, N'TEFSWkdUNWlheGNOdnZqZkFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxZWFJhUmtVeGJEVnNVVk5DUldaMFRGYzBXWFExUjJaQk5Ga3dSekZsTW5JMU1FbGhiSGx2Vm1sSWVEVmxUM1JXVUVsNVFVcExNMmRyWjJacldFdExRVnA0Vmt0cGRrTnlabTlpVGtGV2VYaG1O', N'Gerente/a de Prestaciones', N'Confidential Careers', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSa-gwOMoVWUUuQbEQNJKW8tkb7ItOUetY-OqEI&s=0', N'Argentina', N'Nos encontramos en la búsqueda de un/a Gerente/a de Prestaciones para incorporarse a una importante organización del sector salud, con sede en Capital Federal.

Principales responsabilidades:

Supervisar y realizar el seguimiento de las prestaciones y los acuerdos con financiadores.

Liderar negociaciones de tarifas y convenios, promoviendo la mejora continua de las condiciones comerciales.

Analizar indicadores de gestión (KPIs) y elaborar reportes de resultados por financiador y unidad de negocio.

Identificar oportunidades de mejora, desarrollar propuestas comerciales y realizar el seguimiento de proyectos estratégicos.

Coordinar acciones con las áreas de Sistemas y otros equipos internos para impulsar mejoras en los procesos y herramientas de gestión.

Mantener una comunicación fluida con financiadores y clientes, participando en reuniones y encuentros comerciales.

Monitorear el desempeño de las prestaciones de las distintas unidades de negocio, identificando oportunidades de desarrollo y crecimiento.

Liderar equipos de trabajo, promoviendo la colaboración, el cumplimiento de objetivos y la orientación a resultados.

¿Qué buscamos?
• Experiencia mínima de 10 años en posiciones similares, preferentemente en el sector salud.
• Conocimientos en gestión de prestaciones, convenios y negociaciones con financiadores.
• Experiencia en análisis de indicadores de gestión, seguimiento de resultados y desarrollo de propuestas comerciales.
• Manejo de CRM y herramientas de gestión comercial.
• Habilidades de liderazgo, negociación, comunicación y toma de decisiones.
• Perfil proactivo, analítico, conciliador y orientado al cliente y a la mejora continua.

¿Qué ofrecemos?
• Almuerzo en las oficinas.
• Prepaga.
• Plataformas de descuentos y beneficios exclusivos, entre otros.

Jornada laboral: lunes a viernes, de 9 a 18 h.

Modalidad: híbrida, con 3 días presenciales y 2 días de home office.

Zona de trabajo: Capital Federal.

Si tu perfil se ajusta a lo que estamos buscando, ¡te invitamos a postularte y compartirnos tu CV!

¡Sumate a un nuevo desafío profesional!', 0, N'Tiempo completo', NULL, N'https://ar.linkedin.com/jobs/view/gerente-a-de-prestaciones-at-confidential-careers-4484577039', N'LinkedIn', NULL, CAST(N'2026-11-02T18:55:51.0093539' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (19, N'SG5MTk9pdXUtQVVOdlh1RUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXV3QyWkdWSmVUZ3hORjlpV25OM2IyMVpjMWhGYUZWb1owTkRaRzVqVEMxa2VWQmFjV05rZVU5SlpEaElORWx4UzJ0TWJrVTRXVEV6VUY5SWFWUndiSE53YzI5b1YzTlhjVUZPYkRSSFZtaDJU', N'GERENTE COMERCIAL', N'MANNOL ARGENTINA', N'https://t0.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=https://bumeran.com.ar&size=128', N'Villa Maipú, Provincia de Buenos Aires', N'Sobre RS Lubricantes

RS Lubricantes es una empresa argentina especializada en la importación, comercialización y distribución de lubricantes, aditivos y productos de alta tecnología para el sector automotor e industrial.

Somos representantes de MANNOL en Argentina, una marca internacional reconocida por su amplia gama de lubricantes y soluciones de alto rendimiento.

Con una fuerte orientación al crecimiento y al desarrollo de nuestra red comercial a nivel nacional, trabajamos para consolidar nuestra presencia en el mercado, construyendo relaciones de largo plazo con distribuidores y clientes estratégicos.

En el marco de nuestro proceso de expansión, buscamos incorporar profesionales con experiencia, liderazgo y visión estratégica que nos acompañen en una nueva etapa de crecimiento.

GERENTE COMERCIAL

Industria de Lubricantes y Aftermarket Automotor

RS Lubricantes se encuentra en la búsqueda de un Gerente Comercial para liderar y potenciar el desarrollo de nuestro negocio a nivel nacional.

Buscamos un profesional con sólida trayectoria en el sector de lubricantes, autopartes o aftermarket automotor, con visión estratégica, fuerte orientación a resultados y experiencia comprobable en conducción de equipos comerciales.

Principales responsabilidades
• Diseñar, implementar y ejecutar la estrategia comercial de la compañía.
• Liderar, coordinar y desarrollar el equipo de ventas, estableciendo objetivos claros y medibles.
• Desarrollar y fortalecer la red de distribuidores, mayoristas y clientes estratégicos a nivel nacional.
• Identificar nuevas oportunidades comerciales, mercados y canales de distribución.
• Definir y monitorear indicadores de gestión comercial (KPIs), volumen de ventas, rentabilidad y participación de mercado.
• Analizar el mercado, la competencia y las tendencias del sector para desarrollar estrategias de crecimiento.
• Participar en la definición de políticas comerciales.
• Elaborar presupuestos comerciales, proyecciones de ventas y planes de acción para alcanzar los objetivos establecidos.
• Trabajar de manera coordinada con las áreas de Marketing, Administración y Logística.

Requisitos excluyentes
• Experiencia mínima de 5 años desempeñándose como Gerente Comercial o en posiciones equivalentes de conducción comercial.
• Experiencia comprobable en la industria de lubricantes o en el mercado aftermarket automotor.
• Experiencia en conducción, desarrollo y gestión de equipos de ventas.
• Conocimiento del canal de distribución mayorista y de las redes comerciales del sector automotor.
• Capacidad de planificación estratégica, negociación y desarrollo de negocios.
• Manejo de indicadores comerciales, presupuestos y herramientas de gestión.
• Disponibilidad para realizar viajes comerciales dentro del país.

Competencias valoradas
• Liderazgo y capacidad para desarrollar equipos de alto desempeño.
• Perfil comercial, proactivo y orientado a resultados.
• Visión estratégica y capacidad de ejecución.
• Excelentes habilidades de negociación y comunicación.
• Autonomía, iniciativa y capacidad para tomar decisiones.
• Experiencia en desarrollo y expansión de redes de distribuidores.

Ofrecemos
• Incorporación a una empresa en desarrollo y expansión dentro del mercado automotor.
• Posición estratégica con participación directa en las decisiones comerciales.
• Oportunidad de liderar proyectos de crecimiento y expansión nacional.
• Remuneración acorde a la experiencia y responsabilidades de la posición.

Si contás con experiencia en el sector y buscás un nuevo desafío profesional, te invitamos a postularte.', 0, N'Tiempo completo', NULL, N'https://www.bumeran.com.ar/empleos/gerente-comercial-mannol-argentina-1118498411.html', N'Bumeran', NULL, CAST(N'2026-11-02T18:55:51.0098489' AS DateTime2))
INSERT [dbo].[OfertaExterna] ([ID], [ID_Externo], [Titulo], [Empresa], [Logo], [Ubicacion], [Descripcion], [Es_Remoto], [Tipo_Contrato], [Salario], [Link_Postulacion], [Publicador], [Fecha_Publicacion], [Fecha_Consulta]) VALUES (20, N'emlhM0VwMlBRaUx0TDl0TUFBQUFBQT09OkVzd0JDb3dCUVVSRVlsZGxXbGhJWWtaWFNWUnBNVUl5YVZkeGJYSk5NekJWUzJneGRFTXdjekJoWlY5WFJrSnFTbWxOWkhaQ1lYbEVOREF5Vkhob1VUQkhVbWR5Wmt4TWNXSm5VWFJST1dRMFdqUk9MVFpSVUY5dVFVUnRT', N'Operador/a de digitalización documental', N'Grupo Ceta Argentina', N'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT84Ba2jMsOP5u9B7cxH_t2QkG2huT-O6jp85eb&s=0', N'Vicente López, Provincia de Buenos Aires', N'En Ceta Capital Humano, empresa de Grupo Ceta, con amplia trayectoria y reconocimiento en el mercado, nos encontramos en la búsqueda de operador/a de digitalización documental para incorporarse de forma eventual en una importante empresa de Zona Norte San Martin
Principales responsabilidades:
Digitalización de documentación física de archivo.
Clasificación de la misma para posterior destino.
Requisitos:
Experiencia previa en tareas de digitalización. (Deseable)
Modalidad de trabajo: Contratación eventual
Jornada: Full Time
Residir en San Martín Zona Norte.
Formación académica: Secundario completo, con analítico en mano.
Valoramos:
Buena presencia y trato cordial.
Disponibilidad y compromiso.
Atención al detalle.
· Si contás con experiencia previa en tareas descriptas ¡Postulate!
Ceta Capital Humano, orgullosos de pertenecer a Grupo Ceta.-Requerimientos- Educación mínima: Terciario
1 año de experiencia
Palabras clave: operator, operario, operator', 0, N'Tiempo completo', NULL, N'https://ar.computrabajo.com/ofertas-de-trabajo/oferta-de-trabajo-de-operadora-de-digitalizacion-documental-en-vicente-lopez-B1A052AC8CC3A6B361373E686DCF3405', N'Computrabajo', NULL, CAST(N'2026-11-02T18:55:51.0098489' AS DateTime2))
SET IDENTITY_INSERT [dbo].[OfertaExterna] OFF
GO
