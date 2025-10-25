// src/components/Notificaciones/ListaHistorialNotificaciones.jsx
import React from 'react';
import { Box, Paper, Typography, Button, CircularProgress, Stack } from '@mui/material';
import { MarkChatRead as EmptyIcon, SearchOff as NoResultsIcon } from '@mui/icons-material'; // Added NoResultsIcon
import ItemHistorialNotificacion from './ItemHistorialNotificacion';

function ListaHistorialNotificaciones({
  history,
  loading, // Only true when loading MORE pages (page > 1)
  hasMore,
  onLoadMore,
  onResend,
  onDelete
}) {

  // --- FIX: Specific message for "No results found" after filtering ---
  // We only show this if loading is false AND history is empty.
  // The parent component handles the "Select filters first" message.
  if (!loading && history.length === 0) {
    return (
      <Paper
        variant="outlined"
        sx={{
          p: 4, display: 'flex', flexDirection: 'column',
          alignItems: 'center', gap: 2,
          backgroundColor: 'background.default', borderStyle: 'dashed'
        }}
      >
        <NoResultsIcon sx={{ fontSize: 48, color: 'text.secondary' }} />
        <Typography variant="h6" color="text.secondary">No se encontraron notificaciones</Typography>
        <Typography color="text.secondary" align="center">
          Intenta ajustar los filtros de usuario, fecha o búsqueda.
        </Typography>
      </Paper>
    );
  }

  return (
    <Stack spacing={2}>
      {/* Lista de Tarjetas de Notificación */}
      {history.map((notif) => (
        <ItemHistorialNotificacion
          key={notif.id}
          notif={notif}
          onResend={onResend}
          onDelete={onDelete}
        />
      ))}

      {/* Botón de Cargar Más */}
      {/* Show button only if there are potentially more items and history isn't empty */}
      {hasMore && history.length > 0 && (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 2 }}>
          {/* Disable button while loading more pages */}
          <Button onClick={onLoadMore} disabled={loading}>
            {loading ? <CircularProgress size={24} /> : 'Cargar Más'}
          </Button>
        </Box>
      )}

      {/* Optional: Show a message if loading is done and there are no more pages */}
      {!hasMore && !loading && history.length > 0 && (
         <Typography variant="caption" color="text.secondary" align="center" sx={{ py: 2 }}>
           Fin del historial
         </Typography>
      )}
    </Stack>
  );
}

export default ListaHistorialNotificaciones;