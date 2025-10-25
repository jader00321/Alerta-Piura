/**

* Componente: ListaSmsLog
* ---
* Renderiza una lista de registros de SMS enviados o recibidos, con soporte para
* carga paginada y manejo de estados de carga.
*
* El componente está pensado para mostrar logs dentro del panel de administración,
* permitiendo al usuario revisar el historial, aplicar filtros y cargar más datos
* cuando sea necesario.
  */

import React from 'react';
import { Box, Typography, Button, CircularProgress, Stack, Paper } from '@mui/material';
import { Forum as EmptyIcon } from '@mui/icons-material';
import ItemSmsLog from './ItemSmsLog';

/**

* Props:
* * logs: Array con los registros de SMS (cada objeto incluye id, mensaje, fecha, etc.)
* * loading: Boolean que indica si se están cargando datos (tanto inicial como paginación)
* * hasMore: Boolean que indica si hay más registros por cargar
* * onLoadMore: Función callback ejecutada al presionar "Cargar más"
    */
function ListaSmsLog({ logs, loading, hasMore, onLoadMore }) {
  /*                      Estado inicial: cargando datos base                   */
  if (loading && logs.length === 0) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}> <CircularProgress /> </Box>
    );
  }
  /*                      Caso vacío: sin registros para mostrar                */
  if (logs.length === 0) {
    return (
      <Paper
        variant="outlined"
        sx={{
          p: 4,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: 2,
          backgroundColor: 'background.default',
          borderStyle: 'dashed'
        }}
      >
        <EmptyIcon sx={{ fontSize: 48, color: 'text.secondary' }} /> <Typography variant="h6" color="text.secondary">No se encontraron registros</Typography> <Typography color="text.secondary" align="center">
          Intenta ajustar los filtros o revisa más tarde. </Typography> </Paper>
    );
  }

  /*                            Renderizado principal                           */
  return (<Stack spacing={2}>
    {/* Itera sobre los logs y renderiza cada entrada con su propio componente */}
    {logs.map((log) => (<ItemSmsLog key={log.id} log={log} />
    ))}

    ```
    {/* Botón de carga incremental de registros */}
    {hasMore && (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 2 }}>
        {/* Muestra spinner si 'loading' es true (paginación en curso) */}
        <Button onClick={onLoadMore} disabled={loading}>
          {loading ? <CircularProgress size={24} /> : 'Cargar Más Registros'}
        </Button>
      </Box>
    )}

    {/* Mensaje final cuando no hay más registros */}
    {!hasMore && !loading && logs.length > 0 && (
      <Typography
        variant="caption"
        color="text.secondary"
        align="center"
        sx={{ py: 2 }}
      >
        Fin del historial de SMS
      </Typography>
    )}
  </Stack>
  );
}

export default ListaSmsLog;
