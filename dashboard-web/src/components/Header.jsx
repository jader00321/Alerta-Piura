import React from 'react';
import { AppBar, Toolbar, Typography, IconButton, Tooltip, Box } from '@mui/material';
import LogoutIcon from '@mui/icons-material/Logout'; // Icon for logout

/**
 * Renderiza la barra de navegación (AppBar) superior fija de la aplicación.
 *
 * Muestra el título "Alerta Piura - Admin" y un botón de "Cerrar Sesión" (Logout).
 * Está diseñada para estar por encima del `Sidebar` (controlado por `zIndex`).
 * Utiliza un estilo personalizado (sin sombra, con borde inferior) para
 * integrarse mejor con el layout.
 *
 * @param {object} props - Propiedades del componente.
 * @param {Function} props.onLogout - El callback que se ejecuta cuando el usuario
 * hace clic en el ícono de cerrar sesión.
 * @returns {JSX.Element} El componente AppBar de MUI.
 */
function Header({ onLogout }) {
  return (
    <AppBar
      position="fixed"
      sx={{
        zIndex: (theme) => theme.zIndex.drawer + 1, // Se asegura que esté sobre el Sidebar
        // Optional: Use a slightly different background or subtle border
        backgroundColor: 'background.paper', // Usa el color del 'paper' del tema
        color: 'text.primary', // Usa el color de texto primario del tema
        borderBottom: (theme) => `1px solid ${theme.palette.divider}`, // Borde inferior sutil
        boxShadow: 'none', // Quita la sombra por defecto
      }}
      elevation={0} // Quita la elevación (complementa a boxShadow: 'none')
    >
      <Toolbar sx={{ justifyContent: 'space-between' }}>
        {/* Título */}
        <Typography variant="h6" noWrap component="div" sx={{ fontWeight: 'bold' }}>
          Alerta Piura - Admin
        </Typography>
        
        {/* Botón de Logout */}
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