# 🔐 Documentación externa de `auth.controller.js`

## 🧩 Ubicación del archivo
`/src/controllers/auth.controller.js`

---

## 📝 Descripción general
El archivo **`auth.controller.js`** implementa la **autenticación de usuarios** del sistema: registro, inicio de sesión y verificación de contraseña.  
Utiliza **bcrypt** para el hash/validación de contraseñas, **JWT** para sesiones seguras y el módulo `db` para interactuar con PostgreSQL.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|---|---|
| **Registro (`register`)** | Crea usuarios con `password_hash` y soporta `telefono`/`alias`. Maneja colisiones de correo/alias. |
| **Login (`login`)** | Autentica por email/contraseña, valida estado (`suspendido`) y devuelve **JWT** (7 días). |
| **Verificar contraseña (`verifyPassword`)** | Confirma la contraseña del usuario autenticado (útil para acciones sensibles). |

---

## 📦 Dependencias utilizadas

| Librería / Módulo | Uso principal |
|---|---|
| `../config/db` | Acceso a PostgreSQL (consultas y transacciones). |
| `bcryptjs` | Generación de salt/`password_hash` y comparación segura. |
| `jsonwebtoken` | Firma de tokens JWT para sesiones. |
| `dotenv` | Carga de variables de entorno (llave `JWT_SECRET`). |

---

## 🧠 Flujo general del módulo

1. **Registro**: valida campos → genera `salt` + `password_hash` → inserta usuario → devuelve datos públicos.  
2. **Login**: busca por email → valida estado → compara contraseña → firma JWT (7d) → responde token.  
3. **Verificación de contraseña**: recibe contraseña → compara con `password_hash` del usuario en sesión → responde éxito/error.

---

## 🧩 Componentes / funciones definidas

### 1) `register(req, res)`
Registra un nuevo usuario.

#### 🔧 Lógica interna:
- Campos esperados: `nombre`, `alias`, `email`, `password`, `telefono` (opcional).  
- Genera `salt` y `password_hash` con `bcrypt`.  
- Inserta en **`Usuarios`**:
  ```sql
  INSERT INTO Usuarios (nombre, alias, email, password_hash, telefono)
  RETURNING id, nombre, email, alias
