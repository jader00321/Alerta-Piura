import React, { useEffect, useState, useCallback } from 'react';
import { Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography, IconButton, Tooltip, TextField, Button, CircularProgress } from '@mui/material';
import { Delete as DeleteIcon, Replay as ReplayIcon } from '@mui/icons-material';
import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce';

function NotificationHistoryPage() {
  const [history, setHistory] = useState([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const [loading, setLoading] = useState(false);
  const [filters, setFilters] = useState({ search: '' });
  const debouncedSearch = useDebounce(filters.search, 500);

  const fetchHistory = useCallback((isNewSearch) => {
    const pageToFetch = isNewSearch ? 1 : page;
    setLoading(true);
    adminService.getNotificationHistory({ search: debouncedSearch, page: pageToFetch })
      .then(newHistory => {
        setHistory(isNewSearch ? newHistory : prev => [...prev, ...newHistory]);
        setHasMore(newHistory.length === 20);
        if (isNewSearch) setPage(1);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [page, debouncedSearch]);

  useEffect(() => {
    fetchHistory(true);
  }, [debouncedSearch, fetchHistory]);
  
  const handleLoadMore = () => {
    if (hasMore && !loading) {
      setPage(prev => prev + 1);
    }
  };

  useEffect(() => {
    if (page > 1) {
        fetchHistory(false);
    }
  }, [page, debouncedSearch, filters.search, loading, hasMore, setPage, setHistory, fetchHistory]);


  const handleDelete = (id) => {
    if (window.confirm('¿Eliminar esta notificación del historial?')) {
      adminService.deleteNotification(id).then(() => fetchHistory(true));
    }
  };

  const handleResend = (notif) => {
    if (window.confirm(`¿Reenviar esta notificación a "${notif.receptor}"?`)) {
      adminService.sendNotification([notif.id_usuario_receptor], notif.titulo, notif.cuerpo)
        .then(() => {
            alert('Notificación reenviada. El historial se actualizará en la próxima recarga.');
        })
        .catch(() => alert('Error al reenviar la notificación.'));
    }
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Historial de Notificaciones Enviadas
      </Typography>

      <Paper sx={{ p: 2, mb: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
        <TextField
          fullWidth
          size="small"
          label="Buscar en título, mensaje o destinatario..."
          value={filters.search}
          onChange={(e) => setFilters({ ...filters, search: e.target.value })}
        />
      </Paper>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Fecha</TableCell>
              <TableCell>Destinatario (Alias)</TableCell>
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
                <TableCell>{notif.titulo}</TableCell>
                <TableCell>{notif.cuerpo}</TableCell>
                <TableCell align="right">
                  <Tooltip title="Reenviar Notificación">
                    <IconButton onClick={() => handleResend(notif)} color="primary">
                      <ReplayIcon />
                    </IconButton>
                  </Tooltip>
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

      {hasMore && (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 2 }}>
          <Button onClick={handleLoadMore} disabled={loading}>
            {loading ? <CircularProgress size={24} /> : 'Cargar Más'}
          </Button>
        </Box>
      )}
    </Box>
  );
}

export default NotificationHistoryPage;