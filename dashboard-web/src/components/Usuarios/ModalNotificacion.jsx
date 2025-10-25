// src/components/Usuarios/ModalNotificacion.jsx
import React, { useState, useEffect } from 'react';
import { 
  Dialog, DialogTitle, DialogContent, DialogActions, TextField, Button, 
  DialogContentText, CircularProgress, Alert,
  Box,
  InputAdornment
} from '@mui/material';
import NotificationsActiveIcon from '@mui/icons-material/NotificationsActive';
import TitleIcon from '@mui/icons-material/Title';
import MessageIcon from '@mui/icons-material/Message';
import SendIcon from '@mui/icons-material/Send';
import InfoIcon from '@mui/icons-material/Info';
import PersonIcon from '@mui/icons-material/Person';

function ModalNotificacion({ open, onClose, onSubmit, targetUserCount, isSending, targetUserName }) {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    if (!open) {
      setTitle('');
      setBody('');
      setError('');
    }
  }, [open]);

  const handleSend = () => {
    setError('');
    if (title.trim() === '' || body.trim() === '') {
      setError('El título y el cuerpo son requeridos.');
      return;
    }
    // Llama a la función del padre (PaginaUsuarios)
    onSubmit(title, body);
  };

  return (
    <Dialog open={open} onClose={isSending ? () => {} : onClose} fullWidth maxWidth="sm">
      
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
        <NotificationsActiveIcon color="primary" />
        {targetUserName 
          ? `Enviar Notificación a ${targetUserName}`
          : `Enviar Notificación Masiva`
        }
      </DialogTitle>
      
      <DialogContent dividers>
        
        {!targetUserName ? (
          <Alert severity="info" icon={<InfoIcon />} sx={{ mb: 2 }}>
            El mensaje se enviará a todos los usuarios actualmente visibles en la lista
            ({targetUserCount} usuario(s)).
          </Alert>
        ) : (
          <DialogContentText sx={{ mb: 2, display: 'flex', alignItems: 'center', gap: 1 }}>
            <PersonIcon fontSize="small" color="action" />
            El mensaje se enviará directamente a este usuario.
          </DialogContentText>
        )}

        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 1 }}>
          <TextField
            autoFocus
            label="Título de la Notificación"
            type="text"
            fullWidth
            variant="outlined"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            disabled={isSending}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <TitleIcon color="action" />
                </InputAdornment>
              ),
            }}
          />
          <TextField
            label="Cuerpo del Mensaje"
            type="text"
            fullWidth
            multiline
            rows={4}
            variant="outlined"
            value={body}
            onChange={(e) => setBody(e.target.value)}
            disabled={isSending}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <MessageIcon color="action" />
                </InputAdornment>
              ),
            }}
          />
        </Box>
        {error && <Alert severity="error" sx={{ mt: 2 }}>{error}</Alert>}
      </DialogContent>
      
      <DialogActions sx={{ p: '16px 24px' }}>
        <Button onClick={onClose} disabled={isSending}>Cancelar</Button>
        <Button 
          onClick={handleSend} 
          variant="contained" 
          disabled={isSending}
          startIcon={isSending ? null : <SendIcon />}
        >
          {isSending ? <CircularProgress size={24} color="inherit" /> : 'Enviar'}
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default ModalNotificacion;