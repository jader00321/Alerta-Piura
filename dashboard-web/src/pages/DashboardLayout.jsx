// src/pages/DashboardLayout.jsx
import React from 'react';
import { Routes, Route, NavLink, useNavigate, useLocation, Navigate } from 'react-router-dom';
import {
  Box, Drawer, List, ListItem, ListItemButton, ListItemIcon,
  ListItemText, Toolbar, Typography, Container, useTheme, Divider
} from '@mui/material';

// Importación de íconos de Material-UI (mantener los existentes)
import DashboardIcon from '@mui/icons-material/Dashboard';
import PeopleIcon from '@mui/icons-material/People';
import CategoryIcon from '@mui/icons-material/Category';
import FlagIcon from '@mui/icons-material/Flag';
import ArticleIcon from '@mui/icons-material/Article';
import WarningIcon from '@mui/icons-material/Warning';
import AnalyticsIcon from '@mui/icons-material/Analytics';
import SmsIcon from '@mui/icons-material/Sms';
import MailOutlineIcon from '@mui/icons-material/MailOutline';
import SettingsIcon from '@mui/icons-material/Settings'; // Ejemplo para una sección futura

// Importación de componentes de páginas
import PaginaResumen from './PaginaResumen';
import PaginaUsuarios from './PaginaUsuarios';
import PaginaCategorias from './PaginaCategorias';
import ModerationPage from './ModerationPage';
import PaginaReportes from './PaginaReportes';
import PaginaAlertasSOS from './PaginaAlertasSOS';
import PaginaAnalisis from './PaginaAnalisis';
import PaginaRegistroSms from './PaginaRegistroSms';
import PaginaHistorialNotificaciones from './PaginaHistorialNotificaciones'; // <-- Importación renombrada
import Header from '../components/Header'; // Asumiendo que Header.jsx está en src/components/

// Ancho fijo del drawer lateral
const drawerWidth = 240;

/**
 * Componente DashboardLayout: Layout principal del dashboard de administración.
 * Incluye un header, un drawer lateral con navegación organizada en secciones,
 * y un área principal que renderiza las páginas según la ruta actual usando React Router.
 * 
 * Props:
 * - onLogout: Función para manejar el logout (probablemente desde un contexto o componente padre).
 */
function DashboardLayout({ onLogout }) {
  // Hooks de React Router para navegación y ubicación actual
  const navigate = useNavigate(); // Para redirigir programáticamente
  const location = useLocation(); // Para obtener la ruta actual y resaltar el menú activo
  const theme = useTheme(); // Para acceder al tema de Material-UI

  /**
   * Función para manejar el logout: Confirma con el usuario y ejecuta onLogout,
   * luego redirige a la página de login.
   */
  const handleLogout = () => {
    if (window.confirm('¿Estás seguro de que quieres cerrar la sesión?')) {
      onLogout(); // Ejecuta la función de logout pasada como prop
      navigate('/login'); // Redirige a la página de login
    }
  };

  // --- ITEMS DEL MENÚ ORGANIZADOS POR SECCIONES ---
  // Sección Principal: Resumen y Análisis
  const mainMenuItems = [
    { text: 'Resumen', icon: <DashboardIcon />, path: '/' },
    { text: 'Análisis', icon: <AnalyticsIcon />, path: '/analytics' },
  ];

  // Sección Gestión: Alertas, Reportes, Usuarios, etc.
  const managementMenuItems = [
    { text: 'Alertas SOS', icon: <WarningIcon color="error" />, path: '/sos-alerts' },
    { text: 'Reportes', icon: <ArticleIcon />, path: '/reports' },
    { text: 'Usuarios', icon: <PeopleIcon />, path: '/users' },
    { text: 'Categorías', icon: <CategoryIcon />, path: '/categories' },
    { text: 'Moderación', icon: <FlagIcon />, path: '/moderation' },
  ];

  // Sección Comunicación: Historial de notificaciones y registro de SMS
  const communicationMenuItems = [
    { text: 'Historial Notificaciones', icon: <MailOutlineIcon />, path: '/notifications-history' },
    { text: 'Registro SMS', icon: <SmsIcon />, path: '/sms-log' },
  ];

  /**
   * Función helper para renderizar los items del menú usando NavLink.
   * Aplica estilos condicionales para resaltar el item activo basado en la ruta actual.
   * 
   * @param {Array} items - Lista de objetos con text, icon y path.
   * @returns {JSX.Element[]} Lista de elementos ListItem renderizados.
   */
  const renderMenuItems = (items) => items.map((item) => {
    // Determina si el item está activo (ruta exacta o sub-rutas)
    const isActive = location.pathname === item.path || (item.path !== '/' && location.pathname.startsWith(item.path));
    return (
      <ListItem key={item.text} disablePadding>
        <ListItemButton
          component={NavLink} // Usa NavLink para navegación sin recarga
          to={item.path}
          selected={isActive} // Prop para resaltar si está activo
          sx={{
            borderRadius: '8px', // Bordes ligeramente redondeados
            margin: '4px 8px', // Margen para separación
            '&.Mui-selected': { // Estilos para el item activo
              backgroundColor: theme.palette.action.selected,
              '& .MuiListItemIcon-root, & .MuiListItemText-primary': {
                color: theme.palette.primary.main, // Color primario para ícono y texto
                fontWeight: 'bold',
              },
            },
            '&:hover': {
              backgroundColor: theme.palette.action.hover, // Color al pasar el mouse
            }
          }}
        >
          <ListItemIcon sx={{ minWidth: '40px' }}>{item.icon}</ListItemIcon>
          <ListItemText primary={item.text} />
        </ListItemButton>
      </ListItem>
    );
  });

  // Renderizado del componente
  return (
    <Box sx={{ display: 'flex', bgcolor: 'background.default', minHeight: '100vh' }}>
      {/* Header del dashboard (incluye funcionalidad de logout) */}
      <Header onLogout={handleLogout} />
      
      {/* Drawer lateral permanente para navegación */}
      <Drawer
        variant="permanent" // Siempre visible
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          [`& .MuiDrawer-paper`]: {
            width: drawerWidth,
            boxSizing: 'border-box',
            borderRight: 'none', // Remueve borde por defecto si el header lo tiene
            bgcolor: 'background.paper', // Fondo consistente
          },
        }}
      >
        <Toolbar /> {/* Espaciador para alinear bajo el header */}
        <Box sx={{ overflow: 'auto', p: 1 }}> {/* Contenedor con scroll y padding */}
          {/* Sección Principal */}
          <List subheader={<Typography variant="overline" sx={{ px: 2, mt: 1, color: 'text.secondary' }}>Principal</Typography>}>
            {renderMenuItems(mainMenuItems)}
          </List>
          <Divider sx={{ my: 1 }} /> {/* Separador visual */}

          {/* Sección Gestión */}
          <List subheader={<Typography variant="overline" sx={{ px: 2, color: 'text.secondary' }}>Gestión</Typography>}>
            {renderMenuItems(managementMenuItems)}
          </List>
          <Divider sx={{ my: 1 }} /> {/* Separador visual */}

          {/* Sección Comunicación */}
          <List subheader={<Typography variant="overline" sx={{ px: 2, color: 'text.secondary' }}>Comunicación</Typography>}>
            {renderMenuItems(communicationMenuItems)}
          </List>
        </Box>
      </Drawer>
      
      {/* Área principal del contenido */}
      <Box component="main" sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column' }}>
        <Toolbar /> {/* Espaciador para alinear bajo el header */}
        <Container maxWidth="xl" sx={{ flexGrow: 1, py: 3, px: { xs: 2, sm: 3 } }}> {/* Contenedor con padding responsivo */}
          {/* Definición de rutas usando React Router */}
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
            {/* Ruta por defecto: Redirige a la raíz si no coincide */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </Container>
      </Box>
    </Box>
  );
}

export default DashboardLayout;
