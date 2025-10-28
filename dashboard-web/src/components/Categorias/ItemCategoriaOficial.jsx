// src/components/Categorias/ItemCategoriaOficial.jsx
import React from 'react';
import { Paper, Box, Typography, IconButton, Tooltip, Chip } from '@mui/material';
import {
    DragIndicator as DragIndicatorIcon, Delete as DeleteIcon,
    CheckCircleOutline as CheckIcon, HourglassEmpty as PendingIcon, CancelOutlined as RejectIcon
} from '@mui/icons-material';
/**
 * Componente para mostrar estadísticas de una categoría.
 * @param {Object} param0 - Props del componente.
 * @param {ReactNode} param0.icon - Icono a mostrar en el chip.
 * @param {number} param0.count - Cantidad a mostrar en el chip.
 * @param {string} param0.color - Color del chip.
 * @param {string} param0.tooltip - Texto del tooltip.
 * @returns {JSX.Element} Componente de chip con estadísticas.
 */
// StatChip reutilizado (podría moverse a Comunes)
const StatChip = ({ icon, count = 0, color, tooltip }) => ( // Default count a 0
    <Tooltip title={`${count} ${tooltip}`}>
        {/* Usar span si el count es 0 para evitar error de Tooltip */}
        <span>
            <Chip
                icon={icon}
                label={count}
                size="small"
                variant="outlined"
                color={color}
                // Deshabilitar visualmente si el count es 0
                disabled={count === 0}
                sx={{ mr: 1, '&.Mui-disabled': { opacity: 0.6 } }}
            />
        </span>
    </Tooltip>
);

/**
 *
 *
 * @param {*} { category, provided, snapshot, onDelete }
 * @return {*} 
 */
function ItemCategoriaOficial({ category, provided, snapshot, onDelete }) {
  const isOtro = category.nombre.toLowerCase() === 'otro';

  return (
    <Paper
      ref={provided.innerRef}
      {...provided.draggableProps}
      elevation={snapshot.isDragging ? 6 : 1} // Más sombra al arrastrar
      sx={{
        mb: 1.5, // Espacio entre items
        display: 'flex',
        alignItems: 'center',
        bgcolor: snapshot.isDragging ? 'action.hover' : 'background.paper', // Fondo al arrastrar
        borderLeft: `4px solid ${isOtro ? 'transparent' : 'primary.main'}`, // Borde de color (excepto "Otro")
        transition: 'background-color 0.2s ease, box-shadow 0.2s ease',
      }}
    >
      {/* Handle de Arrastre */}
      <Tooltip title={isOtro ? 'La categoría "Otro" no se puede reordenar' : 'Arrastrar para reordenar'}>
        {/* Usar span para Tooltip en elemento deshabilitado */}
        <span>
            <Box
                {...provided.dragHandleProps}
                sx={{
                    p: 2,
                    cursor: isOtro ? 'not-allowed' : 'grab',
                    display: 'flex', alignItems: 'center',
                    color: isOtro ? 'text.disabled' : 'action.active',
                    opacity: isOtro ? 0.5 : 1
                }}
            >
                <DragIndicatorIcon />
            </Box>
        </span>
      </Tooltip>

      {/* Nombre y Estadísticas */}
      <Box sx={{ flexGrow: 1, py: 1.5, px: 2 }}>
        <Typography variant="h6" sx={{ fontWeight: 500 }}>
          {category.nombre} {isOtro && <Typography component="span" variant="caption">(Categoría Fija)</Typography>}
        </Typography>
        <Box sx={{ mt: 1 }}>
          <StatChip icon={<CheckIcon/>} count={category.reportes_activos} color="success" tooltip="Reportes Verificados" />
          <StatChip icon={<PendingIcon/>} count={category.reportes_pendientes} color="warning" tooltip="Reportes Pendientes" />
          <StatChip icon={<RejectIcon/>} count={category.reportes_rechazados} color="error" tooltip="Reportes Rechazados" />
        </Box>
      </Box>

      {/* Botón Eliminar (si no es "Otro") */}
      {!isOtro && (
        <Tooltip title="Eliminar Categoría">
          {/* Usar span si hay posibilidad de deshabilitar el botón */}
           <span>
                <IconButton
                    sx={{ m: 1 }}
                    onClick={() => onDelete(category)}
                    // Opcional: Deshabilitar si tiene reportes asociados (requiere lógica adicional o confirmación)
                    // disabled={category.reportes_activos > 0 || category.reportes_pendientes > 0 || category.reportes_rechazados > 0}
                >
                    <DeleteIcon color="error"/>
                </IconButton>
           </span>
        </Tooltip>
      )}
      {/* Añadir padding si el botón no existe para mantener alineación */}
       {isOtro && <Box sx={{ width: 40 + 16, mr: 1 }} />} {/* Width IconButton + margin */}

    </Paper>
  );
}

export default ItemCategoriaOficial;