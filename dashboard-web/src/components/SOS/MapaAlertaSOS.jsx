import React, { useRef, useEffect, useState, useCallback} from 'react'; // useState added
import { Paper, Typography, Box, IconButton, Tooltip, Skeleton } from '@mui/material';
import { MapContainer, TileLayer, Marker, Polyline, useMap } from 'react-leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import CameraAltIcon from '@mui/icons-material/CameraAlt';
import MyLocationIcon from '@mui/icons-material/MyLocation';
import html2canvas from 'html2canvas';

// --- Fix Iconos Leaflet ---
// Resuelve un problema común con bundlers (como Webpack) donde las URLs
// de los íconos por defecto de Leaflet no se cargan correctamente.
delete L.Icon.Default.prototype._getIconUrl;
L.Icon.Default.mergeOptions({
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon-2x.png',
  iconUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-icon.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.7.1/dist/images/marker-shadow.png',
});


/**
 * Componente interno para re-centrar el mapa de forma animada (flyTo).
 * Utiliza el hook `useMap()` de react-leaflet para obtener la instancia del mapa.
 * Se activa cuando la prop `center` cambia.
 * @param {object} props - Propiedades del componente.
 * @param {Array<number>} props.center - Las coordenadas [lat, lng] a las que volar.
 * @returns {null} Este componente no renderiza nada.
 */
function MapRecenter({ center }) {
  const map = useMap();
  useEffect(() => {
    if (center && map) {
       // Vuela al centro, asegurando un zoom mínimo de 16
       map.flyTo(center, map.getZoom() > 15 ? map.getZoom() : 16, { animate: true, duration: 1 });
    }
  }, [center, map]);
  return null;
}

// --- Componente Mapa Principal ---

/**
 * Componente principal que renderiza un mapa de Leaflet para una alerta SOS.
 *
 * Muestra la última ubicación (`latestLocation`) con un <Marker> y
 * el historial de ubicaciones (`locationHistory`) con una <Polyline>.
 *
 * Maneja 3 estados:
 * 1. Carga (`loading`=true): Muestra un <Skeleton>.
 * 2. Sin ubicación (`latestLocation`=null): Muestra un mensaje de espera o "Selecciona alerta".
 * 3. Mapa visible: Muestra el <MapContainer> de Leaflet.
 *
 * Incluye controles (flotantes sobre el mapa) para:
 * - Capturar el mapa como imagen PNG (usando html2canvas).
 * - Re-centrar el mapa en la última ubicación.
 *
 * Utiliza un `useCallback` ref (`mapRefCallback`) para obtener la instancia
 * del mapa de Leaflet de forma segura y un estado `isMapReady` para
 * habilitar los controles solo cuando el mapa esté listo.
 *
 * @param {object} props - Propiedades del componente.
 * @param {string|number} props.alertId - ID de la alerta activa. Usado para resetear el estado del mapa si cambia.
 * @param {Array<Array<number>>} [props.locationHistory] - Array de coordenadas `[lat, lng]` que forman la Polyline.
 * @param {Array<number>} [props.latestLocation] - La última coordenada `[lat, lng]` para el Marker y el centrado inicial.
 * @param {string} [props.alertCode] - El código de la alerta (ej: 'SOS-123'), usado para nombrar el archivo de captura.
 * @param {boolean} props.loading - Si es true, muestra un Skeleton en lugar del mapa.
 * @returns {JSX.Element} El componente del mapa en un <Paper>.
 */
function MapaAlertaSOS({ alertId, locationHistory, latestLocation, alertCode, loading }) {
  // --- FIX: State to track map readiness ---
  const [isMapReady, setIsMapReady] = useState(false);
  const mapInstanceRef = useRef(null); // Ref for the Leaflet map instance

  /**
   * Callback ref asignado al prop `ref` del `MapContainer`.
   * Se ejecuta cuando el componente de mapa se monta (proporciona la instancia)
   * o se desmonta (proporciona null).
   * Almacena la instancia del mapa de Leaflet en `mapInstanceRef`
   * y actualiza el estado `isMapReady`.
   * @param {L.Map | null} node - La instancia del mapa de Leaflet o null.
   */
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

  /**
   * Manejador para el botón de captura de pantalla.
   * Utiliza `html2canvas` sobre el contenedor del mapa (obtenido de `mapInstanceRef`).
   * Descarga el resultado como un PNG.
   */
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
      }, 300); // 300ms de retraso para asegurar renderizado de tiles
    } else {
        console.warn("Instancia del mapa o contenedor no encontrada/lista para captura.");
        alert("Error: El mapa no está listo o no se encontró para capturar.");
    }
  };

  /**
   * Manejador para el botón de re-centrar.
   * Llama a `flyTo` en la instancia del mapa para centrarse
   * en la `latestLocation` con un zoom fijo.
   */
  const handleRecenter = () => {
    console.log("handleRecenter - Map Ready:", isMapReady, "Instance:", mapInstanceRef.current, "Location:", latestLocation); // Debug log
    if(mapInstanceRef.current && latestLocation && isMapReady) {
        mapInstanceRef.current.flyTo(latestLocation, 16, { animate: true, duration: 1 });
    } else {
        console.warn("Cannot recenter: Map instance not ready or latest location missing.");
        alert("Error: No se puede centrar el mapa.");
    }
  };

  // Define el path para la Polyline
  const currentPath = locationHistory || [];

  // Resetea el estado de 'mapReady' si la alerta (ID) cambia,
  // forzando a la UI a esperar la nueva instancia del mapa.
   useEffect(() => {
       setIsMapReady(false);
       mapInstanceRef.current = null; // Clear ref too
   }, [alertId]);

  // --- Estado de Carga ---
  if(loading) {
       return (
           <Paper sx={{ height: { xs: '40vh', md: '60vh' }, p: 2, display:'flex', flexDirection:'column' }}>
               <Skeleton variant="text" width="40%"/>
               <Skeleton variant="rectangular" width="100%" sx={{flexGrow: 1, mt:1}} />
           </Paper>
       );
  }

  // --- Renderizado Principal ---
  return (
    <Paper sx={{ height: { xs: '40vh', md: '60vh' }, minWidth: '300px', position: 'relative', borderRadius: '12px', overflow: 'hidden' }} elevation={3}>
      {/* --- Estado con Ubicación (Mapa) --- */}
      {latestLocation ? (
        <MapContainer
          // --- FIX: Use callback ref instead of whenCreated ---
          ref={mapRefCallback}
          center={latestLocation} zoom={16} style={{ height: '100%' }} scrollWheelZoom={true}
        >
          <TileLayer url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png" />
          {/* Historial de ruta */}
          {currentPath.length > 0 && <Polyline pathOptions={{ color: 'red', weight: 5 }} positions={currentPath} />}
          {/* Última ubicación */}
          <Marker position={latestLocation} />
          {/* Componente de re-centrado automático */}
          <MapRecenter center={latestLocation} />
        </MapContainer>
      ) : (
        // --- Estado Vacío / Sin Ubicación ---
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%', textAlign: 'center' }}>
          <Typography color="text.secondary">
             {alertId ? 'Esperando primera ubicación...' : 'Selecciona una alerta para ver el mapa.'}
          </Typography>
        </Box>
      )}

      {/* --- Controles del Mapa (flotantes) --- */}
       {latestLocation && (
         <Box sx={{ position: 'absolute', top: 10, right: 10, zIndex: 1000, display: 'flex', flexDirection: 'column', gap: 1 }}>
             <Tooltip title="Capturar Mapa">
                 {/* Deshabilitar si el mapa no está listo */}
                 <span> {/* Span necesario para Tooltip en botón deshabilitado */}
                     <IconButton onClick={handleCaptureMap} disabled={!isMapReady} sx={{ bgcolor: 'rgba(29, 29, 29, 0.8)', '&:hover': { bgcolor: 'rgba(155, 155, 155, 1)' }, boxShadow: 1 }}>
                         <CameraAltIcon />
                     </IconButton>
                 </span>
             </Tooltip>
             <Tooltip title="Centrar Última Ubicación">
                 {/* Deshabilitar si el mapa no está listo */}
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