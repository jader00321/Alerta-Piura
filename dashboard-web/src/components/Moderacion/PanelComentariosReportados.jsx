// dashboard-web/src/components/Moderacion/PanelComentariosReportados.jsx
import React, { useState, useEffect } from 'react';
import {
  Box, Typography, Button, Paper, CircularProgress, Alert,
  Stack, Divider, Grid, useTheme, Tooltip
} from '@mui/material';
import {
  ChatBubbleOutline as CommentIcon,
  Flag as ReportIcon,
  Person as PersonIcon,
  CheckCircle as CheckCircleIcon,
  Delete as DeleteIcon,
  Forum as EmptyIcon
} from '@mui/icons-material';
import adminService from '../../services/adminService';

function PanelComentariosReportados() {
  const [reportedComments, setReportedComments] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isResolving, setIsResolving] = useState(null);
  const theme = useTheme();

  const fetchReportedComments = () => {
    setIsLoading(true);
    setError(null);
    adminService.getReportedComments()
      .then(data => setReportedComments(data))
      .catch(err => {
        console.error("Error fetching reported comments:", err);
        setError(err.response?.data?.message || 'Error al cargar reportes');
      })
      .finally(() => setIsLoading(false));
  };

  useEffect(() => {
    fetchReportedComments();
  }, []);

  const handleResolve = (reportId, action) => {
    setIsResolving(reportId);
    adminService.resolveCommentReport(reportId, action)
      .then(() => {
        fetchReportedComments();
      })
      .catch(err => alert(err.response?.data?.message || 'Error al resolver reporte'))
      .finally(() => setIsResolving(null));
  };

  if (isLoading && !isResolving) {
    return <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}><CircularProgress /></Box>;
  }

  if (error) {
    return <Alert severity="error" sx={{ m: 2 }}>{error}</Alert>;
  }

  if (reportedComments.length === 0) {
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
        <Typography color="text.secondary">No hay comentarios reportados pendientes.</Typography>
      </Paper>
    );
  }

  return (
    <Stack spacing={2}>
      {reportedComments.map((report) => (
        <Paper 
          key={report.id} 
          variant="outlined" 
          sx={{ opacity: isResolving === report.id ? 0.6 : 1 }}
        >
          {/* --- FIX: Layout de Stack Vertical --- */}
          <Stack>
            {/* --- Contenido del Comentario --- */}
            <Box sx={{ p: 2.5 }}> {/* <-- Más padding */}
              <Stack spacing={2}>
                <Box>
                  {/* --- FIX: Aumento de fuente --- */}
                  <Typography variant="body1" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <ReportIcon fontSize="small" /> 
                    <strong>Motivo del Reporte:</strong> {report.motivo}
                  </Typography>
                  <Typography variant="body1" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: 1, mt: 1 }}>
                    <PersonIcon fontSize="small" /> 
                    <strong>Reportado por:</strong> {report.reportado_por}
                  </Typography>
                </Box>
                
                <Divider />

                {/* El comentario reportado */}
                <Paper 
                  variant="outlined" 
                  sx={{ 
                    p: 2, 
                    bgcolor: theme.palette.background.default,
                    borderLeft: `4px solid ${theme.palette.error.main}`
                  }}
                >
                  {/* --- FIX: Aumento de fuente --- */}
                  <Typography 
                    variant="h6" // <-- Más grande
                    sx={{ fontStyle: 'italic', wordBreak: 'break-word', fontWeight: 500 }}
                  >
                    "{report.comentario}"
                  </Typography>
                  <Typography variant="body2" color="text.secondary" sx={{ mt: 1, textAlign: 'right' }}>
                    — {report.autor_comentario}
                  </Typography>
                </Paper>
              </Stack>
            </Box>
            
            <Divider />

            {/* --- Acciones (Ahora debajo) --- */}
            <Box sx={{ p: 2, display: 'flex', justifyContent: 'flex-end', gap: 2 }}>
              <Button 
                color="success" 
                variant="outlined" 
                startIcon={<CheckCircleIcon />}
                onClick={() => handleResolve(report.id, 'desestimar')}
                disabled={isResolving === report.id}
              >
                Desestimar Reporte
              </Button>
              <Button 
                color="error" 
                variant="contained" 
                startIcon={<DeleteIcon />}
                onClick={() => handleResolve(report.id, 'eliminar_comentario')}
                disabled={isResolving === report.id}
              >
                Eliminar Comentario
              </Button>
            </Box>
          </Stack>
        </Paper>
      ))}
    </Stack>
  );
}

export default PanelComentariosReportados;