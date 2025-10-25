// src/pages/DashboardLayout.jsx
import React from 'react';
import { Routes, Route, NavLink, useNavigate, useLocation, Navigate} from 'react-router-dom';
import {
  Box, Drawer, List, ListItem, ListItemButton, ListItemIcon,
  ListItemText, Toolbar, Typography, Container, useTheme, Divider
} from '@mui/material';

// Import Icons (keep existing ones)
import DashboardIcon from '@mui/icons-material/Dashboard';
import PeopleIcon from '@mui/icons-material/People';
import CategoryIcon from '@mui/icons-material/Category';
import FlagIcon from '@mui/icons-material/Flag';
import ArticleIcon from '@mui/icons-material/Article';
import WarningIcon from '@mui/icons-material/Warning';
import AnalyticsIcon from '@mui/icons-material/Analytics';
import SmsIcon from '@mui/icons-material/Sms';
import MailOutlineIcon from '@mui/icons-material/MailOutline';
import SettingsIcon from '@mui/icons-material/Settings'; // Example for a future section

// Import Page Components
import PaginaResumen from './PaginaResumen';
import PaginaUsuarios from './PaginaUsuarios';
import PaginaCategorias from './PaginaCategorias';
import ModerationPage from './ModerationPage';
import PaginaReportes from './PaginaReportes';
import PaginaAlertasSOS from './PaginaAlertasSOS';
import PaginaAnalisis from './PaginaAnalisis';
import PaginaRegistroSms from './PaginaRegistroSms';
import PaginaHistorialNotificaciones from './PaginaHistorialNotificaciones'; // <-- Renamed import
import Header from '../components/Header'; // Assuming Header.jsx is in src/components/

const drawerWidth = 240;

function DashboardLayout({ onLogout }) {
  const navigate = useNavigate();
  const location = useLocation(); // Hook to get current path
  const theme = useTheme();

  const handleLogout = () => {
    if (window.confirm('¿Estás seguro de que quieres cerrar la sesión?')) {
      onLogout();
      navigate('/login');
    }
  };

  // --- MENU ITEMS ORGANIZED ---
  const mainMenuItems = [
    { text: 'Resumen', icon: <DashboardIcon />, path: '/' },
    { text: 'Análisis', icon: <AnalyticsIcon />, path: '/analytics' },
  ];

  const managementMenuItems = [
    { text: 'Alertas SOS', icon: <WarningIcon color="error" />, path: '/sos-alerts' },
    { text: 'Reportes', icon: <ArticleIcon />, path: '/reports' },
    { text: 'Usuarios', icon: <PeopleIcon />, path: '/users' },
    { text: 'Categorías', icon: <CategoryIcon />, path: '/categories' },
    { text: 'Moderación', icon: <FlagIcon />, path: '/moderation' },
  ];

  const communicationMenuItems = [
    { text: 'Historial Notificaciones', icon: <MailOutlineIcon />, path: '/notifications-history' },
    { text: 'Registro SMS', icon: <SmsIcon />, path: '/sms-log' },
  ];

  // Helper function to render menu items with NavLink
  const renderMenuItems = (items) => items.map((item) => {
    const isActive = location.pathname === item.path || (item.path !== '/' && location.pathname.startsWith(item.path)); // Handle sub-routes potentially
    return (
      <ListItem key={item.text} disablePadding>
        <ListItemButton
          component={NavLink}
          to={item.path}
          selected={isActive} // Highlight if active
          sx={{
            borderRadius: '8px', // Slightly rounded corners
            margin: '4px 8px', // Add some margin
            '&.Mui-selected': { // Styles for active item
              backgroundColor: theme.palette.action.selected,
              '& .MuiListItemIcon-root, & .MuiListItemText-primary': {
                color: theme.palette.primary.main, // Active color for icon and text
                fontWeight: 'bold',
              },
            },
            '&:hover': {
                 backgroundColor: theme.palette.action.hover,
            }
          }}
        >
          <ListItemIcon sx={{ minWidth: '40px' }}>{item.icon}</ListItemIcon>
          <ListItemText primary={item.text} />
        </ListItemButton>
      </ListItem>
    );
  });

  return (
    <Box sx={{ display: 'flex', bgcolor: 'background.default', minHeight: '100vh' }}>
      <Header onLogout={handleLogout} />
      <Drawer
        variant="permanent"
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          [`& .MuiDrawer-paper`]: {
            width: drawerWidth,
            boxSizing: 'border-box',
            borderRight: 'none', // Remove default border if header has one
            bgcolor: 'background.paper', // Match background if needed
          },
        }}
      >
        <Toolbar /> {/* Spacer for under the header */}
        <Box sx={{ overflow: 'auto', p: 1 }}> {/* Add padding around lists */}
          {/* Main Section */}
          <List subheader={<Typography variant="overline" sx={{ px: 2, mt: 1, color: 'text.secondary' }}>Principal</Typography>}>
            {renderMenuItems(mainMenuItems)}
          </List>
          <Divider sx={{ my: 1 }} />

          {/* Management Section */}
          <List subheader={<Typography variant="overline" sx={{ px: 2, color: 'text.secondary' }}>Gestión</Typography>}>
            {renderMenuItems(managementMenuItems)}
          </List>
          <Divider sx={{ my: 1 }} />

          {/* Communication Section */}
          <List subheader={<Typography variant="overline" sx={{ px: 2, color: 'text.secondary' }}>Comunicación</Typography>}>
            {renderMenuItems(communicationMenuItems)}
          </List>
        </Box>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column' }}>
        <Toolbar /> {/* Spacer for under the header */}
        <Container maxWidth="xl" sx={{ flexGrow: 1, py: 3, px: { xs: 2, sm: 3 } }}> {/* Adjusted padding */}
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
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </Container>
      </Box>
    </Box>
  );
}

export default DashboardLayout;