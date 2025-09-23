import React, { useEffect, useState, useCallback, useRef } from 'react';
import { Box, Paper, Typography, Grid, CircularProgress, Chip, Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Select, MenuItem, IconButton, Tooltip, Divider, Button } from '@mui/material';
import { MapContainer, TileLayer, Marker, Polyline, useMap } from 'react-leaflet';
import L from 'leaflet';
import socketService from '../services/socketService';
import sosService from '../services/sosService';
import html2canvas from 'html2canvas';
import CameraAltIcon from '@mui/icons-material/CameraAlt';

// Fix for a known issue with react-leaflet's default icon paths
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});

// A helper component to dynamically recenter the map
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
  const [locationHistory, setLocationHistory] = useState([]);
  const [loading, setLoading] = useState(true);
  
  const mapRef = useRef(null);

  const fetchData = useCallback(() => {
    sosService.getAllAlerts().then(data => {
      setAlerts(data);
      if (data.length > 0) {
        const latestActive = data.find(a => a.estado === 'activo');
        handleSelectAlert(latestActive || data[0]);
      }
      setLoading(false);
    });
  }, []);

  useEffect(() => {
    fetchData();
    socketService.connect();
    
    socketService.on('new-sos-alert', (newAlert) => {
      setAlerts(prev => [newAlert, ...prev.filter(a => a.id !== newAlert.id)]);
      handleSelectAlert(newAlert);
    });

    socketService.on('sos-location-update', (update) => {
      setAlerts(prev => prev.map(alert => 
        alert.id === update.alertId ? { ...alert, latitude: update.location.lat, longitude: update.location.lon } : alert
      ));
      if (selectedAlert && update.alertId === selectedAlert.id) {
        const newLocation = [update.location.lat, update.location.lon];
        setLocationHistory(prev => [...prev, newLocation]);
        setSelectedAlert(prev => ({ ...prev, latitude: update.location.lat, longitude: update.location.lon }));
      }
    });
    
    socketService.on('sos-alert-updated', (updatedAlert) => {
      setAlerts(prev => prev.map(a => a.id === updatedAlert.id ? updatedAlert : a));
      if (selectedAlert && updatedAlert.id === selectedAlert.id) {
        setSelectedAlert(updatedAlert);
      }
    });

    return () => socketService.disconnect();
  }, [fetchData, selectedAlert]);

  const handleSelectAlert = (alert) => {
    if (alert) {
      setSelectedAlert(alert);
      sosService.getLocationHistory(alert.id).then(history => {
        const initialPoint = (alert.latitude && alert.longitude) ? [[alert.latitude, alert.longitude]] : [];
        const path = history.map(p => [p.lat, p.lon]);
        setLocationHistory([...initialPoint, ...path]);
      });
      if (!alert.revisada) {
        sosService.updateStatus(alert.id, { revisada: true });
      }
    }
  };

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
      html2canvas(mapRef.current._container).then(canvas => {
        const link = document.createElement('a');
        const fileName = `SOS-${selectedAlert?.id}-${selectedAlert?.alias || 'user'}-${new Date().toISOString().split('T')[0]}.png`;
        link.download = fileName;
        link.href = canvas.toDataURL();
        link.click();
      });
    }
  };
  
  const latestLocation = selectedAlert ? [selectedAlert.latitude, selectedAlert.longitude] : [-5.19449, -80.63282];
  
  if (loading) {
    return <Box sx={{ display: 'flex', justifyContent: 'center', mt: 4 }}><CircularProgress /></Box>;
  }

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>Alertas SOS en Tiempo Real</Typography>
      
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} md={5}>
          <Typography variant="h6" gutterBottom>Detalle de Alerta Seleccionada</Typography>
          <Paper sx={{ p: 2 }}>
            {!selectedAlert ? <Typography color="text.secondary">Seleccione una alerta de la tabla inferior.</Typography> : (
              <Box>
                <Typography variant="h5" sx={{ fontWeight: 'bold' }}>Alerta #{selectedAlert.id}</Typography>
                <Typography variant="body1">Usuario: <strong>{selectedAlert.alias || selectedAlert.nombre}</strong></Typography>
                <Typography variant="body2" color="text.secondary">{selectedAlert.email}</Typography>
                <Typography variant="body2" color="text.secondary">Teléfono: {selectedAlert.telefono || 'No registrado'}</Typography>
                
                <Divider sx={{ my: 2 }} />
                
                <Typography variant="body2"><strong>Fecha de Inicio:</strong> {new Date(selectedAlert.fecha_inicio).toLocaleString()}</Typography>
                <Typography variant="body2"><strong>Estado:</strong> {selectedAlert.estado}</Typography>
                <Typography variant="body2"><strong>Atención:</strong> {selectedAlert.estado_atencion}</Typography>

                <Box sx={{ mt: 2 }}>
                  <Button 
                    variant="contained" 
                    color="error" 
                    onClick={() => handleFinishAlert(selectedAlert.id)}
                    disabled={selectedAlert.estado === 'finalizado'}
                  >
                    Finalizar Alerta
                  </Button>
                </Box>
              </Box>
            )}
          </Paper>
        </Grid>
        
        <Grid item xs={12} md={7}>
           <Typography variant="h6" gutterBottom>Ubicación en Vivo</Typography>
          <Paper sx={{ height: '50vh', position: 'relative' }}>
             <MapContainer ref={mapRef} center={latestLocation} zoom={16} style={{ height: '100%' }}>
              <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
              <Polyline pathOptions={{ color: 'red' }} positions={locationHistory} />
              <Marker position={latestLocation} />
              <MapRecenter center={latestLocation} />
            </MapContainer>
            <Tooltip title="Capturar Mapa">
              <IconButton onClick={handleCaptureMap} sx={{ position: 'absolute', top: 10, right: 10, zIndex: 1000, bgcolor: 'white', '&:hover': { bgcolor: 'grey.200' }}}>
                <CameraAltIcon />
              </IconButton>
            </Tooltip>
          </Paper>
        </Grid>
      </Grid>
      
      <Typography variant="h6" gutterBottom>Historial de Alertas SOS</Typography>
      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>ID</TableCell>
              <TableCell>Usuario</TableCell>
              <TableCell>Fecha Inicio</TableCell>
              <TableCell>Estado</TableCell>
              <TableCell>Revisada</TableCell>
              <TableCell>Atención</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {alerts.map(alert => (
              <TableRow key={alert.id} hover selected={selectedAlert?.id === alert.id} onClick={() => handleSelectAlert(alert)} sx={{ cursor: 'pointer' }}>
                <TableCell>{alert.id}</TableCell>
                <TableCell>{alert.alias || alert.nombre}</TableCell>
                <TableCell>{new Date(alert.fecha_inicio).toLocaleString()}</TableCell>
                <TableCell><Chip label={alert.estado} color={alert.estado === 'activo' ? 'success' : 'default'} size="small" /></TableCell>
                <TableCell>{alert.revisada ? 'Sí' : 'No'}</TableCell>
                <TableCell>
                  <Select value={alert.estado_atencion || 'En Espera'} onChange={(e) => { e.stopPropagation(); handleAttentionChange(alert.id, e.target.value); }} size="small" sx={{ minWidth: 120 }}>
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