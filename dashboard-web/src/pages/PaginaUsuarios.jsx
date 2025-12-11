import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Paper, Grid, Typography, Select, MenuItem, FormControl, InputLabel,
  ButtonGroup, Button, CircularProgress, TextField, Tabs, Tab,
  InputAdornment, Alert, AlertTitle, Snackbar, Badge, Divider, Stack
} from '@mui/material';
import {
  Notifications as NotificationsIcon,
  Search as SearchIcon,
  People as PeopleIcon,
  FilterList as FilterIcon,
  Sort as SortIcon
} from '@mui/icons-material';

import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce'; 

// Import components
import ModalNotificacion from '../components/Usuarios/ModalNotificacion';
import PanelSolicitudesRol from '../components/Usuarios/PanelSolicitudesRol';
import ModalAsignarZonas from '../components/Usuarios/ModalAsignarZonas';
import TarjetaUsuario from '../components/Usuarios/TarjetaUsuario';
import DrawerDetalleUsuario from '../components/Usuarios/DrawerDetalleUsuario';
import ModalesConfirmacionRol from '../components/Usuarios/ModalesConfirmacionRol';

function PaginaUsuarios() {
  // State Hooks
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' });
  const handleCloseSnackbar = () => setSnackbar({ ...snackbar, open: false });
  
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filters, setFilters] = useState({ search: '', role: '', status: '', sortBy: 'newest' });
  const [drawerOpen, setDrawerOpen] = useState(false);
  const [selectedUser, setSelectedUser] = useState(null);
  const [userDetails, setUserDetails] = useState(null);
  const [detailLoading, setDetailLoading] = useState(false);
  const [promoModal, setPromoModal] = useState({ open: false, type: '', data: null });
  const [adminPassword, setAdminPassword] = useState('');
  const [confirmText, setConfirmText] = useState('');
  const [tabIndex, setTabIndex] = useState(0);
  const [massNotificationModalOpen, setMassNotificationModalOpen] = useState(false);
  const [singleNotificationModal, setSingleNotificationModal] = useState({ open: false, user: null });
  const [isSendingNotification, setIsSendingNotification] = useState(false);
  const [zonasModalOpen, setZonasModalOpen] = useState(false);
  const [selectedLider, setSelectedLider] = useState(null);
  const [isSavingZone, setIsSavingZone] = useState(false);
  const [globalError, setGlobalError] = useState('');
  const [countSolicitudes, setCountSolicitudes] = useState(0);

  const debouncedSearch = useDebounce(filters.search, 500);

  // --- LOGICA (Sin cambios, se mantiene igual) ---
  const fetchSolicitudesCount = useCallback(() => {
    adminService.getSolicitudesRol()
      .then(data => setCountSolicitudes(data.length))
      .catch(err => console.error("Error cargando contador:", err));
  }, []);

  const fetchUsers = useCallback(() => {
    setLoading(true);
    setGlobalError('');
    const activeFilters = {
      role: filters.role,
      status: filters.status,
      sortBy: filters.sortBy,
      search: debouncedSearch
    };
    adminService.getAllUsers(activeFilters)
      .then(data => setUsers(data))
      .catch(err => {
        console.error("Error fetching users:", err);
        setGlobalError('Error al cargar la lista de usuarios.');
      })
      .finally(() => setLoading(false));
  }, [filters.role, filters.status, filters.sortBy, debouncedSearch]);

  useEffect(() => {
    fetchUsers();
    fetchSolicitudesCount();
  }, [fetchUsers, fetchSolicitudesCount]);

  const handleFilterChange = (event) => {
    const { name, value } = event.target;
    setFilters(prev => ({ ...prev, [name]: value }));
  };
  const handleSortChange = (sortByValue) => {
    setFilters(prev => ({ ...prev, sortBy: sortByValue }));
  };
  const handleTabChange = (e, newValue) => {
    setTabIndex(newValue);
    if(newValue === 1) fetchSolicitudesCount(); 
  };

  const handleStatusChange = (userId, currentStatus) => {
    const newStatus = currentStatus === 'activo' ? 'suspendido' : 'activo';
    adminService.updateUserStatus(userId, newStatus).then(() => {
      setTimeout(fetchUsers, 50); 
      if (selectedUser && selectedUser.id === userId) {
        setSelectedUser(prev => ({ ...prev, status: newStatus }));
      }
    });
  };
  
  const handleConfirmPromotion = () => {
    const { userId, newRole } = promoModal.data;
    const password = promoModal.type === 'admin' ? adminPassword : null;
    adminService.updateUserRole(userId, newRole, password)
      .then(() => { closePromoModal(); setTimeout(fetchUsers, 300); })
      .catch(err => alert(err.response?.data?.message || 'Ocurrió un error.'));
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
  const handleDetailClose = () => { setDrawerOpen(false); setTimeout(() => { setSelectedUser(null); setUserDetails(null); }, 300); };
  
  const handleRoleChange = (newRole) => {
    if (!selectedUser || newRole === selectedUser.rol) return;
    setDrawerOpen(false); 
    if (newRole === 'admin' || newRole === 'lider_vecinal' || newRole === 'reportero') {
      setPromoModal({ open: true, type: newRole, data: { userId: selectedUser.id, newRole } });
    } else {
       adminService.updateUserRole(selectedUser.id, newRole).then(() => { setTimeout(fetchUsers, 300); });
    }
  };
  const closePromoModal = () => { setPromoModal({ open: false, type: '', data: null }); setAdminPassword(''); setConfirmText(''); };
  const handleOpenMassNotification = () => setMassNotificationModalOpen(true);
  const handleCloseMassNotification = () => { setMassNotificationModalOpen(false); setIsSendingNotification(false); };
  const handleOpenSingleNotification = (user) => { setSingleNotificationModal({ open: true, user: user }); setDrawerOpen(false); };
  const handleCloseSingleNotification = () => { setSingleNotificationModal({ open: false, user: null }); setIsSendingNotification(false); };
  const handleOpenZonasModal = (lider) => { setSelectedLider(lider); setZonasModalOpen(true); setDrawerOpen(false); };
  const handleCloseZonasModal = () => { setSelectedLider(null); setZonasModalOpen(false); setIsSavingZone(false); };

  const handleSaveZonas = (distritosArray) => {
    if (!selectedLider) return;
    setIsSavingZone(true);
    setGlobalError('');
    adminService.asignarZonasLider(selectedLider.id, distritosArray)
      .then(() => {
        setSnackbar({ open: true, message: 'Zonas asignadas correctamente', severity: 'success' });
        setTimeout(handleCloseSnackbar, 3000);
        handleCloseZonasModal(); 
      })
      .catch(err => {
        setGlobalError(err.response?.data?.message || 'Error al guardar zonas');
        setIsSavingZone(false); 
      });
  };

  const handleSendMassNotification = (title, body) => {
    setIsSendingNotification(true);
    const userIds = users.map(user => user.id);
    if (userIds.length === 0) {
      alert('No hay usuarios a quienes enviar la notificación.');
      setIsSendingNotification(false); return;
    }
    setGlobalError('');
    adminService.sendNotification(userIds, title, body)
      .then(() => {
        setSnackbar({ open: true, message: `Notificación enviada a ${userIds.length} usuarios.`, severity: 'success' });
        handleCloseMassNotification(); 
      })
      .catch(error => {
        setGlobalError(error.response?.data?.message || 'Error al enviar la notificación.');
        setIsSendingNotification(false); 
      });
  };

  const handleSendSingleNotification = (title, body) => {
    if (!singleNotificationModal.user) return;
    setIsSendingNotification(true);
    setGlobalError('');
    const userId = singleNotificationModal.user.id;
    adminService.sendNotification([userId], title, body)
      .then(() => {
        setSnackbar({ open: true, message: `Notificación enviada a ${singleNotificationModal.user.alias}.`, severity: 'success' });
        setTimeout(handleCloseSnackbar, 3000);
        handleCloseSingleNotification(); 
      })
      .catch(error => {
        setGlobalError(error.response?.data?.message || 'Error al enviar la notificación.');
        setIsSendingNotification(false); 
      });
  };

  // --- RENDERIZADO MEJORADO ---
  return (
    <Box sx={{ p: { xs: 2, md: 3 }, maxWidth: '1200px', mx: 'auto' }}>
      
      {/* 1. Header más limpio */}
      <Box sx={{ mb: 4 }}>
        <Typography variant="h4" gutterBottom sx={{ fontWeight: 800, letterSpacing: '-0.5px' }}>
          Gestión de Usuarios
        </Typography>
        <Alert severity="info" icon={<PeopleIcon />} variant="outlined">
            <AlertTitle>Administración de Usuarios</AlertTitle>
            Administra todos los usuarios de la plataforma, asigna roles, gestiona el estado de sus cuentas y modera las solicitudes de rol.
        </Alert>
      </Box>

      {/* Global Error */}
      {globalError && <Alert severity="error" sx={{ mb: 3 }} onClose={() => setGlobalError('')}>{globalError}</Alert>}

      {/* 2. Tabs con Diseño Mejorado y Fix del Badge */}
      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}>
        <Tabs 
          value={tabIndex} 
          onChange={handleTabChange} 
          sx={{ '& .MuiTab-root': { textTransform: 'none', fontWeight: 600, fontSize: '1rem', minHeight: 48 } }}
        >
          <Tab label="Directorio de Usuarios" icon={<PeopleIcon sx={{mb:0, mr:1}}/>} iconPosition="start" />
          
          {/* TAB FIX: Agregamos padding horizontal extra (px: 4) para el badge */}
          <Tab label={
            <Badge 
              badgeContent={countSolicitudes} 
              color="error" 
              max={99}
              sx={{ 
                '& .MuiBadge-badge': { right: -15, top: 2, border: '2px solid white' } 
              }}
            >
              Solicitudes de Rol
            </Badge>
          } 
          sx={{ px: 4, overflow: 'visible' }} // <-- CLAVE: px aumentado y overflow visible
          />
        </Tabs>
      </Box>

      {/* Panel 0: Usuarios */}
      {tabIndex === 0 && (
        <>
        {/* 3. Barra de Filtros Reorganizada y Profesional */}
        <Paper 
          elevation={0} 
          variant="outlined"
          sx={{ 
            p: 2, mb: 4, 
            borderRadius: 2, 
            display: 'flex', 
            flexDirection: { xs: 'column', lg: 'row' }, 
            gap: 2, 
            alignItems: 'center',
            bgcolor: 'background.paper'
          }} 
        >
            {/* Grupo Búsqueda */}
            <TextField
                placeholder="Buscar por nombre, alias o email..." 
                name="search"
                value={filters.search} onChange={handleFilterChange}
                size="small" 
                sx={{ flexGrow: 1, minWidth: { xs: '100%', md: '300px' } }}
                InputProps={{ 
                  startAdornment: (<InputAdornment position="start"><SearchIcon color="action"/></InputAdornment>),
                  sx: { borderRadius: 2 }
                }}
            />

            <Divider orientation="vertical" flexItem sx={{ display: { xs: 'none', lg: 'block' } }} />

            {/* Grupo Filtros Selectores */}
            <Stack direction="row" spacing={2} sx={{ width: { xs: '100%', lg: 'auto' } }}>
              <FormControl size="small" sx={{ minWidth: 160 }}>
                  <InputLabel>Filtrar por Rol</InputLabel>
                  <Select name="role" value={filters.role} label="Filtrar por Rol" onChange={handleFilterChange} sx={{ borderRadius: 2 }}>
                    <MenuItem value="">Todos los Roles</MenuItem>
                    <MenuItem value="ciudadano">Ciudadano</MenuItem>
                    <MenuItem value="lider_vecinal">Líder Vecinal</MenuItem>
                    <MenuItem value="reportero">Reportero</MenuItem>
                    <MenuItem value="admin">Administrador</MenuItem>
                  </Select>
              </FormControl>
              <FormControl size="small" sx={{ minWidth: 130 }}>
                  <InputLabel>Estado</InputLabel>
                  <Select name="status" value={filters.status} label="Estado" onChange={handleFilterChange} sx={{ borderRadius: 2 }}>
                    <MenuItem value="">Cualquier Estado</MenuItem>
                    <MenuItem value="activo">Activo</MenuItem>
                    <MenuItem value="suspendido">Suspendido</MenuItem>
                  </Select>
              </FormControl>
            </Stack>

            {/* Grupo Botones Acción */}
            <Box sx={{ display: 'flex', gap: 1, ml: { lg: 'auto' }, width: { xs: '100%', lg: 'auto' }, justifyContent: 'flex-end' }}>
                <ButtonGroup size="small" variant="outlined" sx={{ mr: 1 }}>
                    <Button 
                      variant={filters.sortBy === 'newest' ? 'contained' : 'outlined'} 
                      onClick={() => handleSortChange('newest')}
                    >
                      <SortIcon fontSize="small"/> Recientes
                    </Button>
                    <Button 
                      variant={filters.sortBy === 'oldest' ? 'contained' : 'outlined'} 
                      onClick={() => handleSortChange('oldest')}
                    >
                      Antiguos
                    </Button>
                    <Button variant={filters.sortBy === 'name' ? 'contained' : 'outlined'} onClick={() => handleSortChange('name')}>Nombre</Button>
                </ButtonGroup>
                
                <Button
                  variant="contained" color="secondary"
                  startIcon={<NotificationsIcon />}
                  onClick={handleOpenMassNotification}
                  disabled={users.length === 0 || loading} 
                  sx={{ borderRadius: 2, whiteSpace: 'nowrap', fontWeight: 'bold' }}
                >
                  Notificar ({users.length})
                </Button>
            </Box>
        </Paper>

        {/* 4. Grid de Usuarios Optimizado */}
        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', p: 8 }}><CircularProgress /></Box>
        ) : users.length === 0 ? (
           <Alert severity="info" variant="outlined" sx={{mt: 2, borderRadius: 2}}>
             No se encontraron usuarios que coincidan con los filtros actuales.
           </Alert>
        ) : (
          <Grid container spacing={3}>
            {users.map(user => (
              // GRID FIX: Ajuste de breakpoints para mejor distribución (4 tarjetas en pantallas grandes)
              <Grid item key={user.id} xs={12} sm={6} md={4} lg={3} xl={2.4}>
                <Box sx={{ height: '100%' }}>
                  <TarjetaUsuario
                    user={user}
                    onStatusChange={handleStatusChange}
                    onDetailOpen={handleDetailOpen}
                    onAssignZone={handleOpenZonasModal}
                  />
                </Box>
              </Grid>
            ))}
          </Grid>
        )}
      </>
      )}

      {/* Tab Panel 1: Solicitudes */}
      {tabIndex === 1 && <PanelSolicitudesRol />}

      {/* --- Modales y Drawers (Sin Cambios Visuales Aquí) --- */}
      <DrawerDetalleUsuario
        open={drawerOpen}
        onClose={handleDetailClose}
        selectedUser={selectedUser}
        userDetails={userDetails}
        detailLoading={detailLoading}
        onRoleChange={handleRoleChange}
        onStatusChange={handleStatusChange}
        onSendNotification={handleOpenSingleNotification}
        onAssignZone={handleOpenZonasModal}
      />
      <ModalesConfirmacionRol
        promoModal={promoModal}
        onClose={closePromoModal}
        onConfirm={handleConfirmPromotion}
        adminPassword={adminPassword}
        setAdminPassword={setAdminPassword}
        confirmText={confirmText}
        setConfirmText={setConfirmText}
      />
      <ModalNotificacion
        open={massNotificationModalOpen}
        onClose={handleCloseMassNotification}
        onSubmit={handleSendMassNotification}
        targetUserCount={users.length}
        isSending={isSendingNotification}
      />
      <ModalNotificacion
        open={singleNotificationModal.open}
        onClose={handleCloseSingleNotification}
        onSubmit={handleSendSingleNotification}
        targetUserCount={1}
        targetUserName={singleNotificationModal.user?.alias || singleNotificationModal.user?.nombre}
        isSending={isSendingNotification}
      />
      <Snackbar 
        open={snackbar.open} 
        autoHideDuration={6000} 
        onClose={handleCloseSnackbar}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }} 
      >
        <Alert onClose={handleCloseSnackbar} severity={snackbar.severity} sx={{ width: '100%', borderRadius: 2 }}>
          {snackbar.message}
        </Alert>
      </Snackbar>
      {selectedLider && (
        <ModalAsignarZonas
          open={zonasModalOpen}
          onClose={handleCloseZonasModal}
          onSave={handleSaveZonas}
          lider={selectedLider}
          isSaving={isSavingZone}
        />
      )}
    </Box>
  );
}

export default PaginaUsuarios;