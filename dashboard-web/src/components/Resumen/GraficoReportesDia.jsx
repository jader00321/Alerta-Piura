// src/components/Resumen/GraficoReportesDia.jsx
import React from 'react';
import { Paper, Typography, Box, Skeleton, useTheme } from '@mui/material'; // <-- Import useTheme
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import BarChartIcon from '@mui/icons-material/BarChart'; // Icon for empty state

function GraficoReportesDia({ chartData, loading }) {
    // --- MODIFICADO: UI con useTheme ---
    const theme = useTheme();

    if (loading) {
        return (
             <Paper sx={{ p: 3, borderRadius: '12px', height: { xs: 300, md: 400 }, display:'flex', flexDirection:'column' }} elevation={3}>
                  <Skeleton variant="text" width="60%" sx={{ mb: 2 }} />
                  <Skeleton variant="rectangular" width="100%" height={250} />
             </Paper>
        );
    }

    // --- MODIFICADO: Estado vacío mejorado ---
    if (!chartData || chartData.length === 0) {
        return (
             <Paper sx={{ p: 3, borderRadius: '12px', height: { xs: 300, md: 400 }, display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', textAlign:'center' }} elevation={3}>
                <Typography variant="h6" gutterBottom sx={{ fontWeight: 500 }}>
                    Actividad de Reportes
                 </Typography>
                  <BarChartIcon color="action" sx={{ fontSize: 40, my: 2 }}/>
                  <Typography color="text.secondary">No hay datos de actividad reciente para mostrar.</Typography>
             </Paper>
        );
    }


    return (
        <Paper sx={{ p: 3, height: { xs: 300, md: 400 }, borderRadius: '12px', overflow: 'hidden', display:'flex', flexDirection:'column',minWidth: '750px' }} elevation={3}>
            <Typography variant="h6" gutterBottom sx={{ fontWeight: 500 }}>
                Actividad de Reportes (Últimos 7 Días)
            </Typography>
            <Box sx={{ height: 'calc(100% - 40px)' }}>
                <ResponsiveContainer width="100%" height="100%">
                    <BarChart
                        data={chartData}
                        margin={{ top: 5, right: 10, left: -15, bottom: 5 }}
                    >
                        {/* --- UI Mejorada --- */}
                        <CartesianGrid strokeDasharray="3 3" stroke={theme.palette.divider} opacity={0.5}/>
                        <XAxis
                            dataKey="date"
                            tick={{ fontSize: 12, fill: theme.palette.text.secondary }}
                            stroke={theme.palette.divider}
                         />
                        <YAxis
                            allowDecimals={false} // Solo números enteros
                            tick={{ fontSize: 12, fill: theme.palette.text.secondary }}
                            stroke={theme.palette.divider}
                         />
                        <Tooltip
                            contentStyle={{
                                backgroundColor: theme.palette.background.paper,
                                border: `1px solid ${theme.palette.divider}`,
                                borderRadius: '8px',
                                color: theme.palette.text.primary // Color texto tooltip
                            }}
                            // Formato tooltip mejorado: "Fecha: Valor"
                            formatter={(value) => [`${value}`, "Nuevos Reportes"]} // Muestra "Nuevos Reportes: 1"
                            labelFormatter={(label) => `Fecha: ${label}`} // Muestra "Fecha: 18 oct"
                        />
                        <Legend wrapperStyle={{ fontSize: 13, color: theme.palette.text.secondary }}/>
                        <Bar
                            dataKey="count"
                            fill={theme.palette.primary.main} // Usar color primario del tema
                            name="Nuevos Reportes"
                            radius={[4, 4, 0, 0]}
                            barSize={40}
                        />
                    </BarChart>
                </ResponsiveContainer>
            </Box>
        </Paper>
    );
}

export default GraficoReportesDia;