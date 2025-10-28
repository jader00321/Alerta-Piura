# 📊 Módulo Análisis

## 📘 Descripción general
Este módulo muestra las métricas y gráficos del sistema Alerta Piura. Incluye visualización de datos analíticos, filtros por fecha, y exportación de reportes en PDF y Excel.

---

## 📁 Hooks internos
Ubicación: `src/components/Analisis/hooks/`

| Hook | Descripción |
|------|--------------|
| `useAnalisisData` | Obtiene datos de rendimiento del backend y gestiona el estado de análisis. |

---

## 🧱 Layout
Ubicación: `src/components/Analisis/layout/`

| Componente | Propósito |
|------------|-----------|
| `SeccionMetricas.jsx` | Layout para mostrar métricas/KPIs principales |
| `SeccionReportes.jsx` | Layout para análisis de reportes con múltiples gráficos |
| `SeccionUsuarios.jsx` | Layout para análisis de usuarios y líderes |

---

## 🛠️ Utilidades
Ubicación: `src/components/Analisis/utils/`

| Utilidad | Función |
|----------|---------|
| `contextHelpers.js` | Helpers para filtros y contexto de gráficos |
| `downloaderExcel.js` | Genera y descarga reportes en Excel |
| `downloaderPDF.js` | Genera y descarga reportes en PDF |

---

## 📊 Componentes de Gráficos

| Componente | Tipo | Descripción |
|------------|------|-------------|
| `GraficoBarrasSimple.jsx` | Barras horizontales | Distribución de datos categóricos |
| `GraficoLineaSimple.jsx` | Línea | Tendencias temporales |
| `GraficoTortaSimple.jsx` | Circular | Distribuciones porcentuales |
| `GraficoTasaAprobacion.jsx` | Circular | Tasa de aprobación vs rechazo |
| `GraficoTendenciaVerificacion.jsx` | Línea | Tiempo de verificación |

---

## 🎛️ Componentes de Interfaz

| Componente | Función |
|------------|---------|
| `FiltrosFechaAnalisis.jsx` | Selector de fechas y filtros |
| `SeccionAnalisis.jsx` | Contenedor para secciones |
| `TarjetaMetrica.jsx` | Valores métricos individuales |
| `TablaRendimientoLideres.jsx` | Rendimiento de líderes |

---

## 📤 Componentes de Exportación

| Componente | Propósito |
|------------|-----------|
| `ModalSeleccionExcel.jsx` | Selección contenido Excel |
| `ModalSeleccionPDF.jsx` | Selección contenido PDF |

---

## 🎨 Paletas de Colores

### Estados de Reportes
- `Pendiente`: #ff9800
- `Verificado`: #4caf50
- `Rechazado`: #f44336
- `Oculto`: #9e9e9e

### Estados de Usuarios
- `activo`: #4caf50
- `suspendido`: #f44336

---

## 🔄 Flujo de Datos

1. **Inicialización** → Hook carga datos iniciales
2. **Filtrado** → Usuario aplica filtros por fecha
3. **Actualización** → Datos se re-fetchean
4. **Renderizado** → Componentes muestran datos
5. **Exportación** → Usuario exporta reportes

---

## 📱 Características Técnicas

- ✅ **Responsive**: Móviles, tablets y desktop
- ✅ **Modular**: Componentes reutilizables
- ✅ **Accesible**: Buenas prácticas de accesibilidad
- ✅ **Performance**: Optimizado con hooks

---

## 🚀 Uso Básico

```jsx
import { useAnalisisData } from './hooks/useAnalisisData';
import SeccionReportes from './layout/SeccionReportes';

function AnalisisPage() {
  const { analyticsData, loading } = useAnalisisData(filterState, true);
  
  return (
    <SeccionReportes 
      analyticsData={analyticsData}
      loading={loading}
    />
  );
}