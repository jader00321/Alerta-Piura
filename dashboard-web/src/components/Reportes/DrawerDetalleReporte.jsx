import React, { useState, useEffect } from 'react';
import {
    Drawer, Box, Typography, Divider, Button, Chip, Dialog, DialogTitle,
    DialogContent, DialogActions, FormControl, Select, MenuItem, InputLabel,
    Paper, Stack, Grid, IconButton, Tooltip, useTheme,
    Collapse, // <-- Import Collapse
    ButtonBase // <-- Import ButtonBase for toggle area
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
    ExpandMore as ExpandMoreIcon, MergeType as MergeTypeIcon
} from '@mui/icons-material';
import adminService from '../../services/adminService';

// Fix Leaflet Icon (keep as before)
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});

// Reusable DetailItem (keep as before)
const DetailItem = ({ icon, primary, secondary, secondaryIsNode = false }) => (
    <Stack direction="row" spacing={1.5} alignItems="flex-start" sx={{ py: 0.8 }}>
        <Box sx={{ mt: 0.3 }}>{React.cloneElement(icon, { fontSize: 'small', color: 'action' })}</Box>
        <Box>
            <Typography variant="caption" color="text.secondary" sx={{ textTransform: 'uppercase', fontSize: '0.7rem' }}>
                {primary}
            </Typography>
            {secondaryIsNode ? (
                 secondary || <Typography variant="body2" color="text.secondary">No especificado</Typography>
            ) : (
                <Typography variant="body2" sx={{ wordBreak: 'break-word', fontWeight: 500 }}>
                    {secondary || 'No especificado'}
                </Typography>
             )}
        </Box>
    </Stack>
);


// Header Status Chip (keep as before)
const HeaderStatusChip = ({ status }) => {
    const statusInfo = {
        verificado: { label: 'Verificado', color: 'success', icon: <VisibilityIcon /> },
        oculto: { label: 'Oculto', color: 'default', icon: <VisibilityOffIcon /> },
        rechazado: { label: 'Rechazado', color: 'error', icon: <RejectIcon /> },
        pendiente_verificacion: { label: 'Pendiente', color: 'warning', icon: <PendingIcon /> },
        fusionado: { label: 'Fusionado', color: 'secondary', icon: <MergeTypeIcon /> }, // <-- AÑADIDO
    };
    const info = statusInfo[status] || { label: status, color: 'default', icon: <></> };
    // Ajustes de tamaño y estilo
    return <Chip
              icon={info.icon}
              label={info.label}
              color={info.color}
              size="medium" // Ligeramente más grande
              variant="filled" // Relleno para destacar
              sx={{
                fontWeight: 'bold',
                fontSize: '0.9rem', // Tamaño de fuente
                px: 1.5, // Padding horizontal
                height: 'auto',
                '& .MuiChip-label': { py: 0.8 }, // Padding vertical del label
                boxShadow: 1 // Sombra sutil
              }}
           />;
};


function DrawerDetalleReporte({ report, open, onClose, onActionCompleted, onOpenChat }) {
    const [confirmModal, setConfirmModal] = useState({ open: false, action: null, title: '', content: '' });
    const [statusToChange, setStatusToChange] = useState('');
    // --- State for collapsible actions ---
    const [actionsExpanded, setActionsExpanded] = useState(false);
    const theme = useTheme();

    useEffect(() => {
        if (report) {
            setStatusToChange(report.estado);
            // Optionally close actions when a new report is loaded
            // setActionsExpanded(false);
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
        if (!report) return; // Guard clause
        const action = confirmModal.action;
        let promise;

        if (action === 'delete') {
            promise = adminService.adminDeleteReport(report.id);
        } else if (action === 'toggleVisibility') {
            promise = adminService.updateReportVisibility(report.id, report.estado);
        } else if (action === 'changeStatus') {
            if (statusToChange === report.estado) { // No actual change needed
                 setConfirmModal({ open: false, action: null, title: '', content: '' });
                 return; // Exit early
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
                alert(`Error al ${action === 'delete' ? 'eliminar' : 'actualizar'} el reporte.`);
            }).finally(() => {
                 setConfirmModal({ open: false, action: null, title: '', content: '' });
            });
        } else {
             setConfirmModal({ open: false, action: null, title: '', content: '' });
        }
    };

    if (!report) return null;

    const isHidable = ['verificado', 'oculto'].includes(report.estado);
    const isHidden = report.estado === 'oculto';

    return (
        <>
            <Drawer anchor="right" open={open} onClose={onClose} PaperProps={{ sx: { bgcolor: 'background.paper', width:{xs:'100vw', sm: 450}, p: 2, pt: 10 } }}>
                 {/* Header with Title, Status Chip and Close Button */}
                 <Box sx={{ p: 2, borderBottom: 1, borderColor: 'divider' }}>
                     <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 1 }}>
                        <Stack>
                             <Typography variant="h5" sx={{fontWeight:'bold'}}>Detalles del Reporte</Typography> {/* <-- Título más grande */}
                             <Chip icon={<CodeIcon/>} label={report.codigo_reporte} size="small" variant="outlined" sx={{mt: 0.5, width:'fit-content'}}/> {/* <-- Código añadido */}
                        </Stack>
                        <IconButton onClick={onClose} sx={{mt: -1, mr: -1}}><CloseIcon /></IconButton>
                     </Box>
                      <HeaderStatusChip status={report.estado} /> {/* <-- Chip de estado prominente */}
                 </Box>

                 <Box sx={{ flexGrow: 1, overflowY: 'auto', p: 2.5, bgcolor: theme.palette.mode === 'dark' ? '#1e1e1e' : '#f5f5f5' }}> {/* Subtle background */}
                    <Stack spacing={2.5}> {/* Increase spacing between papers */}

                        {report.foto_url && (
                            <Paper variant='elevation' elevation={1} sx={{ borderRadius: 2, overflow:'hidden'}}>
                                <img src={report.foto_url} alt="Foto del Reporte" style={{ width: '100%', display: 'block' }} />
                            </Paper>
                        )}

                        {/* Basic Info */}
                        <Paper variant='outlined' sx={{p: 2}}>
                            <Typography variant="h5">{report.titulo}</Typography>
                            <Typography variant="body2" color="text.secondary" paragraph sx={{ whiteSpace: 'pre-wrap', mt: 1 }}>
                                {report.descripcion || "Sin descripción."}
                            </Typography>
                            <Divider sx={{ my: 1.5 }} />
                            <Stack spacing={1}>
                                <DetailItem icon={<CategoryIcon />} primary="Categoría" secondary={report.categoria_sugerida ? `${report.categoria_sugerida} (Sugerida)` : report.categoria} />
                                <DetailItem icon={<PriorityHighIcon />} primary="Urgencia" secondary={report.urgencia} />
                                <DetailItem icon={<CalendarTodayIcon />} primary="Fecha de Creación" secondary={new Date(report.fecha_creacion).toLocaleString()} />
                                <DetailItem icon={<TimeIcon />} primary="Hora del Incidente" secondary={report.hora_incidente} />
                            </Stack>
                        </Paper>

                        {/* Location */}
                         <Paper variant='outlined' sx={{ p: 2 }}>
                             <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1.5 }}>Ubicación</Typography>
                             {locationCoords ? (
                                 <>
                                    <Box sx={{ height: '200px', width: '100%', mb: 2, borderRadius: 1, overflow: 'hidden' }}>
                                        <MapContainer center={locationCoords} zoom={16} style={{ height: '100%', width: '100%' }} scrollWheelZoom={false} key={report.id + '-map'}>
                                            <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                                            <Marker position={locationCoords} />
                                        </MapContainer>
                                    </Box>
                                    <Stack spacing={1}>
                                         <DetailItem icon={<PinDropIcon />} primary="Distrito" secondary={report.distrito} />
                                         <DetailItem icon={<ReferenceIcon />} primary="Referencia" secondary={report.referencia_ubicacion} />
                                          {googleMapsUrl && (
                                            <Button size="small" href={googleMapsUrl} target="_blank" rel="noopener noreferrer" startIcon={<LaunchIcon />} sx={{alignSelf:'flex-start'}}>
                                                Ver en Google Maps
                                            </Button>
                                        )}
                                    </Stack>
                                </>
                             ) : (
                                 <Typography color="text.secondary" variant="body2">Ubicación no disponible.</Typography>
                             )}
                         </Paper>

                         {/* Additional Details */}
                          <Paper variant='outlined' sx={{ p: 2 }}>
                              <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1.5 }}>Detalles Adicionales</Typography>
                              <Stack spacing={1}>
                                 <DetailItem icon={<ImpactIcon />} primary="Impacto" secondary={report.impacto} />
                                 <DetailItem icon={<TagIcon />} primary="Etiquetas" secondary={report.tags?.join(', ') || 'Ninguna'} />
                                 {report.reportes_vinculados_count > 0 && (
                                     <DetailItem
                                         icon={<MergeTypeIcon />}
                                         primary="Reportes Vinculados"
                                         secondary={report.reportes_vinculados_count.toString()}
                                     />
                                 )}
                              </Stack>
                          </Paper>

                         {/* Author Info */}
                         <Paper variant='outlined' sx={{ p: 2 }}>
                             <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1.5 }}>Información del Autor</Typography>
                             <Stack spacing={1}>
                                  {/* --- FIX: Simplified Visibility --- */}
                                  <DetailItem
                                    icon={report.es_anonimo ? <VisibilityOffIcon /> : <VisibilityIcon />}
                                    primary="Visibilidad  "
                                    secondaryIsNode={true}
                                    secondary={
                                        <Chip
                                            label={report.es_anonimo ? 'Anónimo' : 'Público'}
                                            size="small"
                                            variant="filled" // Use filled for clarity
                                            color={report.es_anonimo ? 'default' : 'success'}
                                            sx={{ fontWeight: 'bold' }}
                                        />
                                    }
                                  />
                                 <DetailItem icon={<PersonIcon />} primary="Nombre/Alias" secondary={report.autor_nombre || report.autor_alias || (report.es_anonimo ? 'Anónimo' : 'No especificado')} />
                                 {!report.es_anonimo && <DetailItem icon={<EmailIcon />} primary="Email" secondary={report.autor_email} />}
                             </Stack>
                         </Paper>

                        {/* Verifier Info */}
                        {report.lider_verificador_alias && (
                           <Paper variant='outlined' sx={{ p: 2 }}>
                                <Typography variant="subtitle1" sx={{ fontWeight: 'bold', mb: 1.5 }}>Verificado Por</Typography>
                                <Stack spacing={1}>
                                    <DetailItem icon={<PersonIcon />} primary="Líder/Admin" secondary={report.lider_verificador_nombre || report.lider_verificador_alias} />
                                    <DetailItem icon={<EmailIcon />} primary="Email Verificador" secondary={report.lider_verificador_email} />
                                </Stack>
                            </Paper>
                        )}
                    </Stack> {/* End main content stack */}
                 </Box>

                 {/* Action Bar */}
                 <Box sx={{ borderTop: 1, borderColor: 'divider', bgcolor: 'background.paper', mt: 'auto' }}>
                     {/* --- Toggle Button --- */}
                     <ButtonBase
                        onClick={() => setActionsExpanded(!actionsExpanded)}
                        sx={{
                            display: 'flex',
                            justifyContent: 'space-between',
                            alignItems: 'center',
                            width: '100%',
                            p: 2,
                            textAlign: 'left',
                            borderBottom: actionsExpanded ? 1 : 0, // Add border when expanded
                            borderColor: 'divider',
                            '&:hover': { bgcolor: 'action.hover' }
                        }}
                     >
                         <Typography variant="subtitle1" sx={{ fontWeight: 'bold' }}>
                             Acciones de Moderación
                         </Typography>
                         <ExpandMoreIcon
                             sx={{
                                 transform: actionsExpanded ? 'rotate(180deg)' : 'rotate(0deg)',
                                 transition: theme.transitions.create('transform', {
                                     duration: theme.transitions.duration.short,
                                 }),
                             }}
                         />
                     </ButtonBase>

                     {/* --- Collapsible Content --- */}
                     <Collapse in={actionsExpanded} timeout="auto" unmountOnExit>
                        <Box sx={{ p: 2 }}>
                     <Stack spacing={1.5}>
                        {/* ... (Actions form and buttons - no functional changes needed) ... */}
                         <FormControl fullWidth size="small">
                             <InputLabel>Cambiar Estado</InputLabel>
                             <Select value={statusToChange} label="Cambiar Estado" onChange={(e) => setStatusToChange(e.target.value)}>
                                 <MenuItem value="pendiente_verificacion">Pendiente</MenuItem>
                                 <MenuItem value="verificado">Verificado</MenuItem>
                                 <MenuItem value="rechazado">Rechazado</MenuItem>
                                 <MenuItem value="oculto">Oculto</MenuItem>
                             </Select>
                         </FormControl>
                         <Button variant="contained" onClick={() => handleActionClick('changeStatus', 'Confirmar Cambio de Estado', `¿Deseas cambiar el estado a "${statusToChange.replace(/_/g, ' ')}"?`)} disabled={statusToChange === report.estado}>Aplicar Estado</Button>
                         {!report.es_anonimo && (<Button startIcon={<ChatIcon />} variant="outlined" color="primary" onClick={() => onOpenChat(report)}>Contactar Usuario</Button>)}
                         <Button startIcon={isHidden ? <VisibilityIcon /> : <VisibilityOffIcon />} variant="outlined" color="secondary" onClick={() => handleActionClick('toggleVisibility', isHidden ? 'Mostrar Reporte' : 'Ocultar Reporte', `¿Estás seguro de que quieres ${isHidden ? 'hacer público' : 'ocultar'} este reporte?`)} disabled={!isHidable}> {isHidden ? 'Hacer Público' : 'Ocultar Reporte'}</Button>
                         <Button startIcon={<DeleteIcon />} variant="outlined" color="error" onClick={() => handleActionClick('delete', 'Confirmar Eliminación', 'Esta acción es permanente e irreversible. ¿Estás seguro?')}>Eliminar Reporte</Button>
                     </Stack>
                        </Box>
                     </Collapse>
                 </Box>
            </Drawer>
            {/* Confirmation Modal */}
            <Dialog open={confirmModal.open} onClose={() => setConfirmModal({ ...confirmModal, open: false })}>
               {/* ... (Modal content - no changes needed) ... */}
                <DialogTitle>{confirmModal.title}</DialogTitle>
                <DialogContent><Typography>{confirmModal.content}</Typography></DialogContent>
                <DialogActions>
                    <Button onClick={() => setConfirmModal({ ...confirmModal, open: false })}>Cancelar</Button>
                    <Button onClick={handleConfirmAction} variant="contained" color={confirmModal.action === 'delete' ? 'error' : 'primary'}>Confirmar</Button>
                </DialogActions>
            </Dialog>
        </>
    );
}

export default DrawerDetalleReporte;