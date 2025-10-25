// src/components/Analisis/layout/SeccionMetricas.jsx
import React from 'react';
import { Grid, Typography } from '@mui/material';
import SeccionAnalisis from '../SeccionAnalisis';
import TarjetaMetrica from '../TarjetaMetrica';

/**
 * Componente SeccionMetricas - Layout especializado para mostrar métricas/KPIs
 * 
 * @param {Object} props - Propiedades del componente
 * @param {Object} props.refs - Objeto con referencias para las secciones
 * @param {Object} props.analyticsData - Datos de análisis para las métricas
 * @param {boolean} props.loading - Estado de carga para mostrar skeletons
 * @param {Function} props.getChartContext - Función para obtener contexto del gráfico (título, descripción)
 * @param {Object} props.filterState - Estado actual de los filtros
 * @param {number|string} props.contentMinHeight - Altura mínima personalizada para el contenido
 * 
 * @returns {JSX.Element} Layout de sección de métricas
 * 
 * @example
 * // Uso básico
 * <SeccionMetricas
 *   refs={sectionRefs}
 *   analyticsData={data}
 *   loading={false}
 *   getChartContext={getChartContext}
 *   filterState={filters}
 *   contentMinHeight={200}
 * />
 */
const SeccionMetricas = ({ 
  refs, 
  analyticsData, 
  loading, 
  getChartContext, 
  filterState, 
  contentMinHeight // <-- Prop recibida para controlar altura
}) => {
    
    // Obtener contexto (título y descripción) para la tarjeta de tiempo promedio
    const { title, desc } = getChartContext('avgTimeCard', null, filterState.filterName);

    return (
        <Grid container spacing={3} sx={{ mb: 4 }}>
            <Grid item xs={12} md={4}>
                <SeccionAnalisis
                    elementRef={refs.avgTimeCard}
                    title={title}
                    description={desc}
                    // MODIFICADO: Pasa la prop para anular la altura mínima por defecto
                    contentMinHeight={contentMinHeight} 
                >
                    <TarjetaMetrica
                        value={analyticsData?.avgTime || 'N/A'}
                        loading={loading}
                    />
                </SeccionAnalisis>
            </Grid>
            {/* Espacio reservado para futuras tarjetas KPI adicionales */}
        </Grid>
    );
};

export default SeccionMetricas;