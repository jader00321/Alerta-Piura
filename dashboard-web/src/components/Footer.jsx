import React from 'react';
import { Box, Typography, Link } from '@mui/material';

/**
 * Copyright - Componente para mostrar el texto de copyright
 * @returns {JSX.Element}
 */
function Copyright() {
  return (
    <Typography variant="body2" color="text.secondary" align="center">
      {'Copyright © '}
      <Link color="inherit" href="#">
        Alerta Piura
      </Link>{' '}
      {new Date().getFullYear()}
      {'.'}
    </Typography>
  );
}

/**
 * Footer - Componente de pie de página de la aplicación
 * @returns {JSX.Element}
 */
function Footer() {
  return (
    <Box sx={{ p: 2, mt: 'auto', backgroundColor: (theme) => theme.palette.background.paper }}>
      <Copyright />
    </Box>
  );
}

export default Footer;