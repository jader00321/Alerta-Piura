import React, { useEffect, useState } from 'react';
import { Box, Paper, Typography, CircularProgress } from '@mui/material';
import { MapContainer, TileLayer, Marker } from 'react-leaflet';
import MarkerClusterGroup from '@changey/react-leaflet-markercluster';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import '@changey/react-leaflet-markercluster/dist/styles.min.css'; // CSS for the cluster
import adminService from '../services/adminService';

// Fix for default icon issue
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});

function AnalyticsPage() {
  const [reportPoints, setReportPoints] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  // This useEffect will run only once, preventing any loops.
  useEffect(() => {
    adminService.getReportCoordinates()
      .then(data => {
        // Convert {lat, lon} objects to Leaflet's LatLng object
        const points = data.map(p => new L.LatLng(p.lat, p.lon));
        setReportPoints(points);
      })
      .catch(err => {
        console.error("Failed to load analytics data:", err);
        setError('No se pudieron cargar los datos para el mapa.');
      })
      .finally(() => {
        setLoading(false);
      });
  }, []); // The empty dependency array ensures this runs only ONCE.

  const piuraCenter = [-5.19449, -80.63282];

  // Conditional rendering to handle all states: loading, error, and success
  const renderContent = () => {
    if (loading) {
      return <Box sx={{ display: 'flex', justifyContent: 'center', p: 4 }}><CircularProgress /></Box>;
    }
    if (error) {
      return <Typography color="error" sx={{ p: 4 }}>{error}</Typography>;
    }
    return (
      <MapContainer center={piuraCenter} zoom={13} style={{ height: '100%', width: '100%' }}>
        <TileLayer
          url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          attribution='&copy; OpenStreetMap'
        />
        <MarkerClusterGroup>
          {reportPoints.map((point, index) => (
            <Marker key={index} position={point} />
          ))}
        </MarkerClusterGroup>
      </MapContainer>
    );
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Análisis de Incidentes
      </Typography>
      
      <Typography variant="h6" gutterBottom>Mapa de Concentración de Incidentes</Typography>
      <Paper sx={{ height: '75vh', width: '100%' }}>
        {renderContent()}
      </Paper>
    </Box>
  );
}

export default AnalyticsPage;