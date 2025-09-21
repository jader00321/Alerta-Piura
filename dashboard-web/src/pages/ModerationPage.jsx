import React, { useEffect, useState } from 'react';
import { Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography, Button, ButtonGroup, Tabs, Tab } from '@mui/material';
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

// --- Main Component with Tabs ---
function ModerationPage() {
  const [tabIndex, setTabIndex] = useState(0);

  const handleTabChange = (event, newValue) => {
    setTabIndex(newValue);
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Panel de Moderación
      </Typography>
      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 2 }}>
        <Tabs value={tabIndex} onChange={handleTabChange}>
          <Tab label="Comentarios Reportados" />
          <Tab label="Usuarios Reportados" />
        </Tabs>
      </Box>
      
      {/* Conditionally render the content based on the selected tab */}
      {tabIndex === 0 && <ReportedCommentsPanel />}
      {tabIndex === 1 && <ReportedUsersPanel />}

    </Box>
  );
}

export default ModerationPage;