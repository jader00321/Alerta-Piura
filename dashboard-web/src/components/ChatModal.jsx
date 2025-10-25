import React, { useState, useEffect, useRef, useCallback } from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, TextField, IconButton, List, Box, Paper, ListItemText, CircularProgress, Typography } from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import { jwtDecode } from 'jwt-decode';
import adminService from '../services/adminService';
import socketService from '../services/socketService';

function ChatModal({ open, onClose, report }) {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const [loading, setLoading] = useState(true);
  const [isConnected, setIsConnected] = useState(socketService.socket?.connected || false); // Estado de conexión
  const adminUser = useRef(null);
  const messagesEndRef = useRef(null);

  // --- Función para recibir mensajes (usando useCallback) ---
  const handleReceiveMessage = useCallback((message) => {
    // Asegúrate de que el componente sigue montado antes de actualizar
    // (React maneja esto implícitamente si usas el estado correctamente)
    setMessages(prev => [...prev, message]);
  }, []); // Sin dependencias, la función no cambia

  useEffect(() => {
    // Decodificar admin info (sin cambios)
    const token = localStorage.getItem('admin_token');
    if (token) {
      try {
        adminUser.current = jwtDecode(token).user;
      } catch (e) { console.error("Error decoding admin token", e); }
    }

    if (open && report && adminUser.current) { // Asegura que tengamos reporte y admin
      setLoading(true);
      setIsConnected(socketService.socket?.connected || false); // Estado inicial

      // --- Función para ejecutar después de conectar/autenticar ---
      const onSocketConnect = () => {
        console.log('ChatModal: Socket conectado/autenticado, uniendo a sala y cargando historial...');
        setIsConnected(true);
        // 1. Unirse a la sala AHORA
        socketService.joinRoom(report.id.toString());
        // 2. Configurar listener de recepción AHORA
        socketService.on('receive-message', handleReceiveMessage);
        // 3. Cargar historial
        adminService.getChatHistory(report.id)
          .then(setMessages)
          .catch(err => console.error("Error fetching chat history", err))
          .finally(() => setLoading(false));
      };

      // --- Lógica de Conexión ---
      if (!socketService.socket || !socketService.socket.connected) {
         console.log('ChatModal: Socket no conectado, intentando conectar...');
         // Escuchar 'connect' y 'authenticated'
         socketService.on('connect', onSocketConnect);
         socketService.on('authenticated', onSocketConnect); // El backend emite esto ahora
         socketService.connect(token); // Conectar (pasa el token para autenticación en query)
      } else {
         // Si ya estaba conectado (y asumimos autenticado por la nueva lógica del backend)
         onSocketConnect();
      }

      // --- Función de Limpieza ---
      return () => {
        console.log(`ChatModal: Limpiando para reporte ${report?.id}`);
        // Quitar listeners específicos de este modal
        socketService.off('connect', onSocketConnect);
        socketService.off('authenticated', onSocketConnect);
        socketService.off('receive-message', handleReceiveMessage);
        // Salir de la sala al cerrar el modal
        if (report) {
          socketService.leaveRoom(report.id.toString());
        }
        // No desconectar globalmente aquí, podría usarse en otro lado.
        setMessages([]); // Limpiar mensajes
        setIsConnected(false); // Resetear estado de conexión
      };
    } else {
        // Si no está abierto o no hay reporte/admin, asegúrate que no haya listeners activos
         return () => {
             // eslint-disable-next-line no-undef
             socketService.off('connect', onSocketConnect); // Asegura limpieza si onSocketConnect fue definido
             // eslint-disable-next-line no-undef
             socketService.off('authenticated', onSocketConnect);
             socketService.off('receive-message', handleReceiveMessage);
         };
    }
  }, [open, report, handleReceiveMessage]); // Añadir handleReceiveMessage a dependencias

  // Auto-scroll (sin cambios)
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Enviar Mensaje (ahora debería funcionar porque el socket estará autenticado)
  const handleSendMessage = () => {
    if (newMessage.trim() === '' || !adminUser.current || !isConnected) {
       console.warn("No se puede enviar mensaje: texto vacío, sin admin o socket desconectado.");
       return;
    }

    const messageData = {
      id_reporte: report.id,
      // El backend ahora usa socket.user.userId y socket.user.alias
      id_sender: adminUser.current.userId, // Opcional enviarlo
      message_text: newMessage.trim(),
      sender_alias: adminUser.current.alias || 'Administrador' // Opcional enviarlo
    };

    socketService.emit('send-message', messageData);
    setNewMessage('');
  };

  // --- Renderizado del Modal (Sin cambios significativos, excepto la clave key en el map) ---
  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm">
      <DialogTitle>Chat - Reporte {report?.codigo_reporte ? `#${report.codigo_reporte}` : `ID ${report?.id}`}</DialogTitle>
      <DialogContent dividers sx={{ height: '50vh', p: 0, bgcolor: 'background.default' }}>
        {loading ? (
          <Box display="flex" justifyContent="center" alignItems="center" height="100%"><CircularProgress /></Box>
        ) : (
          <List sx={{ p: 2 }}>
            {messages.map((msg) => ( // No usar index como key si msg.id existe
              <Box
                // --- USA msg.id SI VIENE DEL BACKEND ---
                key={msg.id || Math.random()} // Fallback a random si ID no existe (poco ideal)
                sx={{ display: 'flex', justifyContent: msg.remitente_alias === (adminUser.current?.alias || 'Administrador') ? 'flex-end' : 'flex-start', mb: 1 }}
              >
                <Paper
                  elevation={2}
                  sx={{
                    p: 1.5, maxWidth: '70%',
                    bgcolor: msg.remitente_alias === (adminUser.current?.alias || 'Administrador') ? 'primary.main' : 'grey.700',
                    color: 'white',
                    borderRadius: msg.remitente_alias === (adminUser.current?.alias || 'Administrador')
                      ? '20px 20px 5px 20px'
                      : '20px 20px 20px 5px',
                  }}
                >
                  <ListItemText
                     primary={<Typography variant="caption" sx={{fontWeight: 'bold'}}>{msg.remitente_alias}</Typography>}
                     // --- USA msg.mensaje (clave del backend) ---
                     secondary={<Typography variant="body2" sx={{color: 'white', whiteSpace: 'pre-wrap'}}>{msg.mensaje}</Typography>}
                  />
                   {/* Opcional: Mostrar hora */}
                   <Typography variant="caption" sx={{ display: 'block', textAlign: 'right', fontSize: '0.65rem', color: 'rgba(255, 255, 255, 0.7)', mt: 0.5 }}>
                       {new Date(msg.fecha_envio_iso || msg.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                   </Typography>
                </Paper>
              </Box>
            ))}
            <div ref={messagesEndRef} />
          </List>
        )}
      </DialogContent>
      <DialogActions sx={{ p:1 }}>
        <TextField fullWidth variant="outlined" size="small" placeholder="Escribe un mensaje..." value={newMessage} onChange={(e) => setNewMessage(e.target.value)} onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()} disabled={!isConnected || loading} /* Deshabilitar si no está conectado */ />
        <IconButton color="primary" onClick={handleSendMessage} disabled={!isConnected || loading} /* Deshabilitar si no está conectado */>
          <SendIcon />
        </IconButton>
      </DialogActions>
    </Dialog>
  );
}

export default ChatModal;