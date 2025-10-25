// src/components/Categorias/ModalFusionarSugerencia.jsx
import React, { useState, useEffect } from 'react';
import {
  Dialog, DialogTitle, DialogContent, DialogActions, Button, Typography, Box,
  FormControl, InputLabel, Select, MenuItem, CircularProgress, Alert
} from '@mui/material';
import MergeTypeIcon from '@mui/icons-material/MergeType';

function ModalFusionarSugerencia({ open, onClose, suggestion, categories, onConfirm, loading }) {
  const [targetCategoryId, setTargetCategoryId] = useState('');

  // Resetear target al abrir/cambiar sugerencia
  useEffect(() => {
    if (open) {
      setTargetCategoryId('');
    }
  }, [open, suggestion]);

  const handleConfirmClick = () => {
    if (targetCategoryId) {
      onConfirm(suggestion?.categoria_sugerida, targetCategoryId);
    }
  };

  // Filtrar categorías para no incluir "Otro" como destino
  const availableCategories = categories.filter(c => c.nombre.toLowerCase() !== 'otro');

  return (
    <Dialog open={open} onClose={loading ? () => {} : onClose} fullWidth maxWidth="sm">
      <DialogTitle sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
        <MergeTypeIcon color="primary"/> Fusionar Sugerencia
      </DialogTitle>
      <DialogContent dividers>
        <Alert severity='warning' sx={{mb: 2}}>
            Estás a punto de reclasificar todos los reportes ({suggestion?.count || 0}) sugeridos como
            <strong>"{suggestion?.categoria_sugerida}"</strong>.
        </Alert>
        <Typography paragraph>
            Selecciona la categoría oficial existente donde quieres mover estos reportes. La sugerencia desaparecerá después de la fusión.
        </Typography>
        <FormControl fullWidth margin="dense" required>
            <InputLabel>Categoría Oficial de Destino</InputLabel>
            <Select
                value={targetCategoryId}
                onChange={(e) => setTargetCategoryId(e.target.value)}
                label="Categoría Oficial de Destino"
                disabled={loading}
            >
                {/* Opcional: Deshabilitar si no hay categorías disponibles */}
                 {availableCategories.length === 0 && <MenuItem disabled>No hay categorías de destino</MenuItem>}
                {availableCategories.map(cat => (
                    <MenuItem key={cat.id} value={cat.id}>{cat.nombre}</MenuItem>
                ))}
            </Select>
        </FormControl>
      </DialogContent>
      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose} disabled={loading}> Cancelar </Button>
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