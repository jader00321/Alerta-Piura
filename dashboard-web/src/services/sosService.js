// src/services/sosService.js
import axios from 'axios';

// URL base para endpoints SOS y Admin SOS
const API_URL_ADMIN = import.meta.env.VITE_API_URL_ADMIN || 'http://localhost:3000/api/admin';
const API_URL_SOS = import.meta.env.VITE_API_URL_SOS || 'http://localhost:3000/api/sos'; // URL base para /sos

// getAuthHeader ahora es global vía interceptor, pero podemos mantenerlo por si acaso
const getAuthHeader = () => {
  const token = localStorage.getItem('admin_token');
  return token ? { Authorization: 'Bearer ' + token } : {};
};

// Obtiene datos para el dashboard (usa ruta admin)
const getSosDashboardData = async () => {
  const response = await axios.get(`${API_URL_ADMIN}/sos-dashboard`, { headers: getAuthHeader() });
  return response.data;
};

// Obtiene historial de ubicaciones (usa ruta sos)
const getLocationHistory = async (alertId) => {
  const response = await axios.get(`${API_URL_SOS}/${alertId}/history`, { headers: getAuthHeader() });
  return response.data;
};

// Actualiza estado de atención o estado general (usa ruta sos)
const updateStatus = async (alertId, updates) => {
  // updates podría ser { revisada: true }, { estado_atencion: 'En Curso' } o { estado: 'finalizado' }
  const response = await axios.put(`${API_URL_SOS}/${alertId}/status`, updates, { headers: getAuthHeader() });
  return response.data;
};

const sosService = {
  getSosDashboardData,
  getLocationHistory,
  updateStatus,
};

export default sosService;