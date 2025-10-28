# 🧩 Documentación de Configuración del Proyecto

Este documento reúne la explicación detallada de los archivos de configuración **ESLint** y **Vite** utilizados en el proyecto React con Vite.

---

## 📘 1. Archivo: `eslint.config.js`

### 📄 Descripción general
Archivo de configuración **Flat Config** de **ESLint**, optimizado para proyectos React con Vite.  
Define las reglas de análisis estático para garantizar un código limpio, coherente y sin errores comunes.

---

### ⚙️ Configuración general
Incluye las siguientes características principales:
- **Extensiones recomendadas:**
  - `@eslint/js` → reglas base de JavaScript.
  - `eslint-plugin-react-hooks` → validación de los Hooks de React.
  - `eslint-plugin-react-refresh` → compatibilidad con Hot Module Replacement (HMR) de Vite.
- **Ignora:** el directorio `dist` (archivos de compilación).
- **Entorno:** navegador con soporte para sintaxis moderna (`ECMAScript 2020`) y JSX.

---

### 🧠 Fragmento principal
```js
import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import { defineConfig, globalIgnores } from 'eslint/config'

export default defineConfig([
  // Ignorados globales
  globalIgnores(['dist']),
  {
    files: ['**/*.{js,jsx}'],
    extends: [
      js.configs.recommended,
      reactHooks.configs['recommended-latest'],
      reactRefresh.configs.vite,
    ],
    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
      parserOptions: {
        ecmaVersion: 'latest',
        ecmaFeatures: { jsx: true },
        sourceType: 'module',
      },
    },
    rules: {
      // Personalización de 'no-unused-vars'
      'no-unused-vars': ['error', { varsIgnorePattern: '^[A-Z_]' }],
    },
  },
])
```

---

### 🧩 Regla personalizada destacada
#### `no-unused-vars`
- **Propósito:** Evita la declaración de variables sin uso.
- **Excepción:** Permite nombres de variables que empiecen con mayúscula o guion bajo (`React`, `_evento`).
- **Motivo:** útil en desestructuración de props o importaciones donde no todo se utiliza.

---

### ✅ Beneficios del ESLint configurado
- Detección temprana de errores comunes en React.
- Consistencia en el estilo de código entre todo el equipo.
- Mayor mantenibilidad y legibilidad.

---

## ⚡ 2. Archivo: `vite.config.js`

### 📄 Descripción general
Archivo de configuración de **Vite**, encargado de gestionar el empaquetado, la ejecución y la recarga rápida del proyecto React.

---

### ⚙️ Configuración principal
```js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
})
```

---

### 🧩 Elementos clave
- **`@vitejs/plugin-react`**: agrega compatibilidad con JSX, Fast Refresh y otras herramientas del ecosistema React.
- **`defineConfig`**: simplifica la escritura del archivo con autocompletado y validación de tipos.

---

### 🧰 Uso práctico
1. Instala las dependencias necesarias:
   ```bash
   npm install vite @vitejs/plugin-react
   ```
2. Ejecuta el servidor de desarrollo:
   ```bash
   npm run dev
   ```
3. Genera el build de producción:
   ```bash
   npm run build
   ```

---

## 🗂️ Ubicación sugerida
Colocar este documento en:

```
analisis/
└─ documentacion/
   └─ configuracion/
      └─ configuracion.md
```

---

### ✨ Resultado final
Con ambas configuraciones correctamente documentadas:

- **ESLint** asegura calidad y coherencia del código.  
- **Vite** proporciona un entorno moderno, rápido y eficiente para desarrollo React.  
Ambos conforman la base técnica del proyecto.

---
