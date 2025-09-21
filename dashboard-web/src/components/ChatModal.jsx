import React, { useState, useEffect, useRef } from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, TextField, IconButton, List, ListItem, ListItemText, Typography, Box } from '@mui/material';
import SendIcon from '@mui/icons-material/Send';
import { jwtDecode } from 'jwt-decode';
import adminService from '../services/adminService';
import socketService from '../services/socketService';

function ChatModal({ open, onClose, report }) {
  const [messages, setMessages] = useState([]);
  const [newMessage, setNewMessage] = useState('');
  const adminUser = useRef(null);
  const messagesEndRef = useRef(null);

  useEffect(() => {
    // Decode admin info from token
    const token = localStorage.getItem('admin_token');
    if (token) {
      adminUser.current = jwtDecode(token).user;
    }

    if (open && report) {
      // Fetch history and connect to socket
      adminService.getChatHistory(report.id).then(setMessages);
      socketService.connect();
      socketService.emit('join-chat-room', report.id.toString());
      socketService.on('receive-message', (message) => {
        setMessages(prev => [...prev, message]);
      });
    }

    return () => {
      // Clean up when modal closes
      if (report) {
        socketService.leaveRoom(report.id.toString());
      }
    };
  }, [open, report]);

  // Auto-scroll to the latest message
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSendMessage = () => {
    if (newMessage.trim() === '' || !adminUser.current) return;
    
    const messageData = {
      id_reporte: report.id,
      id_sender: adminUser.current.id,
      message_text: newMessage,
      sender_alias: 'Administrador'
    };

    socketService.emit('send-message', messageData);
    setNewMessage('');
  };

  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="sm">
      <DialogTitle>Chat - Reporte #{report?.id} ({report?.titulo})</DialogTitle>
      <DialogContent dividers sx={{ height: '50vh', p: 0 }}>
        <List sx={{ p: 2 }}>
          {messages.map((msg) => (
            <Box 
              key={msg.id} 
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
                }}
              >
                <ListItemText 
                  primary={msg.sender_alias} 
                  secondary={msg.message_text}
                  secondaryTypographyProps={{ color: 'white' }}
                />
              </Paper>
            </Box>
          ))}
          <div ref={messagesEndRef} />
        </List>
      </DialogContent>
      <DialogActions>
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