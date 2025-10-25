import React from 'react';
import { Box, Paper, Typography, Chip, Stack, Divider, CircularProgress } from '@mui/material';
import {
    Person as PersonIcon, Email as EmailIcon, CheckCircle as CheckCircleIcon,
    Block as BlockIcon, Star as StarIcon, AdminPanelSettings as AdminIcon,
    Group as GroupIcon, Mic as MicIcon, NotificationsActive as NotificationsIcon
} from '@mui/icons-material';

// --- Helper Chip Components ---

/**
 * Componente Chip para mostrar el rol de un usuario con un ícono y color específico.
 * @param {object} props - Propiedades del componente.
 * @param {string} props.role - El rol del usuario (ej: 'admin', 'lider_vecinal', 'reportero', 'ciudadano').
 * @returns {JSX.Element} Un componente Chip de MUI.
 */
const RoleChip = ({ role }) => {
  const roles = {
    admin: { label: 'Admin', icon: <AdminIcon />, color: 'secondary' },
    lider_vecinal: { label: 'Líder Vecinal', icon: <GroupIcon />, color: 'primary' },
    reportero: { label: 'Reportero / Prensa', icon: <MicIcon />, color: 'info' },
    ciudadano: { label: 'Ciudadano', icon: <PersonIcon />, color: 'default' }
  };
  const config = roles[role] || roles.ciudadano;
  return <Chip icon={config.icon} label={config.label} color={config.color} size="small" variant="filled" sx={{ color: '#212121', fontWeight: 'bold' }}/>;
};

/**
 * Componente Chip para mostrar el estado de un usuario (Activo o Suspendido).
 * @param {object} props - Propiedades del componente.
 * @param {string} props.status - El estado del usuario (ej: 'activo').
 * @returns {JSX.Element} Un componente Chip de MUI.
 */
const StatusChip = ({ status }) => {
  const isActive = status === 'activo';
  return <Chip icon={isActive ? <CheckCircleIcon sx={{color:'#212121'}}/> : <BlockIcon sx={{color:'#212121'}}/>} label={isActive ? 'Activo' : 'Suspendido'} color={isActive ? 'success' : 'error'} size="small" variant="filled" sx={{ color: '#212121', fontWeight: 'bold' }}/>;
};

/**
 * Componente Chip para mostrar el plan del usuario, indicando si es premium.
 * @param {object} props - Propiedades del componente.
 * @param {string} props.planNombre - El nombre del plan (ej: 'Plan Básico', 'Plan Reportero').
 * @param {boolean} props.isPremium - Indica si el plan es premium.
 * @returns {JSX.Element} Un componente Chip de MUI.
 */
const PlanChip = ({ planNombre, isPremium }) => {
    let config = { icon: <StarIcon />, label: planNombre, color: 'default', variant: 'outlined' };
    if (isPremium) {
        config.variant = 'filled';
        config.color = planNombre?.includes('Reportero') ? 'info' : 'warning'; // Adjust based on actual plan names
    }
    return <Chip icon={config.icon} label={config.label} color={config.color} size="small" variant={config.variant} sx={{ fontWeight: isPremium ? 'bold' : 'normal' }}/>;
};

// --- Main Component ---

/**
 * Muestra una tarjeta (Paper) con los detalles de un usuario seleccionado
 * en el contexto de la gestión de notificaciones.
 *
 * Maneja tres estados:
 * 1. Carga (loading): Muestra un CircularProgress.
 * 2. Sin selección (!userDetails): Muestra un mensaje placeholder.
 * 3. Detalles visibles (userDetails): Muestra la información del usuario.
 *
 * @param {object} props - Propiedades del componente.
 * @param {object | null} props.userDetails - Objeto con los detalles del usuario seleccionado, o null si no hay selección.
 * @param {string} [props.userDetails.alias] - Alias del usuario.
 * @param {string} [props.userDetails.nombre] - Nombre del usuario.
 * @param {string} props.userDetails.email - Email del usuario.
 * @param {string} props.userDetails.status - Estado (ej: 'activo').
 * @param {string} props.userDetails.rol - Rol (ej: 'admin').
 * @param {string} props.userDetails.nombre_plan - Nombre del plan de suscripción.
 * @param {boolean} props.userDetails.is_premium - Si el plan es premium.
 * @param {number} props.userDetails.total_notificaciones - Conteo total de notificaciones del usuario.
 * @param {boolean} props.loading - Estado de carga. Si es true, muestra un spinner.
 * @param {number} [props.filteredCount] - Conteo opcional de notificaciones en la vista filtrada actual. Se muestra si es diferente al total.
 * @returns {JSX.Element} El panel de detalles del usuario.
 */
function DetallesUsuarioNotificaciones({ userDetails, loading, filteredCount }) {
  if (loading) {
    return (
      <Paper variant="outlined" sx={{ p: 3, display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
        <CircularProgress />
      </Paper>
    );
  }

  if (!userDetails) {
    return (
      <Paper variant="outlined" sx={{ p: 3, display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%', borderStyle: 'dashed', bgcolor: 'action.hover' }}>
         <Typography color="text.secondary">Selecciona un usuario para ver sus detalles</Typography>
      </Paper>
    );
  }

  return (
    <Paper variant="outlined" sx={{ p: 2.5, height: '100%' }}>
      <Typography variant="h6" gutterBottom sx={{ fontWeight: 'bold' }}>
        Detalles del Destinatario
      </Typography>
      <Divider sx={{ mb: 2 }} />
      <Stack spacing={1.5}>
          <Typography variant="body1" sx={{ fontWeight: 500 }}>
             {userDetails.alias || userDetails.nombre}
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <EmailIcon fontSize="small" /> {userDetails.email}
          </Typography>
          <Divider sx={{ my: 1 }}/>
          <Stack direction="row" spacing={1} alignItems="center">
            <Typography variant="body2">Estado:</Typography>
            <StatusChip status={userDetails.status} />
          </Stack>
          <Stack direction="row" spacing={1} alignItems="center">
            <Typography variant="body2">Rol:</Typography>
            <RoleChip role={userDetails.rol} />
          </Stack>
          <Stack direction="row" spacing={1} alignItems="center">
            <Typography variant="body2">Plan:</Typography>
            <PlanChip planNombre={userDetails.nombre_plan} isPremium={userDetails.is_premium} />
          </Stack>
          <Divider sx={{ my: 1 }}/>
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
            <NotificationsIcon color="action"/>
            <Typography variant="body2" color="text.secondary">
                Notificaciones totales:
            </Typography>
             <Typography variant="body1" sx={{ fontWeight: 'bold' }}>
                 {userDetails.total_notificaciones}
             </Typography>
          </Box>
          {/* Show filtered count only if different from total */}
          {filteredCount !== undefined && filteredCount !== userDetails.total_notificaciones && (
            <Typography variant="body2" color="text.secondary" sx={{ml: 3.5}}>
                ({filteredCount} en la vista actual)
            </Typography>
          )}
      </Stack>
    </Paper>
  );
}

export default DetallesUsuarioNotificaciones;