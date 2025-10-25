// src/pages/PaginaResumen.jsx
import React, { useEffect, useState, useCallback } from 'react';
import { Grid, Typography, Box, CircularProgress, Alert, Divider, Skeleton, Paper} from '@mui/material';
import TarjetaEstadistica from '../components/Resumen/TarjetaEstadistica';
import GraficoReportesDia from '../components/Resumen/GraficoReportesDia';
import TablaUltimosReportes from '../components/Resumen/TablaUltimosReportes';
import ModalDetalleReporteResumen from '../components/Resumen/ModalDetalleReporteResumen';
// --- MODIFICADO: Importar GraficoBarrasSimple ---
import GraficoBarrasSimple from '../components/Analisis/GraficoBarrasSimple'; // Assuming it's in Analisis folder
import { useAuth } from '../context/AuthContext';
import adminService from '../services/adminService';

// (Importaciones de Iconos sin cambios)
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

/**
 * Mapeo de colores para los estados de reportes
 * @type {Object}
 */
const STATUS_COLORS = {
  Pendiente: '#ff9800',
  Verificado: '#4caf50',
  Rechazado: '#f44336',
  Oculto: '#9e9e9e',
  Otro: '#607d8b',
};

/**
 * PaginaResumen - Página principal del dashboard con métricas y visualizaciones
 * @returns {JSX.Element}
 */
function PaginaResumen() {
  const [stats, setStats] = useState(null);
  const [dailyChartData, setDailyChartData] = useState([]);
  const [statusChartData, setStatusChartData] = useState([]);
  const [latestReports, setLatestReports] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [modalOpen, setModalOpen] = useState(false);
  const [selectedReport, setSelectedReport] = useState(null);
  const { isAuthenticated } = useAuth();

  /**
   * Función para obtener todos los datos del dashboard
   */
  const fetchData = useCallback(() => {
    if (!isAuthenticated) { setLoading(false); return; }
    setLoading(true);
    setError('');
    
    // Reiniciar datos para asegurar que los Skeletons aparezcan
    setStats(null);
    setDailyChartData([]);
    setStatusChartData([]);
    setLatestReports([]);

    Promise.all([
      adminService.getDashboardStats(),
      adminService.getReportsByDay(), // Obtiene últimos 7 días por defecto
      adminService.getLatestPendingReports(),
      adminService.getReportsGroupedByStatus() // Obtiene todos los estados sin filtro
    ]).then(([statsData, reportsByDayData, latestReportsData, reportsByStatusData]) => {
      setStats(statsData);
      setLatestReports(latestReportsData || []); // Asegurar array
      
      const formattedDailyData = (reportsByDayData || []).map(d => ({
        // Formateo de fecha más robusto
        date: d.date ? new Intl.DateTimeFormat('es-ES', { month: 'short', day: 'numeric' }).format(new Date(d.date.replace(/-/g, '/'))) : 'Fecha Inválida',
        count: parseInt(d.count, 10) || 0
      }));
      setDailyChartData(formattedDailyData);
      
      // Asegurar que statusChartData siempre sea un array
      setStatusChartData(reportsByStatusData || []);

    }).catch(err => {
      console.error("Error fetching dashboard data:", err);
      setError('No se pudieron cargar los datos del resumen.');
      // Mantener los arrays vacíos en caso de error
      setStats({}); // Poner un objeto vacío para evitar errores en las tarjetas
      setLatestReports([]);
      setDailyChartData([]);
      setStatusChartData([]);
    }).finally(() => setLoading(false));
  }, [isAuthenticated]);

  useEffect(() => { fetchData(); }, [fetchData]);

  /**
   * Maneja la apertura del modal de detalle de reporte
   * @param {Object} report - Reporte seleccionado
   */
  const handleOpenModal = (report) => { setSelectedReport(report); setModalOpen(true); };
  
  /**
   * Maneja el cierre del modal de detalle de reporte
   */
  const handleCloseModal = () => { setModalOpen(false); setTimeout(() => setSelectedReport(null), 300);};
  
  /**
   * Maneja las acciones de moderación (aprobar/rechazar reportes)
   * @param {string} reportId - ID del reporte
   * @param {boolean} approve - True para aprobar, false para rechazar
   */
  const handleModerationAction = (reportId, approve) => {
    // Podrías poner un estado de carga específico para la tabla/modal aquí
    adminService.resolveReport(reportId, approve)
      .then(() => {
          // Opcional: Actualizar solo la tabla o el estado local si es posible
          // Por ahora, recarga todo para simplicidad
          fetchData(); 
          handleCloseModal(); // Cerrar modal después de la acción
      })
      .catch((err) => { 
          console.error("Error al moderar:", err);
          setError('Error al procesar la moderación.'); 
          // Considera no poner setLoading(false) aquí si quieres que el spinner general siga
      });
  };

  // Definir tarjetas (sin cambios lógicos, solo Skeletons)
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
  ] : [...Array(12)].map((_, i) => ({ // 12 Skeletons
      title: <Skeleton width="80%"/>,
      value: <Skeleton width="40%"/>,
      icon: <Skeleton variant="circular" width={40} height={40} />,
      color: "default",
      key: `skel-${i}`
  }));

  const urgentCards = statCardsData.slice(0, 5);
  const generalCards = statCardsData.slice(5);

  // Mostrar spinner solo en carga inicial completa
  if (loading && !stats && !error) {
      return <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '80vh' }}><CircularProgress size={60}/></Box>;
  }


  return (
    // --- MODIFICADO: Padding ajustado en contenedor principal ---
    <Box sx={{ p: { xs: 1.5, sm: 2, md: 3 } }}> 
      {/* --- MODIFICADO: Cabecera mejorada --- */}
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" sx={{ fontWeight: 'bold', mb: 1 }}>
            Resumen General
        </Typography>
        <Typography variant="body1" color="text.secondary">
            Bienvenido al panel de administrador. Aquí tienes una vista rápida del estado actual de la plataforma, 
            incluyendo métricas clave, actividad reciente y reportes que requieren tu atención.
        </Typography>
      </Box>
      {/* --- Fin de Cabecera --- */}

      {error && <Alert severity="error" sx={{ mb: 3 }}>{error}</Alert>}

      {/* --- SECCIÓN 1: MÉTRICAS URGENTES --- */}
      <Typography variant="h6" gutterBottom sx={{ fontWeight: 'medium', mb: 2 }}>Métricas Clave</Typography>
      <Grid container spacing={3} sx={{ mb: 5 }}>
        {/* --- MODIFICADO: Se pasa 'loading' correctamente --- */}
        {urgentCards.map((card) => ( <TarjetaEstadistica key={card.key || card.title} {...card} loading={loading && !stats} /> ))}
      </Grid>

      {/* --- SECCIÓN 2: ESTADÍSTICAS GENERALES --- */}
      <Typography variant="h6" gutterBottom sx={{ fontWeight: 'medium', mb: 2 }}>Estadísticas Generales</Typography>
      <Grid container spacing={3} sx={{ mb: 5 }}>
        {/* --- MODIFICADO: Se pasa 'loading' correctamente --- */}
        {generalCards.map((card) => ( <TarjetaEstadistica key={card.key || card.title} {...card} loading={loading && !stats} /> ))}
      </Grid>

      <Divider sx={{ my: 4 }} />

      {/* --- SECCIÓN 3: VISUALIZACIONES --- */}
       <Grid container spacing={4} sx={{ mb: 5 }}>
            <Grid item xs={12} lg={7}>
                 <GraficoReportesDia chartData={dailyChartData} loading={loading && dailyChartData.length === 0} />
            </Grid>
            <Grid item xs={12} lg={5}>
                 {/* --- REEMPLAZADO: GraficoReportesEstado por GraficoBarrasSimple --- */}
                 <Paper sx={{ p: 3, height: { xs: 300, md: 400 }, borderRadius: '12px', overflow: 'hidden', display:'flex', flexDirection:'column',minWidth:'500px' }} elevation={3}>
                     <Typography variant="h6" gutterBottom sx={{ fontWeight: 500, textAlign: 'center' }}>
                         Distribución por Estado
                     </Typography>
                     {/* Pasamos los datos y configuramos para barras horizontales */}
                     <GraficoBarrasSimple
                         data={statusChartData}
                         loading={loading && statusChartData.length === 0}
                         dataKey="value"
                         xAxisKey="name"
                         // --- NUEVO: Pasar el mapeo de colores ---
                         colorMapping={STATUS_COLORS}
                         // layout="vertical" // Ya es vertical por defecto en el componente mejorado
                         barName="Reportes" // Nombre para tooltip/leyenda (aunque leyenda está oculta)
                     />
                 </Paper>
            </Grid>
       </Grid>
      <Divider sx={{ my: 4 }} />
      
      {/* --- SECCIÓN 4: TABLA PENDIENTES --- */}
      <TablaUltimosReportes
          reports={latestReports}
          // --- MODIFICADO: 'loading' más preciso ---
          loading={loading && latestReports.length === 0}
          onReportClick={handleOpenModal}
      />

      {/* Modal (sin cambios) */}
      <ModalDetalleReporteResumen
        report={selectedReport}
        open={modalOpen}
        onClose={handleCloseModal}
        onAction={handleModerationAction}
      />
    </Box>
  );
}

export default PaginaResumen;