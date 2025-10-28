# Guía de Características y Workflows (App Móvil)

Este documento describe los flujos de usuario y las características técnicas clave de la aplicación móvil de Reporta Piura.

## 1. Flujo de Navegación Principal

La navegación de la app se centra en una `HomeScreen` que contiene un `PageView` y una `BottomNavigationBar` con 4 pestañas:

1.  **Mapa (`MapaView`):** Pantalla de inicio. Muestra el mapa interactivo, barra de búsqueda y botones de acción (Filtros, SOS, Crear Reporte).
2.  **Cerca de Ti (`PantallaCercaDeTi`):** Muestra una lista de reportes (verificados y pendientes) cercanos a la ubicación GPS del usuario.
3.  **Actividad / Verificar (Dinámico):**
    * **Ciudadano:** Muestra `MiActividadScreen`, con pestañas para sus reportes, apoyos, seguimientos y comentarios.
    * **Líder:** Muestra `VerificacionScreen`, con pestañas para reportes pendientes, historial de moderación y sus reportes de contenido.
4.  **Perfil (`PerfilScreen`):** Hub central para gestionar la cuenta, ver insignias, acceder a configuraciones, suscripciones y cerrar sesión.

## 2. Workflows Clave

### Flujo 1: Alerta SOS (Premium)

Este es el flujo más complejo que combina UI, servicios en segundo plano, API y sockets.

1.  **Configuración (Usuario):** El usuario va a `PerfilScreen` -> `SettingsScreen` -> `EditarContactoScreen` y guarda un contacto/mensaje de emergencia en `SharedPreferences`.
2.  **Activación (UI):** En `MapaView`, el usuario presiona el botón SOS en `AccionesMapa`.
3.  **Llamada al Servicio (UI):** `MapaView` lee los datos de `SharedPreferences` y llama a `FlutterBackgroundService().invoke('startSosTracking', ...)`.
4.  **Servicio en 2do Plano (App):** `background_service.dart` (`onStart`) recibe el comando.
    * Obtiene la ubicación GPS actual usando `geolocator`.
    * Llama a `SosService.activateSos` (API) enviando la ubicación, contacto y duración.
5.  **Backend (API):** `sos.controller.js` (`activateSos`):
    * Crea una nueva fila en `sos_alerts` (estado 'activo').
    * Guarda la ubicación inicial en `sos_location_updates`.
    * Inserta una fila en `simulated_sms_log`.
    * Emite un evento `new-sos-alert` vía Socket.IO para notificar al panel de administración.
    * Devuelve el `alertId` a la app.
6.  **Timers en 2do Plano (App):** `background_service.dart` recibe el `alertId`:
    * Inicia un `Timer` de cuenta regresiva (`_countdownTimer`) que actualiza la notificación local y envía eventos `updateTimer` a la UI.
    * Inicia un `Timer` periódico (`_locationTimer`) que cada 15 segundos obtiene la nueva ubicación y llama a `SosService.addLocationUpdate` (API).
7.  **Finalización (Múltiples vías):**
    * **Usuario:** Presiona el botón SOS activo en `MapaView` -> `_deactivateSosFromUI` -> `FlutterBackgroundService().invoke('stopSosFromUI')` -> `background_service.dart` llama a `SosService.deactivateSos` (API).
    * **Tiempo:** El `_countdownTimer` llega a 0 -> `background_service.dart` llama a `stopTracking(byUser: true)` -> `SosService.deactivateSos` (API).
    * **Admin:** Un admin finaliza la alerta en el panel web -> Backend `sos.controller.js` (`updateSosStatus`) emite un socket `stopSos` -> `SocketService` (App) recibe el evento y llama a `FlutterBackgroundService().invoke('serverForceStop')` -> `background_service.dart` llama a `stopTracking(byUser: false)` (sin notificar a la API, ya que la API lo inició).

### Flujo 2: Moderación (Líder)

Este flujo describe cómo un líder gestiona un reporte pendiente.

1.  **Login:** El líder inicia sesión. `SplashScreen` llama a `AuthProvider.refreshUserStatus` y detecta que `rol` es 'lider_vecinal'.
2.  **Panel:** `HomeScreen` muestra la pestaña 'Verificar' (`VerificacionScreen`).
3.  **Carga de Datos:** `VerificacionScreen` carga:
    * `LiderService.getModeracionStats` (para los contadores en las pestañas).
    * `LiderService.getMisZonasAsignadas` (para mostrar las zonas gestionadas).
4.  **Lista de Pendientes:** La primera pestaña, `ListaReportesVerificacion` (con `isHistory: false`):
    * Muestra los filtros (`FiltrosPendientes`).
    * Llama a `LiderService.getReportesPendientes` con paginación y filtros.
    * Muestra los reportes usando `TarjetaVerificacion`.
5.  **Selección:** El líder toca un reporte y navega a `VerificacionDetalleScreen`.
6.  **Detalle y Acciones:** `VerificacionDetalleScreen`:
    * Carga los datos completos con `ReporteService.getReporteById`.
    * Muestra los detalles usando `LayoutDetalleVerificacion` (que incluye `ReporteHeader` y `MapaVerificacion`).
    * Muestra la barra de `AccionesModeracion` (Aprobar, Rechazar, Fusionar).
7.  **Acción (Ej. Fusionar):**
    * Líder presiona "Fusionar".
    * Navega a `PantallaBuscarReporteOriginal`.
    * Líder busca y selecciona un reporte verificado (usando `ReporteService.getAllReports(estado: 'verificado')`).
    * La pantalla devuelve el `reporteOriginalId`.
    * `VerificacionDetalleScreen` muestra un diálogo de confirmación.
    * Al confirmar, llama a `LiderService.fusionarReporte`.
8.  **Backend (API):** `lider.controller.js` (`fusionarReporte`):
    * Inicia una **transacción** de base de datos.
    * Actualiza el reporte duplicado a `estado = 'fusionado'` y asigna `id_reporte_original`.
    * Incrementa `reportes_vinculados_count` en el reporte original.
    * Publica un comentario automático en el reporte original.
    * Envía una notificación (`notification` y socket) al autor del reporte duplicado.
    * Hace `COMMIT`.
9.  **Resultado (App):** `VerificacionDetalleScreen` recibe respuesta exitosa, muestra `SnackBar` y hace `Navigator.pop(context, true)` para indicar a `VerificacionScreen` que debe refrescar su lista.

### Flujo 3: Suscripción y Pago

1.  **Inicio:** Usuario (no premium) en `PerfilScreen` presiona "Ver Planes Premium".
2.  **Planes:** Navega a `PantallaPlanesSuscripcion`.
    * Llama a `ServicioSuscripcion.getPlanes` para listar los planes.
    * Muestra los planes usando `TarjetaPlan`.
3.  **Selección:** Usuario selecciona un plan.
4.  **Checkout:** Navega a `PantallaPago`, pasando el objeto `PlanSuscripcion`.
    * Muestra `ResumenPago`.
    * Llama a `MetodoPagoService.listarMetodos` para ver si hay tarjetas guardadas.
    * Si hay, las muestra como `RadioListTile`.
    * Si no hay (o el usuario quiere una nueva), muestra `FormularioPago`.
5.  **Confirmación:** Usuario presiona "Confirmar y Pagar".
    * `_submitPayment` construye el `paymentPayload` (sea un `paymentMethodId` o los datos de la nueva tarjeta).
    * Llama a `ServicioSuscripcion.suscribirseAlPlan` con el `planId` y el `paymentPayload`.
6.  **Backend (API):** `subscription.controller.js` (`subscribe`):
    * Inicia una **transacción**.
    * (Simula) Procesa el pago y guarda el `metodos_pago` si es nuevo.
    * Actualiza la tabla `usuarios` con el `id_plan_suscripcion` y la `fecha_fin_suscripcion`.
    * **Crucial:** Cambia el `rol` del usuario si el plan lo requiere (ej. 'reportero').
    * Otorga insignias (`gamificacionService`).
    * Registra la `transacciones_pago`.
    * **Crucial:** Genera un **nuevo token JWT** que contiene el nuevo `planId` y `rol`.
    * Hace `COMMIT` y devuelve el nuevo token.
7.  **Finalización (App):** `PantallaPago` recibe la respuesta exitosa (código 200).
    * Llama a `Provider.of<AuthNotifier>(context, listen: false).login(nuevoToken)` para actualizar el estado global de la app.
    * Muestra `SnackBar` de éxito.
    * Navega `Navigator.of(context).popUntil((route) => route.isFirst)` para volver a la `HomeScreen`, que ahora se reconstruirá con permisos premium/reportero.

## 3. Arquitectura de Widgets Clave

* **`ListaReportesVerificacion` (`/verificacion`):** Widget con estado clave que maneja la paginación, filtros de búsqueda/fecha/tipo, y la carga de datos (`LiderService`) tanto para la lista de "Pendientes" como la de "Historial", reutilizando la lógica.
* **`ActivityListView` (`/mi_actividad`):** Widget *sin estado* reutilizable que simplemente renderiza una lista de `ReporteResumen`. Es alimentado por `MiActividadScreen`, que es el widget con estado que gestiona la carga de datos para todas sus pestañas.
* **`TarjetaActividad` (`/mi_actividad`):** Widget unificado que adapta su apariencia (mostrando/ocultando autor, comentario contextual, botón de cancelar) basándose en un `enum Fetcher` que le indica en qué pestaña de "Mi Actividad" se encuentra.
* **`FormularioPago` (`/pago`):** Widget de UI que contiene los campos de la tarjeta pero *sin* un `GlobalKey<FormState>`. Esto le permite ser reutilizado dentro de diferentes formularios (`PantallaPago` y `PantallaAgregarMetodoPago`), cada uno con su propia lógica de validación y estado.