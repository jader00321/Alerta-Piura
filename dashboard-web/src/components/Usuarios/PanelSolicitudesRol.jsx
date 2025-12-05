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
  useTheme,
  Chip,
  Fade
} from '@mui/material';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import CancelIcon from '@mui/icons-material/Cancel';
import MapIcon from '@mui/icons-material/Map';
import NotesIcon from '@mui/icons-material/Notes';
import EmailIcon from '@mui/icons-material/Email';
import CalendarTodayIcon from '@mui/icons-material/CalendarToday';
import DoneAllIcon from '@mui/icons-material/DoneAll';
import PersonIcon from '@mui/icons-material/Person';

import adminService from '../../services/adminService';

const InfoRow = ({ icon, label, value }) => (
  <Box sx={{ display: 'flex', gap: 1.5, alignItems: 'flex-start' }}>
    <Avatar sx={{ bgcolor: 'action.hover', width: 32, height: 32, color: 'text.secondary' }}>
       {React.cloneElement(icon, { fontSize: 'small' })}
    </Avatar>
    <Box>
      <Typography variant="caption" color="text.secondary" sx={{ textTransform: 'uppercase', letterSpacing: '0.5px', fontWeight: 600 }}>
        {label}
      </Typography>
      <Typography variant="body2" sx={{ wordBreak: 'break-word', fontWeight: 500, color: 'text.primary' }}>
        {value || 'N/A'}
      </Typography>
    </Box>
  </Box>
);

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
        fetchSolicitudes();
      })
      .catch(err => {
         alert(err.response?.data?.message || 'Error al resolver.');
         setIsResolving(null);
      });
  };

  if (isLoading && !isResolving) {
    return <Box sx={{ display: 'flex', justifyContent: 'center', p: 8 }}><CircularProgress /></Box>;
  }

  if (error) {
    return <Alert severity="error" sx={{ m: 2, borderRadius: 2 }}>{error}</Alert>;
  }

  if (solicitudes.length === 0) {
    return (
      <Paper 
        variant="outlined" 
        sx={{ 
          p: 6, 
          display: 'flex', 
          flexDirection: 'column', 
          alignItems: 'center', 
          gap: 2, 
          bgcolor: 'background.paper', 
          borderStyle: 'dashed',
          borderRadius: 3
        }}
      >
        <Avatar sx={{ bgcolor: 'action.hover', width: 80, height: 80, mb: 1 }}>
           <DoneAllIcon sx={{ fontSize: 40, color: 'success.main' }} />
        </Avatar>
        <Typography variant="h6" color="text.primary" fontWeight="bold">
          ¡Todo al día!
        </Typography>
        <Typography color="text.secondary" align="center">
          No hay solicitudes de rol pendientes por revisar en este momento.
        </Typography>
      </Paper>
    );
  }

  return (
    <Stack spacing={3}>
      {solicitudes.map((sol, index) => (
        <Fade in={true} key={sol.id} style={{ transitionDelay: `${index * 100}ms` }}>
        <Paper 
          elevation={0}
          variant="outlined"
          sx={{ 
            p: 0, 
            overflow: 'hidden',
            borderRadius: 3,
            border: `1px solid ${theme.palette.divider}`,
            opacity: isResolving === sol.id ? 0.6 : 1,
            pointerEvents: isResolving === sol.id ? 'none' : 'auto',
            transition: 'all 0.3s ease',
            '&:hover': {
                borderColor: theme.palette.primary.main,
                boxShadow: theme.shadows[4]
            }
          }}
        >
          <Grid container>
            
            {/* IZQUIERDA: Información del Usuario */}
            <Grid item xs={12} md={8} sx={{ p: 3 }}>
              <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2.5, mb: 3 }}>
                <Avatar 
                  sx={{ 
                    bgcolor: 'primary.main', 
                    width: 56, height: 56,
                    fontSize: '1.5rem',
                    boxShadow: 2
                  }}
                >
                  {sol.nombre ? sol.nombre[0].toUpperCase() : (sol.alias ? sol.alias[0].toUpperCase() : '?')}
                </Avatar>
                <Box>
                  <Typography variant="h6" sx={{ fontWeight: 800, lineHeight: 1.2 }}>
                    {sol.nombre || 'Usuario Desconocido'}
                  </Typography>
                  <Typography variant="body2" color="text.secondary" sx={{ mb: 0.5 }}>
                     {sol.alias ? `@${sol.alias}` : 'Sin alias'}
                  </Typography>
                  <Chip 
                    icon={<EmailIcon fontSize="small"/>} 
                    label={sol.email} 
                    size="small" 
                    variant="outlined" 
                    sx={{ borderRadius: 1 }}
                  />
                </Box>
              </Box>

              <Grid container spacing={3}>
                <Grid item xs={12} sm={6}>
                   <InfoRow icon={<MapIcon />} label="Zona Solicitada" value={sol.zona_propuesta} />
                </Grid>
                <Grid item xs={12} sm={6}>
                   <InfoRow icon={<CalendarTodayIcon />} label="Fecha Solicitud" value={sol.fecha} />
                </Grid>
                <Grid item xs={12}>
                   <Box sx={{ bgcolor: 'action.hover', p: 2, borderRadius: 2, mt: 1 }}>
                      <Stack direction="row" spacing={1} mb={1}>
                         <NotesIcon fontSize="small" color="action"/>
                         <Typography variant="caption" fontWeight="bold" color="text.secondary">MOTIVACIÓN</Typography>
                      </Stack>
                      <Typography variant="body2" sx={{ fontStyle: 'italic', color: 'text.primary' }}>
                         "{sol.motivacion}"
                      </Typography>
                   </Box>
                </Grid>
              </Grid>
            </Grid>
            
            {/* DERECHA: Acciones */}
            <Grid item xs={12} md={4} 
               sx={{ 
                 bgcolor: 'background.default', 
                 borderLeft: { md: `1px solid ${theme.palette.divider}` },
                 borderTop: { xs: `1px solid ${theme.palette.divider}`, md: 'none' },
                 p: 3,
                 display: 'flex',
                 flexDirection: 'column',
                 justifyContent: 'center',
                 gap: 2
               }}
            >
              <Typography variant="caption" color="text.secondary" align="center" display="block" fontWeight="bold">
                 ACCIONES DE MODERACIÓN
              </Typography>
              
              <Button 
                variant="contained" 
                color="success" 
                size="large"
                startIcon={isResolving === sol.id ? <CircularProgress size={20} color="inherit"/> : <CheckCircleIcon />}
                onClick={() => handleResolver(sol.id, 'aprobar')}
                fullWidth
                sx={{ boxShadow: 2, fontWeight: 'bold' }}
              >
                Aprobar Solicitud
              </Button>

              <Button 
                variant="outlined" 
                color="error" 
                size="large"
                startIcon={<CancelIcon />}
                onClick={() => handleResolver(sol.id, 'rechazar')}
                fullWidth
                sx={{ borderWidth: 2, '&:hover': { borderWidth: 2 } }}
              >
                Rechazar
              </Button>
            </Grid>

          </Grid>
        </Paper>
        </Fade>
      ))}
    </Stack>
  );
}

export default PanelSolicitudesRol;