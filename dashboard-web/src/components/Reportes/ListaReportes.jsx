/**
 * Componente: ListaReportes (Versión Mejorada)
 */
import React from 'react';
import { Box, Typography, Button, CircularProgress, Stack, Paper, Fade, Divider } from '@mui/material';
import { 
    FindInPage as EmptyIcon, 
    ExpandMore as ExpandIcon 
} from '@mui/icons-material';
import ItemReporteResumen from './ItemReporteResumen';

function ListaReportes({
  reports,
  loading,
  hasMore,
  onLoadMore,
  onOpenDrawer
}) {

  /* ---------------------------------------------------------------------- */
  /* 1. Mensaje si no hay reportes                       */
  /* ---------------------------------------------------------------------- */
  if (!loading && reports.length === 0) {
    return (
      <Fade in={true}>
        <Paper
            variant="outlined"
            sx={{
            p: 8,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            gap: 2,
            mt: 4,
            borderRadius: 3,
            backgroundColor: 'background.paper',
            borderStyle: 'dashed',
            borderColor: 'divider'
            }}
        >
            <Box sx={{ p: 2, bgcolor: 'action.hover', borderRadius: '50%', mb: 1 }}>
                <EmptyIcon sx={{ fontSize: 60, color: 'text.secondary' }} /> 
            </Box>
            <Typography variant="h5" color="text.primary" fontWeight="bold">
            No se encontraron reportes
            </Typography> 
            <Typography color="text.secondary" align="center" maxWidth="400px">
            No hay resultados que coincidan con tus filtros actuales. Intenta ajustar la búsqueda o los filtros de estado.
            </Typography> 
        </Paper>
      </Fade>
    );
  }

  /* ---------------------------------------------------------------------- */
  /* 2. Renderizado principal                          */
  /* ---------------------------------------------------------------------- */
  return (
    <Box sx={{ mt: 3, pb: 4 }}>
      <Stack spacing={2}>
        {/* Mapeo de reportes con animación de entrada */}
        {reports.map((report, index) => (
            <Fade in={true} timeout={300 + (index % 5) * 100} key={report.id || index}>
                <Box>
                    <ItemReporteResumen
                        report={report}
                        index={index}
                        onOpenDrawer={onOpenDrawer}
                    />
                </Box>
            </Fade>
        ))}
      </Stack>

      {/* Botón de carga adicional */}
      {hasMore && (
        <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}>
          <Button
            variant="outlined"
            size="large"
            onClick={onLoadMore}
            disabled={loading}
            fullWidth
            startIcon={!loading && <ExpandIcon />}
            sx={{ 
                maxWidth: '300px', 
                py: 1.5, 
                borderRadius: 2,
                textTransform: 'none',
                fontSize: '1rem',
                borderWidth: 2,
                '&:hover': { borderWidth: 2 }
            }}
          >
            {loading ? <CircularProgress size={24} color="inherit" /> : 'Cargar más reportes'}
          </Button>
        </Box>
      )}

      {/* Mensaje final (Footer elegante) */}
      {!hasMore && !loading && reports.length > 0 && (
        <Divider sx={{ mt: 4, mb: 2 }}>
            <Typography variant="caption" color="text.disabled" sx={{ textTransform: 'uppercase', letterSpacing: 1, px: 1 }}>
                Fin de los resultados
            </Typography>
        </Divider>
      )}
    </Box>
  );
}

export default ListaReportes;