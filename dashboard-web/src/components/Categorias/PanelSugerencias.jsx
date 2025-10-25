// src/components/Categorias/PanelSugerencias.jsx
import React from 'react';
import { Paper, Typography, List, ListItem, ListItemText, Button, Box, CircularProgress, Skeleton, Stack } from '@mui/material';
import MergeTypeIcon from '@mui/icons-material/MergeType';
import AddIcon from '@mui/icons-material/Add';
import ErrorOutlineIcon from '@mui/icons-material/ErrorOutline'; // Icono para vacío

function PanelSugerencias({ suggestions, loading, onApprove, onMerge }) {
  return (
    <>
      <Typography variant="h5" gutterBottom>Sugerencias Pendientes</Typography>
      <Paper elevation={2} sx={{ p: 1 }}>
        {loading ? (
            <Stack spacing={1} sx={{p:1}}>
                {[...Array(3)].map((_, i) => <Skeleton key={i} variant="rounded" height={60} />)}
            </Stack>
        ) : suggestions.length > 0 ? (
          <List sx={{p: 0}}>
            {suggestions.map((sug, index) => (
              <ListItem
                key={sug.categoria_sugerida}
                divider={index < suggestions.length - 1} // Divider excepto en el último
                sx={{ display: 'flex', flexWrap: 'wrap', gap: 1, py: 1.5 }} // Mejorar espaciado
              >
                <ListItemText
                    primary={<Typography sx={{fontWeight: 500}}>{sug.categoria_sugerida}</Typography>}
                    secondary={`Sugerida ${sug.count} vece(s)`}
                    sx={{ flexGrow: 1, mr: 1 }} // Ocupa espacio
                />
                 <Stack direction="row" spacing={1} sx={{ flexShrink: 0, ml: 'auto' }}> {/* Alinea botones a la derecha */}
                    <Button
                        variant="outlined" size="small"
                        startIcon={<MergeTypeIcon/>}
                        onClick={() => onMerge(sug)} // Pasa toda la sugerencia
                        disabled={loading} // Deshabilitar si está cargando otra cosa
                    >
                        Fusionar
                    </Button>
                    <Button
                        variant="contained" size="small"
                        startIcon={<AddIcon/>}
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
          <Box sx={{ p: 3, textAlign: 'center', color: 'text.secondary' }}>
            <ErrorOutlineIcon sx={{ fontSize: 40, mb: 1 }} />
            <Typography>No hay nuevas sugerencias pendientes.</Typography>
          </Box>
        )}
      </Paper>
    </>
  );
}

export default PanelSugerencias;