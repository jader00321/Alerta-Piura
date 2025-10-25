// src/pages/PaginaLogin.jsx
import React, { useState } from 'react';
//import { useNavigate } from 'react-router-dom';
import { Box, Paper, CssBaseline } from '@mui/material'; // Quitamos Grid de aquí
import authService from '../services/adminService'; // Asegúrate de que apunte al authService correcto
import { useAuth } from '../context/AuthContext';

// Importar componentes de Login
import PanelIlustracionLogin from '../components/Login/PanelIlustracionLogin';
import FormularioLogin from '../components/Login/FormularioLogin';

function PaginaLogin() {
  //const navigate = useNavigate();
  const { login } = useAuth();
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleLoginSubmit = async (email, password) => {
    setError('');
    setLoading(true);
    try {
      // Asumiendo que adminService.login es la función de authService
      // y que espera email y password, y retorna un objeto con { token: '...' }
      const data = await authService.login(email, password); // <- Aquí se usa adminService.login
      if (data && data.token) { // Asegúrate de que data y data.token existan
        login(data.token); // Actualizar contexto global y localStorage
        // navigate('/', { replace: true }); // La redirección la maneja App.jsx
      } else {
        setError('Respuesta inesperada del servidor: no se recibió token.');
      }
    } catch (err) {
      // Si adminService.login lanza un error, lo capturamos aquí
      const message = err.response?.data?.message || err.message || 'Error al iniciar sesión.';
      setError(message);
      console.error("Login error:", err); // Log para depuración
    } finally {
      setLoading(false);
    }
  };

  return (
    <Box sx={{
      display: 'flex',
      height: '100vh', // Ocupa toda la altura de la ventana
      flexDirection: { xs: 'column', md: 'row' }, // Columna en móvil, fila en desktop
      overflow: 'hidden', // Evita scroll principal si los hijos se ajustan
    }}>
      <CssBaseline />

      {/* Panel Izquierdo: Ilustración */}
      <Box sx={{
          flex: { xs: '0 0 30%', md: 1.5 }, // Ocupa 30% alto en móvil, flex:1.5 en desktop
          minHeight: { xs: '200px', md: 'auto' }, // Altura mínima para la imagen en móvil
          display: { xs: 'none', md: 'flex' }, // Oculto en XS, flex en MD y superior
          alignItems: 'center',
          justifyContent: 'center',
          bgcolor: 'background.default',
      }}>
          <PanelIlustracionLogin />
      </Box>

      {/* Panel Derecho: Formulario */}
      <Box
        component={Paper}
        elevation={6}
        square
        sx={{
          flex: { xs: '1 1 auto', md: 1 }, // Ocupa espacio restante en móvil, flex:1 en desktop
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          p: { xs: 2, sm: 3, md: 4 }, // Padding responsivo
          overflowY: 'auto', // Permite scroll solo si el formulario es muy largo
        }}
      >
        <FormularioLogin
            onLoginSubmit={handleLoginSubmit}
            error={error}
            loading={loading}
        />
      </Box>

    </Box>
  );
}

export default PaginaLogin;