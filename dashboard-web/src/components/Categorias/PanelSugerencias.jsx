// src/components/Categorias/PanelSugerencias.jsx
import React from 'react';
import { 
  Paper, Typography, List, ListItem, ListItemText, Button, 
  Box, CircularProgress, Skeleton, Stack 
} from '@mui/material';
import MergeTypeIcon from '@mui/icons-material/MergeType';
import AddIcon from '@mui/icons-material/Add';
import ErrorOutlineIcon from '@mui/icons-material/ErrorOutline'; // Icono para estado vacío

/**
 * Panel que muestra la lista de categorías sugeridas por los usuarios que aún no han sido aprobadas o fusionadas.
 * Permite al administrador aprobar una sugerencia como nueva categoría o fusionarla con una existente.
 *
 * @component
 * @param {Object} props - Propiedades del componente.
 * @param {Array<{categoria_sugerida: string, count: number}>} props.suggestions - Lista de sugerencias pendientes.
 * @param {boolean} props.loading - Indica si los datos están cargando.
 * @param {Function} props.onApprove - Callback ejecutado al aprobar una sugerencia (recibe el nombre de la categoría sugerida).
 * @param {Function} props.onMerge - Callback ejecutado al iniciar una fusión (recibe el objeto completo de la sugerencia).
 *
 * @returns {JSX.Element} Un panel con la lista de sugerencias, botones de acción y estados visuales.
 *
 * @example
 * <PanelSugerencias
 *   suggestions={[
 *     { categoria_sugerida: 'Seguridad', count: 5 },
 *     { categoria_sugerida: 'Residuos', count: 2 }
 *   ]}
 *   loading={false}
 *   onApprove={(nombre) => console.log("Aprobar:", nombre)}
 *   onMerge={(sugerencia) => console.log("Fusionar:", sugerencia)}
 * />
 */
function PanelSugerencias({ suggestions, loading, onApprove, onMerge }) {
  return (
    <>
      {/* Título principal del panel */}
      <Typography variant="h5" gutterBottom>
        Sugerencias Pendientes
      </Typography>

      {/* Contenedor principal */}
      <Paper elevation={2} sx={{ p: 1 }}>
        {loading ? (
          // --- ESTADO: Cargando ---
          <Stack spacing={1} sx={{ p: 1 }}>
            {[...Array(3)].map((_, i) => (
              <Skeleton key={i} variant="rounded" height={60} />
            ))}
          </Stack>
        ) : suggestions.length > 0 ? (
          // --- ESTADO: Con sugerencias ---
          <List sx={{ p: 0 }}>
            {suggestions.map((sug, index) => (
              <ListItem
                key={sug.categoria_sugerida}
                divider={index < suggestions.length - 1} // Agrega separador excepto al último
                sx={{
                  display: 'flex',
                  flexWrap: 'wrap',
                  gap: 1,
                  py: 1.5,
                }}
              >
                {/* Texto principal de la sugerencia */}
                <ListItemText
                  primary={
                    <Typography sx={{ fontWeight: 500 }}>
                      {sug.categoria_sugerida}
                    </Typography>
                  }
                  secondary={`Sugerida ${sug.count} vece(s)`}
                  sx={{ flexGrow: 1, mr: 1 }}
                />

                {/* Botones de acción (fusionar / aprobar) */}
                <Stack
                  direction="row"
                  spacing={1}
                  sx={{ flexShrink: 0, ml: 'auto' }}
                >
                  <Button
                    variant="outlined"
                    size="small"
                    startIcon={<MergeTypeIcon />}
                    onClick={() => onMerge(sug)} // Pasa todo el objeto
                    disabled={loading}
                  >
                    Fusionar
                  </Button>
                  <Button
                    variant="contained"
                    size="small"
                    startIcon={<AddIcon />}
                    onClick={() => onApprove(sug.categoria_sugerida)}
                    disabled={loading}
                  >
                    Aprobar
                  </Button>
                </Stack>
              </ListItem>
            ))}
          </List>
        ) : (
          // --- ESTADO: Sin sugerencias ---
          <Box
            sx={{ p: 3, textAlign: 'center', color: 'text.secondary' }}
          >
            <ErrorOutlineIcon sx={{ fontSize: 40, mb: 1 }} />
            <Typography>
              No hay nuevas sugerencias pendientes.
            </Typography>
          </Box>
        )}
      </Paper>
    </>
  );
}

export default PanelSugerencias;
