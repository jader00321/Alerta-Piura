import axios from 'axios';

const API_URL = 'http://localhost:3000/api/sos';

const getAuthHeader = () => {
  const token = localStorage.getItem('admin_token');
  return token ? { Authorization: 'Bearer ' + token } : {};
};

const getAllAlerts = async () => {
  const response = await axios.get(API_URL + '/all', { headers: getAuthHeader() });
  return response.data;
};

const getLocationHistory = async (alertId) => {
  const response = await axios.get(API_URL + `/${alertId}/history`, { headers: getAuthHeader() });
  return response.data;
};

const updateStatus = async (alertId, updates) => {
  const response = await axios.put(API_URL + `/${alertId}/status`, updates, { headers: getAuthHeader() });
  return response.data;
};

const sosService = {
  getAllAlerts,
  getLocationHistory,
  updateStatus,
};

export default sosService;