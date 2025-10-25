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

/**
 * Componente helper para mostrar una fila de información con ícono, etiqueta y valor.
 *
 * @param {object} props - Propiedades del componente.
 * @param {JSX.Element} props.icon - El elemento de ícono (ej: <MapIcon />).
 * @param {string} props.label - El texto de la etiqueta (ej: "Zona Propuesta").
 * @param {string|number|null} props.value - El valor a mostrar.
 * @returns {JSX.Element} Un componente Box con la información formateada.
 */
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

/**
 * Renderiza un panel que gestiona las solicitudes pendientes para nuevos roles (ej. Líder Vecinal).
 *
 * Este componente es autónomo y maneja su propio estado:
 * 1. Carga las solicitudes pendientes desde `adminService.getSolicitudesRol` al montarse.
 * 2. Muestra un estado de carga (`isLoading`), error (`error`) o un estado vacío
 * (si no hay solicitudes).
 * 3. Renderiza una tarjeta (Paper) por cada solicitud, mostrando detalles
 * del usuario, zona propuesta y motivación.
 * 4. Proporciona botones "Aprobar" y "Rechazar" que llaman a
 * `adminService.resolverSolicitudRol`.
 * 5. Muestra un indicador de carga (`isResolving`) en la tarjeta específica que
 * se está resolviendo, reduciendo su opacidad.
 *
 * No recibe props.
 *
 * @returns {JSX.Element} El panel de solicitudes de rol.
 */
function PanelSolicitudesRol() {
  const [solicitudes, setSolicitudes] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isResolving, setIsResolving] = useState(null); // Almacena el ID de la solicitud en proceso
  const theme = useTheme();

  /**
   * Carga la lista de solicitudes de rol desde el servicio.
   * Maneja los estados de carga y error.
   */
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

  // Carga inicial al montar el componente
  useEffect(() => {
    fetchSolicitudes();
  }, []);

  /**
   * Maneja la acción de aprobar o rechazar una solicitud.
   * Llama al servicio y, si tiene éxito, refresca la lista de solicitudes.
   * @param {string|number} id - El ID de la solicitud a resolver.
   * @param {'aprobar' | 'rechazar'} accion - La acción a tomar.
   */
  const handleResolver = (id, accion) => {
    setIsResolving(id); // Bloquea la tarjeta específica
    adminService.resolverSolicitudRol(id, accion)
      .then(() => {
        fetchSolicitudes(); // Refrescar la lista (esto pondrá isLoading a true)
      })
      .catch(err => {
         // Si falla, desbloquea la tarjeta y muestra alerta
         alert(err.response?.data?.message || 'Error al resolver.');
         setIsResolving(null);
      });
  };

  // --- Renderizado de Estados ---

  // 1. Carga Inicial (distinto de "resolviendo")
  if (isLoading && !isResolving) {
    return <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}><CircularProgress /></Box>;
  }

  // 2. Estado de Error
  if (error) {
    return <Alert severity="error" sx={{ m: 2 }}>{error}</Alert>;
  }

  // 3. Estado Vacío
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

  // 4. Lista de Solicitudes
  return (
    <Stack spacing={2}>
      {solicitudes.map((sol) => (
        <Paper 
          key={sol.id} 
          variant="outlined" 
          sx={{ 
            p: 2, 
            // Reduce opacidad si ESTA tarjeta se está resolviendo
            opacity: isResolving === sol.id ? 0.6 : 1,
            transition: 'opacity 0.3s'
          }}
        >
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
                  value={sol.fecha} // Asumiendo que 'fecha' ya viene formateada
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
                  // Estilos responsivos para la división
                  [theme.breakpoints.up('md')]: {
                      borderLeft: `1px solid ${theme.palette.divider}`,
                      pl: 2
                  },
                  [theme.breakpoints.down('md')]: {
                      borderTop: `1px solid ${theme.palette.divider}`,
                      pt: 2,
                      flexDirection: 'row' // Botones uno al lado del otro en móvil
                  }
                }}
              >
                <Button 
                  color="success" 
                  variant="contained" 
                  startIcon={<CheckCircleIcon />}
                  onClick={() => handleResolver(sol.id, 'aprobar')}
                  disabled={isResolving === sol.id} // Deshabilitar si se está resolviendo
                  fullWidth
                >
                  Aprobar
                </Button>
                <Button 
                  color="error" 
                  variant="outlined" 
                  startIcon={<CancelIcon />}
                  onClick={() => handleResolver(sol.id, 'rechazar')}
                  disabled={isResolving === sol.id} // Deshabilitar si se está resolviendo
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