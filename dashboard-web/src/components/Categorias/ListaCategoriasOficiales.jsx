// src/components/Categorias/ListaCategoriasOficiales.jsx
import React from 'react';
import { DragDropContext, Droppable, Draggable } from '@hello-pangea/dnd';
import { Box, Typography, CircularProgress, Skeleton, Stack } from '@mui/material';
import ItemCategoriaOficial from './ItemCategoriaOficial';
import ErrorOutlineIcon from '@mui/icons-material/ErrorOutline';

/**
 * Componente ListaCategoriasOficiales - Lista drag & drop de categorías oficiales
 * 
 * @param {Object} props - Propiedades del componente
 * @param {Array} props.categories - Array de categorías oficiales
 * @param {boolean} props.loading - Estado de carga para mostrar skeletons
 * @param {Function} props.onDragEnd - Callback cuando se completa el arrastre
 * @param {Function} props.onDelete - Callback para eliminar categoría
 * 
 * @returns {JSX.Element} Lista interactiva de categorías oficiales
 * 
 * @example
 * // Uso básico
 * <ListaCategoriasOficiales
 *   categories={categorias}
 *   loading={false}
 *   onDragEnd={handleDragEnd}
 *   onDelete={handleDelete}
 * />
 * 
 * @example
 * // En estado de carga
 * <ListaCategoriasOficiales
 *   categories={[]}
 *   loading={true}
 *   onDragEnd={handleDragEnd}
 *   onDelete={handleDelete}
 * />
 */
function ListaCategoriasOficiales({ categories, loading, onDragEnd, onDelete }) {

  /**
   * Maneja el evento de finalización de arrastre
   * Filtra casos especiales antes de llamar al callback del padre
   * 
   * @param {Object} result - Resultado del drag & drop
   * @param {Object} result.destination - Destino del arrastre
   * @param {Object} result.source - Origen del arrastre
   */
  const handleInternalDragEnd = (result) => {
      // Prevenir reordenar si no hay destino o si es la categoría "Otro"
      const sourceItem = categories[result.source.index];
      if (!result.destination || sourceItem?.nombre.toLowerCase() === 'otro') {
          return;
      }
      onDragEnd(result); // Llama al handler del padre
  };

  return (
    <>
      {/* Título de la sección */}
      <Typography variant="h5" gutterBottom>
        Categorías Oficiales (Arrastrables)
      </Typography>

      {/* Estados del componente */}
      {loading ? (
        // Estado de carga - Skeletons
        <Stack spacing={1.5}>
           {[...Array(5)].map((_, i) => (
             <Skeleton 
               key={i} 
               variant="rounded" 
               height={80} 
             />
           ))}
        </Stack>
      ) : categories.length === 0 ? (
        // Estado vacío - Sin categorías
        <Box sx={{ 
          p: 3, 
          textAlign: 'center', 
          color: 'text.secondary', 
          border: '1px dashed', 
          borderColor: 'divider', 
          borderRadius: 1 
        }}>
          <ErrorOutlineIcon sx={{ fontSize: 40, mb: 1 }} />
          <Typography>No hay categorías oficiales creadas.</Typography>
        </Box>
      ) : (
        // Estado con datos - Lista drag & drop
        <DragDropContext onDragEnd={handleInternalDragEnd}>
          <Droppable droppableId="categories">
            {(provided) => (
              <Box 
                {...provided.droppableProps} 
                ref={provided.innerRef}
              >
                {categories.map((cat, index) => {
                   // Determina si el elemento es arrastrable
                   // La categoría "Otro" no se puede arrastrar
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