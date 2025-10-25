// dashboard-web/src/components/Moderacion/PanelHistorialModeracion.jsx
import React, { useState, useEffect } from 'react';
import {
  Box, Paper, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Typography, CircularProgress, Chip,
  Alert
} from '@mui/material';
import adminService from '../../services/adminService';

// Helper para dar color a las acciones
const ActionChip = ({ action }) => {
  let color = 'default';
  if (action.includes('ELIMINAR') || action.includes('SUSPENDER')) {
    color = 'error';
  } else if (action.includes('DESESTIMAR')) {
    color = 'success';
  }
  return <Chip label={action} color={color} size="small" variant="outlined" />;
};

function PanelHistorialModeracion() {
  const [history, setHistory] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    setIsLoading(true);
    adminService.getModerationHistory()
      .then(setHistory)
      .catch(err => {
        console.error("Error fetching history:", err);
        setError(err.response?.data?.message || 'Error al cargar historial');
      })
      .finally(() => setIsLoading(false));
  }, []);

  if (isLoading) {
    return <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}><CircularProgress /></Box>;
  }

  if (error) {
    return <Alert severity="error" sx={{ m: 2 }}>{error}</Alert>;
  }

  return (
    <TableContainer component={Paper} sx={{ maxHeight: '70vh' }}>
      <Table stickyHeader>
        <TableHead>
          <TableRow>
            <TableCell sx={{ fontWeight: 'bold' }}>Fecha</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Admin</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Acción</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Contenido Afectado</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {history.length > 0 ? history.map(log => (
            <TableRow key={log.id} hover>
              <TableCell>
                <Typography variant="body2" noWrap>
                  {new Date(log.fecha_accion).toLocaleString()}
                </Typography>
              </TableCell>
              <TableCell>{log.admin_alias}</TableCell>
              <TableCell>
                <ActionChip action={log.accion.replace('_', ' ').toUpperCase()} />
              </TableCell>
              <TableCell>
                <Typography variant="body2" sx={{ fontStyle: 'italic' }}>
                  "{log.contenido_afectado}"
                </Typography>
              </TableCell>
            </TableRow>
          )) : (
            <TableRow>
              <TableCell colSpan={4} align="center">
                <Typography color="text.secondary" sx={{ p: 3 }}>
                  No hay acciones de moderación registradas.
                </Typography>
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </TableContainer>
  );
}

export default PanelHistorialModeracion;