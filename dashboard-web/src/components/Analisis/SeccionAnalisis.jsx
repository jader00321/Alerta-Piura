// src/components/Analisis/SeccionAnalisis.jsx
import React from 'react';
import { Paper, Typography, Box, Skeleton } from '@mui/material';

/**
 * Componente SeccionAnalisis - Contenedor reutilizable para secciones de análisis
 * 
 * @param {Object} props - Propiedades del componente
 * @param {string} props.title - Título de la sección
 * @param {string} props.description - Descripción opcional de la sección
 * @param {ReactNode} props.children - Contenido de la sección
 * @param {React.Ref} props.elementRef - Referencia para el contenedor principal
 * @param {boolean} props.loading - Estado de carga para mostrar skeletons
 * @param {number|string} props.contentMinHeight - Altura mínima del área de contenido (por defecto: 300)
 * 
 * @returns {JSX.Element} Componente de sección de análisis
 * 
 * @example
 * // Uso básico
 * <SeccionAnalisis 
 *   title="Análisis de Ventas"
 *   description="Distribución de ventas por categoría"
 *   loading={false}
 * >
 *   <GraficoTortaSimple data={data} />
 * </SeccionAnalisis>
 * 
 * @example
 * // Con altura personalizada y referencia
 * <SeccionAnalisis 
 *   title="Dashboard"
 *   contentMinHeight={400}
 *   elementRef={dashboardRef}
 *   loading={isLoading}
 * >
 *   <MiGraficoPersonalizado />
 * </SeccionAnalisis>
 */
function SeccionAnalisis({ 
  title, 
  description, 
  children, 
  elementRef, 
  loading, 
  contentMinHeight = 300 // Altura por defecto para gráficos
}) {

  return (
    <Paper 
      ref={elementRef}
      sx={{ 
        p: { xs: 1.5, sm: 2, md: 3 }, 
        mb: 4, 
        borderRadius: '12px', 
        height: '100%', 
        display: 'flex', 
        flexDirection: 'column' 
      }} 
      elevation={3}
    >
      {/* Encabezado de la sección */}
      <Box sx={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'flex-start', 
        mb: 2, 
        gap: 1 
      }}>
        <Box sx={{ flexGrow: 1 }}>
          {/* Título con skeleton loading */}
          <Typography variant="h6" gutterBottom sx={{ fontWeight: 500 }}>
            {loading ? <Skeleton width="60%" /> : title}
          </Typography>
          
          {/* Descripción opcional con skeleton loading */}
          {description && (
            <Typography variant="body2" color="text.secondary">
              {loading ? <Skeleton width="80%" /> : description}
            </Typography>
          )}
        </Box>
      </Box>
      
      {/* Área de contenido principal */}
      {/* MODIFICADO: 'minHeight' ahora es dinámico según la prop contentMinHeight */}
      <Box sx={{ 
        flexGrow: 1, 
        minHeight: contentMinHeight 
      }}>
        {children}
      </Box>
    </Paper>
  );
}

// Display name para mejor debugging en React DevTools
SeccionAnalisis.displayName = 'SeccionAnalisis'; 

export default SeccionAnalisis;