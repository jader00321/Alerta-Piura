// src/components/Usuarios/DrawerDetalleUsuario.jsx
import React, { useState } from 'react';
import {
  Drawer, Box, Typography, Divider, CircularProgress, Button, Avatar,
  Stack, FormControl, InputLabel, Select, MenuItem, Tooltip, List,
  ListItem, ListItemText, Chip, Tabs, Tab, Paper, Grid, useTheme, alpha, IconButton
} from '@mui/material';
import { 
  Person as PersonIcon, Email as EmailIcon, CalendarToday as CalendarTodayIcon, 
  Phone as PhoneIcon, Star as StarIcon, Close as CloseIcon, 
  Security as SecurityIcon, BarChart as BarChartIcon,
  Block as BlockIcon,
  CheckCircle as CheckCircleIcon,
  Notifications as NotificationsIcon,
  Map as MapIcon,
  Verified as VerifiedIcon,
  AdminPanelSettings as AdminIcon,
  Group as GroupIcon,
  Mic as MicIcon,
  ArrowForwardIos as ArrowIcon
} from '@mui/icons-material';

import BotonConfirmacionMantenida from '../Comunes/BotonConfirmacionMantenida';

/** --- Helpers de Estilo --- */
function TabPanel(props) {
  const { children, value, index, ...other } = props;
  return (
    <div
      role="tabpanel"
      hidden={value !== index}
      id={`user-detail-tabpanel-${index}`}
      aria-labelledby={`user-detail-tab-${index}`}
      {...other}
      style={{ height: '100%', overflowY: 'auto' }}
    >
      {value === index && <Box sx={{ p: 3, pt: 3, bgcolor: 'background.default', minHeight: '100%' }}>{children}</Box>}
    </div>
  );
}

const InfoRow = ({ icon, label, value }) => (
  <Stack direction="row" spacing={2} alignItems="center" sx={{ py: 1.5, borderBottom: '1px dashed', borderColor: 'divider' }}>
    <Avatar sx={{ bgcolor: 'action.hover', color: 'text.secondary', width: 32, height: 32 }}>
      {React.cloneElement(icon, { fontSize: 'small' })}
    </Avatar>
    <Box sx={{ flexGrow: 1, minWidth: 0 }}>
      <Typography variant="caption" display="block" color="text.secondary" sx={{ fontWeight: 600, letterSpacing: 0.5 }}>
        {label.toUpperCase()}
      </Typography>
      <Typography variant="body2" sx={{ fontWeight: 500, wordBreak: 'break-all' }}>
        {value || 'No disponible'}
      </Typography>
    </Box>
  </Stack>
);

/**
 * Chip de Rol Mejorado:
 * - Colores intensos (relleno sólido).
 * - Texto blanco para contraste alto.
 * - Tamaño aumentado.
 */
const RoleBadge = ({ role }) => {
  const theme = useTheme();
  
  // Configuración de colores intensos
  let config = { 
    label: 'Ciudadano', 
    bgcolor: theme.palette.grey[700], // Gris oscuro intenso para ciudadano
    icon: <PersonIcon sx={{ color: 'white' }} /> 
  };

  if (role === 'admin') config = { 
    label: 'Administrador', 
    bgcolor: theme.palette.error.main, // Rojo intenso
    icon: <AdminIcon sx={{ color: 'white' }} /> 
  };
  if (role === 'lider_vecinal') config = { 
    label: 'Líder Vecinal', 
    bgcolor: theme.palette.success.main, // Verde intenso (o primary.main si prefieres)
    icon: <GroupIcon sx={{ color: 'white' }} /> 
  };
  if (role === 'reportero') config = { 
    label: 'Reportero', 
    bgcolor: theme.palette.info.main, // Azul intenso
    icon: <MicIcon sx={{ color: 'white' }} /> 
  };

  return (
    <Chip 
      label={config.label} 
      icon={config.icon} 
      // FIX: Tamaño por defecto (medium) en lugar de small para que sea más visible
      sx={{ 
        bgcolor: config.bgcolor, 
        color: 'white', // Texto blanco siempre
        fontWeight: 'bold',
        fontSize: '0.85rem',
        boxShadow: 2,
        px: 1
      }} 
    />
  );
};

/** --- Componente Principal --- */
function DrawerDetalleUsuario({ 
  open, onClose, selectedUser, userDetails, detailLoading, 
  onRoleChange, onStatusChange, onSendNotification, onAssignZone
}) {
  const [tabIndex, setTabIndex] = useState(0);
  const theme = useTheme();

  const handleTabChange = (event, newValue) => setTabIndex(newValue);
  
  const handleClose = () => {
    setTabIndex(0); 
    onClose();
  };
  
  if (!selectedUser) return null;

  const isActive = selectedUser.status === 'activo';
  const statusButtonProps = isActive ?
    { onConfirm: () => onStatusChange(selectedUser.id, selectedUser.status), label: "Suspender Cuenta", color: "error", startIcon: <BlockIcon /> } : 
    { onConfirm: () => onStatusChange(selectedUser.id, selectedUser.status), label: "Reactivar Cuenta", color: "success", startIcon: <CheckCircleIcon /> };

  return (
    <Drawer 
      anchor="right" 
      open={open} 
      onClose={handleClose}
      PaperProps={{
        sx: { 
          width: { xs: '100vw', sm: 450 }, 
          bgcolor: 'background.default',
          // FIX 1: Padding top extra para evitar que el Navbar tape el contenido
          pt: { xs: 7, sm: 7 } 
        }
      }}
    >
      {/* FIX 2: Fondo Oscuro para mejor contraste.
         Usamos un gris muy oscuro (casi negro) con un degradado sutil.
      */}
      <Box sx={{ 
        position: 'relative', 
        p: 4, 
        background: `linear-gradient(180deg, ${theme.palette.grey[900]} 0%, ${theme.palette.grey[800]} 100%)`,
        color: 'white',
        textAlign: 'center',
        borderBottom: `4px solid ${theme.palette.primary.main}` // Línea de acento color de marca
      }}>
        <IconButton 
          onClick={handleClose} 
          sx={{ position: 'absolute', top: 8, right: 8, color: 'white', bgcolor: 'rgba(255,255,255,0.1)' }}
        >
          <CloseIcon />
        </IconButton>

        <Avatar 
          sx={{ 
            width: 90, height: 85, // Un poco más grande
            mx: 'auto', mb: 2, 
            bgcolor: 'white', 
            color: theme.palette.grey[900], // Texto oscuro para contraste
            fontSize: '2.5rem', fontWeight: 800,
            boxShadow: '0 8px 24px rgba(0,0,0,0.4)',
            border: '4px solid rgba(255,255,255,0.2)'
          }}
        >
          {selectedUser.nombre ? selectedUser.nombre[0].toUpperCase() : '?'}
        </Avatar>

        <Typography variant="h5" fontWeight="bold" noWrap sx={{ letterSpacing: 0.5 }}>
          {selectedUser.nombre || 'Sin Nombre'}
        </Typography>
        <Typography variant="body1" sx={{ opacity: 0.7, mb: 2, fontStyle: 'italic' }}>
          {selectedUser.alias || '@usuario'}
        </Typography>
        
        {/* FIX 3: Stack de Chips más visibles */}
        <Stack direction="row" spacing={1} justifyContent="center" alignItems="center" flexWrap="wrap" gap={1}>
          <RoleBadge role={selectedUser.rol} />
          
          {selectedUser.nombre_plan !== 'Plan Gratuito' && (
             <Chip 
               label="PREMIUM" 
               // Tamaño normal (no small)
               icon={<StarIcon sx={{ color: '#ad9405ff !important' }} />}
               sx={{ 
                 bgcolor: '#f8d81fff', // Dorado intenso
                 color: 'black',     // Texto negro para contraste máximo
                 fontWeight: '900',
                 boxShadow: 2
               }} 
             />
          )}
        </Stack>
      </Box>

      {/* Tabs Flotantes */}
      <Paper elevation={0} sx={{ borderBottom: 1, borderColor: 'divider', position: 'sticky', top: 0, zIndex: 10 }}>
        <Tabs 
          value={tabIndex} 
          onChange={handleTabChange} 
          variant="fullWidth" 
          indicatorColor="primary"
          textColor="primary"
          sx={{ minHeight: 56 }}
        >
          <Tab label="Perfil" icon={<PersonIcon />} iconPosition="start" />
          <Tab label="Actividad" icon={<BarChartIcon />} iconPosition="start" />
          <Tab label="Gestión" icon={<SecurityIcon />} iconPosition="start" />
        </Tabs>
      </Paper>

      {/* Contenido Scrolleable */}
      <Box sx={{ flexGrow: 1, overflow: 'hidden', bgcolor: 'background.default' }}>
        
        {/* --- PANEL PERFIL --- */}
        <TabPanel value={tabIndex} index={0}>
          <Paper elevation={0} sx={{ p: 2, borderRadius: 2, border: `1px solid ${theme.palette.divider}`, mb: 3 }}>
            <Typography variant="subtitle2" color="text.secondary" sx={{ mb: 2, fontWeight: 'bold' }}>INFORMACIÓN DE CONTACTO</Typography>
            <InfoRow icon={<EmailIcon />} label="Correo Electrónico" value={selectedUser.email} />
            <InfoRow icon={<PhoneIcon />} label="Teléfono" value={selectedUser.telefono} />
            <InfoRow icon={<CalendarTodayIcon />} label="Miembro Desde" value={selectedUser.fecha_registro_formateada} />
          </Paper>

          <Paper elevation={0} sx={{ p: 2, borderRadius: 2, border: `1px solid ${theme.palette.divider}` }}>
            <Typography variant="subtitle2" color="text.secondary" sx={{ mb: 2, fontWeight: 'bold' }}>ESTADO DE LA CUENTA</Typography>
            <Stack direction="row" spacing={2} sx={{ mb: 2 }}>
               <Paper sx={{ flex: 1, p: 2, bgcolor: 'background.paper', textAlign: 'center', border: `1px solid ${theme.palette.divider}` }} elevation={0}>
                  <Typography variant="h4" color="primary.main" fontWeight="bold">{selectedUser.puntos || 0}</Typography>
                  <Typography variant="caption" color="text.secondary">Puntos</Typography>
               </Paper>
               <Paper sx={{ flex: 1, p: 2, bgcolor: isActive ? alpha(theme.palette.success.main, 0.1) : alpha(theme.palette.error.main, 0.1), textAlign: 'center', color: isActive ? 'success.dark' : 'error.dark' }} elevation={0}>
                  {isActive ? <CheckCircleIcon fontSize="large" /> : <BlockIcon fontSize="large" />}
                  <Typography variant="caption" display="block" fontWeight="bold" sx={{ mt: 0.5 }}>{isActive ? 'Activo' : 'Suspendido'}</Typography>
               </Paper>
            </Stack>
            
            <InfoRow 
              icon={<StarIcon color="warning" />} 
              label="Plan Actual" 
              value={selectedUser.nombre_plan || 'Plan Gratuito'} 
            />
            {selectedUser.nombre_plan && selectedUser.nombre_plan !== 'Plan Gratuito' && (
              <InfoRow 
                icon={<CalendarTodayIcon />} 
                label="Vence el" 
                value={selectedUser.fecha_fin_suscripcion_formateada} 
              />
            )}
          </Paper>
        </TabPanel>

        {/* --- PANEL ACTIVIDAD --- */}
        <TabPanel value={tabIndex} index={1}>
          {detailLoading ? (
             <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', py: 8 }}>
               <CircularProgress size={40} thickness={4} />
               <Typography variant="caption" sx={{ mt: 2 }}>Cargando historial...</Typography>
             </Box>
          ) : userDetails ? (
            <>
              {/* Insignias */}
              <Typography variant="subtitle2" sx={{ mb: 2, fontWeight: 'bold', display: 'flex', alignItems: 'center', gap: 1 }}>
                 <VerifiedIcon color="primary" fontSize="small" /> INSIGNIAS & LOGROS
              </Typography>
              
              {userDetails.insignias.length > 0 ? (
                <Grid container spacing={2} sx={{ mb: 4 }}>
                  {userDetails.insignias.map((insignia, idx) => (
                    <Grid item xs={4} key={idx}>
                       <Paper 
                         elevation={0} 
                         sx={{ 
                           p: 1.5, textAlign: 'center', 
                           bgcolor: 'background.paper', 
                           border: `1px solid ${theme.palette.divider}`,
                           borderRadius: 2,
                           transition: 'transform 0.2s',
                           '&:hover': { transform: 'translateY(-2px)', boxShadow: 2 }
                         }}
                       >
                         <Avatar src={insignia.icono_url} sx={{ width: 40, height: 40, mx: 'auto', mb: 1 }} variant="square" />
                         <Typography variant="caption" sx={{ fontWeight: 600, lineHeight: 1.2, display: 'block' }}>{insignia.nombre}</Typography>
                       </Paper>
                    </Grid>
                  ))}
                </Grid>
              ) : (
                <Paper sx={{ p: 3, textAlign: 'center', bgcolor: 'action.hover', mb: 4 }} variant="outlined">
                   <Typography variant="body2" color="text.secondary">Sin insignias aún.</Typography>
                </Paper>
              )}

              {/* Historial de Reportes */}
              <Typography variant="subtitle2" sx={{ mb: 2, fontWeight: 'bold', display: 'flex', alignItems: 'center', gap: 1 }}>
                 <BarChartIcon color="primary" fontSize="small" /> ÚLTIMOS REPORTES
              </Typography>

              {userDetails.reportes.length > 0 ? (
                <Stack spacing={2}>
                   {userDetails.reportes.map((report) => (
                     <Paper 
                       key={report.codigo_reporte} 
                       elevation={0}
                       sx={{ 
                         p: 2, 
                         border: `1px solid ${theme.palette.divider}`,
                         borderRadius: 2,
                         display: 'flex',
                         justifyContent: 'space-between',
                         alignItems: 'center'
                       }}
                     >
                        <Box sx={{ overflow: 'hidden', mr: 2 }}>
                           <Typography variant="subtitle2" noWrap fontWeight="bold">{report.titulo}</Typography>
                           <Typography variant="caption" color="text.secondary">
                              {report.fecha} • #{report.codigo_reporte}
                           </Typography>
                        </Box>
                        <Chip 
                          label={report.urgencia} 
                          size="small" 
                          color={report.urgencia === 'Alta' ? 'error' : report.urgencia === 'Media' ? 'warning' : 'success'}
                          variant="outlined"
                          sx={{ fontWeight: 'bold' }}
                        />
                     </Paper>
                   ))}
                </Stack>
              ) : (
                <Paper sx={{ p: 4, textAlign: 'center', borderStyle: 'dashed' }} variant="outlined">
                   <Typography variant="body2" color="text.secondary">El usuario no ha realizado reportes.</Typography>
                </Paper>
              )}
            </>
          ) : (
             <Typography color="error" align="center">Error al cargar datos.</Typography>
          )}
        </TabPanel>

        {/* --- PANEL GESTIÓN --- */}
        <TabPanel value={tabIndex} index={2}>
          <Paper elevation={0} sx={{ p: 2.5, borderRadius: 2, border: `1px solid ${theme.palette.divider}`, mb: 3 }}>
             <Typography variant="subtitle2" sx={{ mb: 2, fontWeight: 'bold' }}>MODIFICAR ROL</Typography>
             <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
               Selecciona un nuevo nivel de acceso para este usuario.
             </Typography>
             
             <FormControl fullWidth size="small">
                <InputLabel>Rol del Sistema</InputLabel>
                <Select 
                  value={selectedUser.rol} 
                  label="Rol del Sistema" 
                  onChange={(e) => onRoleChange(e.target.value)}
                >
                  <MenuItem value="ciudadano"><Stack direction="row" alignItems="center" gap={1}><PersonIcon fontSize="small"/> Ciudadano</Stack></MenuItem>
                  <MenuItem value="lider_vecinal"><Stack direction="row" alignItems="center" gap={1}><GroupIcon fontSize="small"/> Líder Vecinal</Stack></MenuItem>
                  <MenuItem value="reportero"><Stack direction="row" alignItems="center" gap={1}><MicIcon fontSize="small"/> Reportero</Stack></MenuItem>
                  <MenuItem value="admin"><Stack direction="row" alignItems="center" gap={1}><AdminIcon fontSize="small"/> Administrador</Stack></MenuItem>
                </Select>
             </FormControl>
          </Paper>

          <Typography variant="subtitle2" sx={{ mb: 2, fontWeight: 'bold', px: 1 }}>ACCIONES RÁPIDAS</Typography>
          
          <Stack spacing={2}>
             <Button 
               variant="outlined" 
               size="large"
               startIcon={<NotificationsIcon />}
               endIcon={<ArrowIcon fontSize="small" />}
               onClick={() => onSendNotification(selectedUser)}
               sx={{ justifyContent: 'space-between', borderRadius: 2, py: 1.5, borderColor: theme.palette.divider, color: 'text.primary' }}
             >
               Enviar Notificación Push
             </Button>

             {selectedUser.rol === 'lider_vecinal' && (
               <Button 
                 variant="outlined" 
                 size="large"
                 color="primary"
                 startIcon={<MapIcon />}
                 endIcon={<ArrowIcon fontSize="small" />}
                 onClick={() => onAssignZone(selectedUser)}
                 sx={{ justifyContent: 'space-between', borderRadius: 2, py: 1.5 }}
               >
                 Gestionar Territorios
               </Button>
             )}

             <Divider sx={{ my: 1 }} />
             
             <BotonConfirmacionMantenida 
               {...statusButtonProps} 
               fullWidth 
               sx={{ py: 1.5, borderRadius: 2, fontWeight: 'bold' }} 
             />
          </Stack>
        </TabPanel>

      </Box>
    </Drawer>
  );
}

export default DrawerDetalleUsuario;