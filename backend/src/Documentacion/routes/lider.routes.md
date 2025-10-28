# 🧭 Documentación externa de `lider.routes.js`

## 🧩 Ubicación del archivo
`/src/routes/lider.routes.js`

---

## 📝 Descripción general
El archivo **`lider.routes.js`** define todas las rutas relacionadas con las **funcionalidades de los líderes vecinales** dentro de la aplicación.  
Estas rutas permiten a los líderes **gestionar reportes locales**, **moderar contenido** y **solicitar revisiones**, actuando como intermediarios entre los ciudadanos y los administradores del sistema.

Todas las rutas están protegidas mediante el **middleware de autenticación (`authMiddleware`)**, lo que garantiza que solo los usuarios autenticados con el rol de líder puedan acceder a estas funciones.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Gestión de reportes pendientes** | Listar y moderar los reportes en estado pendiente dentro de su zona. |
| **Aprobación o rechazo de reportes** | Permite a los líderes aprobar o rechazar reportes ciudadanos. |
| **Visualización de reportes moderados** | Muestra todos los reportes ya revisados o gestionados por el líder. |
| **Gestión de reportes propios** | Permite revisar los comentarios o usuarios reportados directamente por el líder. |
| **Solicitud de revisión de reportes** | Permite enviar un reporte al panel administrativo para revisión adicional. |
| **Gestión de solicitudes** | Permite ver las solicitudes de revisión que el líder ha enviado. |

---

## 📦 Dependencias utilizadas

| Módulo | Uso principal |
|---------|----------------|
| `express` | Creación del router y manejo de rutas HTTP. |
| `../controllers/lider.controller` | Contiene la lógica principal de cada endpoint. |
| `../middleware/auth.middleware` | Verifica la autenticación mediante token JWT. |

---

## 🧠 Flujo general del archivo

1. Se crea una instancia de `Router()` para definir las rutas del líder.  
2. Se aplica **`authMiddleware`** de forma global a todas las rutas, garantizando autenticación.  
3. Se asignan las rutas correspondientes a las funciones del `liderController`.  
4. Se exporta el router para integrarlo en el enrutador principal del backend.

---

## 🗺️ Rutas definidas

| Método | Ruta | Middleware | Controlador | Descripción |
|---------|------|-------------|--------------|--------------|
| `GET` | `/reportes-pendientes` | `authMiddleware` | `getReportesPendientes` | Obtiene la lista de reportes en estado pendiente de verificación en la zona del líder. |
| `PUT` | `/reportes/:id/aprobar` | `authMiddleware` | `aprobarReporte` | Aprueba un reporte y lo marca como verificado. |
| `PUT` | `/reportes/:id/rechazar` | `authMiddleware` | `rechazarReporte` | Rechaza un reporte si no cumple con los criterios de validación. |
| `GET` | `/reportes-moderados` | `authMiddleware` | `getReportesModerados` | Lista los reportes ya moderados o revisados por el líder. |
| `GET` | `/me/comentarios-reportados` | `authMiddleware` | `getMisComentariosReportados` | Muestra los comentarios reportados por el líder vecinal. |
| `GET` | `/me/usuarios-reportados` | `authMiddleware` | `getMisUsuariosReportados` | Muestra los reportes de usuarios hechos por el líder. |
| `POST` | `/reportes/:id/solicitar-revision` | `authMiddleware` | `solicitarRevision` | Envía una solicitud de revisión de un reporte al administrador. |
| `GET` | `/me/solicitudes-revision` | `authMiddleware` | `getMisSolicitudesRevision` | Lista todas las solicitudes de revisión enviadas por el líder. |

---
