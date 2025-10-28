import React, { useState, useEffect } from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogActions, Button, FormGroup,
  FormControlLabel, Checkbox, CircularProgress, Alert, FormControl, FormLabel,
  Typography, Box, Divider, DialogContentText, LinearProgress,
  Grid,
  Paper
} from '@mui/material';
import AssignmentTurnedInIcon from '@mui/icons-material/AssignmentTurnedIn';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import AdminPanelSettingsIcon from '@mui/icons-material/AdminPanelSettings';

import adminService from '../../services/adminService'; // Asegúrate que la ruta sea correcta

// Lista de distritos
const DISTRITOS_PIURA = [
  'Piura', 'Castilla', 'Veintiséis de Octubre', 'Catacaos', 'Cura Mori',
  'El Tallán', 'La Arena', 'La Unión', 'Las Lomas', 'Tambo Grande',
];

/**
 * Renderiza un modal (Dialog) para asignar zonas (distritos) a un Líder Vecinal.
 *
 * Al abrirse, este componente carga las zonas previamente asignadas al líder
 * usando `adminService.getZonasAsignadas`.
 *
 * Ofrece dos modos de asignación:
 * 1. "Asignar Todas las Zonas": Guarda un array con el comodín `['*']`.
 * 2. Selección Específica: Guarda un array con los nombres de los distritos
 * seleccionados (ej: `['Piura', 'Castilla']`).
 *
 * El estado de guardado (`isSaving`) y el de carga (`isLoadingZonas`) son
 * manejados para deshabilitar controles y mostrar indicadores de progreso.
 *
 * @param {object} props - Propiedades del componente.
 * @param {boolean} props.open - Controla si el modal está abierto.
 * @param {Function} props.onClose - Callback que se ejecuta al cerrar el modal (ej. clic en 'Cancelar' o fuera del modal).
 * @param {Function} props.onSave - Callback que se ejecuta al guardar. Recibe un array de strings con las
 * zonas seleccionadas (ej: `['Piura', 'Castilla']` o `['*']`).
 * **Nota:** Este componente *no* cierra el modal; el componente padre debe
 * manejar el cierre después de que la operación de guardado (asíncrona) termine.
 * @param {object | null} props.lider - El objeto del usuario (líder) al que se le están asignando zonas.
 * @param {string} [props.lider.id] - ID del líder, usado para cargar sus zonas.
 * @param {string} [props.lider.alias] - Alias del líder, para mostrar en el título.
 * @param {string} [props.lider.nombre] - Nombre del líder (fallback si no hay alias).
 * @param {boolean} props.isSaving - Indica si la operación de guardado (manejada por el padre)
 * está en progreso. Deshabilita botones y muestra un LinearProgress.
 * @returns {JSX.Element} El componente del modal de asignación de zonas.
 */
function ModalAsignarZonas({ open, onClose, onSave, lider, isSaving }) {
  const [selectedDistritos, setSelectedDistritos] = useState({});
  const [isTodasZonas, setIsTodasZonas] = useState(false);
  const [isLoadingZonas, setIsLoadingZonas] = useState(false);
  const [error, setError] = useState(null);

  // Cargar zonas asignadas
  useEffect(() => {
    // Solo cargar si el modal está abierto y hay un líder
    if (open && lider) {
      setIsLoadingZonas(true);
      setError(null);
      
      adminService.getZonasAsignadas(lider.id)
        .then(zonas => {
          // Si el líder tiene el comodín '*', marcar "Todas las Zonas"
          if (zonas.includes('*')) {
            setIsTodasZonas(true);
            setSelectedDistritos({});
          } else {
            // Mapear el array de zonas a un objeto de estado
            const zonasMap = {};
            for (const distrito of zonas) {
              if (DISTRITOS_PIURA.includes(distrito)) {
                zonasMap[distrito] = true;
              }
            }
            setIsTodasZonas(false);
            setSelectedDistritos(zonasMap);
          }
        })
        .catch(err => {
          console.error("Error cargando zonas asignadas:", err);
          setError("Error al cargar las zonas asignadas.");
        })
        .finally(() => {
          setIsLoadingZonas(false);
        });
    }
  }, [open, lider]); // Dependencias: se recarga si cambia el líder o si se abre

  /**
   * Limpia el estado interno y llama al callback `onClose` del padre.
   */
  const handleClose = () => {
    setSelectedDistritos({});
    setIsTodasZonas(false);
    setError(null);
    onClose();
  };

  /**
   * Manejador para los checkboxes de distritos individuales.
   * Deshabilitado si "Todas las Zonas" está activo.
   * @param {string} distrito - El nombre del distrito a marcar/desmarcar.
   */
  const handleToggle = (distrito) => {
    if (isTodasZonas) return; // No permitir selección individual si 'Todas' está activo
    setSelectedDistritos(prev => ({
      ...prev,
      [distrito]: !prev[distrito],
    }));
  };

  /**
   * Manejador para el checkbox "Todas las Zonas".
   * Si se marca, limpia las selecciones individuales.
   * @param {React.ChangeEvent<HTMLInputElement>} e - Evento del checkbox.
   */
  const handleToggleTodas = (e) => {
    const isChecked = e.target.checked;
    setIsTodasZonas(isChecked);
    if (isChecked) {
      setSelectedDistritos({}); // Limpiar selecciones específicas
    }
  };

  /**
   * Prepara los datos a guardar y llama al callback `onSave` del padre.
   * Valida que se haya seleccionado al menos una opción.
   */
  const handleSave = () => {
    setError(null);
    const distritosArray = isTodasZonas 
      ? ['*'] // Si 'Todas' está marcado, enviar el comodín
      : Object.keys(selectedDistritos).filter(key => selectedDistritos[key]); // Filtrar solo los true
        
    // Validar que se haya seleccionado algo
    if (distritosArray.length === 0) {
      setError('Debes seleccionar al menos una zona o marcar "Todas las Zonas".');
      return;
    }
    
    // Llama al onSave del padre, pasando el array de zonas.
    onSave(distritosArray);
  };

  // --- Helpers de Renderizado ---
  const hasSpecificSelection = Object.values(selectedDistritos).some(val => val === true) && !isTodasZonas;
  const midPoint = Math.ceil(DISTRITOS_PIURA.length / 2);
  const column1 = DISTRITOS_PIURA.slice(0, midPoint);
  const column2 = DISTRITOS_PIURA.slice(midPoint);

  return (
    <Dialog open={open} onClose={isSaving ? () => {} : handleClose} fullWidth maxWidth="sm">
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <AssignmentTurnedInIcon />
        Asignar Zonas a {lider?.alias || lider?.nombre}
      </DialogTitle>
      
      <DialogContent dividers sx={{ minHeight: '350px', bgcolor: 'background.default' }}>
        {/* Indicador de guardado (controlado por el padre) */}
        {isSaving && <LinearProgress sx={{ position: 'absolute', top: 0, left: 0, right: 0 }} />}
        
        {/* Indicador de carga (controlado internamente) */}
        {isLoadingZonas ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '300px' }}>
            <CircularProgress />
          </Box>
        ) : (
          <FormControl component="fieldset" variant="standard" disabled={isSaving} sx={{ width: '100%' }}>
            
            <DialogContentText sx={{ mb: 2 }}>
              Gestiona las zonas (distritos) que este líder podrá moderar.
            </DialogContentText>
            
            {/* Opción "Asignar Todas" */}
            <Paper 
              elevation={0} 
              sx={{ 
                border: '1px solid', 
                borderColor: isTodasZonas ? 'secondary.main' : 'divider',
                borderRadius: 1.5, p: 1.5, mb: 2,
                bgcolor: isTodasZonas ? 'secondary.light' : 'transparent',
                transition: 'all 0.3s ease',
              }}
            >
              <FormGroup>
                <FormControlLabel
                  control={ <Checkbox checked={isTodasZonas} onChange={handleToggleTodas} name="*" color="secondary" /> }
                  label={
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                      <AdminPanelSettingsIcon fontSize="small" />
                      <Typography fontWeight="bold" color={isTodasZonas ? 'secondary.dark' : 'text.primary'}>
                        Asignar Todas las Zonas (Nivel Admin)
                      </Typography>
                    </Box>
                  }
                />
              </FormGroup>
            </Paper>

            {/* Label "O seleccionar" */}
            <FormLabel 
              component="legend" 
              sx={{ 
                mb: 1.5, mt: 1, display: 'flex', alignItems: 'center', gap: 0.5,
                fontSize: '1rem',
                fontWeight: hasSpecificSelection ? 'bold' : 'normal',
                color: hasSpecificSelection ? 'primary.main' : 'text.secondary',
                transition: 'all 0.3s ease',
              }}
            >
              <LocationOnIcon fontSize="small" />
              O seleccionar distritos específicos:
            </FormLabel>

            {/* Lista de Distritos en 2 columnas */}
            <Paper 
              variant="outlined" 
              sx={{ p: 2, pt: 1, borderRadius: 1.5, maxHeight: '250px', overflowY: 'auto', bgcolor: 'background.paper' }}
            >
              <Grid container spacing={1}>
                <Grid item xs={6}>
                  <FormGroup>
                    {column1.map((distrito) => (
                      <FormControlLabel
                        key={distrito}
                        sx={{ '& .Mui-disabled': { color: 'text.disabled' } }}
                        control={ <Checkbox checked={selectedDistritos[distrito] || false} onChange={() => handleToggle(distrito)} name={distrito} disabled={isTodasZonas} /> }
                        label={distrito}
                      />
                    ))}
                  </FormGroup>
                </Grid>
                <Grid item xs={6}>
                  <FormGroup>
                    {column2.map((distrito) => (
                      <FormControlLabel
                        key={distrito}
                        sx={{ '& .Mui-disabled': { color: 'text.disabled' } }}
                        control={ <Checkbox checked={selectedDistritos[distrito] || false} onChange={() => handleToggle(distrito)} name={distrito} disabled={isTodasZonas} /> }
                        label={distrito}
                      />
                    ))}
                  </FormGroup>
                </Grid>
              </Grid>
            </Paper>
          </FormControl>
        )}
        {error && <Alert severity="error" sx={{ mt: 2 }}>{error}</Alert>}
      </DialogContent>
      
      <DialogActions sx={{ p: '16px 24px' }}>
        <Button onClick={handleClose} disabled={isSaving}>Cancelar</Button>
        <Button onClick={handleSave} variant="contained" disabled={isSaving || isLoadingZonas}>
          {isSaving ? <CircularProgress size={24} color="inherit" /> : 'Guardar Zonas'}
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default ModalAsignarZonas;