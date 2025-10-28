import axios from 'axios';

/**
 * @file src/services/sosService.js
 * @module sosService
 * @description
 * Servicio para gestionar las llamadas a la API relacionadas con la
 * funcionalidad de SOS (Alertas de Pánico).
 * Interactúa con los endpoints de admin (`/api/admin`) para datos del dashboard
 * y con los endpoints de SOS (`/api/sos`) para operaciones de alertas.
 */

// URL base para endpoints SOS y Admin SOS
/**
 * URL base de la API para los endpoints de *administración* (lectura de dashboards).
 * @type {string}
 */
const API_URL_ADMIN = import.meta.env.VITE_API_URL_ADMIN || 'http://localhost:3000/api/admin';

/**
 * URL base de la API para los endpoints *específicos de SOS* (gestión de alertas).
 * @type {string}
 */
const API_URL_SOS = import.meta.env.VITE_API_URL_SOS || 'http://localhost:3000/api/sos'; // URL base para /sos

/**
 * Obtiene el token de autenticación del administrador desde localStorage.
 * @private
 * @returns {object} Un objeto de cabecera con el token 'Authorization: Bearer ...'
 * o un objeto vacío si no hay token.
 * @deprecated Esta función puede ser redundante si se está utilizando un interceptor
 * global de Axios para inyectar el token.
 */
// getAuthHeader ahora es global vía interceptor, pero podemos mantenerlo por si acaso
const getAuthHeader = () => {
  const token = localStorage.getItem('admin_token');
  return token ? { Authorization: 'Bearer ' + token } : {};
};

/**
 * Obtiene los datos agregados para el dashboard de SOS (ej. conteos).
 * Llama al endpoint de admin: `GET /api/admin/sos-dashboard`
 *
 * @async
 * @returns {Promise<object>} Una promesa que resuelve a los datos
 * para el dashboard (ej. `{ activeAlerts: 1, totalAlerts: 10, ... }`).
 */
const getSosDashboardData = async () => {
  const response = await axios.get(`${API_URL_ADMIN}/sos-dashboard`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene el historial de ubicaciones (coordenadas) para una alerta SOS específica.
 * Llama al endpoint de SOS: `GET /api/sos/:alertId/history`
 *
 * @async
 * @param {string|number} alertId - El ID de la alerta SOS.
 * @returns {Promise<Array<Array<number>>>} Una promesa que resuelve a un
 * array de coordenadas (historial), ej: `[[lat1, lng1], [lat2, lng2], ...]`.
 */
const getLocationHistory = async (alertId) => {
  const response = await axios.get(`${API_URL_SOS}/${alertId}/history`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Actualiza el estado (general, de atención o revisión) de una alerta SOS.
 * Llama al endpoint de SOS: `PUT /api/sos/:alertId/status`
 *
 * @async
 * @param {string|number} alertId - El ID de la alerta SOS a actualizar.
 * @param {object} updates - Un objeto con los campos a actualizar.
 * @param {boolean} [updates.revisada] - Marcar la alerta como revisada por un admin.
 * @param {string} [updates.estado_atencion] - Cambiar el estado de atención (ej: 'En Espera', 'En Curso', 'Atendida').
 * @param {string} [updates.estado] - Cambiar el estado general (ej: 'activo', 'finalizado').
 * @returns {Promise<object>} Una promesa que resuelve al objeto de la alerta actualizada.
 */
const updateStatus = async (alertId, updates) => {
  // updates podría ser { revisada: true }, { estado_atencion: 'En Curso' } o { estado: 'finalizado' }
  const response = await axios.put(`${API_URL_SOS}/${alertId}/status`, updates, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Objeto que agrupa los métodos del servicio de SOS.
 * @property {function} getSosDashboardData - Obtiene datos del dashboard de SOS.
 * @property {function} getLocationHistory - Obtiene el historial de ubicación de una alerta.
 * @property {function} updateStatus - Actualiza el estado de una alerta.
 */
const sosService = {
  getSosDashboardData,
  getLocationHistory,
  updateStatus,
};

export default sosService;