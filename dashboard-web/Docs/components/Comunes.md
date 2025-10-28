# 🎯 Módulo Comunes

## 📘 Descripción general
Este módulo contiene componentes reutilizables y utilitarios para toda la aplicación. Incluye elementos de UI especializados y modales de confirmación.

---

## 🧩 Componentes Principales

| Componente | Propósito |
|------------|-----------|
| `BotonConfirmacionMantenida.jsx` | Botón que requiere mantener presionado para acciones críticas |
| `ModalConfirmacion.jsx` | Modal reutilizable para confirmaciones y alertas |

---

## 🔒 BotonConfirmacionMantenida

### 🎯 Casos de Uso
- **Eliminaciones** de datos importantes
- **Acciones irreversibles** 
- **Operaciones críticas** del sistema

### ⚙️ Props

| Prop | Tipo | Default | Descripción |
|------|------|---------|-------------|
| `onConfirm` | function | required | Callback al completar la confirmación |
| `label` | string | required | Texto del botón |
| `color` | string | 'primary' | Color MUI (primary, error, etc.) |
| `duration` | number | 2000 | Tiempo en ms para confirmar |
| `startIcon` | ReactNode | undefined | Icono opcional |

### 🎨 Características
- **Barra de progreso** visual durante la confirmación
- **Feedback táctil** con escala
- **Compatibilidad** mouse y touch
- **Limpieza automática** de timers

### 💡 Uso Básico
```jsx
<BotonConfirmacionMantenida
  label="Eliminar Usuario"
  color="error"
  duration={2500}
  onConfirm={() => eliminarUsuario(id)}
  startIcon={<DeleteIcon />}
/>