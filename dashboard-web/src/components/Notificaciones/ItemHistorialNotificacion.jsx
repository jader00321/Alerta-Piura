/**

* Componente: ItemHistorialNotificacion
* ---
* Representa un elemento del historial de notificaciones enviadas.
* Muestra la información del receptor, título, mensaje, fecha de envío
* y permite reenviar o eliminar la notificación.
* Además, si existen notificaciones duplicadas (mismo título y cuerpo),
* muestra un Chip con el conteo de repeticiones.
  */

import React from 'react';
import {
  Box, Paper, Typography, Button, Divider,
  Stack, Avatar, Tooltip, Chip
} from '@mui/material';
import {
  Delete as DeleteIcon,
  Replay as ReplayIcon,
  Person as PersonIcon,
  CalendarToday as CalendarIcon,
  Title as TitleIcon,
  Message as MessageIcon,
  Repeat as RepeatIcon
} from '@mui/icons-material';

/**

* @param {Object} props
* @param {Object} props.notif - Objeto con los datos de la notificación.
* @param {string} props.notif.id - ID único de la notificación.
* @param {string} props.notif.receptor - Nombre o correo del destinatario.
* @param {string} props.notif.titulo - Título del mensaje.
* @param {string} props.notif.cuerpo - Contenido del mensaje.
* @param {string} props.notif.fecha_envio - Fecha y hora del envío.
* @param {Function} props.onResend - Callback para reenviar la notificación.
* @param {Function} props.onDelete - Callback para eliminar la notificación.
* @param {Object} [props.notificationCounts] - Mapa de conteos de notificaciones duplicadas.
  */
function ItemHistorialNotificacion({ notif, onResend, onDelete, notificationCounts }) {

  /**
  
  * Maneja la acción de reenviar una notificación.
  * Muestra una confirmación antes de ejecutar el callback.
    */
  const handleResend = () => {
    if (window.confirm(`¿Reenviar esta notificación a "${notif.receptor}"?`)) {
      onResend(notif);
    }
  };

  /**
  
  * Maneja la acción de eliminar una notificación del historial.
  * Solicita confirmación antes de ejecutar el callback.
    */
  const handleDelete = () => {
    if (window.confirm('¿Eliminar esta notificación del historial?')) {
      onDelete(notif.id);
    }
  };

  // --- Calcular cantidad de duplicados ---
  // Genera una clave basada en el título y cuerpo de la notificación.
  const duplicateKey = `${notif.titulo}|${notif.cuerpo}`;
  // Obtiene el número de notificaciones idénticas (mismo título y cuerpo).
  const duplicateCount = notificationCounts ? notificationCounts[duplicateKey] : 0;

  return (<Paper variant="outlined"> <Stack>

    ```
    {/* --- CABECERA: Destinatario y Fecha --- */}
    <Box
      sx={{
        p: 2,
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        bgcolor: 'background.default',
        flexWrap: 'wrap',
        gap: 1
      }}
    >
      {/* Información del destinatario */}
      <Stack direction="row" spacing={1.5} alignItems="center">
        <Avatar sx={{ bgcolor: 'primary.light', color: 'primary.dark', width: 32, height: 32 }}>
          <PersonIcon fontSize="small" />
        </Avatar>
        <Box>
          <Typography variant="body2" color="text.secondary">
            Destinatario:
          </Typography>
          <Typography sx={{ fontWeight: 'bold' }}>
            {notif.receptor}
          </Typography>
        </Box>
      </Stack>

      {/* --- Mostrar Chip de duplicados (si hay más de uno) y fecha --- */}
      <Stack direction="row" spacing={1} alignItems="center">
        {duplicateCount > 1 && (
          <Tooltip
            title={`Esta notificación (mismo título y cuerpo) aparece ${duplicateCount} veces en la vista actual.`}
          >
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
    </Box>

    <Divider />

    {/* --- CUERPO: Título y Mensaje --- */}
    <Box sx={{ p: 2.5 }}>
      <Stack spacing={1.5}>
        {/* Título */}
        <Box>
          <Typography
            variant="caption"
            color="text.secondary"
            sx={{ display: 'flex', alignItems: 'center', gap: 1 }}
          >
            <TitleIcon fontSize="small" /> Título
          </Typography>
          <Typography variant="h6" sx={{ fontWeight: 600, wordBreak: 'break-word' }}>
            {notif.titulo}
          </Typography>
        </Box>

        {/* Mensaje */}
        <Box>
          <Typography
            variant="caption"
            color="text.secondary"
            sx={{ display: 'flex', alignItems: 'center', gap: 1 }}
          >
            <MessageIcon fontSize="small" /> Mensaje
          </Typography>
          <Typography variant="body1" sx={{ wordBreak: 'break-word', color: 'text.secondary' }}>
            {notif.cuerpo}
          </Typography>
        </Box>
      </Stack>
    </Box>

    <Divider />

    {/* --- ACCIONES: Botones Reenviar y Eliminar --- */}
    <Box sx={{ p: 1.5, display: 'flex', justifyContent: 'flex-end', gap: 1 }}>
      {/* Botón para reenviar la notificación */}
      <Button
        color="primary"
        variant="outlined"
        size="small"
        startIcon={<ReplayIcon />}
        onClick={handleResend}
      >
        Reenviar
      </Button>

      {/* Botón para eliminar la notificación */}
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
