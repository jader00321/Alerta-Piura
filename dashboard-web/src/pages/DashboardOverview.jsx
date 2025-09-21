import React, { useEffect, useState } from 'react';
import { Grid, Paper, Typography, Box, CircularProgress } from '@mui/material';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import PeopleIcon from '@mui/icons-material/People';
import ReportIcon from '@mui/icons-material/Report';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import adminService from '../services/adminService';

// A reusable component for each statistic card
function StatCard({ title, value, icon }) {
  return (
    <Grid item xs={12} sm={6} md={4}>
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
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    // Fetch all data concurrently
    Promise.all([
      adminService.getStats(),
      adminService.getReportsByDay()
    ]).then(([statsData, reportsByDayData]) => {
      setStats(statsData);
      // Format date for display
      const formattedData = reportsByDayData.map(d => ({
        ...d,
        date: new Date(d.date).toLocaleDateString('es-ES', { day: 'numeric', month: 'short' }),
        count: parseInt(d.count, 10)
      }));
      setChartData(formattedData);
    }).catch(err => {
      console.error(err);
      setError('No se pudieron cargar los datos.');
    }).finally(() => {
      setLoading(false);
    });
  }, []);

  if (loading) {
    return <CircularProgress />;
  }

  if (error) {
    return <Typography color="error">{error}</Typography>;
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold', mb: 3 }}>
        Resumen del Sistema
      </Typography>
      <Grid container spacing={3}>
        <StatCard title="Usuarios Totales" value={stats.totalUsuarios} icon={<PeopleIcon color="primary" sx={{ fontSize: 40 }} />} />
        <StatCard title="Reportes Verificados" value={stats.reportesVerificados} icon={<CheckCircleIcon color="success" sx={{ fontSize: 40 }} />} />
        <StatCard title="Reportes Pendientes" value={stats.reportesPendientes} icon={<ReportIcon color="warning" sx={{ fontSize: 40 }} />} />
        <StatCard title="Comentarios Reportados" value={stats.comentariosReportados} icon={<ReportIcon color="error" sx={{ fontSize: 40 }} />} />
        <StatCard title="Usuarios Reportados" value={stats.usuariosReportados} icon={<PeopleIcon color="error" sx={{ fontSize: 40 }} />} />
      </Grid>
      <Paper sx={{ p: 2, mt: 4 }}>
        <Typography variant="h6" gutterBottom>Reportes en los Últimos 7 Días</Typography>
        <ResponsiveContainer width="100%" height={300}>
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
    </Box>
  );
}

export default DashboardOverview;