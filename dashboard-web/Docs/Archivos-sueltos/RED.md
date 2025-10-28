# ⚛️ Documentación de Configuración — Proyecto React + Vite

## 🧩 Descripción general

Este documento explica la estructura de configuración base del proyecto **React + Vite**, incluyendo:

- Configuración de **ESLint**.
- Configuración de **Vite**.
- Estructura y dependencias de **package.json**.
- Referencia al template oficial de Vite.

---

## 🚀 Proyecto base React + Vite

Este proyecto utiliza el **template oficial de React con Vite**, que ofrece un entorno ligero y rápido para el desarrollo moderno en JavaScript.

Incluye **HMR (Hot Module Replacement)** para recarga en tiempo real y un conjunto inicial de reglas **ESLint** para mantener la calidad del código.

Actualmente, existen dos complementos oficiales para React:

- [`@vitejs/plugin-react`](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react) — usa **Babel** para Fast Refresh.
- [`@vitejs/plugin-react-swc`](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react-swc) — usa **SWC** como alternativa más veloz.

> 💡 Para proyectos de producción se recomienda usar **TypeScript** con `typescript-eslint`.  
> Consulta el [template oficial React + TS](https://github.com/vitejs/vite/tree/main/packages/create-vite/template-react-ts) para más detalles.

---

## 📦 Archivo: `package.json`

### 🗂️ Descripción
Define las dependencias, scripts y metadatos del proyecto.  
Este archivo es el núcleo de configuración del entorno de desarrollo.

```json
{
  "name": "dashboard-web",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "lint": "eslint .",
    "preview": "vite preview"
  },
  "dependencies": {
    "@changey/react-leaflet-markercluster": "^4.0.0-rc1",
    "@emotion/react": "^11.14.0",
    "@emotion/styled": "^11.14.1",
    "@hello-pangea/dnd": "^18.0.1",
    "@mui/icons-material": "^7.3.1",
    "@mui/material": "^7.3.1",
    "@mui/x-date-pickers": "^8.14.1",
    "axios": "^1.11.0",
    "date-fns": "^4.1.0",
    "dayjs": "^1.11.18",
    "exceljs": "^4.4.0",
    "file-saver": "^2.0.5",
    "html2canvas": "^1.4.1",
    "jspdf": "^3.0.3",
    "jwt-decode": "^4.0.0",
    "leaflet": "^1.9.4",
    "react": "^19.1.1",
    "react-csv": "^2.2.2",
    "react-datepicker": "^8.7.0",
    "react-dom": "^19.1.1",
    "react-leaflet": "^5.0.0",
    "react-router-dom": "^7.8.2",
    "recharts": "^3.1.2",
    "socket.io-client": "^4.8.1"
  },
  "devDependencies": {
    "@eslint/js": "^9.33.0",
    "@types/react": "^19.1.10",
    "@types/react-dom": "^19.1.7",
    "@vitejs/plugin-react": "^5.0.0",
    "eslint": "^9.33.0",
    "eslint-plugin-react-hooks": "^5.2.0",
    "eslint-plugin-react-refresh": "^0.4.20",
    "globals": "^16.3.0",
    "vite": "^7.1.2"
  }
}
```

### 🧠 Explicación de secciones clave

| Sección | Descripción |
|----------|--------------|
| **scripts** | Comandos principales para ejecutar, compilar, lint y previsualizar el proyecto. |
| **dependencies** | Librerías de ejecución: React, MUI, Leaflet, Axios, etc. |
| **devDependencies** | Herramientas de desarrollo: ESLint, plugins de Vite, tipados, etc. |
| **type** | Define el tipo de módulo ES6 (`module`) para soporte `import/export`. |

---