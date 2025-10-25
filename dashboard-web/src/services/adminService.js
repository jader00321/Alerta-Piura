// src/services/adminService.js
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/admin';

// Función de LOGIN para administradores
const login = async (email, password) => {
  const response = await axios.post(`${API_URL}/login`, { email, password });
  return response.data;
};

/**
 * Obtiene el header de autorización con el token JWT
 * @returns {Object} Header de autorización
 */
const getAuthHeader = () => {
  const token = localStorage.getItem('admin_token');
  return token ? { Authorization: 'Bearer ' + token } : {};
};

/**
 * Construye un query string filtrando valores nulos/undefined
 * @param {Object} params - Parámetros para el query string
 * @returns {string} Query string formateado
 */
const buildQueryString = (params) => {
  if (!params) return '';
  const query = Object.entries(params)
    .filter(([, value]) => value !== undefined && value !== null && value !== '')
    .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`)
    .join('&');
  return query ? `?${query}` : '';
};

// --- Dashboard & Stats ---

/**
 * Obtiene estadísticas generales del dashboard
 * @returns {Promise<Object>} Estadísticas del dashboard
 */
const getDashboardStats = async () => {
  const response = await axios.get(`${API_URL}/stats`, { headers: getAuthHeader() });
  return response.data;
};

// --- User Management ---

/**
 * Obtiene todos los usuarios con filtros opcionales
 * @param {Object} filters - Filtros para la búsqueda de usuarios
 * @returns {Promise<Array>} Lista de usuarios
 */
const getAllUsers = async (filters = {}) => {
  const queryString = buildQueryString(filters);
  const response = await axios.get(`${API_URL}/users${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Actualiza el rol de un usuario
 * @param {string} userId - ID del usuario
 * @param {string} rol - Nuevo rol del usuario
 * @param {string} adminPassword - Contraseña del administrador (para promociones sensibles)
 * @returns {Promise<Object>} Respuesta de la operación
 */
const updateUserRole = async (userId, rol, adminPassword = null) => {
  const body = { rol };
  if (adminPassword) {
    body.adminPassword = adminPassword;
  }
  const response = await axios.put(`${API_URL}/users/${userId}/role`, body, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Actualiza el estado de un usuario (activo/suspendido)
 * @param {string} userId - ID del usuario
 * @param {string} status - Nuevo estado del usuario
 * @returns {Promise<Object>} Respuesta de la operación
 */
const updateUserStatus = async (userId, status) => {
  const response = await axios.put(`${API_URL}/users/${userId}/status`, { status }, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene detalles completos de un usuario
 * @param {string} userId - ID del usuario
 * @returns {Promise<Object>} Detalles del usuario
 */
const getUserDetails = async (userId) => {
    const response = await axios.get(`${API_URL}/users/${userId}/details`, { headers: getAuthHeader() });
    return response.data;
};

/**
 * Obtiene un resumen de la actividad de un usuario
 * @param {string} userId - ID del usuario
 * @returns {Promise<Object>} Resumen del usuario
 */
const getUserSummary = async (userId) => {
    const response = await axios.get(`${API_URL}/users/${userId}/summary`, { headers: getAuthHeader() });
    return response.data;
};

/**
 * Obtiene las solicitudes de rol pendientes
 * @returns {Promise<Array>} Lista de solicitudes de rol
 */
const getSolicitudesRol = async () => {
  const response = await axios.get(`${API_URL}/solicitudes-rol`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Resuelve una solicitud de rol
 * @param {string} solicitudId - ID de la solicitud
 * @param {string} accion - Acción a realizar (aprobar/rechazar)
 * @returns {Promise<Object>} Respuesta de la operación
 */
const resolverSolicitudRol = async (solicitudId, accion) => {
  const response = await axios.put(`${API_URL}/solicitudes-rol/${solicitudId}`, { accion }, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Asigna zonas a un líder vecinal
 * @param {string} liderId - ID del líder
 * @param {Array} distritos - Array de distritos a asignar
 * @returns {Promise<Object>} Respuesta de la operación
 */
const asignarZonasLider = async (liderId, distritos) => {
  const response = await axios.post(`${API_URL}/lider/${liderId}/asignar-zonas`, { distritos }, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene las zonas asignadas a un líder
 * @param {string} liderId - ID del líder
 * @returns {Promise<Array>} Array de distritos asignados
 */
const getZonasAsignadas = async (liderId) => {
    const response = await axios.get(`${API_URL}/lider/${liderId}/asignar-zonas`, { headers: getAuthHeader() });
    return response.data;
};

// --- Category Management ---

/**
 * Obtiene todas las categorías oficiales
 * @returns {Promise<Array>} Lista de categorías
 */
const getAllCategories = async () => {
  const response = await axios.get(`${API_URL}/categories`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene categorías con estadísticas de uso
 * @returns {Promise<Array>} Lista de categorías con stats
 */
const getCategoriesWithStats = async () => {
  const response = await axios.get(`${API_URL}/categories/with-stats`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene sugerencias de categorías pendientes
 * @returns {Promise<Array>} Lista de sugerencias de categorías
 */
const getCategorySuggestions = async () => {
  const response = await axios.get(`${API_URL}/category-suggestions`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Crea una nueva categoría oficial
 * @param {string} nombre - Nombre de la categoría
 * @returns {Promise<Object>} Categoría creada
 */
const createCategory = async (nombre) => {
  const response = await axios.post(`${API_URL}/categories`, { nombre }, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Elimina una categoría oficial
 * @param {string} id - ID de la categoría
 * @returns {Promise<Object>} Respuesta de la operación
 */
const deleteCategory = async (id) => {
  const response = await axios.delete(`${API_URL}/categories/${id}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Reordena las categorías oficiales
 * @param {Array} orderedIds - Array de IDs en el orden deseado
 * @returns {Promise<Object>} Respuesta de la operación
 */
const reorderCategories = async (orderedIds) => {
  const response = await axios.put(`${API_URL}/categories/reorder`, { orderedIds }, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Fusiona una sugerencia de categoría con una categoría oficial
 * @param {string} sourceSuggestionName - Nombre de la sugerencia
 * @param {string} targetCategoryId - ID de la categoría objetivo
 * @returns {Promise<Object>} Respuesta de la operación
 */
const mergeCategorySuggestion = async (sourceSuggestionName, targetCategoryId) => {
  const response = await axios.post(`${API_URL}/categories/merge`, { sourceSuggestionName, targetCategoryId }, { headers: getAuthHeader() });
  return response.data;
};

// --- Report Management (Admin Level) ---

/**
 * Obtiene todos los reportes con filtros avanzados
 * @param {Object} filters - Filtros para la búsqueda
 * @returns {Promise<Object>} Reportes paginados
 */
const getAllAdminReports = async (filters = {}) => {
  const { search, status, categoryId, sortBy, page, suggestedOnly, distrito, planType, prioridad } = filters;
  const params = { search, status, categoryId, sortBy, page, suggestedOnly, distrito, planType, prioridad };
  const queryString = buildQueryString(params);
  const response = await axios.get(`${API_URL}/reports${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Actualiza la visibilidad de un reporte
 * @param {string} id - ID del reporte
 * @param {string} currentState - Estado actual del reporte
 * @returns {Promise<Object>} Respuesta de la operación
 */
const updateReportVisibility = async (id, currentState) => {
  const response = await axios.put(`${API_URL}/reports/${id}/visibility`, { currentState }, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Elimina un reporte (acción de administrador)
 * @param {string} id - ID del reporte
 * @returns {Promise<Object>} Respuesta de la operación
 */
const adminDeleteReport = async (id) => {
  const response = await axios.delete(`${API_URL}/reports/${id}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Resuelve un reporte (aprobar o rechazar)
 * @param {string} reportId - ID del reporte
 * @param {boolean} approve - True para aprobar, false para rechazar
 * @returns {Promise<Object>} Respuesta de la operación
 */
const resolveReport = async (reportId, approve) => {
  const endpoint = approve ? `/reports/${reportId}/approve` : `/reports/${reportId}/reject`;
  const response = await axios.put(`${API_URL}${endpoint}`, {}, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Establece un reporte como pendiente de verificación
 * @param {string} reportId - ID del reporte
 * @returns {Promise<Object>} Respuesta de la operación
 */
const setReportToPending = async (reportId) => {
  const response = await axios.put(`${API_URL}/reports/${reportId}/set-pending`, {}, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene los últimos reportes pendientes de moderación
 * @returns {Promise<Array>} Lista de reportes pendientes
 */
const getLatestPendingReports = async () => {
  const response = await axios.get(`${API_URL}/latest-pending`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene solicitudes de revisión de reportes
 * @returns {Promise<Array>} Lista de solicitudes de revisión
 */
const getReviewRequests = async () => {
  const response = await axios.get(`${API_URL}/review-requests`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Resuelve una solicitud de revisión
 * @param {string} id - ID de la solicitud
 * @param {string} action - Acción a realizar
 * @returns {Promise<Object>} Respuesta de la operación
 */
const resolveReviewRequest = async (id, action) => {
  const response = await axios.put(`${API_URL}/review-requests/${id}`, { action }, { headers: getAuthHeader() });
  return response.data;
};

// --- Moderation Content ---

/**
 * Obtiene comentarios reportados
 * @returns {Promise<Array>} Lista de comentarios reportados
 */
const getReportedComments = async () => {
  const response = await axios.get(`${API_URL}/moderation/comments`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Resuelve un reporte de comentario
 * @param {string} id - ID del reporte
 * @param {string} action - Acción a realizar
 * @returns {Promise<Object>} Respuesta de la operación
 */
const resolveCommentReport = async (id, action) => {
  const response = await axios.put(`${API_URL}/moderation/comments/${id}`, { action }, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene usuarios reportados
 * @returns {Promise<Array>} Lista de usuarios reportados
 */
const getReportedUsers = async () => {
  const response = await axios.get(`${API_URL}/moderation/users`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Resuelve un reporte de usuario
 * @param {string} reportId - ID del reporte
 * @param {string} action - Acción a realizar
 * @param {string} userId - ID del usuario reportado
 * @returns {Promise<Object>} Respuesta de la operación
 */
const resolveUserReport = async (reportId, action, userId) => {
  const response = await axios.put(`${API_URL}/moderation/users/${reportId}`, { action, userId }, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene el historial de moderación
 * @returns {Promise<Array>} Lista de acciones de moderación
 */
const getModerationHistory = async () => {
  const response = await axios.get(`${API_URL}/moderation/history`, { headers: getAuthHeader() });
  return response.data;
};

// --- Analytics ---

/**
 * Obtiene datos para el heatmap de reportes
 * @returns {Promise<Array>} Datos del heatmap
 */
const getHeatmapData = async () => {
  const response = await axios.get(`${API_URL}/heatmap-data`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene coordenadas de reportes para mapas
 * @returns {Promise<Array>} Coordenadas de reportes
 */
const getReportCoordinates = async () => {
  const response = await axios.get(`${API_URL}/report-coordinates`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene reportes agrupados por categoría
 * @param {Object} dateRange - Rango de fechas
 * @returns {Promise<Array>} Reportes por categoría
 */
const getReportsByCategory = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/by-category${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene reportes agrupados por estado
 * @param {Object} dateRange - Rango de fechas
 * @returns {Promise<Array>} Reportes por estado
 */
const getReportsByStatus = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/by-status${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene la tendencia de reportes en el tiempo
 * @param {Object} dateRange - Rango de fechas
 * @returns {Promise<Object>} Datos de tendencia
 */
const getReportTrend = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/report-trend${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene reportes agrupados por distrito
 * @param {Object} dateRange - Rango de fechas
 * @returns {Promise<Array>} Reportes por distrito
 */
const getReportsByDistrict = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/by-district${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene usuarios agrupados por estado
 * @returns {Promise<Array>} Usuarios por estado
 */
const getUsersByStatus = async () => {
  const response = await axios.get(`${API_URL}/analytics/users-by-status`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene el tiempo promedio de resolución de reportes
 * @param {Object} dateRange - Rango de fechas
 * @returns {Promise<Object>} Tiempo de resolución
 */
const getAverageResolutionTime = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/resolution-time${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene el tiempo promedio de verificación de reportes
 * @param {Object} dateRange - Rango de fechas
 * @returns {Promise<Object>} Tiempo de verificación
 */
const getAverageVerificationTime = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/verification-time${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene el rendimiento de los líderes vecinales
 * @param {Object} dateRange - Rango de fechas
 * @returns {Promise<Array>} Rendimiento de líderes
 */
const getLeaderPerformance = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/leader-performance${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Ejecuta una predicción de reportes
 * @param {string} categoryName - Nombre de la categoría
 * @param {number} increasePercent - Porcentaje de aumento
 * @returns {Promise<Object>} Resultado de la predicción
 */
const runPrediction = async (categoryName, increasePercent) => {
  const response = await axios.post(`${API_URL}/predict`, { categoryName, increasePercent }, { headers: getAuthHeader() });
  return response.data;
};

// --- Communication & Logs ---

/**
 * Envía notificaciones a usuarios
 * @param {Array} userIds - IDs de los usuarios
 * @param {string} title - Título de la notificación
 * @param {string} body - Cuerpo de la notificación
 * @returns {Promise<Object>} Respuesta de la operación
 */
const sendNotification = async (userIds, title, body) => {
  const response = await axios.post(`${API_URL}/users/notify`, { userIds, title, body }, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene el historial de notificaciones
 * @param {Object} filters - Filtros para la búsqueda
 * @returns {Promise<Object>} Historial de notificaciones
 */
const getNotificationHistory = async (filters = {}) => {
  const queryString = buildQueryString(filters);
  const response = await axios.get(`${API_URL}/notifications-history${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Elimina una notificación del historial
 * @param {string} id - ID de la notificación
 * @returns {Promise<Object>} Respuesta de la operación
 */
const deleteNotification = async (id) => {
  const response = await axios.delete(`${API_URL}/notifications-history/${id}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene el log de mensajes SMS
 * @param {Object} filters - Filtros para la búsqueda
 * @returns {Promise<Object>} Log de SMS
 */
const getSmsLog = async (filters = {}) => {
  const queryString = buildQueryString(filters);
  const response = await axios.get(`${API_URL}/sms-log${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

// --- SOS ---

/**
 * Obtiene datos del dashboard de SOS
 * @returns {Promise<Object>} Datos del dashboard SOS
 */
const getSosDashboardData = async () => {
    const response = await axios.get(`${API_URL}/sos-dashboard`, { headers: getAuthHeader() });
    return response.data;
};

// --- Chat ---

/**
 * Obtiene el historial de chat de un reporte
 * @param {string} reportId - ID del reporte
 * @returns {Promise<Array>} Historial de chat
 */
const getChatHistory = async (reportId) => {
    const response = await axios.get(`http://localhost:3000/api/reportes/${reportId}/chat`, { headers: getAuthHeader() });
    return response.data;
};

/**
 * Obtiene reportes agrupados por día
 * @param {Object} dateRange - Rango de fechas
 * @returns {Promise<Array>} Reportes por día
 */
const getReportsByDay = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/by-day${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene reportes agrupados por estado
 * @param {Object} dateRange - Rango de fechas
 * @returns {Promise<Array>} Reportes por estado
 */
const getReportsGroupedByStatus = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/reports-by-status${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

/**
 * Obtiene la tendencia del tiempo de verificación
 * @param {Object} dateRange - Rango de fechas
 * @returns {Promise<Object>} Tendencias de tiempo de verificación
 */
const getVerificationTimeTrend = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/verification-time-trend${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

const adminService = {
  // Login
  login,
  // Dashboard & Stats
  getDashboardStats,
  getReportsGroupedByStatus,
  // User Management
  getAllUsers,
  updateUserRole,
  updateUserStatus,
  getUserDetails,
  getUserSummary,
  getSolicitudesRol,
  resolverSolicitudRol,
  asignarZonasLider,
  getZonasAsignadas,
  // Category Management
  getAllCategories,
  getCategoriesWithStats,
  getCategorySuggestions,
  createCategory,
  deleteCategory,
  reorderCategories,
  mergeCategorySuggestion,
  // Report Management
  getAllAdminReports,
  updateReportVisibility,
  adminDeleteReport,
  resolveReport,
  setReportToPending,
  getLatestPendingReports,
  getReviewRequests,
  resolveReviewRequest,
  // Moderation
  getReportedComments,
  resolveCommentReport,
  getReportedUsers,
  resolveUserReport,
  getModerationHistory,
  // Analytics
  getHeatmapData,
  getReportCoordinates,
  getReportsByCategory,
  getReportsByStatus,
  getReportsByDistrict,
  getUsersByStatus,
  getAverageResolutionTime,
  getAverageVerificationTime,
  getLeaderPerformance,
  runPrediction,
  getReportsByDay,
  getVerificationTimeTrend,
  getReportTrend,
  // Communication & Logs
  sendNotification,
  getNotificationHistory,
  deleteNotification,
  getSmsLog,
  // SOS
  getSosDashboardData,
  // Chat
  getChatHistory,
};

export default adminService;