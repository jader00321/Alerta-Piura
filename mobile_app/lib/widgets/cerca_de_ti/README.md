# Carpeta de Widgets: `cerca_de_ti`

## Descripción General

Esta carpeta contiene los widgets especializados que construyen la pantalla "Cerca de Ti" (`PantallaCercaDeTi`). Su propósito es mostrar al usuario una lista de reportes (tanto pendientes como verificados) que están geográficamente cerca de su ubicación actual, permitiéndoles filtrar esta lista e interactuar con reportes pendientes.

## Componentes Principales

### `tarjeta_reporte_cercano.dart`

* **Widget:** `TarjetaReporteCercano`
* **Propósito:** Es la tarjeta de UI principal para cada ítem en la lista "Cerca de Ti". Muestra un resumen visual de un `ReporteCercano`.
* **Lógica Clave y UI:**
    * Muestra la imagen del reporte, título, categoría, autor, fecha y distancia (ej. `~250m`).
    * Muestra chips de estado ("Pendiente" o "Verificado") y de "Urgencia".
    * **Lógica de Interacción (Botón Dinámico):** Este widget contiene la lógica de UI más importante de la pantalla. Muestra un botón de acción diferente basado en el estado del reporte pendiente y el usuario:
        1.  **Botón "Unirme (+X)":** Se muestra si `reporte.puedeUnirse` es `true`. Al tocarlo, llama al callback `onJoinTap`, que está conectado a `_handleJoinReport` en `PantallaCercaDeTi`.
        2.  **Botón "Unido (+X)":** Se muestra si `reporte.usuarioActualUnido` es `true`. Al tocarlo, llama a `onUnjoinTap`, conectado a `_handleUnjoinReport`.
        3.  **Botón "Es tu reporte":** Se muestra (deshabilitado) si el usuario es el autor del reporte.
    * Maneja los estados `isJoining` y `isUnjoining` para mostrar un `CircularProgressIndicator` en los botones mientras se procesa la acción.
* **Conexiones:**
    * **Usado por:** `PantallaCercaDeTi` (dentro de un `ListView.builder`).
    * **Depende de:** `ReporteCercano` (modelo).
    * **Acciona (vía callbacks):** `ReporteService.unirseReportePendiente` y `ReporteService.quitarApoyoPendiente`.

### `panel_filtros_cercanos.dart`

* **Widget:** `PanelFiltrosCercanos`
* **Propósito:** Es el panel modal (`DraggableScrollableSheet`) que se desliza desde abajo para permitir al usuario filtrar la lista de reportes cercanos.
* **Lógica Clave y UI:**
    * Maneja un estado local (`_filtrosSeleccionados`) que se clona desde los `filtrosActuales` pasados por la pantalla.
    * Usa `ChoiceChip` y `FilterChip` para construir secciones de filtro por:
        * Estado (`Todos`, `Verificado`, `Pendiente`).
        * Categoría (poblado dinámicamente desde `categoriasDisponibles`).
        * Urgencia (`Todas`, `Baja`, `Media`, `Alta`).
        * Fecha de Creación (`Cualquier fecha`, `Últimas 24 horas`, etc.).
    * Al presionar "Aplicar", devuelve el objeto `_filtrosSeleccionados` a `PantallaCercaDeTi` a través del callback `onAplicarFiltros`.
* **Conexiones:**
    * **Usado por:** `PantallaCercaDeTi` (mostrado con `showModalBottomSheet`).
    * **Depende de:** `FiltrosCercanos` (clase de `ReporteService`) y `Categoria` (modelo).