// src/pages/PaginaRegistroSms.jsx
import React, { useEffect, useState, useCallback, useRef } from 'react';
import { Box, Typography, CircularProgress, Alert, AlertTitle } from '@mui/material';
import { Sms as SmsIcon } from '@mui/icons-material';
import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce';
import dayjs from 'dayjs'; // Importar dayjs
import { startOfDay, endOfDay, subDays } from 'date-fns'; // Importar date-fns

// --- Importar Componentes ---
import FiltrosSmsLog from '../components/Sms/FiltrosSmsLog';
import ListaSmsLog from '../components/Sms/ListaSmsLog';

function PaginaRegistroSms() {
  const [logs, setLogs] = useState([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const [loading, setLoading] = useState(false);
  
  // --- MEJORA: Estado de Filtros Unificado con Valor por Defecto ---
  const [filters, setFilters] = useState(() => {
      const initialEndDate = endOfDay(new Date());
      const initialStartDate = startOfDay(subDays(initialEndDate, 6)); // Últimos 7 días
      return {
          search: '',
          userId: null,
          startDate: initialStartDate,
          endDate: initialEndDate,
      };
  });
  
  const debouncedSearch = useDebounce(filters.search, 500);
  const isInitialMount = useRef(true);

  // --- Lógica de Carga (Corregida) ---
  const fetchLogs = useCallback((isNewFilterSet = false) => {
      const pageToFetch = isNewFilterSet ? 1 : page;
      
      const apiFilters = {
          search: debouncedSearch,
          page: pageToFetch,
          userId: filters.userId,
          startDate: filters.startDate ? dayjs(filters.startDate).format('YYYY-MM-DD') : null,
          endDate: filters.endDate ? dayjs(filters.endDate).format('YYYY-MM-DD') : null,
      };

      console.log("Fetching SMS logs with filters:", apiFilters);
      setLoading(true);
      if (isNewFilterSet) {
          setPage(1);
          setLogs([]);
          setHasMore(true);
      }

      adminService.getSmsLog(apiFilters)
          .then(newLogs => {
              setLogs(prev => isNewFilterSet ? newLogs : [...prev, ...newLogs]);
              setHasMore(newLogs.length === 20);
          })
          .catch(console.error)
          .finally(() => setLoading(false));
  }, [page, debouncedSearch, filters.userId, filters.startDate, filters.endDate]);

  // --- Effect para Carga Inicial y Cambio de Filtros ---
  useEffect(() => {
    if (isInitialMount.current) {
        isInitialMount.current = false;
        fetchLogs(true); // Llama a la carga inicial (con filtros por defecto)
        return;
    }
    fetchLogs(true); // Recarga desde pág 1 si los filtros cambian
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debouncedSearch, filters.userId, filters.startDate, filters.endDate]);

  // --- Effect para Paginación ---
  useEffect(() => {
    if (isInitialMount.current || page === 1) return;
    fetchLogs(false); // Carga la siguiente página
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page]);


  const handleLoadMore = () => {
    if (hasMore && !loading) {
      setPage(prev => prev + 1); // Dispara el useEffect[page]
    }
  };

  const handleFilterChange = (newFilters) => {
      setFilters(newFilters); // Actualiza el estado de filtros
  };


  return (
    <Box sx={{ p: { xs: 1, sm: 2, md: 3 } }}>
      {/* --- Cabecera --- */}
      <Box sx={{ mb: 3 }}>
        <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
          Registro de SMS Simulados
        </Typography>
         <Alert severity="info" icon={<SmsIcon />} variant="outlined">
            <AlertTitle>Registro de Notificaciones SMS</AlertTitle>
            Esta ventana muestra un historial de todos los mensajes SMS (simulados) enviados por el sistema,
            principalmente para las alertas SOS. Usa los filtros para encontrar mensajes específicos.
         </Alert>
      </Box>

      {/* --- Filtros --- */}
      <FiltrosSmsLog
          filters={filters} // Pasa el estado con valores por defecto
          onFilterChange={handleFilterChange}
          loading={loading && page === 1} // Deshabilita filtros durante carga inicial/filtrado
      />

      {/* --- Lista de Logs --- */}
      <ListaSmsLog
          logs={logs}
          loading={loading} // Pasa el estado de carga general
          hasMore={hasMore}
          onLoadMore={handleLoadMore}
      />
    </Box>
  );
}

export default PaginaRegistroSms;