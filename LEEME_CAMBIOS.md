# Transmetro — V6: validación central de datos personales

## Instalación

1. Respalda TransmetroGestionDB y cierra la aplicación.
2. Si ya aplicaste V3, esta entrega no requiere ejecutar SQL: sustituye el código y conserva tu cadena de conexión. Si todavía estás en una versión anterior, ejecuta `Actualizacion_Transmetro_V3.sql` en SSMS; incluye las actualizaciones previas y conserva tus registros y relaciones.
3. Abre `TransmetroGestion/TransmetroGestion.sln` con Visual Studio, restaura NuGet y compila con .NET 8. Configura tu conexión a SQL Server como en tu instalación actual.
4. Revisa las líneas y estaciones que aún aparecen Pendiente y actívalas cuando estén listas. Para iniciar un viaje nuevo deben estar activos la línea y al menos dos de sus estaciones.

Si ya estás usando V2, basta ejecutar V3 y sustituir el código. El SQL V3 contiene V2; no necesitas ejecutarlas por separado. Para instalar desde cero: creación original → V3 → carga geográfica → datos de prueba. Los archivos de carga están dentro del ZIP.

## Cambios de V6

- Validación central mediante interceptor EF Core para altas y modificaciones de Nombres, Apellidos y Telefono, también si se envía una petición directa al servidor. Las ediciones validan los campos modificados y no bloquean cambios ajenos por datos históricos que no se tocaron.
- Nombres y apellidos personales: sólo letras Unicode, tildes, ñ y espacios, hasta 100 caracteres. Se normaliza Unicode y se recortan espacios de los extremos. Los nombres de líneas, estaciones y otros elementos no se restringen a letras porque pueden contener números.
- Teléfonos: exactamente ocho dígitos ASCII sin guiones ni espacios interiores. Se respeta si el teléfono era opcional; en esos casos puede quedar vacío.
- El navegador aplica las mismas restricciones en formularios existentes y cargados bajo demanda.
- Se conserva la parametrización de consultas y procedimientos de EF Core. Una lista de palabras SQL prohibidas no se usa como protección: las entradas de texto nunca deben concatenarse en instrucciones SQL. El interceptor valida datos personales, no es un filtro universal del lenguaje SQL ni una garantía absoluta sobre futuras consultas agregadas al proyecto.
- Incluye V5 y anteriores. No requiere un nuevo script SQL si ya se aplicó V3.

## Cambios anteriores de V5

- Banner superior verde con el logo y el texto **Transmetro De Guatemala** en azul #243b53, tanto en la plataforma del personal como en el portal ciudadano.
- Menú del personal con su fondo azul anterior #243b53. Permanece visible debajo del banner al desplazar el contenido; en pantallas pequeñas conserva su navegación horizontal y también permanece visible.
- Registro de tarjetas: buscador encima de Tarjetas registradas por nombre, apellido o DPI del titular. Consulta en el servidor, conserva el filtro al cambiar de página o actualizar un estado y muestra 25 tarjetas por página. Limpiar búsqueda vuelve al listado general.
- Reportes: selector inicial independiente para Resumen de líneas, Estaciones, Buses por línea, Recorridos y Bitácora de auditoría. Sólo se consulta y muestra la opción seleccionada. Cada reporte tiene su botón **Imprimir este reporte**; la impresión excluye menú, selector y botones. La auditoría conserva el permiso AUDITORIA_VER y su límite de los últimos 100 registros. También muestra los reportes vacíos con un mensaje.
- Incluye los cambios anteriores. Si ya tienes V3 aplicada en SQL Server, no hay actualización adicional de base de datos para V4/V5.

## Cambios anteriores de V4

- Personal y accesos, y Rutas, estaciones y flota, ahora consultan sólo los totales al entrar. Cada lista se carga al abrirla, con búsqueda en el servidor y páginas de 20 registros. La ficha completa y los formularios se solicitan sólo cuando se seleccionan. Al cerrar una sección se libera su contenido y se cancela la solicitud pendiente para evitar acumular formularios y respuestas tardías.
- Se mantienen las fichas, campos, edición, activación, asignaciones e historial existentes. La búsqueda revisa todos los registros del directorio, no sólo la página visible.
- Se retiraron de las pantallas las explicaciones de estados y de entradas físicas solicitadas. Su explicación permanece en este documento.
- Se incorporó LogoMuni.png sin modificar la imagen en la cabecera y el inicio de sesión. Los fondos y acentos azules se cambiaron al verde del logo (#97D700), conservando la distribución y los colores de avisos/estados.
- El menú ciudadano sólo se presenta con una sesión de tarjeta válida; se oculta en la pantalla de ingreso del número incluso si hay una sesión de empleado abierta.

La captura mostraba que Chrome dejaba de responder. El código anterior generaba todas las fichas, formularios y listas de opciones aunque estuvieran plegadas; esta entrega elimina esa acumulación. La velocidad final también depende de la conexión y del SQL Server de tu equipo.

## Para qué sirve Activar

- **P — Pendiente**: registrado, todavía en preparación.
- **A — Activo**: autorizado para operar.
- **I — Inactivo**: suspendido, por ejemplo, por mantenimiento.

Al activar una línea, el procedimiento valida que tenga estaciones, distancias entre estaciones consecutivas y entre una y dos veces tantos buses como estaciones asignadas. Al activar una estación, valida su línea y operador; al activar un acceso, su guardia. Cambiar a Activo en el editor usa esos mismos procedimientos.

## Rutas, estaciones y flota

Las listas están cerradas al entrar. Abre **Ver líneas**, **Ver estaciones**, **Ver flota**, **Ver parqueos** o **Ver municipalidades**. Cada sección tiene búsqueda y cada registro abre su ficha completa.

- Líneas: datos, municipalidad, estaciones en orden, tiempos, distancias y buses asignados. Puedes editar su información.
- Estaciones: datos, coordenadas, capacidad, estado y todas las líneas a las que pertenece con su orden. Puedes editar sus datos y cambiar su asignación/orden desde esta ficha o desde la línea.
- Flota: código, placa, marca, modelo, año, capacidad, estado, parqueo y línea. Puedes editar el bus y cambiar o quitar su línea mientras no tenga un viaje en curso.
- Parqueos y municipalidades: ficha y edición de sus datos.

Una estación puede pertenecer a varias líneas. Al cambiar una asignación, sólo se mueve la relación seleccionada; las demás se conservan. Cambiar el orden coloca esa estación en la posición indicada y reordena la configuración de la línea sin duplicar posiciones. Los viajes existentes conservan el itinerario con el que fueron creados; la nueva configuración se aplica a los próximos viajes.

Si una reorganización vuelve no consecutivo un tramo, se retira esa distancia para evitar presentar un dato incorrecto. Configura la nueva distancia en la ficha de la línea y revisa los minutos. Si una línea antes activa ya no cumple flota/distancias, queda Pendiente con un mensaje indicando qué revisar. Los límites de flota no se eliminan.

## Mantenimiento de estaciones

En Editar estación elige **Inactivo / mantenimiento**. La relación y el número de orden se conservan; no se elimina la estación ni se modifica su historial.

- Los nuevos viajes no ofrecen estaciones pendientes/inactivas como paradas.
- Los viajes en curso omiten automáticamente esa estación si todavía no registraron su llegada.
- El seguimiento del personal y del ciudadano ocultan esa parada omitida y avanzan a la siguiente disponible.
- Si el bus ya había llegado, se conserva esa visita real y puede terminar sus conteos/salida.
- Al activar de nuevo la estación, los próximos viajes la incluyen en su orden original. En un viaje en curso se reincorpora sólo si el bus aún no pasó su posición; nunca se ordena regresar a una parada anterior.
- Si ya no quedan paradas disponibles, el viaje termina; si no se había registrado ninguna llegada, se cancela. La unidad queda disponible si no tiene otro viaje en curso.

La espera por baja ocupación sigue siendo de cinco minutos desde el conteo. Los tiempos de traslado de estaciones omitidas se siguen sumando porque el trazado mantiene su orden; esto no equivale a calcular una nueva ruta GPS.

## Personal y accesos

Abre **Ver pilotos**, **Ver operadores**, **Ver guardias** o **Ver accesos**, busca y despliega una ficha.

- Pilotos: información personal, contacto, residencia, licencia, actividad e historial educativo. Puedes corregir sus datos, agregar/editar educación y actualizar opcionalmente su documento (se almacena como hash).
- Operadores: información, actividad, estación asignada e historial de asignaciones. Puedes corregir sus datos o cambiar la estación; sustituir al operador de una estación conserva el historial.
- Guardias: información, empresa, actividad, acceso, turno e historial. Puedes corregir sus datos o cambiar acceso/turno.
- Accesos: estación, código, nombre, tipo, descripción, estado y guardias vigentes. Puedes editar esos campos, activar o desactivar el acceso.

No se puede desactivar un piloto con viaje en curso. Para desactivar o trasladar al único guardia de un acceso activo, primero agrega un sustituto o desactiva el acceso. Para desactivar/trasladar un operador responsable de una estación activa, primero sustitúyelo o deja la estación en mantenimiento. Si una estación/acceso está Inactivo y necesita un nuevo responsable, déjalo Pendiente, asigna el personal y luego actívalo.

Los campos de negocio son editables. IDs, fechas automáticas de alta y versiones internas se conservan; los hashes no permiten recuperar el documento original. La edición detecta registros desactualizados para evitar sobrescribir una corrección que otro usuario acaba de guardar.

## Operación y recorridos por línea

Al entrar sólo aparece el selector de línea. Después eliges una acción:

1. Seguimiento y paradas: ubicación por última estación registrada, siguiente estación, destino, estimación y llegada/conteos/salida en la misma tarjeta del bus.
2. Asignar piloto: sólo buses disponibles asignados a esa línea y pilotos libres con licencia vigente. Los pilotos libres no pertenecen previamente a una línea; quedan vinculados mediante el bus asignado.
3. Iniciar recorrido: buses disponibles de esa línea con piloto asignado.
4. Pilotos asignados: sólo asignaciones de sus buses.
5. Alertas de estación.
6. Esperas por baja ocupación.
7. Conteo de estación sin llegada de bus: estaciones activas de esa línea y sus operadores.
8. Historial de conteos por parada.
9. Tiempos de esa línea.
10. Últimos recorridos de esa línea, hasta 100, priorizando los que están en curso.

No se mezclan viajes, buses disponibles, paradas o esperas de otras líneas. El servidor comprueba la relación aunque se modifiquen los parámetros del formulario. Las acciones conservan la línea seleccionada al volver a la pantalla.

Los conteos nuevos de estación guardan su LineaID. Los conteos anteriores que pertenecen a una estación con una única línea se atribuyen a esa línea al migrar. Los anteriores de una estación compartida no tenían esa información: se conservan como conteo físico de la estación y pueden verse en sus líneas correspondientes; no se inventa una atribución histórica.

## Portal ciudadano y datos de prueba

El portal conserva Mi tarjeta, recarga, pago fijo Q2 por línea, cobertura del recorrido, seguimiento filtrado y mapa. El seguimiento omite las estaciones suspendidas que aún no fueron visitadas. El mapa es la imagen de referencia que compartiste.

Las credenciales del SQL de prueba siguen siendo `demo.admin`, `demo.operador`, `demo.auditor`, con contraseña `TransmetroDemo!2026`. Tarjeta: `DEMO-TAR-88000001`. El SQL de prueba usa datos ficticios, incluidos sus minutos y distancias; los registros cargados inicialmente pueden estar Pendiente hasta que los actives.

## Pruebas recomendadas en tu SQL Server

- Editar nombre/código/contacto de cada tipo y comprobar su persistencia.
- Cambiar orden y línea de una estación; verificar relaciones, distancias y posibles mensajes de línea pendiente.
- Iniciar un viaje con estaciones activas 1, 2, 3; desactivar la 2 antes de llegar: la próxima parada debe ser 3 y la 2 no debe aparecer en el seguimiento.
- Reactivar la 2 antes de pasar su posición: vuelve a aparecer. Si ya se pasó, vuelve en el próximo viaje.
- Seleccionar dos líneas distintas y revisar cada acción: ningún viaje, bus disponible, conteo de bus o espera de la otra línea debe aparecer.
- Registrar llegada → pasajeros → salida desde la tarjeta del mismo bus.
- Comprobar que un piloto con viaje en curso y un guardia/operador obligatorio no pueden desactivarse dejando la operación sin responsable.

Las comprobaciones ya ejecutadas se detallan en VERIFICACION.md. La validación final de triggers y transacciones sigue requiriendo tu instancia de SQL Server.
