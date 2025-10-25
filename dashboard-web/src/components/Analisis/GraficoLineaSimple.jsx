// src/components/Analisis/GraficoLineaSimple.jsx
import React from 'react';
import { Box, Skeleton, Typography, Paper, useTheme } from '@mui/material';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import ReportProblemIcon from '@mui/icons-material/ReportProblem';

function GraficoLineaSimple({ data, loading, dataKey = "value", xAxisKey = "name", strokeColor, lineName = "Valor" }) {
  // --- MODIFICADO: UI con useTheme ---
  const theme = useTheme();
  
  // Usar color primario del tema si no se especifica uno
  const color = strokeColor || theme.palette.primary.main;

 if (loading) {
     return (
         <Paper sx={{ p: 3, borderRadius: '12px', height: '100%', display: 'flex', flexDirection: 'column', minHeight: 300 }} elevation={3}>
              <Skeleton variant="text" width="60%" sx={{ mb: 2, alignSelf:'center' }} />
              <Box sx={{ flexGrow: 1, display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                 <Skeleton variant="rectangular" width="90%" height={250} />
              </Box>
         </Paper>
     );
  }

   if (!data || data.length === 0) {
     return (
         <Paper sx={{ p: 3, borderRadius: '12px', height: '100%', display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', textAlign:'center', minHeight: 300 }} elevation={3}>
              <ReportProblemIcon color="action" sx={{ fontSize: 40, my: 2 }}/>
              <Typography color="text.secondary">No hay datos para los filtros seleccionados.</Typography>
         </Paper>
     );
   }

  return (
    <Box sx={{ width: '100%', height: '100%', minHeight: 300 }}>
        <ResponsiveContainer width="100%" height="100%">
            <LineChart
                data={data}
                margin={{ top: 5, right: 20, left: -10, bottom: 5 }}
            >
                {/* --- UI Mejorada --- */}
                <CartesianGrid strokeDasharray="3 3" stroke={theme.palette.divider} opacity={0.5}/>
                <XAxis 
                  dataKey={xAxisKey} 
                  tick={{ fontSize: 12, fill: theme.palette.text.secondary }} 
                  stroke={theme.palette.divider}
                />
                <YAxis 
                  allowDecimals={false} 
                  tick={{ fontSize: 12, fill: theme.palette.text.secondary }} 
                  stroke={theme.palette.divider}
                />
                <Tooltip
                    contentStyle={{
                        backgroundColor: theme.palette.background.paper, // Fondo del tooltip
                        border: `1px solid ${theme.palette.divider}`,
                        borderRadius: '8px',
                        color: theme.palette.text.primary // Color del texto
                    }}
                    formatter={(value) => [`${value}`, undefined]}
                 />
                <Legend wrapperStyle={{ fontSize: 13, color: theme.palette.text.secondary }}/>
                <Line
                    type="monotone"
                    dataKey={dataKey}
                    stroke={color}
                    strokeWidth={2}
                    name={lineName}
                    dot={{ r: 4, fill: color }}
                    activeDot={{ r: 6, stroke: color }}
                 />
            </LineChart>
        </ResponsiveContainer>
    </Box>
  );
}

export default GraficoLineaSimple;