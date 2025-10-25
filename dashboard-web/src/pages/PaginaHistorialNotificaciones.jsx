// src/pages/PaginaHistorialNotificaciones.jsx
import React, { useEffect, useState, useCallback, useMemo } from 'react';
import {
  Box, Paper, Typography, TextField, Grid, // Grid added
  CircularProgress, InputAdornment, Alert, Stack
} from '@mui/material';
import { Search as SearchIcon, FilterList as FilterListIcon } from '@mui/icons-material';
import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce';
import dayjs from 'dayjs'; // Import dayjs for default dates

// Importar los nuevos componentes
import ListaHistorialNotificaciones from '../components/Notificaciones/ListaHistorialNotificaciones';
import SelectorUsuarioNotificaciones from '../components/Notificaciones/SelectorUsuarioNotificaciones';
import FiltrosNotificaciones from '../components/Notificaciones/FiltrosNotificaciones';
import DetallesUsuarioNotificaciones from '../components/Notificaciones/DetallesUsuarioNotificaciones'; // <-- Import User Details panel

function PaginaHistorialNotificaciones() {
  const [history, setHistory] = useState([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(false); // Default to false until data is fetched
  const [loading, setLoading] = useState(false);
  const [loadingUserDetails, setLoadingUserDetails] = useState(false); // Separate loading for user details
  const [searchFilter, setSearchFilter] = useState('');
  const debouncedSearch = useDebounce(searchFilter, 1000);

  // --- Estado para los filtros ---
  const [selectedUserId, setSelectedUserId] = useState(null);
  // --- FIX: Default Date Range (Last 30 days) ---
  const [dateRange, setDateRange] = useState({
    startDate: dayjs().subtract(30, 'day').format('YYYY-MM-DD'),
    endDate: dayjs().format('YYYY-MM-DD'),
  });
  // --- FIX: Initialize activeFiltersApplied based on default dates ---
  const [activeFiltersApplied, setActiveFiltersApplied] = useState(true); // True because dates are set by default
  const [selectedUserDetails, setSelectedUserDetails] = useState(null); // State for user summary

  // --- LÓGICA DE CARGA ---
  const fetchHistory = useCallback(async (currentPage, filters, isNewFilterSet) => {
    setLoading(true);
    setActiveFiltersApplied(true); // Mark filters as active when fetching
    const combinedFilters = {
      search: filters.search || '',
      userId: filters.userId || null,
      startDate: filters.startDate || null,
      endDate: filters.endDate || null,
      page: currentPage,
    };

    try {
      const newHistory = await adminService.getNotificationHistory(combinedFilters);
      const PAGE_SIZE = 20;
      setHistory(isNewFilterSet ? newHistory : prev => [...prev, ...newHistory]);
      setHasMore(newHistory.length === PAGE_SIZE);
      if (isNewFilterSet) setPage(1);
    } catch (error) {
      console.error("Error fetching notification history:", error);
      setHistory([]);
      setHasMore(false);
    } finally {
      setLoading(false);
    }
  }, []);

  // --- EFECTO PARA DISPARAR LA BÚSQUEDA/FILTRADO ---
  useEffect(() => {
    // Determine if any filter is actually active besides potentially empty defaults
    const isUserSelected = !!selectedUserId;
    const areDatesSelected = !!(dateRange.startDate || dateRange.endDate);
    const isSearchActive = !!debouncedSearch;

    if (isUserSelected || areDatesSelected || isSearchActive) {
      // Fetch page 1 whenever a filter changes
      fetchHistory(1, {
        search: debouncedSearch,
        userId: selectedUserId,
        startDate: dateRange.startDate,
        endDate: dateRange.endDate
      }, true); // `true` for new filter set
    } else {
      // If NO filters are active, clear everything
      setActiveFiltersApplied(false);
      setHistory([]);
      setPage(1);
      setHasMore(false);
      setSelectedUserDetails(null); // Also clear user details
    }
  }, [selectedUserId, dateRange, debouncedSearch, fetchHistory]);

  // --- Handler para cargar más ---
  const handleLoadMore = () => {
    if (hasMore && !loading && activeFiltersApplied) {
      const nextPage = page + 1;
      setPage(nextPage);
      fetchHistory(nextPage, {
        search: debouncedSearch,
        userId: selectedUserId,
        startDate: dateRange.startDate,
        endDate: dateRange.endDate
      }, false);
    }
  };

  // --- Fetch User Summary when user is selected ---
  useEffect(() => {
    if (selectedUserId) {
      setLoadingUserDetails(true);
      setSelectedUserDetails(null); // Clear previous details
      adminService.getUserSummary(selectedUserId)
        .then(data => setSelectedUserDetails(data))
        .catch(err => {
            console.error("Error fetching user summary:", err);
            setSelectedUserDetails(null); // Clear on error
        })
        .finally(() => setLoadingUserDetails(false));
    } else {
      setSelectedUserDetails(null); // Clear details if user is deselected
    }
  }, [selectedUserId]);


  // --- Handlers de filtros ---
  const handleUserSelection = (userId) => {
    // Check if the user ID actually changed to prevent unnecessary fetches
    if(userId !== selectedUserId) {
        setSelectedUserId(userId);
    }
  };

  const handleDateFilterChange = (newDateRange) => {
    setDateRange(newDateRange);
  };

   // --- Calculate Duplicate Counts (Frontend) ---
   const notificationCounts = useMemo(() => {
    const counts = {};
    history.forEach(notif => {
        // Use a combination of title and body as the key
        const key = `${notif.titulo}|${notif.cuerpo}`;
        counts[key] = (counts[key] || 0) + 1;
    });
    return counts;
   }, [history]); // Recalculate only when history changes


  // --- Handlers para acciones (Reenviar/Eliminar - No changes needed) ---
  const handleDelete = (id) => {
    adminService.deleteNotification(id).then(() => {
      fetchHistory(1, { /* current filters */ }, true);
    }).catch(err => console.error("Error deleting notification:", err));
  };

  const handleResend = (notif) => {
    adminService.sendNotification([notif.id_usuario_receptor], notif.titulo, notif.cuerpo)
      .then(() => alert('Notificación reenviada.'))
      .catch((err) => {
        console.error("Error resending notification:", err);
        alert('Error al reenviar la notificación.');
      });
  };

  return (
    <Box sx={{ p: 3 }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Historial de Notificaciones Enviadas
      </Typography>

      {/* --- LAYOUT GRID --- */}
      <Grid container spacing={3}>

        {/* --- Columna Izquierda: Filtros y Lista --- */}
        <Grid item xs={12} md={8}>
          {/* --- SECCIÓN DE FILTROS --- */}
          <Paper sx={{ p: 2, mb: 3 }} variant="outlined">
            <Stack spacing={2}>
              <SelectorUsuarioNotificaciones
                onUserSelected={handleUserSelection}
                disabled={loading || loadingUserDetails}
                value={selectedUserId} // Pass current ID for potential internal state sync
              />
              <FiltrosNotificaciones
                onFiltersChange={handleDateFilterChange}
                disabled={loading || loadingUserDetails}
                // Pass current dates if needed for DatePicker initial values (handled internally now)
              />
              <TextField
                fullWidth size="small"
                label="Buscar en título, mensaje..."
                value={searchFilter}
                onChange={(e) => setSearchFilter(e.target.value)}
                disabled={loading || loadingUserDetails}
                InputProps={{ startAdornment: <InputAdornment position="start"><SearchIcon /></InputAdornment> }}
              />
            </Stack>
          </Paper>

          {/* --- SECCIÓN DE RESULTADOS --- */}
          {!activeFiltersApplied && !loading && (
            <Alert severity="info" icon={<FilterListIcon />}>
              Selecciona un usuario o aplica filtros para ver el historial. Por defecto se muestran los últimos 30 días.
            </Alert>
          )}
          {loading && page === 1 && activeFiltersApplied && (
            <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}><CircularProgress /></Box>
          )}
          {activeFiltersApplied && (!loading || page > 1) && (
            <ListaHistorialNotificaciones
              history={history}
              loading={loading && page > 1}
              hasMore={hasMore}
              onLoadMore={handleLoadMore}
              onResend={handleResend}
              onDelete={handleDelete}
              // Pass counts down
              notificationCounts={notificationCounts}
            />
          )}
        </Grid>

        {/* --- Columna Derecha: Detalles del Usuario --- */}
        <Grid item xs={12} md={4}>
           <Box sx={{ position: 'sticky', top: '80px' }}> {/* Make details sticky */}
                <DetallesUsuarioNotificaciones
                    userDetails={selectedUserDetails}
                    loading={loadingUserDetails}
                    filteredCount={activeFiltersApplied ? history.length : undefined} // Pass filtered count
                />
            </Box>
        </Grid>

      </Grid> {/* End Layout Grid */}
    </Box>
  );
}

export default PaginaHistorialNotificaciones;