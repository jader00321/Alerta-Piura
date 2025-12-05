import React, { useState, useEffect, useRef } from 'react';
import { 
  Box, 
  TextField, 
  IconButton, 
  List, 
  Paper, 
  Typography, 
  CircularProgress, 
  AppBar, 
  Toolbar, 
  useTheme, // <-- Usamos useTheme
  Dialog, DialogTitle, DialogContent, DialogActions, Avatar
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import InfoIcon from '@mui/icons-material/Info';
import CloseIcon from '@mui/icons-material/Close';
import { jwtDecode } from 'jwt-decode';

import adminService from '../services/adminService';
import socketService from '../services/socketService';

/**
 * Componente ChatModal: Un modal de chat en tiempo real para administradores.
 */
function ChatModal({ open, onClose, report }) {
  const theme = useTheme(); // Para colores adaptativos
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(true);
  const messagesEndRef = useRef(null);
  
  const token = localStorage.getItem('admin_token');
  let adminId = null;
  if (token) {
    try {
      const decoded = jwtDecode(token);
      adminId = decoded.user.userId;
    } catch (e) {
      console.error("Error decodificando token:", e);
    }
  }

  const scrollToBottom = () => {
    setTimeout(() => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    }, 50);
  };

  useEffect(() => {
    if (!report?.id) return;
    setLoading(true);
    
    // Cargar historial
    adminService.getChatHistory(report.id)
      .then(data => {
        // Asumiendo que el historial trae el flag 'es_admin' o 'id_remitente'
        setMessages(data);
        setLoading(false);
        scrollToBottom();
      })
      .catch(err => { console.error("Error cargando historial:", err); setLoading(false); });

    const room = `report_${report.id}`;
    socketService.joinRoom(room);

    // --- MANEJADOR CORREGIDO DE RECEPCIÓN (ÚNICA FUENTE DE DATOS) ---
    const handleReceiveMessage = (msg) => {
      if (String(msg.id_reporte) === String(report.id)) {
        setMessages(prev => [...prev, msg]);
        scrollToBottom();
      }
    };

    socketService.on('receive-message', handleReceiveMessage);

    return () => {
      socketService.leaveRoom(room);
      socketService.off('receive-message', handleReceiveMessage);
    };
  }, [report]);

  const handleSendMessage = () => {
    if (newMessage.trim() === '') return;

    const msgData = {
      id_reporte: report.id,
      mensaje: newMessage,
      id_remitente: adminId,
      remitente_alias: 'Admin',
      es_admin: true,
      timestamp: new Date().toISOString()
    };

    socketService.sendMessage(msgData);
    
    // --- SOLUCIÓN AL PROBLEMA DE DUPLICACIÓN ---
    // NO actualizamos el estado aquí. Esperamos a que el servidor envíe el mensaje de vuelta.
    // Esto asegura que solo el mensaje final (guardado y con DB ID) aparezca.
    
    setNewMessage('');
    scrollToBottom();
  };

  const isDark = theme.palette.mode === 'dark';
  const chatBackground = isDark ? theme.palette.grey[900] : '#efe7dd';
  
  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="md"> {/* <-- Tamaño ampliado */}
      {/* HEADER con Autor y Título Notorio */}
      <DialogTitle sx={{ 
          display: 'flex', 
          flexDirection: 'column',
          alignItems: 'flex-start',
          bgcolor: theme.palette.primary.main, 
          color: theme.palette.primary.contrastText,
          p: 1.5
      }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', width: '100%' }}>
            <Typography variant="body2" sx={{ opacity: 0.8, fontWeight: 'bold' }}>
                Reporte de {report?.autor_alias || 'Usuario'}
            </Typography>
            <IconButton onClick={onClose} sx={{ color: 'inherit', p: 0 }}>
                <CloseIcon />
            </IconButton>
        </Box>
        
        {/* TÍTULO COMPLETO Y NOTABLE */}
        <Typography variant="h6" sx={{ fontWeight: 'bold', mt: 0.5, wordBreak: 'break-word', whiteSpace: 'normal' }}>
            {report?.titulo || `Chat #${report.id}`}
        </Typography>
      </DialogTitle>
      
      {/* CUERPO DEL CHAT */}
      <DialogContent dividers sx={{ 
          p: 0, 
          bgcolor: chatBackground, 
          height: '600px', // <-- Altura aumentada para mejor visualización
          backgroundImage: isDark ? 'none' : 'url("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png")',
          backgroundBlendMode: 'soft-light'
      }}>
        <Box sx={{ height: '100%', overflowY: 'auto', p: 2, display: 'flex', flexDirection: 'column' }}>
          {loading ? (
            <Box display="flex" justifyContent="center" alignItems="center" height="100%">
              <CircularProgress />
            </Box>
          ) : (
            <List sx={{ width: '100%' }}>
              {messages.map((msg, index) => {
                const isAdmin = msg.es_admin || String(msg.id_remitente) === String(adminId);
                
                return (
                  <Box key={index} sx={{ display: 'flex', justifyContent: isAdmin ? 'flex-end' : 'flex-start', mb: 1.5 }}>
                    <Paper 
                      elevation={1}
                      sx={{ 
                        p: 1.5, 
                        // COLORES ADAPTATIVOS FINALIZADOS
                        bgcolor: isAdmin 
                            ? theme.palette.primary.dark // Admin: Color Primario Oscuro
                            : theme.palette.action.hover, // Usuario: Color Gris/Suave
                        color: isAdmin 
                            ? theme.palette.primary.contrastText 
                            : theme.palette.text.primary,
                        maxWidth: '75%',
                        borderRadius: 2,
                        borderTopRightRadius: isAdmin ? 0 : 16,
                        borderTopLeftRadius: !isAdmin ? 0 : 16
                      }}
                    >
                      <Typography variant="body2" style={{ wordWrap: 'break-word', fontSize: '0.95rem' }}>
                        {msg.mensaje}
                      </Typography>
                      <Typography 
                        variant="caption" 
                        sx={{ 
                          display: 'block', 
                          textAlign: 'right', 
                          mt: 0.5, 
                          opacity: 0.7, 
                          fontSize: '0.65rem',
                          color: 'inherit' // Asegura buen contraste
                        }}
                      >
                        {msg.timestamp ? new Date(msg.timestamp).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}) : '...'}
                      </Typography>
                    </Paper>
                  </Box>
                );
              })}
              <div ref={messagesEndRef} />
            </List>
          )}
        </Box>
      </DialogContent>

      {/* INPUT */}
      <DialogActions sx={{ p: 1.5, bgcolor: theme.palette.background.paper, borderTop: 1, borderColor: theme.palette.divider }}>
        <TextField
          fullWidth
          variant="outlined"
          size="small"
          placeholder="Escribe un mensaje..."
          value={newMessage}
          onChange={(e) => setNewMessage(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
          sx={{ 
              bgcolor: isDark ? theme.palette.grey[800] : 'white', 
              '& .MuiOutlinedInput-root': { borderRadius: 2 }
          }}
        />
        <IconButton 
            color="primary" 
            onClick={handleSendMessage} 
            disabled={!newMessage.trim()}
            sx={{ 
                bgcolor: theme.palette.primary.main, 
                color: theme.palette.primary.contrastText,
                '&:hover': { bgcolor: theme.palette.primary.dark }, 
                ml: 1 
            }}
        >
          <SendIcon />
        </IconButton>
      </DialogActions>
    </Dialog>
  );
}

export default ChatModal;