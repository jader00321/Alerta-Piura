import React, { useState, useEffect, useRef } from 'react';
import { 
  Box, TextField, IconButton, List, Paper, Typography, CircularProgress, AppBar, Toolbar, Button, useTheme 
} from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import ArticleIcon from '@mui/icons-material/Article';
import { jwtDecode } from 'jwt-decode';
import adminService from '../../services/adminService';
import socketService from '../../services/socketService';

function VentanaChatEmbed({ report, onOpenDetails, onMessageSent }) {
  const theme = useTheme(); 
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
    } catch (e) { console.error("Error decodificando token:", e); }
  }

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  // LÓGICA DE LECTURA REAL
  useEffect(() => {
    if (!report?.id) return;
    
    const initChat = async () => {
        setLoading(true);
        try {
            // 1. Cargar mensajes
            const data = await adminService.getChatHistory(report.id);
            setMessages(data);
            
            // 2. Marcar como leído en BD (Backend)
            await adminService.markChatAsRead(report.id);
            
            setLoading(false);
            scrollToBottom();
        } catch (err) {
            console.error(err);
            setLoading(false);
        }
    };

    initChat();

    // Socket
    const room = `report_${report.id}`;
    socketService.joinRoom(room);

    const handleReceiveMessage = (msg) => {
      if (String(msg.id_reporte) === String(report.id)) {
        setMessages(prev => [...prev, msg]);
        scrollToBottom();
        // Si recibo mensaje con el chat abierto, marcar como leído al instante
        if (!msg.es_admin) {
             adminService.markChatAsRead(report.id);
        }
      }
    };

    socketService.on('receive-message', handleReceiveMessage);

    return () => {
        socketService.leaveRoom(room);
        socketService.off('receive-message', handleReceiveMessage);
    };
  }, [report.id]);

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
    // Actualización optimista
    //setMessages(prev => [...prev, msgData]);
    setNewMessage('');
    //scrollToBottom();
    
    // Avisar al padre para reordenar la lista (ponerme primero)
    if (onMessageSent) onMessageSent(report.id, newMessage);
  };

  const isDark = theme.palette.mode === 'dark';
  
  return (
    <Box sx={{ display: 'flex', flexDirection: 'column', height: '100%' }}>
      {/* HEADER */}
      <AppBar position="static" color="default" elevation={0} sx={{ borderBottom: 1, borderColor: 'divider', bgcolor: theme.palette.background.paper }}>
        <Toolbar variant="dense">
            <Typography variant="subtitle1" fontWeight="bold" noWrap>{report.titulo}</Typography>
            <Box sx={{ flexGrow: 1 }} />
            <Button 
                size="small" 
                variant="outlined" 
                startIcon={<ArticleIcon />}
                onClick={() => onOpenDetails(report.id)}
            >
                Ver Detalles
            </Button>
        </Toolbar>
      </AppBar>

      {/* ÁREA DE MENSAJES */}
      <Box sx={{ flexGrow: 1, overflow: 'auto', p: 2, bgcolor: isDark ? theme.palette.grey[900] : '#efe7dd' }}>
        {loading ? (
            <Box display="flex" justifyContent="center" pt={5}><CircularProgress /></Box>
        ) : (
            <List sx={{ width: '100%' }}>
                {messages.map((msg, index) => {
                    const isAdmin = msg.es_admin || String(msg.id_remitente) === String(adminId);
                    return (
                        <Box key={index} sx={{ display: 'flex', justifyContent: isAdmin ? 'flex-end' : 'flex-start', mb: 1 }}>
                            <Paper sx={{ 
                                p: 1.5, 
                                bgcolor: isAdmin ? theme.palette.primary.main : (isDark ? theme.palette.grey[800] : 'white'),
                                color: isAdmin ? theme.palette.primary.contrastText : theme.palette.text.primary,
                                // DISEÑO MÁS ANCHO
                                maxWidth: '85%', 
                                minWidth: '120px',
                                borderRadius: 2,
                                wordBreak: 'break-word'
                            }}>
                                <Typography variant="body1" sx={{ fontSize: '0.95rem' }}>{msg.mensaje}</Typography>
                                <Typography variant="caption" sx={{ display: 'block', textAlign: 'right', opacity: 0.7, fontSize: '0.7rem', mt: 0.5 }}>
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

      {/* INPUT */}
      <Box sx={{ p: 2, bgcolor: theme.palette.background.paper, borderTop: 1, borderColor: 'divider' }}>
          <Box sx={{ display: 'flex', gap: 1 }}>
            <TextField 
                fullWidth size="small" placeholder="Escribe un mensaje..." 
                value={newMessage} onChange={(e) => setNewMessage(e.target.value)}
                onKeyPress={(e) => e.key === 'Enter' && handleSendMessage()}
            />
            <IconButton color="primary" onClick={handleSendMessage} disabled={!newMessage.trim()}><SendIcon /></IconButton>
          </Box>
      </Box>
    </Box>
  );
}

export default VentanaChatEmbed;