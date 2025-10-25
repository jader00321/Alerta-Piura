// src/pages/PaginaCategorias.jsx
import React, { useEffect, useState, useCallback } from 'react';
import { Box, Typography, Grid, Alert, AlertTitle, CircularProgress, Stack} from '@mui/material'; // Quitamos imports no usados
import { DragIndicator as DragIndicatorIcon, InfoOutlined as InfoIcon } from '@mui/icons-material'; // Iconos necesarios

import adminService from '../services/adminService';

// --- Importar Componentes ---
import PanelSugerencias from '../components/Categorias/PanelSugerencias';
import FormularioCrearCategoria from '../components/Categorias/FormularioCrearCategoria';
import ListaCategoriasOficiales from '../components/Categorias/ListaCategoriasOficiales';
import ModalFusionarSugerencia from '../components/Categorias/ModalFusionarSugerencia';
import ModalConfirmacion from '../components/Comunes/ModalConfirmacion'; // Importar modal genérico

function PaginaCategorias() {
  const [suggestions, setSuggestions] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [loadingAction, setLoadingAction] = useState(false); // Loading para acciones específicas (crear, fusionar, aprobar)
  const [error, setError] = useState(''); // Para errores generales

  // Estados de Modales
  const [mergeModal, setMergeModal] = useState({ open: false, suggestion: null });
  const [confirmModal, setConfirmModal] = useState({ open: false, title: '', content: '', onConfirm: () => {} });

  // --- Fetch Data ---
  const fetchData = useCallback(async (showLoading = true) => {
    if(showLoading) setLoading(true);
    setError('');
    try {
      const [sugs, cats] = await Promise.all([
        adminService.getCategorySuggestions(),
        adminService.getCategoriesWithStats()
      ]);
      setSuggestions(sugs);
      // Asegura que "Otro" esté al final
      const otroCategory = cats.find(c => c.nombre.toLowerCase() === 'otro');
      const otherCategories = cats.filter(c => c.nombre.toLowerCase() !== 'otro');
      const sortedCategories = otroCategory ? [...otherCategories, otroCategory] : otherCategories;
      setCategories(sortedCategories);
    } catch (err) {
      console.error("Error fetching category data:", err);
      setError('Error al cargar los datos de categorías.');
    } finally {
      if(showLoading) setLoading(false);
    }
  }, []); // Dependencias vacías, la función no cambia

  useEffect(() => {
    fetchData(true); // Carga inicial con spinner
  }, [fetchData]);

  // --- Handlers ---
  const handleDragEnd = (result) => {
    if (!result.destination) return;
    const items = Array.from(categories);
    const [reorderedItem] = items.splice(result.source.index, 1);
    items.splice(result.destination.index, 0, reorderedItem);

    setCategories(items); // Actualización optimista

    const orderedIds = items.map(item => item.id);
    adminService.reorderCategories(orderedIds)
      .catch(() => {
        setError('No se pudo guardar el nuevo orden. Refrescando...');
        fetchData(false); // Refresca sin spinner principal
      });
  };

  const handleOpenMergeModal = (suggestion) => {
      setMergeModal({ open: true, suggestion: suggestion });
  };
  const handleCloseMergeModal = () => {
       setMergeModal({ open: false, suggestion: null });
  };

  const handleMergeConfirm = async (suggestionName, targetCatId) => {
    setLoadingAction(true); // Activa loading específico
    try {
      await adminService.mergeCategorySuggestion(suggestionName, targetCatId);
      handleCloseMergeModal();
      await fetchData(false); // Refrescar sin spinner principal
    } catch (err) {
      setError(err.response?.data?.message || 'Error al fusionar la categoría.');
    } finally {
      setLoadingAction(false);
    }
  };

  const handleCreate = async (categoryName) => {
    setLoadingAction(true);
    try {
      await adminService.createCategory(categoryName);
      // Opcional: Limpiar nombre aquí si FormularioCrearCategoria no lo hace
      await fetchData(false);
    } catch (err) {
      setError(err.response?.data?.message || 'Error al crear la categoría.');
    } finally {
      setLoadingAction(false);
    }
  };

  const handleDelete = (category) => {
     // Verifica si hay reportes asociados ANTES de mostrar confirmación
     const totalReports = (category.reportes_activos || 0) + (category.reportes_pendientes || 0) + (category.reportes_rechazados || 0);
     if (totalReports > 0) {
        setConfirmModal({
            open: true, title: 'Acción No Permitida',
            content: `No se puede eliminar la categoría "${category.nombre}" porque tiene ${totalReports} reportes asociados. Reasigna los reportes a otra categoría primero.`,
            onConfirm: () => setConfirmModal({ open: false }), // Solo cierra
            confirmText: "Entendido", confirmColor: "primary"
        });
        return;
     }

    // Si no hay reportes, muestra confirmación normal
    setConfirmModal({
        open: true,
        title: `¿Eliminar Categoría "${category.nombre}"?`,
        content: `Esta acción es permanente e irreversible.`,
        confirmColor: "error",
        onConfirm: async () => {
            setLoadingAction(true); // Activa loading del modal
            try {
                await adminService.deleteCategory(category.id);
                setConfirmModal({ open: false }); // Cierra antes de refrescar
                await fetchData(false);
            } catch (err) {
                setError(err.response?.data?.message || 'Error al eliminar la categoría.');
                setConfirmModal({ open: false }); // Cierra en error
            } finally {
                setLoadingAction(false);
            }
        }
    });
  };

  const handleApprove = async (suggestionName) => {
    setLoadingAction(true);
    try {
      await adminService.createCategory(suggestionName);
      await fetchData(false);
    } catch (err) {
      setError(err.response?.data?.message || 'Error al aprobar la sugerencia.');
    } finally {
      setLoadingAction(false);
    }
  };

  return (
    <Box sx={{ p: { xs: 1, sm: 2, md: 3 } }}> {/* Padding responsivo */}
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>Gestión de Categorías</Typography>

      <Alert severity="info" icon={<InfoIcon />} sx={{ mb: 4, textAlign: 'left' }}>
            <AlertTitle>Centro de Control de Categorías</AlertTitle>
            Organiza las categorías de reportes. El orden de las "Categorías Oficiales" se refleja en la app móvil.
            <ul>
                <li><strong>Sugerencias:</strong> Aprueba para crear una nueva categoría oficial o Fusiona para mover sus reportes a una existente.</li>
                <li><strong>Oficiales:</strong> Arrastra (<DragIndicatorIcon sx={{ verticalAlign: 'middle', fontSize: '1rem' }} />) para reordenar (excepto "Otro").</li>
            </ul>
        </Alert>

        {/* Mostrar error general si existe */}
         {error && <Alert severity="error" onClose={() => setError('')} sx={{ mb: 2 }}>{error}</Alert>}

      <Grid container spacing={12}> {/* Aumentar espaciado */}
          {/* --- Columna Izquierda: Sugerencias y Creación --- */}
          <Grid item xs={12} md={5} lg={4}> {/* Ajustar breakpoints */}
              <Stack spacing={4}> {/* Espaciado entre paneles */}
                  <PanelSugerencias
                      suggestions={suggestions}
                      loading={loading && suggestions.length === 0} // Loading si no hay datos iniciales
                      onApprove={handleApprove}
                      onMerge={handleOpenMergeModal}
                  />
                  <FormularioCrearCategoria
                      onCreate={handleCreate}
                      loading={loadingAction} // Usar loading específico
                  />
              </Stack>
          </Grid>

          {/* --- Columna Derecha: Categorías Oficiales --- */}
          <Grid item xs={12} md={7} lg={8}> {/* Ajustar breakpoints */}
              <ListaCategoriasOficiales
                  categories={categories}
                  loading={loading && categories.length === 0} // Loading si no hay datos iniciales
                  onDragEnd={handleDragEnd}
                  onDelete={handleDelete}
              />
          </Grid>
      </Grid>

      {/* --- Modales --- */}
      <ModalFusionarSugerencia
          open={mergeModal.open}
          onClose={handleCloseMergeModal}
          suggestion={mergeModal.suggestion}
          categories={categories}
          onConfirm={handleMergeConfirm}
          loading={loadingAction} // Usar loading específico
      />

      <ModalConfirmacion
          open={confirmModal.open}
          onClose={() => setConfirmModal({ ...confirmModal, open: false })}
          title={confirmModal.title}
          content={confirmModal.content}
          onConfirm={confirmModal.onConfirm}
          confirmText={confirmModal.confirmText} // Pasa texto custom
          confirmColor={confirmModal.confirmColor || 'primary'} // Pasa color custom
          loading={loadingAction} // Usar loading específico para confirmaciones
      />
    </Box>
  );
}
export default PaginaCategorias;