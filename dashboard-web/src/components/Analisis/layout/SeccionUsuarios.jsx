// src/components/Analisis/layout/SeccionUsuarios.jsx
import React from 'react';
import { Grid, Typography } from '@mui/material';
import SeccionAnalisis from '../SeccionAnalisis';
import TablaRendimientoLideres from '../TablaRendimientoLideres';
import GraficoTortaSimple from '../GraficoTortaSimple';

/**
 * Mapeo de colores para los estados de usuario
 * Define los colores semánticos para cada estado en el gráfico circular
 */
const USER_STATUS_COLORS = { 
  activo: '#4caf50',      // Verde para usuarios activos
  suspendido: '#f44336'   // Rojo para usuarios suspendidos
};

/**
 * Componente SeccionUsuarios - Layout para análisis de usuarios y líderes
 * 
 * @param {Object} props - Propiedades del componente
 * @param {Object} props.refs - Objeto con referencias para las secciones
 * @param {Object} props.analyticsData - Datos de análisis para usuarios y líderes
 * @param {boolean} props.loading - Estado de carga para mostrar skeletons
 * @param {Function} props.getChartContext - Función para obtener contexto del gráfico
 * @param {Object} props.filterState - Estado actual de los filtros
 * 
 * @returns {JSX.Element} Layout de sección de usuarios y líderes
 * 
 * @example
 * // Uso básico
 * <SeccionUsuarios
 *   refs={sectionRefs}
 *   analyticsData={userData}
 *   loading={false}
 *   getChartContext={getChartContext}
 *   filterState={filters}
 * />
 */
const SeccionUsuarios = ({ refs, analyticsData, loading, getChartContext, filterState }) => {

    // Obtener contexto para las diferentes visualizaciones
    const leadCtx = getChartContext('leaderPerformance', null, filterState.filterName);
    const userCtx = getChartContext('usersByStatus', null, filterState.filterName);

    return (
        <>
            {/* Título principal de la sección */}
            <Typography variant="h5" sx={{ mb: 2, fontWeight: 500 }}>
                Análisis de Usuarios y Líderes
            </Typography>
            
            {/* Grid layout para las visualizaciones */}
            <Grid container spacing={3}>
                {/* Columna izquierda - Tabla de rendimiento de líderes */}
                <Grid item xs={12} lg={7}>
                    <SeccionAnalisis
                        elementRef={refs.leaderPerformance}
                        title={leadCtx.title}
                        description={leadCtx.desc}
                    >
                        <TablaRendimientoLideres 
                            data={analyticsData.leaderPerf || []} 
                            loading={loading}
                        />
                    </SeccionAnalisis>
                </Grid>
                
                {/* Columna derecha - Gráfico circular de estados de usuario */}
                <Grid item xs={12} lg={5}>
                    <SeccionAnalisis
                        elementRef={refs.usersByStatus}
                        title={userCtx.title}
                        description={userCtx.desc}
                    >
                        <GraficoTortaSimple 
                            data={analyticsData.usersByStatus || []} 
                            title="" // Título vacío porque ya está en SeccionAnalisis
                            loading={loading} 
                            colorMapping={USER_STATUS_COLORS} 
                            innerRadius="40%" 
                            outerRadius="75%"
                        />
                    </SeccionAnalisis>
                </Grid>
           </Grid>
        </>
    );
};

export default SeccionUsuarios;