import React, { useEffect, useState } from 'react';
import { Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography, Button, ButtonGroup, Tabs, Tab, Accordion, AccordionSummary, AccordionDetails } from '@mui/material';
import ExpandMoreIcon from '@mui/icons-material/ExpandMore';
import adminService from '../services/adminService';

// --- Panel for Reported Comments ---
function ReportedCommentsPanel() {
  const [reportedComments, setReportedComments] = useState([]);

  useEffect(() => {
    fetchReportedComments();
  }, []);

  const fetchReportedComments = () => {
    adminService.getReportedComments()
      .then(data => setReportedComments(data))
      .catch(err => console.error("Error fetching reported comments:", err));
  };

  const handleResolve = (reportId, action) => {
    adminService.resolveCommentReport(reportId, action)
      .then(() => {
        fetchReportedComments(); // Refresh the list
      })
      .catch(err => alert(err.response?.data?.message || 'Error al resolver reporte'));
  };

  return (
    <TableContainer component={Paper}>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell sx={{ fontWeight: 'bold' }}>Comentario Reportado</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Autor</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Reportado Por</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Motivo</TableCell>
            <TableCell sx={{ fontWeight: 'bold', width: '250px' }}>Acciones</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {reportedComments.length > 0 ? reportedComments.map((report) => (
            <TableRow key={report.id} hover>
              <TableCell sx={{ fontStyle: 'italic' }}>"{report.comentario}"</TableCell>
              <TableCell>{report.autor_comentario}</TableCell>
              <TableCell>{report.reportado_por}</TableCell>
              <TableCell>{report.motivo}</TableCell>
              <TableCell>
                <ButtonGroup variant="outlined" size="small">
                  <Button color="success" onClick={() => handleResolve(report.id, 'desestimar')}>
                    Desestimar
                  </Button>
                  <Button color="error" onClick={() => handleResolve(report.id, 'eliminar_comentario')}>
                    Eliminar Comentario
                  </Button>
                </ButtonGroup>
              </TableCell>
            </TableRow>
          )) : (
            <TableRow>
              <TableCell colSpan={5} align="center">No hay comentarios reportados pendientes.</TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </TableContainer>
  );
}

// --- Panel for Reported Users ---
function ReportedUsersPanel() {
  const [reportedUsers, setReportedUsers] = useState([]);
  useEffect(() => { fetchReportedUsers(); }, []);

  const fetchReportedUsers = () => {
    adminService.getReportedUsers()
      .then(data => setReportedUsers(data))
      .catch(err => console.error("Error fetching reported users:", err));
  };

  const handleResolve = (reportId, action, userId) => {
    adminService.resolveUserReport(reportId, action, userId)
      .then(() => fetchReportedUsers())
      .catch(err => alert(err.response?.data?.message || 'Error al resolver reporte'));
  };

  return (
    <TableContainer component={Paper}>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell sx={{ fontWeight: 'bold' }}>Usuario Reportado</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Email</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Reportado Por</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Motivo</TableCell>
            <TableCell sx={{ fontWeight: 'bold', width: '250px' }}>Acciones</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {reportedUsers.length > 0 ? reportedUsers.map((report) => (
            <TableRow key={report.id} hover>
              <TableCell>{report.usuario_reportado_nombre}</TableCell>
              <TableCell>{report.usuario_reportado_email}</TableCell>
              <TableCell>{report.reportado_por}</TableCell>
              <TableCell>{report.motivo}</TableCell>
              <TableCell>
                <ButtonGroup variant="outlined" size="small">
                  <Button color="success" onClick={() => handleResolve(report.id, 'desestimar', null)}>
                    Desestimar
                  </Button>
                  <Button color="error" onClick={() => handleResolve(report.id, 'suspender_usuario', report.id_usuario_reportado)}>
                    Suspender Usuario
                  </Button>
                </ButtonGroup>
              </TableCell>
            </TableRow>
          )) : (
            <TableRow>
              <TableCell colSpan={4} align="center">No hay usuarios reportados pendientes.</TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </TableContainer>
  );
}

function ModerationHistoryPanel() {
  const [history, setHistory] = useState([]);
  useEffect(() => {
    adminService.getModerationHistory().then(setHistory);
  }, []);

  return (
    <TableContainer component={Paper}>
      <Table>
        <TableHead>
          <TableRow>
            <TableCell>Fecha</TableCell>
            <TableCell>Admin</TableCell>
            <TableCell>Acción</TableCell>
            <TableCell>Contenido Afectado</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {history.map(log => (
            <TableRow key={log.id}>
              <TableCell>{new Date(log.fecha_accion).toLocaleString()}</TableCell>
              <TableCell>{log.admin_alias}</TableCell>
              <TableCell>{log.accion.replace('_', ' ').toUpperCase()}</TableCell>
              <TableCell>"{log.contenido_afectado}"</TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  );
}

function ModerationPage() {
  const [tabIndex, setTabIndex] = useState(0);
  const handleTabChange = (event, newValue) => setTabIndex(newValue);

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>Panel de Moderación</Typography>
      
      <Accordion sx={{ mb: 3 }}>
        <AccordionSummary expandIcon={<ExpandMoreIcon />}>
          <Typography>Guía de Procesos de Moderación</Typography>
        </AccordionSummary>
        <AccordionDetails>
          <Typography variant="h6">Pasos para Moderar Comentarios</Typography>
          <Typography variant="body2" paragraph>1. Lee el comentario y el motivo del reporte. 2. Verifica el contexto (si es necesario, visita el reporte). 3. Decide si el comentario viola las normas. 4. Toma una acción: Desestimar o Eliminar.</Typography>
          <Typography variant="h6">Pasos para Moderar Usuarios</Typography>
          <Typography variant="body2" paragraph>1. Revisa el motivo del reporte. 2. Considera el historial del usuario (si ha sido reportado antes). 3. Evalúa la gravedad de la falta. 4. Toma una acción: Desestimar o Suspender.</Typography>
        </AccordionDetails>
      </Accordion>

      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 2 }}>
        <Tabs value={tabIndex} onChange={handleTabChange}>
          <Tab label="Comentarios Reportados" />
          <Tab label="Usuarios Reportados" />
          <Tab label="Historial de Acciones" />
        </Tabs>
      </Box>
      
      {tabIndex === 0 && <ReportedCommentsPanel />}
      {tabIndex === 1 && <ReportedUsersPanel />}
      {tabIndex === 2 && <ModerationHistoryPanel />}
    </Box>
  );
}

export default ModerationPage;