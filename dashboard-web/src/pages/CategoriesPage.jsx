import React, { useEffect, useState, useCallback } from 'react';
import { Box, Paper, Typography, List, ListItem, ListItemText, Button, Grid, IconButton, TextField, Dialog, DialogTitle, DialogContent, DialogActions, Select, MenuItem, FormControl, InputLabel, Alert, AlertTitle, CircularProgress, Tooltip } from '@mui/material';
import { DragIndicator as DragIndicatorIcon, DragHandle as DragHandleIcon, Delete as DeleteIcon, Add as AddIcon, MergeType as MergeIcon, InfoOutlined as InfoIcon, CheckCircleOutline as CheckIcon, HourglassEmpty as PendingIcon, CancelOutlined as RejectIcon } from '@mui/icons-material';
import { DragDropContext, Droppable, Draggable } from '@hello-pangea/dnd'; // Usando la librería corregida
import adminService from '../services/adminService';
import Chip from '@mui/material/Chip';

const StatChip = ({ icon, count, color, tooltip }) => (
    <Tooltip title={`${count} ${tooltip}`}>
        <Chip 
            icon={icon} 
            label={count}
            size="small"
            variant="outlined"
            color={color}
            sx={{ mr: 1 }}
        />
    </Tooltip>
);

function CategoriesPage() {
  const [suggestions, setSuggestions] = useState([]);
  const [categories, setCategories] = useState([]);
  const [newCategoryName, setNewCategoryName] = useState('');
  const [isMerging, setIsMerging] = useState(false);
  // REFINAMIENTO: Estados para manejar el modal de fusión de forma más robusta
  const [mergeModal, setMergeModal] = useState({ open: false, suggestion: null });
  const [confirmModal, setConfirmModal] = useState({ open: false, title: '', content: '', onConfirm: () => {} });
  const [targetCategoryId, setTargetCategoryId] = useState('');
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(() => {
    setLoading(true);
    return Promise.all([
        adminService.getCategorySuggestions(),
        adminService.getCategoriesWithStats()
    ]).then(([sugs, cats]) => {
        setSuggestions(sugs);
        // Lógica para asegurar que la categoría "Otro" siempre esté al final
        const otroCategory = cats.find(c => c.nombre.toLowerCase() === 'otro');
        const otherCategories = cats.filter(c => c.nombre.toLowerCase() !== 'otro');
        const sortedCategories = otroCategory ? [...otherCategories, otroCategory] : otherCategories;
        setCategories(sortedCategories);
    }).catch(console.error).finally(() => setLoading(false));
  }, []); // El array vacío asegura que esta función se cree una sola vez

  // useEffect para la carga inicial de datos
  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // Handler para cuando se termina de arrastrar un elemento
  const handleDragEnd = (result) => {
    if (!result.destination) return; // Si se suelta fuera de la lista

    const items = Array.from(categories);
    const [reorderedItem] = items.splice(result.source.index, 1);
    items.splice(result.destination.index, 0, reorderedItem);
    
    setCategories(items); // Actualización optimista de la UI

    const orderedIds = items.map(item => item.id);
    adminService.reorderCategories(orderedIds).catch(() => {
        // Si falla la API, mostramos un modal de error y refrescamos
        setConfirmModal({
            open: true,
            title: 'Error de Sincronización',
            content: 'No se pudo guardar el nuevo orden. La página se refrescará con el orden original.',
            onConfirm: () => { setConfirmModal({ open: false }); fetchData(); }
        });
    });
  };
  
  // Handler para confirmar la fusión desde el modal
  const handleMergeConfirm = async () => {
    if (!mergeModal.suggestion || !targetCategoryId) return;

    setIsMerging(true);
    try {
        await adminService.mergeCategorySuggestion(mergeModal.suggestion.categoria_sugerida, targetCategoryId);
        await fetchData(); 
        setMergeModal({ open: false, suggestion: null });
        setTargetCategoryId('');
    } catch (err) {
        alert(err.response?.data?.message || 'Error al fusionar la categoría.');
    } finally {
        setIsMerging(false);
    }
};

  // Handler para crear una nueva categoría
  const handleCreate = async () => {
    if (!newCategoryName.trim()) return;
    try {
        await adminService.createCategory(newCategoryName);
        setNewCategoryName('');
        fetchData();
    } catch (err) {
        alert(err.response?.data?.message || 'Error al crear la categoría.');
    }
  };

  // Handler para mostrar el modal de confirmación antes de eliminar
  const handleDelete = (category) => {
    setConfirmModal({
        open: true,
        title: `¿Eliminar Categoría "${category.nombre}"?`,
        content: `Esta acción es permanente. ${category.reportes_activos > 0 ? `Hay ${category.reportes_activos} reportes activos que serán afectados.` : ''}`,
        onConfirm: async () => {
            try {
                await adminService.deleteCategory(category.id);
                fetchData();
            } catch (err) {
                alert(err.response?.data?.message || 'Error al eliminar la categoría.');
            } finally {
                setConfirmModal({ open: false, onConfirm: () => {} });
            }
        }
    });
  };

  // Handler para aprobar una sugerencia
  const handleApprove = async (suggestionName) => {
    try {
        await adminService.createCategory(suggestionName);
        fetchData();
    } catch (err) {
        alert(err.response?.data?.message || 'Error al aprobar la sugerencia.');
    }
  };

  return (
    <Box>
        <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>Gestión de Categorías</Typography>
        
        <Alert severity="info" icon={<InfoIcon />} sx={{ mb: 4, textAlign: 'left' }}>
            <AlertTitle>Centro de Control de Categorías</AlertTitle>
            Esta página es fundamental para la organización de los reportes en la aplicación móvil.
            <ul>
                <li><strong>Sugerencias Pendientes:</strong> Aquí aparecen las categorías que los usuarios proponen. Puedes <strong>Aprobarlas</strong> para convertirlas en oficiales o <strong>Fusionarlas</strong> para reclasificar sus reportes dentro de una categoría ya existente.</li>
                <li><strong>Categorías Oficiales:</strong> Esta es la lista principal. Usa el ícono <DragIndicatorIcon sx={{ verticalAlign: 'middle', fontSize: '1rem' }} /> para <strong>arrastrar y cambiar el orden</strong>. Este orden se reflejará directamente en la app.</li>
            </ul>
        </Alert>

        <Grid container spacing={12}>
            {/* --- Columna Izquierda: Sugerencias y Creación --- */}
            <Grid item xs={12} md={5}>
                <Typography variant="h5" gutterBottom>Sugerencias Pendientes</Typography>
                <Paper elevation={2} sx={{ mb: 4, p: 1, width: '105%'}}>
                    <List sx={{p: 0}}>
                    {suggestions.length > 0 ? suggestions.map((sug) => (
                        <ListItem key={sug.categoria_sugerida} divider>
                            <ListItemText primary={<Typography sx={{fontWeight: 500}}>{sug.categoria_sugerida}</Typography>} secondary={`Sugerida ${sug.count} vece(s)`} />
                            <Button variant="outlined" size="small" startIcon={<MergeIcon/>} sx={{ mr: 1 }} onClick={() => setMergeModal({ open: true, suggestion: sug })}>
                                Fusionar
                            </Button>
                            <Button variant="contained" size="small" startIcon={<AddIcon/>} onClick={() => handleApprove(sug.categoria_sugerida)}>
                                Aprobar
                            </Button>
                        </ListItem>
                    )) : <ListItem><ListItemText primary="No hay nuevas sugerencias." /></ListItem>}
                    </List>
                </Paper>
                
                <Typography variant="h5" gutterBottom>Crear Nueva Categoría</Typography>
                <Paper elevation={2} sx={{ p: 2, display: 'flex', gap: 2, width: '105%' }}>
                    <TextField label="Nombre de la categoría" variant="outlined" size="small" fullWidth value={newCategoryName} onChange={(e) => setNewCategoryName(e.target.value)} />
                    <Button variant="contained" onClick={handleCreate}>Crear</Button>
                </Paper>
            </Grid>
            {/* --- Columna Derecha: Categorías Oficiales --- */}
            <Grid item xs={12} md={7}>
                <Typography variant="h5" gutterBottom>Categorías Oficiales (Arrastrables)</Typography>
                {loading ? <Box sx={{display: 'flex', justifyContent: 'center', p: 4}}><CircularProgress /></Box> : (
                <DragDropContext onDragEnd={handleDragEnd}>
                    <Droppable droppableId="categories">
                    {(provided) => (
                        <Box {...provided.droppableProps} ref={provided.innerRef}>
                        {categories.map((cat, index) => (
                            <Draggable key={cat.id.toString()} draggableId={cat.id.toString()} index={index}>
                            {(provided, snapshot) => (
                                <Paper ref={provided.innerRef} {...provided.draggableProps} elevation={snapshot.isDragging ? 8 : 2} sx={{ mb: 2, display: 'flex', alignItems: 'center' }}>
                                    <Tooltip title="Arrastrar para reordenar">
                                        <Box {...provided.dragHandleProps} sx={{ p: 2.5, cursor: 'grab', display: 'flex', alignItems: 'center' }}><DragIndicatorIcon /></Box>
                                    </Tooltip>
                                    <Box sx={{ flexGrow: 1, py: 1.5, px: 3}}>
                                        <Typography variant="h6">{cat.nombre}</Typography>
                                        <Box sx={{ mt: 1 }}>
                                            <StatChip icon={<CheckIcon/>} count={cat.reportes_activos} color="success" tooltip="Verificados" />
                                            <StatChip icon={<PendingIcon/>} count={cat.reportes_pendientes} color="warning" tooltip="Pendientes" />
                                            <StatChip icon={<RejectIcon/>} count={cat.reportes_rechazados} color="error" tooltip="Rechazados" />
                                        </Box>
                                    </Box>
                                    {cat.nombre.toLowerCase() !== 'otro' && (
                                        <Tooltip title="Eliminar Categoría">
                                            <IconButton sx={{ m: 1 }} onClick={() => handleDelete(cat)}><DeleteIcon /></IconButton>
                                        </Tooltip>
                                    )}
                                </Paper>
                            )}
                            </Draggable>
                        ))}
                        {provided.placeholder}
                        </Box>
                    )}
                    </Droppable>
                </DragDropContext>
                )}
            </Grid>
        </Grid>

        {/* --- Modales --- */}
        <Dialog open={mergeModal.open} onClose={() => setMergeModal({ open: false, suggestion: null })}>
            <DialogTitle>Fusionar Sugerencia</DialogTitle>
            <DialogContent>
                <Typography paragraph>Vas a fusionar <strong>"{mergeModal.suggestion?.categoria_sugerida}"</strong> en una categoría oficial. Todos los reportes con esta sugerencia serán reasignados.</Typography>
                <FormControl fullWidth margin="dense">
                    <InputLabel>Categoría Oficial de Destino</InputLabel>
                    <Select value={targetCategoryId} onChange={(e) => setTargetCategoryId(e.target.value)} label="Categoría Oficial de Destino">
                        {categories.filter(c => c.nombre.toLowerCase() !== 'otro').map(cat => (<MenuItem key={cat.id} value={cat.id}>{cat.nombre}</MenuItem>))}
                    </Select>
                </FormControl>
            </DialogContent>
            <DialogActions>
    <Button onClick={() => { setMergeModal({ open: false, suggestion: null }); setTargetCategoryId(''); }} disabled={isMerging}>
        Cancelar
    </Button>
    <Button onClick={handleMergeConfirm} variant="contained" disabled={!targetCategoryId || isMerging}>
        {isMerging ? <CircularProgress size={24} color="inherit" /> : 'Confirmar Fusión'}
    </Button>
</DialogActions>
        </Dialog>

        <Dialog open={confirmModal.open} onClose={() => setConfirmModal({ open: false })}>
            <DialogTitle>{confirmModal.title}</DialogTitle>
            <DialogContent><Typography>{confirmModal.content}</Typography></DialogContent>
            <DialogActions>
                <Button onClick={() => setConfirmModal({ open: false })}>Cancelar</Button>
                <Button onClick={confirmModal.onConfirm} variant="contained" color="primary">Confirmar</Button>
            </DialogActions>
        </Dialog>
    </Box>
  );
}
export default CategoriesPage;