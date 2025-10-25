// src/components/Analisis/ModalSeleccionExcel.jsx
import React from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogActions, Button,
  FormGroup, FormControlLabel, Checkbox, Typography, Divider, Stack
} from '@mui/material';

// Este componente gestiona la selección de hojas para el Excel
function ModalSeleccionExcel({
  open, onClose, selectedCharts, onChartSelectionChange, onConfirmDownload, sectionsConfig = {}
}) {

  const allSectionKeys = Object.keys(sectionsConfig);

  const handleCheckboxChange = (event) => {
    onChartSelectionChange({
      ...selectedCharts,
      [event.target.name]: event.target.checked,
    });
  };

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

  const selectedCount = allSectionKeys.filter(key => selectedCharts[key]).length;

  return (
    <Dialog open={open} onClose={onClose} maxWidth="xs" fullWidth>
      <DialogTitle sx={{ fontWeight: 'bold' }}>Seleccionar Contenido para Excel</DialogTitle>
      <DialogContent dividers>
        <Typography variant="body2" gutterBottom>
          Elige qué hojas de datos incluir en el informe Excel.
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

        <FormGroup sx={{ mt: 1, maxHeight: 300, overflowY: 'auto' }}>
          {allSectionKeys.map((key) => (
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
            ))}
        </FormGroup>
      </DialogContent>
      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose}>Cancelar</Button>
        <Button 
          onClick={onConfirmDownload} 
          variant="contained" 
          color="primary"
          disabled={selectedCount === 0} 
        >
          Descargar Excel
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default ModalSeleccionExcel;