# Módulo de Modelos de Datos (`lib/models`)

Este directorio contiene todas las clases de modelo (POJOs/DTOs) de la aplicación.

Un **modelo** es una clase Dart que define la estructura de un objeto. Su propósito principal es tomar los datos "crudos" en formato JSON que envía la API (desde `lib/api`) y convertirlos en un objeto Dart fuertemente tipado, facilitando su uso seguro en el **Frontend** y en los **Providers**.

Cada modelo incluye un constructor `factory .fromJson(Map<String, dynamic> json)` que realiza esta "deserialización". Algunos factories incluyen lógica adicional para manejar valores nulos, conversiones de tipo (ej. `String` a `int`), o parseo de formatos específicos (ej. GeoJSON a `LatLng`, fechas ISO a `DateTime`).

## Flujo de Uso de los Modelos

1.  **Llamada a la API:** El **Frontend** (ej. una pantalla) o un **Provider** necesita datos. Llama a una función en un **Servicio API** (ej. `ReporteService().getReporteById(id)`).
2.  **Petición HTTP:** El **Servicio API** realiza la petición HTTP al **Backend**.
3.  **Respuesta JSON:** El **Backend** responde con los datos en formato JSON.
4.  **Deserialización:** El **Servicio API** recibe el JSON. Dentro de la función del servicio, se llama al constructor `factory .fromJson()` del modelo correspondiente (ej. `ReporteDetallado.fromJson(jsonResponse)`).
5.  **Objeto Dart:** El factory `.fromJson()` parsea el JSON y crea una instancia del **Modelo Dart** (ej. un objeto `ReporteDetallado`).
6.  **Retorno al Llamador:** El **Servicio API** devuelve este objeto **Modelo Dart** al **Frontend** o **Provider** que lo llamó.
7.  **Uso en la UI:** El **Frontend** ahora tiene un objeto Dart tipado y puede acceder a sus propiedades de forma segura (ej. `reporteDetallado.titulo`, `reporteDetallado.comentarios.length`) para mostrar la información en la pantalla.

## Agrupación de Modelos y Quién los Usa

Los modelos se pueden agrupar por su funcionalidad principal y los servicios/pantallas que típicamente los utilizan:

### 1. Modelos de Reportes (Usados por `ReporteService`, `PerfilService`, `LiderService`, Pantallas de Mapa/Detalle/Perfil)

-   **`reporte_model.dart` (`Reporte`):**
    * **Usado por:** `ReporteService().getAllReports()`.
    * **Consumido por:** `MapaScreen` para mostrar marcadores básicos.
    * **Contiene:** ID, título, ubicación (`LatLng`), categoría, `esPrioritario`.
-   **`reporte_cercano_model.dart` (`ReporteCercano`):**
    * **Usado por:** `ReporteService().getReportesCercanos()`.
    * **Consumido por:** Pantalla/Widget que muestra reportes cercanos (lista o mapa).
    * **Contiene:** Datos básicos + distancia, autor, `apoyosPendientes`, `usuarioActualUnido`.
-   **`reporte_detallado_model.dart` (`ReporteDetallado`):**
    * **Usado por:** `ReporteService().getReporteById()`.
    * **Consumido por:** `ReporteDetalleScreen`.
    * **Contiene:** **Toda** la información del reporte, incluyendo la lista anidada de `Comentario`.
-   **`reporte_resumen_model.dart` (`ReporteResumen`):**
    * **Usado por:** `PerfilService().getMisReportes()`, `getMisApoyos()`, `getMisComentarios()`, `SeguimientoService().getMisReportesSeguidos()`.
    * **Consumido por:** Las diferentes pestañas/listas en `PerfilScreen` o `ActividadScreen`.
    * **Contiene:** Datos resumidos para mostrar en listas (ID, título, estado, fecha, foto, etc.).
-   **`comentario_model.dart` (`Comentario`):**
    * **Usado por:** `ReporteDetallado.fromJson()` (deserializa la lista anidada).
    * **Consumido por:** `ReporteDetalleScreen` para mostrar la lista de comentarios.
    * **Contiene:** ID, texto, autor, fecha, conteo de apoyos.
-   **`categoria_model.dart` (`Categoria`):**
    * **Usado por:** `ReporteService().getCategorias()`.
    * **Consumido por:** `CrearReporteScreen` (para el selector de categorías), filtros del mapa.
    * **Contiene:** ID y nombre de la categoría.

### 2. Modelos de Moderación (Usados por `LiderService`, Panel de Moderación)

-   **`reporte_pendiente_model.dart` (`ReportePendiente`):**
    * **Usado por:** `LiderService().getReportesPendientes()`.
    * **Consumido por:** La lista principal del `PanelModeracionScreen`.
    * **Contiene:** Resumen optimizado para la cola de moderación.
-   **`reporte_historial_moderado_model.dart` (`ReporteHistorialModerado`):**
    * **Usado por:** `LiderService().getReportesModerados()`.
    * **Consumido por:** La pestaña "Historial" del `PanelModeracionScreen`.
    * **Contiene:** Resumen para reportes ya procesados (incluye `idReporteOriginal` si fue fusionado).
-   **`reporte_moderacion_model.dart` (`ReporteModeracion`, `TipoReporteModeracion`):**
    * **Usado por:** `LiderService().getMisComentariosReportados()`, `getMisUsuariosReportados()`.
    * **Consumido por:** Las pestañas de "Mis Reportes de Moderación" en el perfil del líder.
    * **Contiene:** Detalles de un reporte *sobre* un comentario o usuario (motivo, contenido reportado, etc.).
-   **`solicitud_revision_model.dart` (`SolicitudRevision`):**
    * **Usado por:** `LiderService().getMisSolicitudesRevision()`.
    * **Consumido por:** La pestaña "Mis Solicitudes" en el perfil del líder.
    * **Contiene:** ID, estado y título del reporte asociado a la solicitud.

### 3. Modelos de Perfil y Usuario (Usados por `PerfilService`, `AuthService`, Pantallas de Perfil/Configuración)

-   **`perfil_model.dart` (`Perfil`):**
    * **Usado por:** `PerfilService().getMiPerfil()`. También parcialmente poblado desde `AuthService().login()`.
    * **Consumido por:** `PerfilScreen`, `ConfiguracionScreen`, y potencialmente usado por `AuthNotifier`.
    * **Contiene:** Datos completos del usuario (nombre, email, puntos, `List<Insignia>`, estado de suscripción).
-   **`notificacion_model.dart` (`Notificacion`):**
    * **Usado por:** `PerfilService().getMisNotificaciones()`.
    * **Consumido por:** `NotificacionesScreen`.
    * **Contiene:** Título, cuerpo, estado leído y fecha de una notificación.
-   **`zona_segura_model.dart` (`ZonaSegura`):**
    * **Usado por:** `PerfilService().getMisZonasSeguras()`.
    * **Consumido por:** `ZonasSegurasScreen`.
    * **Contiene:** ID, nombre, radio y centro (`LatLng`) de una zona definida por el usuario.

### 4. Modelos de Gamificación (Usados por `GamificacionService`, `PerfilService`, Pantalla de Insignias)

-   **`insignia_model.dart` (`Insignia`):**
    * **Usado por:** `Perfil.fromJson()` (deserializa la lista anidada dentro del perfil).
    * **Consumido por:** `PerfilScreen` para mostrar las insignias ganadas.
    * **Contiene:** Datos básicos de una insignia (nombre, descripción, icono).
-   **`insignia_detalle_model.dart` (`InsigniaDetalle`, `ProgresoInsignias`):**
    * **Usado por:** `GamificacionService().getProgresoInsignias()`.
    * **Consumido por:** `InsigniasScreen`.
    * **Contiene:** `ProgresoInsignias` agrupa los puntos del usuario y una `List<InsigniaDetalle>`. `InsigniaDetalle` incluye `isEarned` para saber si ya se ganó.

### 5. Modelos de Suscripción y Pagos (Usados por `ServicioSuscripcion`, `MetodoPagoService`, `PerfilService`, Pantallas de Planes/Pagos)

-   **`plan_suscripcion_model.dart` (`PlanSuscripcion`):**
    * **Usado por:** `ServicioSuscripcion().getPlanes()`.
    * **Consumido por:** `PlanesScreen`.
    * **Contiene:** ID, nombre, descripción y precio de un plan.
-   **`metodo_pago_model.dart` (`MetodoPago`):**
    * **Usado por:** `MetodoPagoService().listarMetodos()`.
    * **Consumido por:** `MetodosPagoScreen`.
    * **Contiene:** ID, tipo, últimos 4 dígitos, expiración y si es predeterminado.
-   **`historial_pago_model.dart` (`HistorialPago`):**
    * **Usado por:** `PerfilService().getHistorialPagos()`.
    * **Consumido por:** La lista en `HistorialPagosScreen`.
    * **Contiene:** Resumen de una transacción (ID, monto, estado, fecha, plan).
-   **`boleta_detalle_model.dart` (`BoletaDetalle`):**
    * **Usado por:** `PerfilService().getDetalleBoleta()`.
    * **Consumido por:** `BoletaDetalleScreen`.
    * **Contiene:** Detalles completos de una transacción (incluye ID de pasarela, datos del usuario, etc.).

### 6. Modelos de Chat y Estadísticas (Usados por `ReporteService`, `PerfilService`, `AnaliticasService`, Pantallas de Chat/Estadísticas)

-   **`chat_message_model.dart` (`ChatMessage`):**
    * **Usado por:** `ReporteService().getChatHistory()`.
    * **Consumido por:** `ChatScreen` (del líder).
    * **Contiene:** ID, remitente, texto y timestamp de un mensaje.
-   **`conversacion_model.dart` (`Conversacion`):**
    * **Usado por:** `PerfilService().getMisConversaciones()`.
    * **Consumido por:** La lista de chats disponibles para el líder.
    * **Contiene:** ID y título del reporte asociado al chat.
-   **`estadisticas_model.dart` (`EstadisticasResumen`, `DatoGrafico`):**
    * **Usado por:** `PerfilService().getMisEstadisticasResumen()`, `getMisReportesPorCategoria()`, `AnaliticasService().getReportesPorCategoria()`, `getReportesPorDistrito()`, `getTendenciaReportes()`.
    * **Consumido por:** `PerfilScreen` (resumen), `PanelAnaliticoScreen` (gráficos).
    * **Contiene:** `EstadisticasResumen` (conteos totales), `DatoGrafico` (par nombre/valor genérico para gráficos).