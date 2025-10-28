# Carpeta de Widgets: `verificacion`

## Descripción General

Esta es una carpeta de componentes altamente especializados y cruciales para la funcionalidad de **Líder Vecinal**. [cite_start]Estos widgets construyen las pantallas `VerificacionScreen` [cite: 58] (el panel principal del líder) [cite_start]y `VerificacionDetalleScreen` [cite: 57] (la pantalla de moderación de un reporte).

Estos widgets manejan la carga paginada de datos, la aplicación de filtros complejos y las acciones de moderación (Aprobar, Rechazar, Fusionar).

## Componentes Principales

### `lista_reportes_verificacion.dart`

* [cite_start]**Widget:** `ListaReportesVerificacion` (Stateful) [cite: 53]
* **Propósito:** Es el widget **más complejo e importante** de esta carpeta. [cite_start]Es una lista reutilizable y con estado que renderiza *tanto* la pestaña "Pendientes" como la pestaña "Historial" en `VerificacionScreen`[cite: 58].
* **Lógica Clave:**
    * Recibe un booleano `isHistory` que cambia radicalmente su comportamiento.
    * **Manejo de Estado:** Gestiona su propio estado de paginación (`_currentPage`), si hay más datos (`_hasMore`), estado de carga (`_isLoading`, `_isLoadingMore`), y la lista de reportes (`_reportes`).
    * [cite_start]**Filtros:** Renderiza `FiltrosPendientes` [cite: 49] [cite_start]o `FiltrosHistorial` [cite: 51] según `isHistory`.
    * [cite_start]**Carga de Datos:** Llama a `LiderService.getReportesPendientes` [cite: 6] (si `!isHistory`) [cite_start]o `LiderService.getReportesModerados` [cite: 6] (si `isHistory`), pasando los filtros actuales y la página.
    * [cite_start]**Scroll Infinito:** Usa un `ScrollController` (`_onScroll`) para llamar a `_fetchData` cuando se llega al final de la lista[cite: 53].
    * [cite_start]**Renderizado Condicional:** Renderiza `TarjetaVerificacion` [cite: 61] [cite_start]para reportes pendientes o `TarjetaHistorialModerado` [cite: 60] para el historial.
    * **Manejo de Acciones:** Contiene la lógica (`_handleSolicitarRevision`, `_handleNavigation`) que se pasa como callback a las tarjetas.
* **Conexiones:**
    * [cite_start]**Usado por:** `VerificacionScreen` [cite: 58] (se instancia dos veces, una para cada pestaña).
    * [cite_start]**Depende de:** `LiderService` [cite: 6][cite_start], `ReportePendiente` [cite: 26][cite_start], `ReporteHistorialModerado`[cite: 24], y todos los widgets de esta carpeta.

### `filtros_pendientes.dart`

* [cite_start]**Widget:** `FiltrosPendientes` [cite: 49]
* **Propósito:** Muestra la barra de filtros para la lista de reportes pendientes.
* **UI y Lógica Clave:**
    * Es un widget sin estado que recibe controladores y valores desde `ListaReportesVerificacion`.
    * [cite_start]Muestra un `TextField` (para búsqueda por texto), un `IconButton` (para `sortBy`), `ChoiceChip`s (para `FiltroPendiente`: Todos, Prioritarios, Con Apoyos) y un `DropdownButton` (para Categoría)[cite: 49].
    * [cite_start]Llama a los callbacks (`onSortToggle`, `onFiltroPendienteChanged`, `onCategoriaChanged`) que ejecutan `refreshData()` en el padre[cite: 53].
* **Conexiones:**
    * [cite_start]**Usado por:** `ListaReportesVerificacion`[cite: 53].

### `filtros_historial.dart`

* [cite_start]**Widget:** `FiltrosHistorial` [cite: 51]
* **Propósito:** Muestra la barra de filtros para la lista del historial de moderación.
* **UI y Lógica Clave:**
    * Muestra `ChoiceChip`s para `FiltroHistorialEstado` (Todos, Verificado, Rechazado, Fusionado).
    * Muestra un `TextButton.icon` que muestra el rango de fechas seleccionado (ej. "20 Oct - 27 Oct") o "Seleccionar Fechas". [cite_start]Al tocarlo, llama a `onSelectDateRange`, que abre un `showDateRangePicker` en el padre[cite: 51, 53].
* **Conexiones:**
    * [cite_start]**Usado por:** `ListaReportesVerificacion`[cite: 53].

### `mis_reportes_moderacion_view.dart`

* [cite_start]**Widget:** `MisReportesModeracionView` (Stateful) [cite: 54]
* **Propósito:** Renderiza la tercera pestaña de `VerificacionScreen`: la lista de *contenido* (comentarios o usuarios) que el líder *él mismo* ha reportado.
* **Lógica Clave:**
    * Similar a `ListaReportesVerificacion`, maneja su propio estado de paginación y filtros (`_filtroTipo`, `_startDate`, `_endDate`).
    * [cite_start]**Carga Combinada:** Llama a `LiderService.getMisComentariosReportados` y `LiderService.getMisUsuariosReportados` en paralelo y combina los resultados en una sola lista (`_reportes`), ordenándolos por fecha[cite: 54, 6].
    * [cite_start]Renderiza la lista usando `TarjetaModeracionReporte`[cite: 62].
    * [cite_start]Contiene la lógica `_handleQuitarReporte` para permitir al líder cancelar su propio reporte pendiente[cite: 54].
* **Conexiones:**
    * [cite_start]**Usado por:** `VerificacionScreen`[cite: 58].
    * [cite_start]**Depende de:** `LiderService` [cite: 6][cite_start], `ReporteModeracion` (modelo) [cite: 27][cite_start], `TarjetaModeracionReporte`[cite: 62].

### `tarjeta_verificacion.dart`

* [cite_start]**Widget:** `TarjetaVerificacion` [cite: 61]
* **Propósito:** Tarjeta de UI para un item en la lista de "Pendientes" (`ListaReportesVerificacion`).
* **UI:** Muestra la imagen, título, autor, fecha.
* [cite_start]**UI Clave (Priorización):** Muestra chips destacados para "Premium" (`esPrioritario`) y "Con Apoyos" (`apoyosPendientes > 0`) para ayudar al líder a identificar reportes importantes[cite: 61].
* **Conexiones:**
    * [cite_start]**Usado por:** `ListaReportesVerificacion`[cite: 53].
    * [cite_start]**Depende de:** `ReportePendiente` (modelo)[cite: 26].

### `tarjeta_historial_moderado.dart`

* [cite_start]**Widget:** `TarjetaHistorialModerado` [cite: 60]
* **Propósito:** Tarjeta de UI para un item en la lista de "Historial" (`ListaReportesVerificacion`).
* **UI y Lógica Clave:**
    * Muestra un chip de estado final (`_buildStatusChip`: Verificado, Rechazado, Fusionado).
    * Muestra un botón de "Solicitar Revisión" si `estadoSolicitud` es `null` o `desestimada`.
    * [cite_start]Muestra un chip de "Solicitud Enviada" si `estadoSolicitud` es `pendiente`[cite: 60].
    * [cite_start]Muestra un icono de enlace (`onIrAlOriginal`) si `estado == 'fusionado'`[cite: 60].
* **Conexiones:**
    * [cite_start]**Usado por:** `ListaReportesVerificacion`[cite: 53].
    * [cite_start]**Depende de:** `ReporteHistorialModerado` (modelo)[cite: 24].
    * [cite_start]**Acciona (vía callbacks):** `_handleSolicitarRevision` y `_handleIrAlOriginal` en `ListaReportesVerificacion`[cite: 53].

### `tarjeta_moderacion_reporte.dart`

* [cite_start]**Widget:** `TarjetaModeracionReporte` [cite: 62]
* **Propósito:** Tarjeta de UI para un item en `MisReportesModeracionView`.
* **UI y Lógica Clave:**
    * Muestra si es un reporte de "Comentario" o "Usuario".
    * Muestra el `motivo` y el `contenido` (extracto del comentario o alias del usuario).
    * Muestra el estado (`pendiente` o `resuelto`).
    * [cite_start]Muestra un botón "Quitar" si `estado == 'pendiente'`, permitiendo al líder cancelar su propio reporte[cite: 62].
* **Conexiones:**
    * [cite_start]**Usado por:** `MisReportesModeracionView`[cite: 54].
    * [cite_start]**Depende de:** `ReporteModeracion` (modelo)[cite: 27].

### `layout_detalle_verificacion.dart`

* [cite_start]**Widget:** `LayoutDetalleVerificacion` [cite: 52]
* **Propósito:** Define la estructura visual *dentro* de la pantalla `VerificacionDetalleScreen`.
* [cite_start]**UI:** Es un `CustomScrollView` que contiene `ReporteHeader` (con `showImage: true`) y `MapaVerificacion`[cite: 52, 42, 55].
* **Conexiones:**
    * [cite_start]**Usado por:** `VerificacionDetalleScreen`[cite: 57].
    * [cite_start]**Usa:** `ReporteHeader` [cite: 42][cite_start], `MapaVerificacion`[cite: 55].

### `acciones_moderacion.dart`

* [cite_start]**Widget:** `AccionesModeracion` [cite: 46]
* **Propósito:** Es la barra de botones (`BottomAppBar`) fija en la parte inferior de `VerificacionDetalleScreen`.
* **UI:** Muestra los 3 botones principales: "Rechazar" (rojo), "Fusionar" (secundario) y "Aprobar" (primario). [cite_start]Muestra un spinner en "Aprobar" si `isLoading` es `true`[cite: 46].
* **Conexiones:**
    * [cite_start]**Usado por:** `VerificacionDetalleScreen`[cite: 57].
    * [cite_start]**Acciona (vía callbacks):** `_moderarReporte` y `_iniciarFusion` en `VerificacionDetalleScreen`[cite: 57].

### `mapa_verificacion.dart`

* [cite_start]**Widget:** `MapaVerificacion` (Stateful) [cite: 55]
* **Propósito:** Muestra un mini-mapa *no interactivo* que se centra en la ubicación de un reporte.
* **UI:** Muestra un `FlutterMap` con un `Marker` fijo en `initialCenter`. [cite_start]Incluye botones de zoom y recentrado, pero deshabilita el drag/zoom por gestos [cite: 55] [cite_start](Aunque el código actual `mapa_verificacion.dart` [cite: 55] [cite_start]no parece tener la interacción deshabilitada, `cuerpo_detalle_verificacion.dart` [cite: 50] podría estar en una versión anterior. [cite_start]El layout `layout_detalle_verificacion.dart` [cite: 52] usa el mapa directamente).
* **Conexiones:**
    * [cite_start]**Usado por:** `LayoutDetalleVerificacion` [cite: 52] [cite_start]y `PantallaDetallePendienteVista`[cite: 28].

### `dialogo_solicitud_revision.dart`

* [cite_start]**Widget:** `DialogoSolicitudRevision` (Stateful) [cite: 50]
* **Propósito:** Es el `AlertDialog` que se muestra cuando un líder presiona "Solicitar Revisión" en el historial.
* **Lógica Clave:**
    * Muestra un `TextFormField` para que el líder escriba el `motivo` de la revisión.
    * [cite_start]Incluye `ActionChip`s ("Corregir datos", "Reevaluar estado") para autocompletar el motivo[cite: 50].
    * [cite_start]Al presionar "Enviar Solicitud", valida el formulario y hace `Navigator.pop(context, motivo)`, devolviendo el string del motivo a `ListaReportesVerificacion`[cite: 50, 53].
* **Conexiones:**
    * [cite_start]**Usado por:** `ListaReportesVerificacion` (mostrado mediante `showDialog`)[cite: 53].
    * [cite_start]**Depende de:** `ReporteHistorialModerado` (modelo)[cite: 24].