// src/components/SOS/PanelAlertaActiva.jsx
import React, { useState, useEffect, useRef } from 'react';
import { Paper, Typography, Box, Chip, Stack, useTheme, alpha, keyframes } from '@mui/material';
import { WarningAmber as WarningIcon, NotificationsActive as BellIcon, Timer as TimerIcon } from '@mui/icons-material';

const pulse = keyframes`
  0% { transform: scale(1); opacity: 1; }
  50% { transform: scale(1.1); opacity: 0.7; }
  100% { transform: scale(1); opacity: 1; }
`;

function PanelAlertaActiva({ alerts }) {
  const theme = useTheme();
  const [timer, setTimer] = useState(null);
  const intervalRef = useRef(null);

  const latestActiveAlert = alerts.find(a => a.estado === 'activo');
  // Filtramos solo las que están activas Y no revisadas
  const activeUnreviewedCount = alerts.filter(a => a.estado === 'activo' && !a.revisada).length;

  useEffect(() => {
    clearInterval(intervalRef.current);
    setTimer(null);

    if (latestActiveAlert) {
      const startTime = new Date(latestActiveAlert.fecha_inicio).getTime();
      const duration = latestActiveAlert.duracion_segundos || 600;

      const update = () => {
        const remaining = duration - Math.floor((Date.now() - startTime) / 1000);
        if (remaining > 0) {
          const min = Math.floor(remaining / 60).toString().padStart(2, '0');
          const sec = (remaining % 60).toString().padStart(2, '0');
          setTimer(`${min}:${sec}`);
        } else {
          setTimer('00:00');
          clearInterval(intervalRef.current);
        }
      };
      update();
      intervalRef.current = setInterval(update, 1000);
    }
    return () => clearInterval(intervalRef.current);
  }, [latestActiveAlert]);

  return (
    <Paper 
      elevation={latestActiveAlert ? 3 : 0}
      sx={{ 
        p: 2, // Padding reducido
        height: '100%', 
        borderRadius: 2,
        border: `1px solid ${latestActiveAlert ? theme.palette.error.main : theme.palette.divider}`,
        bgcolor: latestActiveAlert ? alpha(theme.palette.error.main, 0.04) : 'background.paper',
        transition: 'all 0.3s ease'
      }}
    >
      <Stack spacing={1.5} height="100%">
        {/* Encabezado Compacto */}
        <Box display="flex" alignItems="center" gap={1.5}>
            <Box sx={{ 
                bgcolor: latestActiveAlert ? 'error.main' : 'action.disabled', 
                color: 'white', p: 0.5, borderRadius: 1.5, display: 'flex',
                animation: latestActiveAlert ? `${pulse} 2s infinite` : 'none'
            }}>
                <WarningIcon fontSize="small" />
            </Box>
            <Typography variant="subtitle1" fontWeight="bold" color={latestActiveAlert ? 'error.main' : 'text.secondary'}>
                {latestActiveAlert ? 'ALERTA EN CURSO' : 'Sin Emergencias'}
            </Typography>
        </Box>

        {latestActiveAlert ? (
            <Box sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
                <Typography variant="caption" color="text.secondary" fontWeight="bold">
                    CÓDIGO DE INCIDENTE
                </Typography>
                {/* Texto más compacto */}
                <Typography variant="h4" fontWeight="800" color="text.primary" sx={{ mb: 0.5, letterSpacing: -0.5 }}>
                    {latestActiveAlert.codigo_alerta}
                </Typography>
                <Typography variant="body2" sx={{ mb: 2 }}>
                    Usuario: <strong>{latestActiveAlert.alias || latestActiveAlert.nombre}</strong>
                </Typography>

                {timer && (
                    <Chip
                        icon={<TimerIcon style={{ fontSize: 20 }} />}
                        label={timer}
                        color="error"
                        size="medium"
                        sx={{ 
                            height: 36, // Altura reducida
                            borderRadius: 1.5, 
                            fontSize: '1.1rem', 
                            fontWeight: 'bold', 
                            width: '100%',
                            justifyContent: 'center'
                        }}
                    />
                )}

                {activeUnreviewedCount > 0 && (
                    <Box sx={{ mt: 1.5, p: 1, bgcolor: 'warning.light', color: 'warning.contrastText', borderRadius: 1, display: 'flex', alignItems: 'center', gap: 1, fontSize: '0.8rem' }}>
                        <BellIcon fontSize="small" />
                        <Typography variant="caption" fontWeight="bold">
                            {activeUnreviewedCount} pendiente(s) de revisión
                        </Typography>
                    </Box>
                )}
            </Box>
        ) : (
            <Box sx={{ flexGrow: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', opacity: 0.5 }}>
                <BellIcon sx={{ fontSize: 40, mb: 1, color: 'text.disabled' }} />
                <Typography variant="body2" fontWeight="medium">Monitoreo activo</Typography>
            </Box>
        )}
      </Stack>
    </Paper>
  );
}

export default PanelAlertaActiva;