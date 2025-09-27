import React, { useState, useEffect, useRef } from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, TextField, IconButton, List, Box, Paper, ListItemText, CircularProgress, Typography } from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import { jwtDecode } from 'jwt-decode';
import adminService from '../services/adminService';
import socketService from '../services/socketService';

function ChatModal({ open, onClose, report }) {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(true);
  const adminUser = useRef(null);
  const messagesEndRef = useRef(null);

  useEffect(() => {
    // 1. Decodificar la info del admin solo una vez
    const token = localStorage.getItem('admin_token');
    if (token) {
      adminUser.current = jwtDecode(token).user;
    }

    // 2. Lógica a ejecutar solo cuando el modal se abre con un reporte válido
    if (open && report) {
      setLoading(true);
      
      // Función para configurar el listener del socket
      const setupSocketListeners = () => {
        socketService.on('receive-message', (message) => {
          // Asegúrate de que el componente sigue montado
          setMessages(prev => [...prev, message]);
        });
      };
      
      // 3. Conectar y unirse a la sala
      socketService.connect(); // Asegura que está conectado
      socketService.emit('join-chat-room', report.id.toString());
      setupSocketListeners();

      // 4. Cargar el historial de mensajes
      adminService.getChatHistory(report.id)
        .then(setMessages)
        .catch(err => console.error("Error fetching chat history", err))
        .finally(() => setLoading(false));
    }

    // 5. Función de limpieza: se ejecuta cuando el modal se cierra o el reporte cambia
    return () => {
      if (report) {
        socketService.leaveRoom(report.id.toString());
        // Opcional: desconectar si no se usará en ningún otro lado inmediatamente
        // socketService.disconnect(); 
      }
      setMessages([]); // Limpia los mensajes para la próxima vez que se abra
    };
  }, [open, report]);

  // Auto-scroll al último mensaje
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = () => {
    if (newMessage.trim() === '' || !adminUser.current) return;
    
    const messageData = {
      id_reporte: report.id,
      id_sender: adminUser.current.id,
      message_text: newMessage.trim(),
      sender_alias: 'Administrador' // O el alias del admin si lo tienes
    };

    socketService.emit('send-message', messageData);
    setNewMessage('');
  };

  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm">
      <DialogTitle>Chat - Reporte #{report?.codigo_reporte}</DialogTitle>
      <DialogContent dividers sx={{ height: '50vh', p: 0, bgcolor: 'background.default' }}>
        {loading ? (
          <Box display="flex" justifyContent="center" alignItems="center" height="100%"><CircularProgress /></Box>
        ) : (
          <List sx={{ p: 2 }}>
            {messages.map((msg, index) => (
              <Box 
                key={index} // Usar índice o un ID único si viene del backend
                sx={{ 
                  display: 'flex', 
                  justifyContent: msg.sender_alias === 'Administrador' ? 'flex-end' : 'flex-start',
                  mb: 1
                }}
              >
                <Paper 
                  elevation={2}
                  sx={{
                    p: 1.5,
                    maxWidth: '70%',
                    bgcolor: msg.sender_alias === 'Administrador' ? 'primary.main' : 'grey.700',
                    color: 'white',
                    borderRadius: msg.sender_alias === 'Administrador'
                      ? '20px 20px 5px 20px'
                      : '20px 20px 20px 5px',
                  }}
                >
                  <ListItemText 
                    primary={<Typography variant="caption" sx={{fontWeight: 'bold'}}>{msg.sender_alias}</Typography>} 
                    secondary={<Typography variant="body2" sx={{color: 'white', whiteSpace: 'pre-wrap'}}>{msg.message_text}</Typography>}
                  />
                </Paper>
              </Box>
            ))}
            <div ref={messagesEndRef} />
          </List>
        )}
      </DialogContent>
      <DialogActions sx={{ p:1 }}>
        <TextField 
          fullWidth 
          variant="outlined" 
          size="small" 
          placeholder="Escribe un mensaje..."
          value={newMessage}
          onChange={(e) => setNewMessage(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
        />
        <IconButton color="primary" onClick={handleSendMessage}>
          <SendIcon />
        </IconButton>
      </DialogActions>
    </Dialog>
  );
}

export default ChatModal;