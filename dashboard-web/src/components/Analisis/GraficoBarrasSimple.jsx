// src/components/Analisis/GraficoBarrasSimple.jsx
import React from 'react';
import { Box, Skeleton, Typography, Paper, useTheme } from '@mui/material';
// --- MODIFICADO: Importar 'Cell' ---
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import ReportProblemIcon from '@mui/icons-material/ReportProblem';

// --- MODIFICADO: Añadir prop 'colorMapping' ---
function GraficoBarrasSimple({
  data,
  loading,
  dataKey = "value",
  xAxisKey = "name",
  fillColor, // Color por defecto si no hay mapping
  //colorMapping = {}, // Objeto para colores específicos por 'name'
  barName = "Total"
}) {
  const theme = useTheme();
  
  // Color de fallback si no hay 'fillColor' ni 'colorMapping'
  const defaultColor = fillColor || theme.palette.secondary.main;

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
            <BarChart
                data={data}
                margin={{ top: 5, right: 10, left: -15, bottom: 5 }}
                // --- MODIFICADO: Layout vertical (horizontal bars) por defecto ---
                layout="vertical"
            >
                <CartesianGrid strokeDasharray="3 3" stroke={theme.palette.divider} opacity={0.5}/>
                <XAxis 
                  type="number" 
                  tick={{ fontSize: 12, fill: theme.palette.text.secondary }} 
                  stroke={theme.palette.divider}
                  // Asegurar que solo muestre enteros si aplica
                  allowDecimals={false} 
                />
                <YAxis 
                  dataKey={xAxisKey} 
                  type="category" 
                  tick={{ fontSize: 12, fill: theme.palette.text.secondary }} 
                  stroke={theme.palette.divider}
                  width={100} // Ajustar ancho según necesidad
                  interval={0}
                />
                <Tooltip
                    contentStyle={{
                        backgroundColor: theme.palette.background.paper,
                        border: `1px solid ${theme.palette.divider}`,
                        borderRadius: '8px',
                        color: theme.palette.text.primary
                    }}
                     // Formato tooltip mejorado: "Estado: Valor"
                     formatter={(value, name) => [`${value}`, name]} // 'name' es la categoría (Estado)
                     labelFormatter={(label) => `Estado: ${label}`} // Opcional: Título del tooltip
                />
                {/* --- MODIFICADO: Usar Cell para colores individuales --- */}
                <Bar
                    dataKey={dataKey}
                    fill={defaultColor} // Usar color dinámico
                    name={barName}
                    radius={[0, 4, 4, 0]} 
                    barSize={25}
                 />
            </BarChart>
        </ResponsiveContainer>
    </Box>
  );
}

export default GraficoBarrasSimple;