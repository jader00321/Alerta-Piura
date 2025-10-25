// src/components/Analisis/GraficoTasaAprobacion.jsx
import React, { useMemo } from 'react';
import { Paper, Typography, Box, Skeleton, useTheme } from '@mui/material';
import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';

const APPROVAL_COLORS = {
  Aprobados: '#4caf50',
  Rechazados: '#f44336',
};

function GraficoTasaAprobacion({ statusData, loading }) {
  const theme = useTheme();

  // Esta lógica pre-calcula el porcentaje y soluciona el NaN%
  const { approvalData, totalModerated } = useMemo(() => {
    if (!statusData || statusData.length === 0) {
      return { approvalData: [], totalModerated: 0 };
    }

    const verified = statusData.find(d => d.name === 'Verificado')?.value || 0;
    const rejected = statusData.find(d => d.name === 'Rechazado')?.value || 0;
    const total = verified + rejected;

    if (total === 0) {
      return { approvalData: [], totalModerated: 0 };
    }

    const data = [
      { name: 'Aprobados', value: verified, percent: (verified / total) },
      { name: 'Rechazados', value: rejected, percent: (rejected / total) }
    ];
    
    return { approvalData: data, totalModerated: total };

  }, [statusData]);

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

 if (totalModerated === 0) {
     return (
         <Paper sx={{ p: 3, borderRadius: '12px', height: '100%', display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center', textAlign:'center', minHeight: 300 }} elevation={3}>
              <CheckCircleIcon color="action" sx={{ fontSize: 40, my: 2 }}/>
              <Typography color="text.secondary">No hay reportes moderados (aprobados/rechazados) en este periodo.</Typography>
         </Paper>
     );
 }

  return (
    <Paper sx={{ p: 3, height: '100%', borderRadius: '12px', overflow: 'hidden', display:'flex', flexDirection:'column', minHeight: 300 }} elevation={3}>
        <Box sx={{ flexGrow: 1 }}>
            <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                    <Pie
                        data={approvalData}
                        cx="50%" cy="50%" labelLine={false}
                        outerRadius="80%" innerRadius="45%"
                        fill="#8884d8" dataKey="value"
                        // --- Etiqueta interna con 'fill="white"' ---
                        label={({ cx, cy, midAngle, innerRadius, outerRadius, payload }) => {
                            const percent = payload.percent; 
                            const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
                            const x = cx + radius * Math.cos(-midAngle * (Math.PI / 180));
                            const y = cy + radius * Math.sin(-midAngle * (Math.PI / 180));
                            return (
                                <text 
                                  x={x} y={y} 
                                  fill="white" // <-- Color blanco
                                  textAnchor="middle" 
                                  dominantBaseline="central" 
                                  fontSize="14px" 
                                  fontWeight="bold"
                                >
                                    {`${(percent * 100).toFixed(0)}%`}
                                </text>
                            );
                        }}
                    >
                        {approvalData.map((entry) => (
                            <Cell key={`cell-${entry.name}`} fill={APPROVAL_COLORS[entry.name]} />
                        ))}
                    </Pie>
                    <Tooltip
                        contentStyle={{ 
                          backgroundColor: theme.palette.background.paper, 
                          border: `1px solid ${theme.palette.divider}`, 
                          borderRadius: '8px',
                          color: theme.palette.text.primary
                        }}
                        // --- Tooltip mejorado que usa el 'percent' seguro ---
                        formatter={(value, name, props) => {
                          const percent = props.payload.percent || 0;
                          return [`${value} (${(percent * 100).toFixed(0)}%)`, name];
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

export default GraficoTasaAprobacion;