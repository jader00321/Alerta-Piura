// src/components/Analisis/layout/SeccionReportes.jsx
import React from 'react';
import { Grid, Typography } from '@mui/material';
import SeccionAnalisis from '../SeccionAnalisis';
import GraficoLineaSimple from '../GraficoLineaSimple';
import GraficoTendenciaVerificacion from '../GraficoTendenciaVerificacion';
import GraficoBarrasSimple from '../GraficoBarrasSimple';
import GraficoTortaSimple from '../GraficoTortaSimple';
import GraficoTasaAprobacion from '../GraficoTasaAprobacion';

const STATUS_COLORS = { Pendiente: '#ff9800', Verificado: '#4caf50', Rechazado: '#f44336', Oculto: '#9e9e9e', Otro: '#607d8b' };

const SeccionReportes = ({ refs, analyticsData, loading, getChartContext, filterState }) => {
    
    // Obtener contextos dinámicos
    const trendCtx = getChartContext('reportTrend', analyticsData.reportTrend, filterState.filterName);
    const verifCtx = getChartContext('verificationTrend', analyticsData.verificationTrend, filterState.filterName);
    const catCtx = getChartContext('byCategory', null, filterState.filterName);
    const statCtx = getChartContext('byStatus', null, filterState.filterName);
    const distCtx = getChartContext('byDistrict', null, filterState.filterName);
    const apprCtx = getChartContext('approvalRate', null, filterState.filterName);

    return (
        <>
            <Typography variant="h5" sx={{ mb: 2, fontWeight: 500 }}>Análisis de Reportes</Typography>
            <Grid container spacing={3}>
                {/* Fila 1: Tendencias */}
                <Grid item xs={12} md={6}>
                    <SeccionAnalisis
                        elementRef={refs.reportTrend}
                        title={trendCtx.title}
                        description={trendCtx.desc}
                    >
                        <GraficoLineaSimple data={analyticsData.reportTrend.data || []} loading={loading} dataKey="value" xAxisKey="name" strokeColor="#8884d8"/>
                    </SeccionAnalisis>
                </Grid>
                <Grid item xs={12} md={6}>
                    <SeccionAnalisis
                        elementRef={refs.verificationTrend}
                        title={verifCtx.title}
                        description={verifCtx.desc}
                    >
                        <GraficoTendenciaVerificacion data={analyticsData.verificationTrend.data || []} loading={loading}/>
                    </SeccionAnalisis>
                </Grid>
                
                {/* Fila 2: Distribuciones Principales */}
                <Grid item xs={12} lg={7}>
                    <SeccionAnalisis
                        elementRef={refs.byCategory}
                        title={catCtx.title}
                        description={catCtx.desc}
                    >
                        <GraficoBarrasSimple data={analyticsData.byCategory || []} loading={loading} dataKey="value" xAxisKey="name" fillColor="#8884d8"/>
                    </SeccionAnalisis>
                </Grid>
                <Grid item xs={12} lg={5}>
                    <SeccionAnalisis
                        elementRef={refs.byStatus}
                        title={statCtx.title}
                        description={statCtx.desc}
                    >
                        <GraficoTortaSimple data={analyticsData.byStatus || []} title="" loading={loading} colorMapping={STATUS_COLORS} innerRadius="40%" outerRadius="75%"/>
                    </SeccionAnalisis>
                </Grid>

                {/* Fila 3: Distribución Secundaria */}
                <Grid item xs={12} lg={7}>
                    <SeccionAnalisis
                        elementRef={refs.byDistrict}
                        title={distCtx.title}
                        description={distCtx.desc}
                    >
                        <GraficoBarrasSimple data={analyticsData.byDistrict || []} loading={loading} dataKey="value" xAxisKey="name" fillColor="#00C49F"/>
                    </SeccionAnalisis>
                </Grid>
                <Grid item xs={12} lg={5}>
                    <SeccionAnalisis
                        elementRef={refs.approvalRate}
                        title={apprCtx.title}
                        description={apprCtx.desc}
                    >
                        <GraficoTasaAprobacion statusData={analyticsData.byStatus || []} loading={loading} />
                    </SeccionAnalisis>
                </Grid>
            </Grid>
        </>
    );
};

export default SeccionReportes;