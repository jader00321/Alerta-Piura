import React, { useEffect, useState, useCallback, useRef } from 'react';
import { Box, Paper, Typography, Grid, CircularProgress, Chip, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Select, MenuItem, IconButton, Tooltip, Divider, Button } from '@mui/material';
import { MapContainer, TileLayer, Marker, Polyline, useMap } from 'react-leaflet';
import L from 'leaflet';
import socketService from '../services/socketService';
import sosService from '../services/sosService';
import html2canvas from 'html2canvas';
import CameraAltIcon from '@mui/icons-material/CameraAlt';
import MyLocationIcon from '@mui/icons-material/MyLocation';

// Fix para un problema conocido con los íconos de react-leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});

function MapRecenter({ center }) {
  const map = useMap();
  useEffect(() => {
    if (center) {
      map.setView(center, map.getZoom(), { animate: true });
    }
  }, [center, map]);
  return null;
}

function SOSAlertsPage() {
  const [alerts, setAlerts] = useState([]);
  const [selectedAlert, setSelectedAlert] = useState(null);
  const [locationHistory, setLocationHistory] = useState({});
  const [loading, setLoading] = useState(true);
  const [activeSosTimer, setActiveSosTimer] = useState(null);
  const mapRef = useRef(null);
  const countdownIntervalRef = useRef(null);

  const handleSelectAlert = useCallback((alert) => {
    if (alert) {
      setSelectedAlert(alert);
      sosService.getLocationHistory(alert.id).then(history => {
        const path = history.map(p => [p.lat, p.lon]);
        setLocationHistory(prev => ({ ...prev, [alert.id]: path }));
      });
      if (!alert.revisada) {
        sosService.updateStatus(alert.id, { revisada: true });
      }
    } else {
      setSelectedAlert(null);
    }
  }, []);

  const fetchData = useCallback(() => {
    sosService.getSosDashboardData().then(data => {
      setAlerts(data);
      if (data.length > 0) {
        const latestActive = data.find(a => a.estado === 'activo');
        handleSelectAlert(latestActive || data[0]);
      }
      setLoading(false);
    }).catch(console.error);
  }, [handleSelectAlert]);

  useEffect(() => {
    fetchData();
    socketService.connect();
    
    socketService.on('new-sos-alert', (newAlert) => {
      setAlerts(prev => [newAlert, ...prev.filter(a => a.id !== newAlert.id)]);
      handleSelectAlert(newAlert);
    });

    socketService.on('sos-location-update', (update) => {
      setLocationHistory(prev => ({
        ...prev,
        [update.alertId]: [...(prev[update.alertId] || []), [update.location.lat, update.location.lon]]
      }));
    });
    
    socketService.on('sos-alert-updated', (updatedAlert) => {
      setAlerts(prev => prev.map(a => a.id === updatedAlert.id ? { ...a, ...updatedAlert } : a));
    });

    return () => socketService.disconnect();
  }, [handleSelectAlert]);

  useEffect(() => {
    if (selectedAlert) {
      const updatedSelected = alerts.find(a => a.id === selectedAlert.id);
      if (updatedSelected) {
        setSelectedAlert(updatedSelected);
      }

      clearInterval(countdownIntervalRef.current);
      if (selectedAlert?.estado === 'activo') {
          const startTime = new Date(selectedAlert.fecha_inicio).getTime();
          // --- USE THE REAL DURATION FROM THE BACKEND ---
          const sosDurationSeconds = selectedAlert.duracion_segundos || 600;

          countdownIntervalRef.current = setInterval(() => {
              const now = new Date().getTime();
              const elapsed = Math.floor((now - startTime) / 1000);
              const remaining = sosDurationSeconds - elapsed;
              
              if (remaining > 0) {
                const minutes = Math.floor(remaining / 60).toString().padStart(2, '0');
                const seconds = (remaining % 60).toString().padStart(2, '0');
                setActiveSosTimer(`${minutes}:${seconds}`);
              } else {
                setActiveSosTimer('00:00');
                clearInterval(countdownIntervalRef.current);
              }
          }, 1000);
      } else {
          setActiveSosTimer(null);
      }
    }
    return () => clearInterval(countdownIntervalRef.current);
  }, [alerts, selectedAlert]);
  
  const handleAttentionChange = (alertId, newStatus) => {
    sosService.updateStatus(alertId, { estado_atencion: newStatus });
  };
  const handleFinishAlert = (alertId) => {
    if (window.confirm('¿Está seguro de que desea finalizar esta alerta SOS?')) {
      sosService.updateStatus(alertId, { estado: 'finalizado' });
    }
  };
  
  const handleCaptureMap = () => {
    if (mapRef.current) {
      // --- FIX FOR SCREENSHOT ---
      // Use the map container's DOM element directly
      html2canvas(mapRef.current.getContainer(), { useCORS: true }).then(canvas => {
        const link = document.createElement('a');
        const fileName = `${selectedAlert.codigo_alerta}.png`;
        link.download = fileName;
        link.href = canvas.toDataURL();
        link.click();
      });
    }
  };

  
  const currentPath = selectedAlert ? locationHistory[selectedAlert.id] || [] : [];
  const latestLocation = currentPath.length > 0 ? currentPath[currentPath.length - 1] : null;
  
  if (loading) {
    return <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}><CircularProgress /></Box>;
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>Alertas SOS en Tiempo Real</Typography>
      
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} md={5}>
          <Typography variant="h6" gutterBottom>Detalle de Alerta Seleccionada</Typography>
          <Paper sx={{ p: 2, minHeight: '50vh' }}>
            <Box sx={{ mt: 2 }}></Box>
            {!selectedAlert ? <Typography color="text.secondary">No hay alertas activas. Esperando nuevas alertas...</Typography> : (
              <Box>
                <Typography variant="h5" sx={{ fontWeight: 'bold' }}>Alerta {selectedAlert.codigo_alerta}</Typography>
                <Divider sx={{ my: 2 }} />
                <Typography variant="body1">Usuario: <strong>{selectedAlert.alias || selectedAlert.nombre}</strong> ({selectedAlert.rol})</Typography>
                <Typography variant="body2" color="text.secondary">{selectedAlert.email}</Typography>
                <Typography variant="body2" color="text.secondary">Teléfono: {selectedAlert.telefono || 'No registrado'}</Typography>
                <Divider sx={{ my: 2 }} />
                <Typography variant="body2"><strong>Fecha de Inicio:</strong> {new Date(selectedAlert.fecha_inicio).toLocaleString()}</Typography>
                <Typography variant="body2"><strong>Estado:</strong> {selectedAlert.estado}</Typography>
                <Typography variant="body2"><strong>Atención:</strong> {selectedAlert.estado_atencion}</Typography>
                <Box sx={{ mt: 3 }}></Box>
                {activeSosTimer && (
                  <Chip label={`Tiempo Restante: ${activeSosTimer}`} color="error" sx={{ mt: 2 }}/>
                )}
                <Box sx={{ mt: 5 }}>
                  <Button 
                  fullWidth variant="contained" color={selectedAlert.estado === 'finalizado' ? 'inherit' : 'error'} 
                  onClick={() => handleFinishAlert(selectedAlert.id)}
                  disabled={selectedAlert.estado === 'finalizado'}
                >
                  {selectedAlert.estado === 'finalizado' ? 'Alerta Finalizada' : 'Finalizar Alerta'}
                </Button>
                </Box>
              </Box>
            )}
          </Paper>
        </Grid>
        
        <Grid item xs={12} md={7}>
          <Typography variant="h6" gutterBottom>Ubicación en Vivo</Typography>
          <Paper sx={{ height: '50vh', minWidth: '400px', position: 'relative' }}>
              {latestLocation ? (
                <MapContainer ref={mapRef} center={latestLocation} zoom={16} style={{ height: '100%' }}>
                  <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
                  <Polyline pathOptions={{ color: 'red' }} positions={currentPath} />
                  <Marker position={latestLocation} />
                  <MapRecenter center={latestLocation} />
                </MapContainer>
              ) : (
                <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%' }}>
                  <Typography color="text.secondary">Ubicación no disponible para esta alerta.</Typography>
                </Box>
              )}
            <Box sx={{ position: 'absolute', top: 10, right: 10, zIndex: 1000, display: 'flex', flexDirection: 'column', gap: 1, }}>
              <Tooltip title="Capturar"><IconButton onClick={handleCaptureMap}sx={{'&:hover':{bgcolor:'grey.200'}}}><CameraAltIcon sx={{ color: 'black',backgroundColor: 'rgba(49, 39, 39, 0.35)', borderRadius: 2, pboxShadow: 2, fontSize: 35, padding: 0.3}}/></IconButton></Tooltip>
              <Tooltip title="Centrar"><IconButton onClick={() => mapRef.current.flyTo(latestLocation, 16)} sx={{top: 20}}><MyLocationIcon sx={{ color: 'black', backgroundColor: 'rgba(49, 39, 39, 0.35)', borderRadius: 1.5, pboxShadow: 2, fontSize: 35, padding: 0.3}}/></IconButton></Tooltip>
            </Box>
          </Paper>
        </Grid>
      </Grid>
      
      <Typography variant="h6" gutterBottom>Historial de Alertas SOS</Typography>
      <TableContainer component={Paper}>
        <Table size="small">
          <TableHead>
            <TableRow>
              <TableCell>Código</TableCell>
              <TableCell>Usuario</TableCell>
              <TableCell>Contacto de Emergencia</TableCell>
              <TableCell>Mensaje</TableCell>
              <TableCell>Estado</TableCell>
              <TableCell>Revisada</TableCell>
              <TableCell>Atención</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {alerts.map(alert => (
              <TableRow key={alert.id} hover selected={selectedAlert?.id === alert.id} onClick={() => handleSelectAlert(alert)} sx={{ cursor: 'pointer' }}>
                <TableCell>{alert.codigo_alerta}</TableCell>
                <TableCell>{alert.alias || alert.nombre}</TableCell>
                <TableCell>{alert.contacto_emergencia_telefono || 'N/A'}</TableCell>
                <TableCell>{alert.contacto_emergencia_mensaje || 'N/A'}</TableCell>
                <TableCell><Chip label={alert.estado} color={alert.estado === 'activo' ? 'success' : 'default'} size="small" /></TableCell>
                <TableCell>{alert.revisada ? 'Sí' : 'No'}</TableCell>
                <TableCell>
                  <Select value={alert.estado_atencion || 'En Espera'} onChange={(e) => { e.stopPropagation(); handleAttentionChange(alert.id, e.target.value); }} size="small">
                    <MenuItem value="En Espera">En Espera</MenuItem>
                    <MenuItem value="En Curso">En Curso</MenuItem>
                    <MenuItem value="Atendida">Atendida</MenuItem>
                  </Select>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>
    </Box>
  );
}

export default SOSAlertsPage;