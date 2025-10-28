# 💬 Documentación externa de `comentarios.controller.js`

## 🧩 Ubicación del archivo
`/src/controllers/comentarios.controller.js`

---

## 📝 Descripción general
El archivo **`comentarios.controller.js`** gestiona toda la **lógica relacionada con los comentarios** dentro de la plataforma:  
creación, edición, eliminación, reportes y sistema de apoyo ("me gusta").  

Este módulo garantiza que solo los **usuarios autorizados** (autor, líder vecinal o administrador) puedan modificar o eliminar comentarios,  
y también permite a los usuarios **reportar contenido inapropiado** o **apoyar comentarios** de otros usuarios.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Editar comentario (`editarComentario`)** | Permite al autor modificar su propio comentario. |
| **Eliminar comentario (`eliminarComentario`)** | Autor, líder o administrador pueden eliminar comentarios. |
| **Reportar comentario (`reportarComentario`)** | Permite a un usuario denunciar un comentario por un motivo específico. |
| **Apoyar comentario (`apoyarComentario`)** | Implementa el sistema de “me gusta” para comentarios. |

---

## 📦 Dependencias utilizadas

| Módulo | Uso principal |
|---------|----------------|
| `../config/db` | Ejecuta consultas SQL en PostgreSQL. |
| `req.user` | Proporciona información del usuario autenticado (id, rol). |

---

## 🧠 Flujo general del módulo

1. **Edición y eliminación**:  
   - Solo el **autor** puede editar.  
   - El **autor, líder o admin** pueden eliminar.  
2. **Reportes**:  
   - Cualquier usuario autenticado puede reportar un comentario, siempre que incluya un motivo.  
3. **Apoyos**:  
   - Inserta un registro en `comentario_apoyos`.  
   - Si el registro ya existe (`error 23505`), lo elimina (efecto "toggle").  

---

## 🧩 Componentes / funciones definidas

### 1) `editarComentario(req, res)`
Permite al **autor** de un comentario modificar su contenido.  

#### 🔧 Lógica interna:
- Requiere `id` del comentario (`req.params.id`) y `req.user.id`.  
- Ejecuta:
  ```sql
  UPDATE comentarios
  SET comentario = $1
  WHERE id = $2 AND id_usuario = $3
  RETURNING *;
