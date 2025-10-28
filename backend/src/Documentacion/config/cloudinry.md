# ☁️ Documentación externa de `cloudinary.js`

## 🧩 Ubicación del archivo
`/src/config/cloudinary.js`

---

## 📝 Descripción general
El archivo **`cloudinary.js`** se encarga de la **configuración e integración del servicio Cloudinary** dentro del backend del proyecto.  
Su función principal es permitir la **subida, almacenamiento y optimización de imágenes** directamente en la nube, utilizando **Multer** como middleware de carga.  

Dentro de este archivo se configuran los siguientes aspectos:

1. **`cloudinary`** → Establece la conexión con la cuenta en la nube mediante credenciales seguras.  
2. **`CloudinaryStorage`** → Define las reglas de almacenamiento y transformación de imágenes.  
3. **`multer`** → Permite recibir archivos desde las peticiones HTTP (por ejemplo, formularios o APIs).  

Este módulo garantiza que las imágenes se suban con un tamaño y formato controlado, mejorando la eficiencia y seguridad del manejo de archivos en el servidor.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Configuración de Cloudinary** | Inicializa la conexión con las credenciales del entorno (`.env`). |
| **Definición del almacenamiento personalizado** | Crea una instancia de `CloudinaryStorage` que define la carpeta de destino, formatos permitidos y transformaciones. |
| **Integración con Multer** | Implementa `multer` para manejar las cargas de archivos y almacenarlas directamente en Cloudinary. |
| **Exportación del middleware `upload`** | Permite reutilizar la configuración de subida en controladores o rutas específicas. |

---

## 🧩 Componentes definidos

### 1. **Configuración de Cloudinary**
Establece las credenciales necesarias para la conexión segura con el servicio.

#### 🔧 Detalles:
- Utiliza las variables de entorno:
  - `CLOUDINARY_CLOUD_NAME`
  - `CLOUDINARY_API_KEY`
  - `CLOUDINARY_API_SECRET`
- Carga las variables desde el archivo `.env` usando `dotenv`.

---

### 2. **Configuración de almacenamiento (`CloudinaryStorage`)**
Define cómo se guardan y procesan las imágenes.

#### 🧠 Parámetros configurados:
- **`folder`**: `alerta_piura` (carpeta en la cuenta de Cloudinary).  
- **`allowed_formats`**: `['jpg', 'png', 'jpeg']` (formatos permitidos).  
- **`transformation`**: Redimensiona las imágenes a un máximo de `800x800` píxeles, manteniendo proporciones (`crop: 'limit'`).

---

### 3. **Integración con Multer**
Crea una instancia de `multer` que utiliza el almacenamiento configurado y la exporta como middleware.

```js
const upload = multer({ storage: storage });
module.exports = upload;
