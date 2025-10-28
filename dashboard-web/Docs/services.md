services

import axios from 'axios';
import { io } from 'socket.io-client';

 CONFIGURACIÓN GLOBAL
const API_URL = import.meta.env.VITE_API_URL || '[http://localhost:3000/api/admin](http://localhost:3000/api/admin)';
const SOCKET_URL = import.meta.env.VITE_API_URL_SOCKET || '[http://localhost:3000](http://localhost:3000)';

SOCKET SERVICE

class SocketService {
socket = null;
isAuthenticated = false;

connect(token) {
if (this.socket && this.socket.connected) {
if (this.isAuthenticated) return;
}

```
if (this.socket) {
  this.socket.disconnect();
  this.socket = null;
}

this.socket = io(SOCKET_URL, {
  auth: { token: token ? `Bearer ${token}` : undefined },
  reconnection: true,
  transports: ['websocket'],
});

this.socket.on('connect', () => console.log('✅ Socket conectado al servidor.'));
this.socket.on('disconnect', () => {
  console.warn('⚠️ Socket desconectado.');
  this.isAuthenticated = false;
});
this.socket.on('authenticated', () => {
  this.isAuthenticated = true;
  console.log('🔒 Autenticado en el socket.');
});
this.socket.on('unauthorized', (err) => {
  console.error('❌ Error de autenticación en socket:', err.message);
  this.isAuthenticated = false;
});
```

}

disconnect() {
if (this.socket) {
this.socket.disconnect();
this.socket = null;
this.isAuthenticated = false;
console.log('🔌 Socket desconectado manualmente.');
}
}

joinRoom(roomId) {
if (this.socket) this.socket.emit('joinRoom', roomId);
}

leaveRoom(roomId) {
if (this.socket) this.socket.emit('leaveRoom', roomId);
}

sendMessage(roomId, message) {
if (this.socket) this.socket.emit('sendMessage', { roomId, message });
}

onMessage(callback) {
if (this.socket) this.socket.on('message', callback);
}

offMessage(callback) {
if (this.socket) this.socket.off('message', callback);
}
}

const socketService = new SocketService();

 AUTH SERVICE
const authService = {
async login(email, password) {
try {
const response = await axios.post(`${API_URL}/login`, { email, password });
return response.data;
} catch (error) {
console.error("Error en authService.login:", error.response?.data || error.message);
throw error.response?.data || new Error('Error de red al iniciar sesión');
}
},

logout() {
localStorage.removeItem('admin_token');
socketService.disconnect();
console.log("authService: Token removido y socket desconectado.");
},
};

ADMIN SERVICE

// 🔑 Headers de autenticación
const getAuthHeader = () => {
const token = localStorage.getItem('admin_token');
return token ? { Authorization: 'Bearer ' + token } : {};
};

// 🔍 Construye query string
const buildQueryString = (params) => {
if (!params) return '';
const query = Object.entries(params)
.filter(([, v]) => v !== undefined && v !== null && v !== '')
.map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(String(v))}`)
.join('&');
return query ? `?${query}` : '';
};

// --- Ejemplo de algunas funciones principales ---
const getDashboardStats = async () => {
const response = await axios.get(`${API_URL}/stats`, { headers: getAuthHeader() });
return response.data;
};

const getAllUsers = async (filters = {}) => {
const queryString = buildQueryString(filters);
const response = await axios.get(`${API_URL}/users${queryString}`, { headers: getAuthHeader() });
return response.data;
};

const updateUserRole = async (userId, rol, adminPassword = null) => {
const body = { rol, ...(adminPassword && { adminPassword }) };
const response = await axios.put(`${API_URL}/users/${userId}/role`, body, { headers: getAuthHeader() });
return response.data;
};

const updateUserStatus = async (userId, status) => {
const response = await axios.put(`${API_URL}/users/${userId}/status`, { status }, { headers: getAuthHeader() });
return response.data;
};

const getChatHistory = async (reportId) => {
const response = await axios.get(`http://localhost:3000/api/reportes/${reportId}/chat`, { headers: getAuthHeader() });
return response.data;
};

// --- Ejemplo de analíticas ---
const getReportsByCategory = async (dateRange) => {
const query = buildQueryString(dateRange);
const response = await axios.get(`${API_URL}/analytics/by-category${query}`, { headers: getAuthHeader() });
return response.data;
};

// --- Export principal del servicio administrativo ---
const adminService = {
getDashboardStats,
getAllUsers,
updateUserRole,
updateUserStatus,
getChatHistory,
getReportsByCategory,
};

//  EXPORTACIÓN UNIFICADA
export { authService, adminService, socketService };
