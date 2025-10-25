// src/components/Login/PanelIlustracionLogin.jsx
import React from 'react';
import { Box } from '@mui/material';
import loginBg from '../../assets/login-bg.png'; // Ajusta la ruta a tu imagen

function PanelIlustracionLogin() {
  return (
    <Box
      sx={{
        flex: 1.5, // Ocupa más espacio
        display: { xs: 'none', md: 'flex' }, // Oculto en pantallas pequeñas, visible en medianas y grandes
        alignItems: 'center',
        justifyContent: 'center',
        p: { sm: 4, md: 6 }, // Padding responsivo
        bgcolor: 'background.default', // Usar color de fondo del tema
      }}
    >
      <Box
        component="img"
        src={loginBg}
        alt="Ilustración de seguridad ciudadana"
        sx={{
          maxWidth: '100%',
          maxHeight: '100%',
          objectFit: 'contain',
          borderRadius: '16px', // Bordes redondeados
          boxShadow: '0px 10px 30px rgba(0,0,0,0.1)', // Sombra más sutil
        }}
      />
    </Box>
  );
}

export default PanelIlustracionLogin;