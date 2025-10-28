# Carpeta de Widgets: `login`

## Descripción General

Esta carpeta contiene los componentes modulares que construyen la pantalla de inicio de sesión (`LoginScreen`). La lógica principal (controladores de texto, estado de carga, y la función `_submitForm`) reside en `LoginScreen`, y estos widgets son en su mayoría *sin estado* que reciben callbacks y controladores.

## Componentes Principales

### `login_header.dart`

* **Widget:** `LoginHeader`
* **Propósito:** Widget puramente visual que muestra la cabecera de la pantalla de login.
* **UI:** Muestra el icono de la app (`Icons.shield_moon_outlined`), el título "Bienvenido a Reporta Piura" y el subtítulo "Inicia sesión para continuar".
* **Conexiones:**
    * **Usado por:** `LoginScreen`.

### `login_form_fields.dart`

* **Widget:** `LoginFormFields` (Stateful)
* **Propósito:** Agrupa los campos de formulario (`TextFormField`) para el email y la contraseña.
* **Lógica Clave:**
    * Es un `StatefulWidget` solo para manejar el estado interno de `_obscurePassword` (visibilidad de la contraseña).
    * **No** tiene un `FormKey` ni controladores propios. Recibe `emailController` y `passwordController` desde `LoginScreen`.
    * Define los `validator` para los campos de email y contraseña.
* **Conexiones:**
    * **Usado por:** `LoginScreen`.

### `login_actions.dart`

* **Widget:** `LoginActions`
* **Propósito:** Muestra el botón principal de "Iniciar Sesión" y el enlace de texto para ir a "Regístrate aquí".
* **Lógica Clave:**
    * Recibe el booleano `isLoading` y el callback `onSubmit` desde `LoginScreen`.
    * Si `isLoading` es `true`, el `ElevatedButton` se deshabilita y muestra un `CircularProgressIndicator`.
    * Si `isLoading` es `false`, el botón está activo y llama a `onSubmit`.
    * El `TextButton` "Regístrate aquí" navega a la ruta `/register`.
* **Conexiones:**
    * **Usado por:** `LoginScreen`.
    * **Navega a:** `RegisterScreen` (`/register`).