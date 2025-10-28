import React, { useEffect, useState, useCallback } from 'react';
import {
  Box, Paper, Grid, Typography, Select, MenuItem, FormControl, InputLabel,
  ButtonGroup, Button, CircularProgress, TextField, Tabs, Tab,
  InputAdornment, Alert, AlertTitle
} from '@mui/material';
import {
  Notifications as NotificationsIcon,
  Search as SearchIcon,
  People as PeopleIcon
} from '@mui/icons-material';

import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce'; // Ensure this path is correct

// Import components
import ModalNotificacion from '../components/Usuarios/ModalNotificacion';
import PanelSolicitudesRol from '../components/Usuarios/PanelSolicitudesRol';
import ModalAsignarZonas from '../components/Usuarios/ModalAsignarZonas';
import TarjetaUsuario from '../components/Usuarios/TarjetaUsuario';
import DrawerDetalleUsuario from '../components/Usuarios/DrawerDetalleUsuario';
import ModalesConfirmacionRol from '../components/Usuarios/ModalesConfirmacionRol';

/**
 * @file src/pages/PaginaUsuarios.jsx
 * @component PaginaUsuarios
 *
 * @description
 * Renderiza la página principal de "Gestión de Usuarios".
 *
 * Este es un componente "inteligente" (contenedor) que orquesta la mayoría de
 * las funcionalidades relacionadas con la administración de usuarios.
 *
 * Responsabilidades Principales:
 * 1. **Gestión de Pestañas:** Controla la navegación entre "Todos los Usuarios"
 * y "Solicitudes de Rol" (`PanelSolicitudesRol`).
 * 2. **Carga y Filtro (Pestaña 0):**
 * - Carga la lista de usuarios (`adminService.getAllUsers`).
 * - Mantiene el estado de los filtros (búsqueda, rol, estado, orden).
 * - Utiliza `useDebounce` en el campo de búsqueda para optimizar las
 * llamadas a la API.
 * - Renderiza la lista de usuarios usando `TarjetaUsuario`.
 * 3. **Orquestación de Modales y Drawers:**
 * - Maneja el estado (apertura, datos seleccionados, estado de carga)
 * para todos los componentes de diálogo:
 * - `DrawerDetalleUsuario`: Para ver detalles, estadísticas y
 * acciones de un usuario.
 * - `ModalesConfirmacionRol`: Para confirmar la promoción de un
 * usuario (ej. a Admin, Líder).
 * - `ModalAsignarZonas`: Para asignar zonas a un 'lider_vecinal'.
 * - `ModalNotificacion` (Masiva): Para enviar notificaciones a
 * todos los usuarios *visibles* en los filtros actuales.
 * - `ModalNotificacion` (Individual): Para enviar una notificación
 * a un usuario específico (desde el Drawer).
 * 4. **Gestión de Acciones:**
 * - Contiene los *handlers* (ej. `handleStatusChange`,
 * `handleSaveZonas`, `handleSendMassNotification`) que llaman a los
 * servicios de `adminService` y gestionan el estado de carga
 * (`isSendingNotification`, `isSavingZone`) y los errores
 * (`globalError`).
 *
 * @returns {JSX.Element} La página completa de gestión de usuarios.
 */
function PaginaUsuarios() {
  // State Hooks
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

  const debouncedSearch = useDebounce(filters.search, 500);

  // Data Fetching
  /**
   * Carga la lista de usuarios basada en los filtros actuales y
   * el término de búsqueda (debounced).
   */
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

  // Effect para la carga inicial y recarga por filtros
  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  // UI Handlers
  const handleFilterChange = (event) => {
    const { name, value } = event.target;
    setFilters(prev => ({ ...prev, [name]: value }));
  };
  const handleSortChange = (sortByValue) => {
    setFilters(prev => ({ ...prev, sortBy: sortByValue }));
  };
  const handleTabChange = (e, newValue) => setTabIndex(newValue);

  // Action Handlers (with local updates or delayed fetch)
  /**
   * Cambia el estado de un usuario (activo/suspendido) y refresca la lista.
   */
  const handleStatusChange = (userId, currentStatus) => {
    const newStatus = currentStatus === 'activo' ? 'suspendido' : 'activo';
    adminService.updateUserStatus(userId, newStatus).then(() => {
      // Espera un frame para que se complete la acción antes de recargar
      setTimeout(fetchUsers, 50); 
      // Actualiza el estado local si el usuario está en el drawer
      if (selectedUser && selectedUser.id === userId) {
        setSelectedUser(prev => ({ ...prev, status: newStatus }));
      }
    });
  };
  
  /**
   * Confirma la promoción de rol (desde el modal de confirmación).
   */
  const handleConfirmPromotion = () => {
    const { userId, newRole } = promoModal.data;
    const password = promoModal.type === 'admin' ? adminPassword : null;

    adminService.updateUserRole(userId, newRole, password)
      .then(() => {
        closePromoModal(); // Cierra el modal
        setTimeout(fetchUsers, 300); // Refresca DESPUÉS que el modal se cierre
      })
      .catch(err => {
        alert(err.response?.data?.message || 'Ocurrió un error.');
        // Asegúrate de manejar el estado de carga si el modal lo usa
      });
  };

  // Modal Handlers (Opening and Closing)
  /**
   * Abre el drawer de detalles y carga la información del usuario.
   */
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
  
  /**
   * Inicia el flujo de cambio de rol (desde el drawer).
   * Cierra el drawer y abre el modal de confirmación apropiado.
   */
  const handleRoleChange = (newRole) => {
    if (!selectedUser || newRole === selectedUser.rol) return;
    setDrawerOpen(false); // Close drawer first

    if (newRole === 'admin' || newRole === 'lider_vecinal' || newRole === 'reportero') {
      // Abre el modal de confirmación para roles que requieren validación
      setPromoModal({ open: true, type: newRole, data: { userId: selectedUser.id, newRole } });
    } else {
       // Si es un cambio simple (ej. a ciudadano), ejecuta y refresca
       adminService.updateUserRole(selectedUser.id, newRole).then(() => {
           setTimeout(fetchUsers, 300); // Refresca con delay
       });
    }
  };
  const closePromoModal = () => { setPromoModal({ open: false, type: '', data: null }); setAdminPassword(''); setConfirmText(''); };
  const handleOpenMassNotification = () => setMassNotificationModalOpen(true);
  const handleCloseMassNotification = () => { setMassNotificationModalOpen(false); setIsSendingNotification(false); };
  const handleOpenSingleNotification = (user) => { setSingleNotificationModal({ open: true, user: user }); setDrawerOpen(false); };
  const handleCloseSingleNotification = () => { setSingleNotificationModal({ open: false, user: null }); setIsSendingNotification(false); };
  const handleOpenZonasModal = (lider) => { setSelectedLider(lider); setZonasModalOpen(true); setDrawerOpen(false); };
  const handleCloseZonasModal = () => { setSelectedLider(null); setZonasModalOpen(false); setIsSavingZone(false); };


  // Corrected Save/Send Handlers (Close modal first, NO automatic refetch)
  /**
   * Guarda las zonas asignadas (desde ModalAsignarZonas).
   * Cierra el modal al éxito, pero NO refresca la lista de usuarios.
   */
  const handleSaveZonas = (distritosArray) => {
    if (!selectedLider) return;
    setIsSavingZone(true);
    setGlobalError('');

    adminService.asignarZonasLider(selectedLider.id, distritosArray)
      .then(() => {
        alert(`Zonas asignadas correctamente al líder ${selectedLider.alias}.`);
        handleCloseZonasModal(); // Close modal FIRST
        // No automatic refetch
      })
      .catch(err => {
        console.error("Error saving zones:", err);
        setGlobalError(err.response?.data?.message || 'Error al guardar zonas');
        setIsSavingZone(false); // Stop loading on error
      });
  };

  /**
   * Envía una notificación masiva (desde ModalNotificacion) a los
   * usuarios actualmente visibles.
   * Cierra el modal al éxito, pero NO refresca.
   */
  const handleSendMassNotification = (title, body) => {
    setIsSendingNotification(true);
    const userIds = users.map(user => user.id);
    if (userIds.length === 0) {
      alert('No hay usuarios a quienes enviar la notificación.');
      setIsSendingNotification(false);
      return;
    }
    setGlobalError('');


    adminService.sendNotification(userIds, title, body)
      .then(() => {
        alert(`Notificación enviada a ${userIds.length} usuario(s) visible(s).`);
        handleCloseMassNotification(); // Close modal FIRST
        // No automatic refetch
      })
      .catch(error => {
        console.error("Error sending mass notification:", error);
        setGlobalError(error.response?.data?.message || 'Error al enviar la notificación.');
        setIsSendingNotification(false); // Stop loading on error
      });
  };

  /**
   * Envía una notificación individual (desde ModalNotificacion).
   * Cierra el modal al éxito, pero NO refresca.
   */
  const handleSendSingleNotification = (title, body) => {
    if (!singleNotificationModal.user) return;
    setIsSendingNotification(true);
    setGlobalError('');
    const userId = singleNotificationModal.user.id;

    adminService.sendNotification([userId], title, body)
      .then(() => {
        alert(`Notificación enviada a ${singleNotificationModal.user.alias}.`);
        handleCloseSingleNotification(); // Close modal FIRST
        // No automatic refetch
      })
      .catch(error => {
        console.error("Error sending single notification:", error);
        setGlobalError(error.response?.data?.message || 'Error al enviar la notificación.');
        setIsSendingNotification(false); // Stop loading on error
      });
  };

  // --- RENDER ---
  return (
    <Box sx={{ p: { xs: 1.5, sm: 2, md: 3 } , minHeight: '100vh', maxWidth:'1400px' }}>
      {/* Header */}
      <Box sx={{ mb: 3 }}>
        <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
          Gestión de Usuarios
        </Typography>
        <Alert severity="info" icon={<PeopleIcon />} variant="outlined">
            <AlertTitle>Administración de Usuarios</AlertTitle>
            Administra todos los usuarios de la plataforma, asigna roles, gestiona el estado de sus cuentas y modera las solicitudes de rol.
        </Alert>
      </Box>

      {/* Global Error Alert */}
      {globalError && <Alert severity="error" sx={{ mb: 2 }} onClose={() => setGlobalError('')}>{globalError}</Alert>}

      {/* Tabs */}
      <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}>
        <Tabs value={tabIndex} onChange={handleTabChange}>
          <Tab label="Todos los Usuarios" />
          <Tab label="Solicitudes de Rol" />
        </Tabs>
      </Box>

      {/* Tab Panel 0: All Users */}
      {tabIndex === 0 && (
    <>
      {/* Filters */}
      <Paper sx={{ p: 2, mb: 3, display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'center'}} variant="outlined">
           <TextField
               label="Buscar por nombre o email" name="search"
               value={filters.search} onChange={handleFilterChange}
               size="small" sx={{ flexGrow: 1, minWidth: '250px' }}
               InputProps={{ startAdornment: (<InputAdornment position="start"><SearchIcon /></InputAdornment>)}}
           />
           <FormControl sx={{ minWidth: 150 }} size="small">
               <InputLabel>Rol</InputLabel>
               <Select name="role" value={filters.role} label="Rol" onChange={handleFilterChange}>
                 <MenuItem value="">Todos</MenuItem>
                 <MenuItem value="ciudadano">Ciudadano</MenuItem>
                 <MenuItem value="lider_vecinal">Líder Vecinal</MenuItem>
                 <MenuItem value="reportero">Reportero</MenuItem>
                 <MenuItem value="admin">Admin</MenuItem>
               </Select>
           </FormControl>
           <FormControl sx={{ minWidth: 150 }} size="small">
               <InputLabel>Estado</InputLabel>
               <Select name="status" value={filters.status} label="Estado" onChange={handleFilterChange}>
                 <MenuItem value="">Todos</MenuItem>
                 <MenuItem value="activo">Activo</MenuItem>
                 <MenuItem value="suspendido">Suspendido</MenuItem>
               </Select>
           </FormControl>
           <ButtonGroup size="small" sx={{ ml: { xs: 0, md: 'auto' } }}>
               <Button variant={filters.sortBy === 'newest' ? 'contained' : 'outlined'} onClick={() => handleSortChange('newest')}>Recientes</Button>
               <Button variant={filters.sortBy === 'oldest' ? 'contained' : 'outlined'} onClick={() => handleSortChange('oldest')}>Antiguos</Button>
               <Button variant={filters.sortBy === 'name' ? 'contained' : 'outlined'} onClick={() => handleSortChange('name')}>Nombre</Button>
           </ButtonGroup>
         <Button
           variant="contained" color="secondary"
           startIcon={<NotificationsIcon />}
           onClick={handleOpenMassNotification}
           sx={{ ml: { xs: 0, md: 2 } }}
           disabled={users.length === 0 || loading} // Disable if loading or no users
         >
           Notificar Visibles ({users.length})
         </Button>
      </Paper>

      {/* User List */}
      {loading ? (
        <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}><CircularProgress /></Box>
      ) : users.length === 0 ? (
         <Alert severity="warning" variant="outlined" sx={{mt: 2}}>No se encontraron usuarios con los filtros aplicados.</Alert>
      ) : (
        <Grid container spacing={3}>
          {users.map(user => (
            <Grid item key={user.id} xs={12} sm={6} lg={4}>
              <TarjetaUsuario
                user={user}
                onStatusChange={handleStatusChange}
                onDetailOpen={handleDetailOpen}
                onAssignZone={handleOpenZonasModal}
              />
            </Grid>
          ))}
        </Grid>
      )}
    </>
      )}

      {/* Tab Panel 1: Role Requests */}
      {tabIndex === 1 && (
        <PanelSolicitudesRol />
      )}

      {/* --- Contenedores de Modales y Drawers --- */}
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
      {/* Renderizar el modal solo si hay un líder seleccionado */}
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