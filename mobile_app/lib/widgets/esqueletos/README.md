# Carpeta de Widgets: `esqueletos`

## Descripción General

Esta carpeta es vital para la Experiencia de Usuario (UX). Contiene una colección de widgets "placeholder" o "esqueletos" (skeletons).

El propósito de estos widgets es **mostrar una UI falsa e inanimada** mientras los datos reales se están cargando desde el servidor. Todos utilizan el paquete `shimmer` para darles un efecto de brillo animado, lo que comunica al usuario que la aplicación está funcionando y cargando contenido.

Cada esqueleto está diseñado para **imitar la estructura y el diseño** de la tarjeta o pantalla que eventualmente reemplazará.

## Componentes Principales

### `esqueleto_lista_actividad.dart`
* **Widget:** `EsqueletoListaActividad`
* **Propósito:** Simula una lista genérica de `ListTile` con un `Container` a la izquierda (para un icono o avatar).
* **UI:** Muestra 6 `Card`s con placeholders para un icono, una línea de título y una línea de subtítulo.
* **Usado por:**
    * `MiActividadScreen` (para las pestañas de actividad).
    * `VerificacionScreen` (para las listas de moderación).
    * `PantallaInsignias` (mientras se cargan las insignias).
    * `EditarPerfilScreen` (mientras se cargan los datos iniciales del perfil).

### `esqueleto_lista_reportes.dart`
* **Widget:** `EsqueletoListaReportes`
* **Propósito:** Simula una lista de tarjetas de reporte más complejas, como las de `PantallaCercaDeTi`.
* **UI:** Muestra 5 `Card`s con placeholders que simulan un chip de categoría, una línea de título y una línea de subtítulo.
* **Usado por:**
    * `PantallaCercaDeTi` (mientras se buscan reportes cercanos).
    * `PantallaBuscarReporteOriginal` (mientras se buscan reportes para fusionar).

### `esqueleto_lista_notificaciones.dart`
* **Widget:** `EsqueletoListaNotificaciones`
* **Propósito:** Simula una lista de `ListTile` estándar con un `CircleAvatar`.
* **UI:** Muestra 8 `ListTile`s simulados con un círculo a la izquierda y placeholders de texto.
* **Usado por:**
    * `PantallaAlertas` (mientras se cargan las notificaciones).
    * `PantallaMetodosPago` (mientras se cargan las tarjetas guardadas).

### `esqueleto_lista_planes.dart`
* **Widget:** `EsqueletoListaPlanes`
* **Propósito:** Simula las tarjetas de suscripción de `TarjetaPlan`.
* **UI:** Muestra 2 tarjetas grandes que imitan la estructura de un plan: título, precio, 4 líneas de características y un botón de selección.
* **Usado por:**
    * `PantallaPlanesSuscripcion`.

### `esqueleto_mapa.dart`
* **Widget:** `EsqueletoMapa`
* **Propósito:** Simula la pantalla principal `MapaView` durante la carga inicial.
* **UI:** Muestra un `Stack` con placeholders para la `TopSearchBar` (barra superior) y las `AccionesMapa` (botones inferiores), sobre un fondo blanco y con un `CircularProgressIndicator` en el centro.
* **Usado por:**
    * `MapaView` (en el `FutureBuilder` de `reportesFuture`).

### `esqueleto_perfil.dart`
* **Widget:** `EsqueletoPerfil`
* **Propósito:** Simula la pantalla `PerfilScreen` mientras se cargan los datos del `PerfilService`.
* **UI:** Imita la estructura de `PerfilScreen`, mostrando placeholders para `PerfilHeaderCard` (avatar, nombre, puntos), y 4 `ListTile` simulados para las acciones y el estatus.
* **Usado por:**
    * `PerfilScreen`.

### `esqueleto_reporte_detalle.dart`
* **Widget:** `EsqueletoReporteDetalle`
* **Propósito:** Simula la pantalla de detalle de un reporte.
* **UI:** Muestra un contenedor grande para la imagen, placeholders para los chips de categoría/urgencia, título, autor/fecha, barra de acciones (apoyos/comentarios) y 2 placeholders de comentarios.
* **Usado por:**
    * `ReporteDetalleScreen`.
    * `VerificacionDetalleScreen`.
    * `PantallaDetallePendienteVista`.

### `esqueleto_detalle_boleta.dart`
* **Widget:** `EsqueletoDetalleBoleta`
* **Propósito:** Simula la vista de `TarjetaDetalleBoleta`.
* **UI:** Muestra una `Card` grande con placeholders para el título ("Boleta de Venta"), el chip de estado, y múltiples filas de detalle (cliente, pago, total).
* **Usado por:**
    * `PantallaDetalleBoleta`.