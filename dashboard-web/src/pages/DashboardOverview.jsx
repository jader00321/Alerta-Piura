import React, { useEffect, useState, useCallback } from 'react';
import { Grid, Paper, Typography, Box, CircularProgress, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Link as MuiLink } from '@mui/material';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import PeopleIcon from '@mui/icons-material/People';
import ReportIcon from '@mui/icons-material/Report';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import adminService from '../services/adminService';
import ReportDetailModal from '../components/ReportDetailModal';

// Enhanced StatCard with better styling
function StatCard({ title, value, icon, color = 'primary' }) {
  return (
    <Grid item xs={12} sm={6} md={4} lg={2.4}>
      <Paper 
        elevation={4}
        sx={{ 
          p: 2.5, 
          display: 'flex', 
          alignItems: 'center',
          borderRadius: '12px',
          transition: 'transform 0.2s, box-shadow 0.2s',
          '&:hover': {
            transform: 'translateY(-4px)',
            boxShadow: 'theme.shadows[6]',
          }
        }}
      >
        <Box sx={{ mr: 2, color: `${color}.main` }}>{icon}</Box>
        <Box>
          <Typography color="text.secondary">{title}</Typography>
          <Typography variant="h4" component="p" sx={{ fontWeight: 'bold' }}>
            {value}
          </Typography>
        </Box>
      </Paper>
    </Grid>
  );
}

function DashboardOverview() {
  const [stats, setStats] = useState(null);
  const [chartData, setChartData] = useState([]);
  const [latestReports, setLatestReports] = useState([]);
  const [loading, setLoading] = useState(true);
  //const [error, setError] = useState('');

  const [modalOpen, setModalOpen] = useState(false);
  const [selectedReport, setSelectedReport] = useState(null);

  const fetchData = useCallback(() => {
    Promise.all([
      adminService.getStats(),
      adminService.getReportsByDay(),
      adminService.getLatestPendingReports()
    ]).then(([statsData, reportsByDayData, latestReportsData]) => {
      setStats(statsData);
      setLatestReports(latestReportsData);
      const formattedData = reportsByDayData.map(d => ({
        ...d,
        date: new Intl.DateTimeFormat('es-ES', { month: 'short', day: 'numeric' }).format(new Date(d.date)),
        count: parseInt(d.count, 10)
      }));
      setChartData(formattedData);
    }).catch(console.error).finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const handleOpenModal = (report) => {
    setSelectedReport(report);
    setModalOpen(true);
  };
  
  const handleCloseModal = () => {
    setModalOpen(false);
    setSelectedReport(null);
  };

  const handleModerationAction = (reportId, approve) => {
    adminService.resolveReport(reportId, approve).then(() => {
      fetchData();
    });
  };

  if (loading) return <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}><CircularProgress /></Box>;
  //if (error) return <Typography color="error">{error}</Typography>;

  return (
    <Box>
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" component="h1" gutterBottom sx={{ fontWeight: 'bold' }}>
          Resumen del Sistema
        </Typography>
        <Typography variant="body1" color="text.secondary">
          Este panel muestra las métricas clave y las tendencias más recientes del sistema.
        </Typography>
      </Box>
      
      <Grid container spacing={2} sx={{ mb: 5 }}>
        <StatCard title="Usuarios Totales" value={stats.totalUsuarios} icon={<PeopleIcon sx={{ fontSize: 40 }} />} color="primary" />
        <StatCard title="Reportes Verificados" value={stats.reportesVerificados} icon={<CheckCircleIcon sx={{ fontSize: 40 }} />} color="success" />
        <StatCard title="Reportes Pendientes" value={stats.reportesPendientes} icon={<ReportIcon sx={{ fontSize: 40 }} />} color="warning" />
        <StatCard title="Comentarios Reportados" value={stats.comentariosReportados} icon={<ReportIcon sx={{ fontSize: 40 }} />} color="error" />
        <StatCard title="Usuarios Reportados" value={stats.usuariosReportados} icon={<PeopleIcon sx={{ fontSize: 40 }} />} color="error" />
      </Grid>

      <Typography variant="h6" gutterBottom sx={{ fontWeight: 400 }}>Últimos Reportes Pendientes de Verificación</Typography>
          <TableContainer component={Paper} elevation={3} sx={{ borderRadius: '12px', overflowX: 'auto', mb: 4, maxHeight: 750, width: 'fit-content', minWidth: 900 }}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Código</TableCell>
                  <TableCell>Título</TableCell>
                  <TableCell>Urgencia</TableCell>
                  <TableCell>Distrito</TableCell>
                  <TableCell>Autor</TableCell>
                  <TableCell>Categoría</TableCell>
                  <TableCell>Fecha</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {latestReports.length > 0 ? latestReports.map((report) => (
                  <TableRow key={report.id} hover onClick={() => handleOpenModal(report)} sx={{ cursor: 'pointer' }}>
                    <TableCell>{report.codigo_reporte}</TableCell>
                    <TableCell sx={{ fontWeight: 'bold' }}>{report.titulo}</TableCell>
                    <TableCell>{report.urgencia || 'N/A'}</TableCell>
                    <TableCell>{report.distrito || 'N/A'}</TableCell>
                    <TableCell>{report.autor_nombre}</TableCell>
                    <TableCell>{report.categoria}</TableCell>
                    <TableCell>{report.fecha_creacion}</TableCell>
                  </TableRow>
                )) : (
                  <TableRow>
                    <TableCell colSpan={4} align="center">No hay reportes pendientes.</TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </TableContainer>
      <Grid>
        <Typography variant="h6" gutterBottom sx={{ fontWeight: 500}}>Actividad de Reportes (Últimos 7 Días)</Typography>
          <Paper sx={{ p: 2, height: {xs: 300, md: 350}, borderRadius: '12px', overflow: 'auto', maxWidth: '90%'}} elevation={3}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={chartData} margin={{ top: 10, right: 20, left: -15, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" opacity={0.3} />
                <XAxis dataKey="date" interval={0} />
                <YAxis allowDecimals={false} />
                <Tooltip />
                <Legend />
                <Bar dataKey="count" fill="#26a69a" name="Nuevos Reportes" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Paper>
      </Grid>    

      <ReportDetailModal
        report={selectedReport}
        open={modalOpen}
        onClose={handleCloseModal}
        onAction={handleModerationAction}
      />
    </Box>
  );
}

export default DashboardOverview;