// src/pages/PaginaReportes.jsx
import React, { useEffect, useState, useCallback, useRef } from 'react';
import { 
  Box, Typography, CircularProgress, Alert, Fade, Container, Paper, Stack,
  Tabs, Tab, Badge
} from '@mui/material';
import { 
  Assessment as AssessmentIcon, 
  RateReview as RateReviewIcon,
  Dashboard as DashboardIcon,
  CheckCircle as CheckIcon
} from '@mui/icons-material';

import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce';
import ChatModal from '../components/ChatModal';

import FiltrosReportes from '../components/Reportes/FiltrosReportes';
import PanelSolicitudesRevision from '../components/Reportes/PanelSolicitudesRevision';
import ListaReportes from '../components/Reportes/ListaReportes';
import DrawerDetalleReporte from '../components/Reportes/DrawerDetalleReporte';

/**
 * Componente PaginaReportes - Diseño con Pestañas (Tabs)
 */
function PaginaReportes() {
    // --- Estados de Datos ---
    const [reports, setReports] = useState([]);
    const [categories, setCategories] = useState([]);
    const [reviewRequests, setReviewRequests] = useState([]);

    // --- Estados de Filtros ---
    const [filters, setFilters] = useState({ search: '', status: '', categoryId: '', sortBy: 'newest', distrito: '', planType: '', prioridad: '' });
    const [showOnlySuggested, setShowOnlySuggested] = useState(false);

    // --- Estados UI ---
    const [page, setPage] = useState(1);
    const [loading, setLoading] = useState(true);
    const [hasMore, setHasMore] = useState(true);
    const [globalError, setGlobalError] = useState('');
    const [tabIndex, setTabIndex] = useState(0); // Estado para controlar las pestañas

    // --- Estados Modales ---
    const [drawerOpen, setDrawerOpen] = useState(false);
    const [selectedReport, setSelectedReport] = useState(null);
    const [chatOpen, setChatOpen] = useState(false);

    const debouncedSearch = useDebounce(filters.search, 500);
    const isInitialMount = useRef(true);

    // --- Carga Inicial ---
    useEffect(() => {
        adminService.getAllCategories()
          .then(setCategories)
          .catch(err => console.error("Error fetching categories:", err));
    }, []);

    // --- Carga de Datos Principal ---
    const fetchReportsAndRequests = useCallback((isNewFilter = false) => {
        const pageToFetch = isNewFilter ? 1 : page;
        const currentFilters = {
            search: debouncedSearch,
            status: filters.status,
            categoryId: showOnlySuggested ? '' : filters.categoryId,
            sortBy: filters.sortBy,
            page: pageToFetch,
            suggestedOnly: showOnlySuggested ? 'true' : null,
            distrito: filters.distrito,
            planType: filters.planType,
            prioridad: filters.prioridad,
        };

        setLoading(true);
        setGlobalError('');

        if (isNewFilter) {
            setPage(1);
            setReports([]);
            setHasMore(true);
        }

        Promise.all([
            adminService.getAllAdminReports(currentFilters),
            adminService.getReviewRequests()
        ]).then(([newReports, requests]) => {
            setReports(prev => isNewFilter ? newReports : [...prev, ...newReports]);
            setReviewRequests(requests);
            setHasMore(newReports.length === 10); 
        }).catch(error => {
            console.error("Error fetching data:", error);
            setGlobalError("No se pudieron cargar los datos. Intente nuevamente.");
            setHasMore(false);
        }).finally(() => {
            setLoading(false);
            if (isInitialMount.current) isInitialMount.current = false;
        });
      
    }, [page, debouncedSearch, filters, showOnlySuggested]);

    useEffect(() => {
        fetchReportsAndRequests(true);
    }, [debouncedSearch, filters.status, filters.categoryId, filters.sortBy, showOnlySuggested, filters.distrito, filters.planType, filters.prioridad, fetchReportsAndRequests]);

    useEffect(() => {
        if (isInitialMount.current || page === 1) return;
        fetchReportsAndRequests(false);
    }, [page, fetchReportsAndRequests]);

    // --- Handlers UI ---
    const handleFilterChange = (name, value) => { setFilters(prev => ({ ...prev, [name]: value })); };
    const handleSortChange = (sortByValue) => { setFilters(prev => ({ ...prev, sortBy: sortByValue })); };
    const handleToggleSuggested = (isChecked) => { setShowOnlySuggested(isChecked); };
    const handleClearFilters = () => {
         setFilters({ search: '', status: '', categoryId: '', sortBy: 'newest', distrito: '', planType: '', prioridad: '' });
         setShowOnlySuggested(false);
    };
    const handleLoadMore = () => { if (!loading && hasMore) setPage(prevPage => prevPage + 1); };
    
    // Handler de Pestañas
    const handleTabChange = (event, newValue) => {
        setTabIndex(newValue);
    };

    // --- Handlers Modales ---
    const handleOpenDrawer = (report) => { setSelectedReport(report); setDrawerOpen(true); };
    const handleCloseDrawer = () => { setDrawerOpen(false); setTimeout(() => setSelectedReport(null), 300); };
    const handleOpenChat = (report) => { setSelectedReport(report); setChatOpen(true); setDrawerOpen(false);};
    const handleActionCompleted = () => { handleCloseDrawer(); fetchReportsAndRequests(true); };
    const handleResolveRequest = (id, action) => { 
        adminService.resolveReviewRequest(id, action)
            .then(() => fetchReportsAndRequests(true))
            .catch(err => alert(err.response?.data?.message || 'Error.')); 
    };

    // --- RENDER ---
    return (
        <Box sx={{ p: { xs: 2, md: 3 }, minHeight: '100vh', bgcolor: 'background.default' }}>
            <Container maxWidth="xl" disableGutters>
                
                {/* 1. Header Principal */}
                <Box sx={{ mb: 4 }}>
                    <Stack direction="row" alignItems="center" spacing={2} sx={{ mb: 1 }}>
                        <AssessmentIcon sx={{ fontSize: 40, color: 'primary.main' }} />
                        <Typography variant="h4" sx={{ fontWeight: 800, letterSpacing: '-0.5px' }}>
                            Control de Reportes
                        </Typography>
                    </Stack>
                    <Typography variant="body1" color="text.secondary" sx={{ maxWidth: '800px', ml: { sm: 7 } }}>
                        Supervisa, modera y gestiona todos los incidentes reportados por la ciudadanía.
                    </Typography>
                </Box>

                {globalError && (
                    <Fade in={true}>
                        <Alert severity="error" sx={{ mb: 3, borderRadius: 2 }}>{globalError}</Alert>
                    </Fade>
                )}

                {/* 2. Pestañas de Navegación */}
                <Box sx={{ borderBottom: 1, borderColor: 'divider', mb: 3 }}>
                    <Tabs 
                        value={tabIndex} 
                        onChange={handleTabChange}
                        sx={{ '& .MuiTab-root': { textTransform: 'none', fontWeight: 600, fontSize: '1rem', minHeight: 48 } }}
                    >
                        <Tab 
                            label="Explorador de Incidentes" 
                            icon={<DashboardIcon sx={{mb:0, mr:1}}/>} 
                            iconPosition="start" 
                        />
                        <Tab 
                            label={
                                <Badge 
                                    badgeContent={reviewRequests.length} 
                                    color="error" 
                                    max={99}
                                    sx={{ '& .MuiBadge-badge': { right: -15, top: 2, border: '2px solid white' } }}
                                >
                                    Solicitudes de Revisión
                                </Badge>
                            }
                            icon={<RateReviewIcon sx={{mb:0, mr:1}}/>} 
                            iconPosition="start" 
                            sx={{ px: 4, overflow: 'visible' }} // Espacio para el badge
                        />
                    </Tabs>
                </Box>

                {/* 3. Contenido Pestaña 0: Explorador */}
                {tabIndex === 0 && (
                    <Box>
                        <FiltrosReportes
                            filters={filters}
                            categories={categories}
                            showOnlySuggested={showOnlySuggested}
                            onFilterChange={handleFilterChange}
                            onSortChange={handleSortChange}
                            onToggleSuggested={handleToggleSuggested}
                            onClearFilters={handleClearFilters}
                            onLoadMore={handleLoadMore}
                            hasMore={hasMore}
                            loadingMore={loading && page > 0}
                        />

                        <Box sx={{ mt: 3 }}>
                            {loading && reports.length === 0 && page === 1 ? (
                                <Paper sx={{ p: 8, textAlign: 'center', borderRadius: 2 }} variant="outlined">
                                    <CircularProgress size={40} thickness={4} />
                                    <Typography variant="body2" sx={{ mt: 2, color: 'text.secondary' }}>
                                        Cargando reportes...
                                    </Typography>
                                </Paper>
                            ) : (
                                <ListaReportes
                                    reports={reports}
                                    onOpenDrawer={handleOpenDrawer}
                                />
                            )}
                        </Box>
                    </Box>
                )}

                {/* 4. Contenido Pestaña 1: Solicitudes de Revisión */}
                {tabIndex === 1 && (
                    <Box sx={{ minHeight: 400 }}>
                        {reviewRequests.length > 0 ? (
                            <PanelSolicitudesRevision
                                reviewRequests={reviewRequests}
                                onResolveRequest={handleResolveRequest}
                            />
                        ) : (
                            // Estado vacío amigable para la pestaña de solicitudes
                            <Paper 
                                variant="outlined" 
                                sx={{ p: 6, textAlign: 'center', borderRadius: 2, borderStyle: 'dashed' }}
                            >
                                <CheckIcon sx={{ fontSize: 60, color: 'success.light', mb: 2 }} />
                                <Typography variant="h6" fontWeight="bold">Todo está al día</Typography>
                                <Typography color="text.secondary">
                                    No hay solicitudes de revisión pendientes en este momento.
                                </Typography>
                            </Paper>
                        )}
                    </Box>
                )}

                {/* --- Modales y Drawers --- */}
                {selectedReport && chatOpen && (
                    <ChatModal 
                        open={chatOpen} 
                        onClose={() => setChatOpen(false)} 
                        report={selectedReport} 
                    />
                )}
                
                <DrawerDetalleReporte
                    report={selectedReport}
                    open={drawerOpen}
                    onClose={handleCloseDrawer}
                    onActionCompleted={handleActionCompleted}
                    onOpenChat={handleOpenChat}
                />

            </Container>
        </Box>
    );
}

export default PaginaReportes;