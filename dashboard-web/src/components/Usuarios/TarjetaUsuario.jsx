import React from 'react';
import { 
  Card, CardHeader, CardContent, CardActions, Chip, IconButton, 
  Avatar, Tooltip, Typography, Box, Divider, Stack, useTheme
} from '@mui/material';
import { 
  Person as PersonIcon, AdminPanelSettings as AdminIcon, Group as GroupIcon, 
  CheckCircle as CheckCircleIcon, Block as BlockIcon, Star as StarIcon, 
  Mic as MicIcon, MoreVert as MoreVertIcon, Map as MapIcon,
  WorkspacePremium as PremiumIcon,
  CameraAlt as ReporteroIcon
} from '@mui/icons-material';
// --- Import Actualizado ---
import BotonConfirmacionMantenida from '../Comunes/BotonConfirmacionMantenida';

/**
 * Componente Chip estilizado para mostrar el rol de un usuario.
 * Utiliza colores y un ícono específicos para cada rol.
 * Clona el ícono para forzar un color de ícono oscuro (#212121)
 * para un mejor contraste sobre fondos claros.
 *
 * @param {object} props - Propiedades del componente.
 * @param {string} props.role - El rol del usuario (ej: 'admin', 'lider_vecinal', 'ciudadano').
 * @returns {JSX.Element} Un componente Chip de MUI.
 */
const RoleChip = ({ role }) => {
  const theme = useTheme();
  const roles = {
    admin: { label: 'Admin', icon: <AdminIcon />, 
             bgColor: theme.palette.secondary.light, color: theme.palette.secondary.dark },
    lider_vecinal: { label: 'Líder Vecinal', icon: <GroupIcon />, 
                     bgColor: theme.palette.primary.light, color: theme.palette.primary.dark },
    reportero: { label: 'Reportero / Prensa', icon: <MicIcon />, 
                 bgColor: theme.palette.info.light, color: theme.palette.info.dark },
    ciudadano: { label: 'Ciudadano', icon: <PersonIcon />, 
                 bgColor: theme.palette.grey[200], color: theme.palette.grey[800] }
  };
  const { label, icon, bgColor } = roles[role] || roles.ciudadano;
  
  // --- FIX: Clonar el icono para forzar su color ---
  const darkIcon = React.cloneElement(icon, { 
    sx: { color: '#212121' } 
  });

  return (
    <Chip 
      icon={darkIcon} // <-- Usar el icono clonado
      label={label} 
      size="small" 
      variant="filled" 
      sx={{ 
        backgroundColor: bgColor, 
        color: '#212121',
        fontWeight: 'bold' 
      }} 
    />
  );
};

/**
 * Componente Chip estilizado para mostrar el estado de un usuario (Activo o Suspendido).
 * Utiliza colores de 'success' (activo) o 'error' (suspendido) y
 * aplica un color oscuro (#212121) a los íconos para contraste.
 *
 * @param {object} props - Propiedades del componente.
 * @param {string} props.status - El estado del usuario (ej: 'activo').
 * @returns {JSX.Element} Un componente Chip de MUI.
 */
const StatusChip = ({ status }) => {
  const theme = useTheme();
  const isActive = status === 'activo';
  
  const chipStyles = isActive 
    ? { bgColor: theme.palette.success.light, color: theme.palette.success.dark }
    : { bgColor: theme.palette.error.light, color: theme.palette.error.dark };

  // --- FIX: Aplicar sx directo al icono ---
  const darkIcon = isActive 
    ? <CheckCircleIcon sx={{ color: '#212121' }} /> 
    : <BlockIcon sx={{ color: '#212121' }} />;

  return (
    <Chip
      icon={darkIcon} // <-- Usar el icono con sx
      label={isActive ? 'Activo' : 'Suspendido'}
      size="small"
      variant="filled" 
      sx={{ 
        backgroundColor: chipStyles.bgColor, 
        color: '#212121',
        fontWeight: 'bold' 
      }}
    />
  );
};

/**
 * Componente Chip estilizado para mostrar el plan de suscripción del usuario.
 * Muestra diferentes estilos (color, ícono, variante) para planes Premium.
 * Envuelve el Chip en un Tooltip que muestra la fecha de fin de la suscripción.
 * Retorna `null` si no se proporciona `planNombre`.
 *
 * @param {object} props - Propiedades del componente.
 * @param {string} [props.planNombre] - El nombre del plan (ej: 'Ciudadano Premium').
 * @param {string} [props.fechaFin] - La fecha de fin de suscripción (formateada), para el Tooltip.
 * @returns {JSX.Element | null} Un Tooltip con un Chip de MUI, o null.
 */
const PlanChip = ({ planNombre, fechaFin }) => {
  if (!planNombre) return null;
  let config = {
    icon: <StarIcon />,
    label: planNombre,
    variant: 'outlined',
    color: 'default',
    title: 'Usuario con plan gratuito'
  };

  switch (planNombre) {
    case 'Ciudadano Premium':
      config = {
        icon: <PremiumIcon />,
        label: 'Ciudadano Premium',
        variant: 'filled',
        color: 'warning',
        title: `Suscripción activa hasta: ${fechaFin || 'N/A'}`
      };
      break;
    case 'Reportero Premium':
      config = {
        icon: <ReporteroIcon />,
        label: 'Reportero Premium',
        variant: 'filled',
        color: 'info',
        title: `Suscripción activa hasta: ${fechaFin || 'N/A'}`
      };
      break;
    case 'Plan Gratuito':
    default:
      break;
  }

  return (
    <Tooltip title={config.title}>
      <Chip 
        icon={config.icon} 
        label={config.label} 
        color={config.color} 
        size="small" 
        variant={config.variant}
        sx={config.variant === 'filled' ? { fontWeight: 'bold' } : {}}
      />
    </Tooltip>
  );
};


/**
 * Renderiza una tarjeta (Card) de MUI que resume la información de un usuario.
 *
 * Muestra:
 * - Avatar, Nombre y Alias/Email.
 * - Chips para Rol, Estado y Plan (usando los helpers RoleChip, StatusChip, PlanChip).
 * - Fecha de registro.
 *
 * Acciones:
 * - Un botón de "Ver Detalles" (ícono MoreVert) que llama a `onDetailOpen`.
 * - Un `BotonConfirmacionMantenida` para "Suspender" o "Reactivar" al usuario, llamando a `onStatusChange`.
 * - Un botón de "Asignar Zonas" (ícono MapIcon) si el rol es 'lider_vecinal', llamando a `onAssignZone`.
 *
 * Estilos:
 * - La tarjeta aparece con opacidad y en escala de grises si el usuario está 'suspendido'.
 *
 * @param {object} props - Propiedades del componente.
 * @param {object} props.user - El objeto de datos del usuario.
 * @param {string} props.user.id - ID del usuario.
 * @param {string} props.user.status - Estado (ej: 'activo', 'suspendido').
 * @param {string} [props.user.nombre] - Nombre del usuario.
 * @param {string} [props.user.alias] - Alias del usuario.
 * @param {string} props.user.email - Email del usuario.
 * @param {string} props.user.rol - Rol del usuario (ej: 'admin', 'lider_vecinal').
 * @param {string} [props.user.nombre_plan] - Nombre del plan de suscripción.
 * @param {string} [props.user.fecha_fin_suscripcion_formateada] - Fecha fin de plan (formateada).
 * @param {string} [props.user.fecha_registro_formateada] - Fecha de registro (formateada).
 * @param {Function} props.onStatusChange - Callback al confirmar cambio de estado. Recibe `(userId, currentStatus)`.
 * @param {Function} props.onDetailOpen - Callback al presionar 'Ver Detalles' (MoreVert). Recibe `(user)`.
 * @param {Function} props.onAssignZone - Callback al presionar 'Asignar Zonas'. Recibe `(user)`.
 * @returns {JSX.Element} Un componente Card de MUI.
 */
const TarjetaUsuario = ({ user, onStatusChange, onDetailOpen, onAssignZone }) => {
  const isSuspended = user.status === 'suspendido';

  return (
    <Card sx={{ 
      height: '100%', 
      display: 'flex', 
      flexDirection: 'column',
      transition: 'all 0.3s ease',
      '&:hover': { boxShadow: '0 4px 12px rgba(0,0,0,0.08)' },
      ...(isSuspended && { // Estilos si está suspendido
        opacity: 0.6,
        filter: 'grayscale(60%)',
        '&:hover': { boxShadow: 'none' }
      })
    }}>
      <CardHeader
        avatar={
          <Avatar 
            sx={{ 
              bgcolor: 'primary.dark', 
              color: 'white', 
              fontWeight: 'bold' 
            }}
          >
            {user.nombre ? user.nombre[0].toUpperCase() : '?'}
          </Avatar>
        }
        action={
          <Tooltip title="Ver Detalles y Acciones">
            <IconButton onClick={() => onDetailOpen(user)}><MoreVertIcon /></IconButton>
          </Tooltip>
        }
        title={<Typography variant="h6" noWrap sx={{ fontWeight: 600 }}>{user.nombre || 'Sin Nombre'}</Typography>}
        subheader={<Typography variant="body2" color="text.secondary" noWrap>{user.alias || user.email}</Typography>}
        sx={{ pb: 1 }}
      />
      
      <CardContent sx={{ flexGrow: 1, pt: 1, display: 'flex', flexDirection: 'column' }}>
        
        {/* Chips de Rol y Estado */}
        <Stack direction="row" spacing={1} sx={{ mb: 2, flexWrap: 'wrap', gap: 0.5 }}>
          <RoleChip role={user.rol} />
          <StatusChip status={user.status} />
        </Stack>
        
        {/* Chip de Plan */}
        <Box sx={{ mb: 2 }}>
          <PlanChip 
            planNombre={user.nombre_plan} 
            fechaFin={user.fecha_fin_suscripcion_formateada} 
          />
        </Box>

        {/* Fecha de Registro (empujada al fondo) */}
        <Box sx={{ mt: 'auto', pt: 1, borderTop: 1, borderColor: 'divider' }}>
          <Typography variant="caption" color="text.secondary" sx={{ display: 'block' }}>
            Registrado: {user.fecha_registro_formateada}
          </Typography>
        </Box>
        
      </CardContent>
      
      <Divider sx={{ mt: 'auto' }} />
      
      {/* Acciones (Suspender/Reactivar y Asignar Zona) */}
      <CardActions sx={{ px: 2, pb: 2, pt: 1.5, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        {user.status === 'activo' ? (
          <BotonConfirmacionMantenida 
            onConfirm={() => onStatusChange(user.id, user.status)} 
            label="Suspender" 
            color="error" 
            startIcon={<BlockIcon />}
          />
        ) : (
          <BotonConfirmacionMantenida 
            onConfirm={() => onStatusChange(user.id, user.status)} 
            label="Reactivar" 
            color="success" 
            startIcon={<CheckCircleIcon />}
          />
        )}
        
        {/* Botón Asignar Zonas (solo para líderes) */}
        {user.rol === 'lider_vecinal' && (
          <Tooltip title="Asignar Zonas de Moderación">
            <IconButton onClick={() => onAssignZone(user)} color="primary" size="small">
              <MapIcon />
            </IconButton>
          </Tooltip>
        )}
      </CardActions>
    </Card>
  );
};

export default TarjetaUsuario;