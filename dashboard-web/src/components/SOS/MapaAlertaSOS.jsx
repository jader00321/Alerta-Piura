// src/components/SOS/MapaAlertaSOS.jsx
import React, { useRef, useEffect, useState, useCallback} from 'react'; // useState added
import { Paper, Typography, Box, IconButton, Tooltip, Skeleton } from '@mui/material';
import { MapContainer, TileLayer, Marker, Polyline, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import CameraAltIcon from '@mui/icons-material/CameraAlt';
import MyLocationIcon from '@mui/icons-material/MyLocation';
import html2canvas from 'html2canvas';

// Fix Iconos Leaflet
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});


// Componente para recentrar mapa
function MapRecenter({ center }) {
  const map = useMap();
  useEffect(() => {
    if (center && map) {
       map.flyTo(center, map.getZoom() > 15 ? map.getZoom() : 16, { animate: true, duration: 1 });
    }
  }, [center, map]);
  return null;
}

// Componente Mapa Principal
function MapaAlertaSOS({ alertId, locationHistory, latestLocation, alertCode, loading }) {
  // --- FIX: State to track map readiness ---
  const [isMapReady, setIsMapReady] = useState(false);
  const mapInstanceRef = useRef(null); // Ref for the Leaflet map instance

  // --- Callback ref to get the map instance ---
  const mapRefCallback = useCallback((node) => {
    // This function is called by MapContainer's 'ref' prop
    // 'node' is the Leaflet map instance
    if (node !== null) {
      console.log("Map instance obtained via callback ref:", node);
      mapInstanceRef.current = node; // Store the instance
      setIsMapReady(true); // Mark map as ready
    } else {
        // Map might be unmounting
        mapInstanceRef.current = null;
        setIsMapReady(false);
    }
  }, []); // No dependencies, this function itself doesn't change

  const handleCaptureMap = () => {
    const mapElement = mapInstanceRef.current?.getContainer();
    console.log("handleCaptureMap - Map Ready:", isMapReady, "Map Element:", mapElement); // Debug log
    if (mapElement && isMapReady) {
      // Small delay might still help ensure rendering is complete
      setTimeout(() => {
          html2canvas(mapElement, { useCORS: true, logging: false })
            .then(canvas => {
                const link = document.createElement('a');
                const fileName = `SOS_${alertCode || alertId || 'mapa'}.png`;
                link.download = fileName;
                link.href = canvas.toDataURL('image/png');
                link.click();
                console.log("Map capture successful.");
            }).catch(err => {
                console.error("Error al capturar mapa con html2canvas:", err);
                alert("No se pudo generar la captura del mapa.");
            });
      }, 300);
    } else {
        console.warn("Instancia del mapa o contenedor no encontrada/lista para captura.");
        alert("Error: El mapa no está listo o no se encontró para capturar.");
    }
  };

  const handleRecenter = () => {
    console.log("handleRecenter - Map Ready:", isMapReady, "Instance:", mapInstanceRef.current, "Location:", latestLocation); // Debug log
    if(mapInstanceRef.current && latestLocation && isMapReady) {
        mapInstanceRef.current.flyTo(latestLocation, 16, { animate: true, duration: 1 });
    } else {
        console.warn("Cannot recenter: Map instance not ready or latest location missing.");
        alert("Error: No se puede centrar el mapa.");
    }
  };

  const currentPath = locationHistory || [];

  // Reset map ready state if alert changes (map might re-render)
   useEffect(() => {
       setIsMapReady(false);
       mapInstanceRef.current = null; // Clear ref too
   }, [alertId]);

  if(loading) {
       return (
            <Paper sx={{ height: { xs: '40vh', md: '60vh' }, p: 2, display:'flex', flexDirection:'column' }}>
                 <Skeleton variant="text" width="40%"/>
                 <Skeleton variant="rectangular" width="100%" sx={{flexGrow: 1, mt:1}} />
            </Paper>
       );
  }

  return (
    <Paper sx={{ height: { xs: '40vh', md: '60vh' }, minWidth: '300px', position: 'relative', borderRadius: '12px', overflow: 'hidden' }} elevation={3}>
      {latestLocation ? (
        <MapContainer
          // --- FIX: Use callback ref instead of whenCreated ---
          ref={mapRefCallback}
          center={latestLocation} zoom={16} style={{ height: '100%' }} scrollWheelZoom={true}
        >
          <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
          {currentPath.length > 0 && <Polyline pathOptions={{ color: 'red', weight: 5 }} positions={currentPath} />}
          <Marker position={latestLocation} />
          {/* MapRecenter might not be needed if initial center works, but keep for updates */}
          <MapRecenter center={latestLocation} />
        </MapContainer>
      ) : (
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%', textAlign: 'center' }}>
          <Typography color="text.secondary">
             {alertId ? 'Esperando primera ubicación...' : 'Selecciona una alerta para ver el mapa.'}
          </Typography>
        </Box>
      )}

      {/* Controles del Mapa */}
       {latestLocation && (
         <Box sx={{ position: 'absolute', top: 10, right: 10, zIndex: 1000, display: 'flex', flexDirection: 'column', gap: 1 }}>
             <Tooltip title="Capturar Mapa">
                 {/* Disable if map not ready */}
                 <span> {/* Span needed for Tooltip on disabled button */}
                     <IconButton onClick={handleCaptureMap} disabled={!isMapReady} sx={{ bgcolor: 'rgba(29, 29, 29, 0.8)', '&:hover': { bgcolor: 'rgba(155, 155, 155, 1)' }, boxShadow: 1 }}>
                         <CameraAltIcon />
                     </IconButton>
                 </span>
             </Tooltip>
             <Tooltip title="Centrar Última Ubicación">
                 {/* Disable if map not ready */}
                  <span>
                     <IconButton onClick={handleRecenter} disabled={!isMapReady} sx={{ bgcolor: 'rgba(29, 29, 29, 0.8)', '&:hover': { bgcolor: 'rgba(155, 155, 155, 1)' }, boxShadow: 1 }}>
                         <MyLocationIcon />
                     </IconButton>
                  </span>
             </Tooltip>
         </Box>
       )}
    </Paper>
  );
}

export default MapaAlertaSOS;