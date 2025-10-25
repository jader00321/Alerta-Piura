// src/pages/PaginaAlertasSOS.jsx
import React, { useEffect, useState, useCallback, useRef, useMemo } from 'react';
import { Box, Typography, Grid, CircularProgress, Alert, Divider, Stack } from '@mui/material';
import socketService from '../services/socketService';     // Asegúrate que la ruta sea correcta
import sosService from '../services/sosService';         // Asegúrate que la ruta sea correcta

// --- Importar Componentes ---
import ListaAlertasSOS from '../components/SOS/ListaAlertasSOS';
import DetalleAlertaSeleccionada from '../components/SOS/DetalleAlertaSeleccionada';
import MapaAlertaSOS from '../components/SOS/MapaAlertaSOS';
import PanelAlertaActiva from '../components/SOS/PanelAlertaActiva';
import FiltrosHistorialSOS from '../components/SOS/FiltrosHistorialSOS';

// Importar date-fns para fechas por defecto
import { subDays, startOfDay, endOfDay } from 'date-fns';

function PaginaAlertasSOS() {
  // --- Estados Principales ---
  const [allAlerts, setAllAlerts] = useState([]); // Todas las alertas recibidas
  const [selectedAlertId, setSelectedAlertId] = useState(null); // ID de la alerta seleccionada
  const [locationHistory, setLocationHistory] = useState({}); // Historial de ubicaciones { alertId: [[lat, lon], ...], ... }
  const [loading, setLoading] = useState(true); // Carga inicial
  const [error, setError] = useState(''); // Mensajes de error
  const [activeSosTimer, setActiveSosTimer] = useState(null); // String del temporizador ej: "09:59"
  const countdownIntervalRef = useRef(null); // Ref para el intervalo

  // --- Estado para Filtros con valor inicial (últimos 7 días) ---
  const [filters, setFilters] = useState(() => {
      const initialEndDate = endOfDay(new Date());
      const initialStartDate = startOfDay(subDays(initialEndDate, 6)); // Últimos 7 días
      return {
          userId: null,
          startDate: initialStartDate,
          endDate: initialEndDate,
          estado: '',
          estado_atencion: '',
      };
  });

  // --- Selección de Alerta y Carga de Historial de Ubicación ---
  const handleSelectAlert = useCallback(async (alert) => {
    if (!alert || alert.id === selectedAlertId) return; // No hacer nada si no hay alerta o ya está seleccionada

    console.log("Seleccionando alerta:", alert.id);
    setSelectedAlertId(alert.id);

    // Marcar como revisada en segundo plano
    if (!alert.revisada) {
      sosService.updateStatus(alert.id, { revisada: true }).catch(err => console.warn("Error al marcar como revisada:", err));
    }

    // Cargar historial si no existe
    if (!locationHistory[alert.id]) {
        try {
            console.log("Cargando historial de ubicación para:", alert.id);
            const history = await sosService.getLocationHistory(alert.id);
            const path = history.map(p => [p.lat, p.lon]);
            // Actualiza el estado con el nuevo historial
            setLocationHistory(prev => ({ ...prev, [alert.id]: path }));
        } catch(histError){
             console.error(`Error cargando historial para alerta ${alert.id}:`, histError);
             // Guarda array vacío en error para evitar reintentos y indicar que se intentó cargar
             setLocationHistory(prev => ({ ...prev, [alert.id]: [] }));
        }
    }
  }, [selectedAlertId, locationHistory]); // Dependencias: selectedAlertId, locationHistory

  // --- Fetch Inicial de Datos ---
  const fetchData = useCallback(async () => {
    console.log("FetchData SOS: Iniciando...");
    setLoading(true); setError('');
    try {
      const data = await sosService.getSosDashboardData();
      // Ordena por fecha de inicio descendente (más reciente primero)
      const sortedData = data ? [...data].sort((a, b) => new Date(b.fecha_inicio) - new Date(a.fecha_inicio)) : [];
      setAllAlerts(sortedData);
      console.log("FetchData SOS: Datos recibidos:", sortedData.length);

      // --- Lógica de Selección Inicial ---
      // Selecciona la alerta MÁS RECIENTE solo si no hay ninguna seleccionada aún
      // Y si NO hay filtros específicos activos (excepto las fechas por defecto)
      const specificFiltersActive = filters.userId || filters.estado || filters.estado_atencion;
      if (sortedData.length > 0 && selectedAlertId === null && !specificFiltersActive) {
          console.log("Estableciendo alerta seleccionada por defecto (la más reciente):", sortedData[0]);
          // Llamar a handleSelectAlert DESPUÉS de un pequeño delay
          setTimeout(() => handleSelectAlert(sortedData[0]), 0);
      } else if (sortedData.length === 0) {
          setSelectedAlertId(null); // Limpia si no hay alertas
      }

    } catch (err) {
      console.error("Error fetching SOS data:", err);
      setError("No se pudieron cargar las alertas SOS.");
      setAllAlerts([]);
      setSelectedAlertId(null);
    } finally {
      setLoading(false);
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [handleSelectAlert]); // Solo depende de handleSelectAlert (estable con useCallback)

  // --- Efecto para Carga Inicial y Configuración de Sockets ---
  useEffect(() => {
    fetchData(); // Carga inicial

    const token = localStorage.getItem('admin_token'); // O usa useAuth().token
    if(token) {
        socketService.connect(token); // Conecta y autentica
    } else {
        console.error("PaginaAlertasSOS: No hay token para conectar socket.");
        setError("Error de autenticación, no se pudo conectar al servidor en tiempo real.");
        return; // No configurar listeners si no hay conexión
    }

    // --- Listeners de Socket ---
    const handleNewAlert = (newAlert) => {
        console.log("Nueva alerta SOS recibida por socket:", newAlert);
        setAllAlerts(prev => {
            const exists = prev.some(a => a.id === newAlert.id);
            if (exists) return prev; // Evita duplicados
            // Añade la nueva al principio
            return [newAlert, ...prev];
        });
        // NO cambia la alerta seleccionada automáticamente
    };
    const handleLocationUpdate = (update) => {
         console.log("Actualización de ubicación SOS recibida:", update);
         if (!update || !update.alertId || !update.location) return; // Validación
         setLocationHistory(prev => {
             const current = prev[update.alertId] || [];
             const newLoc = [update.location.lat, update.location.lon];
             // Evita duplicados exactos
             if(current.length > 0 && current[current.length - 1][0] === newLoc[0] && current[current.length - 1][1] === newLoc[1]) {
                 return prev;
             }
             return { ...prev, [update.alertId]: [...current, newLoc] };
         });
    };
     const handleAlertUpdate = (updatedAlert) => {
         console.log("Actualización de estado SOS recibida:", updatedAlert);
         if (!updatedAlert || !updatedAlert.id) return; // Validación
         setAllAlerts(prev => prev.map(a => a.id === updatedAlert.id ? { ...a, ...updatedAlert } : a));
     };

    socketService.on('new-sos-alert', handleNewAlert);
    socketService.on('sos-location-update', handleLocationUpdate);
    socketService.on('sos-alert-updated', handleAlertUpdate);

    // --- Limpieza al desmontar ---
    return () => {
        console.log("Desmontando PaginaAlertasSOS, limpiando listeners...");
        socketService.off('new-sos-alert', handleNewAlert);
        socketService.off('sos-location-update', handleLocationUpdate);
        socketService.off('sos-alert-updated', handleAlertUpdate);
        // NO desconectar socket aquí, debería ser manejado por AuthContext o App
        clearInterval(countdownIntervalRef.current); // Limpia el intervalo del timer
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []); // Solo ejecutar al montar

   // --- Datos Derivados (para pasar a componentes hijos) ---
   const selectedAlertData = useMemo(() => {
       return allAlerts.find(a => a.id === selectedAlertId) || null;
   }, [allAlerts, selectedAlertId]);

   const currentPath = useMemo(() => selectedAlertId ? locationHistory[selectedAlertId] || [] : [], [selectedAlertId, locationHistory]);
   const latestLocation = useMemo(() => currentPath.length > 0 ? currentPath[currentPath.length - 1] : null, [currentPath]);

   // Lista de alertas filtrada para el historial
   const filteredAlerts = useMemo(() => {
       return allAlerts.filter(alert => {
           if (filters.userId && alert.id_usuario !== filters.userId) return false;
           if (filters.estado && alert.estado !== filters.estado) return false;
           if (filters.estado_atencion && (alert.estado_atencion || 'En Espera') !== filters.estado_atencion) return false;
           const alertDate = new Date(alert.fecha_inicio);
           // Compara fechas usando startOfDay/endOfDay para asegurar inclusión correcta
           if (filters.startDate && alertDate < startOfDay(filters.startDate)) return false;
           if (filters.endDate && alertDate > endOfDay(filters.endDate)) return false;
           return true;
       });
   }, [allAlerts, filters]);


  // --- Efecto para el Temporizador (basado en selectedAlertData) ---
  useEffect(() => {
    clearInterval(countdownIntervalRef.current);
    setActiveSosTimer(null);

    if (selectedAlertData?.estado === 'activo') {
      const startTime = new Date(selectedAlertData.fecha_inicio).getTime();
      // Usar la duración que viene del backend
      const sosDurationSeconds = selectedAlertData.duracion_segundos || 0; // Default a 0 si no existe

      const updateTimer = () => {
          const now = Date.now();
          const elapsed = Math.floor((now - startTime) / 1000);
          const remaining = Math.max(0, sosDurationSeconds - elapsed); // Evitar negativos

          const minutes = Math.floor(remaining / 60).toString().padStart(2, '0');
          const seconds = (remaining % 60).toString().padStart(2, '0');
          setActiveSosTimer(`${minutes}:${seconds}`);

          if (remaining <= 0) {
            clearInterval(countdownIntervalRef.current);
            // Podríamos forzar un refetch aquí si el backend no actualiza automáticamente el estado a 'finalizado'
            // fetchData();
          }
      };

      updateTimer(); // Ejecuta inmediatamente
      countdownIntervalRef.current = setInterval(updateTimer, 1000);
    }

    // Limpieza
    return () => clearInterval(countdownIntervalRef.current);
  }, [selectedAlertData]); // Solo depende de la data de la alerta seleccionada


  // --- Handlers de Acciones ---
  const handleAttentionChange = (alertId, newStatus) => {
      setError('');
      sosService.updateStatus(alertId, { estado_atencion: newStatus })
          .catch(err => {
              setError("Error al actualizar estado de atención.");
              console.error("Error updating attention status:", err);
          });
      // La actualización visual vendrá por socket 'sos-alert-updated'
  };

  const handleFinishAlert = (alertId) => {
    if (window.confirm('¿Está seguro de finalizar esta alerta SOS?')) {
        setError('');
        sosService.updateStatus(alertId, { estado: 'finalizado' })
            .catch(err => {
                setError("Error al finalizar la alerta.");
                console.error("Error finishing alert:", err);
            });
         // Limpia el timer visual inmediatamente si es la alerta seleccionada
         if (selectedAlertId === alertId) {
             setActiveSosTimer(null);
             clearInterval(countdownIntervalRef.current);
         }
         // La actualización visual completa vendrá por socket 'sos-alert-updated'
    }
  };

  // --- Handler para cambio de filtros ---
   const handleFilterChange = (newFilters) => {
       console.log("Aplicando filtros:", newFilters);
       setFilters(newFilters);
   };


  // --- Render Principal ---
  return (
    <Box sx={{ p: { xs: 1, sm: 2, md: 3 } }}>
      {/* --- HEADER --- */}
      <Typography variant="h4" sx={{ fontWeight: 'bold' }}>Alertas SOS</Typography>
      <Typography variant="body1" color="text.secondary" gutterBottom>
        Monitoriza emergencias activas y revisa el historial. Selecciona una alerta para ver detalles y ubicación.
      </Typography>
      <Divider sx={{ my: 2 }}/>
      {error && <Alert severity="error" onClose={() => setError('')} sx={{ mb: 2 }}>{error}</Alert>}

      {/* --- Layout Principal (Stack Vertical) --- */}
      <Stack spacing={3}>

          {/* --- Fila Superior: Panel Activa, Detalles, Mapa --- */}
          <Grid container spacing={3} alignItems="stretch">
              {/* Panel Alerta Activa */}
              <Grid item xs={12} lg={3}>
                  <PanelAlertaActiva alerts={allAlerts} />
              </Grid>
              {/* Detalles Alerta Seleccionada */}
              <Grid item xs={12} md={6} lg={4}>
                  <DetalleAlertaSeleccionada
                      key={selectedAlertId || 'no-alert'} // Clave para forzar re-render
                      alert={selectedAlertData}
                      timer={selectedAlertData?.estado === 'activo' ? activeSosTimer : null}
                      loading={loading && !selectedAlertData} // Muestra skeleton si carga inicial y no hay selección
                      onFinishAlert={handleFinishAlert}
                  />
              </Grid>
              {/* Mapa */}
              <Grid item xs={12} md={6} lg={5}>
                  <MapaAlertaSOS
                      alertId={selectedAlertId}
                      locationHistory={currentPath}
                      latestLocation={latestLocation}
                      alertCode={selectedAlertData?.codigo_alerta}
                       // Muestra skeleton si carga inicial y no hay selección
                      loading={loading && !selectedAlertData}
                  />
              </Grid>
          </Grid>

          {/* --- Fila Inferior: Historial --- */}
          <Box>
              <Typography variant="h6" gutterBottom sx={{ fontWeight: 'medium', mt: 2 }}>
                  Historial de Alertas
              </Typography>
              {/* --- Componente de Filtros --- */}
              <FiltrosHistorialSOS
                  initialFilters={filters} // Pasa filtros iniciales (con fechas por defecto)
                  onFilterChange={handleFilterChange}
                  // Podríamos pasar 'loading' para deshabilitar mientras carga inicial
                  // loading={loading}
              />
              {/* --- Lista ahora recibe las alertas filtradas --- */}
              <ListaAlertasSOS
                  alerts={filteredAlerts} // Pasar lista filtrada
                  selectedAlertId={selectedAlertId}
                  // Muestra skeleton solo si carga inicial Y la lista filtrada está vacía
                  loading={loading && filteredAlerts.length === 0}
                  onSelectAlert={handleSelectAlert}
                  onAttentionChange={handleAttentionChange}
              />
          </Box>
      </Stack>
    </Box>
  );
}

export default PaginaAlertasSOS;