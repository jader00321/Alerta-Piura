// src/components/Login/FormularioLogin.jsx
import React, { useState } from 'react';
import { TextField, Button, Typography, Box, Alert, CircularProgress } from '@mui/material';
import LockOutlinedIcon from '@mui/icons-material/LockOutlined';
import EmailOutlinedIcon from '@mui/icons-material/EmailOutlined';
import InputAdornment from '@mui/material/InputAdornment';
import logo from '../../assets/logo.png';

/**
 * Componente que muestra el texto de derechos de autor en el formulario.
 *
 * @component
 * @param {Object} props - Propiedades pasadas al componente Typography.
 * @returns {JSX.Element} Texto de copyright.
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
 * Formulario de inicio de sesión para administradores.
 * Permite ingresar correo y contraseña, mostrando estado de carga y errores.
 *
 * @component
 * @example
 * ```jsx
 * <FormularioLogin
 *   onLoginSubmit={(email, password) => console.log(email, password)}
 *   error="Credenciales incorrectas"
 *   loading={false}
 * />
 * ```
 *
 * @param {Object} props - Propiedades del componente.
 * @param {(email: string, password: string) => void} props.onLoginSubmit - Función que se ejecuta al enviar el formulario con las credenciales.
 * @param {string} [props.error] - Mensaje de error que se muestra si el inicio de sesión falla.
 * @param {boolean} [props.loading=false] - Indica si el formulario está en estado de carga.
 * @returns {JSX.Element} Formulario de login con validación básica y diseño estilizado con MUI.
 */
function FormularioLogin({ onLoginSubmit, error, loading }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  /**
   * Maneja el envío del formulario y ejecuta la función de login.
   * @param {React.FormEvent<HTMLFormElement>} e - Evento de envío del formulario.
   */
  const handleSubmit = (e) => {
    e.preventDefault();
    onLoginSubmit(email, password);
  };

  return (
    <Box
      sx={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        width: '100%',
        maxWidth: '400px',
        p: 3,
      }}
    >
      {/* Logo */}
      <Box
        component="img"
        src={logo}
        alt="Logo Alerta Piura"
        sx={{
          width: 120,
          height: 120,
          mb: 3,
          border: (theme) => `3px solid ${theme.palette.divider}`,
          borderRadius: '16px',
          p: 0.5,
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
          margin="normal"
          required
          fullWidth
          label="Correo Electrónico"
          name="email"
          type="email"
          autoComplete="email"
          autoFocus
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          disabled={loading}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <EmailOutlinedIcon color="action" />
              </InputAdornment>
            ),
          }}
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
          disabled={loading}
          InputProps={{
            startAdornment: (
              <InputAdornment position="start">
                <LockOutlinedIcon color="action" />
              </InputAdornment>
            ),
          }}
        />

        {error && (
          <Alert severity="error" sx={{ mt: 2, width: '100%' }}>
            {error}
          </Alert>
        )}

        <Button
          type="submit"
          fullWidth
          variant="contained"
          disabled={loading}
          sx={{ mt: 3, mb: 2, py: 1.2, fontSize: '1rem', position: 'relative' }}
        >
          {loading ? (
            <CircularProgress size={24} color="inherit" sx={{ position: 'absolute' }} />
          ) : (
            'Iniciar Sesión'
          )}
        </Button>

        <Copyright sx={{ mt: 5 }} />
      </Box>
    </Box>
  );
}

export default FormularioLogin;
