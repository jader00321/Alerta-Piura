import React from 'react';
import { Dialog, DialogTitle, DialogContent, DialogActions, Button, Typography, Box, Grid, Chip, Divider } from '@mui/material';
import { MapContainer, TileLayer, Marker } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

// Fix for a known issue with react-leaflet's default icon paths
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});

// Helper function to get color for urgency level
const getUrgencyChip = (urgency) => {
  if (!urgency) return null;
  
  let color = 'default';
  if (urgency === 'Alta') color = 'error';
  if (urgency === 'Media') color = 'warning';
  if (urgency === 'Baja') color = 'success';

  return <Chip label={`Urgencia: ${urgency}`} color={color} size="small" />;
};


function ReportDetailModal({ report, open, onClose, onAction }) {
  if (!report) return null;

  const locationCoords = (report.location && report.location.coordinates)
    ? [report.location.coordinates[1], report.location.coordinates[0]]
    : [-5.19449, -80.63282]; // Default to Piura center

  const handleAction = (approve) => {
    onAction(report.id, approve);
    onClose();
  };

  return (
    <Dialog open={open} onClose={onClose} fullWidth maxWidth="md"> 
      <DialogTitle>
        Detalle del Reporte #{report.id}
        {report.codigo_reporte && <Typography variant="caption" fontSize="16px" color="text.secondary"> ({report.codigo_reporte})</Typography>}
      </DialogTitle>
      <DialogContent dividers>
        <Grid container spacing={2}>
          <Grid item xs={12} md={6}>
            <Box sx={{ p: 1 }}>
              <Typography variant="subtitle2" color="text.secondary" sx={{ mb: 1 }}>Imagen del Reporte</Typography>
              {report.foto_url ? (
                <Box 
                  component="img" 
                  src={report.foto_url} 
                  alt="Imagen del reporte" 
                  sx={{ width: '100%', maxHeight: 250, objectFit: 'contain', borderRadius: 2, mb: 2, bgcolor: 'rgba(0,0,0,0.2)' }} 
                />
              ) : (
                <Box sx={{ height: 250, width: '100%', bgcolor: 'grey.900', display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: 2, mb: 2 }}>
                  <Typography color="text.secondary" variant="body2">Sin Imagen</Typography>
                </Box>
              )}
              
              <Typography variant="subtitle2" color="text.secondary" sx={{ mb: 1 }}>Ubicación</Typography>
              <Box sx={{ height: '300px', width: '100%', borderRadius: 2, overflow: 'hidden' }}>
                <MapContainer 
                  center={locationCoords} 
                  zoom={16} 
                  style={{ height: '100%', width: '100%' }}
                  key={report.id}
                >
                  <TileLayer
                    attribution='&copy; OpenStreetMap'
                    url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                  />
                  <Marker position={locationCoords} />
                </MapContainer>
              </Box>
            </Box>
          </Grid>

          <Grid item md={0.5} sx={{ display: { xs: 'none', md: 'flex' }, justifyContent: 'center' }}>
            <Divider orientation="vertical" />
          </Grid>

          <Grid item xs={12} md={5.5}>
            <Box sx={{ p: 1, height: '100%', display: 'flex', flexDirection: 'column' }}>
              <Typography variant="h5" gutterBottom sx={{ fontWeight: 'bold' }}>{report.titulo}</Typography>
              
              <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, mb: 2 }}>
                <Chip label={report.categoria} color="primary" size="small" />
                {getUrgencyChip(report.urgencia)}
              </Box>
              
              <Typography variant="body2" color="text.secondary">Descripción:</Typography>
              <Typography variant="body1" paragraph sx={{ flexGrow: 0.1 }}>
                {report.descripcion || 'No se proporcionó descripción.'}
              </Typography>
              
              <Divider sx={{ my: 1 }} />
              
              <Typography variant="h6" gutterBottom>Detalles Adicionales</Typography>
              <Typography variant="body2"><strong>Distrito:</strong> {report.distrito || 'No especificado'}</Typography>
              <Typography variant="body2"><strong>Referencia:</strong> {report.referencia_ubicacion || 'No especificado'}</Typography>
              <Typography variant="body2"><strong>Hora del Incidente:</strong> {report.hora_incidente || 'No especificada'}</Typography>
              <Typography variant="body2"><strong>Impacto:</strong> {report.impacto || 'No especificado'}</Typography>
              <Typography variant="body2"><strong>Tags:</strong> {report.tags && report.tags.length > 0 ? report.tags.join(', ') : 'Ninguna'}</Typography>

              <Divider sx={{ my: 2 }} />

              <Typography variant="h6" gutterBottom>Detalles del Usuario</Typography>
              <Typography variant="body2"><strong>Autor:</strong> {report.autor_nombre}</Typography>
              <Typography variant="body2"><strong>Email:</strong> {report.autor_email}</Typography>
              <Typography variant="body2"><strong>Teléfono:</strong> {report.autor_telefono || 'No proporcionado'}</Typography>
              
              <Divider sx={{ my: 2 }} />
              
              <Typography variant="body2" color="text.secondary">
                <strong>Fecha del Reporte:</strong> {report.fecha_creacion}
              </Typography>
            </Box>
          </Grid>
        </Grid>
      </DialogContent>
      <DialogActions sx={{ p: 2, justifyContent: 'space-between' }}>
        <Box>
            <Chip label={report.estado.replace('_', ' ')} size="small" color={report.estado === 'pendiente_verificacion' ? 'warning' : 'default'} />
        </Box>
        <Box>
            <Button onClick={onClose}>Cerrar</Button>
            <Button variant="contained" color="error" onClick={() => handleAction(false)} sx={{ mx: 1 }}>Rechazar</Button>
            <Button variant="contained" color="success" onClick={() => handleAction(true)}>Aprobar</Button>
        </Box>
      </DialogActions>
    </Dialog>
  );
}

export default ReportDetailModal;