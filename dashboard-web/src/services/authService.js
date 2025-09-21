import axios from 'axios';

const API_URL = 'http://localhost:3000/api/admin';

const login = async (email, password) => {
  try {
    const response = await axios.post(API_URL + '/login', {
      email,
      password,
    });
    if (response.data.token) {
      localStorage.setItem('admin_token', response.data.token);
    }
    return response.data;
  } catch (error) {
    throw error.response.data;
  }
};

const logout = () => {
  localStorage.removeItem('admin_token');
};

const authService = {
  login,
  logout,
};

export default authService;