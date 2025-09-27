import React, { useState, useEffect } from 'react';
import { Drawer, Box, Typography, Divider, List, ListItem, ListItemIcon, ListItemText, Button, Chip, Dialog, DialogTitle, DialogContent, DialogActions, FormControl, Select, MenuItem, InputLabel } from '@mui/material';
import { MapContainer, TileLayer, Marker } from 'react-leaflet';
import L from 'leaflet';
import { Person as PersonIcon, Email as EmailIcon, CalendarToday as CalendarTodayIcon, Delete as DeleteIcon, VisibilityOff as VisibilityOffIcon, Chat as ChatIcon, PinDrop as PinDropIcon, AccessTime as TimeIcon, People as ImpactIcon, Label as TagIcon, Place as ReferenceIcon } from '@mui/icons-material';
import { Category as CategoryIcon, PriorityHigh as PriorityHighIcon, Visibility as VisibilityIcon, CheckCircleOutline as CheckIcon, CancelOutlined as RejectIcon, HourglassEmpty as PendingIcon } from '@mui/icons-material';
import adminService from '../services/adminService';

// Fix para el ícono de Leaflet (sin cambios)
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});

// MEJORA: Componente reutilizable para mostrar detalles
const DetailItem = ({ icon, primary, secondary }) => (
    <ListItem sx={{ py: 0.5 }}>
        <ListItemIcon sx={{ minWidth: '40px' }}>{icon}</ListItemIcon>
        <ListItemText primary={primary} secondary={secondary || 'No especificado'} />
    </ListItem>
);

const HeaderStatusChip = ({ status }) => {
    const statusInfo = {
        verificado: { label: 'Público', color: 'success', icon: <VisibilityIcon /> },
        oculto: { label: 'Oculto', color: 'gris', icon: <VisibilityOffIcon /> },
        rechazado: { label: 'Rechazado', color: 'error', icon: <RejectIcon /> },
        pendiente_verificacion: { label: 'Pendiente', color: 'warning', icon: <PendingIcon /> },
    };
    const info = statusInfo[status] || { label: status, color: 'default', icon: <></> };

    return (
        <Chip icon={info.icon} label={info.label} color={info.color} size="medium" 
            sx={{ ml: 2, fontWeight: 'bold', fontSize: '1rem', boxShadow: '0px 2px 4px rgba(0,0,0,0.2)',}} 
        />
    );
};

function ReportDetailDrawer({ report, open, onClose, onActionCompleted, onOpenChat }) {
    const [confirmModal, setConfirmModal] = useState({ open: false, action: null, title: '', content: '' });
    const [statusToChange, setStatusToChange] = useState(report.estado);

    useEffect(() => {
        if(report) {
            setStatusToChange(report.estado);
        }
    }, [report]);

    const locationCoords = (report.location && report.location.coordinates)
    ? [report.location.coordinates[1], report.location.coordinates[0]]
    : [-5.19449, -80.63282];

    const handleActionClick = (action, title, content) => {
        setConfirmModal({ open: true, action, title, content });
    };

    const handleConfirmAction = () => {
        const action = confirmModal.action;
        if (action === 'delete') {
            adminService.adminDeleteReport(report.id).then(onActionCompleted);
        } else if (action === 'toggleVisibility') {
            adminService.updateReportVisibility(report.id, report.estado).then(onActionCompleted);
        } else if (action === 'changeStatus') {
            if (statusToChange === 'pendiente_verificacion') {
                adminService.setReportToPending(report.id).then(onActionCompleted);
            } else {
                const isApproval = statusToChange === 'verificado';
                adminService.resolveReport(report.id, isApproval).then(onActionCompleted);
            }
        }
        setConfirmModal({ open: false, action: null, title: '', content: '' });
    };
    
    if (!report) return null;

    const isHidable = ['verificado', 'oculto'].includes(report.estado);
    const isHidden = report.estado === 'oculto';

    return (
        <>
            <Drawer anchor="right" open={open} onClose={onClose} PaperProps={{ sx: { bgcolor: '#212121' } }}>
                <Box sx={{ width: 400, p: 2, pt: 10 }} role="presentation">
                    <Box display="flex" alignItems="center">
                        <Typography variant="h5">Detalles del Reporte</Typography>
                        <HeaderStatusChip status={report.estado} />
                    </Box>
                    <Typography variant="caption" color="text.secondary">Código: {report.codigo_reporte}</Typography>
                    <Divider sx={{ my: 2 }} />

                    {report.foto_url && <img src={report.foto_url} alt="Reporte" style={{ width: '100%', borderRadius: '8px', marginBottom: '16px' }} />}
                    <Box sx={{ height: '200px', width: '100%', mb: 2, borderRadius: '8px', overflow: 'hidden' }}>
                         <MapContainer center={locationCoords} zoom={16} style={{ height: '100%', width: '100%' }} key={report.id}>
                            <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                            <Marker position={locationCoords} />
                        </MapContainer>
                    </Box>
                    
                    <Typography variant="h6">{report.titulo}</Typography>
                    <Typography variant="body2" color="text.secondary" paragraph>{report.descripcion || "Sin descripción."}</Typography>
                    
                    <Divider sx={{ my: 2 }} />
                    <Typography variant="subtitle1" sx={{ fontWeight: 'bold' }}>Detalles Adicionales</Typography>
                    <List dense>
                        {report.categoria_sugerida ? (
                             <DetailItem 
                                icon={<CategoryIcon fontSize="small" />} 
                                primary="Categoría Sugerida" 
                                secondary={
                                    <Typography variant="body2" sx={{ fontWeight: 'bold' }}>
                                        {report.categoria_sugerida}
                                    </Typography>
                                } 
                            />
                        ) : (
                            <DetailItem 
                                icon={<CategoryIcon fontSize="small" />} 
                                primary="Categoría" 
                                secondary={
                                    <Typography variant="body2" sx={{ fontWeight: 'bold' }}>
                                        {report.categoria}
                                    </Typography>
                                } 
                            />
                        )}
                        <DetailItem icon={<PriorityHighIcon fontSize="small" />} primary="Urgencia" secondary={<Typography variant="body2" sx={{ fontWeight: 'bold' }}>{report.urgencia || 'N/A'}</Typography>} />
                        <DetailItem icon={<CalendarTodayIcon fontSize="small" />} primary="Fecha de Creación" secondary={new Date(report.fecha_creacion).toLocaleString()} />
                        <DetailItem icon={<TimeIcon fontSize="small" />} primary="Hora del Incidente" secondary={report.hora_incidente} />
                        <DetailItem icon={<PinDropIcon fontSize="small" />} primary="Distrito" secondary={report.distrito} />
                        <DetailItem icon={<ReferenceIcon fontSize="small" />} primary="Referencia" secondary={report.referencia_ubicacion} />
                        <DetailItem icon={<ImpactIcon fontSize="small" />} primary="Impacto" secondary={report.impacto} />
                        <DetailItem icon={<TagIcon fontSize="small" />} primary="Etiquetas" secondary={report.tags?.join(', ') || 'Ninguna'} />
                    </List>

                    <Divider sx={{ my: 2 }} />
                    <Typography variant="subtitle1" sx={{ fontWeight: 'bold' }}>Información del Autor</Typography>
                     <List dense>
                        <DetailItem 
                            icon={report.es_anonimo ? <VisibilityOffIcon fontSize="small" /> : <VisibilityIcon fontSize="small" />} 
                            primary="Visibilidad Pública" 
                            secondary={
                                <Typography variant="body2" sx={{ fontWeight: 'bold' }}>
                                    {report.es_anonimo ? 'Anónimo' : 'Público'}
                                </Typography>
                            } 
                        />
                        <DetailItem icon={<PersonIcon fontSize="small" />} primary="Nombre del Autor" secondary={report.autor_nombre || (report.es_anonimo ? 'Anónimo' : 'No especificado')} />
                        <DetailItem icon={<EmailIcon fontSize="small" />} primary="Email" secondary={report.autor_email} />
                    </List>

                    {report.lider_verificador_alias && (
                        <>
                            <Divider sx={{ my: 2 }} />
                            <Typography variant="subtitle1" sx={{ fontWeight: 'bold' }}>Verificado Por</Typography>
                            <List dense>
                                <DetailItem icon={<PersonIcon fontSize="small" />} primary="Líder Vecinal" secondary={report.lider_verificador_nombre || report.lider_verificador_alias} />
                                <DetailItem icon={<EmailIcon fontSize="small" />} primary="Email del Líder" secondary={report.lider_verificador_email} />
                            </List>
                        </>
                    )}
                    
                    <Divider sx={{ my: 2 }} />
                    <Typography variant="subtitle1" sx={{ fontWeight: 'bold' }}>Acciones de Moderación</Typography>
                    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 1.5, mt: 1 }}>
                        {/* Lógica de acciones sin cambios */}
                        <FormControl fullWidth size="small">
                            <InputLabel>Cambiar Estado</InputLabel>
                            <Select value={statusToChange} label="Cambiar Estado" onChange={(e) => setStatusToChange(e.target.value)}>
                                <MenuItem value="pendiente_verificacion">Pendiente</MenuItem>
                                <MenuItem value="verificado">Verificado</MenuItem>
                                <MenuItem value="rechazado">Rechazado</MenuItem>
                            </Select>
                        </FormControl>
                        <Button variant="outlined" onClick={() => handleActionClick('changeStatus', 'Confirmar Cambio de Estado', `¿Deseas cambiar el estado a "${statusToChange.replace(/_/g, ' ')}"?`)}>Aplicar Estado</Button>

                        <Button startIcon={<ChatIcon />} variant="contained" color="primary" onClick={() => onOpenChat(report)}>Contactar Usuario</Button>
                        <Button 
                            startIcon={isHidden ? <VisibilityIcon /> : <VisibilityOffIcon />} 
                            variant="outlined" color="warning" onClick={() => handleActionClick('toggleVisibility', isHidden ? 'Mostrar Reporte' : 'Ocultar Reporte', `¿Estás seguro de que quieres ${isHidden ? 'hacer público' : 'ocultar'} este reporte?`)}
                            disabled={!isHidable}
                        > {isHidden ? 'Mostrar Reporte' : 'Ocultar Reporte'}
                        </Button>
                        <Button startIcon={<DeleteIcon />} variant="outlined" color="error" onClick={() => handleActionClick('delete', 'Confirmar Eliminación', 'Esta acción es permanente e irreversible. ¿Estás seguro?')}>Eliminar Reporte</Button>
                    </Box>
                </Box>
            </Drawer>

            <Dialog open={confirmModal.open} onClose={() => setConfirmModal({ ...confirmModal, open: false })}>
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

export default ReportDetailDrawer;