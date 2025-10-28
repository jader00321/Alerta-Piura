# 📱 Módulo SMS

## 📘 Descripción General
Este módulo gestiona el sistema completo de logs y seguimiento de mensajes SMS de emergencia (SOS) enviados a través de la plataforma. Proporciona herramientas avanzadas de filtrado, visualización y análisis de mensajes de alerta.

---

## 🧩 Componentes Principales

| Componente | Propósito |
|------------|-----------|
| `FiltrosSmsLog.jsx` | Sistema avanzado de filtrado para logs SMS |
| `ItemSmsLog.jsx` | Componente individual para mostrar cada registro SMS |
| `ListaSmsLog.jsx` | Lista paginada y gestionada de logs SMS |

---

## 🔍 FiltrosSmsLog

### 🎯 Sistema de Filtrado Avanzado
**Filtros disponibles:**
- 🔍 **Búsqueda textual**: Mensajes, contactos o alias
- 👤 **Selector de usuario**: Autocompletado con avatares
- 📅 **Rango de fechas**: Selectores con validación cruzada
- ⚡ **Presets rápidos**: Hoy, Últimos 7 días, Este mes
- 🗑️ **Limpieza completa**: Reset de todos los filtros

### 🎨 Interfaz de Filtros
```jsx
<FiltrosSmsLog
  filters={currentFilters}
  onFilterChange={updateFilters}
  loading={isLoading}
/>