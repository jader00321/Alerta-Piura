# Carpeta de Widgets: `perfil`

## Descripción General

Esta carpeta contiene los widgets modulares que construyen la pantalla de "Mi Perfil" (`PerfilScreen`). Estos componentes ayudan a organizar la información del usuario y las acciones de navegación en bloques lógicos y visualmente distintos.

## Componentes Principales

### `perfil_header_card.dart`

* **Widget:** `PerfilHeaderCard`
* **Propósito:** Es la tarjeta principal y más prominente en la parte superior de `PerfilScreen`. Muestra la identidad central del usuario.
* **UI:**
    * Muestra un `CircleAvatar` grande con la inicial del usuario (priorizando `perfil.alias` sobre `perfil.nombre`).
    * Muestra el nombre de usuario/alias y el email.
    * Muestra el total de "Puntos de Comunidad" del usuario junto a un icono de estrella.
* **Conexiones:**
    * **Usado por:** `PerfilScreen`.
    * **Depende de:** `Perfil` (modelo).

### `insignia_estatus_widget.dart`

* **Widget:** `InsigniaEstatusWidget`
* **Propósito:** Muestra el "estatus" principal del usuario (su rol o nivel de suscripción) como una insignia destacada.
* **Lógica Clave:**
    * Es un widget dinámico que determina qué mostrar basándose en una combinación de datos.
    * Utiliza `context.watch<AuthNotifier>()` para obtener el `rol` del usuario (ej. 'admin', 'lider_vecinal', 'reportero', 'ciudadano').
    * Utiliza el `perfil.nombrePlan` para identificar a los usuarios "Premium".
    * Llama a helpers internos (`_obtenerEstatus`, `_obtenerIcono`, `_obtenerColor`) para renderizar el título (ej. "Guardián Premium", "Líder Vecinal") y el estilo visual correspondiente.
* **Conexiones:**
    * **Usado por:** `PerfilScreen`.
    * **Depende de:** `Perfil` (modelo) y `AuthNotifier` (Provider).

### `perfil_action_tile.dart`

* **Widget:** `PerfilActionTile`
* **Propósito:** Es el componente de botón/enlace reutilizable para *todas* las acciones de navegación en `PerfilScreen`.
* **UI:**
    * Un `ListTile` estilizado (sin `Card` propia, para ser agrupado dentro de `_buildSectionCard` en `PerfilScreen`).
    * Muestra un `leading` (icono), `title`, `subtitle` (opcional) y un `trailing` (`Icons.chevron_right`).
    * Permite un `color` opcional para resaltar acciones específicas (como "Cerrar Sesión" en rojo o "Premium" en ámbar).
* **Conexiones:**
    * **Usado por:** `PerfilScreen` (usado múltiples veces).

### `dialogo_postulacion_lider.dart`

* **Widget:** `DialogoPostulacionLider` (Stateful)
* **Propósito:** Muestra un `AlertDialog` con un formulario para que los usuarios (con rol 'ciudadano') puedan postularse para ser 'lider_vecinal'.
* **Lógica Clave:**
    * Es un `StatefulWidget` que maneja su propio `FormKey`, controladores de texto (`_motivacionController`, `_zonaController`) y estado de carga (`_isLoading`).
    * Al presionar "Enviar Postulación", llama a `PerfilService.postularComoLider`.
    * Maneja la respuesta de la API:
        * Si es exitosa (`statusCode == 201`), cierra el diálogo y devuelve `true` a `PerfilScreen`.
        * Si falla (ej. `statusCode == 409` "Ya tienes una postulación pendiente"), muestra el `_errorMessage` dentro del diálogo sin cerrarlo.
* **Conexiones:**
    * **Usado por:** `PerfilScreen` (mostrado mediante `showDialog`).
    * **Llama a:** `PerfilService.postularComoLider`.