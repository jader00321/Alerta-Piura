// src/components/Reportes/DrawerDetalleReporte.jsx
import React, { useState, useEffect } from 'react';
import {
    Drawer, Box, Typography, Divider, Button, Chip, Dialog, DialogTitle,
    DialogContent, DialogActions, FormControl, Select, MenuItem, InputLabel,
    Paper, Stack, Grid, IconButton, Tooltip, useTheme,
    Collapse, ButtonBase, Badge, Avatar, alpha, Slide
} from '@mui/material';
import { MapContainer, TileLayer, Marker } from 'react-leaflet';
import L from 'leaflet';
import {
    Person as PersonIcon, Email as EmailIcon, CalendarToday as CalendarTodayIcon,
    Delete as DeleteIcon, VisibilityOff as VisibilityOffIcon, Chat as ChatIcon,
    PinDrop as PinDropIcon, AccessTime as TimeIcon, People as ImpactIcon,
    Label as TagIcon, Place as ReferenceIcon, Category as CategoryIcon,
    PriorityHigh as PriorityHighIcon, Visibility as VisibilityIcon, CheckCircleOutline as CheckIcon,
    CancelOutlined as RejectIcon, HourglassEmpty as PendingIcon, Close as CloseIcon,
    Launch as LaunchIcon, Code as CodeIcon,
    ExpandMore as ExpandMoreIcon, MergeType as MergeTypeIcon,
    WarningAmber as WarningIcon, InfoOutlined as InfoIcon
} from '@mui/icons-material';
import adminService from '../../services/adminService';

// Fix Leaflet Icon
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});

// --- Componente Helper Estilizado ---
const DetailItem = ({ icon, primary, secondary, secondaryIsNode = false }) => {
    const theme = useTheme();
    return (
        <Stack direction="row" spacing={2} alignItems="center" sx={{ py: 1 }}>
            <Avatar sx={{ 
                bgcolor: alpha(theme.palette.primary.main, 0.1), 
                color: theme.palette.primary.main, 
                width: 32, height: 32 
            }}>
                {React.cloneElement(icon, { fontSize: 'small' })}
            </Avatar>
            <Box>
                <Typography variant="caption" display="block" color="text.secondary" sx={{ textTransform: 'uppercase', fontSize: '0.7rem', fontWeight: 'bold', letterSpacing: 0.5 }}>
                    {primary}
                </Typography>
                {secondaryIsNode ? (
                     secondary || <Typography variant="body2" color="text.secondary">No especificado</Typography>
                ) : (
                    <Typography variant="body2" sx={{ fontWeight: 500, color: 'text.primary' }}>
                        {secondary || 'No especificado'}
                    </Typography>
                )}
            </Box>
        </Stack>
    );
};

const HeaderStatusChip = ({ status }) => {
    const statusInfo = {
        verificado: { label: 'Verificado', color: 'success', icon: <CheckIcon /> },
        oculto: { label: 'Oculto', color: 'default', icon: <VisibilityOffIcon /> },
        rechazado: { label: 'Rechazado', color: 'error', icon: <RejectIcon /> },
        pendiente_verificacion: { label: 'Pendiente', color: 'warning', icon: <PendingIcon /> },
        fusionado: { label: 'Fusionado', color: 'info', icon: <MergeTypeIcon /> },
    };
    const info = statusInfo[status] || { label: status, color: 'default', icon: <></> };
    
    return <Chip 
        icon={info.icon} 
        label={info.label} 
        color={info.color} 
        variant="filled" 
        sx={{ fontWeight: 'bold', borderRadius: 1 }} 
    />;
};

// --- Transición para el Modal ---
const Transition = React.forwardRef(function Transition(props, ref) {
    return <Slide direction="up" ref={ref} {...props} />;
});

function DrawerDetalleReporte({ report, open, onClose, onActionCompleted, onOpenChat }) {
    const [confirmModal, setConfirmModal] = useState({ open: false, action: null, title: '', content: '' });
    const [statusToChange, setStatusToChange] = useState('');
    const [actionsExpanded, setActionsExpanded] = useState(false);
    const theme = useTheme();

    useEffect(() => {
        if (report) {
            setStatusToChange(report.estado);
        } else {
            setStatusToChange('');
            setActionsExpanded(false);
        }
    }, [report]);

    const locationCoords = (report?.location?.coordinates) ? [report.location.coordinates[1], report.location.coordinates[0]] : null;
    const googleMapsUrl = locationCoords ? `https://www.google.com/maps?q=${locationCoords[0]},${locationCoords[1]}` : null;

    const handleActionClick = (action, title, content) => {
        setConfirmModal({ open: true, action, title, content });
    };

    const handleConfirmAction = () => {
        if (!report) return;
        const action = confirmModal.action;
        let promise;

        if (action === 'delete') {
            promise = adminService.adminDeleteReport(report.id);
        } else if (action === 'toggleVisibility') {
            promise = adminService.updateReportVisibility(report.id, report.estado);
        } else if (action === 'changeStatus') {
            if (statusToChange === report.estado) {
                 setConfirmModal({ ...confirmModal, open: false });
                 return;
            }
            if (statusToChange === 'pendiente_verificacion') {
                promise = adminService.setReportToPending(report.id);
            } else {
                const isApproval = statusToChange === 'verificado';
                promise = adminService.resolveReport(report.id, isApproval);
            }
        }

        if(promise) {
            promise.then(() => {
                onActionCompleted();
            }).catch(err => {
                console.error(`Error performing action ${action}:`, err);
                alert(`Error al realizar la acción.`);
            }).finally(() => {
                 setConfirmModal({ ...confirmModal, open: false });
            });
        } else {
             setConfirmModal({ ...confirmModal, open: false });
        }
    };

    if (!report) return null;

    const unreadMessages = report.mensajes_no_leidos || 0;
    const isHidable = ['verificado', 'oculto'].includes(report.estado);
    const isHidden = report.estado === 'oculto';

    return (
        <>
            <Drawer 
                anchor="right" 
                open={open} 
                onClose={onClose} 
                PaperProps={{ 
                    sx: { 
                        bgcolor: 'background.default', 
                        width: { xs: '100vw', sm: 500 },
                        display: 'flex', 
                        flexDirection: 'column',
                        // --- FIX: Espacio superior para evitar el Header ---
                        pt: { xs: 8, sm: 7 } // Ajusta este valor según la altura de tu navbar
                    } 
                }}
            >
                 {/* Header */}
                 <Box sx={{ p: 3, borderBottom: 1, borderColor: 'divider', bgcolor: 'background.paper' }}>
                     <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2 }}>
                        <Stack spacing={0.5}>
                             <Typography variant="h5" sx={{ fontWeight: 800, lineHeight: 1.2 }}>
                                Detalles del Incidente
                             </Typography>
                             <Chip 
                                icon={<CodeIcon style={{fontSize: 16}}/>} 
                                label={report.codigo_reporte} 
                                size="small" 
                                variant="outlined" 
                                sx={{ width: 'fit-content', fontWeight: 'bold', border: '1px solid #ccc' }}
                             />
                        </Stack>
                        <IconButton onClick={onClose} sx={{ bgcolor: 'action.hover' }}><CloseIcon /></IconButton>
                     </Box>
                     <HeaderStatusChip status={report.estado} />
                 </Box>

                 {/* Contenido Scrollable */}
                 <Box sx={{ flexGrow: 1, overflowY: 'auto', p: 3 }}>
                    <Stack spacing={3}>

                        {report.foto_url && (
                            <Paper elevation={2} sx={{ borderRadius: 2, overflow: 'hidden', border: `1px solid ${theme.palette.divider}` }}>
                                <img src={report.foto_url} alt="Evidencia" style={{ width: '100%', display: 'block', maxHeight: 300, objectFit: 'cover' }} />
                            </Paper>
                        )}

                        {/* Información Básica */}
                        <Paper variant='outlined' sx={{ p: 2.5, borderRadius: 2, bgcolor: 'background.paper' }}>
                            <Typography variant="h6" fontWeight="bold" gutterBottom>{report.titulo}</Typography>
                            <Typography variant="body2" color="text.secondary" paragraph sx={{ whiteSpace: 'pre-wrap', lineHeight: 1.6 }}>
                                {report.descripcion || "Sin descripción disponible."}
                            </Typography>
                            <Divider sx={{ my: 2 }} />
                            <Grid container spacing={2}>
                                <Grid item xs={6}><DetailItem icon={<CategoryIcon />} primary="Categoría" secondary={report.categoria_sugerida ? `${report.categoria_sugerida} (Sugerida)` : report.categoria} /></Grid>
                                <Grid item xs={6}><DetailItem icon={<PriorityHighIcon />} primary="Urgencia" secondary={report.urgencia} /></Grid>
                                <Grid item xs={6}><DetailItem icon={<CalendarTodayIcon />} primary="Fecha" secondary={new Date(report.fecha_creacion).toLocaleDateString()} /></Grid>
                                <Grid item xs={6}><DetailItem icon={<TimeIcon />} primary="Hora" secondary={report.hora_incidente} /></Grid>
                            </Grid>
                        </Paper>

                        {/* Ubicación */}
                         <Paper variant='outlined' sx={{ p: 2.5, borderRadius: 2 }}>
                             <Typography variant="subtitle2" sx={{ fontWeight: 'bold', mb: 2, letterSpacing: 1 }}>UBICACIÓN GEOGRÁFICA</Typography>
                             {locationCoords ? (
                                 <>
                                     <Box sx={{ height: 200, width: '100%', mb: 2, borderRadius: 2, overflow: 'hidden', border: `1px solid ${theme.palette.divider}` }}>
                                         <MapContainer center={locationCoords} zoom={16} style={{ height: '100%', width: '100%' }} scrollWheelZoom={false} key={report.id + '-map'}>
                                             <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                                             <Marker position={locationCoords} />
                                         </MapContainer>
                                     </Box>
                                     <Stack spacing={1}>
                                          <DetailItem icon={<PinDropIcon />} primary="Distrito" secondary={report.distrito} />
                                          <DetailItem icon={<ReferenceIcon />} primary="Referencia" secondary={report.referencia_ubicacion} />
                                          {googleMapsUrl && (
                                            <Button size="small" href={googleMapsUrl} target="_blank" startIcon={<LaunchIcon />} sx={{ alignSelf: 'flex-start', mt: 1 }}>
                                                Ver en Google Maps
                                            </Button>
                                          )}
                                     </Stack>
                                 </>
                             ) : (
                                 <Typography color="text.secondary" variant="body2">Ubicación no disponible.</Typography>
                             )}
                         </Paper>

                         {/* Detalles Extra */}
                         <Paper variant='outlined' sx={{ p: 2.5, borderRadius: 2 }}>
                             <Typography variant="subtitle2" sx={{ fontWeight: 'bold', mb: 2, letterSpacing: 1 }}>DATOS TÉCNICOS</Typography>
                             <Grid container spacing={2}>
                                 <Grid item xs={6}><DetailItem icon={<ImpactIcon />} primary="Impacto" secondary={report.impacto} /></Grid>
                                 <Grid item xs={6}><DetailItem icon={<TagIcon />} primary="Etiquetas" secondary={report.tags?.join(', ') || 'Ninguna'} /></Grid>
                                 {report.reportes_vinculados_count > 0 && (
                                     <Grid item xs={12}>
                                         <DetailItem icon={<MergeTypeIcon />} primary="Reportes Vinculados" secondary={report.reportes_vinculados_count.toString()} />
                                     </Grid>
                                 )}
                             </Grid>
                         </Paper>

                         {/* Autoría */}
                         <Paper variant='outlined' sx={{ p: 2.5, borderRadius: 2 }}>
                             <Typography variant="subtitle2" sx={{ fontWeight: 'bold', mb: 2, letterSpacing: 1 }}>AUTOR DEL REPORTE</Typography>
                             <Stack spacing={1}>
                                 <DetailItem
                                   icon={report.es_anonimo ? <VisibilityOffIcon /> : <VisibilityIcon />}
                                   primary="Privacidad"
                                   secondaryIsNode={true}
                                   secondary={
                                       <Chip label={report.es_anonimo ? 'Anónimo' : 'Público'} size="small" variant="outlined" color={report.es_anonimo ? 'default' : 'primary'} sx={{ fontWeight: 'bold' }} />
                                   }
                                 />
                                 <DetailItem icon={<PersonIcon />} primary="Usuario" secondary={report.autor_nombre || report.autor_alias || 'N/A'} />
                                 {!report.es_anonimo && <DetailItem icon={<EmailIcon />} primary="Email" secondary={report.autor_email} />}
                             </Stack>
                         </Paper>
                    </Stack>
                 </Box>

                 {/* Barra de Acciones (Inferior) */}
                 <Box sx={{ borderTop: 1, borderColor: 'divider', bgcolor: 'background.paper', mt: 'auto', boxShadow: '0px -4px 10px rgba(0,0,0,0.05)' }}>
                     <ButtonBase
                        onClick={() => setActionsExpanded(!actionsExpanded)}
                        sx={{
                            width: '100%', p: 2,
                            display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                            '&:hover': { bgcolor: 'action.hover' }
                        }}
                     >
                         <Typography variant="subtitle1" sx={{ fontWeight: 'bold', color: 'primary.main' }}>
                             {actionsExpanded ? 'Ocultar Herramientas' : 'Herramientas de Moderación'}
                         </Typography>
                         <ExpandMoreIcon sx={{ 
                             transform: actionsExpanded ? 'rotate(180deg)' : 'rotate(0deg)', 
                             transition: 'transform 0.3s' 
                         }} />
                     </ButtonBase>

                     <Collapse in={actionsExpanded} timeout="auto" unmountOnExit>
                        <Box sx={{ p: 3, pt: 0 }}>
                             <Stack spacing={2}>
                                 {/* Cambiar Estado */}
                                 <Paper variant="outlined" sx={{ p: 2, display: 'flex', gap: 2, alignItems: 'center', bgcolor: 'action.hover' }}>
                                     <FormControl fullWidth size="small">
                                         <InputLabel>Estado del Reporte</InputLabel>
                                         <Select value={statusToChange} label="Estado del Reporte" onChange={(e) => setStatusToChange(e.target.value)}>
                                             <MenuItem value="pendiente_verificacion">Pendiente</MenuItem>
                                             <MenuItem value="verificado">Verificado</MenuItem>
                                             <MenuItem value="rechazado">Rechazado</MenuItem>
                                             <MenuItem value="oculto">Oculto</MenuItem>
                                         </Select>
                                     </FormControl>
                                     <Button 
                                        variant="contained" 
                                        onClick={() => handleActionClick('changeStatus', 'Cambio de Estado', `¿Confirmar cambio a "${statusToChange}"?`)} 
                                        disabled={statusToChange === report.estado}
                                        sx={{ whiteSpace: 'nowrap' }}
                                     >
                                        Actualizar
                                     </Button>
                                 </Paper>

                                 {/* Botones de Acción */}
                                 <Grid container spacing={2}>
                                     <Grid item xs={12} sm={4}>
                                         {!report.es_anonimo && (
                                             <Button 
                                                variant="outlined" 
                                                fullWidth 
                                                startIcon={<Badge badgeContent={unreadMessages} color="error"><ChatIcon /></Badge>}
                                                onClick={() => onOpenChat(report)}
                                             >
                                                 Chat
                                             </Button>
                                         )}
                                     </Grid>
                                     <Grid item xs={12} sm={4}>
                                         <Button 
                                            variant="outlined" 
                                            color="warning" 
                                            fullWidth 
                                            startIcon={isHidden ? <VisibilityIcon /> : <VisibilityOffIcon />} 
                                            onClick={() => handleActionClick('toggleVisibility', isHidden ? 'Hacer Público' : 'Ocultar Reporte', `¿Seguro que deseas ${isHidden ? 'mostrar públicamente' : 'ocultar'} este reporte?`)} 
                                            disabled={!isHidable}
                                         >
                                             {isHidden ? 'Mostrar' : 'Ocultar'}
                                         </Button>
                                     </Grid>
                                     <Grid item xs={12} sm={4}>
                                         <Button 
                                            variant="outlined" 
                                            color="error" 
                                            fullWidth 
                                            startIcon={<DeleteIcon />} 
                                            onClick={() => handleActionClick('delete', 'Eliminar Reporte', 'Esta acción es irreversible. ¿Proceder?')}
                                         >
                                             Eliminar
                                         </Button>
                                     </Grid>
                                 </Grid>
                             </Stack>
                        </Box>
                     </Collapse>
                 </Box>
            </Drawer>

            {/* Modal de Confirmación Mejorado */}
            <Dialog 
                open={confirmModal.open} 
                onClose={() => setConfirmModal({ ...confirmModal, open: false })}
                TransitionComponent={Transition}
                maxWidth="xs"
                fullWidth
            >
                <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    {confirmModal.action === 'delete' ? <WarningIcon color="error" /> : <InfoIcon color="primary" />}
                    {confirmModal.title}
                </DialogTitle>
                <DialogContent>
                    <Typography>{confirmModal.content}</Typography>
                </DialogContent>
                <DialogActions sx={{ p: 2 }}>
                    <Button onClick={() => setConfirmModal({ ...confirmModal, open: false })} color="inherit">Cancelar</Button>
                    <Button 
                        onClick={handleConfirmAction} 
                        variant="contained" 
                        color={confirmModal.action === 'delete' ? 'error' : 'primary'}
                        autoFocus
                    >
                        Confirmar
                    </Button>
                </DialogActions>
            </Dialog>
        </>
    );
}

export default DrawerDetalleReporte;