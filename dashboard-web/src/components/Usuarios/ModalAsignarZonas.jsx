// src/components/Usuarios/ModalAsignarZonas.jsx
import React, { useState, useEffect } from 'react';
import {
  Dialog, DialogContent, DialogActions, Button, FormGroup,
  FormControlLabel, Checkbox, CircularProgress, Alert, FormControl, FormLabel,
  Typography, Box, Paper, Slide, useTheme, alpha, IconButton, Grid, Avatar
} from '@mui/material';
import {
  AssignmentTurnedIn as AssignmentIcon,
  LocationOn as LocationIcon,
  AdminPanelSettings as AdminIcon,
  Close as CloseIcon,
  Save as SaveIcon,
  Map as MapIcon
} from '@mui/icons-material';

import adminService from '../../services/adminService';

// Transición suave
const Transition = React.forwardRef(function Transition(props, ref) {
  return <Slide direction="up" ref={ref} {...props} />;
});

const DISTRITOS_PIURA = [
  'Piura', 'Castilla', 'Veintiséis de Octubre', 'Catacaos', 'Cura Mori',
  'El Tallán', 'La Arena', 'La Unión', 'Las Lomas', 'Tambo Grande',
];

function ModalAsignarZonas({ open, onClose, onSave, lider, isSaving }) {
  const [selectedDistritos, setSelectedDistritos] = useState({});
  const [isTodasZonas, setIsTodasZonas] = useState(false);
  const [isLoadingZonas, setIsLoadingZonas] = useState(false);
  const [error, setError] = useState(null);
  const theme = useTheme();

  useEffect(() => {
    if (open && lider) {
      setIsLoadingZonas(true);
      setError(null);
      adminService.getZonasAsignadas(lider.id)
        .then(zonas => {
          if (zonas.includes('*')) {
            setIsTodasZonas(true);
            setSelectedDistritos({});
          } else {
            const zonasMap = {};
            for (const distrito of zonas) {
              if (DISTRITOS_PIURA.includes(distrito)) zonasMap[distrito] = true;
            }
            setIsTodasZonas(false);
            setSelectedDistritos(zonasMap);
          }
        })
        .catch(() => setError("Error al cargar las zonas asignadas."))
        .finally(() => setIsLoadingZonas(false));
    }
  }, [open, lider]);

  const handleClose = () => {
    setSelectedDistritos({});
    setIsTodasZonas(false);
    setError(null);
    onClose();
  };

  const handleToggle = (distrito) => {
    if (isTodasZonas) return;
    setSelectedDistritos(prev => ({ ...prev, [distrito]: !prev[distrito] }));
  };

  const handleToggleTodas = (e) => {
    const isChecked = e.target.checked;
    setIsTodasZonas(isChecked);
    if (isChecked) setSelectedDistritos({});
  };

  const handleSave = () => {
    const distritosArray = isTodasZonas 
      ? ['*'] 
      : Object.keys(selectedDistritos).filter(key => selectedDistritos[key]);
        
    if (distritosArray.length === 0) {
      setError('Selecciona al menos una zona.');
      return;
    }
    onSave(distritosArray);
  };

  const midPoint = Math.ceil(DISTRITOS_PIURA.length / 2);
  const column1 = DISTRITOS_PIURA.slice(0, midPoint);
  const column2 = DISTRITOS_PIURA.slice(midPoint);

  return (
    <Dialog 
      open={open} 
      onClose={isSaving ? undefined : handleClose} 
      TransitionComponent={Transition}
      fullWidth 
      maxWidth="sm"
      PaperProps={{
        sx: { borderRadius: 3, overflow: 'hidden', boxShadow: theme.shadows[10] }
      }}
    >
      {/* Encabezado */}
      <Box sx={{ 
        background: `linear-gradient(135deg, ${theme.palette.secondary.main} 0%, ${theme.palette.secondary.dark} 100%)`,
        p: 3, display: 'flex', alignItems: 'center', gap: 2, color: 'white', position: 'relative'
      }}>
        <Avatar sx={{ bgcolor: 'white', color: 'secondary.main' }}>
          <MapIcon />
        </Avatar>
        <Box>
          <Typography variant="h6" fontWeight="bold">Asignación de Territorio</Typography>
          <Typography variant="caption" sx={{ opacity: 0.9 }}>
            Líder: {lider?.alias || lider?.nombre}
          </Typography>
        </Box>
        <IconButton onClick={handleClose} disabled={isSaving} sx={{ position: 'absolute', top: 8, right: 8, color: 'white' }}>
          <CloseIcon />
        </IconButton>
      </Box>
      
      <DialogContent sx={{ p: 3, minHeight: 300 }}>
        {isLoadingZonas ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
            <CircularProgress />
          </Box>
        ) : (
          <FormControl component="fieldset" variant="standard" disabled={isSaving} sx={{ width: '100%' }}>
            
            {/* Opción Premium: Todas las Zonas */}
            <Paper 
              elevation={isTodasZonas ? 4 : 0}
              sx={{ 
                border: '1px solid',
                borderColor: isTodasZonas ? 'secondary.main' : 'divider',
                borderRadius: 2, p: 2, mb: 3,
                bgcolor: isTodasZonas ? alpha(theme.palette.secondary.main, 0.05) : 'transparent',
                transition: 'all 0.3s ease',
                cursor: 'pointer',
                '&:hover': { bgcolor: alpha(theme.palette.secondary.main, 0.02) }
              }}
            >
              <FormControlLabel
                control={ <Checkbox checked={isTodasZonas} onChange={handleToggleTodas} color="secondary" /> }
                label={
                  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                    <AdminIcon color={isTodasZonas ? 'secondary' : 'action'} />
                    <Box>
                      <Typography fontWeight="bold" color={isTodasZonas ? 'secondary.main' : 'text.primary'}>
                        Modo Administrador Regional
                      </Typography>
                      <Typography variant="caption" color="text.secondary">
                        Gestiona TODOS los distritos de Piura sin restricción.
                      </Typography>
                    </Box>
                  </Box>
                }
                sx={{ width: '100%', m: 0 }}
              />
            </Paper>

            <FormLabel component="legend" sx={{ mb: 1, display: 'flex', alignItems: 'center', gap: 1 }}>
              <LocationIcon fontSize="small" /> Selección Manual de Distritos
            </FormLabel>

            <Paper variant="outlined" sx={{ p: 2, borderRadius: 2, bgcolor: isTodasZonas ? 'action.hover' : 'background.paper' }}>
              <Grid container spacing={1}>
                <Grid item xs={6}>
                  <FormGroup>
                    {column1.map((distrito) => (
                      <FormControlLabel
                        key={distrito}
                        control={ <Checkbox checked={!!selectedDistritos[distrito]} onChange={() => handleToggle(distrito)} disabled={isTodasZonas} size="small" /> }
                        label={<Typography variant="body2">{distrito}</Typography>}
                      />
                    ))}
                  </FormGroup>
                </Grid>
                <Grid item xs={6}>
                  <FormGroup>
                    {column2.map((distrito) => (
                      <FormControlLabel
                        key={distrito}
                        control={ <Checkbox checked={!!selectedDistritos[distrito]} onChange={() => handleToggle(distrito)} disabled={isTodasZonas} size="small" /> }
                        label={<Typography variant="body2">{distrito}</Typography>}
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
      
      <DialogActions sx={{ p: 3, pt: 0 }}>
        <Button onClick={handleClose} disabled={isSaving} color="inherit">Cancelar</Button>
        <Button 
          onClick={handleSave} 
          variant="contained" 
          disabled={isSaving || isLoadingZonas}
          startIcon={!isSaving && <SaveIcon />}
          sx={{ px: 4, borderRadius: 2 }}
        >
          {isSaving ? <CircularProgress size={24} color="inherit" /> : 'Guardar Cambios'}
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default ModalAsignarZonas;