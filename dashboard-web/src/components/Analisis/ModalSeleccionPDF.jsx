// src/components/Analisis/ModalSeleccionPDF.jsx
import React from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogActions, Button,
  FormGroup, FormControlLabel, Checkbox, Typography, Divider, Stack
} from '@mui/material';

/**
 * Modal para seleccionar las secciones que se incluirán en la generación de un archivo PDF.
 *
 * Permite marcar y desmarcar todas las opciones disponibles, así como gestionar la selección
 * de forma individual a través de checkboxes.
 *
 * @component
 * @example
 * const [open, setOpen] = useState(true);
 * const [selectedCharts, setSelectedCharts] = useState({ resumen: true, detalle: false });
 * const sectionsConfig = {
 *   resumen: { title: "Resumen de Actividades" },
 *   detalle: { title: "Detalle de Reportes" },
 * };
 *
 * return (
 *   <ModalSeleccionPDF
 *     open={open}
 *     onClose={() => setOpen(false)}
 *     selectedCharts={selectedCharts}
 *     onChartSelectionChange={setSelectedCharts}
 *     onConfirmDownload={() => console.log("Descargando PDF...")}
 *     sectionsConfig={sectionsConfig}
 *   />
 * );
 *
 * @param {Object} props - Propiedades del componente.
 * @param {boolean} props.open - Controla si el modal está visible.
 * @param {Function} props.onClose - Función que cierra el modal.
 * @param {Object.<string, boolean>} props.selectedCharts - Estado que indica qué secciones están seleccionadas.
 * @param {Function} props.onChartSelectionChange - Función que actualiza la selección de secciones.
 * @param {Function} props.onConfirmDownload - Función que se ejecuta al confirmar la descarga del PDF.
 * @param {Object.<string, {title: string}>} [props.sectionsConfig={}] - Configuración de las secciones disponibles, donde cada clave representa una sección y su valor contiene metadatos como el título.
 *
 * @returns {JSX.Element} Modal de selección de secciones para exportar a PDF.
 */
function ModalSeleccionPDF({
  open, onClose, selectedCharts, onChartSelectionChange, onConfirmDownload, sectionsConfig = {}
}) {
  // Obtiene las claves de la configuración
  const allSectionKeys = Object.keys(sectionsConfig);

  /**
   * Maneja el cambio individual de cada checkbox.
   * @param {React.ChangeEvent<HTMLInputElement>} event - Evento del checkbox.
   */
  const handleCheckboxChange = (event) => {
    onChartSelectionChange({
      ...selectedCharts,
      [event.target.name]: event.target.checked,
    });
  };

  /** Marca todas las secciones como seleccionadas. */
  const handleSelectAll = () => {
    const newSelection = {};
    allSectionKeys.forEach(key => {
      newSelection[key] = true;
    });
    onChartSelectionChange(newSelection);
  };

  /** Desmarca todas las secciones. */
  const handleDeselectAll = () => {
    const newSelection = {};
    allSectionKeys.forEach(key => {
      newSelection[key] = false;
    });
    onChartSelectionChange(newSelection);
  };

  /** Número total de secciones actualmente seleccionadas. */
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

        {/* Lista dinámica basada en sectionsConfig */}
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
                label={sectionsConfig[key].title}
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
          disabled={selectedCount === 0}
        >
          Descargar
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default ModalSeleccionPDF;
