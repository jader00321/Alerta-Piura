import React from 'react';
import { Paper, Typography, Box, Divider, Chip, Button, Stack, Skeleton } from '@mui/material';
import {
    Person as PersonIcon, Email as EmailIcon, Phone as PhoneIcon,
    CalendarToday as CalendarIcon, Info as InfoIcon, AccessAlarm as TimerIcon,
    ErrorOutline as AlertIcon, ContactPhone as ContactIcon // Icono para contacto emergencia
} from '@mui/icons-material';

// Reusable DetailItem
// eslint-disable-next-line no-unused-vars
const DetailItem = ({ icon: Icon, primary, secondary }) => (
    <Stack direction="row" spacing={1.5} alignItems="center" sx={{ py: 0.5 }}>
        <Icon fontSize="small" color="action" />
        <Box>
            <Typography variant="caption" color="text.secondary" sx={{ textTransform: 'uppercase', fontSize: '0.7rem' }}>
                {primary}
            </Typography>
            <Typography variant="body2" sx={{ wordBreak: 'break-word', fontWeight: 500 }}>
                {secondary || 'No especificado'}
            </Typography>
        </Box>
    </Stack>
);


function DetalleAlertaSeleccionada({ alert, timer, loading, onFinishAlert }) {

    if (loading) {
        return (
             <Paper sx={{ p: 2.5, minHeight: {xs: 'auto', md:'60vh'} }}>
                 <Skeleton variant="text" width="60%" height={30} />
                 <Skeleton variant="text" width="40%" height={20} sx={{mb: 2}}/>
                 <Divider sx={{ my: 2 }} />
                  <Skeleton variant="text" width="80%" />
                  <Skeleton variant="text" width="70%" />
                  <Skeleton variant="text" width="50%" />
                 <Divider sx={{ my: 2 }} />
                 <Skeleton variant="rectangular" width="100%" height={40} />
             </Paper>
        );
    }

    if (!alert) {
        return (
            <Paper sx={{ p: 3, display: 'flex', flexDirection:'column', alignItems: 'center', justifyContent: 'center', minHeight: {xs: 'auto', md:'60vh'}, textAlign: 'center' }}>
                <AlertIcon color="action" sx={{ fontSize: 50, mb: 2 }} />
                <Typography variant="h6" gutterBottom>No hay alerta seleccionada</Typography>
                <Typography color="text.secondary">Selecciona una alerta del historial o espera una nueva.</Typography>
            </Paper>
        );
    }

    const isActive = alert.estado === 'activo';
    let totalDuration = null;
    if (alert.estado === 'finalizado' && alert.fecha_fin && alert.fecha_inicio) {
        const diffSeconds = Math.floor((new Date(alert.fecha_fin) - new Date(alert.fecha_inicio)) / 1000);
        const min = Math.floor(diffSeconds / 60);
        const sec = diffSeconds % 60;
        totalDuration = `${min} min ${sec} seg`;
    }

    return (
        <Paper sx={{ p: 2.5, minHeight: {xs: 'auto', md:'60vh'}, display:'flex', flexDirection:'column' }} elevation={3}>
            {/* --- Info Principal --- */}
            <Typography variant="h5" sx={{ fontWeight: 'bold' }}>
                Detalle Alerta {/* Código AHORA aquí */}
                <Typography component="span" variant='h6' color="text.secondary" sx={{ml: 1}}>
                    #{alert.codigo_alerta}
                </Typography>
            </Typography>

            {isActive && timer && (
                <Chip
                    icon={<TimerIcon />}
                    label={`Tiempo Restante: ${timer}`}
                    color="error"
                    size="medium"
                    sx={{ mt: 1, mb: 2, fontWeight: 'bold', fontSize: '1rem' }}
                 />
            )}
            {!isActive && totalDuration && ( <Chip icon={<TimerIcon />} label={`Duración Total: ${totalDuration}`} color="default" size="small" sx={{mt: 1, mb: 2}}/> )}
            {!isActive && !totalDuration && alert.fecha_fin && ( // Muestra fecha fin si no se puede calcular duración
                 <Typography variant="caption" color="text.secondary" sx={{mt: 1, mb: 2}}>
                    Finalizada: {new Date(alert.fecha_fin).toLocaleString()}
                 </Typography>
            )}

            <Divider sx={{ my: 0.5 }} />

            {/* --- Detalles Usuario --- */}
            <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1 }}>Usuario</Typography>
            <Stack spacing={1} sx={{mb: 2}}>
                {/* Asegurarse que se muestren los datos correctos del 'alert' actual */}
                <DetailItem icon={PersonIcon} primary="Nombre / Alias" secondary={`${alert.alias || alert.nombre || '?'} (${alert.rol || 'N/A'})`} />
                <DetailItem icon={EmailIcon} primary="Email" secondary={alert.email} />
                <DetailItem icon={PhoneIcon} primary="Teléfono" secondary={alert.telefono} />
            </Stack>
            <Divider sx={{ my: 0.5 }} />

            {/* --- Detalles Alerta --- */}
             <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1 }}>Detalles de la Alerta</Typography>
            <Stack spacing={1} sx={{mb: 2}}>
                <DetailItem icon={CalendarIcon} primary="Fecha de Inicio" secondary={new Date(alert.fecha_inicio).toLocaleString()} />
                 <DetailItem icon={InfoIcon} primary="Estado" secondary={alert.estado} />
                 <DetailItem icon={InfoIcon} primary="Atención" secondary={alert.estado_atencion} />
            </Stack>
            <Divider sx={{ my: 0.5 }} />

             {/* --- NUEVO: Contacto de Emergencia --- */}
             <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1 }}>Contacto de Emergencia</Typography>
            <Stack spacing={1}>
                <DetailItem icon={ContactIcon} primary="Teléfono Contacto" secondary={alert.contacto_emergencia_telefono} />
                <DetailItem icon={InfoIcon} primary="Mensaje Predefinido" secondary={alert.contacto_emergencia_mensaje || '(Ninguno)'} />
            </Stack>


            {/* Botón Finalizar */}
            <Box sx={{ mt: 'auto', pt: 3 }}>
                <Button fullWidth variant="contained" color={!isActive ? 'inherit' : 'error'} onClick={() => onFinishAlert(alert.id)} disabled={!isActive} >
                    {isActive ? 'Finalizar Alerta SOS' : 'Alerta Finalizada'}
                </Button>
            </Box>
        </Paper>
    );
}

export default DetalleAlertaSeleccionada;