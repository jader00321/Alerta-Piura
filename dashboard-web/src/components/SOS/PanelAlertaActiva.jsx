// src/components/SOS/PanelAlertaActiva.jsx
import React, { useState, useEffect, useRef } from 'react';
import { Paper, Typography, Box, Chip, Stack, CircularProgress } from '@mui/material';
import { Warning as WarningIcon, NotificationsActive as BellIcon } from '@mui/icons-material';

function PanelAlertaActiva({ alerts }) { // Recibe todas las alertas
  ///const theme = useTheme();
  const [timer, setTimer] = useState(null);
  const intervalRef = useRef(null);

  // Derivar la última alerta activa y el conteo de activas/no revisadas
  const latestActiveAlert = alerts.find(a => a.estado === 'activo');
  const activeUnreviewedCount = alerts.filter(a => a.estado === 'activo' && !a.revisada).length;

  useEffect(() => {
    clearInterval(intervalRef.current); // Limpiar timer anterior
    setTimer(null); // Resetear

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
      update(); // Ejecuta una vez
      intervalRef.current = setInterval(update, 1000); // Actualiza cada segundo
    }

    return () => clearInterval(intervalRef.current); // Limpieza al desmontar o cambiar alerta
  }, [latestActiveAlert]); // Depende solo de si cambia la última alerta activa

  return (
    <Paper sx={{ p: 2, borderLeft: 5, borderColor: latestActiveAlert ? 'error.main' : 'grey.500', height:'100%' }} elevation={3}>
      <Typography variant="h6" sx={{ fontWeight: 'medium', mb: 1.5, display: 'flex', alignItems: 'center', gap: 1 }}>
        <WarningIcon color={latestActiveAlert ? 'error' : 'action'} /> Estado SOS Activo
      </Typography>

      {latestActiveAlert ? (
        <Stack spacing={1}>
          <Typography variant="body1">
            Última Alerta Activa: <strong>{latestActiveAlert.codigo_alerta}</strong>
          </Typography>
          <Typography variant="body2" color="text.secondary">
            Usuario: {latestActiveAlert.alias || latestActiveAlert.nombre}
          </Typography>
          {timer && (
              <Chip
                icon={<TimerIcon />}
                label={`Tiempo Restante: ${timer}`}
                color="error"
                size="medium"
                sx={{ fontWeight: 'bold', fontSize: '1rem', width: 'fit-content' }}
              />
          )}
           {activeUnreviewedCount > 0 && (
               <Chip
                 icon={<BellIcon/>}
                 label={`${activeUnreviewedCount} activa(s) no revisada(s)`}
                 color="warning"
                 size="small"
                 sx={{ width: 'fit-content', mt: 1 }}
               />
           )}
        </Stack>
      ) : (
        <Box sx={{ display: 'flex', flexDirection:'column', alignItems: 'center', justifyContent: 'center', height: '80%', textAlign:'center' }}>
          <BellIcon color="success" sx={{ fontSize: 40, mb: 1 }}/>
          <Typography color="text.secondary">No hay alertas SOS activas en este momento.</Typography>
        </Box>
      )}
    </Paper>
  );
}
// Importar TimerIcon si no está ya en la lista de imports
import { AccessAlarm as TimerIcon } from '@mui/icons-material';

export default PanelAlertaActiva;