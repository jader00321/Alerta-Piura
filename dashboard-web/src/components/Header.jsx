// src/components/Header.jsx
import React from 'react';
import { AppBar, Toolbar, Typography, IconButton, Tooltip, Box } from '@mui/material';
import LogoutIcon from '@mui/icons-material/Logout'; // Icon for logout

function Header({ onLogout }) {
  return (
    <AppBar
      position="fixed"
      sx={{
        zIndex: (theme) => theme.zIndex.drawer + 1,
        // Optional: Use a slightly different background or subtle border
        backgroundColor: 'background.paper', // Example if using dark mode paper color
        color: 'text.primary', // Example text color
        borderBottom: (theme) => `1px solid ${theme.palette.divider}`, // Subtle border
        boxShadow: 'none', // Remove default shadow if using border
      }}
      elevation={0} // Remove elevation if using border
    >
      <Toolbar sx={{ justifyContent: 'space-between' }}>
        <Typography variant="h6" noWrap component="div" sx={{ fontWeight: 'bold' }}>
          Alerta Piura - Admin
        </Typography>
        <Tooltip title="Cerrar Sesión">
          <IconButton color="inherit" onClick={onLogout}>
            <LogoutIcon />
          </IconButton>
        </Tooltip>
      </Toolbar>
    </AppBar>
  );
}

export default Header;