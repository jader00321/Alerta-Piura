# Carpeta de Lógica de Negocio: `services`

## 💎 Descripción General

Esta carpeta contiene servicios que manejan lógica de negocio compleja, tareas de fondo y comunicación persistente. A diferencia de `lib/api`, que se enfoca puramente en llamadas HTTP (obtener/enviar datos), la carpeta `services` orquesta procesos más complejos.

Estos servicios son el "cerebro" de las características más avanzadas de la aplicación.

##  Componentes Principales

### `background_service.dart`

* **Propósito:** Gestionar la funcionalidad de la **Alerta SOS** en un hilo (Isolate) separado del hilo principal de la UI.
* **Herramientas Clave:** `flutter_background_service`, `geolocator`, `flutter_local_notifications`.
* **Cómo Funciona:**
    1.  **Inicialización:** `initializeBackgroundService()` se llama en `main.dart`. Configura el servicio para ejecutarse en modo *Foreground* en Android (requerido para acceso a ubicación en segundo plano).
    2.  **Punto de Entrada:** `onStart` es la función que se ejecuta en el nuevo Isolate. Inicializa `SosTrackingService` y escucha eventos de la UI.
    3.  **Invocación:** La UI (ej. `MapaView`) **no** llama directamente a este servicio. En su lugar, usa `FlutterBackgroundService().invoke('startSosTracking', ...)`.
    4.  **Lógica del Servicio (`SosTrackingService`):**
        * **`startTracking`:** Al recibir el evento, obtiene la ubicación GPS actual, llama a `SosService.activateSos` (de `lib/api`) para registrar la alerta en el backend, y recibe un `alertId`.
        * **Timers:** Inicia dos `Timer`s:
            * `_countdownTimer`: (Cada 1 seg) Reduce el tiempo restante y actualiza la notificación persistente (ej. "Tiempo restante: 09:59"). Envía `service.invoke('updateTimer', ...)` a la UI.
            * `_locationTimer`: (Cada 15 seg) Obtiene la nueva ubicación GPS y llama a `SosService.addLocationUpdate` (de `lib/api`).
        * **Detención:** La función `stopTracking` se puede llamar de 3 maneras:
            1.  `'stopSosFromUI'`: El usuario presiona el botón en la app. `byUser` es `true`, por lo que llama a `SosService.deactivateSos`.
            2.  `'serverForceStop'`: Un evento de socket (admin) detiene el SOS. `byUser` es `false`, por lo que *no* llama a la API (ya se hizo en el backend).
            3.  Temporizador llega a 0: `_countdownTimer` llama a `stopTracking(byUser: true)`.

### `socket_service.dart`

* **Propósito:** Gestionar la conexión WebSocket en tiempo real con el backend usando `socket_io_client`. Es un **Singleton**.
* **Herramientas Clave:** `socket_io_client`, `StreamController.broadcast`.
* **Cómo Funciona:**
    1.  **Conexión y Autenticación:** El `AuthNotifier` (o `SplashScreen`), después de un login exitoso, llama a `SocketService().connect(token)`. El token JWT se pasa en la *query* de la conexión, permitiendo al backend autenticar el socket inmediatamente.
    2.  **Emitters (App -> Servidor):**
        * `emit('join-chat-room', ...)`: Usado por `ChatScreen` para unirse a la sala de un reporte.
        * `emit('send-message', ...)`: Usado por `ChatScreen` para enviar un mensaje.
    3.  **Listeners (Servidor -> App):**
        * `on('receive-message')`: Escuchado por `ChatScreen` para recibir nuevos mensajes en vivo.
        * `on('notification')`: Un listener global que recibe notificaciones push (ej. "Nuevo comentario"). Llama a `NotificationService.showNotification` para mostrar la alerta localmente.
        * `on('stopSos')`: Un listener global. Cuando un admin detiene un SOS, el servidor emite este evento. El `SocketService` lo captura y lo pasa a su `_stopSosController` (un `StreamController.broadcast`). `main.dart` escucha este stream y notifica al `BackgroundService`.

### `notification_service.dart`

* **Propósito:** Servicio Singleton para manejar la **creación y la interacción** con notificaciones locales (del sistema operativo).
* **Herramientas Clave:** `flutter_local_notifications`.
* **Cómo Funciona:**
    1.  **Inicialización:** `main.dart` llama a `initialize(navigatorKey)`.
    2.  **Paso de Clave:** Recibe y almacena la `navigatorKey`. Esto es **fundamental** para la navegación al tocar notificaciones.
    3.  **Canales de Android:** Crea los canales de notificación necesarios (`_generalChannel`, `_reportChannel`, `_sosChannel`). El `_sosChannel` es vital para que `BackgroundService` pueda mostrar su notificación persistente.
    4.  **Callback `_onNotificationTapped`:** Este es el "cerebro" de la interacción. Cuando el usuario toca una notificación (incluso si la app estaba cerrada), esta función se ejecuta. Parsea el `payload` (un JSON string) y usa la `_navigatorKey` almacenada para navegar a la pantalla correcta (ej. a `/reporte_detalle` con el ID del reporte).
    5.  **`showNotification`:** Método público usado por `SocketService` para mostrar notificaciones recibidas en tiempo real.

### `servicio_pdf.dart`

* **Propósito:** Generar un archivo PDF de las analíticas del lado del cliente.
* **Herramientas Clave:** `pdf`, `path_provider`, `intl`.
* **Cómo Funciona:**
    1.  **Invocación:** `PantallaPanelAnalitico` llama a `generarInformeAnalitico(data)`.
    2.  **Carga de Fuentes:** Carga las fuentes `Roboto-Regular.ttf` y `Roboto-Bold.ttf` desde los `assets/` (definidos en `pubspec.yaml`). Esto es **obligatorio** para que el paquete `pdf` pueda renderizar texto.
    3.  **Construcción del PDF:** Usa los widgets del paquete `pdf` (ej. `pw.MultiPage`, `pw.TableHelper.fromTextArray`) para construir el documento en memoria, formateando las tablas con los datos recibidos.
    4.  **Guardado:**
        * Obtiene el directorio de documentos de la app usando `path_provider` (`getApplicationDocumentsDirectory`).
        * Crea un subdirectorio `Informes` si no existe.
        * Guarda el archivo PDF en ese directorio con un nombre único (ej. `Reporte_Analitico_20251027_1403.pdf`).
    5.  **Retorno:** Devuelve el objeto `File` a `PantallaPanelAnalitico`, que luego usa `open_file` para mostrarlo.