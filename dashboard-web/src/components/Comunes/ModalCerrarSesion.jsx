// src/components/Comunes/ModalCerrarSesion.jsx
import React from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogActions, Button, Typography, Box, Slide, Avatar, useTheme, alpha
} from '@mui/material';
import { Logout as LogoutIcon } from '@mui/icons-material';

// Transición suave hacia arriba
const Transition = React.forwardRef(function Transition(props, ref) {
  return <Slide direction="up" ref={ref} {...props} />;
});

function ModalCerrarSesion({ open, onClose, onConfirm }) {
  const theme = useTheme();

  return (
    <Dialog
      open={open}
      onClose={onClose}
      TransitionComponent={Transition}
      PaperProps={{
        sx: {
          borderRadius: 3,
          boxShadow: theme.shadows[10],
          overflow: 'hidden',
          minWidth: 320
        }
      }}
    >
      <Box sx={{ bgcolor: alpha(theme.palette.error.main, 0.08), p: 3, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <Avatar sx={{ bgcolor: 'white', color: 'error.main', width: 56, height: 56, mb: 2, boxShadow: 2 }}>
          <LogoutIcon fontSize="large" />
        </Avatar>
        <Typography variant="h6" fontWeight="800" color="text.primary">
          ¿Cerrar Sesión?
        </Typography>
      </Box>

      <DialogContent sx={{ textAlign: 'center', py: 3 }}>
        <Typography color="text.secondary">
          Estás a punto de salir del panel administrativo.<br/>Tendrás que ingresar tus credenciales nuevamente.
        </Typography>
      </DialogContent>

      <DialogActions sx={{ p: 3, pt: 0, justifyContent: 'center', gap: 2 }}>
        <Button 
          onClick={onClose} 
          variant="outlined" 
          color="inherit" 
          sx={{ borderRadius: 2, px: 3, borderColor: theme.palette.divider }}
        >
          Cancelar
        </Button>
        <Button 
          onClick={onConfirm} 
          variant="contained" 
          color="error" 
          disableElevation
          sx={{ borderRadius: 2, px: 4, fontWeight: 'bold' }}
        >
          Salir Ahora
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default ModalCerrarSesion;