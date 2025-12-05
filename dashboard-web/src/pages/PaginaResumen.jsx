// src/pages/PaginaResumen.jsx
import React, { useEffect, useState, useCallback } from 'react';
import { 
  Grid, Typography, Box, CircularProgress, Alert, Divider, Skeleton, Paper, 
  Stack, useTheme, Fade, Container
} from '@mui/material';
import { 
  Dashboard as DashboardIcon, 
  TrendingUp as TrendingUpIcon,
  PieChart as PieChartIcon,
  ListAlt as ListIcon // Icono para la sección de tabla
} from '@mui/icons-material';

// --- Recharts Imports ---
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';

import TarjetaEstadistica from '../components/Resumen/TarjetaEstadistica';
import TablaUltimosReportes from '../components/Resumen/TablaUltimosReportes';
import ModalDetalleReporteResumen from '../components/Resumen/ModalDetalleReporteResumen';
import GraficoBarrasSimple from '../components/Analisis/GraficoBarrasSimple';
import { useAuth } from '../context/AuthContext';
import adminService from '../services/adminService';

// Iconos
import PeopleIcon from '@mui/icons-material/People';
import ReportIcon from '@mui/icons-material/Report';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CommentIcon from '@mui/icons-material/Comment';
import PersonOffIcon from '@mui/icons-material/PersonOff';
import SosIcon from '@mui/icons-material/Sos';
import PremiumIcon from '@mui/icons-material/WorkspacePremium';
import CategoryIcon from '@mui/icons-material/Category';
import SuggestionIcon from '@mui/icons-material/HelpOutline';
import RejectedIcon from '@mui/icons-material/CancelOutlined';
import HiddenIcon from '@mui/icons-material/VisibilityOff';
import RoleRequestIcon from '@mui/icons-material/AssignmentInd';

const STATUS_COLORS = {
  Pendiente: '#ff9800',
  Verificado: '#4caf50',
  Rechazado: '#f44336',
  Oculto: '#9e9e9e',
  Otro: '#607d8b',
};

function PaginaResumen() {
  const theme = useTheme();
  const [stats, setStats] = useState(null);
  const [dailyChartData, setDailyChartData] = useState([]);
  const [statusChartData, setStatusChartData] = useState([]);
  const [latestReports, setLatestReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedReport, setSelectedReport] = useState(null);
  const { isAuthenticated } = useAuth();

  const fetchData = useCallback(() => {
    if (!isAuthenticated) { setLoading(false); return; }
    setLoading(true);
    setError('');
    
    setStats(null);
    setDailyChartData([]);
    setStatusChartData([]);
    setLatestReports([]);

    Promise.all([
      adminService.getDashboardStats(),
      adminService.getReportsByDay(),
      adminService.getLatestPendingReports(),
      adminService.getReportsGroupedByStatus()
    ]).then(([statsData, reportsByDayData, latestReportsData, reportsByStatusData]) => {
      setStats(statsData);
      setLatestReports(latestReportsData || []);
      
      const formattedDailyData = (reportsByDayData || []).map(d => ({
        date: d.date ? new Intl.DateTimeFormat('es-ES', { month: 'short', day: 'numeric' }).format(new Date(d.date.replace(/-/g, '/'))) : 'N/A',
        count: parseInt(d.count, 10) || 0
      }));
      setDailyChartData(formattedDailyData);
      setStatusChartData(reportsByStatusData || []);

    }).catch(err => {
      console.error("Error fetching dashboard data:", err);
      setError('No se pudieron cargar los datos del resumen.');
      setStats({});
    }).finally(() => setLoading(false));
  }, [isAuthenticated]);

  useEffect(() => { fetchData(); }, [fetchData]);

  const handleOpenModal = (report) => { setSelectedReport(report); setModalOpen(true); };
  const handleCloseModal = () => { setModalOpen(false); setTimeout(() => setSelectedReport(null), 300);};
  
  const handleModerationAction = (reportId, approve) => {
    adminService.resolveReport(reportId, approve)
      .then(() => {
          fetchData(); 
          handleCloseModal();
      })
      .catch((err) => { 
          console.error("Error al moderar:", err);
          setError('Error al procesar la moderación.'); 
      });
  };

  const statCardsData = stats ? [
    { title: "Reportes Pendientes", value: stats.reportesPendientes, icon: <ReportIcon />, color: "warning" },
    { title: "Alertas SOS Activas", value: stats.alertasSosActivas, icon: <SosIcon />, color: "error" },
    { title: "Comentarios Reportados", value: stats.comentariosReportados, icon: <CommentIcon />, color: "info" },
    { title: "Usuarios Reportados", value: stats.usuariosReportados, icon: <PersonOffIcon />, color: "secondary" },
    { title: "Solicitudes de Rol", value: stats.solicitudesRolPendientes, icon: <RoleRequestIcon />, color: "primary" },
    { title: "Usuarios Totales", value: stats.totalUsuarios, icon: <PeopleIcon />, color: "primary" },
    { title: "Usuarios Premium", value: stats.usuariosPremium, icon: <PremiumIcon />, color: "warning" },
    { title: "Reportes Verificados", value: stats.reportesVerificados, icon: <CheckCircleIcon />, color: "success" },
    { title: "Categorías Oficiales", value: stats.categoriasOficiales, icon: <CategoryIcon />, color: "default" },
    { title: "Categorías Sugeridas", value: stats.categoriasSugeridas, icon: <SuggestionIcon />, color: "info" },
    { title: "Reportes Rechazados", value: stats.reportesRechazados, icon: <RejectedIcon />, color: "error" },
    { title: "Reportes Ocultos", value: stats.reportesOcultos, icon: <HiddenIcon />, color: "default" },
  ] : [...Array(12)].map((_, i) => ({ 
      title: <Skeleton width="80%"/>, 
      value: <Skeleton width="40%"/>, 
      icon: <Skeleton variant="circular" width={24} height={24} />, 
      color: "default", 
      key: `skel-${i}` 
  }));

  const urgentCards = statCardsData.slice(0, 5);
  const generalCards = statCardsData.slice(5);

  if (loading && !stats && !error) {
      return <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}><CircularProgress size={60}/></Box>;
  }

  return (
    <Box sx={{ p: { xs: 2, md: 3 }, minHeight: '100vh', bgcolor: 'background.default' }}>
      <Container maxWidth="xl" disableGutters>
        
        {/* --- HEADER --- */}
        <Box sx={{ mb: 5 }}>
          <Stack direction="row" alignItems="center" spacing={2} sx={{ mb: 1 }}>
             <DashboardIcon sx={{ fontSize: 40, color: 'primary.main' }} />
             <Typography variant="h4" sx={{ fontWeight: 800, letterSpacing: '-0.5px', color: 'text.primary' }}>
                Panel de Control
             </Typography>
          </Stack>
          <Typography variant="body1" color="text.secondary" sx={{ maxWidth: '800px', ml: { sm: 7 } }}>
             Visión general del estado de la plataforma Reporta Piura. Monitorea métricas clave y gestiona incidencias urgentes.
          </Typography>
        </Box>

        {error && <Fade in={true}><Alert severity="error" sx={{ mb: 4, borderRadius: 2 }}>{error}</Alert></Fade>}

        {/* --- SECCIÓN 1: ATENCIÓN REQUERIDA --- */}
        <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 2, color: 'text.secondary', textTransform: 'uppercase', letterSpacing: 1 }}>
            Requieren Atención
        </Typography>
        <Grid container spacing={3} sx={{ mb: 5 }}>
          {urgentCards.map((card) => ( <TarjetaEstadistica key={card.key || card.title} {...card} loading={loading && !stats} /> ))}
        </Grid>

        {/* --- SECCIÓN 2 (MOVIDA): ÚLTIMOS REPORTES PENDIENTES --- */}
        {/* Ahora está arriba para acceso rápido a la acción de verificación */}
        <Box sx={{ mb: 6 }}>
            <Stack direction="row" alignItems="center" spacing={1} mb={2}>
               <ListIcon color="action" />
               <Box>
                   <Typography variant="h6" fontWeight="bold">Cola de Verificación Rápida</Typography>
                    <Typography variant="body2" color="text.secondary">Revisa y modera los reportes pendientes más recientes.</Typography>
               </Box>
            </Stack>
            
            <TablaUltimosReportes
                reports={latestReports}
                loading={loading && latestReports.length === 0}
                onReportClick={handleOpenModal}
            />
        </Box>

        <Divider sx={{ my: 6, opacity: 0.5 }} />

        {/* --- SECCIÓN 3: METRICAS GENERALES --- */}
        <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 2, color: 'text.secondary', textTransform: 'uppercase', letterSpacing: 1 }}>
            Estadísticas Globales
        </Typography>
        <Grid container spacing={3} sx={{ mb: 5 }}>
          {generalCards.map((card) => ( <TarjetaEstadistica key={card.key || card.title} {...card} loading={loading && !stats} /> ))}
        </Grid>

        {/* --- SECCIÓN 4 (MOVIDA): VISUALIZACIÓN DE DATOS (GRÁFICOS) --- */}
        {/* Ahora están al final, como información de consulta/análisis */}
        <Grid container spacing={3}>
            {/* Gráfico 1 */}
            <Grid item xs={12} lg={7} sx={{ overflow: 'hidden' }}>
               <Paper elevation={0} sx={{ p: 3, height: 450, borderRadius: 3, border: `1px solid ${theme.palette.divider}`, display: 'flex', flexDirection: 'column', overflowX: 'auto' }}>
                   <Stack direction="row" alignItems="center" spacing={1} mb={3}>
                      <TrendingUpIcon color="primary" />
                      <Typography variant="h6" fontWeight="bold">Actividad de Reportes (Últimos 7 días)</Typography>
                   </Stack>
                   <Box sx={{ flexGrow: 1, minWidth: '750px', height: '100%' }}>
                      {loading && dailyChartData.length === 0 ? (
                          <Skeleton variant="rectangular" width="100%" height="100%" />
                      ) : (
                        <ResponsiveContainer width="100%" height="100%">
                            <BarChart data={dailyChartData} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                                <CartesianGrid strokeDasharray="3 3" stroke={theme.palette.divider} vertical={false} />
                                <XAxis dataKey="date" tick={{ fill: theme.palette.text.secondary, fontSize: 12 }} stroke={theme.palette.divider} axisLine={false} tickLine={false} />
                                <YAxis tick={{ fill: theme.palette.text.secondary, fontSize: 12 }} stroke={theme.palette.divider} axisLine={false} tickLine={false} allowDecimals={false} />
                                <Tooltip cursor={{ fill: 'rgba(0,0,0,0.05)' }} contentStyle={{ backgroundColor: theme.palette.background.paper, border: `1px solid ${theme.palette.divider}`, borderRadius: '8px', boxShadow: theme.shadows[2] }} />
                                <Bar dataKey="count" name="Reportes" fill={theme.palette.primary.main} radius={[4, 4, 0, 0]} barSize={50} />
                            </BarChart>
                        </ResponsiveContainer>
                      )}
                   </Box>
               </Paper>
            </Grid>

            {/* Gráfico 2 */}
            <Grid item xs={12} lg={5}>
               <Paper elevation={0} sx={{ p: 3, height: 450, borderRadius: 3, border: `1px solid ${theme.palette.divider}`, display: 'flex', flexDirection: 'column' }}>
                   <Stack direction="row" alignItems="center" spacing={1} mb={3}>
                      <PieChartIcon color="secondary" />
                      <Typography variant="h6" fontWeight="bold">Estado de Reportes</Typography>
                   </Stack>
                   <Box sx={{ flexGrow: 1, width: '100%', minWidth: 0 }}>
                      <GraficoBarrasSimple
                          data={statusChartData}
                          loading={loading && statusChartData.length === 0}
                          dataKey="value"
                          xAxisKey="name"
                          colorMapping={STATUS_COLORS}
                          barName="Cantidad"
                      />
                   </Box>
               </Paper>
            </Grid>
        </Grid>

        {/* Modal de Detalle */}
        <ModalDetalleReporteResumen
          report={selectedReport}
          open={modalOpen}
          onClose={handleCloseModal}
          onAction={handleModerationAction}
        />

      </Container>
    </Box>
  );
}

export default PaginaResumen;