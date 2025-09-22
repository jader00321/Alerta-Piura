import React from 'react';
import { Box, Typography, Link } from '@mui/material';

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

function Footer() {
  return (
    <Box sx={{ p: 2, mt: 'auto', backgroundColor: (theme) => theme.palette.background.paper }}>
      <Copyright />
    </Box>
  );
}

export default Footer;