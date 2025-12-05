import React from 'react';
import { Box, Typography, Button, CircularProgress, Stack, Paper } from '@mui/material';
import { Forum as EmptyIcon } from '@mui/icons-material';
import ItemSmsLog from './ItemSmsLog';

function ListaSmsLog({ logs, loading, hasMore, onLoadMore, onDelete }) { // <-- Recibe onDelete

  if (loading && logs.length === 0) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}> <CircularProgress /> </Box>
    );
  }

  if (logs.length === 0) {
    return (
      <Paper variant="outlined" sx={{ p: 4, textAlign: 'center', borderStyle: 'dashed', bgcolor: 'action.hover', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2 }}> 
        <EmptyIcon sx={{ fontSize: 48, color: 'text.secondary', opacity: 0.5 }} />
        <Box>
            <Typography variant="h6" color="text.primary">No se encontraron registros</Typography> 
            <Typography variant="body2" color="text.secondary">Intenta ajustar los filtros.</Typography>
        </Box>
      </Paper>
    );
  }

  return (
    <Stack spacing={2}>
      {logs.map((log) => (
        <ItemSmsLog 
            key={log.id} 
            log={log} 
            onDelete={onDelete} // <-- Pasa la función al ítem
        />
      ))}

      {hasMore && (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 2, mt: 2 }}>
          <Button variant="contained" onClick={onLoadMore} disabled={loading} sx={{ minWidth: 200 }}>
            {loading ? <CircularProgress size={24} color="inherit" /> : 'Cargar registros anteriores'}
          </Button>
        </Box>
      )}

      {!hasMore && !loading && logs.length > 0 && (
        <Typography variant="caption" color="text.secondary" align="center" sx={{ py: 3, display: 'block' }}>
          — Fin del historial de SMS —
        </Typography>
      )}
    </Stack>
  );
}

export default ListaSmsLog;