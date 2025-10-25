// src/components/Comunes/ModalConfirmacion.jsx (o src/components/UI/ModalConfirmacion.jsx)
import React from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, Button, Typography, Box, CircularProgress } from '@mui/material';
import WarningAmberIcon from '@mui/icons-material/WarningAmber'; // Icono de advertencia

function ModalConfirmacion({ open, onClose, title, content, onConfirm, confirmText = "Confirmar", cancelText = "Cancelar", confirmColor = "primary", loading = false }) {
  return (
    <Dialog open={open} onClose={loading ? () => {} : onClose} maxWidth="xs" fullWidth>
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
         {confirmColor === 'error' && <WarningAmberIcon color="error"/>}
         {title}
      </DialogTitle>
      <DialogContent dividers>
        {/* Permite pasar JSX o string */}
        {typeof content === 'string' ? <Typography>{content}</Typography> : content}
      </DialogContent>
      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose} disabled={loading}>{cancelText}</Button>
        <Button onClick={onConfirm} variant="contained" color={confirmColor} disabled={loading} startIcon={loading ? <CircularProgress size={16} color="inherit"/> : null}>
          {loading ? 'Procesando...' : confirmText}
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default ModalConfirmacion;