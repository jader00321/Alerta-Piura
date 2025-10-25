// src/components/Analisis/TarjetaMetrica.jsx
import React from 'react';
import { Box, Typography, Skeleton, useTheme } from '@mui/material';

function TarjetaMetrica({ value, loading }) {
  const theme = useTheme();
  
  const valueColor = value === 'N/A' || !value 
    ? theme.palette.text.disabled 
    : theme.palette.primary.main; // Color primario para el valor

  return (
    <Box sx={{ 
      height: '100%', 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center',
      // --- MODIFICADO: Padding vertical eliminado para reducir altura ---
      py: 0 
    }}>
      {loading ? (
        <Skeleton variant="rectangular" width={120} height={60} />
      ) : (
        <Typography 
          variant="h2" 
          component="p"
          sx={{ 
            fontWeight: 'bold', 
            color: valueColor,
            textAlign: 'center',
            lineHeight: 1.2,
            my: 0 // Eliminar márgenes por defecto de h2
          }}
        >
          {value ?? 'N/A'}
        </Typography>
      )}
    </Box>
  );
}

export default TarjetaMetrica;