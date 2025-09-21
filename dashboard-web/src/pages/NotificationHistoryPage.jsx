import React, { useEffect, useState, useCallback } from 'react';
import { Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography, IconButton, Tooltip } from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import adminService from '../services/adminService';

function NotificationHistoryPage() {
  const [history, setHistory] = useState([]);

  const fetchHistory = useCallback(() => {
    adminService.getNotificationHistory()
      .then(setHistory)
      .catch(err => console.error("Error fetching notification history:", err));
  }, []);

  useEffect(() => {
    fetchHistory();
  }, [fetchHistory]);

  const handleDelete = (id) => {
    if (window.confirm('¿Eliminar esta notificación del historial?')) {
      adminService.deleteNotification(id).then(fetchHistory);
    }
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Historial de Notificaciones Enviadas
      </Typography>
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Fecha</TableCell>
              <TableCell>Destinatario</TableCell>
              <TableCell>Email del Destinatario</TableCell> 
              <TableCell>Título</TableCell>
              <TableCell>Mensaje</TableCell>
              <TableCell align="right">Acciones</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {history.map((notif) => (
              <TableRow key={notif.id} hover>
                <TableCell>{new Date(notif.fecha_envio).toLocaleString()}</TableCell>
                <TableCell>{notif.receptor}</TableCell>
                <TableCell>{notif.receptor_email}</TableCell> 
                <TableCell>{notif.titulo}</TableCell>
                <TableCell>{notif.cuerpo}</TableCell>
                <TableCell align="right">
                  <Tooltip title="Eliminar">
                    <IconButton onClick={() => handleDelete(notif.id)} color="error">
                      <DeleteIcon />
                    </IconButton>
                  </Tooltip>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}

export default NotificationHistoryPage;