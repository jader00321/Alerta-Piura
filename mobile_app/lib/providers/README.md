# Módulo de Providers (Gestores de Estado) (`lib/providers`)

Este directorio contiene los "Providers", el núcleo de la gestión de estado de la aplicación, utilizando el paquete `provider` de Flutter y el patrón `ChangeNotifier`. Los providers actúan como un puente centralizado entre la **Interfaz de Usuario (Frontend)**, los **Servicios API** (`lib/api`) y el **Almacenamiento Local** (`SharedPreferences`).

**Propósito:**

1.  **Centralizar el Estado Global:** Mantienen datos que necesitan ser accesibles o modificados desde múltiples partes de la aplicación (ej. estado de autenticación, tema visual).
2.  **Notificar Cambios a la UI:** Cuando un dato gestionado por el provider cambia (ej. el usuario inicia sesión), llama a `notifyListeners()`.
3.  **Reconstruir Widgets:** Los widgets del **Frontend** que estén "escuchando" (`Consumer`, `Selector`, `Provider.of`) a un provider se reconstruyen automáticamente para reflejar el estado actualizado, manteniendo la UI sincronizada con los datos.

---

## Providers Disponibles y Flujos de Interacción

### 1. `auth_provider.dart` (`AuthNotifier`)

Gestiona el estado de autenticación del usuario. Es fundamental para controlar el acceso a diferentes partes de la aplicación y personalizar la experiencia.

**Flujos de Interacción:**

1.  **Inicio de Sesión:**
    * **Frontend:** La `LoginScreen`, tras una llamada exitosa a `AuthService().login()`, recibe el `token` JWT.
    * **Llamada al Provider:** La pantalla llama a `Provider.of<AuthNotifier>(context, listen: false).login(token)`.
    * **Lógica Interna del Provider:**
        * El método `login(token)` guarda el `token` en **SharedPreferences** (`prefs.setString('authToken', token)`).
        * Decodifica el token usando `JwtDecoder.decode(token)` para extraer y almacenar `_userId`, `_userRole`, `_userAlias`, `_planId`.
        * Llama a `_authenticateSocket(token)` para conectar/autenticar el `SocketService`.
        * Llama a `notifyListeners()`.
    * **Reacción del Frontend:** Widgets que escuchan a `AuthNotifier` (como el `AppBar` que muestra el alias o el `Drawer` que muestra opciones según el rol) se reconstruyen. Widgets de ruta (como en `main.dart`) pueden redirigir al usuario a la pantalla principal.

2.  **Cierre de Sesión:**
    * **Frontend:** El usuario presiona "Cerrar Sesión" (ej. en `PerfilScreen` o `Drawer`).
    * **Llamada al Provider:** Se llama a `Provider.of<AuthNotifier>(context, listen: false).logout()`.
    * **Lógica Interna del Provider:**
        * El método `logout()` elimina el `token` de **SharedPreferences** (`prefs.remove('authToken')`).
        * Limpia las variables internas (`_clearAuthData()`).
        * Desconecta el **SocketService** (`SocketService().disconnect()`).
        * Llama a `notifyListeners()`.
    * **Reacción del Frontend:** La UI se actualiza, usualmente redirigiendo al usuario a la `LoginScreen`.

3.  **Verificación al Iniciar la App:**
    * **Frontend:** En `main.dart` (o una pantalla inicial), se llama a `AuthNotifier().checkAuthStatus()`.
    * **Lógica Interna del Provider:**
        * `checkAuthStatus()` lee el `token` desde **SharedPreferences**.
        * Si existe un token válido y no expirado:
            * Llama a `_setAuthData(token)` para restaurar el estado interno.
            * Llama a `_authenticateSocket(token)`.
        * Si no hay token o está expirado:
            * Llama a `logout()` internamente.
        * Llama a `notifyListeners()`.
    * **Reacción del Frontend:** La app decide si mostrar la pantalla principal o la `LoginScreen` basado en el estado restaurado.

4.  **Renovación de Token (Opcional):**
    * **Frontend:** Podría llamarse `AuthNotifier().refreshUserStatus()` al inicio o periódicamente.
    * **Lógica Interna del Provider:**
        * `refreshUserStatus()` llama a `AuthService().refreshToken()` (del **Servicio API**).
        * Si `AuthService` devuelve un `newToken`:
            * Llama a `login(newToken)` internamente para actualizar el estado y `SharedPreferences`.
        * Si `AuthService` devuelve `null` (falló la renovación):
            * Llama a `logout()` internamente.
    * **Reacción del Frontend:** La sesión del usuario se extiende (si tuvo éxito) o se cierra (si falló), notificando a la UI.

### 2. `theme_provider.dart` (`ThemeProvider`)

Gestiona el tema visual (Claro / Oscuro) y persiste la preferencia del usuario.

**Flujos de Interacción:**

1.  **Carga Inicial del Tema:**
    * **Frontend:** En `main.dart`, antes de construir `MaterialApp`, se llama a `ThemeProvider().loadTheme()`.
    * **Lógica Interna del Provider:**
        * `loadTheme()` lee el valor booleano `isDarkMode` desde **SharedPreferences**.
        * Si no existe, usa `false` (tema claro)    por defecto.
        * Actualiza `_isDarkMode` y llama a `notifyListeners()`.
    * **Reacción del Frontend:** El `MaterialApp` inicial se construye con el tema cargado.

2.  **Cambio de Tema por el Usuario:**
    * **Frontend:** El usuario interactúa con un interruptor (Switch) o botón en la pantalla de configuración (`SettingsScreen`).
    * **Llamada al Provider:** Se llama a `Provider.of<ThemeProvider>(context, listen: false).setThemeMode(newIsDarkModeValue)`.
    * **Lógica Interna del Provider:**
        * `setThemeMode(bool)` actualiza `_isDarkMode` con el nuevo valor.
        * Guarda el nuevo valor en **SharedPreferences** (`prefs.setBool('isDarkMode', _isDarkMode)`).
        * Llama a `notifyListeners()`.
    * **Reacción del Frontend:** El `MaterialApp` (y todos los widgets descendientes que dependen del tema) se reconstruyen usando el nuevo `ThemeData` (claro u oscuro).   