import React, { useEffect, useState, useCallback } from 'react';
import { Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography, TextField, Button, CircularProgress } from '@mui/material';
import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce';

function SmsLogPage() {
  const [logs, setLogs] = useState([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const [loading, setLoading] = useState(false);
  const [filters, setFilters] = useState({ search: '' });
  const debouncedSearch = useDebounce(filters.search, 500);

  const fetchLogs = useCallback((isNewSearch) => {
    const pageToFetch = isNewSearch ? 1 : page;
    setLoading(true);
    adminService.getSmsLog({ search: debouncedSearch, page: pageToFetch })
      .then(newLogs => {
        setLogs(isNewSearch ? newLogs : prev => [...prev, ...newLogs]);
        setHasMore(newLogs.length === 20);
        if (isNewSearch) setPage(1);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [page, debouncedSearch]);

  useEffect(() => {
    fetchLogs(true);
  }, [debouncedSearch, fetchLogs]);

  const handleLoadMore = () => {
    if (hasMore && !loading) {
      setPage(prev => prev + 1);
    }
  };
  
  useEffect(() => {
      if (page > 1) {
          fetchLogs(false);
      }
  }, [page, debouncedSearch, filters.search, loading, hasMore, setPage, setLogs, fetchLogs]);


  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Registro de SMS Simulados
      </Typography>

      <Paper sx={{ p: 2, mb: 3, display: 'flex', alignItems: 'center', gap: 2 }}>
        <TextField
          fullWidth
          size="small"
          label="Buscar en mensajes, contactos o alias de usuario..."
          value={filters.search}
          onChange={(e) => setFilters({ ...filters, search: e.target.value })}
        />
      </Paper>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Fecha de Envío</TableCell>
              <TableCell>Usuario SOS</TableCell>
              <TableCell>Nº Contacto</TableCell>
              <TableCell>Mensaje Enviado</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {logs.map((log) => (
              <TableRow key={log.id} hover>
                <TableCell>{new Date(log.fecha_envio).toLocaleString()}</TableCell>
                <TableCell>{log.usuario_sos_alias || 'N/A'}</TableCell>
                <TableCell>{log.contacto_telefono}</TableCell>
                <TableCell sx={{ whiteSpace: 'pre-wrap', wordBreak: 'break-word' }}>{log.mensaje}</TableCell>
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

export default SmsLogPage;