# 📊 Módulo Resumen

## 📘 Descripción general
Este módulo proporciona componentes para visualizar resúmenes y estadísticas del sistema. Incluye gráficos, tablas y tarjetas métricas para el dashboard administrativo.

---

## 🧩 Componentes Principales

| Componente | Propósito |
|------------|-----------|
| `GraficoReportesDia.jsx` | Gráfico de barras de actividad diaria de reportes |
| `ModalDetalleReporteResumen.jsx` | Modal con detalles completos de un reporte |
| `TablaUltimosReportes.jsx` | Tabla de reportes pendientes de verificación |
| `TarjetaEstadistica.jsx` | Tarjeta individual para métricas KPI |

---

## 📈 GraficoReportesDia

### 🎯 Funcionalidades
- **Gráfico de barras** para actividad de reportes
- **Período de 7 días** por defecto
- **Estados de carga** con skeletons
- **Estados vacíos** con mensaje informativo
- **Tema adaptable** a modo claro/oscuro

### 🎨 Características Visuales
```jsx
<GraficoReportesDia
  chartData={dailyActivityData}
  loading={isLoading}
/>