// src/components/Sms/ListaSmsLog.jsx
import React from 'react';
import { Box, Typography, Button, CircularProgress, Stack, Paper } from '@mui/material';
import { Forum as EmptyIcon } from '@mui/icons-material';
import ItemSmsLog from './ItemSmsLog';

function ListaSmsLog({ logs, loading, hasMore, onLoadMore }) {

  if (loading && logs.length === 0) { // Carga inicial
      return (
           <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}>
              <CircularProgress />
           </Box>
      );
  }

  if (logs.length === 0) {
    return (
       <Paper
        variant="outlined"
        sx={{ p: 4, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2, backgroundColor: 'background.default', borderStyle: 'dashed' }}
      >
        <EmptyIcon sx={{ fontSize: 48, color: 'text.secondary' }} />
        <Typography variant="h6" color="text.secondary">No se encontraron registros</Typography>
        <Typography color="text.secondary" align="center">
          Intenta ajustar los filtros o revisa más tarde.
        </Typography>
      </Paper>
    );
  }

  return (
    <Stack spacing={2}>
      {logs.map((log) => (
        <ItemSmsLog key={log.id} log={log} />
      ))}

      {hasMore && (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 2 }}>
          {/* El botón "Cargar Más" muestra spinner si 'loading' es true (cargando paginación) */}
          <Button onClick={onLoadMore} disabled={loading}>
            {loading ? <CircularProgress size={24} /> : 'Cargar Más Registros'}
          </Button>
        </Box>
      )}
       {!hasMore && !loading && logs.length > 0 && (
         <Typography variant="caption" color="text.secondary" align="center" sx={{ py: 2 }}>
           Fin del historial de SMS
         </Typography>
      )}
    </Stack>
  );
}

export default ListaSmsLog;