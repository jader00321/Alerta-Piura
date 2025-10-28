# 👥 Documentación externa de `usuario.controller.js`

## 🧩 Ubicación del archivo
`/src/controllers/usuario.controller.js`

---

## 📝 Descripción general
El archivo **`usuario.controller.js`** contiene la lógica principal para el **reporte de usuarios dentro del sistema**.  
Permite que un usuario autenticado denuncie a otro usuario por comportamiento inapropiado, actividad sospechosa o cualquier otra causa válida.

La acción se registra en la base de datos mediante la tabla `usuario_reportes`, que podrá ser revisada posteriormente por un **administrador o moderador**.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Reportar usuario (`reportarUsuario`)** | Inserta un registro en la tabla `usuario_reportes` con el usuario reportado, el autor del reporte y el motivo. |

---

## 📦 Dependencias utilizadas

| Módulo / Librería | Uso principal |
|--------------------|----------------|
| `../config/db` | Conexión y consultas SQL a PostgreSQL. |
| `req.user` | Identificación del usuario autenticado que realiza el reporte. |

---

## 🧠 Flujo general del módulo

1. **El usuario autenticado** selecciona otro usuario para reportar.  
2. Envía el **motivo del reporte** mediante el cuerpo del request (`req.body.motivo`).  
3. Se inserta un nuevo registro en la tabla `usuario_reportes`.  
4. El sistema responde con un mensaje de confirmación.  
5. En caso de error, se captura y se envía un mensaje de error estándar del servidor.  

---

## 🧩 Componentes / funciones definidas

### 1️⃣ `reportarUsuario(req, res)`
Permite que un usuario **reporte a otro usuario** dentro de la plataforma.

#### 🔧 Parámetros de entrada
| Parámetro | Origen | Descripción |
|------------|---------|-------------|
| `id` | `req.params` | ID del usuario reportado. |
| `req.user.id` | `JWT / Middleware` | ID del usuario que realiza el reporte. |
| `motivo` | `req.body` | Razón o causa del reporte. |

#### 🧠 Lógica interna:
1. **Validación del motivo:**
   - Si el campo `motivo` está vacío → responde **400** con mensaje `"Se requiere un motivo para reportar."`.

2. **Inserción del reporte:**
   ```sql
   INSERT INTO usuario_reportes (id_usuario_reportado, id_reportador, motivo)
   VALUES ($1, $2, $3);
