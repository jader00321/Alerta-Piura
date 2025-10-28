# 🧭 Documentación externa de `lider.controller.js`

## 🧩 Ubicación del archivo
`/src/controllers/lider.controller.js`

---

## 📝 Descripción general
El archivo **`lider.controller.js`** contiene la lógica que permite a los **líderes vecinales** y usuarios autorizados **gestionar comentarios dentro de la plataforma**.  
Incluye operaciones de edición, eliminación, reporte y apoyo de comentarios, con validaciones de rol y permisos de usuario.

La estructura y comportamiento son similares al módulo `comentarios.controller.js`, pero enfocados en las acciones del **rol líder** dentro del sistema.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Editar comentario (`editarComentario`)** | Permite a los autores modificar sus propios comentarios. |
| **Eliminar comentario (`eliminarComentario`)** | Permite a líderes vecinales o administradores eliminar cualquier comentario. |
| **Reportar comentario (`reportarComentario`)** | Permite a los usuarios reportar comentarios inapropiados. |
| **Apoyar comentario (`apoyarComentario`)** | Implementa la funcionalidad de "me gusta" para los comentarios. |

---

## 📦 Dependencias utilizadas

| Módulo | Uso principal |
|---------|----------------|
| `../config/db` | Ejecución de consultas SQL en PostgreSQL. |
| `req.user` | Proporciona la información del usuario autenticado (`id`, `rol`). |

---

## 🧠 Flujo general del módulo

1. **Edición y eliminación de comentarios**:  
   - Los usuarios pueden editar solo sus propios comentarios.  
   - Los **líderes vecinales** y **administradores** pueden eliminar cualquier comentario.  
2. **Reportes**:  
   - Cualquier usuario puede reportar un comentario con un motivo válido.  
3. **Apoyos**:  
   - Los usuarios pueden expresar su apoyo a comentarios con un sistema tipo “me gusta” (toggle).

---

## 🧩 Componentes / funciones definidas

### 1) `editarComentario(req, res)`
Permite al autor modificar el texto de su comentario.  

#### 🔧 Lógica interna:
- Requiere el `id` del comentario (`req.params.id`) y el `id_usuario` autenticado (`req.user.id`).  
- Ejecuta:
  ```sql
  UPDATE comentarios 
  SET comentario = $1 
  WHERE id = $2 AND id_usuario = $3 
  RETURNING *;
