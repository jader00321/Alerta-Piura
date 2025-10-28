// src/components/Analisis/layout/SeccionReportes.jsx

import React from 'react';
import { Grid, Typography } from '@mui/material';
import SeccionAnalisis from '../SeccionAnalisis';
import GraficoLineaSimple from '../GraficoLineaSimple';
import GraficoTendenciaVerificacion from '../GraficoTendenciaVerificacion';
import GraficoBarrasSimple from '../GraficoBarrasSimple';
import GraficoTortaSimple from '../GraficoTortaSimple';
import GraficoTasaAprobacion from '../GraficoTasaAprobacion';

/**
 * Mapa de colores asociados al estado de los reportes.
 * @constant
 * @type {Object<string, string>}
 * @example
 * STATUS_COLORS.Pendiente // '#ff9800'
 */
const STATUS_COLORS = { 
  Pendiente: '#ff9800', 
  Verificado: '#4caf50', 
  Rechazado: '#f44336', 
  Oculto: '#9e9e9e', 
  Otro: '#607d8b' 
};

/**
 * Componente que renderiza la sección de análisis de reportes en el panel de analítica.
 * Incluye gráficos de tendencias, distribuciones y tasas de aprobación.
 * 
 * @component
 * @param {Object} props - Propiedades del componente.
 * @param {Object} props.refs - Referencias a los elementos de cada sección (para exportar o scroll).
 * @param {Object} props.analyticsData - Datos analíticos que alimentan los gráficos.
 * @param {boolean} props.loading - Estado de carga; si es `true`, muestra skeletons.
 * @param {Function} props.getChartContext - Función que genera contexto (título, descripción) para cada gráfico.
 * @param {Object} props.filterState - Estado de filtros aplicados (como `filterName`).
 * 
 * @returns {JSX.Element} Retorna un conjunto de gráficos dentro de un grid con secciones descriptivas.
 * 
 * @example
 * <SeccionReportes
 *   refs={{ reportTrend: ref1, verificationTrend: ref2 }}
 *   analyticsData={data}
 *   loading={false}
 *   getChartContext={(id, data, filter) => ({ title: "Ejemplo", desc: "Descripción" })}
 *   filterState={{ filterName: "General" }}
 * />
 */
const SeccionReportes = ({ refs, analyticsData, loading, getChartContext, filterState }) => {
    
    //   CONTEXTOS DE CADA SECCIÓN

    /**
     * Contexto para la tendencia de reportes.
     * @constant
     * @type {{title: string, desc: string}}
     */
    const trendCtx = getChartContext('reportTrend', analyticsData.reportTrend, filterState.filterName);

    /**
     * Contexto para la tendencia de verificación.
     * @constant
     * @type {{title: string, desc: string}}
     */
    const verifCtx = getChartContext('verificationTrend', analyticsData.verificationTrend, filterState.filterName);

    /**
     * Contexto para la distribución por categoría.
     * @constant
     * @type {{title: string, desc: string}}
     */
    const catCtx = getChartContext('byCategory', null, filterState.filterName);

    /**
     * Contexto para la distribución por estado.
     * @constant
     * @type {{title: string, desc: string}}
     */
    const statCtx = getChartContext('byStatus', null, filterState.filterName);

    /**
     * Contexto para la distribución por distrito.
     * @constant
     * @type {{title: string, desc: string}}
     */
    const distCtx = getChartContext('byDistrict', null, filterState.filterName);

    /**
     * Contexto para la tasa de aprobación.
     * @constant
     * @type {{title: string, desc: string}}
     */
    const apprCtx = getChartContext('approvalRate', null, filterState.filterName);

 
    //   RENDER PRINCIPAL


    return (
        <>
            <Typography variant="h5" sx={{ mb: 2, fontWeight: 500 }}>
                Análisis de Reportes
            </Typography>

            <Grid container spacing={3}>

                {/* FILA 1: TENDENCIAS */}
                 
                <Grid item xs={12} md={6}>
                    <SeccionAnalisis
                        elementRef={refs.reportTrend}
                        title={trendCtx.title}
                        description={trendCtx.desc}
                    >
                        <GraficoLineaSimple 
                            data={analyticsData.reportTrend.data || []} 
                            loading={loading} 
                            dataKey="value" 
                            xAxisKey="name" 
                            strokeColor="#8884d8"
                        />
                    </SeccionAnalisis>
                </Grid>

                <Grid item xs={12} md={6}>
                    <SeccionAnalisis
                        elementRef={refs.verificationTrend}
                        title={verifCtx.title}
                        description={verifCtx.desc}
                    >
                        <GraficoTendenciaVerificacion 
                            data={analyticsData.verificationTrend.data || []} 
                            loading={loading}
                        />
                    </SeccionAnalisis>
                </Grid>

                {/* FILA 2: DISTRIBUCIONES PRINCIPALES */}
                <Grid item xs={12} lg={7}>
                    <SeccionAnalisis
                        elementRef={refs.byCategory}
                        title={catCtx.title}
                        description={catCtx.desc}
                    >
                        <GraficoBarrasSimple 
                            data={analyticsData.byCategory || []} 
                            loading={loading} 
                            dataKey="value" 
                            xAxisKey="name" 
                            fillColor="#8884d8"
                        />
                    </SeccionAnalisis>
                </Grid>

                <Grid item xs={12} lg={5}>
                    <SeccionAnalisis
                        elementRef={refs.byStatus}
                        title={statCtx.title}
                        description={statCtx.desc}
                    >
                        <GraficoTortaSimple 
                            data={analyticsData.byStatus || []} 
                            title="" 
                            loading={loading} 
                            colorMapping={STATUS_COLORS} 
                            innerRadius="40%" 
                            outerRadius="75%"
                        />
                    </SeccionAnalisis>
                </Grid>

                {/* FILA 3: DISTRIBUCIÓN SECUNDARIA */}
                    

                <Grid item xs={12} lg={7}>
                    <SeccionAnalisis
                        elementRef={refs.byDistrict}
                        title={distCtx.title}
                        description={distCtx.desc}
                    >
                        <GraficoBarrasSimple 
                            data={analyticsData.byDistrict || []} 
                            loading={loading} 
                            dataKey="value" 
                            xAxisKey="name" 
                            fillColor="#00C49F"
                        />
                    </SeccionAnalisis>
                </Grid>

                <Grid item xs={12} lg={5}>
                    <SeccionAnalisis
                        elementRef={refs.approvalRate}
                        title={apprCtx.title}
                        description={apprCtx.desc}
                    >
                        <GraficoTasaAprobacion 
                            statusData={analyticsData.byStatus || []} 
                            loading={loading} 
                        />
                    </SeccionAnalisis>
                </Grid>
            </Grid>
        </>
    );
};

export default SeccionReportes;
