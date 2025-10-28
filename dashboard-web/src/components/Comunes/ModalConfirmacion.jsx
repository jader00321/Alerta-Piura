// src/components/Comunes/ModalConfirmacion.jsx (o src/components/UI/ModalConfirmacion.jsx)
import React from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, Button, Typography, Box, CircularProgress } from '@mui/material';
import WarningAmberIcon from '@mui/icons-material/WarningAmber'; // Icono de advertencia

/**
 * ModalConfirmacion - Componente de modal reutilizable para confirmaciones y acciones críticas
 * @param {Object} props - Propiedades del componente
 * @param {boolean} props.open - Estado de apertura del modal
 * @param {function} props.onClose - Callback cuando se cierra el modal
 * @param {string} props.title - Título del modal
 * @param {string|ReactNode} props.content - Contenido del modal (texto o JSX)
 * @param {function} props.onConfirm - Callback cuando se confirma la acción
 * @param {string} [props.confirmText="Confirmar"] - Texto del botón confirmar
 * @param {string} [props.cancelText="Cancelar"] - Texto del botón cancelar
 * @param {string} [props.confirmColor="primary"] - Color del botón confirmar
 * @param {boolean} [props.loading=false] - Estado de carga para deshabilitar botones
 * @returns {JSX.Element}
 */
function ModalConfirmacion({ 
  open, 
  onClose, 
  title, 
  content, 
  onConfirm, 
  confirmText = "Confirmar", 
  cancelText = "Cancelar", 
  confirmColor = "primary", 
  loading = false 
}) {
  return (
    <Dialog 
      open={open} 
      onClose={loading ? () => {} : onClose} 
      maxWidth="xs" 
      fullWidth
    >
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
         {/* Muestra icono de advertencia solo para confirmaciones de error */}
         {confirmColor === 'error' && <WarningAmberIcon color="error"/>}
         {title}
      </DialogTitle>
      <DialogContent dividers>
        {/* Renderiza contenido como texto o JSX */}
        {typeof content === 'string' ? <Typography>{content}</Typography> : content}
      </DialogContent>
      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose} disabled={loading}>
          {cancelText}
        </Button>
        <Button 
          onClick={onConfirm} 
          variant="contained" 
          color={confirmColor} 
          disabled={loading} 
          startIcon={loading ? <CircularProgress size={16} color="inherit"/> : null}
        >
          {loading ? 'Procesando...' : confirmText}
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default ModalConfirmacion;