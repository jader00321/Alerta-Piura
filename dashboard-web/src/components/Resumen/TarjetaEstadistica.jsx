// src/components/Resumen/TarjetaEstadistica.jsx
import React from 'react';
import { Grid, Paper, Typography, Box, Skeleton, Avatar, useTheme, alpha } from '@mui/material';

/**
 * TarjetaEstadistica - Diseño Profesional
 * Estilo "Glassy" sutil con icono en burbuja de color.
 */
function TarjetaEstadistica({ title, value, icon, color = 'primary', loading }) {
  const theme = useTheme();

  // Mapeo seguro de colores del tema
  const themeColor = theme.palette[color] ? theme.palette[color].main : theme.palette.primary.main;

  return (
    <Grid item xs={12} sm={6} md={4} lg={2.4}>
      <Paper
        elevation={0}
        sx={{
          p: 3,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between', // Separa icono y texto
          borderRadius: 3,
          border: `1px solid ${theme.palette.divider}`,
          transition: 'all 0.3s cubic-bezier(0.4, 0, 0.2, 1)',
          cursor: 'default',
          bgcolor: 'background.paper',
          // Efecto Hover: Elevación y cambio sutil de borde
          '&:hover': {
            transform: 'translateY(-4px)',
            boxShadow: theme.shadows[4],
            borderColor: theme.palette.primary.light,
          }
        }}
      >
        <Box sx={{ overflow: 'hidden', mr: 2 }}>
          <Typography 
            variant="caption" 
            color="text.secondary" 
            sx={{ fontWeight: 600, textTransform: 'uppercase', letterSpacing: 0.5, fontSize: '0.7rem' }} 
            noWrap
          >
            {loading ? <Skeleton width="80%" /> : title}
          </Typography>
          
          <Typography 
            variant="h4" 
            component="div" 
            sx={{ fontWeight: 800, mt: 0.5, color: 'text.primary' }} 
            noWrap
          >
            {loading ? <Skeleton width="50%" /> : value ?? '0'}
          </Typography>
        </Box>

        {/* Icono en burbuja con color suave */}
        <Avatar
          variant="rounded"
          sx={{
            bgcolor: alpha(themeColor, 0.1), // Fondo transparente del color
            color: themeColor,               // Icono del color intenso
            width: 56,
            height: 56,
            borderRadius: 2
          }}
        >
          {loading ? (
            <Skeleton variant="circular" width={24} height={24} />
          ) : (
            React.cloneElement(icon, { fontSize: 'medium' })
          )}
        </Avatar>
      </Paper>
    </Grid>
  );
}

export default TarjetaEstadistica;