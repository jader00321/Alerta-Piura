// src/components/Categorias/ModalFusionarSugerencia.jsx
import React, { useState, useEffect } from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogActions, Button, Typography, Box,
  FormControl, InputLabel, Select, MenuItem, CircularProgress, Alert
} from '@mui/material';
import MergeTypeIcon from '@mui/icons-material/MergeType';

/**
 * Componente modal que permite fusionar una sugerencia de categoría con una categoría oficial existente.
 * Se utiliza principalmente para reclasificar reportes que fueron sugeridos bajo una categoría no oficial.
 *
 * @component
 * @param {Object} props - Propiedades del componente.
 * @param {boolean} props.open - Controla si el modal está visible.
 * @param {Function} props.onClose - Función para cerrar el modal.
 * @param {Object} props.suggestion - Objeto con información de la sugerencia a fusionar.
 * @param {string} props.suggestion.categoria_sugerida - Nombre de la categoría sugerida.
 * @param {number} [props.suggestion.count] - Número de reportes asociados a la sugerencia.
 * @param {Array<{id: string|number, nombre: string}>} props.categories - Lista de categorías disponibles.
 * @param {Function} props.onConfirm - Callback que se ejecuta al confirmar la fusión.
 * @param {boolean} props.loading - Indica si la fusión está en proceso (bloquea inputs y muestra spinner).
 *
 * @returns {JSX.Element} Un cuadro de diálogo con formulario para seleccionar la categoría de destino.
 *
 * @example
 * <ModalFusionarSugerencia
 *   open={true}
 *   onClose={() => setOpen(false)}
 *   suggestion={{ categoria_sugerida: "Limpieza", count: 12 }}
 *   categories={[{ id: 1, nombre: "Residuos" }, { id: 2, nombre: "Seguridad" }]}
 *   onConfirm={(origen, destino) => console.log(origen, destino)}
 *   loading={false}
 * />
 */
function ModalFusionarSugerencia({ open, onClose, suggestion, categories, onConfirm, loading }) {
  
  /**
   * Estado local que almacena la categoría oficial seleccionada como destino de la fusión.
   * @type {[string, Function]}
   */
  const [targetCategoryId, setTargetCategoryId] = useState('');

  /**
   * Efecto que limpia la selección de categoría destino cada vez que se abre el modal
   * o cambia la sugerencia activa.
   */
  useEffect(() => {
    if (open) {
      setTargetCategoryId('');
    }
  }, [open, suggestion]);

  /**
   * Maneja el clic en el botón de confirmación.
   * Llama al callback `onConfirm` con el nombre de la categoría sugerida y el ID de la categoría destino.
   * @function
   * @returns {void}
   */
  const handleConfirmClick = () => {
    if (targetCategoryId) {
      onConfirm(suggestion?.categoria_sugerida, targetCategoryId);
    }
  };

  /**
   * Lista de categorías disponibles para seleccionar como destino de fusión.
   * Se excluye la categoría "Otro" para evitar reclasificaciones ambiguas.
   * @constant
   * @type {Array<{id: string|number, nombre: string}>}
   */
  const availableCategories = categories.filter(c => c.nombre.toLowerCase() !== 'otro');
  // RENDER PRINCIPAL DEL MODAL
  return (
    <Dialog open={open} onClose={loading ? () => {} : onClose} fullWidth maxWidth="sm">
      {/* Título del modal con ícono */}
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <MergeTypeIcon color="primary"/> Fusionar Sugerencia
      </DialogTitle>

      {/* Contenido del modal */}
      <DialogContent dividers>
        <Alert severity='warning' sx={{mb: 2}}>
          Estás a punto de reclasificar todos los reportes ({suggestion?.count || 0}) sugeridos como 
          <strong> "{suggestion?.categoria_sugerida}"</strong>.
        </Alert>

        <Typography paragraph>
          Selecciona la categoría oficial existente donde quieres mover estos reportes. 
          La sugerencia desaparecerá después de la fusión.
        </Typography>

        {/* Selector de categoría destino */}
        <FormControl fullWidth margin="dense" required>
          <InputLabel>Categoría Oficial de Destino</InputLabel>
          <Select
            value={targetCategoryId}
            onChange={(e) => setTargetCategoryId(e.target.value)}
            label="Categoría Oficial de Destino"
            disabled={loading}
          >
            {/* Si no hay categorías disponibles */}
            {availableCategories.length === 0 && (
              <MenuItem disabled>No hay categorías de destino</MenuItem>
            )}

            {/* Opciones válidas */}
            {availableCategories.map(cat => (
              <MenuItem key={cat.id} value={cat.id}>{cat.nombre}</MenuItem>
            ))}
          </Select>
        </FormControl>
      </DialogContent>

      {/* Botones de acción */}
      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose} disabled={loading}>Cancelar</Button>
        <Button
          onClick={handleConfirmClick}
          variant="contained"
          disabled={!targetCategoryId || loading}
          startIcon={loading ? <CircularProgress size={16} color="inherit"/> : null}
        >
          {loading ? 'Fusionando...' : 'Confirmar Fusión'}
        </Button>
      </DialogActions>
    </Dialog>
  );
}

export default ModalFusionarSugerencia;
