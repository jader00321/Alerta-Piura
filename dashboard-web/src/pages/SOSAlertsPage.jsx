import React, { useEffect, useState} from 'react';
import { Box, Paper, Typography, List, ListItem, ListItemButton, ListItemText, Grid, Divider } from '@mui/material';
import { MapContainer, TileLayer, Marker, Polyline, useMap } from 'react-leaflet';
import L from 'leaflet';
import socketService from '../services/socketService';
import sosService from '../services/sosService';

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
  }, [center]);
  return null;
}

function SOSAlertsPage() {
  const [activeAlerts, setActiveAlerts] = useState([]);
  const [selectedAlert, setSelectedAlert] = useState(null);
  const [locationHistory, setLocationHistory] = useState({});

  useEffect(() => {
    sosService.getActiveAlerts().then(initialAlerts => {
      setActiveAlerts(initialAlerts);
    });

    socketService.connect();

    socketService.on('new-sos-alert', (newAlert) => {
      setActiveAlerts(prevAlerts => [newAlert, ...prevAlerts]);
      // Automatically select the newest alert
      setSelectedAlert(newAlert);
      // Initialize location history for this new alert
      setLocationHistory(prev => ({ ...prev, [newAlert.id]: [[newAlert.latitude, newAlert.longitude]] }));
    });

    socketService.on('sos-location-update', (update) => {
      // Find the alert in the list and update its latest location
      setActiveAlerts(prev => prev.map(alert => 
        alert.id === update.alertId ? { ...alert, latitude: update.location.lat, longitude: update.location.lon } : alert
      ));
      // Add new location to the history for the specific alert
      setLocationHistory(prev => ({
        ...prev,
        [update.alertId]: [...(prev[update.alertId] || []), [update.location.lat, update.location.lon]]
      }));
      if (selectedAlert && update.alertId === selectedAlert.id) {
        setSelectedAlert(prev => ({ ...prev, latitude: update.location.lat, longitude: update.location.lon }));
      }
    });

    return () => {
      socketService.disconnect();
    };
  }, [selectedAlert]);

  const handleSelectAlert = (alert) => {
    setSelectedAlert(alert);
  };
  
  const currentPath = selectedAlert ? locationHistory[selectedAlert.id] || [] : [];
  const latestLocation = selectedAlert ? [selectedAlert.latitude, selectedAlert.longitude] : null;

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Alertas SOS en Tiempo Real
      </Typography>
      <Grid container spacing={3}>
        <Grid item xs={12} md={4}>
          <Typography variant="h6" gutterBottom>Alertas Activas</Typography>
          <Paper sx={{ height: '75vh', overflow: 'auto' }}>
            <List>
              {activeAlerts.length > 0 ? activeAlerts.map(alert => (
                <ListItemButton 
                  key={alert.id} 
                  onClick={() => handleSelectAlert(alert)}
                  selected={selectedAlert?.id === alert.id}
                >
                  <ListItemText 
                    primaryTypographyProps={{ style: { fontWeight: 'bold' } }}
                    primary={`Alerta #${alert.id} - ${alert.usuario.alias || alert.usuario.nombre}`}
                    secondary={`Iniciada: ${new Date(alert.fecha_inicio).toLocaleString()}`}
                  />
                </ListItemButton>
              )) : (
                <ListItemText primary="No hay alertas SOS activas en este momento." sx={{ p: 2, color: 'text.secondary' }} />
              )}
            </List>
          </Paper>
        </Grid>

        <Grid item xs={12} md={8}>
           <Typography variant="h6" gutterBottom>Ubicación en Vivo</Typography>
          <Paper sx={{ height: '75vh', width: '100%' }}>
            {selectedAlert && latestLocation ? (
              <MapContainer center={latestLocation} zoom={16} style={{ height: '100%', width: '100%' }}>
                <TileLayer
                  url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                  attribution='&copy; OpenStreetMap'
                />
                <Polyline pathOptions={{ color: 'red' }} positions={currentPath} />
                <Marker position={latestLocation} />
                <MapRecenter center={latestLocation} />
              </MapContainer>
            ) : (
              <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%' }}>
                <Typography color="text.secondary">Seleccione una alerta para ver el mapa.</Typography>
              </Box>
            )}
          </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}

export default SOSAlertsPage;