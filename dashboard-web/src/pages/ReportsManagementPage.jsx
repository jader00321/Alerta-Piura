import React, { useEffect, useState, useCallback, useRef } from 'react';
import { Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography, Button, IconButton, Grid, TextField, Select, MenuItem, FormControl, InputLabel, Tooltip, Chip, Avatar, ButtonGroup } from '@mui/material';
import { Delete as DeleteIcon, Chat as ChatIcon } from '@mui/icons-material';
import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce';
import ChatModal from '../components/ChatModal'; 

// Helper para colores de Chip de Estado
const getStatusChipColor = (status) => {
    switch (status) {
        case 'verificado': return 'success';
        case 'rechazado': return 'error';
        case 'pendiente_verificacion': return 'warning';
        default: return 'default';
    }
};

function ReportsManagementPage() {
    const [chatOpen, setChatOpen] = useState(false);
    const [selectedReportForChat, setSelectedReportForChat] = useState(null);
    
    const [reports, setReports] = useState([]);
    const [categories, setCategories] = useState([]);
    
    const [filters, setFilters] = useState({ search: '', status: '', categoryId: '', sortBy: 'newest' });
    const [page, setPage] = useState(1);
    const [loading, setLoading] = useState(true);
    const [hasMore, setHasMore] = useState(true);
    
    const debouncedSearch = useDebounce(filters.search, 500);
    // Usamos una ref para evitar que el cambio de filtros reinicie la carga inicial
    const isInitialMount = useRef(true);

    const fetchReports = useCallback((isNewFilter) => {
        setLoading(true);
        const activeFilters = { ...filters, search: debouncedSearch, page: isNewFilter ? 1 : page };

        adminService.getAllAdminReports(activeFilters)
            .then(newReports => {
                setReports(prev => isNewFilter ? newReports : [...prev, ...newReports]);
                // Si devuelve menos de 20, ya no hay más páginas
                setHasMore(newReports.length === 20);
            })
            .catch(console.error)
            .finally(() => setLoading(false));
    }, [page, debouncedSearch, filters]);

    // Carga inicial de categorías
    useEffect(() => {
        adminService.getAllCategories().then(setCategories);
    }, []);

    // Efecto para cargar más páginas
    useEffect(() => {
        if (!isInitialMount.current) {
            fetchReports(false);
        }
    }, [page]);
    
    // Efecto para re-buscar cuando los filtros cambian
    useEffect(() => {
        // Para evitar doble carga al inicio
        if (isInitialMount.current) {
            isInitialMount.current = false;
            fetchReports(true);
            return;
        }
        setPage(1); // Reinicia la paginación
        fetchReports(true); // Carga con nuevos filtros
    }, [debouncedSearch, filters.status, filters.categoryId, filters.sortBy]);


    const handleFilterChange = (e) => {
        const { name, value } = e.target;
        setFilters(prev => ({ ...prev, [name]: value }));
    };
    
    const handleSortChange = (sortByValue) => {
        setFilters(prev => ({ ...prev, sortBy: sortByValue }));
    };

    const handleLoadMore = () => {
        setPage(prevPage => prevPage + 1);
    };

    const handleOpenChat = (report) => {
        setSelectedReportForChat(report);
        setChatOpen(true);
    };
 
    return (
        <Box>
            <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>Gestión General de Reportes</Typography>
            
            <Paper sx={{ p: 2, mb: 3 }}>
                <Grid container spacing={2} alignItems="center">
                    <Grid item xs={12} md={4}><TextField fullWidth size="small" label="Buscar por título o autor" name="search" value={filters.search} onChange={handleFilterChange} /></Grid>
                    <Grid item xs={6} md={2}><FormControl fullWidth size="small"><InputLabel>Estado</InputLabel><Select name="status" value={filters.status} label="Estado" onChange={handleFilterChange}><MenuItem value="">Todos</MenuItem><MenuItem value="pendiente_verificacion">Pendiente</MenuItem><MenuItem value="verificado">Verificado</MenuItem><MenuItem value="rechazado">Rechazado</MenuItem></Select></FormControl></Grid>
                    <Grid item xs={6} md={2}><FormControl fullWidth size="small"><InputLabel>Categoría</InputLabel><Select name="categoryId" value={filters.categoryId} label="Categoría" onChange={handleFilterChange}><MenuItem value="">Todas</MenuItem>{categories.map(cat => <MenuItem key={cat.id} value={cat.id}>{cat.nombre}</MenuItem>)}</Select></FormControl></Grid>
                    <Grid item xs={12} md={4}><ButtonGroup fullWidth size="small"><Button variant={filters.sortBy === 'newest' ? 'contained' : 'outlined'} onClick={() => handleSortChange('newest')}>Más Recientes</Button><Button variant={filters.sortBy === 'oldest' ? 'contained' : 'outlined'} onClick={() => handleSortChange('oldest')}>Más Antiguos</Button></ButtonGroup></Grid>
                </Grid>
            </Paper>

            <TableContainer component={Paper}>
                <Table>
                    <TableHead>
                        <TableRow>
                            <TableCell></TableCell>
                            <TableCell>Código</TableCell>
                            <TableCell>Título</TableCell>
                            <TableCell>Estado</TableCell>
                            <TableCell>Distrito</TableCell>
                            <TableCell>Urgencia</TableCell>
                            <TableCell>Líder Verificador</TableCell>
                            <TableCell>Fecha Creación</TableCell>
                            <TableCell>Acciones</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {reports.map((report) => (
                            <TableRow key={report.id} hover>
                                <TableCell><Avatar variant="rounded" src={report.foto_url}> </Avatar></TableCell>
                                <TableCell sx={{ fontWeight: 'bold' }}>{report.codigo_reporte}</TableCell>
                                <TableCell>{report.titulo}</TableCell>
                                <TableCell><Chip label={report.estado.replace(/_/g, ' ')} color={getStatusChipColor(report.estado)} size="small" /></TableCell>
                                <TableCell>{report.distrito || 'N/A'}</TableCell>
                                <TableCell>{report.urgencia || 'N/A'}</TableCell>
                                <TableCell>{report.lider_verificador_alias || '---'}</TableCell>
                                <TableCell>{report.fecha_creacion}</TableCell>
                                <TableCell>
                                    <Tooltip title="Contactar Usuario"><IconButton size="small" color="primary" onClick={() => handleOpenChat(report)}><ChatIcon /></IconButton></Tooltip>
                                    <Tooltip title="Eliminar Reporte"><IconButton size="small" color="error"><DeleteIcon /></IconButton></Tooltip>
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
            
            {hasMore && (
                <Box sx={{ display: 'flex', justifyContent: 'center', p: 2 }}>
                    <Button variant="contained" onClick={handleLoadMore} disabled={loading}>
                        {loading ? 'Cargando...' : 'Cargar Más Reportes'}
                    </Button>
                </Box>
            )}

            {selectedReportForChat && (
                <ChatModal open={chatOpen} onClose={() => setChatOpen(false)} report={selectedReportForChat} />
            )}
        </Box>
    );
}

export default ReportsManagementPage;