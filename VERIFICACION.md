# Verificación V6

- Compilación de todas las fuentes C# y vistas Razor con .NET 8/EF Core 8.0.11: sin errores ni advertencias.
- Pruebas del interceptor entregado, registrado en EF Core InMemory: letras Unicode, tildes compuestas/descompuestas, nombres con espacios, teléfono opcional, ocho dígitos incluyendo cero inicial, rechazo de números/signos/saltos de línea en nombres, teléfono corto/largo/con letras/guiones/dígitos de ancho completo. Altas, ediciones, SaveChanges y SaveChangesAsync.
- Chrome Headless/Playwright con el proyecto: restricciones en formulario Nuevo piloto cargado bajo demanda y en Nuevo titular; nombres válidos con tildes aceptados, nombres con números y teléfonos inválidos rechazados en pantalla.
- POSTs directos con token antifalsificación válido a CrearTitular: nombre con números, nombre con texto SQL y teléfono de siete dígitos generan el error específico del interceptor y no se guardan. Consulta posterior sin resultados para el DPI utilizado. POST válido posterior con ese mismo DPI, José Ángel De León y teléfono de ocho dígitos: guardado correcto y recuperación correcta por búsqueda.
- En el arnés HTTP, la sesión ficticia usa un identificador no numérico para omitir exclusivamente la configuración de SESSION_CONTEXT de SQL Server, que no está disponible en InMemory. El proyecto entregado conserva la sesión y auditoría originales.
- Sin errores JavaScript durante estas pruebas. Integridad del ZIP comprobada.

Límites: base ficticia InMemory, sin ejecutar procedimientos/triggers ni medir rendimiento en el SQL Server del usuario. La validación se aplica a los cambios de entidades mediante EF; no modifica ni sanea registros históricos automáticamente. Se mantienen las llamadas SQL parametrizadas existentes; no se afirma una auditoría integral de seguridad.

## Comprobaciones anteriores

# Verificación V5

- Compilación directa de C# y del generador Razor con .NET/ASP.NET Core 8 y EF Core 8.0.11: sin errores ni advertencias.
- Pruebas HTTP con datos simulados: entradas y fichas de Personal/Catálogos, formularios, búsqueda de tarjetas, paginación, límites negativos/excesivos de página, resultados vacíos, selector inicial y cinco reportes. Tipo de reporte inválido rechazado con 400.
- Chrome Headless 151 mediante Playwright: escritorio 1440×900 y pantalla pequeña 390×844. Se comprobaron color verde del banner, texto exacto y color #243b53, azul de la barra lateral y posición constante de ésta después de desplazar la página. Capturas inspeccionadas visualmente.
- Búsqueda real desde el formulario por DPI (titular correcto y exclusión de otros titulares) y nombre con tilde; 60 tarjetas coincidentes distribuidas en páginas de 25/25/10, filtro conservado y mensaje para búsqueda sin resultados.
- Carga bajo demanda de 20 pilotos y apertura de ficha con datos completos en navegador; no hubo errores JavaScript durante las pruebas.
- Selector de reportes: entrada sin tablas, una sola tabla y un botón de impresión por reporte, selección conservada después de consultar. Se generaron PDFs de los cinco reportes; comprobación del modo impresión y extracción de texto confirmaron que no incluye navegación ni selector ni otros reportes.
- Auditoría: usuario sin AUDITORIA_VER no ve la opción y su acceso por URL es rechazado por el flujo de acceso denegado.
- Portal ciudadano: menú oculto al ingresar tarjeta y título del banner presente.
- Integridad del ZIP verificada; excluye bin, obj y archivos de pruebas.

Límites: entorno de pruebas con EF Core InMemory y datos ficticios. Para poblar los reportes de prueba, sus modelos de vistas se mapearon sólo en el arnés de pruebas a entidades con clave; el proyecto entregado conserva sus vistas SQL originales. No se consultó la base del usuario ni se ejecutaron procedimientos/triggers de SQL Server. No se modificó el esquema de base de datos en V5.

## Comprobaciones anteriores

# Verificación V4

- Compilación de todas las fuentes C# y vistas Razor con .NET/ASP.NET Core 8 y EF Core 8.0.11: sin errores ni advertencias. Se usó el compilador y generador Razor directamente; no se ejecutó la compilación desde Visual Studio.
- Pruebas HTTP del proyecto con EF Core InMemory y 2,875 entidades simuladas, incluyendo 171 pilotos, 480 guardias, 480 accesos, 240 buses y 120 estaciones.
- Se renderizaron y comprobaron las dos entradas, nueve directorios, nueve fichas completas, trece formularios de creación/asignación, búsqueda y paginación. Respuestas parciales identificadas y sin almacenamiento en caché; tipo no permitido devuelve 400 y ficha inexistente 404.
- HTML inicial: Personal 3,876 bytes/59 elementos y Catálogos 4,280 bytes/65 elementos, sin listas desplegables de registros. Cada página del directorio contiene como máximo 20 resúmenes y no carga formularios de edición. Medidas del entorno simulado, no un porcentaje de mejora sobre la instalación del usuario.
- Con cookies reales de autenticación: menú ciudadano ausente al ingresar número de tarjeta, tanto con sesión de personal como con sesión ciudadana previa; presente en la vista de tarjeta autenticada.
- JavaScript: sintaxis válida; pruebas simuladas de eventos para petición única, cancelación al cerrar, descarte de respuesta tardía, reapertura, búsqueda, reintento y conservación del valor del botón LLEGADA en formularios POST.
- Logo copiado idéntico al archivo recibido; verde dominante de la imagen: #97D700. Bloques explicativos retirados de las vistas.
- Repetidas las pruebas de edición segura, aislamiento por línea y planificación de mantenimiento/reactivación: correctas.

Límites: las pruebas HTTP usan una base en memoria y no ejecutan los triggers, procedimientos ni transacciones SQL Server. No se accedió a la base del usuario ni se midió el rendimiento en su equipo. Se inspeccionó el HTML renderizado; no se completó una revisión visual ni de rendimiento con Chrome. V4 no modifica el esquema ni agrega SQL.

## Verificación anterior V3


Comprobaciones ejecutadas:

- Compilación directa C# 12 / .NET y ASP.NET Core 8 con los ensamblados EF Core 8.0.11 del proyecto. Compilación del generador Razor con Tag Helpers reales. Sin errores ni advertencias.
- Pruebas del servicio de consulta con dos líneas y datos simulados mediante EF Core InMemory: antes de seleccionar línea no se cargan datos operativos; viajes, ruta, buses disponibles, pilotos asignados, paradas, alertas, esperas y estaciones se filtran por la línea correcta. No se ofrecen pilotos ocupados.
- Prueba de planificación: ruta con estación intermedia inactiva; omisión sin renumerar, siguiente estación disponible, suma de minutos de traslado y restitución en el orden original al planificar con la estación reactivada.
- Prueba de edición: corrección de apellido y desactivación de guardia sin asignación obligatoria; IDs y fechas automáticas no aceptan cambios enviados por el formulario; se rechaza una revisión desactualizada.
- Renderizado de 22 escenarios Razor: fases de llegada/conteos/salida, portal ciudadano, selector inicial, todas las acciones de línea, catálogos, personal y editor. Sin excepciones.
- Inspección del HTML: fichas desplegables, relaciones de línea-estación, formularios de edición con revisión, tokens antifalsificación y campos de contexto de línea en los formularios operativos.
- Renderizado específico del seguimiento de personal y ciudadano: no muestra una estación marcada omitida y sí muestra la terminal activa siguiente.
- Parser Microsoft SQL Server ScriptDom: sintaxis T-SQL de Actualizacion_Transmetro_V3.sql válida.
- Integridad del ZIP verificada.

Límites de estas comprobaciones: EF Core InMemory no ejecuta triggers SQL, índices filtrados, procedimientos ni transacciones SQL Server. No se ejecutó la migración sobre la base del usuario. Las pruebas de mantenimiento de viajes existentes, activación, reasignación/reordenación y concurrencia transaccional deben completarse en SQL Server. Las páginas se renderizaron con datos simulados y se inspeccionó su HTML; no se hizo una revisión visual en navegador.
