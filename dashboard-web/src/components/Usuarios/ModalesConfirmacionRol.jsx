// src/components/Usuarios/DrawerDetalleUsuario.jsx
import React, { useState } from 'react';
import {
  Drawer, Box, Typography, Divider, CircularProgress, Button, Avatar,
  Stack, FormControl, InputLabel, Select, MenuItem, Tooltip, List,
  ListItem, ListItemText, Chip, Tabs, Tab, Paper, Grid,
} from '@mui/material';
import { 
  Person as PersonIcon, Email as EmailIcon, CalendarToday as CalendarTodayIcon, 
  Phone as PhoneIcon, Star as StarIcon, Close as CloseIcon, 
  Security as SecurityIcon, BarChart as BarChartIcon,
  Block as BlockIcon,
  CheckCircle as CheckCircleIcon,
  Notifications as NotificationsIcon,
  Map as MapIcon
} from '@mui/icons-material';
// --- IMPORT ACTUALIZADO ---
import BotonConfirmacionMantenida from '../Comunes/BotonConfirmacionMantenida';

/**
 * TabPanel - Componente para contener el contenido de cada pestaña
 * @param {Object} props - Propiedades del componente
 * @param {ReactNode} props.children - Contenido del panel
 * @param {number} props.value - Valor actual de la pestaña
 * @param {number} props.index - Índice de este panel
 * @returns {JSX.Element}
 */
function TabPanel(props) {
  const { children, value, index, ...other } = props;
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`user-detail-tabpanel-${index}`}
      aria-labelledby={`user-detail-tab-${index}`}
      {...other}
    >
      {value === index && <Box sx={{ p: 2, pt: 3, bgcolor: 'background.default', height: '100%' }}>{children}</Box>}
    </div>
  );
}

/**
 * InfoItem - Componente reutilizable para mostrar información con icono
 * @param {Object} props - Propiedades del componente
 * @param {ReactNode} props.icon - Icono a mostrar
 * @param {string} props.label - Etiqueta del campo
 * @param {string} props.value - Valor del campo
 * @returns {JSX.Element}
 */
const InfoItem = ({ icon, label, value }) => (
  <Box sx={{ display: 'flex', alignItems: 'flex-start', gap: 2, mb: 2.5 }}>
    {React.cloneElement(icon, { color: 'action', sx: { mt: 0.5 } })}
    <Box>
      <Typography 
        variant="caption" 
        color="text.secondary" 
        sx={{ textTransform: 'uppercase', letterSpacing: '0.5px' }}
      >
        {label}
      </Typography>
      <Typography variant="body1" sx={{ wordBreak: 'break-all', fontWeight: 500 }}>
        {value || 'No disponible'}
      </Typography>
    </Box>
  </Box>
);

/**
 * DrawerDetalleUsuario - Componente de drawer para mostrar detalles completos de un usuario
 * @param {Object} props - Propiedades del componente
 * @param {boolean} props.open - Estado de apertura del drawer
 * @param {function} props.onClose - Callback cuando se cierra el drawer
 * @param {Object} props.selectedUser - Usuario seleccionado para mostrar
 * @param {Object} props.userDetails - Detalles adicionales del usuario
 * @param {boolean} props.detailLoading - Estado de carga de detalles
 * @param {function} props.onRoleChange - Callback para cambiar el rol del usuario
 * @param {function} props.onStatusChange - Callback para cambiar estado (suspender/reactivar)
 * @param {function} props.onSendNotification - Callback para enviar notificación
 * @param {function} props.onAssignZone - Callback para asignar zonas a líderes
 * @returns {JSX.Element}
 */
function DrawerDetalleUsuario({ 
  open, 
  onClose, 
  selectedUser, 
  userDetails, 
  detailLoading, 
  onRoleChange,
  // Props para acciones
  onStatusChange,
  onSendNotification,
  onAssignZone
}) {
  const [tabIndex, setTabIndex] = useState(0);

  /**
   * Maneja el cambio de pestaña
   * @param {Object} event - Evento del cambio
   * @param {number} newValue - Nuevo índice de pestaña
   */
  const handleTabChange = (event, newValue) => {
    setTabIndex(newValue);
  };

  /**
   * Maneja el cierre del drawer
   */
  const handleClose = () => {
    setTabIndex(0); 
    onClose();
  };
  
  if (!selectedUser) return null;

  // Props para el botón de Suspender/Reactivar
  const statusButtonProps = selectedUser.status === 'activo' ?
    { 
      onConfirm: () => onStatusChange(selectedUser.id, selectedUser.status), 
      label: "Suspender Usuario", 
      color: "error", 
      startIcon: <BlockIcon />
    } : { 
      onConfirm: () => onStatusChange(selectedUser.id, selectedUser.status), 
      label: "Reactivar Usuario", 
      color: "success", 
      startIcon: <CheckCircleIcon />
    };

  return (
    <Drawer anchor="right" open={open} onClose={handleClose}>
      <Box sx={{ width: { xs: '100vw', sm: 400 }, display: 'flex', flexDirection: 'column', height: '100vh', p: 2, pt: 10 }} role="presentation">
        
        {/* Cabecera del Drawer */}
        <Box sx={{ p: 3, bgcolor: 'primary.main', color: 'white' }}>
          <Stack direction="row" spacing={2} alignItems="center">
            <Avatar 
              sx={{ 
                width: 60, height: 60, 
                bgcolor: 'white', color: 'primary.dark', 
                fontWeight: 'bold', fontSize: '1.8rem'
              }}
            >
              {selectedUser.nombre ? selectedUser.nombre[0].toUpperCase() : '?'}
            </Avatar>
            <Box sx={{ overflow: 'hidden' }}>
              <Typography variant="h5" sx={{ fontWeight: 'bold' }} noWrap>
                {selectedUser.nombre || 'Sin Nombre'}
              </Typography>
              <Typography variant="body1" noWrap>{selectedUser.alias}</Typography>
              <Typography variant="body2" sx={{ opacity: 0.8 }} noWrap>
                {selectedUser.email}
              </Typography>
            </Box>
          </Stack>
        </Box>
        
        {/* Pestañas */}
        <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
          <Tabs value={tabIndex} onChange={handleTabChange} variant="fullWidth">
            <Tab label="Perfil" icon={<PersonIcon />} iconPosition="start" />
            <Tab label="Actividad" icon={<BarChartIcon />} iconPosition="start" />
            <Tab label="Acciones" icon={<SecurityIcon />} iconPosition="start" />
          </Tabs>
        </Box>

        {/* Contenido de Pestañas */}
        <Box sx={{ flexGrow: 1, overflowY: 'auto' }}>
          {/* PANEL 0: PERFIL */}
          <TabPanel value={tabIndex} index={0}>
            <Paper variant="outlined" sx={{ p: 2, pt: 2.5 }}>
              <Typography variant="h6" sx={{ mb: 2, px: 1 }}>Datos Personales</Typography>
              <InfoItem icon={<PhoneIcon />} label="Teléfono" value={selectedUser.telefono} />
              <InfoItem icon={<CalendarTodayIcon />} label="Registro" value={selectedUser.fecha_registro_formateada} />
              <InfoItem icon={<StarIcon color="warning"/>} label="Puntos" value={selectedUser.puntos ?? '0'} />
            </Paper>

            <Paper variant="outlined" sx={{ p: 2, pt: 2.5, mt: 3 }}>
              <Typography variant="h6" sx={{ mb: 2, px: 1 }}>Suscripción</Typography>
              <InfoItem 
                icon={<StarIcon color="warning" />} 
                label="Plan Activo" 
                value={selectedUser.nombre_plan || 'Ninguno (Gratuito)'} 
              />
              {selectedUser.nombre_plan && selectedUser.nombre_plan !== 'Plan Gratuito' && (
                <InfoItem 
                  icon={<CalendarTodayIcon />} 
                  label="Beneficios Válidos Hasta" 
                  value={selectedUser.fecha_fin_suscripcion_formateada || 'N/A'} 
                />
              )}
            </Paper>
          </TabPanel>

          {/* PANEL 1: ACTIVIDAD */}
          <TabPanel value={tabIndex} index={1}>
            {detailLoading ? (
              <Box sx={{ display: 'flex', justifyContent: 'center', my: 4 }}><CircularProgress /></Box>
            ) : userDetails ? (
              <>
                <Typography variant="h6" sx={{ mt: 0, mb: 2 }}>Insignias Obtenidas</Typography>
                {userDetails.insignias.length > 0 ? (
                  <Paper variant="outlined" sx={{ p: 2 }}>
                    <Grid container spacing={2}>
                      {userDetails.insignias.map(insignia => (
                        <Grid item xs={4} sm={3} key={insignia.nombre} sx={{ textAlign: 'center' }}>
                          <Tooltip title={`${insignia.nombre}: ${insignia.descripcion}`}>
                            <Avatar 
                              src={insignia.icono_url} 
                              sx={{ width: 56, height: 56, border: '2px solid', borderColor: 'divider', margin: '0 auto 4px auto' }} 
                            />
                          </Tooltip>
                          <Typography variant="caption" sx={{ display: 'block' }} noWrap>
                            {insignia.nombre}
                          </Typography>
                        </Grid>
                      ))}
                    </Grid>
                  </Paper>
                ) : (
                  <Typography variant="body2" color="text.secondary">Este usuario aún no ha ganado insignias.</Typography>
                )}
                
                <Divider sx={{ my: 3 }} />
                
                <Typography variant="h6" sx={{ mt: 3, mb: 2 }}>Últimos Reportes</Typography>
                {userDetails.reportes.length > 0 ? (
                  <Paper variant="outlined">
                    <List dense sx={{ p: 0 }}>
                      {userDetails.reportes.map((report, index) => (
                        <ListItem key={report.codigo_reporte} 
                          sx={{ borderBottom: index < userDetails.reportes.length - 1 ? 1 : 0, borderColor: 'divider' }}
                        >
                          <ListItemText 
                            primary={
                              <Box component="span" sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                <Typography variant="body1" component="span" sx={{ fontWeight: '500', flexGrow: 1 }} noWrap>
                                  {report.titulo}
                                </Typography>
                                <Chip label={report.urgencia} color={report.urgencia === 'Alta' ? 'error' : 'warning'} size="small" sx={{ ml: 1 }} />
                              </Box>
                            }
                            secondary={`#${report.codigo_reporte} - ${report.fecha}`} 
                          />
                        </ListItem>
                      ))}
                    </List>
                  </Paper>
                ) : (
                  <Typography variant="body2" color="text.secondary">Este usuario no ha creado reportes.</Typography>
                )}
              </>
            ) : (
              <Typography variant="body2" color="error" sx={{ mt: 2 }}>No se pudieron cargar los detalles.</Typography>
            )}
          </TabPanel>

          {/* PANEL 2: ACCIONES */}
          <TabPanel value={tabIndex} index={2}>
            
            <Paper variant="outlined" sx={{ p: 2, pt: 2.5 }}>
              <Typography variant="h6" sx={{ mb: 1.5 }}>Cambiar Rol</Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
                Promueve o degrada al usuario. Ciertas acciones requerirán confirmación.
              </Typography>
              <FormControl fullWidth size="small">
                <InputLabel>Nuevo Rol</InputLabel>
                <Select value={selectedUser.rol} label="Nuevo Rol" onChange={(e) => onRoleChange(e.target.value)}>
                  <MenuItem value="ciudadano">Ciudadano</MenuItem>
                  <MenuItem value="lider_vecinal">Líder Vecinal</MenuItem>
                  <MenuItem value="reportero">Reportero / Prensa</MenuItem>
                  <MenuItem value="admin">Admin</MenuItem>
                </Select>
              </FormControl>
            </Paper>

            <Typography variant="h6" sx={{ mt: 3, mb: 1.5, px: 1 }}>
              Atajos de Acción
            </Typography>

            <Paper variant="outlined" sx={{ p: 2 }}>
              <Stack spacing={2}>
                {/* --- USA EL BOTÓN RENOMBRADO --- */}
                <BotonConfirmacionMantenida {...statusButtonProps} />
                
                <Button 
                  variant="outlined" 
                  startIcon={<NotificationsIcon />}
                  onClick={() => onSendNotification(selectedUser)}
                  fullWidth
                >
                  Enviar Notificación
                </Button>
                
                {selectedUser.rol === 'lider_vecinal' && (
                  <Button 
                    variant="outlined" 
                    startIcon={<MapIcon />}
                    onClick={() => onAssignZone(selectedUser)}
                    fullWidth
                  >
                    Asignar Zonas de Líder
                  </Button>
                )}
              </Stack>
            </Paper>

          </TabPanel>
        </Box>

        {/* Botón Cerrar */}
        <Box sx={{ p: 2, borderTop: 1, borderColor: 'divider', mt: 'auto', bgcolor: 'background.paper' }}>
          <Button onClick={handleClose} startIcon={<CloseIcon />}>
            Cerrar
          </Button>
        </Box>
      </Box>
    </Drawer>
  );
}

export default DrawerDetalleUsuario;