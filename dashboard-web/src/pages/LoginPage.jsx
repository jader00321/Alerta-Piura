import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { TextField, Button, Typography, Box, Alert, Paper, CssBaseline } from '@mui/material';
import authService from '../services/authService';
import { useAuth } from '../context/AuthContext';
import logo from '../assets/logo.png';
import loginBg from '../assets/login-bg.png';

function Copyright(props) {
  return (
    <Typography variant="body2" color="text.secondary" align="center" {...props}>
      {'Copyright © '}
      Alerta Piura {new Date().getFullYear()}
      {'.'}
    </Typography>
  );
}

function LoginPage() {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    try {
      const data = await authService.login(email, password);
      if (data.token) {
        login(data.token);
        navigate('/');
      }
    } catch (err) {
      setError(err.message || 'Error al iniciar sesión.');
    }
  };

  return (
    <Box sx={{ display: 'flex', height: '100vh', width: '80vw' }}>
      <CssBaseline />
      
      {/* --- Panel Izquierdo (Imagen) --- */}
      <Box 
        sx={{ 
          flex: 8.5, 
          display: { xs: 'none', sm: 'flex' },
          alignItems: 'center',
          justifyContent: 'center',
          p: 4,
          backgroundColor: '#121212', 
          position: 'relative',
          overflow: 'hidden'
        }}
      >
        <Box
          component="img"
          src={loginBg}
          alt="Ilustración de seguridad"
          sx={{
            maxWidth: '110%',
            maxHeight: '90%',
            objectFit: 'cover', // Ajuste para llenar el marco si es necesario
            borderRadius: 4, // Bordes redondeados para el marco
            border: '1px solid rgba(255, 255, 255, 0.1)', // Borde sutil
            boxShadow: '0px 20px 40px rgba(0,0,0,0.6)', // Sombra profunda para el recuadro
            zIndex: 2
          }}
        />
      </Box>
      
      {/* --- Panel Derecho (Formulario) --- */}
      <Box 
        component={Paper} 
        elevation={0} 
        square
        sx={{
          flex: 5,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          p: { xs: 3, sm: 6, md: 8 },
          backgroundColor: 'background.paper'
        }}
      >
        <Box
          sx={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            width: '100%',
            maxWidth: '600px',
            p: 1,
            mb: 4,
            borderRadius: 4,
            boxShadow: '0px 20px 40px rgba(0,0,0,0.1)' // Sombra suave para el contenedor del formulario
          }}
        >
          {/* Logo con Recuadro y Sombra */}
          <Paper
            elevation={6} // Sombra fuerte para efecto flotante
            sx={{
              p: 1, // Espacio interno entre el borde y el logo
              borderRadius: 4, // Bordes redondeados (Cuadrado suavizado, NO circular)
              mb: 3,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              backgroundColor: 'white', // Fondo blanco para resaltar el logo
              border: '1px solid rgba(0,0,0,0.05)' // Borde sutil para definición
            }}
          >
            <Box 
              component="img"
              src={logo} 
              alt="Alerta Piura Logo" 
              sx={{ 
                width: 140, 
                height: 140, 
                objectFit: 'contain',
                // Opcional: Borde interno a la imagen si lo deseas
                // border: '1px solid #eee', 
                // borderRadius: 2 
              }} 
            />
          </Paper>
          
          <Typography component="h1" variant="h4" sx={{ fontWeight: 800, color: 'text.primary', mb: 1 }}>
            Bienvenido
          </Typography>
          <Typography variant="body1" color="text.secondary" sx={{ mb: 4 }}>
            Ingresa tus credenciales de administrador
          </Typography>

          <Box component="form" noValidate onSubmit={handleLogin} sx={{ width: '100%' }}>
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
              sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2 } }}
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
              sx={{ '& .MuiOutlinedInput-root': { borderRadius: 2 } }}
            />
            
            {error && (
              <Alert severity="error" sx={{ mt: 2, borderRadius: 2 }}>
                {error}
              </Alert>
            )}

            <Button
              type="submit" 
              fullWidth 
              variant="contained"
              size="large"
              sx={{ 
                mt: 4, 
                mb: 4, 
                py: 1.5, 
                fontSize: '1rem', 
                fontWeight: 'bold',
                borderRadius: 2, 
                textTransform: 'none', 
                boxShadow: 2
              }}
            >
              Iniciar Sesión
            </Button>
            
            <Copyright />
          </Box>
        </Box>
      </Box>
    </Box>
  );
}

export default LoginPage;