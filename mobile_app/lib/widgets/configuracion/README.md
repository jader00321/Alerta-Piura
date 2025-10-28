# Carpeta de Widgets: `configuracion`

## Descripción General

Esta carpeta contiene los widgets que componen la pantalla de "Configuración" (`SettingsScreen`). Cada widget es una sección modular de la pantalla, encapsulando su propia lógica y UI dentro de una `Card`.

## Componentes Principales

### `seccion_apariencia.dart`

* **Widget:** `SeccionApariencia`
* **Propósito:** Proporcionar la interfaz para cambiar el tema de la aplicación (Modo Claro/Oscuro).
* **Lógica Clave y UI:**
    * Muestra un `SwitchListTile` con el título "Modo Oscuro".
    * Utiliza `Consumer<ThemeProvider>` para escuchar el estado `isDarkMode` y reconstruir el switch cuando cambia.
    * Utiliza `context.read<ThemeProvider>()` para llamar al método `setThemeMode(value)` cuando el usuario activa el switch.
* **Conexiones:**
    * **Usado por:** `SettingsScreen`.
    * **Depende de:** `ThemeProvider` (para leer y actualizar el estado del tema).

### `seccion_notificaciones.dart`

* **Widget:** `SeccionNotificaciones`
* **Propósito:** Proporcionar un atajo de navegación al historial de notificaciones.
* **Lógica Clave y UI:**
    * Muestra un `ListTile` simple con el título "Historial de Notificaciones".
    * Al ser presionado (`onTap`), navega a la ruta `/alertas`, que corresponde a `PantallaAlertas`.
* **Conexiones:**
    * **Usado por:** `SettingsScreen`.

### `seccion_sos.dart`

* **Widget:** `SeccionSOS`
* **Propósito:** Agrupar todas las configuraciones relacionadas con la función de Alerta SOS.
* **Lógica Clave y UI:**
    * Este es un widget **sin estado**. El estado (`_sosDurationInMinutes`) se mantiene en el widget padre, `SettingsScreen`.
    * **Slider de Duración:** Muestra un `Slider` que permite al usuario elegir la duración de la alerta (de 5 a 30 minutos).
        * `onDurationChanged`: Reporta el cambio de valor *mientras se desliza* (para actualizar la UI en el padre).
        * `onDurationChangeEnd`: Reporta el valor final *al soltar* el slider (para guardarlo en `SharedPreferences` en el padre).
    * **Contacto de Emergencia:** Muestra un `ListTile` que, al ser presionado, navega a la ruta `/editar-contacto` (`EditarContactoScreen`).
* **Conexiones:**
    * **Usado por:** `SettingsScreen`.
    * **Navega a:** `EditarContactoScreen`.