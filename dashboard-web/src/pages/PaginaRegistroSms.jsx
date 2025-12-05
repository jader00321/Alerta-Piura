import React, { useEffect, useState, useCallback } from 'react';
import { Box, Typography, Alert, AlertTitle, Snackbar } from '@mui/material';
import { Sms as SmsIcon } from '@mui/icons-material';
import adminService from '../services/adminService';
import { useDebounce } from '../hooks/useDebounce';
import dayjs from 'dayjs';
import { subDays } from 'date-fns';

// Componentes
import FiltrosSmsLog from '../components/Sms/FiltrosSmsLog';
import ListaSmsLog from '../components/Sms/ListaSmsLog';
import ModalConfirmacion from '../components/Comunes/ModalConfirmacion'; // Importar Modal

function PaginaRegistroSms() {
  // Estados de datos
  const [logs, setLogs] = useState([]);
  const [filters, setFilters] = useState({
    search: '',
    startDate: subDays(new Date(), 6),
    endDate: new Date(),
    userId: null
  });
  
  // Estados UI
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const [feedback, setFeedback] = useState({ open: false, message: '', type: 'success' });

  // Estado para eliminar
  const [deleteModal, setDeleteModal] = useState({ open: false, id: null });

  const debouncedSearch = useDebounce(filters.search, 500);

  // Carga de datos
  const fetchLogs = useCallback(async (pageNum, isRefresh = false) => {
    if (isRefresh) setLoading(true);
    
    try {
      const params = {
        page: pageNum,
        search: debouncedSearch,
        userId: filters.userId,
        startDate: filters.startDate ? dayjs(filters.startDate).format('YYYY-MM-DD') : null,
        endDate: filters.endDate ? dayjs(filters.endDate).format('YYYY-MM-DD') : null,
      };

      const data = await adminService.getSimulatedSmsLog(params);

      if (isRefresh) {
        setLogs(data);
      } else {
        setLogs(prev => [...prev, ...data]);
      }
      setHasMore(data.length === 20); 
    } catch (error) {
      console.error("Error cargando SMS logs:", error);
    } finally {
      setLoading(false);
    }
  }, [debouncedSearch, filters]);

  useEffect(() => {
    setPage(1);
    fetchLogs(1, true);
  }, [fetchLogs]);

  const handleLoadMore = () => {
    if (!loading && hasMore) {
      const nextPage = page + 1;
      setPage(nextPage);
      fetchLogs(nextPage, false);
    }
  };

  const handleFilterChange = (newFilters) => {
      setFilters(newFilters);
  };

  // --- LÓGICA DE ELIMINACIÓN ---
  const handleDeleteClick = (id) => {
      setDeleteModal({ open: true, id });
  };

  const confirmDelete = async () => {
      try {
          await adminService.deleteSmsLog(deleteModal.id);
          setFeedback({ open: true, message: 'Registro eliminado correctamente', type: 'success' });
          // Recargar lista (opción rápida: filtrar localmente)
          setLogs(prev => prev.filter(l => l.id !== deleteModal.id));
      // eslint-disable-next-line no-unused-vars
      } catch (error) {
          setFeedback({ open: true, message: 'Error al eliminar registro', type: 'error' });
      } finally {
          setDeleteModal({ open: false, id: null });
      }
  };

  return (
    <Box sx={{ p: { xs: 1, sm: 2, md: 3 } }}>
      <Box sx={{ mb: 3 }}>
        <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
          Registro de SMS Simulados
        </Typography>
         <Alert severity="info" icon={<SmsIcon />} variant="outlined">
           <AlertTitle>Historial de Envíos</AlertTitle>
           Aquí puedes auditar y limpiar el historial de mensajes de emergencia.
         </Alert>
      </Box>

      <FiltrosSmsLog
        filters={filters}
        onFilterChange={handleFilterChange}
        loading={loading && page === 1}
      />

      <ListaSmsLog
        logs={logs}
        loading={loading && page > 1}
        hasMore={hasMore}
        onLoadMore={handleLoadMore}
        onDelete={handleDeleteClick} // Pasar función
      />

      {/* Modal de Confirmación */}
      <ModalConfirmacion 
          open={deleteModal.open}
          onClose={() => setDeleteModal({ open: false, id: null })}
          title="Eliminar Registro"
          content="¿Estás seguro de eliminar este registro de SMS? Esta acción es irreversible."
          confirmText="Eliminar"
          confirmColor="error"
          onConfirm={confirmDelete}
      />

      {/* Snackbar Feedback */}
      <Snackbar
        open={feedback.open}
        autoHideDuration={4000}
        onClose={() => setFeedback(prev => ({ ...prev, open: false }))}
        message={feedback.message}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      />
    </Box>
  );
}

export default PaginaRegistroSms;