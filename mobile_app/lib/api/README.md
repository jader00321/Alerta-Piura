# Módulo de Servicios API (`lib/api`)

Este directorio contiene todos los servicios que interactúan directamente con el backend de la aplicación. Cada clase de servicio agrupa un conjunto de endpoints de la API relacionados con una entidad o funcionalidad específica (ej. autenticación, reportes, perfil).

El objetivo de estos servicios es encapsular la lógica de las llamadas HTTP (usando el paquete `http`), manejar la autenticación (añadiendo el token JWT) y transformar las respuestas JSON del backend en los modelos de Dart definidos en `lib/models`.

## Servicios Disponibles

-   **`AuthService`**: Gestiona el registro, inicio de sesión y renovación de tokens.
-   **`ReporteService`**: Gestiona todas las operaciones públicas de reportes (crear, obtener para el mapa, obtener detalles, comentar, apoyar).
-   **`LiderService`**: Contiene todos los endpoints exclusivos para el rol de "Líder Vecinal" (moderación, estadísticas de moderación, etc.).
-   **`PerfilService`**: Gestiona los datos del perfil del usuario autenticado (obtener perfil, mis reportes, mis apoyos, mis notificaciones, zonas seguras).
-   **`SeguimientoService`**: Gestiona la funcionalidad de "seguir" y "dejar de seguir" reportes.
-   **`AnaliticasService`**: Obtiene los datos estadísticos para el panel de analíticas del líder.
-   **`GamificacionService`**: Obtiene la información de insignias y puntos del usuario.
-   **`SosService`**: Gestiona la activación, actualización de ubicación y desactivación de las alertas SOS.
-   **`ServicioSuscripcion`** y **`MetodoPagoService`**: Gestionan la lógica de suscripciones y pagos.

---

## Flujos Detallados (Frontend -> API Service -> Backend)

A continuación se detalla cómo las acciones del usuario en el **Frontend** desencadenan llamadas a los **Servicios API** (en esta carpeta), los cuales a su vez realizan peticiones a endpoints específicos del **Backend**.

### 1. Flujo de Autenticación

Este flujo se inicia principalmente desde las pantallas de Registro (`RegisterScreen`) e Inicio de Sesión (`LoginScreen`).

1.  **Registro de Usuario:**
    * **Frontend:** El usuario llena el formulario en `RegisterScreen` y presiona "Registrar".
    * **Servicio API:** Se llama a `AuthService().register(...)`.
    * **Backend:** Esta función realiza una petición **POST** al endpoint `/api/auth/register`. El backend crea un nuevo registro de usuario en la base de datos.
    * **Respuesta:** El backend devuelve un mensaje de éxito o error.

2.  **Inicio de Sesión:**
    * **Frontend:** El usuario ingresa email/contraseña en `LoginScreen` y presiona "Iniciar Sesión".
    * **Servicio API:** Se llama a `AuthService().login(...)`.
    * **Backend:** Realiza una petición **POST** a `/api/auth/login`. El backend verifica las credenciales.
    * **Respuesta:** Si las credenciales son válidas, el backend genera un **token JWT** y lo devuelve en la respuesta junto con los datos básicos del usuario.

3.  **Almacenamiento del Token:**
    * **Frontend:** La `LoginScreen`, al recibir una respuesta exitosa de `AuthService().login()`, extrae el `token`.
    * **Provider:** Llama a `Provider.of<AuthNotifier>(...).login(token)`.
    * **Lógica Interna:** El `AuthNotifier` guarda el `token` en `SharedPreferences` y actualiza su estado interno (`_token`, `_userId`, etc.), notificando a la UI.

4.  **Autenticación Automática (Peticiones Posteriores):**
    * **Frontend:** El usuario realiza una acción que requiere autenticación (ej. ver su perfil).
    * **Servicio API:** Se llama a una función como `PerfilService().getMiPerfil()`.
    * **Lógica Interna:** La función del servicio llama primero a `_getToken()` (método privado presente en casi todos los servicios).
    * `_getToken()`: Lee el `token` guardado en `SharedPreferences`.
    * **Petición:** El servicio API añade la cabecera `Authorization: Bearer <token>` a la petición **GET** (o POST, PUT, DELETE según corresponda) antes de enviarla al endpoint del backend (ej. `/api/perfil/me`).
    * **Backend:** El backend recibe la petición, verifica la validez del token en la cabecera, identifica al usuario y procesa la solicitud.

5.  **Renovación de Token:**
    * **Frontend:** Al iniciar la app, `main.dart` llama a `AuthNotifier().checkAuthStatus()` o `refreshUserStatus()`.
    * **Servicio API:** `AuthNotifier` puede llamar a `AuthService().refreshToken()`.
    * **Backend:** Realiza una petición **GET** a `/api/auth/refresh-token`, enviando el token actual en la cabecera. El backend verifica si el token es válido (aunque expirado) y emite uno nuevo.
    * **Respuesta:** Si la renovación es exitosa, devuelve el `newToken`. El `AuthNotifier` lo guarda con `login(newToken)`. Si falla, `AuthNotifier` llama a `logout()`.

---

### 2. Flujo de Creación y Visualización de Reportes

Este flujo involucra `ReporteService` y varias pantallas (Mapa, Crear Reporte, Detalle).

1.  **Crear Reporte:**
    * **Frontend:** El usuario llena el formulario en `CrearReporteScreen` (título, descripción, categoría, ubicación, foto, etc.) y presiona "Enviar".
    * **Servicio API:** Se llama a `ReporteService().createReport(...)`.
    * **Lógica Interna:** Esta función construye una petición `http.MultipartRequest` porque necesita enviar datos de formulario y un archivo de imagen.
    * **Backend:** Realiza una petición **POST** a `/api/reportes`. El backend recibe los datos y la imagen, valida la información, guarda el nuevo reporte en la base de datos (con estado inicial `pendiente_verificacion`) y almacena la imagen.
    * **Respuesta:** Devuelve un código 201 (Creado) si es exitoso.

2.  **Ver Reportes en el Mapa:**
    * **Frontend:** La `MapaScreen` (pantalla principal) se inicializa o el usuario mueve el mapa.
    * **Servicio API:** Se llama a `ReporteService().getAllReports(...)` pasando filtros opcionales (categoría, días) y el estado (normalmente `verificado`).
    * **Backend:** Realiza una petición **GET** a `/api/reportes` con los parámetros de query correspondientes (ej. `?status=verificado&categoriaIds=1&limit=50`). El backend consulta la base de datos buscando reportes que coincidan.
    * **Respuesta:** Devuelve una lista de objetos `Reporte` (modelo básico) en formato JSON. El servicio los deserializa a `List<Reporte>`.

3.  **Ver Detalles de un Reporte:**
    * **Frontend:** El usuario toca un marcador en el mapa o un ítem en una lista, navegando a `ReporteDetalleScreen` con el `idReporte`.
    * **Servicio API:** La pantalla llama a `ReporteService().getReporteById(idReporte)`.
    * **Backend:** Realiza una petición **GET** a `/api/reportes/{idReporte}`. El backend busca el reporte específico, incluyendo sus comentarios asociados y todos los detalles.
    * **Respuesta:** Devuelve un objeto JSON complejo. El servicio lo deserializa al modelo `ReporteDetallado`.

4.  **Interactuar con un Reporte (Comentar, Apoyar, Seguir):**
    * **Frontend:** En `ReporteDetalleScreen`, el usuario escribe un comentario y presiona "Enviar", o toca el botón "Apoyar" o "Seguir".
    * **Servicio API (Comentar):** Se llama a `ReporteService().createComentario(idReporte, texto)`. **Backend:** Petición **POST** a `/api/comentarios`.
    * **Servicio API (Apoyar Reporte):** Se llama a `ReporteService().apoyarReporte(idReporte)`. **Backend:** Petición **POST** a `/api/reportes/{idReporte}/apoyar`.
    * **Servicio API (Seguir Reporte):** Se llama a `SeguimientoService().seguirReporte(idReporte)`. **Backend:** Petición **POST** a `/api/seguimiento/reporte/{idReporte}/seguir`.
    * **Lógica:** Cada servicio envía la petición correspondiente al backend, que actualiza la base de datos (crea comentario, incrementa apoyos, registra seguimiento).
    * **Respuesta:** El backend devuelve un mensaje de éxito/error. La UI puede actualizarse (ej. mostrar el nuevo comentario, cambiar el estado del botón).

---

### 3. Flujo de Perfil y Actividad del Usuario

Este flujo es gestionado por `PerfilService` y `SeguimientoService`, usado en las pantallas del perfil.

1.  **Ver Perfil:**
    * **Frontend:** El usuario navega a `PerfilScreen`.
    * **Servicio API:** Se llama a `PerfilService().getMiPerfil()`.
    * **Backend:** Petición **GET** a `/api/perfil/me`. El backend obtiene los datos del usuario autenticado (identificado por el token).
    * **Respuesta:** Devuelve el objeto `Perfil` en JSON.

2.  **Ver Listas de Actividad (Mis Reportes, Apoyos, Comentarios, Seguidos):**
    * **Frontend:** El usuario selecciona una pestaña en `PerfilScreen` o `ActividadScreen`.
    * **Servicio API:** Se llama a la función correspondiente:
        * `PerfilService().getMisReportes()` -> **GET** `/api/perfil/me/reportes`
        * `PerfilService().getMisApoyos()` -> **GET** `/api/perfil/me/apoyos`
        * `PerfilService().getMisComentarios()` -> **GET** `/api/perfil/me/comentarios`
        * `SeguimientoService().getMisReportesSeguidos()` -> **GET** `/api/seguimiento/mis-seguimientos`
    * **Backend:** Cada endpoint consulta la base de datos para obtener la lista de reportes (en formato `ReporteResumen`) asociada a la actividad del usuario.
    * **Respuesta:** Devuelve una `List<ReporteResumen>` en JSON.

3.  **Ver Notificaciones:**
    * **Frontend:** El usuario navega a `NotificacionesScreen`.
    * **Servicio API:** Se llama a `PerfilService().getMisNotificaciones()`.
    * **Backend:** Petición **GET** a `/api/perfil/me/notificaciones`.
    * **Respuesta:** Devuelve `List<Notificacion>` en JSON.

4.  **Gestionar Zonas Seguras:**
    * **Frontend:** El usuario interactúa con la pantalla de `ZonasSegurasScreen`.
    * **Servicio API:** Se llaman a las funciones CRUD de `PerfilService`:
        * `getMisZonasSeguras()` -> **GET** `/api/perfil/me/zonas-seguras`
        * `crearZonaSegura(...)` -> **POST** `/api/perfil/me/zonas-seguras`
        * `eliminarZonaSegura(id)` -> **DELETE** `/api/perfil/me/zonas-seguras/{id}`
    * **Backend:** Los endpoints correspondientes gestionan las zonas seguras del usuario en la base de datos.

---

### 4. Flujo de Moderación (Exclusivo para Líderes)

Gestionado por `LiderService`, usado en el panel de moderación (`PanelModeracionScreen`).

1.  **Ver Estadísticas:**
    * **Frontend:** El líder abre `PanelModeracionScreen`.
    * **Servicio API:** Se llama a `LiderService().getModeracionStats()`.
    * **Backend:** Petición **GET** a `/api/lider/stats/moderacion`. Devuelve conteos.

2.  **Ver Cola de Pendientes:**
    * **Frontend:** El líder ve la lista de reportes pendientes.
    * **Servicio API:** Se llama a `LiderService().getReportesPendientes(...)` con filtros/paginación.
    * **Backend:** Petición **GET** a `/api/lider/reportes-pendientes`. Devuelve `PagedResult<ReportePendiente>`.

3.  **Realizar Acciones de Moderación:**
    * **Frontend:** El líder presiona "Aprobar", "Rechazar", "Fusionar", etc.
    * **Servicio API:** Se llama a la función correspondiente de `LiderService`:
        * `aprobarReporte(id)` -> **PUT** `/api/lider/reportes/{id}/aprobar`
        * `rechazarReporte(id)` -> **PUT** `/api/lider/reportes/{id}/rechazar`
        * `fusionarReporte(dupId, origId)` -> **POST** `/api/lider/reporte/{dupId}/fusionar`
        * `editarReporteLider(id, ...)` -> **PUT** `/api/lider/reporte/{id}`
    * **Backend:** Los endpoints actualizan el estado o los datos del reporte en la base de datos.

4.  **Ver Historial de Moderación:**
    * **Frontend:** El líder navega a la pestaña de historial.
    * **Servicio API:** Se llama a `LiderService().getReportesModerados(...)` con filtros.
    * **Backend:** Petición **GET** a `/api/lider/reportes-moderados`. Devuelve `PagedResult<ReporteHistorialModerado>`.

---

### 5. Flujo de Alerta SOS

Coordinado entre `SosService`, el `BackgroundService` y la `SosScreen`.

1.  **Activación:**
    * **Frontend:** Usuario presiona botón SOS en `SosScreen`.
    * **Servicio API:** Se llama a `SosService().activateSos(...)`.
    * **Backend:** Petición **POST** a `/api/sos/activate`. El backend crea un registro de alerta SOS, potencialmente notifica a contactos/autoridades, y devuelve el `alertId`.
    * **Respuesta:** El `alertId` se devuelve al frontend.

2.  **Inicio del Servicio de Fondo:**
    * **Frontend:** La `SosScreen` usa el `alertId` y la duración para iniciar el `BackgroundService` (`FlutterBackgroundService().start(...)`) pasándole estos datos.

3.  **Seguimiento en Segundo Plano (Dentro del BackgroundService):**
    * **Servicio de Fondo:** Inicia un `Timer`.
    * **Servicio API (cada 15s):** El `Timer` llama a `SosService().addLocationUpdate(alertId, lat, lon)`.
    * **Backend:** Petición **POST** a `/api/sos/{alertId}/location`. El backend registra la nueva ubicación en la alerta activa.

4.  **Desactivación:**
    * **Frontend:** Usuario presiona "Cancelar SOS" en `SosScreen` O el `BackgroundService` detecta que el tiempo se agotó.
    * **Servicio de Fondo:** Llama a `stopTracking(byUser: true)`.
    * **Servicio API:** `stopTracking` llama a `SosService().deactivateSos(alertId)`.
    * **Backend:** Petición **PUT** a `/api/sos/{alertId}/deactivate`. El backend marca la alerta como finalizada.
    * **Servicio de Fondo:** Se detiene a sí mismo (`service.stopSelf()`).

---

### 6. Flujo de Suscripciones y Pagos

Gestionado por `ServicioSuscripcion` y `MetodoPagoService`.

1.  **Ver Planes:**
    * **Frontend:** Usuario navega a `PlanesScreen`.
    * **Servicio API:** Se llama a `ServicioSuscripcion().getPlanes()`.
    * **Backend:** Petición **GET** a `/api/subscriptions/plans`. Devuelve `List<PlanSuscripcion>`.

2.  **Gestionar Métodos de Pago:**
    * **Frontend:** Usuario interactúa con `MetodosPagoScreen`.
    * **Servicio API:** Se llaman las funciones CRUD de `MetodoPagoService`:
        * `listarMetodos()` -> **GET** `/api/metodos-pago`
        * `crearMetodo(...)` -> **POST** `/api/metodos-pago`
        * `establecerPredeterminado(id)` -> **PUT** `/api/metodos-pago/{id}/predeterminado`
        * `eliminarMetodo(id)` -> **DELETE** `/api/metodos-pago/{id}`
    * **Backend:** Los endpoints gestionan los métodos de pago asociados al usuario.

3.  **Suscribirse:**
    * **Frontend:** Usuario selecciona un plan y un método de pago, presiona "Suscribirse".
    * **Servicio API:** Se llama a `ServicioSuscripcion().suscribirseAlPlan(planId, paymentPayload)`.
    * **Backend:** Petición **POST** a `/api/subscriptions/subscribe`. El backend procesa el pago (a través de una pasarela) y actualiza el estado de suscripción del usuario.

4.  **Cancelar Suscripción:**
    * **Frontend:** Usuario presiona "Cancelar Suscripción" en `PerfilScreen` o similar.
    * **Servicio API:** Se llama a `ServicioSuscripcion().cancelarSuscripcion()`.
    * **Backend:** Petición **PUT** a `/api/subscriptions/cancel`. El backend marca la suscripción para que no se renueve al final del período actual.