// src/components/Analisis/SeccionAnalisis.jsx
import React from 'react';
import { Paper, Typography, Box, Skeleton } from '@mui/material';

// --- MODIFICADO: Añadida la prop 'contentMinHeight' con un valor por defecto ---
function SeccionAnalisis({ 
  title, 
  description, 
  children, 
  elementRef, 
  loading, 
  contentMinHeight = 300 // Altura por defecto para gráficos
}) {

  return (
    <Paper ref={elementRef} sx={{ p: { xs: 1.5, sm: 2, md: 3 }, mb: 4, borderRadius: '12px', height: '100%', display: 'flex', flexDirection: 'column' }} elevation={3}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 2, gap: 1 }}>
        <Box sx={{ flexGrow: 1 }}>
          <Typography variant="h6" gutterBottom sx={{ fontWeight: 500 }}>
            {loading ? <Skeleton width="60%" /> : title}
          </Typography>
          {description && (
            <Typography variant="body2" color="text.secondary">
              {loading ? <Skeleton width="80%" /> : description}
            </Typography>
          )}
        </Box>
      </Box>
      
      {/* --- MODIFICADO: 'minHeight' ahora es dinámico --- */}
      <Box sx={{ flexGrow: 1, minHeight: contentMinHeight }}>
        {children}
      </Box>
    </Paper>
  );
}

SeccionAnalisis.displayName = 'SeccionAnalisis'; 
export default SeccionAnalisis;