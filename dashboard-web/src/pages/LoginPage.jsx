import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { TextField, Button, Typography, Box, Alert, Paper, CssBaseline } from '@mui/material';
import authService from '../services/authService';
import { useAuth } from '../context/AuthContext'; // Importar el hook useAuth
import logo from '../assets/logo.png';
import loginBg from '../assets/login-bg.png';

/**
 * Copyright - Componente para mostrar el texto de copyright
 * @param {Object} props - Propiedades del componente
 * @returns {JSX.Element}
 */
function Copyright(props) {
  return (
    <Typography variant="body2" color="text.secondary" align="center" {...props}>
      {'Copyright © '}
      Alerta Piura {new Date().getFullYear()}
      {'.'}
    </Typography>
  );
}

/**
 * LoginPage - Página de inicio de sesión para administradores
 * @returns {JSX.Element}
 */
function LoginPage() {
  const navigate = useNavigate();
  const { login } = useAuth(); // Usar la función login del contexto
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  /**
   * Maneja el proceso de inicio de sesión
   * @param {Event} e - Evento del formulario
   */
  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const data = await authService.login(email, password);
      if (data.token) {
        login(data.token); // Llamar a la función del contexto para actualizar el estado global
        navigate('/');
      }
    } catch (err) {
      setError(err.message || 'Error al iniciar sesión.');
    }
  };

  return (
    <Box sx={{ display: 'flex', height: '100vh' }}>
      <CssBaseline />
      
      {/* Panel lateral con imagen */}
      <Box 
        sx={{ 
          flex: 1.5,
          display: { xs: 'none', sm: 'flex' },
          alignItems: 'center',
          justifyContent: 'center',
          p: { xs: 2, sm: 3, md: 8 },
          backgroundColor: '#1e1e1e'
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
            border: `6px solid ${'#333'}`,
            borderRadius: '16px',
            boxShadow: '0px 10px 30px rgba(0,0,0,0.5)',
          }}
        />
      </Box>
      
      {/* Panel de formulario de login */}
      <Box 
        component={Paper} 
        elevation={6} 
        square
        sx={{
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          p: { xs: 2, sm: 3, md: 4 },
        }}
      >
        <Box
          sx={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            width: '100%',
            maxWidth: '600px'
          }}
        >
          {/* Logo de la aplicación */}
          <img 
            src={logo} 
            alt="Alerta Piura Logo" 
            style={{ 
              width: '160px', 
              height: '160px', 
              border: `3px solid black`, 
              borderRadius: '16px', 
              padding: '5px'
            }} 
          />
          
          {/* Título de la página */}
          <Typography component="h1" variant="h5" sx={{ mt: 4, fontWeight: 'bold' }}>
            Ingreso de Administrador
          </Typography>

          {/* Formulario de login */}
          <Box component="form" noValidate onSubmit={handleLogin} sx={{ mt: 1, width: '100%' }}>
            <TextField
              margin="normal" 
              required 
              fullWidth
              label="Correo Electrónico"
              name="email"
              autoComplete="email" 
              autoFocus
              value={email}
              onChange={(e) => setEmail(e.target.value)}
            />
            <TextField
              margin="normal" 
              required 
              fullWidth
              name="password" 
              label="Contraseña"
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
            />
            {error && <Alert severity="error" sx={{ mt: 2, width: '100%' }}>{error}</Alert>}
            <Button
              type="submit" 
              fullWidth 
              variant="contained"
              sx={{ mt: 3, mb: 2, py: 1.5, fontSize: '1rem' }}
            >
              Iniciar Sesión
            </Button>
            <Copyright sx={{ mt: 5 }} />
          </Box>
        </Box>
      </Box>
    </Box>
  );
}

export default LoginPage;