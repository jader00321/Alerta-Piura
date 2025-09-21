import React, { useEffect, useState, useCallback } from 'react';
import { Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography, Select, MenuItem, TextField, Button, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle, Chip, IconButton, Tooltip } from '@mui/material';
import NotificationsIcon from '@mui/icons-material/Notifications';
import adminService from '../services/adminService';
import HoldToConfirmButton from '../components/HoldToConfirmButton';

const getRoleChipProps = (role) => {
  switch (role) {
    case 'admin':
      return { label: 'Administración', color: 'secondary' };
    case 'lider_vecinal':
      return { label: 'Líder Vecinal', color: 'primary' };
    default:
      return { label: 'Ciudadano', color: 'default' };
  }
};

function UsersPage() {
  const [users, setUsers] = useState([]);
  const [filteredUsers, setFilteredUsers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  
  const [adminPromoDialog, setAdminPromoDialog] = useState({ open: false, data: {} });
  const [confirmText, setConfirmText] = useState('');
  const [adminPassword, setAdminPassword] = useState('');

  // State for the notification dialog
  const [notifDialog, setNotifDialog] = useState({ open: false, title: '', body: '', recipients: [] });

  const fetchUsers = useCallback(() => {
    adminService.getAllUsers()
      .then(data => setUsers(data))
      .catch(err => console.error("Error fetching users:", err));
  }, []);

  useEffect(() => {
    fetchUsers();
  }, [fetchUsers]);

  useEffect(() => {
    const results = users.filter(user =>
      (user.nombre?.toLowerCase() || '').includes(searchTerm.toLowerCase()) ||
      (user.email?.toLowerCase() || '').includes(searchTerm.toLowerCase())
    );
    setFilteredUsers(results);
  }, [searchTerm, users]);

  const handleRoleChange = (userId, newRole) => {
    if (newRole === 'admin') {
      setAdminPromoDialog({ open: true, data: { userId, newRole } });
    } else {
      adminService.updateUserRole(userId, newRole).then(fetchUsers);
    }
  };

  const handleStatusChange = (userId, currentStatus) => {
    const newStatus = currentStatus === 'activo' ? 'suspendido' : 'activo';
    adminService.updateUserStatus(userId, newStatus).then(fetchUsers);
  };
  
  const handleConfirmAdminPromotion = () => {
    adminService.updateUserRole(adminPromoDialog.data.userId, adminPromoDialog.data.newRole, adminPassword)
      .then(() => {
        handleCloseAdminPromoDialog();
        fetchUsers();
      })
      .catch(err => alert(err.response?.data?.message || 'Error al promover a admin.'));
  };
  
  const handleCloseAdminPromoDialog = () => {
    setAdminPromoDialog({ open: false, data: {} });
    setConfirmText('');
    setAdminPassword('');
  };

  const handleOpenNotificationDialog = (userIds) => {
    if (userIds.length === 0) {
      alert('No users selected to notify.');
      return;
    }
    setNotifDialog({ open: true, title: '', body: '', recipients: userIds });
  };

  const handleCloseNotificationDialog = () => {
    setNotifDialog({ open: false, title: '', body: '', recipients: [] });
  };

  const handleSendNotification = () => {
    const { recipients, title, body } = notifDialog;
    adminService.sendNotification(recipients, title, body)
      .then(() => {
        alert('Notificación enviada con éxito.');
        handleCloseNotificationDialog();
      })
      .catch(err => alert(err.response?.data?.message || 'Error al enviar notificación.'));
  };

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
        <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold', mb: 0 }}>
          Gestión de Usuarios
        </Typography>
        <Button
          variant="contained"
          startIcon={<NotificationsIcon />}
          onClick={() => handleOpenNotificationDialog(filteredUsers.map(u => u.id))}
          disabled={filteredUsers.length === 0}
        >
          Notificar a Filtrados ({filteredUsers.length})
        </Button>
      </Box>

      <TextField label="Buscar por nombre o email" variant="outlined" fullWidth sx={{ mb: 3 }} onChange={(e) => setSearchTerm(e.target.value)} />
      
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell sx={{ fontWeight: 'bold' }}>ID</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Nombre</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Email</TableCell>
              <TableCell sx={{ fontWeight: 'bold', minWidth: 160 }}>Rol</TableCell>
              <TableCell sx={{ fontWeight: 'bold', minWidth: 120 }}>Estado</TableCell>
              <TableCell sx={{ fontWeight: 'bold', minWidth: 150 }}>Acción de Estado</TableCell>
              <TableCell sx={{ fontWeight: 'bold' }}>Notificar</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {filteredUsers.map((user) => (
              <TableRow key={user.id} hover>
                <TableCell>{user.id}</TableCell>
                <TableCell>{user.nombre}</TableCell>
                <TableCell>{user.email}</TableCell>
                <TableCell>
                  <Select
                    value={user.rol}
                    onChange={(e) => handleRoleChange(user.id, e.target.value)}
                    variant="standard"
                    sx={{ '&:before': { border: 'none' }, '&:after': { border: 'none' } }}
                    renderValue={(selected) => {
                      const { label, color } = getRoleChipProps(selected);
                      return <Chip label={label} color={color} size="small" variant="outlined" />;
                    }}
                  >
                    <MenuItem value="ciudadano">Ciudadano</MenuItem>
                    <MenuItem value="lider_vecinal">Líder Vecinal</MenuItem>
                    <MenuItem value="admin">Admin</MenuItem>
                  </Select>
                </TableCell>
                <TableCell>
                   <Chip 
                     label={user.status === 'activo' ? 'Activo' : 'Suspendido'}
                     color={user.status === 'activo' ? 'success' : 'error'}
                     size="small"
                   />
                </TableCell>
                <TableCell>
                  {user.status === 'activo' ? (
                    <HoldToConfirmButton 
                      onConfirm={() => handleStatusChange(user.id, user.status)}
                      label="Suspender"
                      color="error"
                    />
                  ) : (
                    <HoldToConfirmButton 
                      onConfirm={() => handleStatusChange(user.id, user.status)}
                      label="Activar"
                      color="success"
                    />
                  )}
                </TableCell>
                <TableCell>
                   <Tooltip title="Enviar Notificación Individual">
                    <IconButton color="primary" onClick={() => handleOpenNotificationDialog([user.id])}>
                      <NotificationsIcon />
                    </IconButton>
                  </Tooltip>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      {/* Admin Promotion Dialog */}
      <Dialog open={adminPromoDialog.open} onClose={handleCloseAdminPromoDialog}>
        <DialogTitle>Confirmación de Seguridad Requerida</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Está a punto de otorgar privilegios de Administrador. Para continuar, por favor escriba "PROMOVER" y su contraseña actual.
          </DialogContentText>
          <TextField
            autoFocus margin="dense" label='Escriba "PROMOVER"' type="text" fullWidth variant="standard"
            value={confirmText}
            onChange={(e) => setConfirmText(e.target.value)}
          />
          <TextField
            margin="dense" label="Su Contraseña de Administrador" type="password" fullWidth variant="standard"
            value={adminPassword}
            onChange={(e) => setAdminPassword(e.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseAdminPromoDialog}>Cancelar</Button>
          <Button 
            onClick={handleConfirmAdminPromotion}
            variant="contained" 
            color="error" 
            disabled={confirmText !== 'PROMOVER' || adminPassword.length < 1}
          >
            Confirmar Promoción
          </Button>
        </DialogActions>
      </Dialog>
      
      {/* Notification Dialog */}
      <Dialog open={notifDialog.open} onClose={handleCloseNotificationDialog} fullWidth>
        <DialogTitle>Enviar Notificación a {notifDialog.recipients.length} Usuario(s)</DialogTitle>
        <DialogContent>
          <DialogContentText>
            El siguiente mensaje será enviado como una notificación push a los dispositivos de los usuarios seleccionados.
          </DialogContentText>
          <TextField
            autoFocus margin="dense" label="Título de la Notificación" type="text" fullWidth
            value={notifDialog.title}
            onChange={(e) => setNotifDialog(prev => ({ ...prev, title: e.target.value }))}
          />
          <TextField
            margin="dense" label="Cuerpo del Mensaje" type="text" fullWidth multiline rows={4}
            value={notifDialog.body}
            onChange={(e) => setNotifDialog(prev => ({ ...prev, body: e.target.value }))}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseNotificationDialog}>Cancelar</Button>
          <Button onClick={handleSendNotification} variant="contained">Enviar</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
}

export default UsersPage;