import React, { useState, useEffect, useRef, useCallback } from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, TextField, IconButton, List, Box, Paper, ListItemText, CircularProgress, Typography } from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import { jwtDecode } from 'jwt-decode';
import adminService from '../services/adminService';
import socketService from '../services/socketService';

/**
 * Componente ChatModal: Un modal de chat en tiempo real para administradores.
 * Permite chatear sobre un reporte específico, cargando el historial de mensajes
 * y manejando la comunicación en vivo vía Socket.IO.
 * 
 * Props:
 * - open: Booleano que indica si el modal está abierto.
 * - onClose: Función para cerrar el modal.
 * - report: Objeto del reporte (debe incluir id y opcionalmente codigo_reporte).
 */
function ChatModal({ open, onClose, report }) {
  // Estados para manejar mensajes, nuevo mensaje, carga y conexión del socket
  const [messages, setMessages] = useState([]); // Lista de mensajes del chat
  const [newMessage, setNewMessage] = useState(''); // Texto del mensaje que se está escribiendo
  const [loading, setLoading] = useState(true); // Indicador de carga mientras se obtiene el historial
  const [isConnected, setIsConnected] = useState(socketService.socket?.connected || false); // Estado de conexión del socket

  // Refs para almacenar información del admin y referencia al final de la lista de mensajes (para auto-scroll)
  const adminUser = useRef(null); // Información del administrador decodificada del token JWT
  const messagesEndRef = useRef(null); // Referencia al final de la lista para hacer scroll automático

  /**
   * Función para manejar la recepción de mensajes entrantes vía socket.
   * Se usa useCallback para evitar recrearla en cada render y optimizar el listener.
   */
  const handleReceiveMessage = useCallback((message) => {
    // Actualiza el estado de mensajes agregando el nuevo mensaje recibido
    setMessages(prev => [...prev, message]);
  }, []); // Sin dependencias, ya que no cambia

  /**
   * useEffect principal: Maneja la inicialización del modal, conexión al socket,
   * unión a la sala del reporte, carga del historial y limpieza al cerrar.
   * Se ejecuta cuando cambian 'open', 'report' o 'handleReceiveMessage'.
   */
  useEffect(() => {
    // Decodifica la información del admin desde el token almacenado en localStorage
    const token = localStorage.getItem('admin_token');
    if (token) {
      try {
        adminUser.current = jwtDecode(token).user; // Almacena el usuario admin en la ref
      } catch (e) {
        console.error("Error decoding admin token", e);
      }
    }

    // Solo proceder si el modal está abierto, hay un reporte y un admin válido
    if (open && report && adminUser.current) {
      setLoading(true); // Activa el indicador de carga
      setIsConnected(socketService.socket?.connected || false); // Verifica el estado inicial del socket

      /**
       * Función interna: Se ejecuta después de conectar y autenticar el socket.
       * Une al usuario a la sala del reporte, configura el listener de mensajes y carga el historial.
       */
      const onSocketConnect = () => {
        console.log('ChatModal: Socket conectado/autenticado, uniendo a sala y cargando historial...');
        setIsConnected(true); // Actualiza el estado de conexión
        // 1. Unirse a la sala del reporte (usando el ID como string)
        socketService.joinRoom(report.id.toString());
        // 2. Configurar el listener para recibir mensajes
        socketService.on('receive-message', handleReceiveMessage);
        // 3. Cargar el historial de mensajes del reporte desde el servicio admin
        adminService.getChatHistory(report.id)
          .then(setMessages) // Actualiza el estado con los mensajes históricos
          .catch(err => console.error("Error fetching chat history", err))
          .finally(() => setLoading(false)); // Desactiva la carga
      };

      // Lógica de conexión al socket
      if (!socketService.socket || !socketService.socket.connected) {
        console.log('ChatModal: Socket no conectado, intentando conectar...');
        // Escucha eventos de conexión y autenticación, luego ejecuta onSocketConnect
        socketService.on('connect', onSocketConnect);
        socketService.on('authenticated', onSocketConnect); // El backend emite 'authenticated' tras autenticar
        socketService.connect(token); // Conecta al socket pasando el token para autenticación
      } else {
        // Si ya está conectado (y autenticado), ejecuta directamente
        onSocketConnect();
      }

      // Función de limpieza: Se ejecuta al desmontar el componente o cambiar dependencias
      return () => {
        console.log(`ChatModal: Limpiando para reporte ${report?.id}`);
        // Remueve los listeners específicos de este modal
        socketService.off('connect', onSocketConnect);
        socketService.off('authenticated', onSocketConnect);
        socketService.off('receive-message', handleReceiveMessage);
        // Sale de la sala del reporte
        if (report) {
          socketService.leaveRoom(report.id.toString());
        }
        // Nota: No desconecta el socket globalmente, ya que podría usarse en otros lugares
        setMessages([]); // Limpia los mensajes
        setIsConnected(false); // Resetea el estado de conexión
      };
    } else {
      // Si no está abierto o falta reporte/admin, asegura limpieza de listeners
      return () => {
        // Remueve listeners si onSocketConnect fue definido (aunque no debería en este caso)
        socketService.off('connect', onSocketConnect); // Nota: onSocketConnect no está definido aquí, pero se incluye por seguridad
        socketService.off('authenticated', onSocketConnect);
        socketService.off('receive-message', handleReceiveMessage);
      };
    }
  }, [open, report, handleReceiveMessage]); // Dependencias: cambios en apertura, reporte o función de recepción

  /**
   * useEffect para auto-scroll: Hace scroll automático al final de la lista de mensajes
   * cada vez que los mensajes cambian.
   */
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  /**
   * Función para enviar un mensaje: Valida y emite el mensaje vía socket si está conectado.
   */
  const handleSendMessage = () => {
    // Validaciones: mensaje no vacío, admin presente y socket conectado
    if (newMessage.trim() === '' || !adminUser.current || !isConnected) {
      console.warn("No se puede enviar mensaje: texto vacío, sin admin o socket desconectado.");
      return;
    }

    // Prepara los datos del mensaje (el backend usa socket.user para ID y alias)
    const messageData = {
      id_reporte: report.id,
      id_sender: adminUser.current.userId, // Opcional, ya que el backend lo toma del socket
      message_text: newMessage.trim(),
      sender_alias: adminUser.current.alias || 'Administrador' // Opcional
    };

    // Emite el mensaje y limpia el campo de entrada
    socketService.emit('send-message', messageData);
    setNewMessage('');
  };

  // Renderizado del componente: Estructura del modal con Material-UI
  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm">
      {/* Título del modal con información del reporte */}
      <DialogTitle>
        Chat - Reporte {report?.codigo_reporte ? `#${report.codigo_reporte}` : `ID ${report?.id}`}
      </DialogTitle>
      
      {/* Contenido del modal: Lista de mensajes o indicador de carga */}
      <DialogContent dividers sx={{ height: '50vh', p: 0, bgcolor: 'background.default' }}>
        {loading ? (
          // Muestra un spinner mientras carga
          <Box display="flex" justifyContent="center" alignItems="center" height="100%">
            <CircularProgress />
          </Box>
        ) : (
          // Lista de mensajes
          <List sx={{ p: 2 }}>
            {messages.map((msg) => (
              // Cada mensaje se renderiza en un Paper con estilo condicional (derecha para admin, izquierda para otros)
              <Box
                key={msg.id || Math.random()} // Usa msg.id si existe, sino un random (mejor usar ID único del backend)
                sx={{
                  display: 'flex',
                  justifyContent: msg.remitente_alias === (adminUser.current?.alias || 'Administrador') ? 'flex-end' : 'flex-start',
                  mb: 1
                }}
              >
                <Paper
                  elevation={2}
                  sx={{
                    p: 1.5,
                    maxWidth: '70%',
                    bgcolor: msg.remitente_alias === (adminUser.current?.alias || 'Administrador') ? 'primary.main' : 'grey.700',
                    color: 'white',
                    borderRadius: msg.remitente_alias === (adminUser.current?.alias || 'Administrador')
                      ? '20px 20px 5px 20px' // Burbuja redondeada para admin
                      : '20px 20px 20px 5px', // Burbuja para otros
                  }}
                >
                  {/* Texto del mensaje con alias y timestamp */}
                  <ListItemText
                    primary={<Typography variant="caption" sx={{ fontWeight: 'bold' }}>{msg.remitente_alias}</Typography>}
                    secondary={<Typography variant="body2" sx={{ color: 'white', whiteSpace: 'pre-wrap' }}>{msg.mensaje}</Typography>} // Usa 'mensaje' del backend
                  />
                  {/* Timestamp opcional */}
                  <Typography variant="caption" sx={{ display: 'block', textAlign: 'right', fontSize: '0.65rem', color: 'rgba(255, 255, 255, 0.7)', mt: 0.5 }}>
                    {new Date(msg.fecha_envio_iso || msg.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                  </Typography>
                </Paper>
              </Box>
            ))}
            {/* Referencia para auto-scroll */}
            <div ref={messagesEndRef} />
          </List>
        )}
      </DialogContent>
      
      {/* Acciones del modal: Campo de texto y botón de enviar */}
      <DialogActions sx={{ p: 1 }}>
        <TextField
          fullWidth
          variant="outlined"
          size="small"
          placeholder="Escribe un mensaje..."
          value={newMessage}
          onChange={(e) => setNewMessage(e.target.value)}
          onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()} // Envía al presionar Enter
          disabled={!isConnected || loading} // Deshabilita si no está conectado o cargando
        />
        <IconButton
          color="primary"
          onClick={handleSendMessage}
          disabled={!isConnected || loading} // Deshabilita si no está conectado o cargando
        >
          <SendIcon />
        </IconButton>
      </DialogActions>
    </Dialog>
  );
}

export default ChatModal;
