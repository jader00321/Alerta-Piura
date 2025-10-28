# 📍 Documentación externa de `reportes.routes.js`

## 🧩 Ubicación del archivo
`/src/routes/reportes.routes.js`

---

## 📝 Descripción general
El archivo **`reportes.routes.js`** define las rutas principales para la **gestión de reportes ciudadanos** dentro de la aplicación.  
Incluye funcionalidades públicas para visualizar reportes, así como rutas protegidas para **crear**, **apoyar**, **comentar**, **eliminar** y **consultar detalles** de cada reporte.

Además, se integra con **Cloudinary** para la carga de imágenes, **PostGIS** para manejo de coordenadas geográficas y **JWT** para autenticación de usuarios.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Listar reportes** | Devuelve todos los reportes verificados junto con su ubicación geográfica. |
| **Crear reporte** | Permite a un usuario autenticado enviar un nuevo reporte con imagen, categoría, descripción y ubicación. |
| **Apoyar reporte** | Permite a un usuario dar o quitar apoyo (“me gusta”) a un reporte. |
| **Comentar reporte** | Permite dejar comentarios sobre un reporte específico. |
| **Eliminar reporte** | Permite al autor eliminar su propio reporte si aún no ha sido moderado. |
| **Historial de chat** | Obtiene el historial de mensajes asociados a un reporte. |
| **Calcular riesgo de zona** | Evalúa el nivel de riesgo en un área según reportes cercanos. |

---

## 📦 Dependencias utilizadas

| Módulo | Uso principal |
|---------|----------------|
| `express` | Creación del router y manejo de rutas HTTP. |
| `../controllers/reportes.controller` | Contiene la lógica de negocio para todas las operaciones relacionadas con reportes. |
| `../middleware/auth.middleware` | Protege las rutas que requieren autenticación mediante JWT. |
| `../config/cloudinary` | Gestiona la carga de imágenes a través del servicio Cloudinary. |

---

## 🧠 Flujo general del archivo

1. Se crea una instancia de `Router()` de Express.  
2. Se define el parser `jsonParser` para procesar los cuerpos JSON.  
3. Se definen primero las **rutas públicas**, seguidas de las rutas **protegidas con autenticación**.  
4. Se integran middlewares específicos:  
   - `authMiddleware`: protege rutas que requieren autenticación.  
   - `upload.single('foto')`: gestiona la subida de imágenes en reportes.  
5. Finalmente, se exporta el router configurado.

---

## 🗺️ Rutas definidas

| Método | Ruta | Middleware | Controlador | Descripción |
|---------|------|-------------|--------------|--------------|
| `GET` | `/` | — | `getAllReports` | Obtiene todos los reportes verificados con sus ubicaciones geográficas. |
| `GET` | `/riesgo-zona` | — | `getRiesgoZona` | Calcula el nivel de riesgo en una zona específica según reportes cercanos. |
| `GET` | `/:id` | — | `getReporteById` | Devuelve los detalles completos de un reporte específico (descripción, autor, apoyos, comentarios, etc.). |
| `GET` | `/:id/chat` | `authMiddleware` | `getChatHistory` | Obtiene el historial de chat asociado a un reporte. |
| `POST` | `/` | `authMiddleware`, `upload.single('foto')` | `createReport` | Crea un nuevo reporte ciudadano con imagen y ubicación. |
| `POST` | `/:id/apoyar` | `jsonParser`, `authMiddleware` | `apoyarReporte` | Da o quita un apoyo (“me gusta”) a un reporte. |
| `POST` | `/:id/comentarios` | `jsonParser`, `authMiddleware` | `createComentario` | Agrega un comentario a un reporte. |
| `DELETE` | `/:id` | `authMiddleware` | `eliminarReporte` | Elimina un reporte si pertenece al usuario y aún está pendiente de verificación. |

---

## 🧩 Ejemplos de uso (API)

### 📋 Obtener todos los reportes
```http
GET /api/reportes
→ 200 OK
[
  {
    "id": 12,
    "titulo": "Bache en la Av. Grau",
    "categoria": "Vial",
    "location": { "type": "Point", "coordinates": [-80.631, -5.198] }
  }
]
