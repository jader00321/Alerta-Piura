# 💬 Documentación externa de `comentarios.routes.js`

## 🧩 Ubicación del archivo
`/src/routes/comentarios.routes.js`

---

## 📝 Descripción general
El archivo **`comentarios.routes.js`** define todas las rutas relacionadas con la **gestión de comentarios** en los reportes dentro del sistema.  
Incluye funcionalidades para **editar, eliminar, reportar** y **apoyar comentarios**, asegurando que solo los usuarios autenticados puedan interactuar con estos recursos.

Todas las rutas están protegidas mediante el **middleware de autenticación (`authMiddleware`)**, lo que garantiza que cada acción sea realizada por un usuario válido con un token JWT activo.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Editar comentario** | Permite modificar el contenido de un comentario propio. |
| **Eliminar comentario** | Elimina un comentario (autores, líderes vecinales o administradores). |
| **Reportar comentario** | Envía un reporte por contenido inapropiado o indebido. |
| **Apoyar comentario** | Permite dar o quitar un “me gusta” a un comentario. |

---

## 📦 Dependencias utilizadas

| Módulo | Uso principal |
|---------|----------------|
| `express` | Creación del enrutador y manejo de peticiones HTTP. |
| `../controllers/comentarios.controller` | Contiene la lógica para las operaciones CRUD de comentarios. |
| `../middleware/auth.middleware` | Verifica la autenticación mediante token JWT. |

---

## 🧠 Flujo general del archivo

1. Se crea una instancia de `Router()` de Express.  
2. Se aplica el middleware global `authMiddleware` a todas las rutas del archivo.  
3. Se usa `express.json()` para manejar el cuerpo de las solicitudes con formato JSON.  
4. Se definen las rutas para editar, eliminar, reportar y apoyar comentarios.  
5. Se exporta el router configurado para ser usado en el archivo principal de rutas.

---

## 🗺️ Rutas definidas

| Método | Ruta | Middleware | Controlador | Descripción |
|---------|------|-------------|--------------|--------------|
| `PUT` | `/:id` | `authMiddleware`, `jsonParser` | `editarComentario` | Edita un comentario existente del usuario autenticado. |
| `DELETE` | `/:id` | `authMiddleware` | `eliminarComentario` | Elimina un comentario (autorizado para autor, líder o admin). |
| `POST` | `/:id/reportar` | `authMiddleware`, `jsonParser` | `reportarComentario` | Reporta un comentario por contenido indebido. |
| `POST` | `/:id/apoyar` | `authMiddleware`, `jsonParser` | `apoyarComentario` | Da o quita un “me gusta” a un comentario. |

---

## 🧩 Ejemplo de uso (API)

### ✏️ Editar un comentario
```http
PUT /api/comentarios/15
Authorization: Bearer <token>
Content-Type: application/json

{
  "comentario": "Actualizando mi comentario para más detalles."
}

→ Respuesta:
200 OK
{
  "message": "Comentario actualizado.",
  "comentario": {
    "id": 15,
    "comentario": "Actualizando mi comentario para más detalles."
  }
}
