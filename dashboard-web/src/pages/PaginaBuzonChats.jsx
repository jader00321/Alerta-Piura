import React, { useState, useEffect } from 'react';
import { 
    Box, Paper, Typography, List, ListItemButton, ListItemAvatar, 
    Avatar, ListItemText, Divider, TextField, InputAdornment, 
    Badge, Tabs, Tab, CircularProgress, useTheme 
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import ChatIcon from '@mui/icons-material/Chat';
import adminService from '../services/adminService';
import { useChat } from '../context/ChatContext';
import VentanaChatEmbed from '../components/Chat/VentanaChatEmbed';
import ModalDetalleReporteResumen from '../components/Resumen/ModalDetalleReporteResumen'; // Importar Modal

function PaginaBuzonChats() {
    const theme = useTheme();
    const [conversations, setConversations] = useState([]);
    const [filteredConversations, setFilteredConversations] = useState([]);
    const [selectedChat, setSelectedChat] = useState(null);
    const [search, setSearch] = useState('');
    const [tabIndex, setTabIndex] = useState(0); 
    const [loading, setLoading] = useState(true);
    
    // Estados para el Modal de Detalles
    const [detailOpen, setDetailOpen] = useState(false);
    const [selectedReportData, setSelectedReportData] = useState(null);
    
    const { resetUnreadCount } = useChat();

    useEffect(() => {
        loadConversations();
        resetUnreadCount(); 
    }, [resetUnreadCount]);

    // Lógica de Filtrado y Ordenamiento
    useEffect(() => {
        let result = [...conversations]; // Copia para no mutar
        
        // 1. Filtro
        if (search) {
            const lower = search.toLowerCase();
            result = result.filter(c => 
                c.usuario_nombre?.toLowerCase().includes(lower) || 
                c.reporte_titulo?.toLowerCase().includes(lower)
            );
        }
        if (tabIndex === 1) {
            result = result.filter(c => parseInt(c.unread_count) > 0);
        }
        // 2. Ordenamiento por fecha_envio descendente
        result.sort((a, b) => new Date(b.fecha_envio) - new Date(a.fecha_envio));

        setFilteredConversations(result);
    }, [search, tabIndex, conversations]);

    const loadConversations = async () => {
        setLoading(true);
        try {
            const data = await adminService.getAllConversations();
            const dataWithCounts = data.map(c => ({
                ...c,
                unread_count: parseInt(c.unread_count) || 0,
                fecha_envio: c.fecha_envio ? new Date(c.fecha_envio) : new Date(0)
            }));
            setConversations(dataWithCounts);
        } catch (error) {
            console.error("Error cargando buzón:", error);
        } finally {
            setLoading(false);
        }
    };

    const handleSelectChat = (chat) => {
        setSelectedChat(chat);
        // MARCAR LOCALMENTE COMO LEÍDO (para que desaparezca el badge sin recargar todo)
        setConversations(prev => prev.map(c => 
            c.id_reporte === chat.id_reporte ? { ...c, unread_count: 0 } : c
        ));
    };

    // Función para abrir el modal con los detalles completos
    const handleOpenDetails = async (reportId) => {
        try {
            const data = await adminService.getReportById(reportId);
            setSelectedReportData(data);
            setDetailOpen(true);
        } catch (error) {
            console.error("Error fetching report details:", error);
        }
    };

    // Cuando envío un mensaje, actualizo la lista para que suba
    const handleMessageSent = (reportId, msgText) => {
        setConversations(prev => {
            const updated = prev.map(c => {
                if (c.id_reporte === reportId) {
                    return { ...c, mensaje: msgText, fecha_envio: new Date() };
                }
                return c;
            });
            return updated; // El useEffect se encargará de reordenar
        });
    };

    const unreadTotal = conversations.filter(c => c.unread_count > 0).length;

    const isDark = theme.palette.mode === 'dark';
    const paperBackground = isDark ? theme.palette.background.paper : 'white';
    
    return (
        <Box sx={{ height: 'calc(100vh - 80px)', p: { xs: 1, md: 2 } }}>
            <Paper 
                elevation={3}
                sx={{ height: '100%', maxWidth: '110%',display: 'flex', overflow: 'hidden', borderRadius: 2, border: 1, borderColor: theme.palette.divider }}
            >
                {/* Lista Chats */}
                <Box sx={{ width: { xs: '100%', sm: 300, md: 380 }, borderRight: 1, borderColor: 'divider', display: 'flex', flexDirection: 'column', bgcolor: paperBackground }}>
                    {/* Header y Search... (Código igual al anterior) */}
                    <Box sx={{ p: 2, bgcolor: paperBackground, borderBottom: 1, borderColor: theme.palette.divider }}>
                        <Typography variant="h6" fontWeight="bold" mb={1}>Buzón de Chats</Typography>
                        <TextField
                            fullWidth size="small" placeholder="Buscar..."
                            value={search} onChange={(e) => setSearch(e.target.value)}
                            InputProps={{ startAdornment: <InputAdornment position="start"><SearchIcon/></InputAdornment>, sx: { borderRadius: 2 } }}
                        />
                    </Box>
                    
                    <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
                        <Tabs value={tabIndex} onChange={(_, v) => setTabIndex(v)} variant="fullWidth">
                            <Tab label="Todos" />
                            <Tab label={
                             <Badge badgeContent={unreadTotal} color="error" sx={{ '& .MuiBadge-badge': { right: -10, top: -5 } }}>
                                 No leídos
                             </Badge>
                        } />
                        </Tabs>
                    </Box>

                    <List sx={{ flexGrow: 1, overflow: 'auto', p: 0 }}>
                        {loading ? <Box p={4} display="flex" justifyContent="center"><CircularProgress/></Box> : 
                        filteredConversations.map((chat) => (
                            <React.Fragment key={chat.id_reporte}>
                                <ListItemButton 
                                    selected={selectedChat?.id_reporte === chat.id_reporte}
                                    onClick={() => handleSelectChat(chat)}
                                    sx={{ 
                                        py: 1.5, 
                                        bgcolor: selectedChat?.id_reporte === chat.id_reporte ? (isDark ? theme.palette.action.selected : '#f0f0f0') : 'transparent',
                                        borderLeft: parseInt(chat.unread_count) > 0 ? `4px solid ${theme.palette.success.main}` : '4px solid transparent'
                                    }}
                                >
                                    <ListItemAvatar>
                                        <Badge badgeContent={parseInt(chat.unread_count)} color="success">
                                            <Avatar src={chat.foto_url} sx={{ bgcolor: theme.palette.primary.light }}>{chat.usuario_nombre?.[0]}</Avatar>
                                        </Badge>
                                    </ListItemAvatar>
                                    <ListItemText 
                                        primary={
                                            <Box display="flex" justifyContent="space-between">
                                                <Typography variant="subtitle2" fontWeight={parseInt(chat.unread_count)>0 ? "bold" : "regular"} noWrap sx={{ maxWidth: 140 }}>
                                                    {chat.usuario_nombre}
                                                </Typography>
                                                <Typography variant="caption" color="text.secondary">
                                                    {new Date(chat.fecha_envio).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
                                                </Typography>
                                            </Box>
                                        }
                                        secondary={<Typography variant="body2" color="text.secondary" noWrap>{chat.mensaje}</Typography>}
                                    />
                                </ListItemButton>
                                <Divider component="li" />
                            </React.Fragment>
                        ))}
                    </List>
                </Box>

                {/* Panel Chat */}
                <Box sx={{ flexGrow: 1, minWidth: '650px', bgcolor: isDark ? theme.palette.background.default : '#efe7dd', backgroundImage: isDark ? 'none' : 'url("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png")', backgroundBlendMode: 'overlay' }}>
                    {selectedChat ? (
                        <VentanaChatEmbed 
                            report={{ id: selectedChat.id_reporte, titulo: selectedChat.reporte_titulo, codigo_reporte: selectedChat.codigo_reporte }} 
                            onOpenDetails={handleOpenDetails}
                            onMessageSent={handleMessageSent}
                        />
                    ) : (
                        <Box sx={{ height: '100%', display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column', color: 'text.secondary' }}>
                            <ChatIcon sx={{ fontSize: 80, opacity: 0.5, mb: 2 }} />
                            <Typography variant="h5">Selecciona un chat</Typography>
                        </Box>
                    )}
                </Box>
            </Paper>

            {/* Modal de Detalles */}
            <ModalDetalleReporteResumen
                report={selectedReportData}
                open={detailOpen}
                onClose={() => setDetailOpen(false)}
                readOnly={true} // <-- MODO LECTURA
                onAction={() => {}}
            />
        </Box>
    );
}

export default PaginaBuzonChats;