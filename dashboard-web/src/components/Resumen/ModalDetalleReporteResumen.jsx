// src/components/Resumen/ModalDetalleReporteResumen.jsx
import React from 'react';
import {
    Dialog, DialogTitle, DialogContent, DialogActions, Button, Typography, Box,
    Grid, Chip, Divider, Paper, Stack, IconButton, Tooltip, Link as MuiLink 
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
    Star as StarIcon, WorkspacePremium as PremiumIcon
} from '@mui/icons-material';

// Fix Leaflet Icon (sin cambios)
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});

// --- DetailItem CORREGIDO ---
// eslint-disable-next-line no-unused-vars
const DetailItem = ({ icon: Icon, primary, secondary }) => ( // Use 'icon: Icon'
    <Stack direction="row" spacing={1.5} alignItems="flex-start" sx={{ py: 0.8 }}>
        {/* FIX: Use the capitalized 'Icon' variable */}
        <Box sx={{ mt: 0.3 }}><Icon fontSize="small" color="action" /></Box>
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

const PlanChip = ({ planNombre }) => {
    let config = { icon: <StarIcon />, label: planNombre || 'Gratuito', color: 'default', variant: 'outlined' };
    const isPremium = planNombre && planNombre !== 'Plan Gratuito';

    if (isPremium) {
        config.variant = 'filled';
        // Ajusta colores/iconos basados en nombres específicos si es necesario
        if (planNombre?.includes('Reportero')) {
            config.color = 'info';
            // config.icon = <ReporteroIcon />; // Opcional: icono específico
        } else { // Asume Ciudadano Premium u otro premium
            config.color = 'warning';
            config.icon = <PremiumIcon />;
        }
    }
    return <Chip {...config} size="small" sx={{ fontWeight: isPremium ? 'bold' : 'normal' }}/>;
};

function ModalDetalleReporteResumen({ report, open, onClose, onAction }) {
  //const theme = useTheme(); // Hook para colores
  if (!report) return null;

  const locationCoords = (report.location?.coordinates)
    ? [report.location.coordinates[1], report.location.coordinates[0]]
    : null;
  const googleMapsUrl = locationCoords ? `https://www.google.com/maps?q=${locationCoords[0]},${locationCoords[1]}` : null;


  const handleAction = (approve) => {
    onAction(report.id, approve);
    onClose();
  };

  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="md" scroll="paper">
        <DialogTitle sx={{ borderBottom: 1, borderColor: 'divider', pb: 1.5 }}>
            <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                 <Stack direction="row" spacing={1.5} alignItems="center">
                     <Stack>
                         Detalle del Reporte
                         {report.codigo_reporte &&
                            <Typography variant="caption" color="text.secondary">
                                #{report.codigo_reporte}
                            </Typography>}
                     </Stack>
                     {report.es_prioritario && (
                        <Tooltip title="Reporte Prioritario (Premium)">
                             <Chip
                                icon={<StarIcon />}
                                label="Prioritario"
                                color="warning"
                                size="small"
                                variant="filled"
                                sx={{ fontWeight:'bold'}}
                             />
                        </Tooltip>
                     )}
                 </Stack>
                 <IconButton onClick={onClose}><CloseIcon /></IconButton>
            </Box>
        </DialogTitle>

        {/* --- Contenido Principal (Scrollable) --- */}
        <DialogContent sx={{ bgcolor: 'background.default', p: { xs: 1.5, sm: 2, md: 2.5} }}>
            <Divider sx={{ mb: 2 }} />
            <Stack spacing={2.5}> {/* Espaciado entre secciones */}

                {/* Sección Título y Chips */}
                 <Paper variant="outlined" sx={{ p: 2 }}>
                    <Typography variant="h5" gutterBottom sx={{ fontWeight: 'bold' }}>{report.titulo}</Typography>
                    <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
                        <Chip label={report.categoria} color="primary" size="small" variant="filled" icon={<CategoryIcon/>}/>
                        <Chip label={`Urgencia: ${report.urgencia || 'N/A'}`} color={report.urgencia === 'Alta' ? 'error' : (report.urgencia === 'Media' ? 'warning' : 'default')} size="small" variant="filled" icon={<PriorityHighIcon/>}/>
                    </Box>
                 </Paper>

                {/* Sección Imagen (si existe) */}
                {report.foto_url && (
                    <Paper variant="outlined" sx={{ overflow: 'hidden', borderRadius: 2, p:1 }}>
                         <Typography variant="subtitle2" color="text.secondary" sx={{ mb: 1, px:1 }}>Imagen del Reporte</Typography>
                        <Box component="img" src={report.foto_url} alt="Imagen del reporte" sx={{ width: '100%', display:'block', maxHeight: 350, objectFit: 'contain', borderRadius: 1 }} />
                    </Paper>
                )}

                {/* Sección Descripción y Detalles */}
                 <Paper variant="outlined" sx={{ p: 2 }}>
                    <Typography variant="subtitle2" color="text.secondary">Descripción:</Typography>
                    <Typography variant="body1" paragraph sx={{ whiteSpace: 'pre-wrap', mt: 0.5 }}>
                        {report.descripcion || 'No se proporcionó descripción.'}
                    </Typography>
                    <Divider sx={{ my: 1.5 }} />
                     <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1 }}>Detalles Adicionales</Typography>
                     {/* Usar Grid interno para distribuir detalles */}
                     <Grid container spacing={1}>
                        <Grid item xs={12} sm={6}><DetailItem icon={CalendarIcon} primary="Fecha Reporte" secondary={report.fecha_creacion_formateada || new Date(report.fecha_creacion).toLocaleString()} /></Grid>
                        <Grid item xs={12} sm={6}><DetailItem icon={TimeIcon} primary="Hora Incidente" secondary={report.hora_incidente} /></Grid>
                        <Grid item xs={12} sm={6}><DetailItem icon={ImpactIcon} primary="Impacto" secondary={report.impacto} /></Grid>
                        <Grid item xs={12} sm={6}><DetailItem icon={TagIcon} primary="Etiquetas" secondary={report.tags?.join(', ') || 'Ninguna'} /></Grid>
                     </Grid>
                 </Paper>

                {/* Sección Mapa y Ubicación */}
                <Paper variant="outlined" sx={{ p: 2 }}>
                    <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1.5 }}>Ubicación</Typography>
                     {locationCoords ? (
                         <>
                            <Box sx={{ height: '300px', width: '100%', borderRadius: 1, overflow: 'hidden', mb: 1 }}>
                                <MapContainer center={locationCoords} zoom={16} style={{ height: '100%', width: '100%' }} scrollWheelZoom={false} key={report.id + '-modalmap'}>
                                    <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                                    <Marker position={locationCoords} />
                                </MapContainer>
                            </Box>
                            <Grid container spacing={1}>
                                <Grid item xs={12} sm={6}><DetailItem icon={PinDropIcon} primary="Distrito" secondary={report.distrito} /></Grid>
                                <Grid item xs={12} sm={6}><DetailItem icon={ReferenceIcon} primary="Referencia" secondary={report.referencia_ubicacion} /></Grid>
                            </Grid>
                              {googleMapsUrl && (
                                <Button size="small" href={googleMapsUrl} target="_blank" rel="noopener noreferrer" startIcon={<LaunchIcon />} sx={{mt: 1.5}}>
                                    Ver en Google Maps
                                </Button>
                            )}
                        </>
                     ) : (
                         <Typography color="text.secondary" variant="body2">Ubicación no disponible.</Typography>
                     )}
                </Paper>

                {/* Detalles del Autor (con Plan) */}
                  <Paper variant="outlined" sx={{ p: 2.5 }}>
                      <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1.5 }}>Detalles del Autor</Typography>
                        <Stack spacing={1.5}> {/* Aumentar espaciado */}
                            <DetailItem icon={PersonIcon} primary="Nombre / Alias" secondary={report.autor_nombre || report.autor_alias || (report.es_anonimo ? 'Anónimo' : 'No especificado')} />
                            {/* --- ADDED: Plan del Autor --- */}
                            {!report.es_anonimo && (
                                <Stack direction="row" spacing={1.5} alignItems="center" sx={{ py: 0.8 }}>
                                    <Box sx={{ mt: 0.3 }}><PremiumIcon fontSize="small" color="action" /></Box>
                                    <Box>
                                        <Typography variant="caption" color="text.secondary" sx={{ textTransform: 'uppercase', fontSize: '0.7rem' }}> Plan     </Typography>
                                        <PlanChip planNombre={report.nombre_plan_autor} />
                                    </Box>
                                </Stack>
                            )}
                            {/* --- END ADDED --- */}
                            {!report.es_anonimo && <DetailItem icon={EmailIcon} primary="Email" secondary={report.autor_email} />}
                            {!report.es_anonimo && <DetailItem icon={PhoneIcon} primary="Teléfono" secondary={report.autor_telefono} />}
                            <Chip label={report.es_anonimo ? 'Reporte Anónimo' : 'Reporte Público'} size="small" variant="outlined" sx={{ width: 'fit-content', mt: 1 }}/>
                        </Stack>
                  </Paper>
            </Stack>
        </DialogContent>

        {/* Acciones */}
        <DialogActions sx={{ p: 2, borderTop: 1, borderColor: 'divider', justifyContent: 'space-between' }}>
             <Button onClick={onClose} color="inherit">Cerrar</Button>
             {report.estado === 'pendiente_verificacion' && (
                 <Box sx={{ display: 'flex', gap: 1}}>
                    <Button variant="outlined" color="error" onClick={() => handleAction(false)} startIcon={<RejectIcon />}>
                        Rechazar
                    </Button>
                    <Button variant="contained" color="success" onClick={() => handleAction(true)} startIcon={<ApproveIcon/>}>
                        Aprobar
                    </Button>
                 </Box>
             )}
        </DialogActions>
    </Dialog>
  );
}

export default ModalDetalleReporteResumen;