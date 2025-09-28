import React, { useEffect, useState, useCallback } from 'react';
import { Box, Paper, Grid, Typography, Select, MenuItem, FormControl, InputLabel, ButtonGroup, Button, Card, CardHeader, CardContent, CardActions, Chip, IconButton, Avatar, Tooltip, Drawer, List, ListItem, ListItemText, ListItemIcon, Divider, CircularProgress, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle, TextField } from '@mui/material';
import { Person as PersonIcon, Email as EmailIcon, CalendarToday as CalendarTodayIcon, MoreVert as MoreVertIcon, Phone as PhoneIcon, AdminPanelSettings as AdminIcon, Group as GroupIcon, CheckCircle as CheckCircleIcon, Block as BlockIcon, Star as StarIcon, Notifications as NotificationsIcon } from '@mui/icons-material';
import adminService from '../services/adminService';
import HoldToConfirmButton from '../components/HoldToConfirmButton';
import { useDebounce } from '../hooks/useDebounce';

// --- Componentes de Diseño Mejorados ---

const RoleChip = ({ role }) => {
    const roles = {
        admin: { label: 'Admin', color: 'secondary', icon: <AdminIcon /> },
        lider_vecinal: { label: 'Líder Vecinal', color: 'primary', icon: <GroupIcon /> },
        ciudadano: { label: 'Ciudadano', color: 'default', icon: <PersonIcon /> }
    };
    const { label, color, icon } = roles[role] || roles.ciudadano;
    return <Chip icon={icon} label={label} color={color} size="small" />;
};

const StatusChip = ({ status }) => {
    const isActive = status === 'activo';
    return (
        <Chip
            icon={isActive ? <CheckCircleIcon /> : <BlockIcon />}
            label={isActive ? 'Activo' : 'Suspendido'}
            color={isActive ? 'success' : 'error'}
            size="small"
            variant="outlined"
        />
    );
};

const UserCard = ({ user, onStatusChange, onDetailOpen }) => (
    <Card sx={{ height: '100%', display: 'flex', flexDirection: 'column' }}>
        <CardHeader
            avatar={<Avatar sx={{ bgcolor: 'primary.dark' }}>{user.nombre ? user.nombre[0].toUpperCase() : '?'}</Avatar>}
            action={
                <Tooltip title="Ver Detalles y Acciones">
                    <IconButton onClick={() => onDetailOpen(user)}><MoreVertIcon /></IconButton>
                </Tooltip>
            }
            title={<Typography variant="h6" noWrap>{user.nombre || 'Sin Nombre'}</Typography>}
            subheader={<Typography variant="body2" color="text.secondary" noWrap>{user.alias || user.email}</Typography>}
        />
        <CardContent sx={{ flexGrow: 1 }}>
            <Box sx={{ display: 'flex', gap: 1, mb: 2, flexWrap: 'wrap' }}>
                <RoleChip role={user.rol} />
                <StatusChip status={user.status} />
            </Box>
            <Typography variant="caption" color="text.secondary">
                Registrado: {user.fecha_registro_formateada}
            </Typography>
        </CardContent>
        <CardActions sx={{ px: 2, pb: 2 }}>
            {user.status === 'activo' ? (
                <HoldToConfirmButton onConfirm={() => onStatusChange(user.id, user.status)} label="Suspender" color="error" />
            ) : (
                <HoldToConfirmButton onConfirm={() => onStatusChange(user.id, user.status)} label="Reactivar" color="success" />
            )}
        </CardActions>
    </Card>
);


// --- Componente Principal ---
function UsersPage() {
    const [users, setUsers] = useState([]);
    const [loading, setLoading] = useState(true);
    // MEJORA: Añadimos 'search' al estado de los filtros
    const [filters, setFilters] = useState({ search: '', role: '', status: '', sortBy: 'newest' });
    const [drawerOpen, setDrawerOpen] = useState(false);
    const [selectedUser, setSelectedUser] = useState(null);
    const [userDetails, setUserDetails] = useState(null);
    const [detailLoading, setDetailLoading] = useState(false);
    const [promoModal, setPromoModal] = useState({ open: false, type: '', data: null });
    const [adminPassword, setAdminPassword] = useState('');
    const [confirmText, setConfirmText] = useState('');

    // NUEVO: Estados para la funcionalidad de notificación
    const [notificationModalOpen, setNotificationModalOpen] = useState(false);
    const [notificationData, setNotificationData] = useState({ title: '', body: '' });

    // Usamos debounce para el campo de búsqueda para no hacer peticiones en cada tecleo
    const debouncedSearch = useDebounce(filters.search, 500);

    const fetchUsers = useCallback(() => {
        setLoading(true);
        const activeFilters = { 
            role: filters.role,
            status: filters.status,
            sortBy: filters.sortBy,
            search: debouncedSearch 
        };
        adminService.getAllUsers(activeFilters)
            .then(data => setUsers(data))
            .catch(err => console.error("Error fetching users:", err))
            .finally(() => setLoading(false));
    }, [filters.role, filters.status, filters.sortBy, debouncedSearch]);

    useEffect(() => {
        fetchUsers();
    }, [fetchUsers]);

    const handleFilterChange = (event) => {
        const { name, value } = event.target;
        setFilters(prev => ({ ...prev, [name]: value }));
    };
    
    const handleSortChange = (sortByValue) => {
        setFilters(prev => ({ ...prev, sortBy: sortByValue }));
    };

    const handleSendNotification = async () => {
        if (!notificationData.title || !notificationData.body) {
            alert('El título y el cuerpo de la notificación son requeridos.');
            return;
        }

        const userIds = users.map(user => user.id);
        if (userIds.length === 0) {
            alert('No hay usuarios a quienes enviar la notificación.');
            return;
        }

        try {
            await adminService.sendNotification(userIds, notificationData.title, notificationData.body);
            alert(`Notificación enviada a ${userIds.length} usuario(s).`);
            setNotificationModalOpen(false);
            setNotificationData({ title: '', body: '' });
        } catch (error) {
            console.error("Fallo al enviar la notificación:", error);
            const message = error.response?.data?.message || 'Error al enviar la notificación.';
            alert(message);
        }
    };

    const handleStatusChange = (userId, currentStatus) => {
        const newStatus = currentStatus === 'activo' ? 'suspendido' : 'activo';
        adminService.updateUserStatus(userId, newStatus).then(fetchUsers);
    };
    
    const handleDetailOpen = (user) => {
        setSelectedUser(user);
        setDrawerOpen(true);
        setDetailLoading(true);
        setUserDetails(null); 
        adminService.getUserDetails(user.id)
            .then(data => setUserDetails(data))
            .catch(err => console.error("Error fetching user details", err))
            .finally(() => setDetailLoading(false));
    };

    const handleRoleChange = (newRole) => {
        if (!selectedUser || newRole === selectedUser.rol) return;
        setDrawerOpen(false);
        if (newRole === 'admin') {
            setPromoModal({ open: true, type: 'admin', data: { userId: selectedUser.id, newRole } });
        } else if (newRole === 'lider_vecinal') {
            setPromoModal({ open: true, type: 'lider', data: { userId: selectedUser.id, newRole } });
        } else {
            adminService.updateUserRole(selectedUser.id, newRole).then(fetchUsers);
        }
    };
    
    const closePromoModal = () => {
        setPromoModal({ open: false, type: '', data: null });
        setAdminPassword('');
        setConfirmText('');
    };

    const handleConfirmPromotion = () => {
        const { userId, newRole } = promoModal.data;
        adminService.updateUserRole(userId, newRole, promoModal.type === 'admin' ? adminPassword : null)
            .then(() => {
                fetchUsers();
                closePromoModal();
            })
            .catch(err => alert(err.response?.data?.message || 'Ocurrió un error.'));
    };

    return (
        <Box>
            <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>Gestión de Usuarios</Typography>
            
            <Paper sx={{ p: 2, mb: 3, display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'center', minHeight: '80px', justifyContent: 'center',maxWidth: '1400px'}}>
                <TextField 
                    label="Buscar por nombre o email"
                    name="search"
                    value={filters.search}
                    onChange={handleFilterChange}
                    size="small"
                    sx={{ flexGrow: 1, minWidth: '200px' }}
                />
                <FormControl sx={{ minWidth: 150 }} size="small">
                    <InputLabel>Rol</InputLabel>
                    <Select name="role" value={filters.role} label="Rol" onChange={handleFilterChange}>
                        <MenuItem value="">Todos los Roles</MenuItem>
                        <MenuItem value="ciudadano">Ciudadano</MenuItem>
                        <MenuItem value="lider_vecinal">Líder Vecinal</MenuItem>
                        <MenuItem value="admin">Admin</MenuItem>
                    </Select>
                </FormControl>
                <FormControl sx={{ minWidth: 150 }} size="small">
                    <InputLabel>Estado</InputLabel>
                    <Select name="status" value={filters.status} label="Estado" onChange={handleFilterChange}>
                        <MenuItem value="">Todos los Estados</MenuItem>
                        <MenuItem value="activo">Activo</MenuItem>
                        <MenuItem value="suspendido">Suspendido</MenuItem>
                    </Select>
                </FormControl>
                <Button 
                    variant="contained" 
                    startIcon={<NotificationsIcon />} 
                    onClick={() => setNotificationModalOpen(true)}
                    sx={{ ml: 'auto' }}
                >
                    Notificar
                </Button>
                <ButtonGroup size="small" sx={{ ml: 'auto' }}>
                    <Button variant={filters.sortBy === 'newest' ? 'contained' : 'outlined'} onClick={() => handleSortChange('newest')}>Más Recientes</Button>
                    <Button variant={filters.sortBy === 'oldest' ? 'contained' : 'outlined'} onClick={() => handleSortChange('oldest')}>Más Antiguos</Button>
                    <Button variant={filters.sortBy === 'name' ? 'contained' : 'outlined'} onClick={() => handleSortChange('name')}>Por Nombre</Button>
                </ButtonGroup>
            </Paper>

            {loading ? (
                 <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}><CircularProgress /></Box>
            ) : (
                <Grid container spacing={3}>
                    {users.map(user => (
                        <Grid item key={user.id} xs={12} sm={6} lg={4}>
                            <UserCard user={user} onStatusChange={handleStatusChange} onDetailOpen={handleDetailOpen} />
                        </Grid>
                    ))}
                </Grid>
            )}

            {/* --- DRAWER DE DETALLES --- */}
            <Drawer anchor="right" open={drawerOpen} onClose={() => setDrawerOpen(false)}>
                <Box sx={{ width: 350, p: 2,pt: 10}} role="presentation">
                    {selectedUser && (
                        <>
                            <Typography variant="h5" sx={{ mb: 2 }}>Detalles del Usuario</Typography>
                            <Divider />
                            <List>
                                <ListItem><ListItemIcon><PersonIcon /></ListItemIcon><ListItemText primary="Nombre" secondary={selectedUser.nombre || 'No disponible'} /></ListItem>
                                <ListItem><ListItemIcon><PersonIcon color="action" /></ListItemIcon><ListItemText primary="Alias" secondary={selectedUser.alias || 'No disponible'} /></ListItem>
                                <ListItem><ListItemIcon><EmailIcon /></ListItemIcon><ListItemText primary="Email" secondary={selectedUser.email} /></ListItem>
                                <ListItem><ListItemIcon><PhoneIcon /></ListItemIcon><ListItemText primary="Teléfono" secondary={selectedUser.telefono || 'No registrado'} /></ListItem>
                                <ListItem><ListItemIcon><CalendarTodayIcon /></ListItemIcon><ListItemText primary="Registro" secondary={selectedUser.fecha_registro_formateada} /></ListItem>
                                <ListItem><ListItemIcon><StarIcon color="warning"/></ListItemIcon><ListItemText primary="Puntos" secondary={selectedUser.puntos ?? '0'} /></ListItem>
                            </List>
                            <Divider sx={{ my: 2 }} />
                            <Typography variant="h6" sx={{ mb: 1 }}>Cambiar Rol</Typography>
                            <FormControl fullWidth size="small">
                                <InputLabel>Nuevo Rol</InputLabel>
                                <Select value={selectedUser.rol} label="Nuevo Rol" onChange={(e) => handleRoleChange(e.target.value)}>
                                    <MenuItem value="ciudadano">Ciudadano</MenuItem>
                                    <MenuItem value="lider_vecinal">Líder Vecinal</MenuItem>
                                    <MenuItem value="admin">Admin</MenuItem>
                                </Select>
                            </FormControl>
                            <Divider sx={{ my: 2 }}  />
                             {detailLoading ? (
                            <Box sx={{ display: 'flex', justifyContent: 'center', my: 4 }}><CircularProgress /></Box>
                        ) : userDetails ? (
                            <>
                                {/* --- Sección de Insignias --- */}
                                <Typography variant="h6" sx={{ mt: 2, mb: 1 }}>Insignias Obtenidas</Typography>
                                {userDetails.insignias.length > 0 ? (
                                    <Box sx={{ display: 'flex', gap: 2, flexWrap: 'wrap' }}>
                                        {userDetails.insignias.map(insignia => (
                                            <Tooltip key={insignia.nombre} title={`${insignia.nombre}: ${insignia.descripcion}`}>
                                                <Avatar src={insignia.icono_url} sx={{ width: 56, height: 56, border: '2px solid', borderColor: 'divider' }} />
                                            </Tooltip>
                                        ))}
                                    </Box>
                                ) : (
                                    <Typography variant="body2" color="text.secondary">Este usuario aún no ha ganado insignias.</Typography>
                                )}
                                
                                {/* --- Sección de Reportes Recientes --- */}
                                <Typography variant="h6" sx={{ mt: 3, mb: 1 }}>Últimos Reportes</Typography>
                                {userDetails.reportes.length > 0 ? (
                                    <List dense>
                                        {userDetails.reportes.map(report => (
                                            <ListItem key={report.codigo_reporte} disablePadding>
                                                <ListItemText 
                                                    primary={
                                                        <Box component="span" sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                                                            <Typography variant="body2" component="span" sx={{ fontWeight: 'bold', flexGrow: 1 }} noWrap>
                                                                {report.titulo}
                                                            </Typography>
                                                            <Chip label={report.urgencia} color={report.urgencia === 'Alta' ? 'error' : 'warning'} size="small" sx={{ ml: 1 }} />
                                                        </Box>
                                                    }
                                                    secondary={`#${report.codigo_reporte} - ${report.fecha}`} 
                                                />
                                            </ListItem>
                                        ))}
                                    </List>
                                ) : (
                                     <Typography variant="body2" color="text.secondary">Este usuario no ha creado reportes.</Typography>
                                )}
                            </>
                        ) : (
                           <Typography variant="body2" color="error" sx={{ mt: 2 }}>No se pudieron cargar los detalles.</Typography>
                        )}
                        
                        <Divider sx={{ my: 2 }} />
                            <Button onClick={() => setDrawerOpen(false)} sx={{ mt: 3 }}>Cerrar</Button>
                        </>
                    )}
                </Box>
            </Drawer>

            {/* --- MODALES DE CONFIRMACIÓN DE ROL --- */}
            <Dialog open={promoModal.open && promoModal.type === 'lider'} onClose={closePromoModal}>
                <DialogTitle>Confirmar Promoción</DialogTitle>
                <DialogContent><DialogContentText>¿Estás seguro de que quieres promover a este usuario a Líder Vecinal?</DialogContentText></DialogContent>
                <DialogActions>
                    <Button onClick={closePromoModal}>Cancelar</Button>
                    <Button onClick={handleConfirmPromotion} variant="contained">Confirmar</Button>
                </DialogActions>
            </Dialog>

            <Dialog open={promoModal.open && promoModal.type === 'admin'} onClose={closePromoModal}>
                <DialogTitle>Confirmación de Seguridad Requerida</DialogTitle>
                <DialogContent>
                    <DialogContentText>Está a punto de otorgar privilegios de Administrador. Para continuar, escriba "PROMOVER" y su contraseña actual de administrador.</DialogContentText>
                    <TextField autoFocus margin="dense" label='Escriba "PROMOVER"' type="text" fullWidth variant="standard" value={confirmText} onChange={(e) => setConfirmText(e.target.value)} />
                    <TextField margin="dense" label="Su Contraseña de Administrador" type="password" fullWidth variant="standard" value={adminPassword} onChange={(e) => setAdminPassword(e.target.value)} />
                </DialogContent>
                <DialogActions>
                    <Button onClick={closePromoModal}>Cancelar</Button>
                    <Button onClick={handleConfirmPromotion} variant="contained" color="error" disabled={confirmText !== 'PROMOVER' || !adminPassword}>Confirmar Promoción</Button>
                </DialogActions>
            </Dialog>
            <Dialog open={notificationModalOpen} onClose={() => setNotificationModalOpen(false)} fullWidth maxWidth="sm">
                <DialogTitle>Enviar Notificación a {users.length} Usuario(s)</DialogTitle>
                <DialogContent>
                    <DialogContentText sx={{ mb: 2 }}>
                        El mensaje se enviará a todos los usuarios actualmente visibles en la pantalla.
                        Si has aplicado filtros, solo ellos recibirán el mensaje.
                    </DialogContentText>
                    <TextField
                        autoFocus
                        margin="dense"
                        label="Título de la Notificación"
                        type="text"
                        fullWidth
                        variant="outlined"
                        value={notificationData.title}
                        onChange={(e) => setNotificationData(prev => ({ ...prev, title: e.target.value }))}
                    />
                    <TextField
                        margin="dense"
                        label="Cuerpo del Mensaje"
                        type="text"
                        fullWidth
                        multiline
                        rows={4}
                        variant="outlined"
                        value={notificationData.body}
                        onChange={(e) => setNotificationData(prev => ({ ...prev, body: e.target.value }))}
                    />
                </DialogContent>
                <DialogActions>
                    <Button onClick={() => setNotificationModalOpen(false)}>Cancelar</Button>
                    <Button onClick={handleSendNotification} variant="contained">Enviar</Button>
                </DialogActions>
            </Dialog>

        </Box>
    );
}

export default UsersPage;