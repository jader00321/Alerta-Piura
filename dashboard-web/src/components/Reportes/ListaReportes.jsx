// src/components/Reportes/ListaReportes.jsx
import React from 'react';
import { Box, Typography, Button, CircularProgress, Stack, Paper } from '@mui/material';
import { FindInPage as EmptyIcon } from '@mui/icons-material'; // Icon for empty
import ItemReporteResumen from './ItemReporteResumen';

function ListaReportes({
  reports,
  loading, // True if loading MORE pages
  hasMore,
  onLoadMore,
  onOpenDrawer
}) {

  if (!loading && reports.length === 0) {
    return (
       <Paper
        variant="outlined"
        sx={{
          p: 4, display: 'flex', flexDirection: 'column',
          alignItems: 'center', gap: 2, mt: 3,
          backgroundColor: 'background.default', borderStyle: 'dashed'
        }}
      >
        <EmptyIcon sx={{ fontSize: 48, color: 'text.secondary' }} />
        <Typography variant="h6" color="text.secondary">No se encontraron reportes</Typography>
        <Typography color="text.secondary" align="center">
          Prueba ajustar los filtros o revisa más tarde.
        </Typography>
      </Paper>
    );
  }

  return (
    <Stack spacing={2} sx={{ mt: 3 }}> {/* Add margin top */}
      {reports.map((report, index) => (
        <ItemReporteResumen
          key={report.id}
          report={report}
          index={index}
          onOpenDrawer={onOpenDrawer}
        />
      ))}

      {hasMore && (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 2 }}>
          <Button variant="contained" onClick={onLoadMore} disabled={loading}>
            {loading ? <CircularProgress size={24} /> : 'Cargar Más Reportes'}
          </Button>
        </Box>
      )}
       {!hasMore && !loading && reports.length > 0 && (
         <Typography variant="caption" color="text.secondary" align="center" sx={{ py: 2 }}>
           Fin de los reportes
         </Typography>
      )}
    </Stack>
  );
}

export default ListaReportes;