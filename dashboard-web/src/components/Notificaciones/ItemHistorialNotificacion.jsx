// src/components/Notificaciones/ItemHistorialNotificacion.jsx
import React from 'react';
import {
  Box, Paper, Typography, Button, Divider,
  Stack, Avatar, Tooltip, Chip // Chip added
} from '@mui/material';
import {
  Delete as DeleteIcon,
  Replay as ReplayIcon,
  Person as PersonIcon,
  CalendarToday as CalendarIcon,
  Title as TitleIcon,
  Message as MessageIcon,
  Repeat as RepeatIcon // Icon for duplicates
} from '@mui/icons-material';

// Receive notificationCounts map and calculate count for this specific item
function ItemHistorialNotificacion({ notif, onResend, onDelete, notificationCounts }) {

  const handleResend = () => {
    if (window.confirm(`¿Reenviar esta notificación a "${notif.receptor}"?`)) {
      onResend(notif);
    }
  };

  const handleDelete = () => {
    if (window.confirm('¿Eliminar esta notificación del historial?')) {
      onDelete(notif.id);
    }
  };

  // --- Calculate Duplicate Count ---
  const duplicateKey = `${notif.titulo}|${notif.cuerpo}`;
  const duplicateCount = notificationCounts ? notificationCounts[duplicateKey] : 0;
  // ---

  return (
    <Paper variant="outlined">
      <Stack>
        {/* --- Cabecera: Destinatario y Fecha --- */}
        <Box
          sx={{
            p: 2, display: 'flex', justifyContent: 'space-between',
            alignItems: 'center', bgcolor: 'background.default',
            flexWrap: 'wrap', gap: 1
          }}
        >
          {/* ... (User info remains the same) ... */}
           <Stack direction="row" spacing={1.5} alignItems="center">
            <Avatar sx={{ bgcolor: 'primary.light', color: 'primary.dark', width: 32, height: 32 }}>
              <PersonIcon fontSize="small" />
            </Avatar>
            <Box>
              <Typography variant="body2" color="text.secondary">Destinatario:</Typography>
              <Typography sx={{ fontWeight: 'bold' }}>
                {notif.receptor}
              </Typography>
            </Box>
          </Stack>

          {/* --- Show Duplicate Count Chip if > 1 --- */}
          <Stack direction="row" spacing={1} alignItems="center">
              {duplicateCount > 1 && (
                 <Tooltip title={`Esta notificación (mismo título y cuerpo) aparece ${duplicateCount} veces en la vista actual.`}>
                      <Chip
                          icon={<RepeatIcon />}
                          label={`x ${duplicateCount}`}
                          size="small"
                          color="info"
                          variant="outlined"
                          sx={{ mr: 1 }}
                      />
                 </Tooltip>
              )}
              <Stack direction="row" spacing={1} alignItems="center" color="text.secondary">
                  <CalendarIcon fontSize="small" />
                  <Typography variant="caption" noWrap>
                    {new Date(notif.fecha_envio).toLocaleString()}
                  </Typography>
              </Stack>
          </Stack>
          {/* --- End Duplicate Count --- */}
        </Box>

        <Divider />

        {/* --- Cuerpo: Título y Mensaje --- */}
        {/* ... (Body remains the same) ... */}
        <Box sx={{ p: 2.5 }}>
          <Stack spacing={1.5}>
            <Box>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <TitleIcon fontSize="small" /> Título
              </Typography>
              <Typography variant="h6" sx={{ fontWeight: 600, wordBreak: 'break-word' }}>
                {notif.titulo}
              </Typography>
            </Box>
            <Box>
              <Typography variant="caption" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                <MessageIcon fontSize="small" /> Mensaje
              </Typography>
              <Typography variant="body1" sx={{ wordBreak: 'break-word', color: 'text.secondary' }}>
                {notif.cuerpo}
              </Typography>
            </Box>
          </Stack>
        </Box>

        <Divider />

        {/* --- Acciones --- */}
        {/* ... (Actions remain the same) ... */}
         <Box sx={{ p: 1.5, display: 'flex', justifyContent: 'flex-end', gap: 1 }}>
          <Button
            color="primary"
            variant="outlined"
            size="small"
            startIcon={<ReplayIcon />}
            onClick={handleResend}
          >
            Reenviar
          </Button>
          <Button
            color="error"
            variant="outlined"
            size="small"
            startIcon={<DeleteIcon />}
            onClick={handleDelete}
          >
            Eliminar
          </Button>
        </Box>
      </Stack>
    </Paper>
  );
}

export default ItemHistorialNotificacion;