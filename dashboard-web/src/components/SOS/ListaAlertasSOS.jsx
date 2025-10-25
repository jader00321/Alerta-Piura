// src/components/SOS/ListaAlertasSOS.jsx
import React from 'react';
import {
    List, ListItemButton, ListItemText, Typography, Box, Chip,
    Skeleton, Paper, Stack, IconButton, Tooltip, ButtonGroup, Button, useTheme // useTheme added
} from '@mui/material';
import {
    Warning as WarningIcon, CheckCircle as CheckIcon, AccessTime as TimeIcon,
    RadioButtonChecked as ActiveIcon, // En Espera activo
    RadioButtonUnchecked as WaitingIcon, // En Espera inactivo
    Autorenew as InProgressIcon, DoneAll as AttendedIcon,
    Visibility as VisibleIcon, VisibilityOff as NotVisibleIcon // Revisada
} from '@mui/icons-material';

// --- EstadoAlertaChip (Sin cambios) ---
const EstadoAlertaChip = ({ estado }) => {
    const active = estado === 'activo';
    return <Chip
             label={active ? 'Activa' : 'Finalizada'}
             color={active ? 'error' : 'default'} // Activa ahora es error
             size="small"
             icon={active ? <WarningIcon /> : <CheckIcon />}
             variant="filled"
             sx={{ mr: 1, color: active ? '#fff' : 'text.primary', fontWeight:'bold' }}
            />;
};

// --- EstadoAtencionControl (Estilos ajustados) ---
const EstadoAtencionControl = ({ estado, alertId, onChange }) => {
    const theme = useTheme();
    const statuses = [
        { value: 'En Espera', icon: <WaitingIcon />, color: 'error', activeIcon: <ActiveIcon sx={{color: theme.palette.error.contrastText}}/> }, // Icono activo blanco
        { value: 'En Curso', icon: <InProgressIcon />, color: 'warning', activeIcon: <InProgressIcon sx={{color: theme.palette.warning.contrastText}}/> }, // Icono activo más oscuro/negro
        { value: 'Atendida', icon: <AttendedIcon />, color: 'success', activeIcon: <AttendedIcon sx={{color: theme.palette.success.contrastText}}/> }, // Icono activo blanco
    ];
    const currentStatusValue = estado || 'En Espera';

    return (
        <ButtonGroup variant="outlined" size="small" aria-label="Estado de atención SOS">
           {statuses.map(s => {
               const isSelected = currentStatusValue === s.value;
               return (
                   <Tooltip title={s.value} key={s.value}>
                       <Button
                         onClick={(e) => { e.stopPropagation(); onChange(alertId, s.value); }}
                         color={s.color}
                         variant={isSelected ? 'contained' : 'outlined'}
                         sx={{
                             minWidth: 40, px: 1,
                             // FIX: Reduce sombra y ajusta color si está 'contained' para diferenciarlo
                             boxShadow: isSelected ? 'none' : undefined, // Sin sombra si seleccionado
                             // Opcional: Ajustar ligeramente el fondo si es 'contained'
                             // bgcolor: isSelected ? theme.palette[s.color].dark : undefined
                             // Opcional: Asegurar contraste del icono
                             '& .MuiButton-startIcon': { color: isSelected ? theme.palette[s.color].contrastText : theme.palette[s.color].main }
                         }}
                         // Mostrar icono activo o inactivo
                         startIcon={isSelected ? s.activeIcon : s.icon}
                       >
                         {/* Opcional: Mostrar texto en botones si hay espacio */}
                         {/* {s.value} */}
                       </Button>
                   </Tooltip>
               );
           })}
        </ButtonGroup>
    );
};


function ListaAlertasSOS({ alerts, selectedAlertId, loading, onSelectAlert, onAttentionChange }) {

    if (loading) {
        return (
            <Paper variant="outlined">
                <Stack spacing={1} sx={{ p: 1 }}>
                    {[...Array(5)].map((_, i) => <Skeleton key={i} variant="rounded" height={80} />)}
                </Stack>
            </Paper>
        );
    }

    if (!alerts || alerts.length === 0) {
        return (
            <Paper variant="outlined" sx={{ p: 3, textAlign: 'center', borderStyle: 'dashed', bgcolor: 'action.hover' }}>
                <Typography color="text.secondary">No hay historial de alertas SOS.</Typography>
            </Paper>
        );
    }

    return (
        <Paper variant="outlined">
            <List sx={{ p: 0, maxHeight: { xs: '50vh', md: '75vh' }, overflowY: 'auto' }}> {/* Altura adaptable */}
                {alerts.map((alert, index) => (
                    <ListItemButton
                        key={alert.id}
                        selected={selectedAlertId === alert.id}
                        onClick={() => onSelectAlert(alert)}
                        divider={index < alerts.length - 1}
                        sx={{
                            py: 1.5,
                            bgcolor: !alert.revisada ? 'warning.lighter' : 'inherit',
                             '&.Mui-selected': { bgcolor: 'action.selected', '&:hover': { bgcolor: 'action.selected' } }
                        }}
                        alignItems="flex-start" // Alinear items al inicio
                    >
                        <ListItemText
                            disableTypography // Permite estructura personalizada
                            primary={
                                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
                                    <Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap">
                                        <EstadoAlertaChip estado={alert.estado} />
                                        <Typography variant="body1" sx={{ fontWeight: 'bold' }}>
                                            {alert.alias || alert.nombre}
                                        </Typography>
                                         {!alert.revisada && <Chip label="Nueva" color="warning" size="small" sx={{ml:1, height: 'auto'}}/>}
                                    </Stack>
                                    <Typography variant="caption" color="text.secondary" sx={{ flexShrink: 0, ml: 1 }}>
                                        {new Date(alert.fecha_inicio).toLocaleString()}
                                    </Typography>
                                </Box>
                            }
                            secondary={
                                // Usar Stack vertical para organizar la info secundaria
                                <Stack spacing={1} sx={{ mt: 0.5 }}>
                                     <Stack direction={{xs:'column', sm:'row'}} justifyContent="space-between" alignItems={{xs:'flex-start', sm:'center'}} spacing={1}>
                                         <Typography variant="body2" color="text.secondary" sx={{fontSize:'0.8rem'}}>
                                             Código: <strong>{alert.codigo_alerta}</strong>
                                         </Typography>
                                          <Tooltip title={alert.revisada ? "Alerta ya revisada" : "Alerta NUEVA (no revisada)"}>
                                             <Chip
                                                 icon={alert.revisada ? <VisibleIcon/> : <NotVisibleIcon/>}
                                                 label={alert.revisada ? "Revisada" : "Nueva"}
                                                 size="small"
                                                 color={alert.revisada ? "default" : "warning"}
                                                 variant="outlined"
                                             />
                                         </Tooltip>
                                     </Stack>
                                     {/* Información de Contacto */}
                                     <Box>
                                        <Typography variant="caption" color="text.secondary">
                                            Contacto Emergencia: {alert.contacto_emergencia_telefono || 'N/A'}
                                        </Typography>
                                        <Tooltip title={alert.contacto_emergencia_mensaje || ''}>
                                             <Typography variant="caption" color="text.secondary" noWrap display="block">
                                                 Mensaje: {alert.contacto_emergencia_mensaje || 'N/A'}
                                             </Typography>
                                        </Tooltip>
                                     </Box>
                                     {/* Controles de Atención */}
                                     <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 1 }}>
                                        <EstadoAtencionControl
                                            estado={alert.estado_atencion}
                                            alertId={alert.id}
                                            onChange={onAttentionChange}
                                        />
                                    </Box>
                                </Stack>
                            }
                        />
                    </ListItemButton>
                ))}
            </List>
        </Paper>
    );
}

export default ListaAlertasSOS;