// src/components/Categorias/ListaCategoriasOficiales.jsx
import React from 'react';
import { DragDropContext, Droppable, Draggable } from '@hello-pangea/dnd';
import { Box, Typography, CircularProgress, Skeleton, Stack } from '@mui/material';
import ItemCategoriaOficial from './ItemCategoriaOficial';
import ErrorOutlineIcon from '@mui/icons-material/ErrorOutline';

function ListaCategoriasOficiales({ categories, loading, onDragEnd, onDelete }) {

  // Handler intermedio para filtrar antes de llamar al padre
  const handleInternalDragEnd = (result) => {
      // Prevenir reordenar si se intenta mover "Otro" o si no hay destino
      const sourceItem = categories[result.source.index];
      if (!result.destination || sourceItem?.nombre.toLowerCase() === 'otro') {
          return;
      }
      onDragEnd(result); // Llama al handler del padre
  };

  return (
    <>
      <Typography variant="h5" gutterBottom>Categorías Oficiales (Arrastrables)</Typography>
      {loading ? (
        <Stack spacing={1.5}>
           {[...Array(5)].map((_, i) => <Skeleton key={i} variant="rounded" height={80} />)}
        </Stack>
      ) : categories.length === 0 ? (
           <Box sx={{ p: 3, textAlign: 'center', color: 'text.secondary', border: '1px dashed', borderColor: 'divider', borderRadius: 1 }}>
            <ErrorOutlineIcon sx={{ fontSize: 40, mb: 1 }} />
            <Typography>No hay categorías oficiales creadas.</Typography>
          </Box>
      ) : (
        <DragDropContext onDragEnd={handleInternalDragEnd}>
          <Droppable droppableId="categories">
            {(provided) => (
              <Box {...provided.droppableProps} ref={provided.innerRef}>
                {categories.map((cat, index) => {
                   // Determina si el elemento es draggable
                   const isDraggable = cat.nombre.toLowerCase() !== 'otro';
                   return (
                      <Draggable
                        key={cat.id.toString()}
                        draggableId={cat.id.toString()}
                        index={index}
                        isDragDisabled={!isDraggable} // Deshabilita arrastre para "Otro"
                      >
                        {(provided, snapshot) => (
                           <ItemCategoriaOficial
                             category={cat}
                             provided={provided}
                             snapshot={snapshot}
                             onDelete={onDelete}
                           />
                        )}
                      </Draggable>
                   );
                })}
                {provided.placeholder}
              </Box>
            )}
          </Droppable>
        </DragDropContext>
      )}
    </>
  );
}

export default ListaCategoriasOficiales;