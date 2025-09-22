import axios from 'axios';

const API_URL = 'http://localhost:3000/api/admin';

const getAuthHeader = () => {
  const token = localStorage.getItem('admin_token');
  return token ? { Authorization: 'Bearer ' + token } : {};
};

const getStats = async () => {
  const response = await axios.get(API_URL + '/stats', { headers: getAuthHeader() });
  return response.data;
};

const getAllUsers = async () => {
  const response = await axios.get(API_URL + '/users', { headers: getAuthHeader() });
  return response.data;
};

const updateUserRole = async (userId, rol, adminPassword = null) => {
  const body = { rol };
  if (adminPassword) {
    body.adminPassword = adminPassword;
  }
  const response = await axios.put(API_URL + `/users/${userId}/role`, body, { headers: getAuthHeader() });
  return response.data;
};
const updateUserStatus = async (userId, status) => {
    const body = { status };
  const response = await axios.put(API_URL + `/users/${userId}/status`, body, { headers: getAuthHeader() });
  return response.data;
};

const getAllCategories = async () => {
  const response = await axios.get(API_URL + '/categories', { headers: getAuthHeader() });
  return response.data;
};

const getCategorySuggestions = async () => {
  const response = await axios.get(API_URL + '/category-suggestions', { headers: getAuthHeader() });
  return response.data;
};

const createCategory = async (nombre) => {
  const response = await axios.post(API_URL + '/categories', { nombre }, { headers: getAuthHeader() });
  return response.data;
};

const deleteCategory = async (id) => {
  const response = await axios.delete(API_URL + `/categories/${id}`, { headers: getAuthHeader() });
  return response.data;
};

const getReportedComments = async () => {
  const response = await axios.get(API_URL + '/moderation/comments', { headers: getAuthHeader() });
  return response.data;
};

const resolveCommentReport = async (id, action) => {
  const response = await axios.put(API_URL + `/moderation/comments/${id}`, { action }, { headers: getAuthHeader() });
  return response.data;
};

const getReportedUsers = async () => {
  const response = await axios.get(API_URL + '/moderation/users', { headers: getAuthHeader() });
  return response.data;
};

const resolveUserReport = async (reportId, action, userId) => {
  const response = await axios.put(API_URL + `/moderation/users/${reportId}`, { action, userId }, { headers: getAuthHeader() });
  return response.data;
};

const getReviewRequests = async () => {
  const response = await axios.get(API_URL + '/reports/review-requests', { headers: getAuthHeader() });
  return response.data;
};
const resolveReviewRequest = async (id, action) => {
  const response = await axios.put(API_URL + `/reports/review-requests/${id}`, { action }, { headers: getAuthHeader() });
  return response.data;
};
const adminDeleteReport = async (id) => {
  const response = await axios.delete(API_URL + `/reports/${id}`, { headers: getAuthHeader() });
  return response.data;
};

const getAllAdminReports = async (filters = {}) => {
  const params = new URLSearchParams(filters).toString();
  const response = await axios.get(`${API_URL}/reports?${params}`, { headers: getAuthHeader() });
  return response.data;
};

const updateReportVisibility = async (id, currentState) => {
  const response = await axios.put(`${API_URL}/reports/${id}/visibility`, { currentState }, { headers: getAuthHeader() });
  return response.data;
};

const getChatHistory = async (reportId) => {
  const response = await axios.get(API_URL + `/reportes/${reportId}/chat`, { headers: getAuthHeader() });
  return response.data;
};

const getReportsByDay = async () => {
  const response = await axios.get(API_URL + '/stats/reports-by-day', { headers: getAuthHeader() });
  return response.data;
};

const getHeatmapData = async () => {
  const response = await axios.get(API_URL + '/reports/heatmap-data', { headers: getAuthHeader() });
  return response.data;
};

const runPrediction = async (categoryName, increasePercent) => {
  const response = await axios.post(API_URL + '/predict', { categoryName, increasePercent }, { headers: getAuthHeader() });
  return response.data;
};

const getSmsLog = async () => {
  const response = await axios.get(API_URL + '/sms-log', { headers: getAuthHeader() });
  return response.data;
};

const sendNotification = async (userIds, title, body) => {
  const response = await axios.post(API_URL + '/users/notify', { userIds, title, body }, { headers: getAuthHeader() });
  return response.data;
};

const getNotificationHistory = async () => {
  const response = await axios.get(API_URL + '/notifications-history', { headers: getAuthHeader() });
  return response.data;
};

const deleteNotification = async (id) => {
  const response = await axios.delete(API_URL + `/notifications-history/${id}`, { headers: getAuthHeader() });
  return response.data;
};

const getLatestPendingReports = async () => {
  const response = await axios.get(API_URL + '/reports/latest-pending', { headers: getAuthHeader() });
  return response.data;
};

const adminService = {
  getStats,
  getAllUsers,
  updateUserRole,
  updateUserStatus,
  getAllCategories,
  getCategorySuggestions,
  createCategory,
  deleteCategory,
  getReportedComments,
  resolveCommentReport,
  getReportedUsers,
  resolveUserReport,
  getAllAdminReports,
  getReviewRequests,
  resolveReviewRequest,
  adminDeleteReport,
  updateReportVisibility,
  getHeatmapData,
  runPrediction,
  getChatHistory,
  getReportsByDay,
  getSmsLog,
  sendNotification,
  getNotificationHistory,
  deleteNotification,
  getLatestPendingReports,
};

export default adminService;