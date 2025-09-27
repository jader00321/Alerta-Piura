import React, { useEffect, useState, useCallback, useRef } from 'react';
import { Box, Paper, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography, Button, IconButton, Grid, TextField, Select, MenuItem, FormControl, InputLabel, Tooltip, Chip, Avatar, ButtonGroup } from '@mui/material';
import { MoreVert as MoreVertIcon, ImageNotSupported as NoImageIcon, CheckCircleOutline as CheckIcon, CancelOutlined as RejectIcon, HourglassEmpty as PendingIcon, HelpOutline as SuggestionIcon, ThumbUp as ApproveIcon, ThumbDown as DisapproveIcon } from '@mui/icons-material';
import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce';
import ChatModal from '../components/ChatModal';
import ReportDetailDrawer from '../components/ReportDetailDrawer';

// MEJORA: Nuevo componente para los chips de estado
const StatusChip = ({ status }) => {
    const statusInfo = {
        verificado: { label: 'Verificado', color: 'success', icon: <CheckIcon /> },
        rechazado: { label: 'Rechazado', color: 'error', icon: <RejectIcon /> },
        pendiente_verificacion: { label: 'Pendiente', color: 'warning', icon: <PendingIcon /> },
    };
    const info = statusInfo[status] || { label: status, color: 'default', icon: <></> };
    return <Chip icon={info.icon} label={info.label} color={info.color} size="small" variant="outlined" />;
};

function ReportsManagementPage() {
    // El resto de tus estados se mantienen igual...
    const [reports, setReports] = useState([]);
    const [categories, setCategories] = useState([]);
    const [reviewRequests, setReviewRequests] = useState([]);
    const [filters, setFilters] = useState({ search: '', status: '', categoryId: '', sortBy: 'newest' });
    const [showOnlySuggested, setShowOnlySuggested] = useState(false);
    const [page, setPage] = useState(1);
    const [loading, setLoading] = useState(false);
    const [hasMore, setHasMore] = useState(true);
    const [drawerOpen, setDrawerOpen] = useState(false);
    const [selectedReport, setSelectedReport] = useState(null);
    const [chatOpen, setChatOpen] = useState(false);
     
    const debouncedSearch = useDebounce(filters.search, 500);
    const isInitialMount = useRef(true);
     
    // La lógica de fetching de datos que ya tienes está bien, la mantendremos.
    // ... (toda la lógica de fetching y handlers que ya tenías)
    const fetchReportsAndRequests = useCallback((isNewFilter) => {
        const currentFilters = { 
            ...filters, 
            search: debouncedSearch, 
            page: isNewFilter ? 1 : page,
            suggestedOnly: showOnlySuggested ? 'true' : null,
            categoryId: showOnlySuggested ? '' : filters.categoryId // Ignora el ID de categoría si se filtran sugerencias
        };
        setLoading(true);
        Promise.all([
            adminService.getAllAdminReports(currentFilters),
            adminService.getReviewRequests()
        ]).then(([newReports, requests]) => {
            setReports(isNewFilter ? newReports : [...reports, ...newReports]);
            setReviewRequests(requests);
            setHasMore(newReports.length === 20);
            if(isNewFilter) setPage(1);
        }).catch(console.error).finally(() => setLoading(false));
    }, [page, debouncedSearch, filters, reports, showOnlySuggested]);

    useEffect(() => {
        adminService.getAllCategories().then(setCategories);
        fetchReportsAndRequests(true);
    }, []);

    useEffect(() => {
        if (isInitialMount.current) {
            isInitialMount.current = false;
            return;
        }
        fetchReportsAndRequests(true);
    }, [debouncedSearch, filters.status, filters.categoryId, filters.sortBy, showOnlySuggested]);

    const handleFilterChange = (e) => {
        const { name, value } = e.target;
        setFilters(prev => ({ ...prev, [name]: value }));
        if (name === 'categoryId' && value !== '') {
            setShowOnlySuggested(false);
        }
    };
     
    const handleSortChange = (sortByValue) => {
        setFilters(prev => ({ ...prev, sortBy: sortByValue }));
    };

    const handleLoadMore = () => {
        const nextPage = page + 1;
        setLoading(true);
        const currentFilters = { 
            ...filters, 
            search: debouncedSearch, 
            page: nextPage,
            suggestedOnly: showOnlySuggested ? 'true' : null,
            categoryId: showOnlySuggested ? '' : filters.categoryId
        };
        adminService.getAllAdminReports(currentFilters)
            .then(newReports => {
                setReports(prev => [...prev, ...newReports]);
                setHasMore(newReports.length === 20);
                setPage(nextPage);
            }).catch(console.error).finally(() => setLoading(false));
    };
     
    const handleOpenDrawer = (report) => {
        setSelectedReport(report);
        setDrawerOpen(true);
    };

    const handleCloseDrawer = () => {
        setDrawerOpen(false);
        setSelectedReport(null);
    };
     
    const handleOpenChat = (report) => {
        setSelectedReport(report);
        setChatOpen(true);
    };

    const handleActionCompleted = () => {
        fetchReportsAndRequests(true);
        handleCloseDrawer();
    };
     
    const handleResolveRequest = (id, action) => {
        adminService.resolveReviewRequest(id, action)
            .then(() => {
                fetchReportsAndRequests(true);
            })
            .catch(err => alert(err.response?.data?.message || 'Error al resolver la solicitud.'));
    };
     
    return (
        <Box>
            <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>Gestión General de Reportes</Typography>
            <Box mb={4}>
                <Typography variant="h6" gutterBottom>Solicitudes de Revisión Pendientes</Typography>
                {reviewRequests.length > 0 ? (
                    <Grid container spacing={2}>
                        {reviewRequests.map(req => (
                            <Grid item key={req.id} xs={12} sm={6} md={4}>
                                <Paper elevation={2} sx={{ p: 2, display: 'flex', flexDirection: 'column', height: '100%' }}>
                                    <Typography variant="caption" color="text.secondary">Solicitud de {req.lider_nombre || req.lider_alias}</Typography>
                                    <Typography variant="body1" sx={{ fontWeight: 'bold' }}>{req.titulo}</Typography>
                                    <Typography variant="body2" color="text.secondary">Código: {req.codigo_reporte}</Typography>
                                    <Typography variant="body2" color="text.secondary">Fecha: {req.fecha_reporte}</Typography>
                                    <Box mt="auto" pt={2} display="flex" justifyContent="flex-end" gap={1}>
                                        <Button size="small" variant="outlined" startIcon={<DisapproveIcon />} onClick={() => handleResolveRequest(req.id, 'desestimar')}>Desestimar</Button>
                                        <Button size="small" variant="contained" color="success" startIcon={<ApproveIcon />} onClick={() => handleResolveRequest(req.id, 'aprobar')}>Re-evaluar</Button>
                                    </Box>
                                </Paper>
                            </Grid>
                        ))}
                    </Grid>
                ) : ( <Typography color="text.secondary">No hay solicitudes de revisión pendientes.</Typography> )}
            </Box>

            {/* Filtros (sin cambios) */}
            <Paper sx={{ p: 2, mb: 3, display: 'flex', gap: 2, flexWrap: 'wrap', alignItems: 'center' }}>
                 {/* ... tu JSX de filtros aquí ... */}
                 <TextField fullWidth size="small" label="Buscar por título o autor" name="search" value={filters.search} onChange={handleFilterChange} sx={{ flexGrow: 1, minWidth: '200px' }}/>
                <FormControl sx={{ minWidth: 150 }} size="small">
                    <InputLabel>Estado</InputLabel>
                    <Select name="status" value={filters.status} label="Estado" onChange={handleFilterChange}>
                        <MenuItem value="">Todos</MenuItem>
                        <MenuItem value="pendiente_verificacion">Pendiente</MenuItem>
                        <MenuItem value="verificado">Verificado</MenuItem>
                        <MenuItem value="rechazado">Rechazado</MenuItem>
                    </Select>
                </FormControl>
                <FormControl sx={{ minWidth: 150 }} size="small" disabled={showOnlySuggested}>
                    <InputLabel>Categoría</InputLabel>
                    <Select name="categoryId" value={filters.categoryId} label="Categoría" onChange={handleFilterChange}>
                        <MenuItem value="">Todas</MenuItem>
                        {categories.map(cat => <MenuItem key={cat.id} value={cat.id}>{cat.nombre}</MenuItem>)}
                    </Select>
                </FormControl>
                 
                {/* NUEVO: Botón para filtrar solo categorías sugeridas */}
                <Button 
                    variant={showOnlySuggested ? 'contained' : 'outlined'}
                    color="info"
                    onClick={() => {
                        setShowOnlySuggested(!showOnlySuggested);
                        if (!showOnlySuggested) { // Al activar, limpiar filtro de categoría
                            setFilters(prev => ({ ...prev, categoryId: '' }));
                        }
                    }}
                >
                    Sugeridas
                </Button>
                <ButtonGroup size="20px" sx={{ ml: 'auto', display: 'flex', gap: 1, p:1}}>
                    <Button variant={filters.sortBy === 'newest' ? 'contained' : 'outlined'} onClick={() => handleSortChange('newest')}>Más Recientes</Button>
                    <Button variant={filters.sortBy === 'oldest' ? 'contained' : 'outlined'} onClick={() => handleSortChange('oldest')}>Más Antiguos</Button>
                </ButtonGroup>

                <Box sx={{ display: 'flex', justifyContent: 'center', p: 1 }}>
                    <Button variant="contained" onClick={handleLoadMore} disabled={loading}>
                        {loading ? 'Cargando...' : 'Cargar Más Reportes'}
                    </Button>
                </Box>
            </Paper>

            <TableContainer component={Paper}>
                <Table>
                    <TableHead>
                        <TableRow>
                            {/* NUEVO: Columna de numeración */}
                            <TableCell sx={{ fontWeight: 'bold' }}>#</TableCell>
                            <TableCell>Imagen</TableCell>
                            <TableCell>Código</TableCell>
                            <TableCell>Título</TableCell>
                            <TableCell>Autor</TableCell>
                            <TableCell>Categoría</TableCell>
                            <TableCell>Estado</TableCell>
                            <TableCell>Distrito</TableCell>
                            <TableCell>Urgencia</TableCell>
                            <TableCell>Líder Verificador</TableCell>
                            <TableCell>Fecha Creación</TableCell>
                            <TableCell align="center">Acciones</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {reports.map((report, index) => (
                            <TableRow key={report.id} hover>
                                <TableCell>{index + 1}</TableCell>
                                <TableCell>
                                    <Avatar variant="rounded" src={report.foto_url}>
                                        <NoImageIcon />
                                    </Avatar>
                                </TableCell>
                                <TableCell sx={{ fontWeight: 'bold' }}>{report.codigo_reporte}</TableCell>
                                <TableCell>{report.titulo}</TableCell>
                                <TableCell>{report.autor_nombre || report.autor_alias || 'Anónimo'}</TableCell>
                                <TableCell>
                                    {report.categoria_sugerida ? (
                                        <Tooltip title={`Sugerencia del usuario`}>
                                            <Chip 
                                                icon={<SuggestionIcon />} 
                                                label={report.categoria_sugerida} 
                                                size="small" 
                                                variant="outlined" 
                                                color="info"
                                            />
                                        </Tooltip>
                                    ) : (
                                        report.categoria
                                    )}
                                </TableCell>
                                <TableCell><StatusChip status={report.estado} /></TableCell>
                                <TableCell>{report.distrito || 'N/A'}</TableCell>
                                <TableCell>{report.urgencia || 'N/A'}</TableCell>
                                <TableCell>{report.lider_verificador_alias || '---'}</TableCell>
                                <TableCell>{new Date(report.fecha_creacion).toLocaleDateString()}</TableCell>
                                <TableCell align="center">
                                    <Tooltip title="Ver Detalles y Acciones">
                                        <IconButton size="small" onClick={() => handleOpenDrawer(report)}>
                                            <MoreVertIcon />
                                        </IconButton>
                                    </Tooltip>
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

            {selectedReport && (
                <ChatModal open={chatOpen} onClose={() => setChatOpen(false)} report={selectedReport} />
            )}

            {selectedReport && (
                <ReportDetailDrawer 
                    report={selectedReport}
                    open={drawerOpen}
                    onClose={handleCloseDrawer}
                    onActionCompleted={handleActionCompleted}
                    onOpenChat={handleOpenChat}
                />
            )}
        </Box>
    );
}

export default ReportsManagementPage;