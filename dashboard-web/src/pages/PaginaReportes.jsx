// src/pages/ReportsManagementPage.jsx (renombrado a PaginaReportes en el export)
import React, { useEffect, useState, useCallback, useRef } from 'react';
import { Box, Typography, CircularProgress, Divider } from '@mui/material';
import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce';
import ChatModal from '../components/ChatModal';

import FiltrosReportes from '../components/Reportes/FiltrosReportes';
import PanelSolicitudesRevision from '../components/Reportes/PanelSolicitudesRevision';
import ListaReportes from '../components/Reportes/ListaReportes';
import DrawerDetalleReporte from '../components/Reportes/DrawerDetalleReporte';

/**
 * Componente PaginaReportes: Página principal para la gestión general de reportes.
 * Incluye carga de reportes con filtros, paginación infinita, panel de solicitudes de revisión,
 * y modales para ver detalles de reportes y chatear con usuarios.
 * 
 * Funcionalidades principales:
 * - Carga inicial de categorías, reportes y solicitudes de revisión.
 * - Filtros avanzados con búsqueda debounced y opciones de ordenamiento.
 * - Paginación infinita para cargar más reportes.
 * - Panel para resolver solicitudes de revisión.
 * - Drawer para detalles de reporte y modal de chat.
 */
function PaginaReportes() {
    // Estados para datos principales
    const [reports, setReports] = useState([]); // Lista de reportes cargados
    const [categories, setCategories] = useState([]); // Lista de categorías disponibles
    const [reviewRequests, setReviewRequests] = useState([]); // Solicitudes de revisión pendientes

    // Estados para filtros y búsqueda
    const [filters, setFilters] = useState({ search: '', status: '', categoryId: '', sortBy: 'newest', distrito: '', planType: '', prioridad: '' }); // Filtros aplicados
    const [showOnlySuggested, setShowOnlySuggested] = useState(false); // Flag para mostrar solo reportes sugeridos

    // Estados para paginación y carga
    const [page, setPage] = useState(1); // Página actual para paginación
    const [loading, setLoading] = useState(true); // Indicador de carga único
    const [hasMore, setHasMore] = useState(true); // Indica si hay más páginas disponibles

    // Estados para modales/drawers
    const [drawerOpen, setDrawerOpen] = useState(false); // Estado del drawer de detalles
    const [selectedReport, setSelectedReport] = useState(null); // Reporte seleccionado para detalles/chat
    const [chatOpen, setChatOpen] = useState(false); // Estado del modal de chat

    // Búsqueda debounced para optimizar llamadas al servidor
    const debouncedSearch = useDebounce(filters.search, 500);
    const isInitialMount = useRef(true); // Ref para controlar si es el montaje inicial

    /**
     * useEffect para cargar categorías una sola vez al montar el componente.
     * No depende de nada, se ejecuta solo una vez.
     */
    useEffect(() => {
        adminService.getAllCategories()
          .then(setCategories)
          .catch(err => console.error("Error fetching categories:", err));
    }, []);

    /**
     * Función centralizada para cargar reportes y solicitudes de revisión.
     * Maneja paginación y reseteo de lista si es un nuevo filtro.
     * 
     * @param {boolean} isNewFilter - Si es true, resetea página y lista; si false, agrega a la existente.
     */
    const fetchReportsAndRequests = useCallback((isNewFilter = false) => {
        const pageToFetch = isNewFilter ? 1 : page; // Usa página 1 si es filtro nuevo, sino la actual
        const currentFilters = {
            search: debouncedSearch,
            status: filters.status,
            categoryId: showOnlySuggested ? '' : filters.categoryId, // Ignora categoría si solo sugeridos
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
            setPage(1); // Resetea página para filtros nuevos
            setReports([]); // Limpia lista visualmente
            setHasMore(true); // Asume que habrá resultados
        }

        // Carga reportes y solicitudes en paralelo
        Promise.all([
            adminService.getAllAdminReports(currentFilters),
            adminService.getReviewRequests()
        ]).then(([newReports, requests]) => {
            console.log("Received new reports:", newReports.length, "Has More:", newReports.length === 10); // Log
            setReports(prev => isNewFilter ? newReports : [...prev, ...newReports]); // Agrega o resetea lista
            setReviewRequests(requests);
            setHasMore(newReports.length === 10); // Verifica si hay más (asumiendo PAGE_SIZE=10)
            // El estado 'page' se actualiza en handleLoadMore antes si no es filtro nuevo
        }).catch(error => {
            console.error("Error fetching data:", error);
            setHasMore(false);
        }).finally(() => {
            setLoading(false);
            // Marca que el montaje inicial terminó después de la primera carga
            if (isInitialMount.current) {
                isInitialMount.current = false;
            }
        });
     
    }, [page, debouncedSearch, filters, showOnlySuggested]); // Dependencias para optimización

    /**
     * useEffect para carga inicial y cambios en filtros.
     * Se ejecuta cuando cambian los filtros, reseteando a página 1.
     */
    useEffect(() => {
        // Llama siempre que cambien los filtros, reseteando a página 1
        console.log("Filter change detected, fetching page 1"); // Log
        fetchReportsAndRequests(true);
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [debouncedSearch, filters.status, filters.categoryId, filters.sortBy, showOnlySuggested, filters.distrito, filters.planType, filters.prioridad]); // Dependencias de filtros

     /**
      * useEffect para paginación (cargar más reportes).
      * Solo se ejecuta cuando cambia 'page', y no en montaje inicial o página 1.
      */
      useEffect(() => {
          // No hacer nada en montaje inicial o si es página 1 (ya cargada por el effect de filtros)
          if (isInitialMount.current || page === 1) return;

          console.log(`Page changed to ${page}, fetching more...`); // Log
          // Cargar la página actual (incrementada en handleLoadMore)
          fetchReportsAndRequests(false); // 'false' indica que no es filtro nuevo

      // eslint-disable-next-line react-hooks/exhaustive-deps
      }, [page]); // Solo depende de 'page'

    // --- Handlers para filtros y acciones ---
    /**
     * Handler para cambios en filtros individuales.
     * @param {string} name - Nombre del filtro (e.g., 'status').
     * @param {any} value - Nuevo valor del filtro.
     */
    const handleFilterChange = (name, value) => { setFilters(prev => ({ ...prev, [name]: value })); };

    /**
     * Handler para cambio de ordenamiento.
     * @param {string} sortByValue - Valor de orden (e.g., 'newest').
     */
    const handleSortChange = (sortByValue) => { setFilters(prev => ({ ...prev, sortBy: sortByValue })); };

    /**
     * Handler para toggle de "solo sugeridos".
     * @param {boolean} isChecked - Si está activado.
     */
    const handleToggleSuggested = (isChecked) => { setShowOnlySuggested(isChecked); };

    /**
     * Handler para limpiar todos los filtros.
     */
    const handleClearFilters = () => {
         setFilters({ search: '', status: '', categoryId: '', sortBy: 'newest', distrito: '', planType: '', prioridad: '' });
         setShowOnlySuggested(false);
    };

    /**
     * Handler para cargar más reportes (paginación).
     * Incrementa la página, lo que dispara el useEffect [page].
     */
    const handleLoadMore = () => {
        if (!loading && hasMore) {
            console.log("Load More clicked, incrementing page..."); // Log
            // Actualiza el estado de la página, disparando el useEffect [page]
            setPage(prevPage => prevPage + 1);
        }
    };

    // --- Handlers para drawer, chat y acciones (sin cambios significativos) ---
    /**
     * Handler para abrir el drawer de detalles.
     * @param {Object} report - Reporte seleccionado.
     */
    const handleOpenDrawer = (report) => { setSelectedReport(report); setDrawerOpen(true); };

    /**
     * Handler para cerrar el drawer de detalles.
     * Limpia el reporte seleccionado con delay para animación.
     */
    const handleCloseDrawer = () => { setDrawerOpen(false); setTimeout(() => setSelectedReport(null), 300); };

    /**
     * Handler para abrir el modal de chat.
     * Cierra el drawer y abre el chat.
     * @param {Object} report - Reporte para chatear.
     */
    const handleOpenChat = (report) => { setSelectedReport(report); setChatOpen(true); setDrawerOpen(false);};

    /**
     * Handler para cuando se completa una acción en el drawer.
     * Cierra el drawer y recarga datos.
     */
    const handleActionCompleted = () => { handleCloseDrawer(); fetchReportsAndRequests(true); };

    /**
     * Handler para resolver una solicitud de revisión.
     * @param {number} id - ID de la solicitud.
     * @param {string} action - Acción a realizar (e.g., 'approve').
     */
    const handleResolveRequest = (id, action) => { adminService.resolveReviewRequest(id, action).then(() => fetchReportsAndRequests(true)).catch(err => alert(err.response?.data?.message || 'Error.')); };

    // --- Render Principal ---
    return (
        <Box sx={{ p: { xs: 1, sm: 2, md: 3 } }}>
            {/* Título de la página */}
            <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
                Gestión General de Reportes
            </Typography>

            {/* Panel para solicitudes de revisión */}
            <PanelSolicitudesRevision
                reviewRequests={reviewRequests}
                onResolveRequest={handleResolveRequest}
            />

            {/* Componente de filtros */}
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
                loadingMore={loading && page > 0} // Indicador correcto para el botón de cargar más
            />

            {/* Carga inicial o lista de reportes */}
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

            {/* Modales y drawers */}
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
