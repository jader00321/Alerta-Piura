/**

* Componente: ListaReportes
* ---
* Muestra una lista de reportes en formato resumido, con soporte para:
* * Indicador de carga (spinner) al traer más datos.
* * Botón "Cargar más reportes".
* * Mensaje amigable cuando no existen resultados.
*
* Este componente trabaja junto con `ItemReporteResumen`, que se encarga de
* renderizar cada tarjeta individual de reporte.
  */

import React from 'react';
import { Box, Typography, Button, CircularProgress, Stack, Paper } from '@mui/material';
import { FindInPage as EmptyIcon } from '@mui/icons-material';
import ItemReporteResumen from './ItemReporteResumen';

/* -------------------------------------------------------------------------- */
/*                              COMPONENTE PRINCIPAL                          */
/* -------------------------------------------------------------------------- */

/**

* @param {Object} props - Propiedades del componente.
* @param {Array} props.reports - Lista de objetos de reportes a mostrar.
* @param {boolean} props.loading - Indica si se están cargando más reportes.
* @param {boolean} props.hasMore - Indica si hay más reportes disponibles.
* @param {Function} props.onLoadMore - Función que se ejecuta al hacer clic en "Cargar Más".
* @param {Function} props.onOpenDrawer - Función para abrir el panel o drawer con los detalles del reporte seleccionado.
  */
function ListaReportes({
  reports,
  loading,
  hasMore,
  onLoadMore,
  onOpenDrawer
}) {

  /* ---------------------------------------------------------------------- */
  /*                    1. Mensaje si no hay reportes                      */
  /* ---------------------------------------------------------------------- */
  if (!loading && reports.length === 0) {
    return (
      <Paper
        variant="outlined"
        sx={{
          p: 4,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: 2,
          mt: 3,
          backgroundColor: 'background.default',
          borderStyle: 'dashed'
        }}
      >
        <EmptyIcon sx={{ fontSize: 48, color: 'text.secondary' }} /> <Typography variant="h6" color="text.secondary">
          No se encontraron reportes </Typography> <Typography color="text.secondary" align="center">
          Prueba ajustar los filtros o revisa más tarde. </Typography> </Paper>
    );
  }

  /* ---------------------------------------------------------------------- */
  /*                      2. Renderizado principal                         */
  /* ---------------------------------------------------------------------- */
  return (
    <Stack spacing={2} sx={{ mt: 3 }}>
      {/* Mapeo de cada reporte a su componente resumen */}
      {reports.map((report, index) => (<ItemReporteResumen
        key={report.id}
        report={report}
        index={index}
        onOpenDrawer={onOpenDrawer}
      />
      ))}

      ```
      {/* Botón de carga adicional */}
      {hasMore && (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 2 }}>
          <Button
            variant="contained"
            onClick={onLoadMore}
            disabled={loading}
          >
            {loading ? <CircularProgress size={24} /> : 'Cargar Más Reportes'}
          </Button>
        </Box>
      )}

      {/* Mensaje final cuando ya no hay más reportes */}
      {!hasMore && !loading && reports.length > 0 && (
        <Typography
          variant="caption"
          color="text.secondary"
          align="center"
          sx={{ py: 2 }}
        >
          Fin de los reportes
        </Typography>
      )}
    </Stack>
  );
}

export default ListaReportes;
