import axios from 'axios';
import socketService from './socketService'; // Importar para desconectar

/**
 * @file src/services/authService.js
 * @module authService
 * @description
 * Servicio para gestionar la autenticación del administrador (Login/Logout).
 * Interactúa con el endpoint de login de la API y maneja la limpieza
 * del token en localStorage y la desconexión del socket.
 */

// Asegúrate que la URL base para el endpoint de login sea correcta
/**
 * URL base de la API para los endpoints de administración.
 * Lee desde la variable de entorno `VITE_API_URL` o usa 'http://localhost:3000/api/admin'
 * como valor por defecto.
 * @type {string}
 */
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/admin';

/**
 * Envía las credenciales (email y password) al endpoint de login de la API.
 *
 * @async
 * @param {string} email - El email del administrador.
 * @param {string} password - La contraseña del administrador.
 * @returns {Promise<object>} Los datos de respuesta del servidor (generalmente
 * un objeto que incluye el token, ej: `{ token: '...' }`).
 * @throws {object} Lanza el objeto de error de la respuesta de Axios
 * (error.response.data) si el login falla (ej. credenciales incorrectas).
 */
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

/**
 * Realiza la limpieza local al cerrar sesión.
 *
 * Esta función elimina el 'admin_token' de localStorage y llama
 * a `socketService.disconnect()` para cerrar la conexión del socket.
 *
 * **Nota:** Este servicio no maneja la redirección de la UI; se espera
 * que `AuthContext` (o el componente que lo llame) gestione la
 * navegación del usuario a la página de login.
 *
 * @returns {void}
 */
const logout = () => {
  localStorage.removeItem('admin_token');
  socketService.disconnect(); // Desconectar el socket
  console.log("authService: Token removido y socket desconectado.");
  // No redirigir aquí, AuthContext lo hará
};

/**
 * Objeto que agrupa los métodos del servicio de autenticación.
 * @property {function} login - Función para iniciar sesión (async).
 * @property {function} logout - Función para cerrar sesión (limpieza local).
 */
const authService = {
  login,
  logout,
};

export default authService;