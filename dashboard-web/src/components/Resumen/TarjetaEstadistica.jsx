// src/components/Resumen/TarjetaEstadistica.jsx
import React from 'react';
import { Grid, Paper, Typography, Box, Skeleton } from '@mui/material'; // Added Skeleton for loading

function TarjetaEstadistica({ title, value, icon, color = 'primary', loading }) {
  return (
    // Ajusta los breakpoints (lg={2.4}) para que quepan 5 en una fila en pantallas grandes
    <Grid item xs={12} sm={6} md={4} lg={2.4}>
      <Paper
        elevation={2} // Sombra más sutil
        sx={{
          p: 2.5,
          display: 'flex',
          alignItems: 'center',
          borderRadius: '12px', // Bordes redondeados
          overflow: 'hidden', // Para efectos de borde
          position: 'relative',
          minHeight: '100px',
          // Borde de color sutil a la izquierda
          '&:before': {
             content: '""',
             position: 'absolute',
             left: 0,
             top: 0,
             bottom: 0,
             width: '4px',
             backgroundColor: `${color}.main`,
           }
        }}
      >
        <Box sx={{ mr: 2, color: `${color}.main`, display: 'flex' }}>
          {React.cloneElement(icon, { sx: { fontSize: 40 } })}
        </Box>
        <Box sx={{ overflow: 'hidden' }}>
          <Typography variant="body2" color="text.secondary" noWrap>
            {loading ? <Skeleton width="80%" /> : title}
          </Typography>
          <Typography variant="h4" component="p" sx={{ fontWeight: 'bold' }} noWrap>
            {loading ? <Skeleton width="50%" /> : value ?? '0'}
          </Typography>
        </Box>
      </Paper>
    </Grid>
  );
}

export default TarjetaEstadistica;