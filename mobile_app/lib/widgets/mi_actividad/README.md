# Carpeta de Widgets: `mi_actividad`

## Descripción General

Esta carpeta contiene los widgets que construyen las vistas de lista para la pantalla "Mi Actividad" (`MiActividadScreen`), la cual es visible para ciudadanos y líderes (aunque `VerificacionScreen` es la principal para líderes).

El componente clave aquí es `ActivityListView`, un widget reutilizable que renderiza diferentes tipos de listas de actividad (Mis Reportes, Mis Apoyos, etc.) usando una tarjeta unificada, `TarjetaActividad`.

## Componentes Principales

### `activity_list_view.dart`

* **Widget:** `ActivityListView`
* **Propósito:** Un widget **reutilizable** que gestiona la renderización de las listas en las pestañas de `MiActividadScreen`. Es un componente sin estado que recibe toda su lógica y datos del padre.
* **UI y Lógica Clave:**
    * Recibe un `enum Fetcher` (`misReportes`, `misApoyos`, etc.) que le indica qué tipo de lista está mostrando.
    * Maneja la UI para los estados de carga (`isLoading` y `reportes.isEmpty`) mostrando `EsqueletoListaActividad`, y el estado de lista vacía mostrando un mensaje centrado.
    * Renderiza la lista usando `ListView.builder` y `RefreshIndicator` (que llama al callback `onRefresh`).
    * **Lógica Condicional:** Pasa un `trailingAction` (un botón "Cancelar") a `TarjetaActividad` *únicamente* si `fetcher == Fetcher.misReportes` y el reporte está `pendiente_verificacion`.
* **Conexiones:**
    * **Usado por:** `MiActividadScreen` (para 4 de sus pestañas).
    * **Depende de:** `ReporteResumen` (modelo), `TarjetaActividad`.
    * **Acciona (vía callbacks):** `_fetchAllData`, `_handleCancelarReporte`, `_handleNavigateToDetail` en `MiActividadScreen`.

### `tarjeta_actividad.dart`

* **Widget:** `TarjetaActividad`
* **Propósito:** Es la **tarjeta unificada** para *todas* las listas de `ActivityListView`. Es un widget inteligente que adapta su apariencia visual basándose en el `Fetcher` que recibe.
* **UI y Lógica Clave:**
    * Muestra información común: imagen (si existe), `_buildStatusChip` (estado del reporte) y título.
    * **UI Contextual:**
        * Si `fetcher == Fetcher.misReportes`: Muestra chips de "Categoría" y "Urgencia", y el "Distrito".
        * Si `fetcher != Fetcher.misReportes`: Muestra el "Autor" original del reporte.
    * **Fila Contextual:** Llama a `_buildContextualRow` que renderiza una fila especial según el `fetcher`:
        * `misApoyos`: Muestra "Apoyaste este reporte" con un icono de "like".
        * `misSeguimientos`: Muestra "Estás siguiendo este reporte" con un icono de "bookmark".
        * `misComentarios`: Muestra un extracto de `reporte.miComentario`.
        * `misReportes`: No muestra nada.
    * Acepta un `trailingAction` opcional, que se usa para mostrar el botón "Cancelar" pasado desde `ActivityListView`.
* **Conexiones:**
    * **Usado por:** `ActivityListView`.
    * **Depende de:** `ReporteResumen` (modelo).

### `solicitudes_revision_view.dart`

* **Widget:** `SolicitudesRevisionView`
* **Propósito:** Widget sin estado que renderiza la pestaña "Revisiones" en `MiActividadScreen` (visible solo para Líderes).
* **UI y Lógica Clave:**
    * Similar a `ActivityListView`, maneja estados de carga (`isLoading`) y lista vacía.
    * Renderiza una lista de `SolicitudRevision`.
    * Cada ítem es un `ListTile` que muestra el `solicitud.titulo` del reporte, la fecha de solicitud y un `Chip` con el estado de la solicitud (`pendiente`, `aprobada`, `desestimada`).
* **Conexiones:**
    * **Usado por:** `MiActividadScreen` (en la última pestaña, si es líder).
    * **Depende de:** `SolicitudRevision` (modelo).
    * **Acción:** `onTap` en un `ListTile` navega a `/reporte_detalle` usando el `solicitud.idReporte`.