// src/pages/ReportsManagementPage.jsx
import React, { useEffect, useState, useCallback, useRef } from 'react';
import { Box, Typography, CircularProgress, Divider } from '@mui/material';
import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce';
import ChatModal from '../components/ChatModal';

import FiltrosReportes from '../components/Reportes/FiltrosReportes';
import PanelSolicitudesRevision from '../components/Reportes/PanelSolicitudesRevision';
import ListaReportes from '../components/Reportes/ListaReportes';
import DrawerDetalleReporte from '../components/Reportes/DrawerDetalleReporte';

function PaginaReportes() {
    const [reports, setReports] = useState([]);
    const [categories, setCategories] = useState([]);
    const [reviewRequests, setReviewRequests] = useState([]);
    const [filters, setFilters] = useState({ search: '', status: '', categoryId: '', sortBy: 'newest', distrito: '', planType: '', prioridad: '' });
    const [showOnlySuggested, setShowOnlySuggested] = useState(false);
    const [page, setPage] = useState(1);
    const [loading, setLoading] = useState(true); // Single loading state
    const [hasMore, setHasMore] = useState(true);
    const [drawerOpen, setDrawerOpen] = useState(false);
    const [selectedReport, setSelectedReport] = useState(null);
    const [chatOpen, setChatOpen] = useState(false);

    const debouncedSearch = useDebounce(filters.search, 500);
    const isInitialMount = useRef(true); // Ref para controlar carga inicial

    // Fetch categories only once
    useEffect(() => {
        adminService.getAllCategories()
          .then(setCategories)
          .catch(err => console.error("Error fetching categories:", err));
    }, []);

    // --- LÓGICA DE CARGA CENTRALIZADA ---
    const fetchReportsAndRequests = useCallback((isNewFilter = false) => {
        const pageToFetch = isNewFilter ? 1 : page; // Usar 'page' state actual si no es filtro nuevo
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

        console.log("Fetching data with filters:", currentFilters, "Is New Filter:", isNewFilter); // Log para depuración
        setLoading(true);
        if (isNewFilter) {
            setPage(1); // Importante resetear la página para filtros nuevos ANTES de llamar a la API
            setReports([]); // Limpia visualmente al instante
            setHasMore(true); // Asume que habrá resultados
        }

        Promise.all([
            adminService.getAllAdminReports(currentFilters),
            adminService.getReviewRequests()
        ]).then(([newReports, requests]) => {
            console.log("Received new reports:", newReports.length, "Has More:", newReports.length === 10); // Log
            setReports(prev => isNewFilter ? newReports : [...prev, ...newReports]);
            setReviewRequests(requests);
            setHasMore(newReports.length === 10);
            // El estado 'page' se actualiza en handleLoadMore *antes* de esta llamada si isNewFilter es false
        }).catch(error => {
            console.error("Error fetching data:", error);
            setHasMore(false);
        }).finally(() => {
            setLoading(false);
            // Marca que el montaje inicial ya pasó después de la primera carga
            if (isInitialMount.current) {
                isInitialMount.current = false;
            }
        });
     
    }, [page, debouncedSearch, filters, showOnlySuggested]); // Dependencias originales que funcionaban

    // --- EFFECT PARA CARGA INICIAL Y CAMBIO DE FILTROS ---
    useEffect(() => {
        // Llama siempre que cambien los filtros, reseteando a página 1
        console.log("Filter change detected, fetching page 1"); // Log
        fetchReportsAndRequests(true);
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [debouncedSearch, filters.status, filters.categoryId, filters.sortBy, showOnlySuggested, filters.distrito, filters.planType, filters.prioridad]); // Dependencias de filtros


     // --- EFFECT PARA PAGINACIÓN (CARGAR MÁS) ---
      useEffect(() => {
          // No hacer nada en el montaje inicial O si es la página 1 (ya cargada por el effect de filtros)
          if (isInitialMount.current || page === 1) return;

          console.log(`Page changed to ${page}, fetching more...`); // Log
          // Cargar la página actual (que fue incrementada en handleLoadMore)
          fetchReportsAndRequests(false); // 'false' indica que no es un filtro nuevo

      // eslint-disable-next-line react-hooks/exhaustive-deps
      }, [page]); // Solo depende de 'page'


    // --- Handlers ---
    const handleFilterChange = (name, value) => { setFilters(prev => ({ ...prev, [name]: value })); };
    const handleSortChange = (sortByValue) => { setFilters(prev => ({ ...prev, sortBy: sortByValue })); };
    const handleToggleSuggested = (isChecked) => { setShowOnlySuggested(isChecked); };
    const handleClearFilters = () => {
         setFilters({ search: '', status: '', categoryId: '', sortBy: 'newest', distrito: '', planType: '', prioridad: '' });
         setShowOnlySuggested(false);
    };

    // --- handleLoadMore CORREGIDO ---
    const handleLoadMore = () => {
        if (!loading && hasMore) {
            console.log("Load More clicked, incrementing page..."); // Log
            // Actualiza el estado de la página, lo que disparará el useEffect [page]
            setPage(prevPage => prevPage + 1);
        }
    };

    // --- Drawer, Chat, Action Handlers (Sin cambios) ---
    const handleOpenDrawer = (report) => { setSelectedReport(report); setDrawerOpen(true); };
    const handleCloseDrawer = () => { setDrawerOpen(false); setTimeout(() => setSelectedReport(null), 300); };
    const handleOpenChat = (report) => { setSelectedReport(report); setChatOpen(true); setDrawerOpen(false);};
    const handleActionCompleted = () => { handleCloseDrawer(); fetchReportsAndRequests(true); };
    const handleResolveRequest = (id, action) => { adminService.resolveReviewRequest(id, action).then(() => fetchReportsAndRequests(true)).catch(err => alert(err.response?.data?.message || 'Error.')); };

    return (
        <Box sx={{ p: { xs: 1, sm: 2, md: 3 } }}>
            <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
                Gestión General de Reportes
            </Typography>

            <PanelSolicitudesRevision
                reviewRequests={reviewRequests}
                onResolveRequest={handleResolveRequest}
            />

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
                loadingMore={loading && page > 0} // Indicador correcto para el botón
            />

            {/* Carga Inicial (basada en loading y si reports está vacío Y es la primera carga) o Lista */}
            {loading && reports.length === 0 && page === 1 ? (
                <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}>
                    <CircularProgress size={50}/>
                </Box>
            ) : (
                <ListaReportes
                    reports={reports}
                    onOpenDrawer={handleOpenDrawer}
                    // No necesita props de carga/paginación
                />
            )}

            {/* Modales */}
            {selectedReport && chatOpen && (<ChatModal open={chatOpen} onClose={() => setChatOpen(false)} report={selectedReport} />)}
            <DrawerDetalleReporte
                report={selectedReport}
                open={drawerOpen}
                onClose={handleCloseDrawer}
                onActionCompleted={handleActionCompleted}
                onOpenChat={handleOpenChat}
            />
        </Box>
    );
}

export default PaginaReportes;