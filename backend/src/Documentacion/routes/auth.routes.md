# 📘 Documentación externa de `auth.routes.js`

## 🧩 Ubicación del archivo
`/src/routes/auth.routes.js`

---

## 📝 Descripción general
El archivo **`auth.routes.js`** gestiona las rutas relacionadas con el **registro, inicio de sesión y verificación de contraseñas** de los usuarios en la aplicación.  
Estas rutas son el punto de entrada al sistema de autenticación mediante **JWT (JSON Web Tokens)**.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Registro de usuarios (`/register`)** | Crea una nueva cuenta con datos básicos (nombre, alias, email, contraseña, teléfono). |
| **Inicio de sesión (`/login`)** | Valida las credenciales y genera un token JWT. |
| **Verificación de contraseña (`/verify-password`)** | Confirma la validez de la contraseña actual de un usuario autenticado. |

---

## 📦 Dependencias utilizadas

| Módulo | Uso principal |
|---------|----------------|
| `express` | Creación del router y manejo de peticiones HTTP. |
| `../controllers/auth.controller` | Contiene la lógica de registro, login y verificación de contraseña. |
| `../middleware/auth.middleware` | Protege rutas que requieren autenticación mediante JWT. |

---

## 🧠 Flujo general del archivo

1. Se importa `express` y se crea un `Router()`.  
2. Se declara `jsonParser` para interpretar cuerpos JSON.  
3. Se definen las rutas públicas (`/register`, `/login`) y protegidas (`/verify-password`).  
4. Se exporta el router para ser utilizado en el enrutador principal (`app.js` o `index.js`).

---

## 🗺️ Rutas definidas

| Método | Ruta | Middleware | Controlador | Descripción |
|---------|------|-------------|--------------|--------------|
| `POST` | `/register` | `jsonParser` | `authController.register` | Registra un nuevo usuario en el sistema. |
| `POST` | `/login` | `jsonParser` | `authController.login` | Inicia sesión y devuelve un token JWT. |
| `POST` | `/verify-password` | `jsonParser`, `authMiddleware` | `authController.verifyPassword` | Verifica la contraseña actual del usuario autenticado. |

---



