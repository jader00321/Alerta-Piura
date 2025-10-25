// src/components/Login/FormularioLogin.jsx
import React, { useState } from 'react';
import { TextField, Button, Typography, Box, Alert, CircularProgress } from '@mui/material';
import LockOutlinedIcon from '@mui/icons-material/LockOutlined'; // Icono para contraseña
import EmailOutlinedIcon from '@mui/icons-material/EmailOutlined'; // Icono para email
import InputAdornment from '@mui/material/InputAdornment';
import logo from '../../assets/logo.png'; // Ajusta la ruta a tu logo

// Componente Copyright
function Copyright(props) {
  return (
    <Typography variant="body2" color="text.secondary" align="center" {...props}>
      {'Copyright © '}
      Alerta Piura {new Date().getFullYear()}
      {'.'}
    </Typography>
  );
}

function FormularioLogin({ onLoginSubmit, error, loading }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    onLoginSubmit(email, password); // Llama a la función del padre
  };

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center', // Centrar verticalmente
        width: '100%',
        maxWidth: '400px', // Ancho máximo del formulario
        p: 3, // Padding interno
      }}
    >
      {/* Logo */}
      <Box
        component="img"
        src={logo}
        alt="Logo Alerta Piura"
        sx={{
            width: 120, // Tamaño ajustado
            height: 120,
            mb: 3, // Margen inferior
            border: (theme) => `3px solid ${theme.palette.divider}`, // Borde con color del tema
            borderRadius: '16px',
            p: 0.5
        }}
       />

      <Typography component="h1" variant="h5" sx={{ fontWeight: 'bold', mb: 1 }}>
        Ingreso de Administrador
      </Typography>
       <Typography color="text.secondary" sx={{ mb: 3 }}>
        Ingresa tus credenciales para acceder al panel.
       </Typography>


      <Box component="form" noValidate onSubmit={handleSubmit} sx={{ width: '100%' }}>
        <TextField
          margin="normal" required fullWidth
          label="Correo Electrónico"
          name="email"
          type="email"
          autoComplete="email" autoFocus
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          disabled={loading} // Deshabilitar si está cargando
           InputProps={{
             startAdornment: (
               <InputAdornment position="start">
                 <EmailOutlinedIcon color="action"/>
               </InputAdornment>
             ),
           }}
        />
        <TextField
          margin="normal" required fullWidth
          name="password" label="Contraseña"
          type="password"
          autoComplete="current-password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          disabled={loading} // Deshabilitar si está cargando
           InputProps={{
             startAdornment: (
               <InputAdornment position="start">
                 <LockOutlinedIcon color="action"/>
               </InputAdornment>
             ),
           }}
        />

        {/* Muestra el error si existe */}
        {error && <Alert severity="error" sx={{ mt: 2, width: '100%' }}>{error}</Alert>}

        <Button
          type="submit" fullWidth variant="contained"
          disabled={loading} // Deshabilitar si está cargando
          sx={{ mt: 3, mb: 2, py: 1.2, fontSize: '1rem', position: 'relative' }} // Ajuste de padding y posición
        >
          {loading ? <CircularProgress size={24} color="inherit" sx={{ position: 'absolute' }} /> : 'Iniciar Sesión'}
        </Button>

        <Copyright sx={{ mt: 5 }} />
      </Box>
    </Box>
  );
}

export default FormularioLogin;