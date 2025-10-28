import React from 'react';
import { Box, Paper, Typography, Button, CircularProgress, Stack } from '@mui/material';
import { MarkChatRead as EmptyIcon, SearchOff as NoResultsIcon } from '@mui/icons-material';
import ItemHistorialNotificacion from './ItemHistorialNotificacion';

/**
 * Muestra una lista (Stack) de notificaciones enviadas (historial).
 * * Este componente es responsable de:
 * 1. Renderizar un <ItemHistorialNotificacion> por cada notificación en el prop `history`.
 * 2. Mostrar un estado vacío específico (con ícono <NoResultsIcon>) si `history` está vacío 
 * y `loading` es falso, indicando que la búsqueda o filtros no arrojaron resultados.
 * 3. Mostrar un botón "Cargar Más" si `hasMore` es verdadero, que muestra un 
 * <CircularProgress> si `loading` (cargando más) es verdadero.
 * 4. Mostrar un mensaje de "Fin del historial" cuando `hasMore` es falso.
 *
 * @param {object} props - Propiedades del componente.
 * @param {Array<object>} props.history - Array de objetos de notificación a mostrar.
 * @param {boolean} props.loading - Indica si se está cargando la *siguiente* página (paginación).
 * @param {boolean} props.hasMore - Indica si hay más notificaciones por cargar.
 * @param {Function} props.onLoadMore - Callback ejecutado al hacer clic en 'Cargar Más'.
 * @param {Function} props.onResend - Callback para reenviar una notificación (pasado a `ItemHistorialNotificacion`).
 * @param {Function} props.onDelete - Callback para eliminar una notificación (pasado a `ItemHistorialNotificacion`).
 * @returns {JSX.Element} El componente de la lista del historial.
 */
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