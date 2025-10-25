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

/**
 * Componente PaginaHistorialNotificaciones: Página para visualizar y gestionar el historial de notificaciones enviadas.
 * Incluye filtros por usuario, rango de fechas y búsqueda, paginación infinita,
 * conteo de notificaciones duplicadas, y un panel lateral con detalles del usuario seleccionado.
 * 
 * Funcionalidades principales:
 * - Carga paginada del historial con filtros aplicados.
 * - Búsqueda debounced para evitar llamadas excesivas.
 * - Selección de usuario para ver detalles y filtrar.
 * - Acciones como reenviar o eliminar notificaciones.
 * - Indicadores de carga y mensajes informativos.
 */
function PaginaHistorialNotificaciones() {
  // Estados para el historial y paginación
  const [history, setHistory] = useState([]); // Lista de notificaciones del historial
  const [page, setPage] = useState(1); // Página actual para paginación
  const [hasMore, setHasMore] = useState(false); // Indica si hay más páginas disponibles
  const [loading, setLoading] = useState(false); // Indicador de carga para el historial
  const [loadingUserDetails, setLoadingUserDetails] = useState(false); // Indicador de carga para detalles de usuario

  // Estados para filtros y búsqueda
  const [searchFilter, setSearchFilter] = useState(''); // Texto de búsqueda
  const debouncedSearch = useDebounce(searchFilter, 1000); // Búsqueda debounced para optimización

  // --- Estado para los filtros ---
  const [selectedUserId, setSelectedUserId] = useState(null); // ID del usuario seleccionado para filtrar
  // --- FIX: Default Date Range (Last 30 days) ---
  const [dateRange, setDateRange] = useState({
    startDate: dayjs().subtract(30, 'day').format('YYYY-MM-DD'), // Fecha de inicio por defecto (30 días atrás)
    endDate: dayjs().format('YYYY-MM-DD'), // Fecha de fin por defecto (hoy)
  });
  // --- FIX: Initialize activeFiltersApplied based on default dates ---
  const [activeFiltersApplied, setActiveFiltersApplied] = useState(true); // True porque las fechas están activas por defecto
  const [selectedUserDetails, setSelectedUserDetails] = useState(null); // Detalles del usuario seleccionado

  /**
   * Función para cargar el historial de notificaciones desde el backend.
   * Maneja paginación y reseteo de lista si es un nuevo conjunto de filtros.
   * 
   * @param {number} currentPage - Página a cargar.
   * @param {Object} filters - Filtros aplicados (search, userId, startDate, endDate).
   * @param {boolean} isNewFilterSet - Si es true, resetea la lista y página a 1.
   */
  const fetchHistory = useCallback(async (currentPage, filters, isNewFilterSet) => {
    setLoading(true);
    setActiveFiltersApplied(true); // Marca que hay filtros activos
    const combinedFilters = {
      search: filters.search || '',
      userId: filters.userId || null,
      startDate: filters.startDate || null,
      endDate: filters.endDate || null,
      page: currentPage,
    };

    try {
      const newHistory = await adminService.getNotificationHistory(combinedFilters);
      const PAGE_SIZE = 20; // Tamaño de página fijo
      setHistory(isNewFilterSet ? newHistory : prev => [...prev, ...newHistory]); // Agrega o resetea la lista
      setHasMore(newHistory.length === PAGE_SIZE); // Verifica si hay más páginas
      if (isNewFilterSet) setPage(1); // Resetea página si es nuevo filtro
    } catch (error) {
      console.error("Error fetching notification history:", error);
      setHistory([]);
      setHasMore(false);
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * useEffect para disparar la carga del historial cuando cambian los filtros.
   * Solo carga si hay filtros activos (usuario, fechas o búsqueda).
   * Si no hay filtros, limpia el estado.
   */
  useEffect(() => {
    // Determina si algún filtro está activo (además de defaults vacíos)
    const isUserSelected = !!selectedUserId;
    const areDatesSelected = !!(dateRange.startDate || dateRange.endDate);
    const isSearchActive = !!debouncedSearch;

    if (isUserSelected || areDatesSelected || isSearchActive) {
      // Carga página 1 cuando cambia un filtro
      fetchHistory(1, {
        search: debouncedSearch,
        userId: selectedUserId,
        startDate: dateRange.startDate,
        endDate: dateRange.endDate
      }, true); // `true` para nuevo conjunto de filtros
    } else {
      // Si NO hay filtros activos, limpia todo
      setActiveFiltersApplied(false);
      setHistory([]);
      setPage(1);
      setHasMore(false);
      setSelectedUserDetails(null); // También limpia detalles de usuario
    }
  }, [selectedUserId, dateRange, debouncedSearch, fetchHistory]);

  /**
   * Handler para cargar más notificaciones (paginación infinita).
   * Solo carga si hay más páginas y no está cargando.
   */
  const handleLoadMore = () => {
    if (hasMore && !loading && activeFiltersApplied) {
      const nextPage = page + 1;
      setPage(nextPage);
      fetchHistory(nextPage, {
        search: debouncedSearch,
        userId: selectedUserId,
        startDate: dateRange.startDate,
        endDate: dateRange.endDate
      }, false); // `false` para agregar a la lista existente
    }
  };

  /**
   * useEffect para cargar detalles del usuario cuando se selecciona uno.
   * Limpia detalles si no hay usuario seleccionado.
   */
  useEffect(() => {
    if (selectedUserId) {
      setLoadingUserDetails(true);
      setSelectedUserDetails(null); // Limpia detalles previos
      adminService.getUserSummary(selectedUserId)
        .then(data => setSelectedUserDetails(data))
        .catch(err => {
            console.error("Error fetching user summary:", err);
            setSelectedUserDetails(null); // Limpia en caso de error
        })
        .finally(() => setLoadingUserDetails(false));
    } else {
      setSelectedUserDetails(null); // Limpia si no hay usuario
    }
  }, [selectedUserId]);

  // --- Handlers de filtros ---
  /**
   * Handler para selección de usuario.
   * Evita fetches innecesarios si el ID no cambió.
   * 
   * @param {number|null} userId - ID del usuario seleccionado.
   */
  const handleUserSelection = (userId) => {
    // Verifica si el ID cambió para evitar fetches innecesarios
    if(userId !== selectedUserId) {
        setSelectedUserId(userId);
    }
  };

  /**
   * Handler para cambio en el rango de fechas.
   * @param {Object} newDateRange - Nuevo rango {startDate, endDate}.
   */
  const handleDateFilterChange = (newDateRange) => {
    setDateRange(newDateRange);
  };

   // --- Calculate Duplicate Counts (Frontend) ---
   /**
    * Cálculo de conteos de notificaciones duplicadas basado en título y cuerpo.
    * Se recalcula solo cuando cambia el historial.
    */
   const notificationCounts = useMemo(() => {
    const counts = {};
    history.forEach(notif => {
        // Usa combinación de título y cuerpo como clave
        const key = `${notif.titulo}|${notif.cuerpo}`;
        counts[key] = (counts[key] || 0) + 1;
    });
    return counts;
   }, [history]); // Recalcula solo cuando cambia history

  // --- Handlers para acciones (Reenviar/Eliminar - No changes needed) ---
  /**
   * Handler para eliminar una notificación.
   * Recarga el historial después de eliminar.
   * 
   * @param {number} id - ID de la notificación a eliminar.
   */
  const handleDelete = (id) => {
    adminService.deleteNotification(id).then(() => {
      fetchHistory(1, { /* current filters */ }, true); // Recarga con filtros actuales
    }).catch(err => console.error("Error deleting notification:", err));
  };

  /**
   * Handler para reenviar una notificación.
   * Muestra alerta de éxito o error.
   * 
   * @param {Object} notif - Objeto de la notificación a reenviar.
   */
  const handleResend = (notif) => {
    adminService.sendNotification([notif.id_usuario_receptor], notif.titulo, notif.cuerpo)
      .then(() => alert('Notificación reenviada.'))
      .catch((err) => {
        console.error("Error resending notification:", err);
        alert('Error al reenviar la notificación.');
      });
  };

  // --- Render Principal ---
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
                disabled={loading || loadingUserDetails} // Deshabilita durante carga
                value={selectedUserId} // Pasa ID actual para sincronización interna
              />
              <FiltrosNotificaciones
                onFiltersChange={handleDateFilterChange}
                disabled={loading || loadingUserDetails} // Deshabilita durante carga
                // Pasa fechas actuales si se necesitan para inicializar DatePicker (manejado internamente)
              />
              <TextField
                fullWidth size="small"
                label="Buscar en título, mensaje..."
                value={searchFilter}
                onChange={(e) => setSearchFilter(e.target.value)}
                disabled={loading || loadingUserDetails} // Deshabilita durante carga
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
              loading={loading && page > 1} // Muestra carga solo en páginas adicionales
              hasMore={hasMore}
              onLoadMore={handleLoadMore}
              onResend={handleResend}
              onDelete={handleDelete}
              // Pasa conteos de duplicados
              notificationCounts={notificationCounts}
            />
          )}
        </Grid>

        {/* --- Columna Derecha: Detalles del Usuario --- */}
        <Grid item xs={12} md={4}>
           <Box sx={{ position: 'sticky', top: '80px' }}> {/* Hace el panel sticky */}
                <DetallesUsuarioNotificaciones
                    userDetails={selectedUserDetails}
                    loading={loadingUserDetails}
                    filteredCount={activeFiltersApplied ? history.length : 0} // Pasa conteo filtrado
                />
            </Box>
        </Grid>

      </Grid> {/* End Layout Grid */}
    </Box>
  );
}

export default PaginaHistorialNotificaciones;
