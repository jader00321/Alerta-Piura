// src/components/Usuarios/TarjetaUsuario.jsx
import React from 'react';
import { 
  Card, CardHeader, CardContent, CardActions, Chip, IconButton, 
  Avatar, Tooltip, Typography, Box, Divider, Stack, useTheme, alpha
} from '@mui/material';
import { 
  Person as PersonIcon, AdminPanelSettings as AdminIcon, Group as GroupIcon, 
  CheckCircle as CheckCircleIcon, Block as BlockIcon, Star as StarIcon, 
  Mic as MicIcon, MoreVert as MoreVertIcon, Map as MapIcon,
  WorkspacePremium as PremiumIcon,
  CameraAlt as ReporteroIcon,
  Email as EmailIcon
} from '@mui/icons-material';

import BotonConfirmacionMantenida from '../Comunes/BotonConfirmacionMantenida';

/**
 * RoleChip - Versión Mejorada
 * Estilo más plano y moderno con colores semitransparentes.
 */
const RoleChip = ({ role }) => {
  const theme = useTheme();
  
  const configs = {
    admin: { 
        label: 'Admin', 
        icon: <AdminIcon fontSize="small"/>, 
        color: theme.palette.error.main,
        bg: alpha(theme.palette.error.main, 0.1)
    },
    lider_vecinal: { 
        label: 'Líder', 
        icon: <GroupIcon fontSize="small"/>, 
        color: theme.palette.success.main,
        bg: alpha(theme.palette.success.main, 0.1)
    },
    reportero: { 
        label: 'Reportero', 
        icon: <MicIcon fontSize="small"/>, 
        color: theme.palette.info.main,
        bg: alpha(theme.palette.info.main, 0.1)
    },
    ciudadano: { 
        label: 'Ciudadano', 
        icon: <PersonIcon fontSize="small"/>, 
        color: theme.palette.text.secondary,
        bg: theme.palette.action.selected
    }
  };

  const { label, icon, color, bg } = configs[role] || configs.ciudadano;

  return (
    <Chip 
      icon={React.cloneElement(icon, { style: { color: color } })} 
      label={label} 
      size="small" 
      sx={{ 
        bgcolor: bg, 
        color: color,
        fontWeight: 700,
        borderRadius: '6px',
        border: `1px solid ${alpha(color, 0.2)}`,
        '& .MuiChip-icon': { marginLeft: '8px' }
      }} 
    />
  );
};

/**
 * StatusChip - Versión Minimalista
 * Indicador visual tipo "punto" + texto.
 */
const StatusChip = ({ status }) => {
  const theme = useTheme();
  const isActive = status === 'activo';
  const color = isActive ? theme.palette.success.main : theme.palette.error.main;

  return (
    <Box sx={{ 
      display: 'inline-flex', 
      alignItems: 'center', 
      gap: 0.5,
      px: 1, py: 0.5,
      borderRadius: 10,
      bgcolor: alpha(color, 0.08)
    }}>
      <Box sx={{ width: 8, height: 8, borderRadius: '50%', bgcolor: color }} />
      <Typography variant="caption" fontWeight="bold" color={color} sx={{ textTransform: 'capitalize' }}>
        {status}
      </Typography>
    </Box>
  );
};

/**
 * PlanChip - Versión Premium
 * Estilo dorado para planes pagados.
 */
const PlanChip = ({ planNombre, fechaFin }) => {
  if (!planNombre) return null;
  const isPremium = planNombre !== 'Plan Gratuito';

  // Configuración base
  let icon = <StarIcon fontSize="small" />;
  let sx = { fontWeight: 500 };
  let color = "default";
  let variant = "outlined";

  if (isPremium) {
    icon = <PremiumIcon fontSize="small" />;
    color = "warning"; // Usualmente naranja/dorado en MUI
    variant = "filled";
    sx = { 
      fontWeight: 'bold',
      background: 'linear-gradient(45deg, #FFC107 30%, #FF8F00 90%)',
      color: 'black',
      border: 'none',
      boxShadow: '0 2px 5px rgba(255, 193, 7, 0.4)'
    };
  }

  return (
    <Tooltip title={isPremium ? `Vence: ${fechaFin}` : 'Plan Básico'}>
      <Chip 
        icon={icon} 
        label={planNombre} 
        size="small" 
        color={color}
        variant={variant}
        sx={sx}
      />
    </Tooltip>
  );
};

/**
 * TarjetaUsuario - Componente Principal
 */
const TarjetaUsuario = ({ user, onStatusChange, onDetailOpen, onAssignZone }) => {
  const theme = useTheme();
  const isSuspended = user.status === 'suspendido';

  return (
    <Card 
      elevation={0}
      sx={{ 
        height: '100%', 
        display: 'flex', 
        flexDirection: 'column',
        borderRadius: 3, // Bordes más redondeados
        border: `1px solid ${theme.palette.divider}`,
        transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
        position: 'relative',
        bgcolor: 'background.paper',
        // Efectos condicionales
        ...(isSuspended ? {
            opacity: 0.75,
            bgcolor: alpha(theme.palette.action.disabledBackground, 0.5),
        } : {
            '&:hover': { 
                transform: 'translateY(-4px)', // Efecto de elevación
                boxShadow: theme.shadows[8],
                borderColor: 'primary.main'
            }
        })
      }}
    >
      {/* 1. Encabezado */}
      <CardHeader
        avatar={
          <Avatar 
            sx={{ 
              bgcolor: isSuspended ? 'action.disabled' : 'primary.main', 
              color: 'white', 
              fontWeight: 800,
              width: 48, height: 48,
              boxShadow: 2,
              fontSize: '1.2rem'
            }}
          >
            {user.nombre ? user.nombre[0].toUpperCase() : '?'}
          </Avatar>
        }
        action={
          <IconButton onClick={() => onDetailOpen(user)} sx={{ color: 'text.secondary' }}>
            <MoreVertIcon />
          </IconButton>
        }
        title={
          <Typography variant="subtitle1" noWrap sx={{ fontWeight: 700, lineHeight: 1.2 }}>
            {user.nombre || 'Usuario Sin Nombre'}
          </Typography>
        }
        subheader={
          <Stack direction="row" alignItems="center" spacing={0.5} sx={{ mt: 0.5 }}>
            <EmailIcon sx={{ fontSize: 14, color: 'text.secondary' }} />
            <Typography variant="caption" color="text.secondary" noWrap sx={{ maxWidth: 140 }}>
               {user.email}
            </Typography>
          </Stack>
        }
        sx={{ pb: 1 }}
      />
      
      <Divider sx={{ mx: 2, opacity: 0.6 }} />

      {/* 2. Contenido Principal */}
      <CardContent sx={{ flexGrow: 1, pt: 2, pb: 1, display: 'flex', flexDirection: 'column', gap: 1.5 }}>
        
        {/* Fila: Rol y Estado */}
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
           <RoleChip role={user.rol} />
           <StatusChip status={user.status} />
        </Box>
        
        {/* Fila: Plan (Si existe) */}
        <Box>
          <PlanChip 
            planNombre={user.nombre_plan} 
            fechaFin={user.fecha_fin_suscripcion_formateada} 
          />
        </Box>

        {/* Fila: Fecha Registro (Al fondo) */}
        <Box sx={{ mt: 'auto' }}>
           <Typography variant="caption" display="block" color="text.disabled" sx={{ fontStyle: 'italic', fontSize: '0.7rem' }}>
             Registrado: {user.fecha_registro_formateada}
           </Typography>
        </Box>
        
      </CardContent>
      
      {/* 3. Acciones */}
      <Box sx={{ p: 2, pt: 0 }}>
        <Stack direction="row" spacing={1} alignItems="center">
          {/* Botón Principal (Suspender/Activar) */}
          <Box sx={{ flexGrow: 1 }}>
             {user.status === 'activo' ? (
              <BotonConfirmacionMantenida 
                onConfirm={() => onStatusChange(user.id, user.status)} 
                label="Suspender" 
                color="error" 
                variant="outlined" // Menos agresivo visualmente
                size="small"
                fullWidth
                startIcon={<BlockIcon />}
                sx={{ borderRadius: 2, textTransform: 'none', fontWeight: 600 }}
              />
            ) : (
              <BotonConfirmacionMantenida 
                onConfirm={() => onStatusChange(user.id, user.status)} 
                label="Reactivar" 
                color="success" 
                variant="contained"
                size="small"
                fullWidth
                startIcon={<CheckCircleIcon />}
                sx={{ borderRadius: 2, textTransform: 'none', fontWeight: 600, color: 'white' }}
              />
            )}
          </Box>
          
          {/* Botón Secundario (Asignar Zonas) - Solo líderes */}
          {user.rol === 'lider_vecinal' && (
            <Tooltip title="Gestionar Zonas">
              <IconButton 
                onClick={() => onAssignZone(user)} 
                color="primary" 
                sx={{ 
                  bgcolor: alpha(theme.palette.primary.main, 0.1), 
                  border: `1px solid ${alpha(theme.palette.primary.main, 0.2)}`,
                  borderRadius: 2,
                  '&:hover': { bgcolor: alpha(theme.palette.primary.main, 0.2) }
                }}
              >
                <MapIcon fontSize="small" />
              </IconButton>
            </Tooltip>
          )}
        </Stack>
      </Box>
    </Card>
  );
};

export default TarjetaUsuario;