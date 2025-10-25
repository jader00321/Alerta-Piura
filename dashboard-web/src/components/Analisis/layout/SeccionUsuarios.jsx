// src/components/Analisis/layout/SeccionUsuarios.jsx
import React from 'react';
import { Grid, Typography } from '@mui/material';
import SeccionAnalisis from '../SeccionAnalisis';
import TablaRendimientoLideres from '../TablaRendimientoLideres';
import GraficoTortaSimple from '../GraficoTortaSimple';

const USER_STATUS_COLORS = { activo: '#4caf50', suspendido: '#f44336' };

const SeccionUsuarios = ({ refs, analyticsData, loading, getChartContext, filterState }) => {

    const leadCtx = getChartContext('leaderPerformance', null, filterState.filterName);
    const userCtx = getChartContext('usersByStatus', null, filterState.filterName);

    return (
        <>
            <Typography variant="h5" sx={{ mb: 2, fontWeight: 500 }}>Análisis de Usuarios y Líderes</Typography>
            <Grid container spacing={3}>
                <Grid item xs={12} lg={7}>
                    <SeccionAnalisis
                        elementRef={refs.leaderPerformance}
                        title={leadCtx.title}
                        description={leadCtx.desc}
                    >
                        <TablaRendimientoLideres data={analyticsData.leaderPerf || []} loading={loading}/>
                    </SeccionAnalisis>
                </Grid>
                <Grid item xs={12} lg={5}>
                    <SeccionAnalisis
                        elementRef={refs.usersByStatus}
                        title={userCtx.title}
                        description={userCtx.desc}
                    >
                        <GraficoTortaSimple data={analyticsData.usersByStatus || []} title="" loading={loading} colorMapping={USER_STATUS_COLORS} innerRadius="40%" outerRadius="75%"/>
                    </SeccionAnalisis>
                </Grid>
           </Grid>
        </>
    );
};

export default SeccionUsuarios;