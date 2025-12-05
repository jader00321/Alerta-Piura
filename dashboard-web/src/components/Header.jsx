// src/components/Header.jsx
import React from 'react';
import { 
  AppBar, Toolbar, Typography, IconButton, Tooltip, Box, Avatar, Stack, useTheme, alpha, Badge 
} from '@mui/material';
import { 
  Logout as LogoutIcon,
  Notifications as BellIcon,
  AdminPanelSettings as ShieldIcon
} from '@mui/icons-material';

/**
 * Header - Barra Superior Profesional
 * Estilo "Glassy" y zona de usuario mejorada.
 */
function Header({ onLogout }) { // Recibimos drawerWidth para alinear si quisiéramos, pero zIndex maneja la superposición
  const theme = useTheme();

  return (
    <AppBar
      position="fixed"
      elevation={0}
      sx={{
        zIndex: (theme) => theme.zIndex.drawer + 1,
        // Efecto Vidrio (Glassmorphism)
        backgroundColor: alpha(theme.palette.background.paper, 0.9),
        backdropFilter: 'blur(12px)',
        borderBottom: `1px solid ${theme.palette.divider}`,
        color: 'text.primary',
      }}
    >
      <Toolbar sx={{ justifyContent: 'space-between', height: 64 }}>
        
        {/* --- IZQUIERDA: Marca / Logo --- */}
        <Stack direction="row" alignItems="center" spacing={1.5}>
          <Box sx={{ 
            bgcolor: alpha(theme.palette.primary.main, 0.1), 
            p: 0.8, borderRadius: 1.5, display: 'flex' 
          }}>
            <ShieldIcon color="primary" />
          </Box>
          <Box>
            <Typography variant="subtitle1" fontWeight="800" lineHeight={1.1} sx={{ letterSpacing: '-0.5px' }}>
              ALERTA PIURA
            </Typography>
            <Typography variant="caption" color="text.secondary" fontWeight="bold" sx={{ letterSpacing: '1px' }}>
              ADMINISTRACIÓN
            </Typography>
          </Box>
        </Stack>
        
        {/* --- DERECHA: Acciones de Usuario --- */}
        <Stack direction="row" alignItems="center" spacing={1}>
          
          {/* Botón de Notificaciones (Decorativo o Funcional) */}
          {/*<Tooltip title="Notificaciones del Sistema">
            <IconButton sx={{ color: 'text.secondary', '&:hover': { color: 'primary.main', bgcolor: alpha(theme.palette.primary.main, 0.1) } }}>
              <Badge badgeContent={3} color="error" variant="dot">
                <BellIcon />
              </Badge>
            </IconButton>
          </Tooltip>*/}

          {/* Separador vertical pequeño */}
          <Box sx={{ width: '1px', height: 24, bgcolor: 'divider', mx: 1 }} />

          {/* Perfil y Logout */}
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, pl: 1 }}>
            <Box sx={{ textAlign: 'right', display: { xs: 'none', md: 'block' } }}>
              <Typography variant="body2" fontWeight="bold">
                Administrador
              </Typography>
              <Typography variant="caption" color="text.secondary" display="block">
                En línea
              </Typography>
            </Box>
            
            <Tooltip title="Cerrar Sesión">
              <IconButton 
                onClick={onLogout}
                sx={{ 
                  p: 0.5,
                  border: `1px solid ${theme.palette.divider}`,
                  transition: 'all 0.2s',
                  '&:hover': { 
                    borderColor: 'error.main', 
                    bgcolor: alpha(theme.palette.error.main, 0.05) 
                  }
                }}
              >
                <Avatar 
                  sx={{ 
                    width: 36, height: 36, 
                    bgcolor: theme.palette.secondary.main,
                    fontSize: '0.9rem', fontWeight: 'bold'
                  }}
                >
                  <LogoutIcon fontSize="small" />
                </Avatar>
              </IconButton>
            </Tooltip>
          </Box>

        </Stack>
      </Toolbar>
    </AppBar>
  );
}

export default Header;