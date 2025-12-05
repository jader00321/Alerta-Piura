import React from 'react';
import { 
  Paper, Typography, Box, Stack, Divider, Avatar, Chip, Button, Grid, useTheme, IconButton, Tooltip 
} from '@mui/material';
import {
    Person as PersonIcon, 
    PhoneForwarded as PhoneIcon,
    CalendarToday as CalendarIcon, 
    Message as MessageIcon,
    LocationOn as LocationIcon, 
    Phone as PhoneUserIcon,
    Email as EmailIcon, 
    Map as MapIcon,
    Delete as DeleteIcon // <-- Importar icono
} from '@mui/icons-material';

/**
 * Renderiza un registro individual del historial de SMS.
 * Ahora incluye botón de eliminar.
 */
function ItemSmsLog({ log, onDelete }) { // <-- Recibe prop onDelete
  const theme = useTheme();
  
  const fecha = new Date(log.fecha_envio).toLocaleString('es-ES', {
    day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit'
  });

  const usuarioAlias = log.usuario_sos_alias || 'Usuario Desconocido';
  const usuarioRol = log.usuario_sos_rol || 'ciudadano';
  const usuarioEmail = log.usuario_sos_email || 'Sin email';
  const usuarioTel = log.telefono_usuario_sos || 'Sin teléfono';

  const contactoNombre = log.contacto_nombre || 'Contacto de Emergencia';
  const contactoTel = log.contacto_telefono || '---';

  return (
    <Paper variant="outlined" sx={{ p: 2, borderLeft: `4px solid ${theme.palette.primary.main}`, position: 'relative' }}>
      
      {/* Botón de Eliminar (Posicionado absoluto o en grid) */}
      <Box sx={{ position: 'absolute', top: 8, right: 8 }}>
          <Tooltip title="Eliminar registro">
              <IconButton size="small" onClick={() => onDelete(log.id)} sx={{ color: 'text.disabled', '&:hover': { color: 'error.main' } }}>
                  <DeleteIcon fontSize="small" />
              </IconButton>
          </Tooltip>
      </Box>

      <Grid container spacing={2}>
        
        {/* --- COLUMNA IZQUIERDA: REMITENTE --- */}
        <Grid item xs={12} md={4}>
          <Stack spacing={1}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
              <Avatar sx={{ bgcolor: theme.palette.primary.light }}>
                {usuarioAlias[0].toUpperCase()}
              </Avatar>
              <Box>
                <Typography variant="subtitle2" fontWeight="bold">
                  {usuarioAlias}
                </Typography>
                <Chip 
                  label={usuarioRol.toUpperCase()} 
                  size="small" 
                  sx={{ height: 20, fontSize: '0.65rem', fontWeight: 'bold' }} 
                  color={usuarioRol === 'admin' ? 'secondary' : 'default'}
                />
              </Box>
            </Box>
            
            <Box sx={{ pl: 1, borderLeft: '2px solid #eee' }}>
              <Stack direction="row" spacing={1} alignItems="center" sx={{ mb: 0.5 }}>
                <EmailIcon fontSize="small" color="action" sx={{ fontSize: 16 }} />
                <Typography variant="caption" color="text.secondary">{usuarioEmail}</Typography>
              </Stack>
              <Stack direction="row" spacing={1} alignItems="center">
                <PhoneUserIcon fontSize="small" color="action" sx={{ fontSize: 16 }} />
                <Typography variant="caption" color="text.secondary">{usuarioTel}</Typography>
              </Stack>
            </Box>
          </Stack>
        </Grid>

        {/* --- COLUMNA DERECHA: CONTENIDO --- */}
        <Grid item xs={12} md={8}>
          <Paper elevation={0} sx={{ bgcolor: theme.palette.action.hover, p: 2, borderRadius: 2, mt: { xs: 2, md: 0 } }}>
            
            <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 1.5, flexWrap: 'wrap', gap: 1, pr: 4 }}>
              <Stack direction="row" spacing={1} alignItems="center">
                <PhoneIcon fontSize="small" color="primary" />
                <Typography variant="body2" fontWeight="bold">
                   Enviado a: {contactoNombre} ({contactoTel})
                </Typography>
              </Stack>
              <Stack direction="row" spacing={0.5} alignItems="center">
                <CalendarIcon fontSize="small" color="action" sx={{ fontSize: 16 }} />
                <Typography variant="caption" color="text.secondary">{fecha}</Typography>
              </Stack>
            </Box>
            
            <Divider sx={{ mb: 1.5 }} />

            <Stack spacing={1.5}>
              <Box>
                <Stack direction="row" spacing={1} alignItems="start">
                  <MessageIcon fontSize="small" sx={{ mt: 0.3, color: 'text.secondary' }} />
                  <Box>
                    <Typography variant="caption" color="text.secondary" display="block">MENSAJE:</Typography>
                    <Typography variant="body1" sx={{ fontStyle: 'italic', fontWeight: 500 }}>
                      "{log.mensaje}"
                    </Typography>
                  </Box>
                </Stack>
              </Box>

              {log.ubicacion_url && (
                <Box>
                   <Stack direction="row" spacing={1} alignItems="center">
                      <LocationIcon fontSize="small" sx={{ color: 'text.secondary' }} />
                      <Typography variant="caption" color="text.secondary">UBICACIÓN ADJUNTA:</Typography>
                   </Stack>
                   <Box sx={{ mt: 1, ml: 3.5 }}>
                     <Button 
                        variant="outlined" 
                        size="small" 
                        startIcon={<MapIcon />}
                        href={log.ubicacion_url}
                        target="_blank"
                        rel="noopener noreferrer"
                        sx={{ textTransform: 'none', borderColor: theme.palette.divider }}
                     >
                        Ver ubicación en Google Maps
                     </Button>
                   </Box>
                </Box>
              )}
            </Stack>
          </Paper>
        </Grid>
      </Grid>
    </Paper>
  );
}

export default ItemSmsLog;