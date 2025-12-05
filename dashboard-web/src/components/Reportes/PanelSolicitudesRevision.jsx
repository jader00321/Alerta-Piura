// src/components/Reportes/PanelSolicitudesRevision.jsx
import React from 'react';
import { 
  Box, Typography, Grid, Paper, Button, Avatar, Chip, Stack, useTheme, alpha, Fade
} from '@mui/material';
import { 
  CheckCircleOutline as ApproveIcon, 
  HighlightOff as DisapproveIcon, 
  FormatQuote as QuoteIcon,
  CalendarToday as CalendarIcon,
  Tag as TagIcon
} from '@mui/icons-material';

/**
 * SolicitudCard - Diseño Ampliado y Legible
 */
const SolicitudCard = ({ req, onResolve }) => {
  const theme = useTheme();
  const leaderName = req.lider_alias || req.lider_nombre || 'Líder';
  const initial = leaderName.charAt(0).toUpperCase();

  return (
    <Paper 
      elevation={0} 
      variant="outlined"
      sx={{ 
        height: '100%', 
        display: 'flex', 
        flexDirection: 'column', 
        position: 'relative',
        borderRadius: 4, // Bordes más redondeados
        bgcolor: 'background.paper',
        borderLeft: `8px solid ${theme.palette.warning.main}`, // Borde lateral más grueso
        transition: 'all 0.2s ease-in-out',
        '&:hover': {
          transform: 'translateY(-4px)',
          boxShadow: theme.shadows[6],
          borderColor: theme.palette.divider 
        }
      }}
    >
      {/* Contenido Principal con más Padding */}
      <Box sx={{ p: 3, flexGrow: 1 }}>
        
        {/* 1. Encabezado: Usuario y Fecha (Más grande) */}
        <Stack direction="row" justifyContent="space-between" alignItems="flex-start" mb={3}>
            <Stack direction="row" spacing={2} alignItems="center">
                <Avatar 
                    sx={{ 
                        width: 48, height: 48, // Avatar más grande
                        bgcolor: alpha(theme.palette.warning.main, 0.1), 
                        color: theme.palette.warning.dark,
                        fontWeight: 'bold',
                        fontSize: '1.2rem'
                    }}
                >
                    {initial}
                </Avatar>
                <Box>
                    <Typography variant="subtitle1" fontWeight="bold" lineHeight={1.2} sx={{ fontSize: '1.1rem' }}>
                        {leaderName}
                    </Typography>
                    <Typography variant="body2" color="text.secondary">
                        Solicitante
                    </Typography>
                </Box>
            </Stack>
            
            <Chip 
                icon={<CalendarIcon style={{ fontSize: 16 }} />} 
                label={req.fecha_reporte} 
                size="medium" // Chip tamaño normal
                variant="outlined"
                sx={{ borderRadius: 2, borderColor: 'divider', color: 'text.secondary', fontWeight: 500 }} 
            />
        </Stack>

        {/* 2. Datos del Reporte */}
        <Box mb={3}>
            <Chip 
                icon={<TagIcon style={{ fontSize: 16 }} />} 
                label={req.codigo_reporte} 
                sx={{ mb: 1.5, fontWeight: 'bold', bgcolor: 'action.hover', fontSize: '0.85rem' }} 
            />
            <Typography variant="h5" sx={{ fontWeight: 800, lineHeight: 1.3, mb: 1 }}>
                {req.titulo}
            </Typography>
        </Box>

        {/* 3. Motivo (Más espacio y letra más grande) */}
        {req.motivo ? (
          <Box sx={{ 
            bgcolor: alpha(theme.palette.warning.main, 0.05), 
            p: 2.5, // Más relleno interno
            borderRadius: 3, 
            position: 'relative',
            border: `1px dashed ${alpha(theme.palette.warning.main, 0.4)}`,
            mt: 2
          }}>
            <QuoteIcon sx={{ position: 'absolute', top: -12, left: 12, color: theme.palette.warning.main, bgcolor: 'background.paper', fontSize: 24, borderRadius: '50%' }} />
            <Typography variant="body1" sx={{ fontStyle: 'italic', color: 'text.primary', fontSize: '1rem', lineHeight: 1.6 }}>
              "{req.motivo}"
            </Typography>
          </Box>
        ) : (
          <Typography variant="body1" color="text.disabled" fontStyle="italic" sx={{ p: 2 }}>
            Sin motivo especificado.
          </Typography>
        )}
      </Box>

      {/* 4. Botones de Acción (Grandes y claros) */}
      <Box sx={{ p: 3, pt: 0, mt: 'auto' }}>
        <Stack direction="row" spacing={2}>
            <Button 
                fullWidth 
                variant="outlined" 
                color="inherit" 
                size="medium" // Botón tamaño normal
                startIcon={<DisapproveIcon />}
                onClick={() => onResolve(req.id, 'desestimar')}
                sx={{ 
                    borderRadius: 2, 
                    py: 1.2,
                    textTransform: 'none', 
                    color: 'text.secondary',
                    borderColor: theme.palette.divider,
                    fontSize: '0.95rem'
                }}
            >
                Descartar
            </Button>
            <Button 
                fullWidth 
                variant="contained" 
                color="warning" 
                size="medium" // Botón tamaño normal
                startIcon={<ApproveIcon />}
                onClick={() => onResolve(req.id, 'aprobar')}
                sx={{ 
                    borderRadius: 2, 
                    py: 1.2,
                    textTransform: 'none', 
                    color: 'white', 
                    fontWeight: 'bold', 
                    boxShadow: 3,
                    fontSize: '0.95rem'
                }}
            >
                Revisar
            </Button>
        </Stack>
      </Box>
    </Paper>
  );
};

/**
 * Componente Principal
 */
function PanelSolicitudesRevision({ reviewRequests, onResolveRequest }) {
  // Si no hay datos, no renderizamos nada (el padre maneja el estado vacío)
  if (!reviewRequests || reviewRequests.length === 0) return null;

  return (
    <Box sx={{ py: 3 }}> 
      <Grid container spacing={3}>
        {reviewRequests.map((req, index) => (
          // GRID FIX: Tarjetas más anchas en pantallas grandes
          <Grid item key={req.id} xs={12} md={6} lg={4}> 
            <Fade in={true} timeout={300 + (index * 100)}>
                <Box height="100%">
                    <SolicitudCard req={req} onResolve={onResolveRequest} />
                </Box>
            </Fade>
          </Grid>
        ))}
      </Grid>
    </Box>
  );
}

export default PanelSolicitudesRevision;