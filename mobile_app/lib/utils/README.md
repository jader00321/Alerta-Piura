# Módulo de Utilidades (`lib/utils`)

Este directorio contiene archivos y clases de utilidad que proporcionan funciones de ayuda o constantes reutilizables, que no encajan directamente en las categorías de `api`, `models`, `providers` o `services`.

Su propósito es ofrecer herramientas y datos de apoyo transversales a diferentes partes de la aplicación.

## Archivos Disponibles y Flujos de Interacción

### 1. `api_constants.dart` (`ApiConstants`)

Esta clase define constantes **estáticas** cruciales para la comunicación con el backend.

**Flujos de Interacción:**

1.  **Obtención de la URL Base:**
    * **Iniciador:** Prácticamente **todos los Servicios API** (`lib/api`) al construir la URL para una petición HTTP.
    * **Acción:** Acceden a la constante `ApiConstants.baseUrl`.
    * **Lógica Interna (`ApiConstants`):**
        * La variable estática `baseUrl` comprueba `Platform.isAndroid`.
        * Si es Android, devuelve `http://10.0.2.2:3000` (IP especial del emulador para `localhost`).
        * Si es iOS u otra plataforma, devuelve `http://localhost:3000`.
    * **Uso:** El Servicio API concatena esta `baseUrl` con el endpoint específico (ej. `'$baseUrl/api/auth/login'`).

2.  **Uso de Endpoints Específicos (Opcional):**
    * **Iniciador:** Servicios API (`lib/api`).
    * **Acción:** Podrían acceder a constantes como `ApiConstants.registerEndpoint` (aunque en la implementación actual, los endpoints se construyen directamente).
    * **Lógica Interna (`ApiConstants`):** Simplemente devuelve el valor de la cadena estática.
    * **Uso:** Facilita tener los endpoints definidos en un solo lugar.

**Importancia:** Centraliza la configuración de la conexión al backend, permitiendo cambiar fácilmente la URL base si el servidor se mueve a otra dirección (ej. a producción) modificando solo este archivo.

### (Otros posibles archivos de utilidad y sus flujos)

Esta carpeta podría contener otros archivos con los siguientes flujos típicos:

* **`validators.dart`:**
    * **Iniciador:** **Frontend** (ej. `TextFormField` en `LoginScreen` o `RegisterScreen`).
    * **Acción:** Llama a funciones como `Validators.isValidEmail(text)` o `Validators.isPasswordStrong(text)` dentro de la propiedad `validator` del campo de texto.
    * **Lógica Interna:** Las funciones aplican expresiones regulares u otras reglas para verificar el formato del texto.
    * **Uso:** Muestra mensajes de error en los formularios si la validación falla.

* **`formatters.dart`:**
    * **Iniciador:** **Frontend** (ej. al mostrar fechas en `ReporteDetalleScreen` o `HistorialPagosScreen`) o **Servicios API** (si necesitan enviar fechas en un formato específico).
    * **Acción:** Llama a funciones como `Formatters.formatDate(dateTime)` o `Formatters.formatCurrency(amount)`.
    * **Lógica Interna:** Usan paquetes como `intl` para convertir objetos (`DateTime`, `double`) a Strings legibles para el usuario o para la API.
    * **Uso:** Asegura que los datos se muestren o envíen en el formato correcto.

* **`constants.dart`:**
    * **Iniciador:** Cualquier parte de la aplicación (**Frontend**, **Providers**, **Services**).
    * **Acción:** Acceden a constantes estáticas definidas aquí (ej. `AppColors.primary`, `AppConstants.defaultPadding`, `PrefKeys.authToken`).
    * **Lógica Interna:** Simplemente define valores fijos.
    * **Uso:** Mantiene la consistencia en colores, espaciados, claves de SharedPreferences, etc., y facilita cambios globales.