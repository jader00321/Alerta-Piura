import React, { useEffect, useState } from 'react';
import { Box, Paper, Typography, CircularProgress } from '@mui/material';
import { MapContainer, TileLayer, Marker } from 'react-leaflet';
import MarkerClusterGroup from '@changey/react-leaflet-markercluster'; // <-- IMPORT NEW PACKAGE
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import '@changey/react-leaflet-markercluster/dist/styles.min.css'; // CSS for the new cluster
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

  useEffect(() => {
    // We can reuse the getHeatmapData endpoint as it provides the lat/lon
    adminService.getHeatmapData()
      .then(data => {
        const points = data.map(p => new L.LatLng(p[0], p[1]));
        setReportPoints(points);
        setLoading(false);
      })
      .catch(err => {
        console.error(err);
        setLoading(false);
      });
  }, []);

  const piuraCenter = [-5.19449, -80.63282];

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Análisis de Incidentes
      </Typography>
      
      <Typography variant="h6" gutterBottom>Mapa de Concentración de Incidentes</Typography>
      <Paper sx={{ height: '75vh', width: '100%' }}>
        {loading ? <CircularProgress /> : (
          <MapContainer center={piuraCenter} zoom={13} style={{ height: '100%', width: '100%' }}>
            <TileLayer
              url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
              attribution='&copy; OpenStreetMap'
            />
            {/* --- USE THE NEW CLUSTER GROUP --- */}
            <MarkerClusterGroup>
              {reportPoints.map((point, index) => (
                <Marker key={index} position={point} />
              ))}
            </MarkerClusterGroup>
          </MapContainer>
        )}
      </Paper>
    </Box>
  );
}

export default AnalyticsPage;