// dashboard-web/src/components/Moderacion/PanelUsuariosReportados.jsx
import React, { useState, useEffect } from 'react';
import {
  Box, Typography, Button, Paper, CircularProgress, Alert,
  Stack, Divider, Avatar
} from '@mui/material';
import {
  Flag as ReportIcon,
  Person as PersonIcon,
  Email as EmailIcon,
  CheckCircle as CheckCircleIcon,
  Block as BlockIcon,
  GroupOff as EmptyIcon
} from '@mui/icons-material';
import adminService from '../../services/adminService';

function PanelUsuariosReportados() {
  const [reportedUsers, setReportedUsers] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isResolving, setIsResolving] = useState(null);

  const fetchReportedUsers = () => {
    setIsLoading(true);
    setError(null);
    adminService.getReportedUsers()
      .then(data => setReportedUsers(data))
      .catch(err => {
        console.error("Error fetching reported users:", err);
        setError(err.response?.data?.message || 'Error al cargar reportes');
      })
      .finally(() => setIsLoading(false));
  };

  useEffect(() => { fetchReportedUsers(); }, []);

  const handleResolve = (reportId, action, userId) => {
    setIsResolving(reportId);
    adminService.resolveUserReport(reportId, action, userId)
      .then(() => fetchReportedUsers())
      .catch(err => alert(err.response?.data?.message || 'Error al resolver reporte'))
      .finally(() => setIsResolving(null));
  };

  if (isLoading && !isResolving) {
    return <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}><CircularProgress /></Box>;
  }

  if (error) {
    return <Alert severity="error" sx={{ m: 2 }}>{error}</Alert>;
  }
  
  if (reportedUsers.length === 0) {
    return (
      <Paper 
        variant="outlined" 
        sx={{ 
          p: 4, display: 'flex', flexDirection: 'column', 
          alignItems: 'center', gap: 2, 
          backgroundColor: 'background.default', borderStyle: 'dashed' 
        }}
      >
        <EmptyIcon sx={{ fontSize: 48, color: 'text.secondary' }} />
        <Typography variant="h6" color="text.secondary">No hay reportes</Typography>
        <Typography color="text.secondary">No hay usuarios reportados pendientes.</Typography>
      </Paper>
    );
  }

  return (
    <Stack spacing={2}>
      {reportedUsers.map((report) => (
        <Paper 
          key={report.id} 
          variant="outlined" 
          sx={{ opacity: isResolving === report.id ? 0.6 : 1 }}
        >
          {/* --- FIX: Layout de Stack Vertical --- */}
          <Stack>
            {/* --- Info del Usuario Reportado --- */}
            <Box sx={{ p: 2.5 }}> {/* <-- Más padding */}
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                <Avatar sx={{ bgcolor: 'error.main', width: 48, height: 48 }}>
                  {report.usuario_reportado_nombre ? report.usuario_reportado_nombre[0].toUpperCase() : '?'}
                </Avatar>
                <Box>
                  <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
                    {report.usuario_reportado_nombre}
                  </Typography>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <EmailIcon fontSize="small" color="action" />
                    <Typography variant="body2" color="text.secondary">
                      {report.usuario_reportado_email}
                    </Typography>
                  </Box>
                </Box>
              </Box>
              
              <Divider />

              {/* Detalles del Reporte */}
              <Stack spacing={1.5} sx={{ mt: 2 }}>
                {/* --- FIX: Aumento de fuente --- */}
                <Typography variant="body1" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <ReportIcon fontSize="small" color="action" />
                  <strong>Motivo:</strong> {report.motivo}
                </Typography>
                <Typography variant="body1" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                  <PersonIcon fontSize="small" color="action" />
                  <strong>Reportado por:</strong> {report.reportado_por}
                </Typography>
              </Stack>
            </Box>
            
            <Divider />

            {/* --- Acciones (Ahora debajo) --- */}
            <Box sx={{ p: 2, display: 'flex', justifyContent: 'flex-end', gap: 2 }}>
              <Button 
                color="success" 
                variant="outlined" 
                startIcon={<CheckCircleIcon />}
                onClick={() => handleResolve(report.id, 'desestimar', null)}
                disabled={isResolving === report.id}
              >
                Desestimar Reporte
              </Button>
              <Button 
                color="error" 
                variant="contained" 
                startIcon={<BlockIcon />}
                onClick={() => handleResolve(report.id, 'suspender_usuario', report.id_usuario_reportado)}
                disabled={isResolving === report.id}
              >
                Suspender Usuario
              </Button>
            </Box>
          </Stack>
        </Paper>
      ))}
    </Stack>
  );
}

export default PanelUsuariosReportados;