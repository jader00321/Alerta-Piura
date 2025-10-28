# Carpeta Raíz: `lib`

## 💎 Descripción General

Esta carpeta es el corazón de la aplicación móvil de Reporta Piura, escrita en **Flutter (Dart)**. Contiene todo el código fuente.

El punto de entrada principal es `main.dart`, que inicia la aplicación y configura los servicios y proveedores globales. La arquitectura general de la aplicación sigue un patrón de **Servicio-Repositorio** (implícito en los `api_services`) y **Gestión de Estado con Provider**.

## 🚀 Archivos Principales

### `main.dart`

Este es el punto de entrada (`void main()`) de toda la aplicación.

#### Responsabilidades Clave:

1.  **Inicialización de Servicios Críticos:** Antes de que se muestre cualquier UI (`runApp`), `main.dart` se asegura de que todos los servicios de bajo nivel estén listos en el orden correcto. Esto es crucial para evitar errores de "servicios no inicializados".
    * `WidgetsFlutterBinding.ensureInitialized()`: Requerido por Flutter.
    * `initializeDateFormatting('es_ES', null)`: Configura la app para mostrar fechas y horas en formato español.
    * `NotificationService().initialize(navigatorKey)`: Inicializa el servicio de notificaciones locales y, lo más importante, le **entrega la `navigatorKey`**. Esto permite que el servicio de notificaciones (que corre en segundo plano) pueda forzar una navegación cuando el usuario toca una notificación.
    * `initializeBackgroundService()`: Configura e inicializa `flutter_background_service`, preparando el *Isolate* (hilo secundario) que manejará la lógica de la Alerta SOS.

2.  **Inicialización de Providers (Gestión de Estado):**
    * Crea las instancias de `ThemeProvider` y `AuthNotifier` (`AuthProvider`).
    * Llama a `themeProvider.loadTheme()` y `authProvider.checkAuthStatus()` **antes** de `runApp`. Esto es vital porque `checkAuthStatus` lee el token JWT guardado en `SharedPreferences`, permitiendo que la app "recuerde" la sesión del usuario desde el primer fotograma.

3.  **Configuración de `MaterialApp`:**
    * **Gestión de Estado Global:** Envuelve toda la `MaterialApp` en un `MultiProvider` para que `ThemeProvider` y `AuthNotifier` estén disponibles en todo el árbol de widgets.
    * **Navegación:** Asigna la `navigatorKey` al `MaterialApp`.
    * **Localización:** Configura la app para usar `es_ES` (español de España/Latam) como el idioma por defecto.
    * **Definición de Rutas:** Define dos tipos de rutas:
        * **Rutas Estáticas (`routes`):** Para pantallas simples que no requieren argumentos (ej. `/home`, `/login`, `/perfil`).
        * **Rutas Dinámicas (`onGenerateRoute`):** Para pantallas que SÍ requieren argumentos (ej. `/reporte_detalle` que necesita un `reporteId`, o `/pago` que necesita un objeto `PlanSuscripcion`).

### `navigator_key.dart`

* **Propósito:** Este archivo declara una única `GlobalKey<NavigatorState>`.
* **Importancia:** Es la "llave maestra" de la navegación. Dado que servicios como `NotificationService` (cuando una notificación es tocada) o `SocketService` (potencialmente) no tienen un `BuildContext` disponible, no pueden usar `Navigator.of(context)`. Al asignar esta clave global al `MaterialApp` en `main.dart`, estos servicios pueden navegar usando `navigatorKey.currentState?.pushNamed(...)` desde cualquier parte de la aplicación.

## 🏛️ Arquitectura de Carpetas (Nivel `lib`)

* **`api/`:** Capa de acceso a datos. Contiene todas las clases (`_service.dart`) que realizan las llamadas HTTP (`http`) al backend. Cada servicio agrupa endpoints relacionados (ej. `AuthService`, `ReporteService`, `LiderService`).
* **`models/`:** Define la estructura de datos de la aplicación. Contiene todas las clases (ej. `ReporteDetallado`, `Perfil`, `Usuario`) con sus métodos `fromJson` para parsear las respuestas JSON del backend.
* **`providers/`:** Capa de gestión de estado. Contiene los `ChangeNotifier` (ej. `AuthProvider`, `ThemeProvider`) que la UI "escucha" (`context.watch`) para reconstruirse cuando los datos cambian.
* **`screens/`:** Las vistas principales de la aplicación. Cada archivo corresponde a una pantalla completa (ver `lib/screens/README.md`).
* **`services/`:** Servicios de lógica de negocio y tareas de fondo. A diferencia de `api/`, estos *no* solo hacen llamadas HTTP, sino que *orquestan* tareas complejas (ej. `BackgroundService` maneja los timers y `Geolocator`, `SocketService` maneja la conexión en tiempo real).
* **`utils/`:** Clases de utilidad, principalmente `api_constants.dart` para definir la `baseUrl` del backend.
* **`widgets/`:** El corazón de la UI. Contiene todos los componentes reutilizables (tarjetas, botones, formularios) que son ensamblados por las `screens`. Están organizados en subcarpetas por funcionalidad (ej. `mapa/`, `perfil/`, `verificacion/`).