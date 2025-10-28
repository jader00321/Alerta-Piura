# Manual Completo - Sistema de Administración Alerta Piura

## 📋 TABLA DE CONTENIDOS
- [Descripción General](#descripción-general)
- [Arquitectura del Sistema](#arquitectura-del-sistema)
- [Páginas y Componentes](#páginas-y-componentes)
- [Flujos de Trabajo](#flujos-de-trabajo)
- [API y Servicios](#api-y-servicios)
- [Configuración](#configuración)
- [Guías Rápidas](#guías-rápidas)
- [Soporte](#soporte)

---

## 🎯 DESCRIPCIÓN GENERAL

### Propósito del Sistema
Plataforma web de administración para gestionar reportes ciudadanos, alertas SOS, usuarios y contenido en tiempo real.

### Características Principales
- ✅ **Dashboard** con métricas en tiempo real
- ✅ **Gestión de Usuarios** y sistema de roles
- ✅ **Moderación de Contenido** con chat integrado
- ✅ **Alertas SOS** con geolocalización en vivo
- ✅ **Análisis Avanzado** y reportes exportables
- ✅ **Sistema de Notificaciones** masivas
- ✅ **WebSockets** para actualizaciones en tiempo real

### Tecnologías Utilizadas
| Tecnología | Versión | Uso |
|------------|---------|-----|
| React | 18.x | Framework principal |
| Material-UI | 5.x | Componentes UI |
| React Router | 6.x | Navegación |
| Socket.io | 4.x | Comunicación en tiempo real |
| JWT | - | Autenticación |
| date-fns | 2.x | Manejo de fechas |

---

## 🏗️ ARQUITECTURA DEL SISTEMA

### Estructura de Archivos
src/
├── components/ # Componentes reutilizables
│ ├── Analisis/ # Gráficos y métricas
│ ├── SOS/ # Alertas y mapas
│ ├── Usuarios/ # Gestión de usuarios
│ └── Comunes/ # Componentes compartidos
├── pages/ # Páginas principales
├── context/ # Estados globales
├── services/ # APIs y WebSockets
├── hooks/ # Hooks personalizados
└── assets/ # Imágenes y recursos

### Contextos Globales

#### AuthContext (Autenticación)
```javascript
// Uso en componentes
const { user, isAuthenticated, login, logout } = useAuth();

// Ejemplo de login
const handleLogin = async (email, password) => {
  const data = await authService.login(email, password);
  login(data.token); // Actualiza contexto y localStorage
};

1. Usuario crea reporte → Estado: Pendiente
2. Aparece en panel de administración
3. Administrador revisa y:
   - Aprueba → Estado: Verificado
   - Rechaza → Estado: Rechazado
   - Chatea → Solicita más información
4. Notificación al usuario del resultado

Flujo de alerta SOS
1. Usuario activa alerta SOS
2. Sistema notifica a todos los administradores
3. Alerta aparece en tiempo real con:
   - Ubicación en mapa
   - Temporizador countdown
   - Información del usuario
4. Administrador puede:
   - Cambiar estado de atención
   - Ver historial de ubicaciones
   - Finalizar manualmente
5. Notificaciones SMS a usuarios cercanos

FLUJO DE USUARIOS
1. Usuario solicita rol especial
2. Solicitud aparece en panel pendiente
3. Administrador evalúa y:
   - Aprueba rol + asigna zonas (líder)
   - Rechaza solicitud con motivo
4. Usuario recibe notificación del resultado
5. Para suspensiones: notificación y bloqueo

FLUJO DE CATEGORIAS
1. Usuario sugiere categoría nueva
2. Sugerencia aparece en panel pendiente
3. Administrador decide:
   - Aprobar → Crea categoría oficial
   - Fusionar → Mueve a categoría existente
   - Rechazar → Elimina sugerencia
4. Reordenar categorías para app móvil