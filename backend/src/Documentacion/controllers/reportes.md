# 🗺️ Documentación externa de `reportes.controller.js`

## 🧩 Ubicación del archivo
`/src/controllers/reportes.controller.js`

---

## 📝 Descripción general
El archivo **`reportes.controller.js`** gestiona toda la **lógica de reportes ciudadanos**: creación de reportes con ubicación (PostGIS), obtención de listados y detalle, apoyos (like), comentarios asociados, eliminación por autor, **cálculo de riesgo por zona**, **historial de chat** por reporte y **zonas peligrosas** para el mapa.  
Incluye un helper transaccional `checkAndAwardBadges` que **otorga insignias** automáticamente según los puntos del usuario.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|---|---|
| **Listar reportes (`getAllReports`)** | Obtiene reportes verificados con su ubicación en **GeoJSON** y categoría. |
| **Crear reporte (`createReport`)** | Inserta un reporte con `location` (GeoJSON → `ST_GeomFromGeoJSON`), suma +10 puntos y otorga **insignias** si corresponde. |
| **Apoyar reporte (`apoyarReporte`)** | Toggle de apoyo: inserta o elimina el like ante duplicado (`23505`). |
| **Detalle de reporte (`getReporteById`)** | Devuelve datos completos del reporte, apoyos y sus comentarios con autor, fechas y ubicación. |
| **Comentar (`createComentario`)** | Agrega un comentario al reporte. |
| **Eliminar reporte propio (`eliminarReporte`)** | Permite cancelar un reporte **solo** si está `pendiente_verificacion`. |
| **Riesgo por zona (`getRiesgoZona`)** | Calcula un score simple según reportes verificados dentro de un radio (metros) con `ST_DWithin`. |
| **Historial de chat (`getChatHistory`)** | Lista mensajes de chat asociados al reporte (con alias del emisor). |
| **Zonas peligrosas (`getZonasPeligrosas`)** | Devuelve coordenadas de reportes verificados de categoría **Delito**. |
| **Otorgar insignias (`checkAndAwardBadges`)** | Helper: evalúa puntos e inserta nuevas insignias si aplica (evita duplicados). |

---

## 📦 Dependencias utilizadas

| Módulo / Tecnología | Uso principal |
|---|---|
| `../config/db` | Consultas a PostgreSQL y clientes transaccionales. |
| **PostGIS** (`ST_AsGeoJSON`, `ST_SetSRID`, `ST_GeomFromGeoJSON`, `ST_DWithin`, `ST_MakePoint`) | Geolocalización y geometrías. |
| **Transacciones** (`getClient`, `BEGIN/COMMIT/ROLLBACK`) | Atomicidad al crear reporte y otorgar insignias. |
| `req.user` (middleware) | Identidad del usuario autenticado (`id`). |

---

## 🧠 Flujo general del módulo

1. **Creación de reporte**: valida input → inicia transacción → inserta con geometría → suma +10 puntos → **check insignias** → COMMIT.  
2. **Lecturas**: listados y detalle con `JOIN` a **Usuarios** y **Categorias**, serializando ubicación en GeoJSON.  
3. **Interacciones**: apoyo **toggle** (insert/delete), comentarios, chat.  
4. **Geo**: consultas espaciales para riesgo por zona y extracción de hotspots (Delito).  

---

## 🧩 Componentes / funciones definidas

### 1) `checkAndAwardBadges(client, id_usuario)`
Helper transaccional que **otorga insignias** según puntos acumulados.

#### 🔧 Lógica interna:
- Obtiene `puntos` e **insignias ya ganadas**:
  ```sql
  SELECT puntos,
         ARRAY(SELECT id_insignia FROM usuario_insignias WHERE id_usuario = $1) AS insignias_ganadas
  FROM usuarios WHERE id = $1;
