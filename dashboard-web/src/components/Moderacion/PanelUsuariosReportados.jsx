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

/**

* Panel de administración que muestra los usuarios reportados por otros usuarios.
* Permite desestimar reportes o suspender a usuarios directamente.
*
* @component
* @example
* return <PanelUsuariosReportados />
  */
function PanelUsuariosReportados() {
  /** @type {[Array<Object>, Function]} Lista de usuarios reportados obtenida desde la API */
  const [reportedUsers, setReportedUsers] = useState([]);
  /** @type {[boolean, Function]} Estado de carga general */
  const [isLoading, setIsLoading] = useState(true);
  /** @type {[string|null, Function]} Mensaje de error en caso de fallo al cargar */
  const [error, setError] = useState(null);
  /** @type {[number|null, Function]} ID del reporte que se está resolviendo actualmente */
  const [isResolving, setIsResolving] = useState(null);

  /**
  
  * Obtiene la lista de usuarios reportados desde el servicio adminService.
  * Maneja el estado de carga y los errores.
  * @returns {void}
    */
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

  // Ejecuta la carga inicial al montar el componente
  useEffect(() => { fetchReportedUsers(); }, []);

  /**
  
  * Maneja la resolución de un reporte (desestimar o suspender usuario).
  * Llama al servicio adminService y actualiza la lista de reportes.
  *
  * @param {number} reportId - ID del reporte que se está resolviendo.
  * @param {'desestimar' | 'suspender_usuario'} action - Acción a ejecutar.
  * @param {number|null} userId - ID del usuario afectado (si aplica).
  * @returns {void}
    */
  const handleResolve = (reportId, action, userId) => {
    setIsResolving(reportId);
    adminService.resolveUserReport(reportId, action, userId)
      .then(() => fetchReportedUsers())
      .catch(err => alert(err.response?.data?.message || 'Error al resolver reporte'))
      .finally(() => setIsResolving(null));
  };

  // --- Renderizado condicional ---

  if (isLoading && !isResolving) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}> <CircularProgress /> </Box>
    );
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
        <EmptyIcon sx={{ fontSize: 48, color: 'text.secondary' }} /> <Typography variant="h6" color="text.secondary">No hay reportes</Typography> <Typography color="text.secondary">
          No hay usuarios reportados pendientes. </Typography> </Paper>
    );
  }

  // --- Render principal ---

  return (<Stack spacing={2}>
    {reportedUsers.map((report) => (
      <Paper
        key={report.id}
        variant="outlined"
        sx={{ opacity: isResolving === report.id ? 0.6 : 1 }}
      > <Stack>
          {/* Información del usuario reportado */}
          <Box sx={{ p: 2.5 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
              <Avatar sx={{ bgcolor: 'error.main', width: 48, height: 48 }}>
                {report.usuario_reportado_nombre
                  ? report.usuario_reportado_nombre[0].toUpperCase()
                  : '?'} </Avatar> <Box>
                <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
                  {report.usuario_reportado_nombre} </Typography>
                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}> <EmailIcon fontSize="small" color="action" /> <Typography variant="body2" color="text.secondary">
                  {report.usuario_reportado_email} </Typography> </Box> </Box> </Box>

            ```
            <Divider />

            <Stack spacing={1.5} sx={{ mt: 2 }}>
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

          {/* Acciones */}
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
