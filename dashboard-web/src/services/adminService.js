// src/services/adminService.js
import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/api/admin';

// ... (getAuthHeader, buildQueryString, getDashboardStats, getReportsByDay, etc.) ...

// Función de LOGIN para administradores
const login = async (email, password) => {
  const response = await axios.post(`${API_URL}/login`, { email, password });
  return response.data;
};

const getAuthHeader = () => {
  const token = localStorage.getItem('admin_token');
  return token ? { Authorization: 'Bearer ' + token } : {};
};

// Helper to build query strings, filtering out null/undefined values
const buildQueryString = (params) => {
  if (!params) return '';
  const query = Object.entries(params)
    .filter(([, value]) => value !== undefined && value !== null && value !== '')
    .map(([key, value]) => `${encodeURIComponent(key)}=${encodeURIComponent(String(value))}`)
    .join('&');
  return query ? `?${query}` : '';
};

// --- Dashboard & Stats ---
const getDashboardStats = async () => {
  const response = await axios.get(`${API_URL}/stats`, { headers: getAuthHeader() });
  return response.data;
};

// --- User Management ---
const getAllUsers = async (filters = {}) => {
  const queryString = buildQueryString(filters);
  const response = await axios.get(`${API_URL}/users${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

const updateUserRole = async (userId, rol, adminPassword = null) => {
  const body = { rol };
  if (adminPassword) {
    body.adminPassword = adminPassword;
  }
  const response = await axios.put(`${API_URL}/users/${userId}/role`, body, { headers: getAuthHeader() });
  return response.data;
};

const updateUserStatus = async (userId, status) => {
  const response = await axios.put(`${API_URL}/users/${userId}/status`, { status }, { headers: getAuthHeader() });
  return response.data;
};

const getUserDetails = async (userId) => {
    const response = await axios.get(`${API_URL}/users/${userId}/details`, { headers: getAuthHeader() });
    return response.data;
};

const getUserSummary = async (userId) => {
    const response = await axios.get(`${API_URL}/users/${userId}/summary`, { headers: getAuthHeader() });
    return response.data;
};

const getSolicitudesRol = async () => {
  const response = await axios.get(`${API_URL}/solicitudes-rol`, { headers: getAuthHeader() });
  return response.data;
};

const resolverSolicitudRol = async (solicitudId, accion) => {
  const response = await axios.put(`${API_URL}/solicitudes-rol/${solicitudId}`, { accion }, { headers: getAuthHeader() });
  return response.data;
};

const asignarZonasLider = async (liderId, distritos) => {
  // La ruta es POST /api/admin/lider/:id/asignar-zonas
  const response = await axios.post(`${API_URL}/lider/${liderId}/asignar-zonas`, { distritos }, { headers: getAuthHeader() });
  return response.data; // Devuelve { message }
};

// --- OBTENER ZONAS ASIGNADAS ---
const getZonasAsignadas = async (liderId) => {
    // La ruta es GET /api/admin/lider/:id/asignar-zonas
    const response = await axios.get(`${API_URL}/lider/${liderId}/asignar-zonas`, { headers: getAuthHeader() });
    return response.data; // Devuelve array de strings ['distrito1', 'distrito2'] o ['*']
};

// --- Category Management ---
const getAllCategories = async () => {
  const response = await axios.get(`${API_URL}/categories`, { headers: getAuthHeader() });
  return response.data;
};

const getCategoriesWithStats = async () => {
  const response = await axios.get(`${API_URL}/categories/with-stats`, { headers: getAuthHeader() });
  return response.data;
};

const getCategorySuggestions = async () => {
  const response = await axios.get(`${API_URL}/category-suggestions`, { headers: getAuthHeader() });
  return response.data;
};

const createCategory = async (nombre) => {
  const response = await axios.post(`${API_URL}/categories`, { nombre }, { headers: getAuthHeader() });
  return response.data;
};

const deleteCategory = async (id) => {
  const response = await axios.delete(`${API_URL}/categories/${id}`, { headers: getAuthHeader() });
  return response.data;
};

const reorderCategories = async (orderedIds) => {
  const response = await axios.put(`${API_URL}/categories/reorder`, { orderedIds }, { headers: getAuthHeader() });
  return response.data;
};

const mergeCategorySuggestion = async (sourceSuggestionName, targetCategoryId) => {
  const response = await axios.post(`${API_URL}/categories/merge`, { sourceSuggestionName, targetCategoryId }, { headers: getAuthHeader() });
  return response.data;
};

// --- Report Management (Admin Level) ---
const getAllAdminReports = async (filters = {}) => {
  const { search, status, categoryId, sortBy, page, suggestedOnly, distrito, planType, prioridad } = filters;
  const params = { search, status, categoryId, sortBy, page, suggestedOnly, distrito, planType, prioridad }; // <-- Incluir prioridad
  const queryString = buildQueryString(params);
  const response = await axios.get(`${API_URL}/reports${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

const updateReportVisibility = async (id, currentState) => {
  const response = await axios.put(`${API_URL}/reports/${id}/visibility`, { currentState }, { headers: getAuthHeader() });
  return response.data;
};

const adminDeleteReport = async (id) => {
  const response = await axios.delete(`${API_URL}/reports/${id}`, { headers: getAuthHeader() });
  return response.data;
};

// Combined approve/reject into resolveReport for consistency
const resolveReport = async (reportId, approve) => {
  const endpoint = approve ? `/reports/${reportId}/approve` : `/reports/${reportId}/reject`;
  const response = await axios.put(`${API_URL}${endpoint}`, {}, { headers: getAuthHeader() });
  return response.data;
};

const setReportToPending = async (reportId) => {
  const response = await axios.put(`${API_URL}/reports/${reportId}/set-pending`, {}, { headers: getAuthHeader() });
  return response.data;
};

const getLatestPendingReports = async () => {
  const response = await axios.get(`${API_URL}/latest-pending`, { headers: getAuthHeader() });
  return response.data;
};

const getReviewRequests = async () => {
  const response = await axios.get(`${API_URL}/review-requests`, { headers: getAuthHeader() });
  return response.data;
};

const resolveReviewRequest = async (id, action) => {
  const response = await axios.put(`${API_URL}/review-requests/${id}`, { action }, { headers: getAuthHeader() });
  return response.data;
};

// --- Moderation Content ---
const getReportedComments = async () => {
  const response = await axios.get(`${API_URL}/moderation/comments`, { headers: getAuthHeader() });
  return response.data;
};

const resolveCommentReport = async (id, action) => {
  const response = await axios.put(`${API_URL}/moderation/comments/${id}`, { action }, { headers: getAuthHeader() });
  return response.data;
};

const getReportedUsers = async () => {
  const response = await axios.get(`${API_URL}/moderation/users`, { headers: getAuthHeader() });
  return response.data;
};

const resolveUserReport = async (reportId, action, userId) => {
  const response = await axios.put(`${API_URL}/moderation/users/${reportId}`, { action, userId }, { headers: getAuthHeader() });
  return response.data;
};

const getModerationHistory = async () => {
  const response = await axios.get(`${API_URL}/moderation/history`, { headers: getAuthHeader() });
  return response.data;
};

// --- Analytics ---
const getHeatmapData = async () => {
  const response = await axios.get(`${API_URL}/heatmap-data`, { headers: getAuthHeader() });
  return response.data;
};

const getReportCoordinates = async () => {
  const response = await axios.get(`${API_URL}/report-coordinates`, { headers: getAuthHeader() });
  return response.data;
};

const getReportsByCategory = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/by-category${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

const getReportsByStatus = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/by-status${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

const getReportTrend = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/report-trend${queryString}`, { headers: getAuthHeader() });
  // Devuelve el objeto completo: { data: [], groupingType: '...' }
  return response.data; 
};

const getReportsByDistrict = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/by-district${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

const getUsersByStatus = async () => {
  const response = await axios.get(`${API_URL}/analytics/users-by-status`, { headers: getAuthHeader() });
  return response.data;
};

const getAverageResolutionTime = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/resolution-time${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

const getAverageVerificationTime = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/verification-time${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

const getLeaderPerformance = async (dateRange) => {
  const queryString = buildQueryString(dateRange);
  const response = await axios.get(`${API_URL}/analytics/leader-performance${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

const runPrediction = async (categoryName, increasePercent) => {
  const response = await axios.post(`${API_URL}/predict`, { categoryName, increasePercent }, { headers: getAuthHeader() });
  return response.data;
};

// --- Communication & Logs ---
// Note: Route changed in backend routes file, reflected here
const sendNotification = async (userIds, title, body) => {
  const response = await axios.post(`${API_URL}/users/notify`, { userIds, title, body }, { headers: getAuthHeader() });
  return response.data; // Devuelve { message }
};

const getNotificationHistory = async (filters = {}) => {
  const queryString = buildQueryString(filters);
  const response = await axios.get(`${API_URL}/notifications-history${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

const deleteNotification = async (id) => {
  const response = await axios.delete(`${API_URL}/notifications-history/${id}`, { headers: getAuthHeader() });
  return response.data;
};

const getSmsLog = async (filters = {}) => {
  const queryString = buildQueryString(filters); // Pasa { search, page, userId, startDate, endDate }
  const response = await axios.get(`${API_URL}/sms-log${queryString}`, { headers: getAuthHeader() });
  return response.data;
};

// --- SOS ---
const getSosDashboardData = async () => {
    const response = await axios.get(`${API_URL}/sos-dashboard`, { headers: getAuthHeader() });
    return response.data;
};

// --- Chat (Belongs to reports, check if needed in adminService) ---
const getChatHistory = async (reportId) => {
    // Corrected path - assuming chat is under reports, not admin
    const response = await axios.get(`http://localhost:3000/api/reportes/${reportId}/chat`, { headers: getAuthHeader() });
    return response.data;
};

const getReportsByDay = async (dateRange) => { // 1. Aceptar dateRange
  const queryString = buildQueryString(dateRange); // 2. Usar helper
  const response = await axios.get(`${API_URL}/analytics/by-day${queryString}`, { headers: getAuthHeader() }); // 3. Añadir query
  return response.data;
};

const getReportsGroupedByStatus = async (dateRange) => { // 1. Aceptar dateRange
  const queryString = buildQueryString(dateRange); // 2. Usar helper
  const response = await axios.get(`${API_URL}/analytics/reports-by-status${queryString}`, { headers: getAuthHeader() }); // 3. Añadir query
  return response.data;
};

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
  resolveReport, // Covers approve/reject
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