import React, { useEffect, useState } from 'react';
import { Box, Paper, Typography, List, ListItem, ListItemText, Button, Grid, IconButton, TextField } from '@mui/material';
import DeleteIcon from '@mui/icons-material/Delete';
import adminService from '../services/adminService';

function CategoriesPage() {
  const [suggestions, setSuggestions] = useState([]);
  const [categories, setCategories] = useState([]);
  const [newCategoryName, setNewCategoryName] = useState('');

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = () => {
    adminService.getCategorySuggestions().then(setSuggestions).catch(console.error);
    adminService.getAllCategories().then(setCategories).catch(console.error);
  };

  const handleApprove = (suggestionName) => {
    adminService.createCategory(suggestionName)
      .then(() => fetchData())
      .catch(err => alert(err.response?.data?.message || 'Error al aprobar'));
  };
  
  const handleCreate = () => {
    if (!newCategoryName.trim()) return;
    adminService.createCategory(newCategoryName)
      .then(() => {
        setNewCategoryName('');
        fetchData();
      })
      .catch(err => alert(err.response?.data?.message || 'Error al crear'));
  };

  const handleDelete = (categoryId) => {
    if (window.confirm('¿Estás seguro de que quieres eliminar esta categoría? Esta acción no se puede deshacer.')) {
      adminService.deleteCategory(categoryId)
        .then(() => fetchData())
        .catch(err => alert(err.response?.data?.message || 'Error al eliminar'));
    }
  };

  return (
    <Box>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Gestión de Categorías
      </Typography>
      <Grid container spacing={4}>
        {/* --- Pending Suggestions Column --- */}
        <Grid item xs={12} md={6}>
          <Typography variant="h6" gutterBottom>Sugerencias Pendientes (Nuevas primero)</Typography>
          <Paper elevation={2}>
            <List>
              {suggestions.length > 0 ? suggestions.map((sug, index) => (
                <ListItem key={index} divider>
                  <ListItemText 
                    primary={sug.categoria_sugerida} 
                    secondary={`Sugerida ${sug.count} vece(s)`} // Counter is now displayed
                  />
                  <Button variant="contained" size="small" onClick={() => handleApprove(sug.categoria_sugerida)}>
                    Aprobar
                  </Button>
                </ListItem>
              )) : <ListItem><ListItemText primary="No hay nuevas sugerencias." /></ListItem>}
            </List>
          </Paper>
        </Grid>

        {/* --- Current Categories Column --- */}
        <Grid item xs={12} md={6}>
           <Typography variant="h6" gutterBottom>Categorías Oficiales</Typography>
           <Paper elevation={2} sx={{ mb: 3 }}>
            <List>
              {categories.map((cat) => (
                <ListItem 
                  key={cat.id} 
                  divider
                  secondaryAction={ // The delete button appears on the right
                    <IconButton edge="end" aria-label="delete" onClick={() => handleDelete(cat.id)}>
                      <DeleteIcon />
                    </IconButton>
                  }
                >
                  <ListItemText primary={cat.nombre} />
                </ListItem>
              ))}
            </List>
          </Paper>
          
          <Typography variant="h6" gutterBottom>Crear Nueva Categoría</Typography>
           <Paper elevation={2} sx={{ p: 2, display: 'flex', gap: 2 }}>
            <TextField 
              label="Nombre de la categoría" 
              variant="outlined" 
              size="small"
              fullWidth
              value={newCategoryName}
              onChange={(e) => setNewCategoryName(e.target.value)}
            />
            <Button variant="contained" onClick={handleCreate}>Crear</Button>
           </Paper>
        </Grid>
      </Grid>
    </Box>
  );
}

export default CategoriesPage;