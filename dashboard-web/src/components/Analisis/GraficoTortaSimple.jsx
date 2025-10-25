// src/components/Analisis/GraficoTortaSimple.jsx
import React, { useMemo } from 'react';
import { Paper, Typography, Box, Skeleton, useTheme } from '@mui/material';
import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import ReportProblemIcon from '@mui/icons-material/ReportProblem';

function GraficoTortaSimple({ data, loading, title, colorMapping = {}, innerRadius = "45%", outerRadius = "80%" }) {
  const theme = useTheme();

  const fallbackColors = [
    theme.palette.primary.main,
    theme.palette.secondary.main,
    theme.palette.success.main,
    theme.palette.warning.main,
    theme.palette.info.main,
    theme.palette.error.main,
  ];

  // --- MODIFICADO: Pre-calcular total y porcentajes para evitar NaN% ---
  const { dataWithPercent, total } = useMemo(() => {
    if (!data || data.length === 0) {
      return { dataWithPercent: [], total: 0 };
    }
    const filteredData = data.filter(entry => entry.value > 0);
    const totalValue = filteredData.reduce((acc, entry) => acc + entry.value, 0);
    
    const augmentedData = filteredData.map(entry => ({
      ...entry,
      // Añadimos el porcentaje pre-calculado y seguro
      percent: totalValue > 0 ? (entry.value / totalValue) : 0 
    }));
    
    return { dataWithPercent: augmentedData, total: totalValue };
  }, [data]);


  if (loading) {
     return (
         <Paper sx={{ p: 3, borderRadius: '12px', height: '100%', display: 'flex', flexDirection: 'column', minHeight: 300 }} elevation={3}>
              <Skeleton variant="text" width="60%" sx={{ mb: 2, alignSelf:'center' }} />
              <Box sx={{ flexGrow: 1, display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
                 <Skeleton variant="circular" width={150} height={150} />
              </Box>
         </Paper>
     );
  }

  // --- MODIFICADO: Usar el 'total' pre-calculado ---
  if (total === 0) {
     return (
         <Paper sx={{ p: 3, borderRadius: '12px', height: '100%', display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', textAlign:'center', minHeight: 300 }} elevation={3}>
            {title && <Typography variant="h6" gutterBottom sx={{ fontWeight: 500 }}>{title}</Typography>}
              <ReportProblemIcon color="action" sx={{ fontSize: 40, my: 2 }}/>
              <Typography color="text.secondary">No hay datos para los filtros seleccionados.</Typography>
         </Paper>
     );
   }

  return (
    <Paper sx={{ p: 3, height: '100%', borderRadius: '12px', overflow: 'hidden', display:'flex', flexDirection:'column', minHeight: 300 }} elevation={3}>
        {title && (
          <Typography variant="h6" gutterBottom sx={{ fontWeight: 500, textAlign: 'center' }}>
            {title}
          </Typography>
        )}
        <Box sx={{ flexGrow: 1 }}>
            <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                    <Pie
                        // --- MODIFICADO: Usar 'dataWithPercent' ---
                        data={dataWithPercent}
                        cx="50%" cy="50%" labelLine={false}
                        outerRadius={outerRadius} innerRadius={innerRadius}
                        fill="#8884d8" dataKey="value" paddingAngle={1}
                        // --- NUEVO: Etiqueta interna con texto blanco ---
                        label={({ cx, cy, midAngle, innerRadius, outerRadius, payload }) => {
                            const percent = payload.percent; // Usar el 'percent' seguro
                            if (percent < 0.05) return null; // Ocultar si es muy pequeño
                            const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
                            const x = cx + radius * Math.cos(-midAngle * (Math.PI / 180));
                            const y = cy + radius * Math.sin(-midAngle * (Math.PI / 180));
                            return (
                                <text x={x} y={y} fill="white" textAnchor="middle" dominantBaseline="central" fontSize="14px" fontWeight="bold">
                                    {`${(percent * 100).toFixed(0)}%`}
                                </text>
                            );
                        }}
                    >
                        {dataWithPercent.map((entry, index) => (
                            <Cell 
                              key={`cell-${index}`} 
                              fill={colorMapping[entry.name] || fallbackColors[index % fallbackColors.length]} 
                            />
                        ))}
                    </Pie>
                    <Tooltip
                        contentStyle={{ 
                          backgroundColor: theme.palette.background.paper, 
                          border: `1px solid ${theme.palette.divider}`, 
                          borderRadius: '8px',
                          color: theme.palette.text.primary
                        }}
                        // --- MODIFICADO: Tooltip usa el 'percent' seguro ---
                        formatter={(value, name, props) => {
                          const percent = props.payload.percent || 0; // Usar el 'percent' seguro
                          return [
                            `${value} (${(percent * 100).toFixed(0)}%)`,
                            name
                          ];
                        }}
                    />
                    <Legend 
                      iconType="circle" 
                      verticalAlign="bottom" 
                      height={36} 
                      wrapperStyle={{ fontSize: 13, color: theme.palette.text.secondary, paddingTop: '10px' }}
                    />
                </PieChart>
            </ResponsiveContainer>
        </Box>
    </Paper>
  );
}

export default GraficoTortaSimple;