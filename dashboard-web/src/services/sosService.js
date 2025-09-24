import axios from 'axios';

const API_URL = 'http://localhost:3000/api';

const getAuthHeader = () => {
  const token = localStorage.getItem('admin_token');
  return token ? { Authorization: 'Bearer ' + token } : {};
};

const getSosDashboardData = async () => {
  const response = await axios.get(`${API_URL}/admin/sos-dashboard`, { headers: getAuthHeader() });
  return response.data;
};

const getLocationHistory = async (alertId) => {
  const response = await axios.get(`${API_URL}/sos/${alertId}/history`, { headers: getAuthHeader() });
  return response.data;
};

const updateStatus = async (alertId, updates) => {
  const response = await axios.put(`${API_URL}/sos/${alertId}/status`, updates, { headers: getAuthHeader() });
  return response.data;
};

const sosService = {
  getSosDashboardData,
  getLocationHistory,
  updateStatus,
};

export default sosService;