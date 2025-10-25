// src/components/Usuarios/PanelSolicitudesRol.jsx
import React, { useState, useEffect } from 'react';
import { 
  Box, 
  Typography, 
  Button, 
  Paper, 
  CircularProgress, 
  Alert,
  Stack,
  Grid,
  Avatar,
  Divider,
  useTheme
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';
import MapIcon from '@mui/icons-material/Map';
import NotesIcon from '@mui/icons-material/Notes';
import EmailIcon from '@mui/icons-material/Email';
import CalendarTodayIcon from '@mui/icons-material/CalendarToday';
import DoneAllIcon from '@mui/icons-material/DoneAll';

import adminService from '../../services/adminService'; // Asegúrate que la ruta sea correcta

// --- Componente InfoRow (Sin cambios) ---
const InfoRow = ({ icon, label, value }) => (
  <Box sx={{ display: 'flex', gap: 1.5, alignItems: 'flex-start' }}>
    {React.cloneElement(icon, { color: 'action', fontSize: 'small' })}
    <Box>
      <Typography variant="caption" color="text.secondary" sx={{ textTransform: 'uppercase', letterSpacing: '0.5px' }}>
        {label}
      </Typography>
      <Typography variant="body2" sx={{ wordBreak: 'break-word', fontWeight: 500 }}>
        {value || 'N/A'}
      </Typography>
    </Box>
  </Box>
);

// --- COMPONENTE RENOMBRADO ---
function PanelSolicitudesRol() {
  const [solicitudes, setSolicitudes] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isResolving, setIsResolving] = useState(null);
  const theme = useTheme();

  const fetchSolicitudes = () => {
    setIsLoading(true);
    setError(null);
    adminService.getSolicitudesRol()
      .then(setSolicitudes)
      .catch(err => {
        console.error("Error al cargar solicitudes:", err);
        setError(err.response?.data?.message || 'Error al cargar solicitudes');
      })
      .finally(() => setIsLoading(false));
  };

  useEffect(() => {
    fetchSolicitudes();
  }, []);

  const handleResolver = (id, accion) => {
    setIsResolving(id);
    adminService.resolverSolicitudRol(id, accion)
      .then(() => {
        fetchSolicitudes(); // Refrescar la lista
      })
      .catch(err => {
         alert(err.response?.data?.message || 'Error al resolver.');
         setIsResolving(null);
      });
  };

  if (isLoading && !isResolving) {
    return <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}><CircularProgress /></Box>;
  }

  if (error) {
    return <Alert severity="error" sx={{ m: 2 }}>{error}</Alert>;
  }

  // Estado vacío (Sin cambios)
  if (solicitudes.length === 0) {
    return (
      <Paper 
        variant="outlined" 
        sx={{ p: 4, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 2, backgroundColor: 'background.default', borderStyle: 'dashed' }}
      >
        <DoneAllIcon sx={{ fontSize: 48, color: 'text.secondary' }} />
        <Typography variant="h6" color="text.secondary">
          ¡Todo listo!
        </Typography>
        <Typography color="text.secondary">
          No hay solicitudes de rol pendientes por revisar.
        </Typography>
      </Paper>
    );
  }

  // Layout de Tarjetas (Sin cambios)
  return (
    <Stack spacing={2}>
      {solicitudes.map((sol) => (
        <Paper key={sol.id} variant="outlined" sx={{ p: 2, opacity: isResolving === sol.id ? 0.6 : 1 }}>
          <Grid container spacing={2}>
            
            {/* Sección de Información (Izquierda) */}
            <Grid item xs={12} md={8}>
              <Box sx={{ display: 'flex', alignItems: 'center', gap: 2, mb: 2 }}>
                <Avatar sx={{ bgcolor: 'primary.main' }}>
                  {sol.nombre ? sol.nombre[0].toUpperCase() : (sol.alias ? sol.alias[0].toUpperCase() : '?')}
                </Avatar>
                <Box>
                  <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
                    {sol.alias || sol.nombre}
                  </Typography>
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <EmailIcon fontSize="small" color="action" />
                    <Typography variant="body2" color="text.secondary">
                      {sol.email}
                    </Typography>
                  </Box>
                </Box>
              </Box>
              <Divider sx={{ mb: 2 }} />
              <Stack spacing={2}>
                <InfoRow 
                  icon={<MapIcon />}
                  label="Zona Propuesta"
                  value={sol.zona_propuesta}
                />
                <InfoRow 
                  icon={<NotesIcon />}
                  label="Motivación"
                  value={sol.motivacion}
                />
                <InfoRow 
                  icon={<CalendarTodayIcon />}
                  label="Fecha de Solicitud"
                  value={sol.fecha}
                />
              </Stack>
            </Grid>
            
            {/* Sección de Acciones (Derecha) */}
            <Grid item xs={12} md={4}>
              <Stack 
                spacing={1.5} 
                sx={{ 
                  height: '100%', 
                  justifyContent: 'center', 
                  alignItems: 'center',
                  [theme.breakpoints.up('md')]: {
                     borderLeft: `1px solid ${theme.palette.divider}`,
                     pl: 2
                  },
                  [theme.breakpoints.down('md')]: {
                     borderTop: `1px solid ${theme.palette.divider}`,
                     pt: 2,
                     flexDirection: 'row'
                  }
                }}
              >
                <Button 
                  color="success" 
                  variant="contained" 
                  startIcon={<CheckCircleIcon />}
                  onClick={() => handleResolver(sol.id, 'aprobar')}
                  disabled={isResolving === sol.id}
                  fullWidth
                >
                  Aprobar
                </Button>
                <Button 
                  color="error" 
                  variant="outlined" 
                  startIcon={<CancelIcon />}
                  onClick={() => handleResolver(sol.id, 'rechazar')}
                  disabled={isResolving === sol.id}
                  fullWidth
                >
                  Rechazar
                </Button>
              </Stack>
            </Grid>

          </Grid>
        </Paper>
      ))}
    </Stack>
  );
}

export default PanelSolicitudesRol;