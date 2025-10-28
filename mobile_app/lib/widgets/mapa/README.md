# Carpeta de Widgets: `mapa`

## Descripción General

Esta es una de las carpetas de widgets más importantes de la aplicación. Contiene todos los componentes de UI reutilizables que conforman la pantalla principal del mapa (`MapaView`).

Estos widgets manejan la renderización del mapa, la clusterización de marcadores, las acciones flotantes (incluyendo la compleja lógica del botón SOS), los paneles de filtro y las hojas de resumen que aparecen al interactuar con el mapa.

## Componentes Principales

### `capa_mapa_base.dart`

* **Widget:** `CapaMapaBase`
* **Propósito:** Es el widget fundamental que renderiza el mapa de `flutter_map`, la capa de tiles de OpenStreetMap y, lo más importante, la capa de marcadores clusterizados.
* **UI y Lógica Clave:**
    * Utiliza un `FutureBuilder` para esperar a que `reportesFuture` (la lista de reportes desde la API) se resuelva.
    * Renderiza un `MarkerClusterLayerWidget` que agrupa automáticamente los marcadores (`Marker`) cuando están muy juntos, mostrando un círculo con un número.
    * Cada `Marker` individual es un `GestureDetector` que, al ser tocado, llama al callback `onShowReportSummary`.
    * **Estilo Dinámico:** Utiliza una función interna `_getCategoryColor` para asignar un color diferente al pin de ubicación (`Icons.location_pin`) basado en la categoría del reporte (ej. "Delito" es rojo).
    * Muestra un `Icon(Icons.star)` superpuesto en el marcador si el reporte `esPrioritario`.
* **Conexiones:**
    * **Usado por:** `MapaView`.
    * **Depende de:** `Reporte` (modelo), `MapController`.

### `acciones_mapa.dart`

* **Widget:** `AccionesMapa`
* **Propósito:** Organiza todos los `FloatingActionButton` (FAB) que se superponen al mapa.
* **UI y Lógica Clave:**
    * Organiza los botones en una `Column` con dos `Row`s para lograr el diseño dividido (filtros a la izquierda, acciones a la derecha).
    * Muestra botones simples para "Filtros" (`onShowFilterSheet`), "Mi Ubicación" (`onCenterOnUser`) y "Reportar" (`onCreateReport`).
    * **Lógica del Botón SOS (Compleja):** Este es el componente más dinámico.
        1.  **Estado:** Recibe `isSosActive` (bool) y `sosRemainingSeconds` (int) como parámetros.
        2.  **Permisos:** Comprueba `authNotifier.canUseSos` (si es Premium/Reportero).
        3.  **UI Dinámica:**
            * Si `isSosActive` es `true`, el botón es rojo brillante y muestra el `sosRemainingSeconds` formateado como un temporizador (ej. "09:58").
            * Si `isSosActive` es `false` y `canActivateSos` es `true`, el botón es rojo pálido con el icono `Icons.sos`.
            * Si `canActivateSos` es `false`, el botón es gris y deshabilitado.
        4.  **Acción (`onTap`):**
            * Si está activo, llama a `onDeactivateSos` (que muestra un diálogo de confirmación en `MapaView`).
            * Si está inactivo y tiene permisos, llama a `onActivateSos` (que inicia el `BackgroundService`).
            * Si está inactivo y no tiene permisos, muestra un `AlertDialog` que ofrece navegar a la pantalla de planes (`/subscription_plans`).
* **Conexiones:**
    * **Usado por:** `MapaView`.
    * **Depende de:** `AuthProvider` (para permisos SOS).
    * **Acciona (vía callbacks):** Funciones `_showFilterSheet`, `_centerOnUserLocation`, `_activateSos`, `_deactivateSosFromUI` en `MapaView`.

### `indicador_riesgo.dart`

* **Widget:** `IndicadorRiesgo`
* **Propósito:** Muestra el nivel de riesgo percibido del área visible actual del mapa.
* **UI y Lógica Clave:**
    * Recibe un `riesgoScore` (int) como parámetro.
    * Utiliza una función interna `_getRiskLevel` que mapea el puntaje a un color y una etiqueta (ej. 40+ = Rojo, "Zona Peligrosa").
    * Usa un `AnimatedSwitcher` para cambiar suavemente entre los diferentes niveles de riesgo (color y texto) cuando el puntaje cambia.
* **Conexiones:**
    * **Usado por:** `MapaView`.
    * **Depende de:** El puntaje de riesgo calculado por `ReporteService.getRiesgoZona`.

### `panel_filtros_avanzados.dart`

* **Widget:** `PanelFiltrosAvanzados` (Stateful)
* **Propósito:** Es el panel modal (`DraggableScrollableSheet`) que se desliza desde abajo para permitir al usuario filtrar los reportes en el mapa.
* **UI y Lógica Clave:**
    * Carga su propia lista de `Categoria`s desde `ReporteService`.
    * Maneja un estado local (`_filtrosSeleccionados`) que se inicializa con `filtrosIniciales` del `MapaView`.
    * Usa `ChoiceChip` (para selección única como "Estado" y "Rango de Fechas") y `FilterChip` (para "Categorías", que permite seleccionar/deseleccionar).
    * Al presionar "Aplicar", llama al callback `onAplicarFiltros` pasando el `_filtrosSeleccionados` local a `MapaView`.
* **Conexiones:**
    * **Usado por:** `MapaView` (se muestra mediante `_showFilterSheet`).
    * **Depende de:** `ReporteService.getCategorias`.

### `pin_pulsante.dart`

* **Widget:** `PinPulsante` (Stateful)
* **Propósito:** Widget puramente visual que se coloca en el centro de `MapaView` para indicar el punto exacto que se está usando para calcular el riesgo de zona.
* **UI y Lógica Clave:**
    * Es un `StatefulWidget` que usa un `AnimationController` con `repeat(reverse: true)`.
    * Muestra un `Icon(Icons.location_pin)` estático.
    * Detrás del pin, un `AnimatedBuilder` dibuja un círculo cuyo tamaño y opacidad están vinculados al `_controller.value`, creando un efecto de "pulsación" o "radar".
    * Está envuelto en `IgnorePointer` para que no bloquee los gestos del mapa (como arrastrar o hacer zoom).
* **Conexiones:**
    * **Usado por:** `MapaView` (dentro del `Stack` principal).

### `report_summary_sheet.dart`

* **Widget:** `ReportSummarySheet`
* **Propósito:** Muestra un breve resumen de un reporte en un `ModalBottomSheet` cuando un usuario toca un marcador en el mapa.
* **UI y Lógica Clave:**
    * Muestra el `reporte.titulo`, el `reporte.categoria` como un `Chip`, y un extracto de la descripción (máx. 3 líneas).
    * Contiene un único botón "Ver Detalles y Comentarios" que navega a la pantalla completa `ReporteDetalleScreen` (`/reporte_detalle`), pasando el `reporte.id` como argumento.
* **Conexiones:**
    * **Usado por:** `MapaView` (se muestra mediante `_showReportSummary`).
    * **Depende de:** `Reporte` (modelo).
    * **Navega a:** `ReporteDetalleScreen`.