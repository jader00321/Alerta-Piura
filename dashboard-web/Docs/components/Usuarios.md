# 👥 Módulo Usuarios

## 📘 Descripción General
Este módulo gestiona el sistema completo de administración de usuarios. Proporciona herramientas para visualizar, gestionar y administrar todos los usuarios del sistema, incluyendo roles, estados, suscripciones y permisos especiales.

---

## 🧩 Componentes Principales

| Componente | Propósito |
|------------|-----------|
| `DrawerDetalleUsuario.jsx` | Panel lateral con detalles completos del usuario |
| `ModalAsignarZonas.jsx` | Modal para asignar zonas de moderación a líderes |
| `ModalNotificacion.jsx` | Modal para enviar notificaciones a usuarios |
| `PanelSolicitudesRol.jsx` | Panel de solicitudes de cambio de rol pendientes |
| `TarjetaUsuario.jsx` | Tarjeta individual de usuario en la lista principal |

---

## 🔍 DrawerDetalleUsuario

### 🎯 Funcionalidades Avanzadas
- **Sistema de pestañas** organizado (Perfil, Actividad, Acciones)
- **Información completa** del usuario con diseño visual mejorado
- **Gestión de roles** en tiempo real con selector desplegable
- **Panel de actividad** con insignias y reportes recientes
- **Acciones rápidas** integradas con confirmación mantenida

### 🎨 Estructura de Pestañas
**Pestaña 1: Perfil**
- Datos personales (teléfono, fecha registro, puntos)
- Información de suscripción (plan activo, fecha fin)
- Diseño con tarjetas separadas y bordes visuales

**Pestaña 2: Actividad**
- Grid de insignias obtenidas con tooltips
- Lista de reportes recientes con estado de urgencia
- Estados de carga específicos para cada sección

**Pestaña 3: Acciones**
- Cambio de rol con selector completo
- Botones de acción rápida (Suspender/Reactivar, Notificar, Asignar Zonas)
- Integración con `BotonConfirmacionMantenida` para acciones críticas

### 🔧 Componentes Especializados
```jsx
// InfoItem reutilizable para datos estructurados
<InfoItem 
  icon={<PhoneIcon />} 
  label="Teléfono" 
  value={selectedUser.telefono} 
/>

// Sistema de pestañas con iconos
<Tabs value={tabIndex} onChange={handleTabChange} variant="fullWidth">
  <Tab label="Perfil" icon={<PersonIcon />} iconPosition="start" />
  <Tab label="Actividad" icon={<BarChartIcon />} iconPosition="start" />
  <Tab label="Acciones" icon={<SecurityIcon />} iconPosition="start" />
</Tabs>