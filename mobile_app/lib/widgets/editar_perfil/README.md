# Carpeta de Widgets: `editar_perfil`

## Descripción General

Esta carpeta contiene los widgets que dividen la pantalla "Editar Perfil" (`EditarPerfilScreen`) en secciones de formulario manejables. A diferencia de los widgets de `crear_reporte`, estos componentes son `StatefulWidgets` que manejan su propia lógica interna de estado y validación.

## Componentes Principales

### `seccion_datos_personales.dart`

* **Widget:** `SeccionDatosPersonales` (Stateful)
* **Propósito:** Muestra y gestiona la actualización de los datos no sensibles del usuario: Nombre, Alias, Teléfono y Correo Electrónico.
* **Lógica Clave y UI:**
    * Inicializa sus propios `TextEditingController`s con los valores `...Inicial` pasados como props.
    * Contiene un `ElevatedButton` "Guardar Datos Personales".
    * **Flujo de Guardado:**
        1.  Al presionar "Guardar", se llama a `_showConfirmationDialog`.
        2.  Este diálogo muestra un `TextFormField` que solicita la **contraseña actual** del usuario.
        3.  Si el usuario ingresa la contraseña y confirma, se llama a `_updateProfileData` pasándole la contraseña.
        4.  `_updateProfileData` llama a `PerfilService.updateMyProfile` para los datos básicos (nombre, alias, tel).
        5.  Si el email fue modificado, llama *además* a `PerfilService.updateMyEmail`, pasando la contraseña para verificación en el backend.
        6.  Muestra un `SnackBar` con el resultado y, si todo es exitoso, llama al callback `onProfileUpdated` para notificar a `EditarPerfilScreen`.
* **Conexiones:**
    * **Usado por:** `EditarPerfilScreen`.
    * **Llama a:** `PerfilService.updateMyProfile` y `PerfilService.updateMyEmail`.

### `seccion_seguridad.dart`

* **Widget:** `SeccionSeguridad` (Stateful)
* **Propósito:** Muestra y gestiona el formulario para cambiar la contraseña del usuario.
* **Lógica Clave y UI:**
    * Maneja un `GlobalKey<FormState>` y controladores para "Contraseña Actual", "Nueva Contraseña" y "Confirmar Nueva Contraseña".
    * Incluye un `IconButton` para alternar la visibilidad de la contraseña (`_obscureText`).
    * **Flujo de Guardado:**
        1.  Al presionar "Cambiar Contraseña", se llama a `_updatePassword`.
        2.  Valida el formulario (campos no vacíos, 6+ caracteres, contraseñas nuevas coinciden).
        3.  Llama a `PerfilService.updateMyPassword`.
        4.  Muestra un `SnackBar` (verde para éxito, rojo para error).
        5.  Si tiene éxito, limpia todos los campos del formulario.
* **Conexiones:**
    * **Usado por:** `EditarPerfilScreen`.
    * **Llama a:** `PerfilService.updateMyPassword`.