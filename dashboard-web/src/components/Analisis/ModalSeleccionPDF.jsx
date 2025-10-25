// src/components/Analisis/ModalSeleccionPDF.jsx
import React from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogActions, Button,
  FormGroup, FormControlLabel, Checkbox, Typography, Divider, Stack
} from '@mui/material';

function ModalSeleccionPDF({
  open, onClose, selectedCharts, onChartSelectionChange, onConfirmDownload, sectionsConfig = {}
}) {

  // Obtiene las claves de la configuración
  const allSectionKeys = Object.keys(sectionsConfig);

  const handleCheckboxChange = (event) => {
    onChartSelectionChange({
      ...selectedCharts,
      [event.target.name]: event.target.checked,
    });
  };

  // Handlers para seleccionar/deseleccionar todo
  const handleSelectAll = () => {
    const newSelection = {};
    allSectionKeys.forEach(key => {
      newSelection[key] = true;
    });
    onChartSelectionChange(newSelection);
  };

  const handleDeselectAll = () => {
    const newSelection = {};
    allSectionKeys.forEach(key => {
      newSelection[key] = false;
    });
    onChartSelectionChange(newSelection);
  };

  // --- LÓGICA DEL CONTADOR (Se mantiene para deshabilitar el botón) ---
  const selectedCount = allSectionKeys.filter(key => selectedCharts[key]).length;

  return (
    <Dialog open={open} onClose={onClose} maxWidth="xs" fullWidth>
      <DialogTitle sx={{ fontWeight: 'bold' }}>Seleccionar Contenido para PDF</DialogTitle>
      <DialogContent dividers>
        <Typography variant="body2" gutterBottom>
          Elige qué secciones incluir en el informe PDF generado.
        </Typography>
        
        <Stack direction="row" spacing={1} sx={{ my: 1 }}>
            <Button size="small" variant="outlined" onClick={handleSelectAll}>
              Marcar Todo
            </Button>
            <Button size="small" variant="outlined" onClick={handleDeselectAll} disabled={selectedCount === 0}>
              Desmarcar Todo
            </Button>
        </Stack>
        <Divider sx={{ mb: 1 }} />

        {/* Lista Dinámica basada en sectionsConfig */}
        <FormGroup sx={{ mt: 1, maxHeight: 300, overflowY: 'auto' }}>
          {allSectionKeys.length > 0 ? (
            allSectionKeys.map((key) => (
              <FormControlLabel
                key={key}
                control={
                  <Checkbox
                    checked={selectedCharts[key] ?? false} 
                    onChange={handleCheckboxChange}
                    name={key}
                  />
                }
                label={sectionsConfig[key].title} // Usa el título de la config
              />
            ))
          ) : (
            <Typography variant="body2" color="text.secondary">
              No hay secciones configuradas para exportar.
            </Typography>
          )}
        </FormGroup>
      </DialogContent>
      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose}>Cancelar</Button>
        <Button 
          onClick={onConfirmDownload} 
          variant="contained" 
          color="primary"
          // La lógica de deshabilitar se mantiene
          disabled={selectedCount === 0} 
        >
          {/* --- MODIFICADO: Texto del botón sin contador --- */}
          Descargar
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default ModalSeleccionPDF;