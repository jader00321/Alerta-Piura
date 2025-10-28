# 📋 Módulo Reportes

## 📘 Descripción general
Este módulo gestiona la visualización, filtrado y moderación de reportes del sistema. Incluye componentes para listar reportes, aplicar filtros avanzados, mostrar detalles completos y gestionar solicitudes de revisión.

---

## 🧩 Componentes Principales

| Componente | Propósito |
|------------|-----------|
| `DrawerDetalleReporte.jsx` | Panel lateral con detalles completos del reporte |
| `FiltrosReportes.jsx` | Sistema de filtros avanzados para reportes |
| `ItemReporteResumen.jsx` | Item individual en lista de reportes |
| `ListaReportes.jsx` | Lista paginada de reportes con estados |
| `PanelSolicitudesRevision.jsx` | Panel de solicitudes de revisión pendientes |

---

## 🔍 DrawerDetalleReporte

### 🎯 Funcionalidades
- **Visualización completa** de todos los datos del reporte
- **Mapa interactivo** con ubicación exacta usando Leaflet
- **Acciones de moderación** colapsables para ahorrar espacio
- **Información del autor** y verificador
- **Sistema de confirmación** para acciones críticas

### 🎨 Estructura del Drawer
```jsx
<DrawerDetalleReporte
  report={reportData}
  open={isOpen}
  onClose={handleClose}
  onActionCompleted={refreshData}
  onOpenChat={openChat}
/>