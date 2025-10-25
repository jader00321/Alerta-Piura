// src/components/Analisis/layout/SeccionMetricas.jsx
import React from 'react';
import { Grid, Typography } from '@mui/material';
import SeccionAnalisis from '../SeccionAnalisis';
import TarjetaMetrica from '../TarjetaMetrica';

// --- MODIFICADO: Acepta y usa 'contentMinHeight' ---
const SeccionMetricas = ({ 
  refs, 
  analyticsData, 
  loading, 
  getChartContext, 
  filterState, 
  contentMinHeight // <-- Prop recibida
}) => {
    
    const { title, desc } = getChartContext('avgTimeCard', null, filterState.filterName);

    return (
        <Grid container spacing={3} sx={{ mb: 4 }}>
            <Grid item xs={12} md={4}>
                <SeccionAnalisis
                    elementRef={refs.avgTimeCard}
                    title={title}
                    description={desc}
                    // --- MODIFICADO: Pasa la prop para anular la altura mínima ---
                    contentMinHeight={contentMinHeight} 
                >
                    <TarjetaMetrica
                        value={analyticsData?.avgTime || 'N/A'}
                        loading={loading}
                    />
                </SeccionAnalisis>
            </Grid>
            {/* Puedes añadir más tarjetas KPI aquí si las creas */}
        </Grid>
    );
};

export default SeccionMetricas;