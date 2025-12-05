/* eslint-disable no-unused-vars */
// src/components/Resumen/ModalDetalleReporteResumen.jsx

/**
 * Componente: ModalDetalleReporteResumen
 * ---
 * Versión Optimizada: Diseño limpio manteniendo estructura original.
 */

import React from 'react';
import {
    Dialog, DialogTitle, DialogContent, DialogActions, Button, Typography, Box,
    Grid, Chip, Divider, Paper, Stack, IconButton, Tooltip, useTheme, alpha
} from '@mui/material';
import { MapContainer, TileLayer, Marker } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import {
    Close as CloseIcon, CheckCircle as ApproveIcon, Cancel as RejectIcon,
    Person as PersonIcon, Email as EmailIcon, Phone as PhoneIcon,
    Category as CategoryIcon, PriorityHigh as PriorityHighIcon, CalendarToday as CalendarIcon,
    AccessTime as TimeIcon, PinDrop as PinDropIcon, Place as ReferenceIcon,
    People as ImpactIcon, Label as TagIcon, Launch as LaunchIcon,
    Star as StarIcon, WorkspacePremium as PremiumIcon,
    Image as ImageIcon
} from '@mui/icons-material';

/* --- Configuración de Leaflet --- */
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
    iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
    iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
    shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});

/* --- Subcomponentes --- */

const DetailItem = ({ icon: Icon, primary, secondary }) => {
    const theme = useTheme();
    return (
        <Stack direction="row" spacing={2} alignItems="center" sx={{ py: 1 }}>
            <Box sx={{ 
                color: 'primary.main', 
                bgcolor: alpha(theme.palette.primary.main, 0.1), 
                p: 0.5, borderRadius: 1, display: 'flex' 
            }}>
                <Icon fontSize="small" />
            </Box> 
            <Box>
                <Typography variant="caption" color="text.secondary" sx={{ textTransform: 'uppercase', fontSize: '0.7rem', fontWeight: 'bold', letterSpacing: 0.5 }}>
                    {primary} 
                </Typography>
                <Typography variant="body2" sx={{ wordBreak: 'break-word', fontWeight: 500 }}>
                    {secondary || 'No especificado'} 
                </Typography> 
            </Box> 
        </Stack>
    );
};

const PlanChip = ({ planNombre }) => {
    let config = { icon: <StarIcon />, label: planNombre || 'Gratuito', color: 'default', variant: 'outlined' };
    const isPremium = planNombre && planNombre !== 'Plan Gratuito';

    if (isPremium) {
        config.variant = 'filled';
        if (planNombre?.includes('Reportero')) {
            config.color = 'info';
        } else {
            config.color = 'warning';
            config.icon = <PremiumIcon />;
        }
    }
    return <Chip {...config} size="small" sx={{ fontWeight: isPremium ? 'bold' : 'normal', height: 24 }} />;
};

/* --- Componente Principal --- */

function ModalDetalleReporteResumen({ report, open, onClose, onAction, readOnly = false }) {
    const theme = useTheme();
    
    if (!report) return null;

    /* --- Configuración Mapa --- */
    const locationCoords = report.location?.coordinates
        ? [report.location.coordinates[1], report.location.coordinates[0]]
        : null;
    const googleMapsUrl = locationCoords
        ? `https://www.google.com/maps?q=${locationCoords[0]},${locationCoords[1]}`
        : null;

    const handleAction = (approve) => {
        onAction(report.id, approve);
        onClose();
    };

    return (
        <Dialog 
            open={open} 
            onClose={onClose} 
            fullWidth 
            maxWidth="md" 
            scroll="paper"
            PaperProps={{ sx: { borderRadius: 3, overflow: 'hidden' } }}
        >
            {/* ---------------------------- Encabezado ---------------------------- */}
            <DialogTitle sx={{ 
                borderBottom: `1px solid ${theme.palette.divider}`, 
                pb: 2, pt: 2.5, px: 3,
                bgcolor: 'background.paper'
            }}>
                <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}> 
                    <Stack>
                        <Stack direction="row" spacing={1} alignItems="center" mb={0.5}>
                            <Typography variant="overline" color="text.secondary" fontWeight="bold" lineHeight={1}>
                                DETALLE DEL REPORTE
                            </Typography>
                            {report.codigo_reporte && (
                                <Chip label={report.codigo_reporte} size="small" variant="outlined" sx={{ height: 20, fontSize: '0.65rem', fontWeight: 'bold' }} />
                            )}
                        </Stack>
                        
                        {report.es_prioritario && (
                            <Tooltip title="Reporte Prioritario (Premium)">
                                <Chip
                                    icon={<StarIcon style={{fontSize: 16}} />}
                                    label="Prioritario"
                                    color="warning"
                                    size="small"
                                    variant="filled"
                                    sx={{ fontWeight: 'bold', width: 'fit-content', mb: 1 }}
                                /> 
                            </Tooltip>
                        )}
                        
                        <Typography variant="h5" fontWeight="800" sx={{ lineHeight: 1.2 }}>
                            {report.titulo}
                        </Typography>
                    </Stack> 
                    <IconButton onClick={onClose} sx={{ bgcolor: 'action.hover' }}><CloseIcon /></IconButton> 
                </Box> 
            </DialogTitle>
            <Divider sx={{ mb: 0 }} />            
            {/* ----------------------------- Contenido ---------------------------- */}
            <DialogContent sx={{ bgcolor: 'background.default', p: 3 }}>
                <Stack spacing={3}>
                    
                    {/* 1. Categoría y Estado */}
                    <Paper elevation={0} sx={{ p: 2, borderRadius: 2, border: `1px solid ${theme.palette.divider}` }}>
                        <Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap" gap={1}>
                            <Chip 
                                icon={<CategoryIcon />} 
                                label={report.categoria} 
                                sx={{ bgcolor: alpha(theme.palette.primary.main, 0.1), color: 'primary.main', fontWeight: 'bold' }} 
                            />
                            <Chip
                                label={`Urgencia: ${report.urgencia || 'N/A'}`}
                                color={report.urgencia === 'Alta' ? 'error' : (report.urgencia === 'Media' ? 'warning' : 'default')}
                                size="medium"
                                variant="filled" // Relleno para destacar urgencia
                                icon={<PriorityHighIcon />}
                                sx={{ fontWeight: 'bold' }}
                            />
                        </Stack>
                    </Paper>

                    {/* 2. Imagen */}
                    {report.foto_url && (
                        <Paper elevation={0} sx={{ overflow: 'hidden', borderRadius: 2, border: `1px solid ${theme.palette.divider}` }}>
                            <Box sx={{ position: 'relative' }}>
                                <Box component="img" src={report.foto_url} alt="Evidencia"
                                    sx={{ width: '100%', maxHeight: 400, objectFit: 'contain', display: 'block', bgcolor: '#000' }} 
                                />
                                <Box sx={{ position: 'absolute', bottom: 10, left: 10, bgcolor: 'rgba(0,0,0,0.6)', color: 'white', px: 1, borderRadius: 1, display: 'flex', alignItems: 'center', gap: 0.5 }}>
                                    <ImageIcon fontSize="small" /> <Typography variant="caption">Evidencia Fotográfica</Typography>
                                </Box>
                            </Box>
                        </Paper>
                    )}

                    {/* 3. Descripción */}
                    <Paper elevation={0} sx={{ p: 3, borderRadius: 2, border: `1px solid ${theme.palette.divider}` }}>
                        <Typography variant="subtitle2" color="text.secondary" fontWeight="bold" gutterBottom>DESCRIPCIÓN DEL INCIDENTE</Typography>
                        <Typography variant="body1" sx={{ whiteSpace: 'pre-wrap', lineHeight: 1.6 }}>
                            {report.descripcion || 'No se proporcionó descripción.'}
                        </Typography>
                        
                        <Divider sx={{ my: 2 }} />
                        
                        <Typography variant="subtitle2" color="text.secondary" fontWeight="bold" gutterBottom>DETALLES TÉCNICOS</Typography>
                        <Grid container spacing={2}>
                            <Grid item xs={12} sm={6}>
                                <DetailItem icon={CalendarIcon} primary="Fecha" secondary={report.fecha_creacion_formateada || new Date(report.fecha_creacion).toLocaleString()} />
                            </Grid>
                            <Grid item xs={12} sm={6}><DetailItem icon={TimeIcon} primary="Hora" secondary={report.hora_incidente} /></Grid>
                            <Grid item xs={12} sm={6}><DetailItem icon={ImpactIcon} primary="Impacto" secondary={report.impacto} /></Grid>
                            <Grid item xs={12} sm={6}><DetailItem icon={TagIcon} primary="Etiquetas" secondary={report.tags?.join(', ') || 'Ninguna'} /></Grid>
                        </Grid>
                    </Paper>

                    {/* 4. Mapa */}
                    <Paper elevation={0} sx={{ p: 3, borderRadius: 2, border: `1px solid ${theme.palette.divider}` }}>
                        <Typography variant="subtitle2" color="text.secondary" fontWeight="bold" gutterBottom>UBICACIÓN GEOGRÁFICA</Typography>
                        {locationCoords ? (
                            <>
                                <Box sx={{ height: 300, width: '100%', borderRadius: 2, overflow: 'hidden', mb: 2, border: `1px solid ${theme.palette.divider}` }}>
                                    <MapContainer center={locationCoords} zoom={16} style={{ height: '100%', width: '100%' }} scrollWheelZoom={false}>
                                        <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                                        <Marker position={locationCoords} />
                                    </MapContainer>
                                </Box>
                                <Grid container spacing={2}>
                                    <Grid item xs={12} sm={6}><DetailItem icon={PinDropIcon} primary="Distrito" secondary={report.distrito} /></Grid>
                                    <Grid item xs={12} sm={6}><DetailItem icon={ReferenceIcon} primary="Referencia" secondary={report.referencia_ubicacion} /></Grid>
                                </Grid>
                                {googleMapsUrl && (
                                    <Button size="small" href={googleMapsUrl} target="_blank" rel="noopener noreferrer" startIcon={<LaunchIcon />} sx={{ mt: 1 }}>
                                        Abrir en Google Maps
                                    </Button>
                                )}
                            </>
                        ) : (
                            <Box p={4} textAlign="center" bgcolor="action.hover" borderRadius={2}>
                                <Typography color="text.secondary" variant="body2">Ubicación no disponible.</Typography>
                            </Box>
                        )}
                    </Paper>

                    {/* 5. Autor */}
                    <Paper elevation={0} sx={{ p: 3, borderRadius: 2, border: `1px solid ${theme.palette.divider}` }}>
                        <Typography variant="subtitle2" color="text.secondary" fontWeight="bold" gutterBottom>INFORMACIÓN DEL AUTOR</Typography>
                        <Stack spacing={1}>
                            <DetailItem icon={PersonIcon} primary="Nombre / Alias" secondary={report.autor_nombre || report.autor_alias || (report.es_anonimo ? 'Anónimo' : 'No especificado')} />
                            {!report.es_anonimo && (
                                <Stack direction="row" spacing={2} alignItems="center" sx={{ py: 1 }}>
                                    <Box sx={{ color: 'warning.main', bgcolor: alpha(theme.palette.warning.main, 0.1), p: 0.5, borderRadius: 1, display: 'flex' }}>
                                        <PremiumIcon fontSize="small" />
                                    </Box>
                                    <Box>
                                        <Typography variant="caption" color="text.secondary" sx={{ textTransform: 'uppercase', fontSize: '0.7rem', fontWeight: 'bold' }}>PLAN</Typography>
                                        <Box mt={0.5}><PlanChip planNombre={report.nombre_plan_autor} /></Box>
                                    </Box>
                                </Stack>
                            )}
                            {!report.es_anonimo && <DetailItem icon={EmailIcon} primary="Email" secondary={report.autor_email} />}
                            {!report.es_anonimo && <DetailItem icon={PhoneIcon} primary="Teléfono" secondary={report.autor_telefono} />}
                            
                            <Box pt={1}>
                                <Chip label={report.es_anonimo ? 'Reporte Anónimo' : 'Reporte Público'} size="small" color={report.es_anonimo ? 'default' : 'success'} variant="outlined" sx={{ fontWeight: 'bold' }} />
                            </Box>
                        </Stack>
                    </Paper>
                </Stack>
            </DialogContent>

            {/* ----------------------------- Acciones ---------------------------- */}
            {!readOnly && report.estado === 'pendiente_verificacion' && (
                <DialogActions sx={{ p: 3, borderTop: `1px solid ${theme.palette.divider}` }}>
                    <Button onClick={onClose} size="large" color="inherit" sx={{ mr: 'auto' }}>Cancelar</Button>
                    
                    <Stack direction="row" spacing={2}>
                        <Button 
                            variant="outlined" 
                            color="error" 
                            onClick={() => handleAction(false)} 
                            startIcon={<RejectIcon />}
                            sx={{ px: 3 }}
                        >
                            Rechazar
                        </Button>
                        <Button 
                            variant="contained" 
                            color="success" 
                            onClick={() => handleAction(true)} 
                            startIcon={<ApproveIcon />}
                            sx={{ px: 3, fontWeight: 'bold', boxShadow: 2 }}
                        >
                            Aprobar Publicación
                        </Button>
                    </Stack>
                </DialogActions>
            )}
            
            {/* Botón de cierre simple si es solo lectura o no está pendiente */}
            {(readOnly || report.estado !== 'pendiente_verificacion') && (
                 <DialogActions sx={{ p: 2 }}>
                    <Button onClick={onClose} color="inherit">Cerrar</Button>
                 </DialogActions>
            )}
        </Dialog>
    );
}

export default ModalDetalleReporteResumen;