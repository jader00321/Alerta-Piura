// src/components/SOS/DetalleAlertaSeleccionada.jsx
import React from 'react';
import { Paper, Typography, Box, Chip, Button, Stack, Skeleton, Avatar, useTheme, alpha } from '@mui/material';
import {
    Person as PersonIcon, Email as EmailIcon, Phone as PhoneIcon,
    CalendarToday as CalendarIcon, Info as InfoIcon, AccessAlarm as TimerIcon,
    ErrorOutline as AlertIcon, ContactPhone as ContactIcon, Tag as TagIcon,
    MedicalServices as StatusIcon // Nuevo icono para estado de atención
} from '@mui/icons-material';

// Helper para colores de Estado de Atención
const getAttentionStatusConfig = (status, theme) => {
    const s = status ? status.toLowerCase() : '';
    if (s.includes('espera')) return { color: theme.palette.error.main, bg: alpha(theme.palette.error.main, 0.1), label: status };
    if (s.includes('curso') || s.includes('atendiendo')) return { color: theme.palette.warning.main, bg: alpha(theme.palette.warning.main, 0.1), label: status };
    if (s.includes('atendida') || s.includes('final')) return { color: theme.palette.success.main, bg: alpha(theme.palette.success.main, 0.1), label: status };
    return { color: theme.palette.text.secondary, bg: theme.palette.action.hover, label: status || 'N/A' };
};

const DetailRow = ({ icon, label, value, highlight = false, customValueComponent = null }) => {
    const theme = useTheme();
    return (
        <Stack direction="row" spacing={1.5} alignItems="center" sx={{ py: 0.5 }}> {/* Padding vertical reducido */}
            <Avatar sx={{ 
                width: 28, height: 28, // Avatar más pequeño
                bgcolor: highlight ? alpha(theme.palette.error.main, 0.1) : 'action.hover', 
                color: highlight ? theme.palette.error.main : 'text.secondary' 
            }}>
                {React.cloneElement(icon, { fontSize: 'small', style: { fontSize: 16 } })}
            </Avatar>
            <Box sx={{ overflow: 'hidden', flexGrow: 1 }}>
                <Typography variant="caption" display="block" color="text.secondary" fontWeight="bold" fontSize="0.65rem">
                    {label.toUpperCase()}
                </Typography>
                {customValueComponent ? (
                    customValueComponent
                ) : (
                    <Typography variant="body2" fontWeight={500} noWrap fontSize="0.85rem">
                        {value || 'N/A'}
                    </Typography>
                )}
            </Box>
        </Stack>
    );
};

function DetalleAlertaSeleccionada({ alert, timer, loading, onFinishAlert }) {
    const theme = useTheme();

    if (loading) {
        return (
             <Paper sx={{ p: 2, height: '100%', borderRadius: 2 }}>
                 <Skeleton variant="text" width="50%" height={30} />
                 <Skeleton variant="rectangular" width="100%" height={150} sx={{ my: 1, borderRadius: 1 }} />
                 <Skeleton variant="rectangular" width="100%" height={40} sx={{ borderRadius: 1 }} />
             </Paper>
        );
    }

    if (!alert) {
        return (
            <Paper sx={{ p: 3, height: '100%', display: 'flex', flexDirection:'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', borderRadius: 2 }}>
                <Avatar sx={{ width: 60, height: 60, bgcolor: 'action.hover', mb: 1.5 }}>
                    <AlertIcon sx={{ fontSize: 30, color: 'text.disabled' }} />
                </Avatar>
                <Typography variant="subtitle1" fontWeight="bold" gutterBottom>Sin Selección</Typography>
                <Typography variant="caption" color="text.secondary">Selecciona una alerta para ver detalles.</Typography>
            </Paper>
        );
    }

    const isActive = alert.estado === 'activo';
    const attentionConfig = getAttentionStatusConfig(alert.estado_atencion, theme);

    // Calcular duración si finalizó
    let totalDuration = null;
    if (!isActive && alert.fecha_fin && alert.fecha_inicio) {
        const diffSeconds = Math.floor((new Date(alert.fecha_fin) - new Date(alert.fecha_inicio)) / 1000);
        const min = Math.floor(diffSeconds / 60);
        const sec = diffSeconds % 60;
        totalDuration = `${min}m ${sec}s`;
    }

    return (
        <Paper elevation={0} sx={{ p: 0, height: '100%', display:'flex', flexDirection:'column', borderRadius: 2, border: `1px solid ${theme.palette.divider}`, overflow: 'hidden' }}>
            
            {/* Encabezado Compacto */}
            <Box sx={{ p: 2, bgcolor: isActive ? alpha(theme.palette.error.main, 0.05) : 'background.paper', borderBottom: `1px solid ${theme.palette.divider}` }}>
                <Stack direction="row" justifyContent="space-between" alignItems="center" mb={0.5}>
                    <Chip 
                        icon={<TagIcon style={{fontSize: 12}}/>} 
                        label={alert.codigo_alerta} 
                        size="small" 
                        sx={{ fontWeight: 'bold', height: 20, fontSize: '0.7rem', bgcolor: 'background.paper', border: `1px solid ${theme.palette.divider}` }} 
                    />
                    {isActive ? (
                        <Chip label="EN CURSO" color="error" size="small" sx={{ fontWeight: 'bold', height: 20, fontSize: '0.65rem' }} />
                    ) : (
                        <Chip label="FINALIZADA" size="small" variant="outlined" sx={{ height: 20, fontSize: '0.65rem' }} />
                    )}
                </Stack>
                <Box display="flex" justifyContent="space-between" alignItems="flex-end">
                    <Typography variant="h6" fontWeight="800" fontSize="1.1rem">
                        Detalles del Incidente
                    </Typography>
                    {isActive && timer && (
                        <Typography variant="h5" color="error.main" fontWeight="bold" sx={{ fontFamily: 'monospace', lineHeight: 1 }}>
                            {timer}
                        </Typography>
                    )}
                </Box>
            </Box>

            {/* Cuerpo Scrollable */}
            <Box sx={{ p: 2, flexGrow: 1, overflowY: 'auto' }}>
                <Stack spacing={2}>
                    
                    {/* Sección Usuario */}
                    <Box>
                        <Typography variant="caption" color="text.secondary" fontWeight="bold" mb={0.5} display="block">USUARIO REPORTANTE</Typography>
                        <Paper variant="outlined" sx={{ p: 1.5, borderRadius: 1.5 }}>
                            <DetailRow icon={<PersonIcon />} label="Nombre" value={`${alert.alias || alert.nombre} (${alert.rol})`} />
                            <DetailRow icon={<PhoneIcon />} label="Teléfono" value={alert.telefono} />
                            <DetailRow icon={<EmailIcon />} label="Email" value={alert.email} />
                        </Paper>
                    </Box>

                    {/* Sección Detalles del Evento */}
                    <Box>
                        <Typography variant="caption" color="text.secondary" fontWeight="bold" mb={0.5} display="block">ESTADO DEL EVENTO</Typography>
                        <Paper variant="outlined" sx={{ p: 1.5, borderRadius: 1.5 }}>
                            <DetailRow icon={<CalendarIcon />} label="Inicio" value={new Date(alert.fecha_inicio).toLocaleString()} />
                            
                            {/* --- AQUÍ ESTÁ EL ESTADO DE ATENCIÓN COLOREADO --- */}
                            <DetailRow 
                                icon={<StatusIcon />} 
                                label="Estado Atención" 
                                customValueComponent={
                                    <Chip 
                                        label={attentionConfig.label} 
                                        size="small" 
                                        sx={{ 
                                            bgcolor: attentionConfig.bg, 
                                            color: attentionConfig.color, 
                                            fontWeight: 'bold', 
                                            height: 20, 
                                            fontSize: '0.75rem',
                                            mt: 0.5,
                                            border: `1px solid ${alpha(attentionConfig.color, 0.2)}`
                                        }} 
                                    />
                                }
                            />

                            {!isActive && (
                                <Stack direction="row" spacing={2}>
                                    <Box flex={1}><DetailRow icon={<TimerIcon />} label="Duración" value={totalDuration} /></Box>
                                    <Box flex={1}><DetailRow icon={<CalendarIcon />} label="Fin" value={new Date(alert.fecha_fin).toLocaleTimeString()} /></Box>
                                </Stack>
                            )}
                        </Paper>
                    </Box>

                    {/* Sección Contacto Emergencia */}
                    <Box>
                        <Typography variant="caption" color="text.secondary" fontWeight="bold" mb={0.5} display="block">CONTACTO DE EMERGENCIA</Typography>
                        <Paper variant="outlined" sx={{ p: 1.5, borderRadius: 1.5, bgcolor: alpha(theme.palette.info.main, 0.03), borderColor: alpha(theme.palette.info.main, 0.2) }}>
                            <DetailRow icon={<ContactIcon />} label="Teléfono" value={alert.contacto_emergencia_telefono} />
                            <Box mt={1}>
                                <Typography variant="caption" color="text.secondary" fontWeight="bold" fontSize="0.6rem">MENSAJE PREDEFINIDO</Typography>
                                <Typography variant="body2" sx={{ fontStyle: 'italic', color: 'text.primary', fontSize: '0.8rem' }}>
                                    "{alert.contacto_emergencia_mensaje || 'Sin mensaje'}"
                                </Typography>
                            </Box>
                        </Paper>
                    </Box>

                </Stack>
            </Box>

            {/* Pie con Botón de Acción */}
            <Box sx={{ p: 2, borderTop: `1px solid ${theme.palette.divider}`, bgcolor: 'background.paper' }}>
                <Button 
                    fullWidth 
                    variant="contained" 
                    color={isActive ? 'error' : 'inherit'} 
                    size="medium" // Botón tamaño normal
                    onClick={() => onFinishAlert(alert.id)} 
                    disabled={!isActive}
                    sx={{ 
                        py: 1, 
                        fontWeight: 'bold', 
                        fontSize: '0.9rem',
                        boxShadow: isActive ? 3 : 0,
                        opacity: isActive ? 1 : 0.6
                    }}
                >
                    {isActive ? 'FINALIZAR EMERGENCIA' : 'Emergencia Cerrada'}
                </Button>
            </Box>
        </Paper>
    );
}

export default DetalleAlertaSeleccionada;