// src/pages/PaginaAlertasSOS.jsx
import React, { useEffect, useState, useCallback, useRef, useMemo } from 'react';
import { 
  Box, Typography, Grid, CircularProgress, Alert, Divider, Stack, Container, Fade 
} from '@mui/material';
import { 
  Sos as SosIcon, 
  History as HistoryIcon,
  // Map as MapIcon, // (No usado en render, se puede quitar si no se usa)
  // Info as InfoIcon // (No usado en render)
} from '@mui/icons-material';

// Importar date-fns
import { subDays, startOfDay, endOfDay } from 'date-fns';

// Servicios
import socketService from '../services/socketService';
import sosService from '../services/sosService';

// Componentes
import ListaAlertasSOS from '../components/SOS/ListaAlertasSOS';
import DetalleAlertaSeleccionada from '../components/SOS/DetalleAlertaSeleccionada';
import MapaAlertaSOS from '../components/SOS/MapaAlertaSOS';
import PanelAlertaActiva from '../components/SOS/PanelAlertaActiva';
import FiltrosHistorialSOS from '../components/SOS/FiltrosHistorialSOS';

/**
 * PaginaAlertasSOS - Panel de Control de Emergencias
 * Diseño profesional enfocado en la respuesta rápida.
 */
function PaginaAlertasSOS() {
  // --- Estados ---
  const [allAlerts, setAllAlerts] = useState([]);
  const [selectedAlertId, setSelectedAlertId] = useState(null);
  const [locationHistory, setLocationHistory] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [activeSosTimer, setActiveSosTimer] = useState(null);
  const countdownIntervalRef = useRef(null);

  // --- Filtros Iniciales ---
  const [filters, setFilters] = useState(() => {
      const initialEndDate = endOfDay(new Date());
      const initialStartDate = startOfDay(subDays(initialEndDate, 6));
      return {
          userId: null,
          startDate: initialStartDate,
          endDate: initialEndDate,
          estado: '',
          estado_atencion: '',
      };
  });

  // --- Lógica de Selección y Carga ---
  const handleSelectAlert = useCallback(async (alert) => {
    if (!alert || alert.id === selectedAlertId) return;
    setSelectedAlertId(alert.id);

    if (!alert.revisada) {
      sosService.updateStatus(alert.id, { revisada: true }).catch(console.warn);
    }

    if (!locationHistory[alert.id]) {
        try {
            const history = await sosService.getLocationHistory(alert.id);
            const path = history.map(p => [p.lat, p.lon]);
            setLocationHistory(prev => ({ ...prev, [alert.id]: path }));
        // eslint-disable-next-line no-unused-vars
        } catch(e) {
             setLocationHistory(prev => ({ ...prev, [alert.id]: [] }));
        }
    }
  }, [selectedAlertId, locationHistory]);

  const fetchData = useCallback(async () => {
    setLoading(true); setError('');
    try {
      const data = await sosService.getSosDashboardData();
      const sortedData = data ? [...data].sort((a, b) => new Date(b.fecha_inicio) - new Date(a.fecha_inicio)) : [];
      setAllAlerts(sortedData);

      const specificFiltersActive = filters.userId || filters.estado || filters.estado_atencion;
      if (sortedData.length > 0 && selectedAlertId === null && !specificFiltersActive) {
          setTimeout(() => handleSelectAlert(sortedData[0]), 0);
      } else if (sortedData.length === 0) {
          setSelectedAlertId(null);
      }
    } catch (err) {
      console.error("Error fetching SOS:", err);
      setError("No se pudo cargar el panel de emergencias.");
    } finally {
      setLoading(false);
    }
  }, [handleSelectAlert, filters, selectedAlertId]); // Agregado filters a dependencias si es necesario, sino quitar

  // --- Sockets (LÓGICA MEJORADA AQUÍ) ---
  useEffect(() => {
    fetchData();
    
    // Asegurar conexión
    const token = localStorage.getItem('admin_token');
    if(token && !socketService.socket?.connected) {
        socketService.connect(token);
    }

    // 1. Nueva Alerta
    const handleNewAlert = (newAlert) => setAllAlerts(prev => [newAlert, ...prev]);
    
    // 2. Actualización de Ubicación
    const handleLocationUpdate = (update) => {
          if (!update?.alertId || !update?.location) return;
          setLocationHistory(prev => {
              const current = prev[update.alertId] || [];
              const newLoc = [update.location.lat, update.location.lon];
              // Evitar duplicados exactos
              if(current.length > 0 && current[current.length - 1][0] === newLoc[0] && current[current.length - 1][1] === newLoc[1]) return prev;
              return { ...prev, [update.alertId]: [...current, newLoc] };
          });
    };
    
    // 3. Actualización General (ej. cambio de estado manual o automático)
    const handleAlertUpdate = (updatedAlert) => {
          if (!updatedAlert?.id) return;
          setAllAlerts(prev => prev.map(a => a.id === updatedAlert.id ? { ...a, ...updatedAlert } : a));
    };

    // 4. Finalización de Alerta (evento 'sos-alert-ended')
    // Este evento lo emite el backend cuando se acaba el tiempo o el usuario cancela
    const handleAlertEnded = (data) => {
        if (!data?.id) return;
        setAllAlerts(prev => prev.map(a => 
            a.id === data.id 
                ? { ...a, estado: 'finalizado', fecha_fin: new Date().toISOString() } 
                : a
        ));
    };

    // 5. Eliminación de Alerta (evento 'sos-alert-deleted')
    const handleAlertDeleted = (data) => {
         if (!data?.id) return;
         setAllAlerts(prev => prev.filter(a => a.id !== data.id));
         if (selectedAlertId === data.id) setSelectedAlertId(null);
    };

    // Registro de Listeners
    socketService.on('new-sos-alert', handleNewAlert);
    socketService.on('sos-location-update', handleLocationUpdate);
    socketService.on('sos-alert-updated', handleAlertUpdate);
    socketService.on('sos-alert-ended', handleAlertEnded); // <-- MEJORA CRÍTICA
    socketService.on('sos-alert-deleted', handleAlertDeleted); // <-- MEJORA ADICIONAL

    return () => {
        socketService.off('new-sos-alert', handleNewAlert);
        socketService.off('sos-location-update', handleLocationUpdate);
        socketService.off('sos-alert-updated', handleAlertUpdate);
        socketService.off('sos-alert-ended', handleAlertEnded);
        socketService.off('sos-alert-deleted', handleAlertDeleted);
        clearInterval(countdownIntervalRef.current);
    };
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  // --- Datos Derivados ---
  const selectedAlertData = useMemo(() => allAlerts.find(a => a.id === selectedAlertId) || null, [allAlerts, selectedAlertId]);
  const currentPath = useMemo(() => selectedAlertId ? locationHistory[selectedAlertId] || [] : [], [selectedAlertId, locationHistory]);
  const latestLocation = useMemo(() => currentPath.length > 0 ? currentPath[currentPath.length - 1] : null, [currentPath]);

  const filteredAlerts = useMemo(() => {
       return allAlerts.filter(alert => {
           if (filters.userId && alert.id_usuario !== filters.userId) return false;
           if (filters.estado && alert.estado !== filters.estado) return false;
           if (filters.estado_atencion && (alert.estado_atencion || 'En Espera') !== filters.estado_atencion) return false;
           const alertDate = new Date(alert.fecha_inicio);
           if (filters.startDate && alertDate < startOfDay(filters.startDate)) return false;
           if (filters.endDate && alertDate > endOfDay(filters.endDate)) return false;
           return true;
       });
   }, [allAlerts, filters]);

  // --- Timer ---
  useEffect(() => {
    clearInterval(countdownIntervalRef.current);
    setActiveSosTimer(null);

    if (selectedAlertData?.estado === 'activo') {
      const startTime = new Date(selectedAlertData.fecha_inicio).getTime();
      const sosDurationSeconds = selectedAlertData.duracion_segundos || 0;

      const updateTimer = () => {
          const now = Date.now();
          const elapsed = Math.floor((now - startTime) / 1000);
          const remaining = Math.max(0, sosDurationSeconds - elapsed);
          const minutes = Math.floor(remaining / 60).toString().padStart(2, '0');
          const seconds = (remaining % 60).toString().padStart(2, '0');
          setActiveSosTimer(`${minutes}:${seconds}`);
          if (remaining <= 0) {
              clearInterval(countdownIntervalRef.current);
              // Opcional: Forzar estado visual a finalizado si el contador llega a 0 localmente
              // aunque es mejor esperar el evento del socket para confirmación real.
          }
      };
      updateTimer();
      countdownIntervalRef.current = setInterval(updateTimer, 1000);
    }
    return () => clearInterval(countdownIntervalRef.current);
  }, [selectedAlertData]);

  // --- Acciones ---
  const handleAttentionChange = (alertId, newStatus) => {
      setError('');
      sosService.updateStatus(alertId, { estado_atencion: newStatus }).catch(() => setError("Error al actualizar atención."));
  };

  const handleFinishAlert = (alertId) => {
    // Nota: Quitamos el window.confirm aquí si ya lo manejas en el componente DetalleAlertaSeleccionada
    // O lo dejamos como doble seguridad. Asumiremos que DetalleAlertaSeleccionada ya tiene su modal.
    
    setError('');
    // Enviamos 'finalizado' al backend. El backend emitirá 'sos-alert-ended' que capturamos arriba en el useEffect.
    sosService.updateStatus(alertId, { estado: 'finalizado' }).catch(() => setError("Error al finalizar."));
    
    if (selectedAlertId === alertId) {
         setActiveSosTimer(null);
         clearInterval(countdownIntervalRef.current);
    }
  };

  const handleFilterChange = (newFilters) => setFilters(newFilters);

  // --- RENDER (Diseño Original Intacto) ---
  return (
    <Box sx={{ p: { xs: 2, md: 3 }, minHeight: '100vh', bgcolor: 'background.default' }}>
      <Container maxWidth="xl" disableGutters>
        
        {/* 1. Header Principal */}
        <Box sx={{ mb: 4 }}>
            <Stack direction="row" alignItems="center" spacing={2} sx={{ mb: 1 }}>
                <SosIcon sx={{ fontSize: 40, color: 'error.main' }} />
                <Typography variant="h4" sx={{ fontWeight: 800, letterSpacing: '-0.5px' }}>
                    Centro de Emergencias
                </Typography>
            </Stack>
            <Typography variant="body1" color="text.secondary" sx={{ maxWidth: '800px', ml: { sm: 7 } }}>
                Monitoreo en tiempo real de alertas ciudadanas. Prioriza la atención inmediata y coordina la respuesta.
            </Typography>
        </Box>

        {error && <Fade in={true}><Alert severity="error" sx={{ mb: 3, borderRadius: 2 }}>{error}</Alert></Fade>}

        {/* 2. Panel de Control (Grid Principal) */}
        <Grid container spacing={3} sx={{ mb: 5 }}>
            
            {/* Columna Izquierda: Estado Activo y Detalles */}
            <Grid item xs={12} lg={4}>
                <Stack spacing={3} height="100%">
                    {/* Panel de Alerta Activa (KPI) */}
                    <PanelAlertaActiva alerts={allAlerts} />
                    
                    {/* Detalles de la Selección */}
                    <Box sx={{ flexGrow: 1 }}>
                        <DetalleAlertaSeleccionada
                            key={selectedAlertId || 'no-alert'}
                            alert={selectedAlertData}
                            timer={selectedAlertData?.estado === 'activo' ? activeSosTimer : null}
                            loading={loading && !selectedAlertData}
                            onFinishAlert={handleFinishAlert}
                        />
                    </Box>
                </Stack>
            </Grid>

            {/* Columna Derecha: Mapa Táctico */}
            <Grid item xs={12} lg={8}>
                <Box height="100%" minHeight={500}>
                    <MapaAlertaSOS
                        alertId={selectedAlertId}
                        locationHistory={currentPath}
                        latestLocation={latestLocation}
                        alertCode={selectedAlertData?.codigo_alerta}
                        loading={loading && !selectedAlertData}
                    />
                </Box>
            </Grid>
        </Grid>

        <Divider sx={{ my: 6, opacity: 0.6 }} />

        {/* 3. Sección Historial */}
        <Box>
            <Stack direction="row" alignItems="center" spacing={1} mb={3}>
                <HistoryIcon color="action" />
                <Typography variant="h5" fontWeight="bold">Historial de Incidentes</Typography>
            </Stack>

            <FiltrosHistorialSOS
                initialFilters={filters}
                onFilterChange={handleFilterChange}
            />

            <Box sx={{ mt: 3 }}>
                <ListaAlertasSOS
                    alerts={filteredAlerts}
                    selectedAlertId={selectedAlertId}
                    loading={loading && filteredAlerts.length === 0}
                    onSelectAlert={handleSelectAlert}
                    onAttentionChange={handleAttentionChange}
                />
            </Box>
        </Box>

      </Container>
    </Box>
  );
}

export default PaginaAlertasSOS;