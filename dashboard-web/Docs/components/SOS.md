# 🚨 Módulo SOS

## 📘 Descripción General
Este módulo gestiona el sistema completo de alertas SOS de emergencia. Proporciona monitoreo en tiempo real, historial detallado, mapas interactivos y herramientas de gestión para administradores y equipos de respuesta.

---

## 🧩 Componentes Principales

| Componente | Propósito |
|------------|-----------|
| `DetalleAlertaSeleccionada.jsx` | Panel de detalles completos de alerta SOS |
| `FiltrosHistorialSOS.jsx` | Sistema avanzado de filtrado para historial SOS |
| `ListaAlertasSOS.jsx` | Lista interactiva de alertas con controles de estado |
| `MapaAlertaSOS.jsx` | Mapa interactivo con ubicación y herramientas |
| `PanelAlertaActiva.jsx` | Panel de estado en tiempo real de alertas activas |

---

## 🔍 DetalleAlertaSeleccionada

### 🎯 Funcionalidades
- **Información completa** de la alerta seleccionada
- **Timer en tiempo real** para alertas activas
- **Datos del usuario** y contacto de emergencia
- **Control de finalización** de alertas activas
- **Estados de carga** y selección

### 🎨 Estructura de Información
**Secciones principales:**
1. **Información Principal**: Código, timer activo, estado
2. **Datos del Usuario**: Alias, rol, email, teléfono
3. **Detalles de Alerta**: Fecha inicio, estado, atención
4. **Contacto Emergencia**: Teléfono y mensaje predefinido
5. **Acciones**: Botón de finalización

### 🔧 Componente DetailItem
```jsx
<DetailItem 
  icon={PersonIcon} 
  primary="Nombre / Alias" 
  secondary="Juan Pérez (Líder Vecinal)" 
/>