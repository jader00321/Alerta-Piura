# 🛠️ Documentación externa de `admin.controller.js`

## 🧩 Ubicación del archivo
`/src/controllers/admin.controller.js`

---

## 📝 Descripción general
El archivo **`admin.controller.js`** concentra la **lógica administrativa** del sistema: autenticación para administradores, panel de estadísticas, gestión de usuarios (roles/estado), categorías, moderación de reportes y comentarios, envío de notificaciones y utilidades de analítica (series diarias y mapa de calor).  
Opera sobre PostgreSQL a través del módulo `db` y usa **transacciones** cuando se requiere consistencia ACID.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|---|---|
| **Autenticación de administradores** | Valida credenciales y firma un JWT con expiración de 8h. |
| **Estadísticas del dashboard** | Obtiene contadores simultáneos (usuarios, reportes, reportes verificados, etc.). |
| **Gestión de usuarios** | Listar, actualizar **rol** (con verificación extra para promover a admin) y **estado** (activo/suspendido). |
| **Gestión de categorías** | Listar, crear (con control de unicidad), eliminar con validaciones de uso y protección de “Otro”. |
| **Moderación** | Revisar y resolver reportes de **comentarios** y de **usuarios** (desestimar, eliminar/suspender). |
| **Administración de reportes** | Listar con filtros; alternar visibilidad **verificado/oculto**; eliminar reportes. |
| **Solicitudes de revisión** | Listar y resolver solicitudes de líderes vecinales. |
| **Notificaciones** | Guardar notificaciones para múltiples usuarios y consultar/eliminar historial. |
| **Analítica** | Series por día (últimos 7), datos para **heatmap** (lat/lon), y **simulación** de predicciones. |

---

## 🧩 Dependencias utilizadas

| Librería / Módulo | Uso principal |
|---|---|
| `../config/db` | Pool de PostgreSQL y `getClient()` para transacciones. |
| `bcryptjs` | Comparación de contraseñas (`password_hash`). |
| `jsonwebtoken` | Firma de tokens JWT para sesiones de administrador. |
| `node-fetch` | Importado (no usado en este archivo). |
| `process.env.JWT_SECRET` | Llave para firmar el JWT. |

---

## 🧠 Flujo general del módulo

1. **Login admin**: verifica email/rol y contraseña → firma JWT (8h).  
2. **Panel**: obtiene contadores en paralelo con `Promise.all`.  
3. **Gestión**: endpoints de CRUD/acciones sobre usuarios, categorías, reportes y notificaciones.  
4. **Moderación**: usa **transacciones** (`getClient`, `BEGIN/COMMIT/ROLLBACK`) para operaciones que afectan varias tablas.  
5. **Analítica**: consultas agregadas (series de días) y datos geoespaciales para mapa de calor.

---

## 🧩 Endpoints / funciones definidas

### 1) `login(req, res)`
**Autenticación exclusiva para administradores**.  
- Busca usuario por `email` **y** `rol = 'admin'`.  
- Compara `password` con `password_hash` (bcrypt).  
- Firma JWT con `{ id, rol }` y expiración de **8h**.  
- **Errores**: 400 (faltan campos), 403 (credenciales/rol), 500 (interno).

---

### 2) `getDashboardStats(req, res)`
Obtiene, en **paralelo**, contadores esenciales:
- Total de usuarios.  
- Reportes `pendiente_verificacion` y `verificado`.  
- Comentarios y usuarios **reportados** (`estado = 'pendiente'`).

---

### 3) `getAllUsers(req, res)`
Listado de usuarios con columnas clave (`telefono`, `rol`, `status`, `fecha_registro` formateada).  
Ordenados por `id ASC`.

---

### 4) `updateUserRole(req, res)`
Actualiza el **rol** de un usuario (`ciudadano | lider_vecinal | admin`).  
- Si se promueve a **admin**, requiere `adminPassword` del **admin logueado** y la verifica contra su `password_hash`.  
- Devuelve el usuario actualizado.

---

### 5) `updateUserStatus(req, res)`
Actualiza `status` de un usuario (`activo | suspendido`).  
Devuelve `id`, `nombre`, `status`.

---

### 6) `getAllCategories(req, res)`
Retorna todas las categorías oficiales **ordenadas por nombre**.

---

### 7) `getCategorySuggestions(req, res)`
Obtiene **sugerencias** de categorías desde `reportes` cuyo `id_categoria` es **“Otro”**, excluyendo las ya existentes (comparación `LOWER()`), con **conteo** y **fecha más reciente**.

---

### 8) `createCategory(req, res)`
Crea una categoría (`INSERT … RETURNING *`).  
- Maneja error **`23505`** (unicidad → 409 “ya existe”).

---

### 9) `deleteCategory(req, res)`
Elimina una categoría **con validaciones**:  
- No permite borrar **“Otro”**.  
- No permite borrar si existen `reportes` que la usan.

---

### 10) `getReportedComments(req, res)`
Lista comentarios **reportados** `pendiente` con `JOIN` a usuarios (autor/reportador) y comentario original.

---

### 11) `resolveCommentReport(req, res)`
**Transaccional**:  
- Si `action === 'eliminar_comentario'`: elimina el comentario original.  
- Luego marca el reporte de comentario como `resuelto`.

---

### 12) `getReportedUsers(req, res)`
Lista reportes de **usuarios** `pendiente` con datos del usuario reportado (id, nombre, email) y el `alias` del reportador.

---

### 13) `resolveUserReport(req, res)`
**Transaccional**:  
- Si `action === 'suspender_usuario'`: actualiza `status = 'suspendido'` en `usuarios`.  
- Marca el reporte de **usuario** como `resuelto`.

---

### 14) `getAllAdminReports(req, res)`
Lista reportes con `LEFT JOIN` a `usuarios` y `categorias`.  
**Filtros opcionales** (`?search`, `?status`, `?categoryId`):  
- `search`: por `titulo` o **nombre real** del autor.  
- Orden: `r.id DESC`.

---

### 15) `updateReportVisibility(req, res)`
Alterna estado **`verificado` ⇄ `oculto`** para un reporte (y actualiza `fecha_actualizacion`).

---

### 16) `getReviewRequests(req, res)`
Lista **solicitudes de revisión** (`sr`) pendientes de líderes, con título del reporte y alias del líder.

---

### 17) `resolveReviewRequest(req, res)`
Resuelve una solicitud de revisión:  
- **Aprobar**: `reportes.estado = 'pendiente_verificacion'` y `sr.estado = 'aprobada'`.  
- **Desestimar**: `sr.estado = 'desestimada'`.

---

### 18) `adminDeleteReport(req, res)`
Elimina un **reporte** por `id`.

---

### 19) `getReportsByDay(req, res)`
Serie de los últimos **7 días**: genera días con `generate_series` y cuenta `reportes` por fecha.

---

### 20) `getHeatmapData(req, res)`
Devuelve `[[lat, lon, 1], …]` para **heatmap** a partir de `reportes` **verificados** (`ST_Y/ST_X` de la columna `location`).

---

### 21) `runPredictionSimulation(req, res)`
Simulación **simplificada** basada en reglas:  
- Según `categoryName` y `increasePercent`, genera una predicción con **confianza** (baja/media).  
- *Nota*: es demostrativa; no es un modelo ML real.

---

### 22) `getSimulatedSmsLog(req, res)`
Lista de mensajes en `simulated_sms_log` ordenados por `fecha_envio DESC`.

---

### 23) `sendNotification(req, res)`
**Transaccional**: inserta una notificación por cada `userId` recibido.  
- Requiere `userIds[]`, `title`, `body`.

---

### 24) `getNotificationHistory(req, res)`
Historial de notificaciones con `JOIN` a `usuarios` para incluir **email** del receptor.

---

### 25) `deleteNotification(req, res)`
Elimina una notificación por `id`.

---

## 🧩 Ejemplos de uso (fragmentos)

```js
// 1) Login admin
POST /api/admin/login
Body: { "email": "...", "password": "..." }
-> 200 { token }

// 2) Cambiar rol (requiere auth admin)
PUT /api/admin/usuarios/:id/rol
Body: { "rol": "admin", "adminPassword": "..." }

// 3) Toggle visibilidad de reporte
PUT /api/admin/reportes/:id/visibility
Body: { "currentState": "verificado" }

// 4) Enviar notificaciones a múltiples usuarios
POST /api/admin/notificaciones
Body: { "userIds": [1,2,3], "title": "Alerta", "body": "Mensaje" }
