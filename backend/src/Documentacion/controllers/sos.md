# 🚨 Documentación externa de `sos.controller.js`

## 🧩 Ubicación del archivo
`/src/controllers/sos.controller.js`

---

## 📝 Descripción general
El archivo **`sos.controller.js`** gestiona toda la lógica relacionada con el **sistema de alertas SOS** de la aplicación.  
Permite a los usuarios activar una alerta de emergencia, registrar actualizaciones de ubicación en tiempo real y consultar todas las alertas activas.  

Además, implementa un **simulador de envío de SMS** hacia contactos de emergencia y emite eventos **en tiempo real mediante Socket.IO**, notificando a otros clientes del sistema sobre nuevas alertas o movimientos.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Activar alerta SOS (`activateSos`)** | Crea una nueva alerta de emergencia asociada al usuario autenticado, registra la ubicación y simula el envío de un SMS al contacto de emergencia. |
| **Actualizar ubicación (`addLocationUpdate`)** | Registra nuevas coordenadas GPS para una alerta existente y las transmite por Socket.IO. |
| **Listar alertas activas (`getActiveSosAlerts`)** | Devuelve todas las alertas SOS actualmente activas con información del usuario asociado. |

---

## 📦 Dependencias utilizadas

| Librería / Módulo | Uso principal |
|--------------------|----------------|
| `../config/db` | Conexión y consultas SQL a PostgreSQL. |
| `socket.io` | Emisión de eventos en tiempo real (`new-sos-alert`, `sos-location-update`). |
| `PostGIS` | Gestión de coordenadas geográficas (`ST_MakePoint`, `ST_SetSRID`). |
| `req.user` | Información del usuario autenticado (proporcionada por el middleware JWT). |

---

## 🧠 Flujo general del módulo

1. **El usuario activa el SOS** desde la app móvil.  
2. Se crea un registro en la tabla `sos_alerts` y se asocia la ubicación inicial (`lat`, `lon`).  
3. Si se proporcionó un contacto de emergencia, se **simula el envío de SMS** y se almacena el mensaje en `simulated_sms_log`.  
4. Se emite un evento de Socket.IO `new-sos-alert` para notificar en tiempo real a los administradores o panel web.  
5. Las posiciones posteriores se registran con `addLocationUpdate` y se emite `sos-location-update` en vivo.  

---

## 🧩 Componentes / funciones definidas

### 1️⃣ `activateSos(req, res)`
Activa una **alerta SOS** para el usuario autenticado y registra la ubicación inicial.

#### 🔧 Parámetros de entrada (`req.body`)
| Campo | Tipo | Descripción |
|--------|------|-------------|
| `lat` | `float` | Latitud de la ubicación actual. |
| `lon` | `float` | Longitud de la ubicación actual. |
| `emergencyContact` | `object` | Objeto con los datos del contacto de emergencia (`nombre`, `telefono`, `mensaje`). |

#### 🧠 Lógica interna:
1. Crea una alerta:
   ```sql
   INSERT INTO sos_alerts (id_usuario) VALUES ($1) RETURNING *;
