import React from 'react';
import { AppBar, Toolbar, Typography, Button } from '@mui/material';

function Header({ onLogout }) {
  return (
    <AppBar position="fixed" sx={{ zIndex: (theme) => theme.zIndex.drawer + 1 }}>
      <Toolbar>
        <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
          Panel de Administrador de Alerta Piura
        </Typography>
        <Button color="inherit" onClick={onLogout}>Cerrar Sesión</Button>
      </Toolbar>
    </AppBar>
  );
}

export default Header;