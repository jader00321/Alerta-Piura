// src/components/Analisis/ModalSeleccionExcel.jsx
import React from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogActions, Button,
  FormGroup, FormControlLabel, Checkbox, Typography, Divider, Stack
} from '@mui/material';

/**
 * Modal que permite seleccionar qué secciones o gráficos incluir
 * en la exportación de un archivo Excel.
 *
 * Incluye opciones para marcar o desmarcar todos los elementos y
 * controla la lógica de selección mediante checkboxes.
 *
 * @component
 * @example
 * const [open, setOpen] = useState(true);
 * const [selectedCharts, setSelectedCharts] = useState({ grafico1: true, grafico2: false });
 * const sectionsConfig = {
 *   grafico1: { title: "Tendencia de Ventas" },
 *   grafico2: { title: "Distribución por Región" },
 * };
 *
 * return (
 *   <ModalSeleccionExcel
 *     open={open}
 *     onClose={() => setOpen(false)}
 *     selectedCharts={selectedCharts}
 *     onChartSelectionChange={setSelectedCharts}
 *     onConfirmDownload={() => console.log("Descargar Excel")}
 *     sectionsConfig={sectionsConfig}
 *   />
 * );
 *
 * @param {Object} props - Propiedades del componente.
 * @param {boolean} props.open - Controla si el modal está abierto.
 * @param {Function} props.onClose - Función para cerrar el modal.
 * @param {Object.<string, boolean>} props.selectedCharts - Objeto con el estado de selección de cada sección.
 * @param {Function} props.onChartSelectionChange - Callback que actualiza el estado de selección.
 * @param {Function} props.onConfirmDownload - Callback que se ejecuta al confirmar la descarga.
 * @param {Object.<string, {title: string}>} [props.sectionsConfig={}] - Configuración de las secciones, donde cada clave representa una hoja o gráfico, y su valor contiene metadatos (como `title`).
 *
 * @returns {JSX.Element} Modal de selección de secciones para exportar a Excel.
 */
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
              label={sectionsConfig[key].title}
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
