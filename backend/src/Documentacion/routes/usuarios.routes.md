# 👥 Documentación externa de `usuario.routes.js`

## 🧩 Ubicación del archivo
`/src/routes/usuario.routes.js`

---

## 📝 Descripción general
El archivo **`usuario.routes.js`** define las rutas relacionadas con la **gestión de reportes de usuarios** dentro del sistema.  
Su función principal es permitir que un usuario autenticado **repporte a otro usuario** por comportamiento inapropiado, abuso o violación de las normas de la comunidad.

Todas las rutas están **protegidas mediante el middleware `authMiddleware`**, lo que garantiza que solo los usuarios autenticados puedan acceder a estas funciones.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Reportar usuario** | Permite a un usuario enviar un reporte formal contra otro, especificando un motivo. |

---

## 📦 Dependencias utilizadas

| Módulo | Uso principal |
|---------|----------------|
| `express` | Creación del router y manejo de peticiones HTTP. |
| `../controllers/usuarios.controller` | Contiene la lógica de negocio para registrar reportes de usuarios. |
| `../middleware/auth.middleware` | Verifica el token JWT para asegurar autenticación antes de procesar la solicitud. |

---

## 🧠 Flujo general del archivo

1. Se crea una instancia de `Router()` de Express.  
2. Se define el parser `jsonParser` para manejar cuerpos JSON en solicitudes POST.  
3. Se aplica el **middleware `authMiddleware`** a todas las rutas del archivo.  
4. Se define una ruta principal que permite reportar a otro usuario.  
5. Finalmente, se exporta el router configurado para integrarse en el enrutador principal del servidor.

---

## 🗺️ Rutas definidas

| Método | Ruta | Middleware | Controlador | Descripción |
|---------|------|-------------|--------------|--------------|
| `POST` | `/:id/reportar` | `authMiddleware`, `jsonParser` | `reportarUsuario` | Permite a un usuario enviar un reporte sobre otro, indicando el motivo. |

