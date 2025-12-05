// src/components/Usuarios/ModalNotificacion.jsx
import React, { useState, useEffect } from 'react';
import { 
  Dialog, DialogContent, DialogActions, TextField, Button, 
  CircularProgress, Alert, Box, InputAdornment, Typography,
  Avatar, Slide, useTheme, alpha, IconButton
} from '@mui/material';
import {
  NotificationsActive as NotificationsIcon,
  Title as TitleIcon,
  Message as MessageIcon,
  Send as SendIcon,
  Close as CloseIcon,
  Group as GroupIcon,
  Person as PersonIcon
} from '@mui/icons-material';

// Transición suave
const Transition = React.forwardRef(function Transition(props, ref) {
  return <Slide direction="up" ref={ref} {...props} />;
});

function ModalNotificacion({ open, onClose, onSubmit, targetUserCount, isSending, targetUserName }) {
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [error, setError] = useState('');
  const theme = useTheme();

  // Resetear formulario
  useEffect(() => {
    if (!open) {
      setTitle('');
      setBody('');
      setError('');
    }
  }, [open]);

  const handleSend = () => {
    setError('');
    if (!title.trim() || !body.trim()) {
      setError('El título y el cuerpo son requeridos.');
      return;
    }
    onSubmit(title, body);
  };

  return (
    <Dialog 
      open={open} 
      onClose={isSending ? undefined : onClose} 
      TransitionComponent={Transition}
      fullWidth 
      maxWidth="sm"
      PaperProps={{
        sx: { borderRadius: 3, overflow: 'hidden', boxShadow: theme.shadows[10] }
      }}
    >
      {/* Encabezado con Diseño Premium */}
      <Box sx={{ 
        background: `linear-gradient(135deg, ${theme.palette.primary.main} 0%, ${theme.palette.primary.dark} 100%)`,
        p: 3, display: 'flex', alignItems: 'center', gap: 2, color: 'white', position: 'relative'
      }}>
        <Avatar sx={{ bgcolor: 'white', color: 'primary.main' }}>
          <NotificationsIcon />
        </Avatar>
        <Box>
          <Typography variant="h6" fontWeight="bold">
            {targetUserName ? 'Notificación Personal' : 'Notificación Masiva'}
          </Typography>
          <Typography variant="caption" sx={{ opacity: 0.9 }}>
            {targetUserName 
              ? `Destinatario: ${targetUserName}` 
              : `Destinatarios: ${targetUserCount} usuarios visibles`
            }
          </Typography>
        </Box>
        <IconButton 
          onClick={onClose} 
          disabled={isSending}
          sx={{ position: 'absolute', top: 8, right: 8, color: 'white' }}
        >
          <CloseIcon />
        </IconButton>
      </Box>
      
      <DialogContent sx={{ p: 3 }}>
        {/* Banner Informativo */}
        <Box sx={{ 
          mb: 3, p: 2, borderRadius: 2, 
          bgcolor: targetUserName ? alpha(theme.palette.info.main, 0.08) : alpha(theme.palette.warning.main, 0.08),
          border: `1px solid ${targetUserName ? alpha(theme.palette.info.main, 0.2) : alpha(theme.palette.warning.main, 0.2)}`,
          display: 'flex', alignItems: 'center', gap: 2
        }}>
          {targetUserName 
            ? <PersonIcon color="info" /> 
            : <GroupIcon color="warning" />
          }
          <Typography variant="body2" color="text.secondary">
            {targetUserName 
              ? "Este mensaje llegará como una alerta directa al dispositivo del usuario."
              : `Estás a punto de enviar una alerta a ${targetUserCount} personas. Úsalo con responsabilidad.`
            }
          </Typography>
        </Box>

        <Box sx={{ display: 'flex', flexDirection: 'column', gap: 3 }}>
          <TextField
            autoFocus
            label="Asunto / Título"
            fullWidth
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            disabled={isSending}
            variant="outlined"
            InputProps={{
              startAdornment: (
                <InputAdornment position="start"><TitleIcon color="action" /></InputAdornment>
              ),
            }}
          />
          <TextField
            label="Mensaje"
            fullWidth
            multiline
            rows={4}
            value={body}
            onChange={(e) => setBody(e.target.value)}
            disabled={isSending}
            placeholder="Escribe el contenido de la notificación aquí..."
            InputProps={{
              startAdornment: (
                <InputAdornment position="start" sx={{ mt: 1.5 }}><MessageIcon color="action" /></InputAdornment>
              ),
            }}
          />
        </Box>
        {error && <Alert severity="error" sx={{ mt: 2 }}>{error}</Alert>}
      </DialogContent>
      
      <DialogActions sx={{ p: 3, pt: 0 }}>
        <Button onClick={onClose} disabled={isSending} color="inherit">Cancelar</Button>
        <Button 
          onClick={handleSend} 
          variant="contained" 
          disabled={isSending}
          startIcon={!isSending && <SendIcon />}
          sx={{ px: 4, borderRadius: 2 }}
        >
          {isSending ? <CircularProgress size={24} color="inherit" /> : 'Enviar Notificación'}
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default ModalNotificacion;