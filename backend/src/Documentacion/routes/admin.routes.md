# 🧭 Documentación externa de `admin.routes.js`

## 🧩 Ubicación del archivo
`/src/routes/admin.routes.js`

---

## 📝 Descripción general
El archivo **`admin.routes.js`** define todas las **rutas del panel administrativo** de la aplicación.  
Estas rutas permiten a los administradores gestionar usuarios, categorías, reportes, notificaciones y estadísticas del sistema.

El archivo integra los **middlewares de autenticación y autorización** para asegurar que solo los administradores puedan acceder a los endpoints críticos.  
Todas las funciones de negocio están delegadas al controlador `admin.controller.js`.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|-------------|
| **Autenticación de administrador** | Permite iniciar sesión y generar un token JWT. |
| **Gestión de usuarios** | Ver, editar roles y actualizar estados de usuarios. |
| **Gestión de categorías** | Crear, listar, sugerir y eliminar categorías de reportes. |
| **Moderación de contenido** | Revisar y resolver reportes de usuarios y comentarios. |
| **Administración de reportes** | Consultar, ocultar, eliminar o aprobar reportes. |
| **Análisis y estadísticas** | Consultar métricas del dashboard y datos de visualización (mapas, gráficas, predicciones). |
| **Notificaciones** | Enviar y consultar el historial de notificaciones a usuarios. |
| **Simulación de SMS** | Ver registros de mensajes simulados generados por alertas SOS. |

---

## 📦 Dependencias utilizadas

| Módulo | Uso principal |
|---------|----------------|
| `express` | Framework para definir rutas y middlewares. |
| `../controllers/admin.controller` | Contiene la lógica de negocio para todas las funciones administrativas. |
| `../middleware/auth.middleware` | Middleware de autenticación JWT (valida el token del usuario). |
| `../middleware/admin.middleware` | Middleware de autorización (verifica rol `admin`). |

---

## 🧠 Flujo general del módulo

1. **El administrador inicia sesión** a través de `/login` y obtiene un token JWT.  
2. Todas las rutas siguientes exigen autenticación (`authMiddleware`) o rol `admin` (`adminMiddleware`).  
3. Según la ruta, se ejecuta una función específica del controlador `admin.controller.js`.  
4. Las respuestas son devueltas en formato JSON con códigos de estado HTTP claros (200, 201, 403, 500, etc.).  

---

## 🧩 Definición de rutas

### 🔐 Autenticación
| Método | Endpoint | Middleware | Controlador | Descripción |
|---------|-----------|-------------|--------------|--------------|
| `POST` | `/login` | `jsonParser` | `login` | Inicia sesión como administrador y devuelve un token JWT. |

---

### 👥 Gestión de usuarios
| Método | Endpoint | Middleware | Controlador | Descripción |
|---------|-----------|-------------|--------------|--------------|
| `GET` | `/users` | `adminMiddleware` | `getAllUsers` | Lista todos los usuarios registrados. |
| `PUT` | `/users/:id/role` | `jsonParser`, `adminMiddleware` | `updateUserRole` | Cambia el rol de un usuario (por ejemplo, de “ciudadano” a “líder” o “admin”). |
| `PUT` | `/users/:id/status` | `jsonParser`, `adminMiddleware` | `updateUserStatus` | Activa o suspende una cuenta de usuario. |
| `POST` | `/users/notify` | `jsonParser`, `adminMiddleware` | `sendNotification` | Envía notificaciones personalizadas a uno o varios usuarios. |

---

### 🗂️ Categorías
| Método | Endpoint | Middleware | Controlador | Descripción |
|---------|-----------|-------------|--------------|--------------|
| `GET` | `/categories` | — | `getAllCategories` | Obtiene todas las categorías oficiales. |
| `GET` | `/category-suggestions` | `adminMiddleware` | `getCategorySuggestions` | Muestra sugerencias de categorías propuestas por usuarios. |
| `POST` | `/categories` | `jsonParser`, `adminMiddleware` | `createCategory` | Crea una nueva categoría oficial. |
| `DELETE` | `/categories/:id` | `adminMiddleware` | `deleteCategory` | Elimina una categoría (excepto “Otro”). |

---

### 🛠️ Moderación
| Método | Endpoint | Middleware | Controlador | Descripción |
|---------|-----------|-------------|--------------|--------------|
| `GET` | `/moderation/comments` | `adminMiddleware` | `getReportedComments` | Lista los comentarios reportados. |
| `PUT` | `/moderation/comments/:id` | `jsonParser`, `adminMiddleware` | `resolveCommentReport` | Marca un reporte de comentario como resuelto o elimina el comentario. |
| `GET` | `/moderation/users` | `adminMiddleware` | `getReportedUsers` | Lista los reportes de usuarios pendientes. |
| `PUT` | `/moderation/users/:id` | `jsonParser`, `adminMiddleware` | `resolveUserReport` | Resuelve un reporte de usuario (suspender o desestimar). |

---

### 📋 Reportes
| Método | Endpoint | Middleware | Controlador | Descripción |
|---------|-----------|-------------|--------------|--------------|
| `GET` | `/reports` | `adminMiddleware` | `getAllAdminReports` | Lista los reportes registrados en el sistema. |
| `GET` | `/reports/review-requests` | `adminMiddleware` | `getReviewRequests` | Lista las solicitudes de revisión enviadas por líderes vecinales. |
| `PUT` | `/reports/review-requests/:id` | `jsonParser`, `adminMiddleware` | `resolveReviewRequest` | Aprueba o rechaza una solicitud de revisión. |
| `PUT` | `/reports/:id/visibility` | `jsonParser`, `adminMiddleware` | `updateReportVisibility` | Alterna el estado de visibilidad (oculto/verificado). |
| `DELETE` | `/reports/:id` | `adminMiddleware` | `adminDeleteReport` | Elimina un reporte definitivamente. |

---

### 📈 Estadísticas y análisis
| Método | Endpoint | Middleware | Controlador | Descripción |
|---------|-----------|-------------|--------------|--------------|
| `GET` | `/stats` | `authMiddleware` | `getDashboardStats` | Obtiene estadísticas generales del panel administrativo. |
| `GET` | `/stats/reports-by-day` | `adminMiddleware` | `getReportsByDay` | Devuelve la cantidad de reportes creados en los últimos días. |
| `GET` | `/reports/heatmap-data` | `adminMiddleware` | `getHeatmapData` | Proporciona datos geográficos para generar mapas de calor. |
| `POST` | `/predict` | `jsonParser`, `adminMiddleware` | `runPredictionSimulation` | Ejecuta simulaciones predictivas basadas en categorías de reportes. |

---

### 💬 Notificaciones y SMS
| Método | Endpoint | Middleware | Controlador | Descripción |
|---------|-----------|-------------|--------------|--------------|
| `GET` | `/sms-log` | `adminMiddleware` | `getSimulatedSmsLog` | Obtiene el historial de SMS simulados. |
| `GET` | `/notifications-history` | `adminMiddleware` | `getNotificationHistory` | Muestra el historial completo de notificaciones enviadas. |
| `DELETE` | `/notifications-history/:id` | `adminMiddleware` | `deleteNotification` | Elimina una notificación específica del historial. |

---

## 🧩 Ejemplo de flujo básico

1. El administrador inicia sesión en `/login` → obtiene un **token JWT**.  
2. Usa ese token en los encabezados:  
