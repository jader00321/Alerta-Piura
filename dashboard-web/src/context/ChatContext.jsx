import React, { createContext, useState, useContext, useEffect, useCallback} from 'react';
import socketService from '../services/socketService';
// Aseguramos la importación del hook desde el archivo de Auth
import { useAuth } from './AuthContext'; 

const ChatContext = createContext(null);

// eslint-disable-next-line react-refresh/only-export-components
export const useChat = () => useContext(ChatContext);

export const ChatProvider = ({ children }) => {
    // Usamos el hook de Auth
    const { isAuthenticated } = useAuth(); 
    const [unreadCount, setUnreadCount] = useState(0);
    
    // Función para manejar el incremento de no leídos al recibir un mensaje
    const handleNewMessage = useCallback((data) => {
        // Incrementa el contador si el mensaje NO fue enviado por el Admin actual
        // El backend debe enviar 'es_admin: true' para los mensajes del admin
        if (!data.es_admin) { 
            setUnreadCount(prev => prev + 1);
        }
    }, []);
    
    // Función para cargar el conteo inicial (si tu adminService.getUnreadChatCount existe)
    // const loadInitialCount = () => { /* ... load initial count from API ... */ };

    useEffect(() => {
        if (!isAuthenticated) return;
        
        // Al autenticarse, cargar el conteo inicial (si no lo hace el header)
        // loadInitialCount(); 

        // Suscribirse al evento de mensaje y al evento global de notificación
        socketService.on('receive-message', handleNewMessage);
        // Este evento se emite para forzar un refresco visual en el Header
        socketService.on('new_chat_notification', () => setUnreadCount(prev => prev + 1)); 

        return () => {
            socketService.off('receive-message', handleNewMessage);
            socketService.off('new_chat_notification');
        };
    }, [isAuthenticated, handleNewMessage]);

    const resetUnreadCount = () => {
        // Idealmente, llamar al backend para marcar TODOS los chats como leídos
        setUnreadCount(0);
        // Si tienes una función en adminService para marcar todos los chats como leídos, llámala aquí.
    };

    return (
        <ChatContext.Provider value={{ unreadCount, resetUnreadCount }}>
            {children}
        </ChatContext.Provider>
    );
};