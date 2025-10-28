# 🧩 Archivo: `main.jsx`

## 📘 Descripción general

Este archivo representa el **punto de entrada principal** de la aplicación React.
Su propósito es inicializar la aplicación, renderizar el componente raíz `<App />` dentro del DOM y configurar el entorno global necesario para el funcionamiento de componentes y librerías.

---

## 🛠️ Funcionalidades principales

1. **Renderizado inicial de la aplicación**
   Crea el punto de montaje de React sobre el elemento con id `"root"` del archivo `index.html`.

2. **Modo estricto de React**
   Se usa `<React.StrictMode>` para detectar advertencias, efectos secundarios o malas prácticas durante el desarrollo.

3. **Configuración de localización (Date Picker)**
   Integra el proveedor `LocalizationProvider` del paquete `@mui/x-date-pickers`, utilizando `Day.js` como adaptador de fechas, configurado en idioma español (`es`).

4. **Estilos globales**
   Importa el archivo `index.css` que contiene los estilos globales de la aplicación.

---

## 📦 Importaciones utilizadas

| Módulo / Librería           | Descripción                                                    |
| --------------------------- | -------------------------------------------------------------- |
| `react`, `react-dom/client` | Librerías base de React y renderizado en el DOM.               |
| `App`                       | Componente raíz de la aplicación (`src/App.jsx`).              |
| `'./index.css'`             | Hoja de estilos global.                                        |
| `@mui/x-date-pickers`       | Proveedor de localización y adaptador de fechas (Material UI). |
| `dayjs`                     | Librería ligera para manipulación de fechas.                   |
| `'dayjs/locale/es'`         | Configuración regional española para Day.js.                   |

---

## 🧱 Flujo de ejecución

1. Se importa y configura `dayjs` para utilizar el idioma español.
2. Se inicializa el `LocalizationProvider` de MUI con `AdapterDayjs`.
3. Se renderiza la aplicación dentro del elemento raíz del DOM.
4. Toda la aplicación queda envuelta con soporte de localización para los componentes de fecha.

---

## 💡 Ejemplo simplificado del flujo

```jsx
ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <LocalizationProvider dateAdapter={AdapterDayjs} adapterLocale="es">
      <App />
    </LocalizationProvider>
  </React.StrictMode>,
);
```

---

## 🌎 Configuración de localización

```js
import dayjs from 'dayjs';
import 'dayjs/locale/es';
dayjs.locale('es');
```

> Esta configuración asegura que todos los componentes de selección de fecha (Date Pickers) muestren los textos y formatos en español.

---

## 🔗 Relación con otros módulos

| Módulo       | Relación                                                                   |
| ------------ | -------------------------------------------------------------------------- |
| `App.jsx`    | Es el componente principal que se renderiza desde `main.jsx`.              |
| `index.css`  | Define los estilos globales aplicados al renderizado inicial.              |
| `index.html` | Contiene el elemento `<div id="root"></div>` donde se monta la aplicación. |

---

## 🧾 Notas técnicas

* Este archivo debe permanecer en la raíz de `src/`.
* No contiene lógica de negocio; únicamente configura el entorno de renderizado.
* El uso de `React.StrictMode` **no afecta la ejecución en producción**, solo en modo desarrollo.

---

## 🧱 Ubicación en el proyecto

```
src/
│
├── main.jsx   ← Este archivo
├── App.jsx
├── index.css
└── ...
```

---

**Autor:** Equipo de desarrollo del Dashboard
**Última actualización:** Octubre 2025
