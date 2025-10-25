// src/components/Analisis/TarjetaMetrica.jsx
import React from 'react';
import { Box, Typography, Skeleton, useTheme } from '@mui/material';

/**
 * Componente TarjetaMetrica - Muestra un valor métrico individual con estilo
 * 
 * @param {Object} props - Propiedades del componente
 * @param {string|number} props.value - Valor a mostrar (puede ser string, número o 'N/A')
 * @param {boolean} props.loading - Estado de carga para mostrar skeleton
 * 
 * @returns {JSX.Element} Componente de tarjeta métrica
 * 
 * @example
 * // Uso básico con número
 * <TarjetaMetrica value={1250} loading={false} />
 * 
 * @example
 * // Uso con string
 * <TarjetaMetrica value="1.2K" loading={false} />
 * 
 * @example
 * // Estado de carga
 * <TarjetaMetrica value={null} loading={true} />
 * 
 * @example
 * // Valor no disponible
 * <TarjetaMetrica value={null} loading={false} />
 */
function TarjetaMetrica({ value, loading }) {
  const theme = useTheme();
  
  /**
   * Determina el color del valor basado en su contenido
   * - Valores 'N/A' o nulos: color de texto deshabilitado
   * - Valores válidos: color primario del tema
   */
  const valueColor = value === 'N/A' || !value 
    ? theme.palette.text.disabled 
    : theme.palette.primary.main;

  return (
    <Box sx={{ 
      height: '100%', 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center',
      // MODIFICADO: Padding vertical eliminado para reducir altura
      py: 0 
    }}>
      {loading ? (
        // Estado de carga - skeleton
        <Skeleton 
          variant="rectangular" 
          width={120} 
          height={60} 
        />
      ) : (
        // Valor renderizado
        <Typography 
          variant="h2" 
          component="p" // Semánticamente correcto para valores
          sx={{ 
            fontWeight: 'bold', 
            color: valueColor,
            textAlign: 'center',
            lineHeight: 1.2, // Compacto para números
            my: 0 // Eliminar márgenes por defecto de h2
          }}
        >
          {/* Valor o 'N/A' si es nulo/undefined */}
          {value ?? 'N/A'}
        </Typography>
      )}
    </Box>
  );
}

export default TarjetaMetrica;