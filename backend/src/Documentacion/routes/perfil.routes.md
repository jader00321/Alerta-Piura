# 👤 Documentación externa de `perfil.routes.js`

## 🧩 Ubicación del archivo
`/src/routes/perfil.routes.js`

---

## 📝 Descripción general
El archivo **`perfil.routes.js`** gestiona todas las rutas relacionadas con el **perfil del usuario autenticado** dentro del sistema.  
Permite obtener información personal, modificar datos de cuenta, consultar actividad (reportes, apoyos, comentarios, conversaciones) y revisar notificaciones.

Todas las rutas están **protegidas por el middleware `authMiddleware`**, lo que garantiza que solo los usuarios con un token JWT válido puedan acceder a sus datos.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Obtener perfil del usuario** | Devuelve los datos personales, insignias y estadísticas del usuario autenticado. |
| **Gestionar información de perfil** | Permite editar nombre, alias, teléfono, email y contraseña. |
| **Consultar actividad del usuario** | Muestra reportes creados, apoyos, comentarios y conversaciones asociadas. |
| **Notificaciones** | Obtiene el historial de notificaciones del usuario y su contador de no leídas. |

---

## 📦 Dependencias utilizadas

| Módulo | Uso principal |
|---------|----------------|
| `express` | Creación del router y manejo de rutas HTTP. |
| `../controllers/perfil.controller` | Contiene la lógica principal de las operaciones de perfil. |
| `../middleware/auth.middleware` | Protege todas las rutas mediante autenticación JWT. |

---

## 🧠 Flujo general del archivo

1. Se crea una instancia de `Router()` de Express.  
2. Se aplica globalmente el middleware `authMiddleware` a todas las rutas.  
3. Se define un parser JSON (`express.json()`) para procesar cuerpos de solicitudes.  
4. Se agrupan todas las rutas bajo el prefijo `/me` para mantener una estructura clara y consistente.  
5. Se exporta el router configurado para su integración en el enrutador principal.

---

## 🗺️ Rutas definidas

| Método | Ruta | Middleware | Controlador | Descripción |
|---------|------|-------------|--------------|--------------|
| `GET` | `/me` | `authMiddleware` | `getMiPerfil` | Devuelve el perfil completo del usuario (nombre, alias, email, puntos, insignias). |
| `GET` | `/me/reportes` | `authMiddleware` | `getMisReportes` | Obtiene los reportes creados por el usuario. |
| `GET` | `/me/apoyos` | `authMiddleware` | `getMisApoyos` | Lista los reportes en los que el usuario ha dado apoyo. |
| `GET` | `/me/comentarios` | `authMiddleware` | `getMisComentarios` | Muestra los reportes en los que el usuario ha comentado. |
| `GET` | `/me/conversaciones` | `authMiddleware` | `getMisConversaciones` | Devuelve las conversaciones iniciadas por el usuario. |
| `PUT` | `/me` | `jsonParser`, `authMiddleware` | `updateMyProfile` | Permite modificar nombre, alias o teléfono. |
| `PUT` | `/me/email` | `jsonParser`, `authMiddleware` | `updateMyEmail` | Actualiza el correo electrónico tras verificar la contraseña. |
| `PUT` | `/me/password` | `jsonParser`, `authMiddleware` | `updateMyPassword` | Cambia la contraseña actual por una nueva. |
| `GET` | `/me/notificaciones` | `authMiddleware` | `getMisNotificaciones` | Muestra el historial de notificaciones del usuario. |

---

## 🧩 Ejemplos de uso (API)

### 📄 Obtener perfil del usuario
```http
GET /api/perfil/me
Authorization: Bearer <token>

→ 200 OK
{
  "id": 12,
  "nombre": "Laura Gómez",
  "alias": "laurag",
  "email": "laura@example.com",
  "puntos": 85,
  "insignias": [
    { "nombre": "Colaborador Activo", "descripcion": "Más de 5 reportes creados" }
  ]
}
