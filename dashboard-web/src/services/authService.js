// src/services/authService.js
import axios from 'axios';
import socketService from './socketService'; // Importar para desconectar

// Asegúrate que la URL base para el endpoint de login sea correcta
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/admin';

const login = async (email, password) => {
  try {
    // Llama al endpoint /login del backend de admin
    const response = await axios.post(`${API_URL}/login`, { email, password });
    // Devuelve los datos (que deben incluir el token)
    return response.data;
  } catch (error) {
    // Si hay un error (ej. 403 Forbidden), relanza la data del error
    // para que el componente Login pueda mostrar el mensaje
    console.error("Error en authService.login:", error.response?.data || error.message);
    throw error.response?.data || new Error('Error de red al intentar iniciar sesión');
  }
};

// Logout ahora se maneja principalmente en AuthContext para la navegación,
// pero este servicio puede encargarse de la limpieza local y del socket.
const logout = () => {
  localStorage.removeItem('admin_token');
  socketService.disconnect(); // Desconectar el socket
  console.log("authService: Token removido y socket desconectado.");
  // No redirigir aquí, AuthContext lo hará
};

const authService = {
  login,
  logout,
};

export default authService;