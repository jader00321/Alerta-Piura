import axios from 'axios';

const API_URL = 'http://localhost:3000/api/sos';

const getAuthHeader = () => {
  const token = localStorage.getItem('admin_token');
  return token ? { Authorization: 'Bearer ' + token } : {};
};

// This function now fetches real data
const getActiveAlerts = async () => {
  try {
    const response = await axios.get(API_URL + '/active', { headers: getAuthHeader() });
    return response.data;
  } catch (error) {
    console.error("Failed to fetch active alerts:", error);
    return [];
  }
};

const sosService = {
  getActiveAlerts,
};

export default sosService;