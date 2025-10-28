# Carpeta de Widgets: `registro`

## Descripción General

[cite_start]Esta carpeta contiene los componentes modulares que construyen la pantalla de registro (`RegisterScreen` [cite: 35]). [cite_start]La lógica principal (controladores de texto, estado de carga, y la función `_submitForm`) reside en `RegisterScreen`[cite: 35], y estos widgets son *sin estado* (`StatelessWidget` o `StatefulWidget` simple) que reciben controladores y callbacks.

Esta modularidad hace que `RegisterScreen` sea mucho más limpio y fácil de leer.

## Componentes Principales

### `register_header.dart`

* [cite_start]**Widget:** `RegisterHeader` [cite: 36]
* **Propósito:** Widget puramente visual que muestra la cabecera de la pantalla de registro.
* **UI:** Muestra el título "Únete a la comunidad" y el subtítulo "Crea tu cuenta para empezar a reportar".
* **Conexiones:**
    * [cite_start]**Usado por:** `RegisterScreen`[cite: 35].

### `register_form_fields.dart`

* [cite_start]**Widget:** `RegisterFormFields` (Stateful) [cite: 34]
* **Propósito:** Agrupa todos los campos de formulario (`TextFormField`) necesarios para el registro.
* **Lógica Clave:**
    * [cite_start]Es un `StatefulWidget` únicamente para manejar el estado interno de `_obscurePassword` (el botón de visibilidad de la contraseña)[cite: 34].
    * **No** tiene su propio `FormKey`. [cite_start]Recibe todos los `TextEditingController`s (nombre, alias, email, teléfono, contraseña, confirmar contraseña) como parámetros desde `RegisterScreen`[cite: 34].
    * [cite_start]Define los `validator` para cada campo (nombre requerido, email válido, contraseña de 6+ caracteres, contraseñas coinciden)[cite: 34].
* **Conexiones:**
    * [cite_start]**Usado por:** `RegisterScreen` [cite: 35] (dentro del `Form`).

### `register_actions.dart`

* [cite_start]**Widget:** `RegisterActions` [cite: 33]
* **Propósito:** Muestra el botón de acción principal ("Registrarse").
* **Lógica Clave:**
    * Recibe el booleano `isLoading` y el callback `onSubmit` desde `RegisterScreen`.
    * [cite_start]Si `isLoading` es `true`, el `ElevatedButton` se deshabilita y muestra un `CircularProgressIndicator`[cite: 33].
    * [cite_start]Si `isLoading` es `false`, el botón está activo y llama a `onSubmit` (que en `RegisterScreen` ejecuta `_submitForm`)[cite: 33, 35].
* **Conexiones:**
    * [cite_start]**Usado por:** `RegisterScreen`[cite: 35].