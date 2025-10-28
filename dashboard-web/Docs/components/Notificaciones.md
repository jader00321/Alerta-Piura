# 🔔 Módulo Notificaciones

## 📘 Descripción general
Este módulo gestiona el sistema de notificaciones del administrador. Permite enviar, gestionar y consultar el historial de notificaciones a usuarios del sistema.

---

## 🧩 Componentes Principales

| Componente | Propósito |
|------------|-----------|
| `DetallesUsuarioNotificaciones.jsx` | Panel de detalles del usuario seleccionado |
| `FiltrosNotificaciones.jsx` | Filtros por fecha para notificaciones |
| `ItemHistorialNotificacion.jsx` | Item individual del historial de notificaciones |
| `ListaHistorialNotificaciones.jsx` | Lista paginada del historial de notificaciones |
| `SelectorUsuarioNotificaciones.jsx` | Autocompletado para seleccionar usuarios |

---

## 👤 DetallesUsuarioNotificaciones

### 🎯 Funcionalidades
- **Panel informativo** del usuario seleccionado
- **Chips visuales** para estado, rol y plan
- **Contadores** de notificaciones totales y filtradas
- **Estados de carga** y selección

### 🎨 Componentes Chip
```jsx
<StatusChip status="activo" />        // 🟢 Activo / 🔴 Suspendido
<RoleChip role="lider_vecinal" />     // 👥 Líder Vecinal
<PlanChip planNombre="Plan Premium" isPremium={true} /> // ⭐ Plan Premium