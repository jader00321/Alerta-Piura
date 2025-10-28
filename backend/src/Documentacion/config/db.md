# 🗄️ Documentación externa de `db.js`

## 🧩 Ubicación del archivo
`/src/config/db.js`

---

## 📝 Descripción general
El archivo **`db.js`** gestiona la **conexión a la base de datos PostgreSQL** mediante el uso del módulo oficial **`pg` (node-postgres)**.  
Su propósito principal es centralizar la configuración y proveer funciones reutilizables para realizar **consultas SQL** y manejar **transacciones** dentro del backend del proyecto.

Este archivo utiliza un **pool de conexiones** (grupo de conexiones persistentes) para optimizar el rendimiento y permitir múltiples operaciones simultáneas sin necesidad de reconectarse a la base de datos en cada solicitud.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Creación del pool de conexiones** | Inicializa un grupo de conexiones a PostgreSQL con las credenciales del archivo `.env`. |
| **Función `query()`** | Ejecuta consultas SQL simples pasando la sentencia y los parámetros. |
| **Función `getClient()`** | Obtiene una conexión directa del pool para manejar transacciones complejas (BEGIN, COMMIT, ROLLBACK). |
| **Gestión de credenciales seguras** | Carga las variables de entorno con `dotenv` para evitar exponer información sensible. |

---

## 🧩 Componentes definidos

### 1. **Pool de conexiones**
Crea e inicializa un conjunto de conexiones reutilizables a la base de datos PostgreSQL.

#### 🔧 Configuración:
- **Usuario:** `process.env.DB_USER`  
- **Host:** `process.env.DB_HOST`  
- **Base de datos:** `process.env.DB_DATABASE`  
- **Contraseña:** `process.env.DB_PASSWORD`  
- **Puerto:** `process.env.DB_PORT`  

Esta configuración se carga dinámicamente desde el archivo `.env`, garantizando seguridad y flexibilidad entre entornos (desarrollo, pruebas, producción).

---

### 2. **Función `query(text, params)`**
Método simplificado para ejecutar consultas SQL directas.

#### 🧠 Lógica interna:
- Recibe como parámetros la sentencia SQL (`text`) y un arreglo de parámetros (`params`).  
- Devuelve una promesa con los resultados de la consulta (`pool.query(text, params)`).

**Ejemplo de uso:**
```js
const db = require('../config/db');
const result = await db.query('SELECT * FROM usuarios WHERE id = $1', [id]);
