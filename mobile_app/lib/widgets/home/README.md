# Carpeta de Widgets: `home`

## Descripción General

Esta carpeta contiene widgets que se utilizan exclusivamente en la pantalla principal de la aplicación, `MapaView`.

## Componentes Principales

### `top_search_bar.dart`

* **Widget:** `TopSearchBar`
* **Propósito:** Es la barra de búsqueda y perfil que se muestra superpuesta en la parte superior de `MapaView`.
* **UI:**
    * Está envuelta en un `SafeArea` para evitar la barra de estado del sistema.
    * Muestra un `TextField` dentro de una `Card` redondeada para la búsqueda de reportes.
    * Muestra un `CircleAvatar` a la derecha que actúa como el botón de perfil/login.
* **Lógica Clave:**
    * **Búsqueda:** El `TextField` no tiene controlador local; en su lugar, utiliza el callback `onSearchChanged` para notificar a `MapaView` de cada cambio en el texto. `MapaView` es responsable de aplicar el *debounce* (retraso) y volver a ejecutar la consulta a la API.
    * **Avatar:** El `CircleAvatar` es dinámico.
        * Usa `context.watch<AuthNotifier>()` para escuchar los cambios de autenticación.
        * Si el usuario está autenticado (`isAuthenticated`), muestra la primera letra de `authNotifier.userAlias`.
        * Si no está autenticado, muestra un `Icon(Icons.person)`.
        * El `GestureDetector` (`onTap`) navega a `/perfil` si está autenticado, o a `/login` si no lo está.
* **Conexiones:**
    * **Usado por:** `MapaView`.
    * **Depende de:** `AuthNotifier` (Provider).