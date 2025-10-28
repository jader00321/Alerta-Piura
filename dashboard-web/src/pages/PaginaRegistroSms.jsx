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

/**
 * @file src/pages/PaginaRegistroSms.jsx
 * @component PaginaRegistroSms
 *
 * @description
 * Renderiza la página principal del "Registro de SMS Simulados".
 *
 * Este componente actúa como el orquestador principal (componente "inteligente" o contenedor)
 * para la visualización del historial de SMS.
 *
 * Responsabilidades:
 * 1. **Estado de Filtros:** Mantiene un estado unificado (`filters`) para
 * búsqueda, ID de usuario y rango de fechas.
 * 2. **Filtros por Defecto:** Inicializa los filtros para mostrar automáticamente
 * los últimos 7 días al cargar la página.
 * 3. **Debouncing:** Utiliza el hook `useDebounce` sobre el término de búsqueda
 * (`filters.search`) para optimizar las llamadas a la API y evitar
 * recargas en cada pulsación de tecla.
 * 4. **Carga de Datos:** Contiene la lógica de carga (`fetchLogs`) que
 * contacta a `adminService.getSmsLog`, formateando las fechas con `dayjs`.
 * 5. **Paginación:** Implementa la lógica para cargar más resultados (paginación)
 * a través de un botón "Cargar Más", llevando la cuenta de `page` y `hasMore`.
 * 6. **Orquestación de UI:** Pasa los datos, estados y callbacks a los componentes
 * hijos `FiltrosSmsLog` (control) y `ListaSmsLog` (presentación).
 *
 * El flujo de carga se maneja con `useEffect`:
 * - Un `useEffect` se dispara con los filtros (debouncedSearch, userId, fechas)
 * para recargar la lista desde la página 1.
 * - Un `useEffect` separado se dispara solo con `page` para cargar
 * páginas adicionales (paginación).
 * - Un `useRef` (`isInitialMount`) se usa para gestionar la carga inicial.
 *
 * @returns {JSX.Element} La página de registro de SMS completa.
 */
function PaginaRegistroSms() {
  const [logs, setLogs] = useState([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const [loading, setLoading] = useState(false);
  
  // --- MEJORA: Estado de Filtros Unificado con Valor por Defecto ---
  const [filters, setFilters] = useState(() => {
      // Valor por defecto: últimos 7 días
      const initialEndDate = endOfDay(new Date());
      const initialStartDate = startOfDay(subDays(initialEndDate, 6)); 
      return {
          search: '',
          userId: null,
          startDate: initialStartDate,
          endDate: initialEndDate,
      };
  });
  
  const debouncedSearch = useDebounce(filters.search, 500);
  const isInitialMount = useRef(true); // Ref para controlar la carga inicial

  /**
   * Carga los logs desde la API.
   * Maneja tanto la carga inicial/filtrado (reset) como la paginación (append).
   * @param {boolean} [isNewFilterSet=false] - Si es true, resetea la lista y la página a 1.
   */
  const fetchLogs = useCallback((isNewFilterSet = false) => {
      const pageToFetch = isNewFilterSet ? 1 : page;
      
      // Prepara los filtros para la API (formatea fechas)
      const apiFilters = {
          search: debouncedSearch,
          page: pageToFetch,
          userId: filters.userId,
          startDate: filters.startDate ? dayjs(filters.startDate).format('YYYY-MM-DD') : null,
          endDate: filters.endDate ? dayjs(filters.endDate).format('YYYY-MM-DD') : null,
      };

      console.log("Fetching SMS logs with filters:", apiFilters);
      setLoading(true);
      
      // Si es un nuevo filtro, resetea el estado
      if (isNewFilterSet) {
          setPage(1);
          setLogs([]);
          setHasMore(true);
      }

      adminService.getSmsLog(apiFilters)
          .then(newLogs => {
              // Reemplaza o añade logs según el tipo de carga
              setLogs(prev => isNewFilterSet ? newLogs : [...prev, ...newLogs]);
              // Asume que si devuelve menos de 20, no hay más. (Debería ser 20 o el límite de pág)
              setHasMore(newLogs.length === 20);
          })
          .catch(console.error)
          .finally(() => setLoading(false));
  }, [page, debouncedSearch, filters.userId, filters.startDate, filters.endDate]); // Dependencias del useCallback

  // --- Effect para Carga Inicial y Cambio de Filtros ---
  useEffect(() => {
    // En el montaje inicial, isInitialMount.current es true
    if (isInitialMount.current) {
        isInitialMount.current = false;
        fetchLogs(true); // Llama a la carga inicial (con filtros por defecto)
        return; // Evita la doble llamada
    }
    
    // Si no es el montaje inicial, cualquier cambio en las dependencias
    // es un cambio de filtro, así que recarga desde pág 1.
    fetchLogs(true);
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debouncedSearch, filters.userId, filters.startDate, filters.endDate]); // Dependencias: filtros (search debounced)

  // --- Effect para Paginación ---
  useEffect(() => {
    // No ejecutar en montaje inicial O si la página se reseteó a 1
    if (isInitialMount.current || page === 1) return;
    
    fetchLogs(false); // Carga la siguiente página (sin resetear)
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [page]); // Dependencia: solo la página


  /**
   * Manejador para el botón "Cargar Más".
   * Incrementa el estado `page`, lo que dispara el useEffect de paginación.
   */
  const handleLoadMore = () => {
    if (hasMore && !loading) {
      setPage(prev => prev + 1); // Dispara el useEffect[page]
    }
  };

  /**
   * Callback pasado a FiltrosSmsLog.
   * Actualiza el estado de filtros unificado.
   * @param {object} newFilters - El nuevo objeto de filtros completo.
   */
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