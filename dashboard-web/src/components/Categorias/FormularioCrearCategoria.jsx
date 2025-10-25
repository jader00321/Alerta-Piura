// src/components/Categorias/FormularioCrearCategoria.jsx
import React, { useState } from 'react';
import { Paper, Typography, Box, TextField, Button, CircularProgress } from '@mui/material';
import AddIcon from '@mui/icons-material/Add';

function FormularioCrearCategoria({ onCreate, loading }) {
  const [newCategoryName, setNewCategoryName] = useState('');

  const handleCreateClick = () => {
    if (newCategoryName.trim()) {
      onCreate(newCategoryName.trim());
      // Opcional: Limpiar el campo aquí o dejar que el padre lo haga si onCreate tiene éxito
      // setNewCategoryName('');
    }
  };

   // Limpiar campo si loading termina (asumiendo que onCreate fue exitoso)
   // Se necesita un useEffect si el padre no limpia el estado
   // useEffect(() => { if (!loading) setNewCategoryName(''); }, [loading]);


  return (
    <>
      <Typography variant="h5" gutterBottom sx={{ mt: 4 }}>Crear Nueva Categoría</Typography>
      <Paper elevation={2} sx={{ p: 2.5, display: 'flex', gap: 2 }}>
        <TextField
            label="Nombre de la nueva categoría"
            variant="outlined"
            size="small"
            fullWidth
            value={newCategoryName}
            onChange={(e) => setNewCategoryName(e.target.value)}
            disabled={loading}
        />
        <Button
            variant="contained"
            onClick={handleCreateClick}
            disabled={!newCategoryName.trim() || loading}
            startIcon={loading ? <CircularProgress size={16} color="inherit"/> : <AddIcon />}
            sx={{ flexShrink: 0 }} // Evita que el botón se encoja
        >
            {loading ? 'Creando...' : 'Crear'}
        </Button>
      </Paper>
    </>
  );
}

export default FormularioCrearCategoria;