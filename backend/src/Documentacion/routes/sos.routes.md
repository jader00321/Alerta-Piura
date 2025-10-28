# 🚨 Documentación externa de `sos.routes.js`

## 🧩 Ubicación del archivo
`/src/routes/sos.routes.js`

---

## 📝 Descripción general
El archivo **`sos.routes.js`** define las rutas relacionadas con el **sistema de alertas SOS**, una funcionalidad crítica que permite a los usuarios **enviar señales de emergencia** con su ubicación actual y un contacto de emergencia.

Todas las rutas están protegidas mediante el **middleware de autenticación (`authMiddleware`)**, garantizando que únicamente usuarios registrados puedan activar o gestionar alertas.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Activar alerta SOS** | Permite a un usuario iniciar una alerta de emergencia con ubicación y contacto asociado. |
| **Actualizar ubicación SOS** | Envía coordenadas en tiempo real durante una alerta activa. |
| **Listar alertas activas** | Devuelve todas las alertas SOS activas en el sistema para su monitoreo en tiempo real. |

---

## 📦 Dependencias utilizadas

| Módulo | Uso principal |
|---------|----------------|
| `express` | Creación del router y manejo de peticiones HTTP. |
| `../controllers/sos.controller` | Contiene la lógica de activación, seguimiento y recuperación de alertas SOS. |
| `../middleware/auth.middleware` | Protege las rutas mediante autenticación JWT. |

---

## 🧠 Flujo general del archivo

1. Se crea una instancia de `Router()` de Express.  
2. Se aplica el **middleware `authMiddleware`** a todas las rutas.  
3. Se define un parser JSON (`express.json()`) para procesar cuerpos de solicitudes.  
4. Se crean rutas para **activar una alerta**, **enviar actualizaciones de ubicación**, y **consultar alertas activas**.  
5. Se exporta el router configurado para su integración en el enrutador principal del backend.

---

## 🗺️ Rutas definidas

| Método | Ruta | Middleware | Controlador | Descripción |
|---------|------|-------------|--------------|--------------|
| `GET` | `/active` | `authMiddleware` | `getActiveSosAlerts` | Devuelve todas las alertas SOS activas, incluyendo datos del usuario que las generó. |
| `POST` | `/activate` | `jsonParser`, `authMiddleware` | `activateSos` | Activa una alerta SOS con ubicación y contacto de emergencia. |
| `POST` | `/:alertId/location` | `jsonParser`, `authMiddleware` | `addLocationUpdate` | Envía coordenadas de actualización de ubicación de una alerta activa. |

