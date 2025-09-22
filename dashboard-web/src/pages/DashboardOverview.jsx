import React, { useEffect, useState, useCallback } from 'react';
import { Grid, Paper, Typography, Box, CircularProgress, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Link as MuiLink } from '@mui/material';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import PeopleIcon from '@mui/icons-material/People';
import ReportIcon from '@mui/icons-material/Report';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import { Link as RouterLink } from 'react-router-dom';
import adminService from '../services/adminService';

function StatCard({ title, value, icon }) {
  return (
    <Grid item xs={12} sm={6} md={4} lg={2.4}>
      <Paper 
        elevation={3}
        sx={{ 
          p: 2, 
          display: 'flex', 
          alignItems: 'center',
          borderRadius: 2,
        }}
      >
        <Box sx={{ mr: 2 }}>{icon}</Box>
        <Box>
          <Typography color="text.secondary">{title}</Typography>
          <Typography variant="h5" component="p" sx={{ fontWeight: 'bold' }}>
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
  const [error, setError] = useState('');

  // We use useCallback to memoize the function, preventing it from being recreated on every render.
  const fetchData = useCallback(() => {
    setLoading(true);
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
    }).catch(err => {
      console.error(err);
      setError('No se pudieron cargar los datos del resumen.');
    }).finally(() => {
      setLoading(false);
    });
  }, []); // The dependency array is empty, so this function is created only once.

  // This useEffect hook will run only once when the component mounts.
  useEffect(() => {
    fetchData();
  }, [fetchData]);

  if (loading) {
    return <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}><CircularProgress /></Box>;
  }

  if (error) {
    return <Typography color="error">{error}</Typography>;
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Resumen del Sistema
      </Typography>
      
      <Typography variant="body2" color="text.secondary" sx={{ mb: 3 }}>
        Este panel muestra las métricas clave y las tendencias más recientes del sistema. Úselo para obtener una visión general rápida de la actividad de los usuarios y el estado de los reportes.
      </Typography>
      
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <StatCard title="Usuarios Totales" value={stats.totalUsuarios} icon={<PeopleIcon color="primary" sx={{ fontSize: 40 }} />} />
        <StatCard title="Reportes Verificados" value={stats.reportesVerificados} icon={<CheckCircleIcon color="success" sx={{ fontSize: 40 }} />} />
        <StatCard title="Reportes Pendientes" value={stats.reportesPendientes} icon={<ReportIcon color="warning" sx={{ fontSize: 40 }} />} />
        <StatCard title="Comentarios Reportados" value={stats.comentariosReportados} icon={<ReportIcon color="error" sx={{ fontSize: 40 }} />} />
        <StatCard title="Usuarios Reportados" value={stats.usuariosReportados} icon={<PeopleIcon color="error" sx={{ fontSize: 40 }} />} />
      </Grid>
      
      <Grid container spacing={4}>
        <Grid item xs={12} lg={5}>
          <Typography variant="h6" gutterBottom>Últimos Reportes Pendientes</Typography>
          <TableContainer component={Paper}>
            <Table size="small">
              <TableHead>
                <TableRow>
                  <TableCell>Título</TableCell>
                  <TableCell>Categoría</TableCell>
                  <TableCell>Autor</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {latestReports.length > 0 ? latestReports.map((report) => (
                  <TableRow key={report.id} hover>
                    <TableCell>
                      <MuiLink component={RouterLink} to="/reports" underline="hover">
                        {report.titulo}
                      </MuiLink>
                    </TableCell>
                    <TableCell>{report.categoria}</TableCell>
                    <TableCell>{report.autor}</TableCell>
                  </TableRow>
                )) : (
                  <TableRow>
                    <TableCell colSpan={3} align="center">No hay reportes pendientes.</TableCell>
                  </TableRow>
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Grid>
        
        <Grid item xs={12} lg={7}>
          <Typography variant="h6" gutterBottom>Reportes en los Últimos 7 Días</Typography>
          <Paper sx={{ p: 2, height: { xs: 250, md: 300 } }}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={chartData} margin={{ top: 5, right: 20, left: -10, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="date" />
                <YAxis allowDecimals={false} />
                <Tooltip />
                <Legend />
                <Bar dataKey="count" fill="#26a69a" name="Nuevos Reportes" />
              </BarChart>
            </ResponsiveContainer>
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}

export default DashboardOverview;