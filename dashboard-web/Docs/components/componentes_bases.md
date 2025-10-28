# 🏗️ Componentes Base

## 📘 Descripción General
Este módulo contiene los componentes fundamentales y estructurales de la aplicación. Incluye elementos de UI reutilizables, componentes de layout y utilidades base que sirven como cimientos para toda la aplicación.

---

## 🧩 Componentes Principales

| Componente | Propósito |
|------------|-----------|
| `ChatModal.jsx` | Modal de chat en tiempo real para comunicación |
| `Footer.jsx` | Pie de página de la aplicación |
| `Header.jsx` | Barra de navegación superior |

---

## 💬 ChatModal

### 🎯 Sistema de Chat en Tiempo Real
**Características principales:**
- **Comunicación bidireccional** usando Socket.IO
- **Historial de mensajes** con carga automática
- **Auto-scroll** al final de la conversación
- **Burbujas de chat** estilizadas con Material-UI
- **Indicadores de estado** de conexión

### 🔧 Arquitectura Técnica
**Gestión de Estado:**
```javascript
const [messages, setMessages] = useState([]); // Mensajes del chat
const [newMessage, setNewMessage] = useState(''); // Mensaje en edición
const [loading, setLoading] = useState(true); // Estado de carga
const [isConnected, setIsConnected] = useState(false); // Estado socket