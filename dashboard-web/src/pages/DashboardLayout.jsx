// src/pages/DashboardLayout.jsx
import React, { useState } from 'react';
import { Routes, Route, NavLink, useNavigate, useLocation, Navigate } from 'react-router-dom';
import {
  Box, Drawer, List, ListItem, ListItemButton, ListItemIcon,
  ListItemText, Toolbar, Typography, Container, useTheme, Divider, Fade
} from '@mui/material';

// Iconos (Mantenemos tus importaciones)
import {
  Dashboard as DashboardIcon, People as PeopleIcon, Category as CategoryIcon,
  GppGood as ModerationIcon, Article as ReportIcon, WarningAmber as SosIcon,
  Analytics as AnalyticsIcon, Sms as SmsIcon, NotificationsActive as NotifIcon,
  Chat as ChatIcon
} from '@mui/icons-material';

// Páginas (Mantenemos tus importaciones)
import PaginaResumen from './PaginaResumen';
import PaginaUsuarios from './PaginaUsuarios';
import PaginaCategorias from './PaginaCategorias';
import ModerationPage from './ModerationPage';
import PaginaReportes from './PaginaReportes';
import PaginaAlertasSOS from './PaginaAlertasSOS';
import PaginaAnalisis from './PaginaAnalisis';
import PaginaRegistroSms from './PaginaRegistroSms';
import PaginaHistorialNotificaciones from './PaginaHistorialNotificaciones';
import PaginaBuzonChats from './PaginaBuzonChats'; 

// NUEVAS IMPORTACIONES
import Header from '../components/Header';
import ModalCerrarSesion from '../components/Comunes/ModalCerrarSesion'; // Asegúrate de la ruta

const drawerWidth = 260; // Ancho un poco más generoso para el sidebar

function DashboardLayout({ onLogout }) {
  const navigate = useNavigate();
  const location = useLocation();
  const theme = useTheme();
  
  // --- Estado para el Modal de Logout ---
  const [logoutModalOpen, setLogoutModalOpen] = useState(false);

  // Abrir modal en lugar de window.confirm
  const handleLogoutClick = () => {
    setLogoutModalOpen(true);
  };

  // Acción confirmada
  const confirmLogout = () => {
    setLogoutModalOpen(false);
    onLogout();
    navigate('/login');
  };

  // Menús (Sin cambios lógicos, solo estructura)
  const menuGroups = [
    {
      title: "PRINCIPAL",
      items: [
        { text: 'Resumen', icon: <DashboardIcon />, path: '/' },
        { text: 'Análisis', icon: <AnalyticsIcon />, path: '/analytics' },
      ]
    },
    {
      title: "GESTIÓN",
      items: [
        { text: 'Alertas SOS', icon: <SosIcon sx={{ color: theme.palette.error.main }} />, path: '/sos-alerts' },
        { text: 'Reportes', icon: <ReportIcon />, path: '/reports' },
        { text: 'Usuarios', icon: <PeopleIcon />, path: '/users' },
        { text: 'Categorías', icon: <CategoryIcon />, path: '/categories' },
        { text: 'Moderación', icon: <ModerationIcon />, path: '/moderation' },
      ]
    },
    {
      title: "COMUNICACIÓN",
      items: [
        { text: 'Chats y Mensajes', icon: <ChatIcon />, path: '/chats' },
        { text: 'Historial Notif.', icon: <NotifIcon />, path: '/notifications-history' },
        { text: 'Registro SMS', icon: <SmsIcon />, path: '/sms-log' },
      ]
    }
  ];

  // Contenido del Sidebar
  const renderDrawerContent = (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      {/* Espaciador transparente para que el contenido empiece DEBAJO del Header */}
      <Toolbar /> 
      
      <Box sx={{ overflow: 'auto', flexGrow: 1, py: 2, px: 2 }}>
        {menuGroups.map((group) => (
          <Box key={group.title} sx={{ mb: 3 }}>
            <Typography variant="caption" sx={{ px: 1.5, mb: 1, display: 'block', fontWeight: 800, color: 'text.disabled', letterSpacing: 1 }}>
                {group.title}
            </Typography>
            <List disablePadding>
              {group.items.map((item) => {
                const isActive = location.pathname === item.path || (item.path !== '/' && location.pathname.startsWith(item.path));
                return (
                  <ListItem key={item.text} disablePadding sx={{ mb: 0.5 }}>
                    <ListItemButton
                      component={NavLink}
                      to={item.path}
                      selected={isActive}
                      sx={{
                        borderRadius: 2,
                        py: 1, px: 1.5,
                        '&.Mui-selected': {
                          backgroundColor: theme.palette.primary.main,
                          color: 'white',
                          boxShadow: `0 4px 12px ${theme.palette.primary.light}40`,
                          '&:hover': { backgroundColor: theme.palette.primary.dark },
                          '& .MuiListItemIcon-root': { color: 'white' },
                        },
                        '&:not(.Mui-selected):hover': { backgroundColor: theme.palette.action.hover }
                      }}
                    >
                      <ListItemIcon sx={{ minWidth: 36, color: isActive ? 'inherit' : 'text.secondary' }}>
                        {item.icon}
                      </ListItemIcon>
                      <ListItemText 
                        primary={item.text} 
                        primaryTypographyProps={{ fontSize: '0.9rem', fontWeight: isActive ? 600 : 500 }} 
                      />
                    </ListItemButton>
                  </ListItem>
                );
              })}
            </List>
          </Box>
        ))}
      </Box>
      <Divider />
      {/* Footer del Sidebar con versión o info extra */}
      <Box sx={{ p: 2, textAlign: 'center' }}>
          <Typography variant="caption" color="text.disabled">v1.0.0 Admin Panel</Typography>
      </Box>
    </Box>
  );

  return (
    <Box sx={{ display: 'flex', minHeight: '100vh', bgcolor: 'background.default' }}>
      
      {/* 1. Header (Pasa por encima del sidebar gracias a zIndex) */}
      <Header onLogout={handleLogoutClick} />
      
      {/* 2. Sidebar Lateral */}
      <Drawer
        variant="permanent"
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          [`& .MuiDrawer-paper`]: {
            width: drawerWidth,
            boxSizing: 'border-box',
            borderRight: `1px solid ${theme.palette.divider}`,
            bgcolor: 'background.paper',
          },
        }}
      >
        {renderDrawerContent}
      </Drawer>
      
      {/* 3. Área Principal */}
      <Box 
        component="main" 
        sx={{ 
            flexGrow: 1, 
            display: 'flex', 
            flexDirection: 'column', 
            width: { sm: `calc(100% - ${drawerWidth}px)` },
            overflowX: 'hidden'
        }}
      >
        <Toolbar /> {/* Espaciador para no quedar debajo del Header fijo */}
        
        <Fade in={true} timeout={600}>
            <Container maxWidth="xl" sx={{ py: 4, px: { xs: 2, sm: 4 }, flexGrow: 1 }}>
            <Routes>
                <Route path="/" element={<PaginaResumen />} />
                <Route path="/sos-alerts" element={<PaginaAlertasSOS />} />
                <Route path="/users" element={<PaginaUsuarios />} />
                <Route path="/reports" element={<PaginaReportes />} />
                <Route path="/categories" element={<PaginaCategorias />} />
                <Route path="/moderation" element={<ModerationPage />} />
                <Route path="/analytics" element={<PaginaAnalisis />} />
                <Route path="/sms-log" element={<PaginaRegistroSms />} />
                <Route path="/notifications-history" element={<PaginaHistorialNotificaciones />} />
                <Route path="/chats" element={<PaginaBuzonChats />} />
                <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
            </Container>
        </Fade>
      </Box>

      {/* 4. Modal de Confirmación de Logout */}
      <ModalCerrarSesion 
        open={logoutModalOpen}
        onClose={() => setLogoutModalOpen(false)}
        onConfirm={confirmLogout}
      />
    </Box>
  );
}

export default DashboardLayout;