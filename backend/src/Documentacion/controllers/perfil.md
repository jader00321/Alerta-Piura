# 👤 Documentación externa de `perfil.controller.js`

## 🧩 Ubicación del archivo
`/src/controllers/perfil.controller.js`

---

## 📝 Descripción general
El archivo **`perfil.controller.js`** maneja todas las operaciones relacionadas con el **perfil del usuario autenticado** dentro del sistema.  
Proporciona funcionalidades para visualizar y actualizar información personal, consultar reportes asociados, interacciones (apoyos, comentarios, conversaciones) y gestionar credenciales de acceso (correo y contraseña).

Además, permite consultar las **notificaciones** del usuario y su conteo de mensajes no leídos.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Obtener perfil (`getMiPerfil`)** | Retorna la información del usuario autenticado junto con sus insignias. |
| **Obtener mis reportes (`getMisReportes`)** | Devuelve todos los reportes creados por el usuario. |
| **Obtener mis apoyos (`getMisApoyos`)** | Lista los reportes en los que el usuario ha brindado apoyo. |
| **Obtener mis comentarios (`getMisComentarios`)** | Devuelve los reportes en los que el usuario ha comentado. |
| **Obtener mis conversaciones (`getMisConversaciones`)** | Lista los chats asociados a reportes creados por el usuario. |
| **Actualizar perfil (`updateMyProfile`)** | Permite modificar nombre, alias y teléfono. |
| **Actualizar email (`updateMyEmail`)** | Actualiza el correo electrónico tras verificar la contraseña. |
| **Actualizar contraseña (`updateMyPassword`)** | Permite cambiar la contraseña del usuario autenticado. |
| **Obtener notificaciones (`getMisNotificaciones`)** | Muestra las notificaciones del usuario y el conteo de no leídas. |

---

## 📦 Dependencias utilizadas

| Módulo / Librería | Uso principal |
|--------------------|----------------|
| `../config/db` | Consultas SQL en PostgreSQL. |
| `bcryptjs` | Validación y hash de contraseñas. |
| `req.user` | Información del usuario autenticado (id, email, rol). |

---

## 🧠 Flujo general del módulo

1. **Consultas de datos personales y actividad:** obtiene información del usuario, reportes, apoyos, comentarios y notificaciones.  
2. **Actualización de datos sensibles:** modifica perfil, correo o contraseña con validaciones de seguridad.  
3. **Integración de insignias y notificaciones:** vincula logros e interacciones relevantes del usuario en el sistema.  

---

## 🧩 Componentes / funciones definidas

### 1) `getMiPerfil(req, res)`
Obtiene los **datos del usuario autenticado** junto con sus **insignias ganadas**.

#### 🔧 Lógica interna:
- Consulta `Usuarios` por `id` (proveniente de `req.user.id`).  
- Si no se encuentra → 404 “Usuario no encontrado.”  
- Realiza una segunda consulta para unir `Usuario_Insignias` con `Insignias`.  
- Devuelve objeto `perfil` con los datos y array `insignias`.

```sql
SELECT i.nombre, i.descripcion, i.icono_url
FROM Insignias i
INNER JOIN Usuario_Insignias ui ON i.id = ui.id_insignia
WHERE ui.id_usuario = $1;
