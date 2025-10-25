// src/components/Usuarios/ModalesConfirmacionRol.jsx
import React from 'react';
import {
  Dialog, DialogActions, DialogContent, DialogContentText,
  DialogTitle, TextField, Button, Box, Typography
} from '@mui/material';
import { 
  AdminPanelSettings as AdminIcon, 
  Group as GroupIcon, 
  Mic as MicIcon,
  WarningAmber as WarningIcon
} from '@mui/icons-material';

// --- Modal genérico para roles simples (Líder, Reportero) ---
const ModalPromocionSimple = ({ open, onClose, onConfirm, roleConfig }) => {
  const { type, Icon, color, lightColor } = roleConfig;
  
  return (
    <Dialog open={open} onClose={onClose}>
      <DialogTitle sx={{ fontWeight: 'bold' }}>Confirmar Promoción</DialogTitle>
      <DialogContent sx={{ p: 0 }}>
        {/* Banner de color con Icono */}
        <Box 
          sx={{ 
            bgcolor: lightColor, 
            color: color, 
            p: 3,
            display: 'flex',
            alignItems: 'center',
            gap: 2
          }}
        >
          <Icon sx={{ fontSize: 40 }} />
          <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
            Promover a {type}
          </Typography>
        </Box>
        <DialogContentText sx={{ p: 3, pb: 1 }}>
          ¿Estás seguro de que quieres promover a este usuario al rol de **{type}**?
        </DialogContentText>
      </DialogContent>
      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose}>Cancelar</Button>
        <Button onClick={onConfirm} variant="contained" sx={{ bgcolor: color, '&:hover': { bgcolor: color } }}>
          Confirmar
        </Button>
      </DialogActions>
    </Dialog>
  );
};

// --- Modal de Seguridad para Admin ---
const ModalPromocionAdmin = ({ open, onClose, onConfirm, adminPassword, setAdminPassword, confirmText, setConfirmText }) => {
  return (
    <Dialog open={open} onClose={onClose}>
      <DialogTitle sx={{ fontWeight: 'bold' }}>Confirmación de Seguridad</DialogTitle>
      <DialogContent>
        {/* Banner de color con Icono */}
        <Box 
          sx={{ 
            bgcolor: 'secondary.light', 
            color: 'secondary.dark', 
            p: 3, mb: 2,
            display: 'flex',
            alignItems: 'center',
            gap: 2,
            borderRadius: 1
          }}
        >
          <AdminPanelSettingsIcon sx={{ fontSize: 40 }} />
          <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
            Promoción a Administrador
          </Typography>
        </Box>
        <DialogContentText sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
          <WarningIcon color="error" fontSize="small" />
          Está a punto de otorgar privilegios de **Administrador**.
        </DialogContentText>
        <DialogContentText sx={{ mt: 1, mb: 2 }}>
          Para continuar, escriba "PROMOVER" y su contraseña actual.
        </DialogContentText>
        <TextField 
          autoFocus 
          margin="dense" 
          label='Escriba "PROMOVER"' 
          type="text" 
          fullWidth 
          variant="outlined" 
          value={confirmText} 
          onChange={(e) => setConfirmText(e.target.value)} 
        />
        <TextField 
          margin="dense" 
          label="Su Contraseña de Administrador" 
          type="password" 
          fullWidth 
          variant="outlined" 
          value={adminPassword} 
          onChange={(e) => setAdminPassword(e.target.value)} 
        />
      </DialogContent>
      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose}>Cancelar</Button>
        <Button 
          onClick={onConfirm} 
          variant="contained" 
          color="error" 
          disabled={confirmText !== 'PROMOVER' || !adminPassword}
        >
          Confirmar Promoción
        </Button>
      </DialogActions>
    </Dialog>
  );
};

// --- Componente principal renombrado ---
function ModalesConfirmacionRol(props) {
  const { promoModal, ...rest } = props;

  if (promoModal.type === 'lider_vecinal') {
    return (
      <ModalPromocionSimple
        open={promoModal.open}
        onClose={props.onClose}
        onConfirm={props.onConfirm}
        roleConfig={{ 
          type: 'Líder Vecinal', 
          Icon: GroupIcon, 
          color: 'primary.dark', 
          lightColor: 'primary.light' 
        }}
      />
    );
  }

  if (promoModal.type === 'reportero') {
    return (
      <ModalPromocionSimple
        open={promoModal.open}
        onClose={props.onClose}
        onConfirm={props.onConfirm}
        roleConfig={{ 
          type: 'Reportero / Prensa', 
          Icon: MicIcon, 
          color: 'info.dark', 
          lightColor: 'info.light' 
        }}
      />
    );
  }

  if (promoModal.type === 'admin') {
    return (
      <ModalPromocionAdmin
        open={promoModal.open}
        {...rest}
      />
    );
  }

  return null; // No mostrar nada si el tipo no coincide
}

export default ModalesConfirmacionRol;