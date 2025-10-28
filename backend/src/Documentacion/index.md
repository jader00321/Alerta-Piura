# 🚀 Documentación externa de `index.js`

## 🧩 Ubicación del archivo
`/src/index.js`

---

## 📝 Descripción general
El archivo **`index.js`** es el **punto de entrada principal** del backend del proyecto.  
Se encarga de **inicializar el servidor Express**, configurar el **sistema de rutas**, habilitar la **comunicación en tiempo real** mediante **Socket.IO**, y establecer la conexión con la base de datos PostgreSQL a través del módulo `db.js`.

Además, implementa la configuración de **CORS**, **middlewares globales** y un **endpoint de prueba (healthcheck)** para verificar el estado del servidor.

---

## ⚙️ Funcionalidades principales

| Funcionalidad | Descripción |
|----------------|--------------|
| **Inicialización del servidor** | Crea y ejecuta una instancia del servidor Express y HTTP. |
| **Configuración de WebSockets** | Implementa `socket.io` para la comunicación en tiempo real entre cliente y servidor. |
| **Gestión de rutas principales** | Define y organiza todos los módulos de rutas de la aplicación. |
| **Conexión con base de datos** | Importa el módulo `db.js` para ejecutar consultas SQL desde los controladores. |
| **Middleware de CORS y JSON** | Permite comunicación segura entre cliente y servidor y parseo de datos. |
| **Sistema de chat en tiempo real** | Permite envío y recepción de mensajes entre usuarios dentro de reportes específicos. |
| **Healthcheck API** | Endpoint `/api/healthcheck` para comprobar el estado del servidor. |

---

## 📦 Dependencias utilizadas

| Paquete | Uso principal |
|----------|----------------|
| `dotenv` | Carga de variables de entorno desde el archivo `.env`. |
| `express` | Framework base para la creación del servidor HTTP y las rutas. |
| `cors` | Configuración de permisos entre dominios (CORS). |
| `http` | Creación del servidor base sobre el cual se monta Socket.IO. |
| `socket.io` | Comunicación bidireccional en tiempo real entre clientes y el servidor. |
| `./config/db.js` | Módulo de conexión a la base de datos PostgreSQL. |
| `./routes/*.js` | Conjunto de rutas modulares (autenticación, reportes, perfil, admin, SOS, etc.). |

---

## 🧩 Estructura general del servidor

```plaintext
index.js
├── Configuración inicial (dotenv, express, cors)
├── Integración de Socket.IO
├── Configuración de middlewares
├── Registro de rutas /api/*
├── Endpoint de prueba (/api/healthcheck)
└── Inicialización del servidor HTTP
