import React from 'react';
import { Routes, Route, Link, useNavigate } from 'react-router-dom';
import { Box, AppBar, Toolbar, Drawer, List, ListItem, ListItemButton, ListItemIcon, ListItemText, Typography, Button, Container } from '@mui/material';
import DashboardIcon from '@mui/icons-material/Dashboard';
import PeopleIcon from '@mui/icons-material/People';
import CategoryIcon from '@mui/icons-material/Category';
import FlagIcon from '@mui/icons-material/Flag';
import ArticleIcon from '@mui/icons-material/Article';
import WarningIcon from '@mui/icons-material/Warning';
import AnalyticsIcon from '@mui/icons-material/Analytics';
import DashboardOverview from './DashboardOverview';
import UsersPage from './UsersPage';
import CategoriesPage from './CategoriesPage';
import ModerationPage from './ModerationPage';
import ReportsManagementPage from './ReportsManagementPage';
import SOSAlertsPage from './SOSAlertsPage';
import AnalyticsPage from './AnalyticsPage';
import SmsIcon from '@mui/icons-material/Sms';
import SmsLogPage from './SmsLogPage';
import MailOutlineIcon from '@mui/icons-material/MailOutline';
import NotificationHistoryPage from './NotificationHistoryPage';
import Header from '../components/Header';
import Footer from '../components/Footer';

const drawerWidth = 240;

function DashboardLayout({ onLogout }) {
  const navigate = useNavigate();
  const handleLogout = () => {
    if (window.confirm('¿Estás seguro de que quieres cerrar la sesión?')) {
      onLogout();
      navigate('/login');
    }
  };

  const menuItems = [
    { text: 'Alertas SOS', icon: <WarningIcon color="error" />, path: '/sos-alerts' },
    { text: 'Resumen', icon: <DashboardIcon />, path: '/' },
    { text: 'Análisis', icon: <AnalyticsIcon />, path: '/analytics' },
    { text: 'Usuarios', icon: <PeopleIcon />, path: '/users' },
    { text: 'Reportes', icon: <ArticleIcon />, path: '/reports' },
    { text: 'Categorías', icon: <CategoryIcon />, path: '/categories' },
    { text: 'Moderación', icon: <FlagIcon />, path: '/moderation' },
    { text: 'Registro SMS', icon: <SmsIcon />, path: '/sms-log' },
    { text: 'Historial Notificaciones', icon: <MailOutlineIcon />, path: '/notifications-history' },
  ];

  return (
    <Box sx={{ display: 'flex' }}>
      <Header onLogout={handleLogout} />
      <Drawer
        variant="permanent"
        sx={{
          width: drawerWidth,
          flexShrink: 0,
          [`& .MuiDrawer-paper`]: { width: drawerWidth, boxSizing: 'border-box' },
        }}
      >
        <Toolbar />
        <Box sx={{ overflow: 'auto' }}>
          <List>
            {menuItems.map((item) => (
              <ListItem key={item.text} disablePadding>
                <ListItemButton component={Link} to={item.path}>
                  <ListItemIcon>{item.icon}</ListItemIcon>
                  <ListItemText primary={item.text} />
                </ListItemButton>
              </ListItem>
            ))}
          </List>
        </Box>
      </Drawer>
      <Box component="main" sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
        <Toolbar />
        <Container maxWidth="xl" sx={{ flexGrow: 1, p: 3 }}>
          <Routes>
            <Route path="/" element={<DashboardOverview />} />
            <Route path="/sos-alerts" element={<SOSAlertsPage />} />
            <Route path="/users" element={<UsersPage />} />
            <Route path="/reports" element={<ReportsManagementPage />} />
            <Route path="/categories" element={<CategoriesPage />} />
            <Route path="/moderation" element={<ModerationPage />} />
            <Route path="/analytics" element={<AnalyticsPage />} />
            <Route path="/sms-log" element={<SmsLogPage />} />
            <Route path="/notifications-history" element={<NotificationHistoryPage />} />
          </Routes>
        </Container>
      </Box>
    </Box>
  );
}

export default DashboardLayout;