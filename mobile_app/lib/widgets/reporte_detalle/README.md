# Carpeta de Widgets: `reporte_detalle`

## Descripción General

[cite_start]Esta es una carpeta de componentes crucial, ya que sus widgets construyen la pantalla de detalle de reporte (`ReporteDetalleScreen` [cite: 37]), que es una de las pantallas más complejas de la aplicación.

Estos widgets se encargan de mostrar la información del reporte, las acciones del usuario, la sección de comentarios y manejar estados visuales especiales.

## Componentes Principales

### `layout_detalle_reporte.dart`

* [cite_start]**Widget:** `LayoutDetalleReporte` [cite: 40]
* **Propósito:** Es el widget de *estructura principal* para `ReporteDetalleScreen`. Organiza todos los demás componentes en un `Column` (para el input fijo) y un `Expanded(ListView)` (para el contenido scrollable).
* **Lógica Clave:**
    * **Manejo de Estado:** Es el primer widget en la jerarquía que maneja los estados visuales del reporte. [cite_start]Comprueba `reporte.estado` y muestra `VistaReporteFusionado` [cite: 45] [cite_start]o `VistaReporteOculto` [cite: 45] en lugar del layout normal si es necesario.
    * [cite_start]**Filtrado de Comentarios:** Separa la `reporte.comentarios` en dos listas: `mergeNotifications` (comentarios del sistema sobre fusiones) y `userComments` (comentarios de usuarios)[cite: 40].
    * [cite_start]**Input Condicional:** Muestra `CampoComentarioInput` [cite: 39] [cite_start]o `PromptLoginComentario` [cite: 39] en la parte inferior solo si el usuario está autenticado y el reporte está en un estado que permite comentarios (ej. 'verificado').
* **Conexiones:**
    * [cite_start]**Usado por:** `ReporteDetalleScreen`[cite: 37].
    * [cite_start]**Usa:** `ReporteHeader` [cite: 42][cite_start], `ReporteActionsBar` [cite: 41][cite_start], `CommentsSection` [cite: 38][cite_start], `vistas_estado_reporte.dart` [cite: 45][cite_start], `campo_comentario.dart` [cite: 39][cite_start], `merge_notification_card.dart`[cite: 43].

### `reporte_header.dart`

* [cite_start]**Widget:** `ReporteHeader` [cite: 42]
* **Propósito:** Muestra toda la información "estática" de un reporte en la parte superior. [cite_start]Es reutilizado por `LayoutDetalleReporte` [cite: 40] [cite_start]y `LayoutDetalleVerificacion`[cite: 52].
* [cite_start]**UI:** Muestra la imagen (si `showImage: true`), chips de categoría/urgencia, título, autor/fecha, descripción, código de reporte, y detalles (distrito, referencia, hora, impacto, tags) usando el helper `_buildInfoRow`[cite: 42].
* **Conexiones:**
    * [cite_start]**Usado por:** `LayoutDetalleReporte` [cite: 40][cite_start], `LayoutDetalleVerificacion`[cite: 52].
    * [cite_start]**Depende de:** `ReporteDetallado` (modelo)[cite: 25].

### `reporte_actions_bar.dart`

* [cite_start]**Widget:** `ReporteActionsBar` [cite: 41]
* **Propósito:** Muestra la barra de interacción social simple: el botón de "Apoyar" y el contador de comentarios.
* **Lógica Clave:**
    * Recibe los contadores (`apoyosCount`, `comentariosCount`) como parámetros.
    * El `TextButton.icon` de "Apoyar" llama al callback `onSupportPressed`.
    * [cite_start]Si el usuario no está autenticado (`AuthNotifier.isAuthenticated` es `false`), el botón "Apoyar" redirige a `/login`[cite: 41].
* **Conexiones:**
    * [cite_start]**Usado por:** `LayoutDetalleReporte`[cite: 40].
    * **Depende de:** `AuthProvider`.
    * [cite_start]**Acciona (vía callbacks):** `_onSupportReport` en `ReporteDetalleScreen`[cite: 37].

### `comments_section.dart`

* [cite_start]**Widget:** `CommentsSection` [cite: 38]
* **Propósito:** Renderiza la lista completa de comentarios de usuarios (`userComments` pasados desde `LayoutDetalleReporte`).
* **UI y Lógica Clave:**
    * [cite_start]Muestra cada `Comentario` [cite: 10] en una `Card` individual.
    * [cite_start]Formatea la `fechaCreacion` del comentario a un formato legible[cite: 38].
    * Muestra un `TextButton.icon` para "apoyar" un comentario (llama a `onSupportComment`).
    * **Menú de Opciones (`PopupMenuButton`):** Muestra un menú (tres puntos) en cada comentario. [cite_start]Las opciones ("Editar", "Eliminar", "Reportar Comentario", "Reportar Usuario") se muestran condicionalmente basándose en los permisos (`isOwner`, `isLider`, `isAdmin`)[cite: 38].
* **Conexiones:**
    * [cite_start]**Usado por:** `LayoutDetalleReporte`[cite: 40].
    * [cite_start]**Depende de:** `Comentario` (modelo)[cite: 10], `AuthProvider`.
    * [cite_start]**Acciona (vía callbacks):** `_showEditCommentDialog`, `_showConfirmDeleteDialog`, `_showReportCommentDialog`, `_showReportUserDialog`, `_onSupportComment` en `ReporteDetalleScreen`[cite: 37].

### `campo_comentario.dart`

* [cite_start]**Widget:** `CampoComentarioInput` y `PromptLoginComentario` [cite: 39]
* **Propósito:** Proporciona la UI para la entrada de comentarios en la parte inferior de la pantalla.
* **Lógica Clave:**
    * [cite_start]`LayoutDetalleReporte` [cite: 40] decide cuál de los dos widgets mostrar.
    * `CampoComentarioInput`: Es el `TextField` y el botón de enviar. Muestra un `CircularProgressIndicator` si `isPosting` es `true`.
    * `PromptLoginComentario`: Es un `ElevatedButton` que se muestra si el usuario no está logueado, invitándolo a `/login`.
* **Conexiones:**
    * [cite_start]**Usado por:** `LayoutDetalleReporte`[cite: 40].
    * [cite_start]**Acciona (vía callbacks):** `_postComentario` en `ReporteDetalleScreen`[cite: 37].

### `vistas_estado_reporte.dart`

* [cite_start]**Widget:** `BannerReporteOculto`, `VistaReporteFusionado`, `VistaReporteOculto` [cite: 45]
* **Propósito:** Muestra vistas especiales que reemplazan o complementan el detalle del reporte.
* **UI:**
    * `BannerReporteOculto`: Un banner amarillo que se muestra *dentro* del layout normal si un admin/autor está viendo su propio reporte oculto.
    * `VistaReporteFusionado`: Una vista de pantalla *completa* que reemplaza el layout. [cite_start]Informa que el reporte es un duplicado y proporciona un botón para navegar al reporte original (`idReporteOriginal`)[cite: 45].
    * `VistaReporteOculto`: Una vista de pantalla *completa* que se muestra si un usuario normal intenta acceder a un reporte oculto.
* **Conexiones:**
    * [cite_start]**Usado por:** `LayoutDetalleReporte`[cite: 40].
    * [cite_start]**Depende de:** `ReporteDetallado` (modelo)[cite: 25].

### `merge_notification_card.dart`

* [cite_start]**Widget:** `MergeNotificationCard` [cite: 43]
* [cite_start]**Propósito:** Una tarjeta con un estilo visual distintivo (azul pálido) diseñada específicamente para mostrar los comentarios generados por el sistema durante una fusión (ej. "Reporte #AP-2025-123 fue fusionado con este...")[cite: 43].
* **Conexiones:**
    * [cite_start]**Usado por:** `LayoutDetalleReporte` (dentro de un `ExpansionTile`)[cite: 40].
    * [cite_start]**Depende de:** `Comentario` (modelo)[cite: 10].