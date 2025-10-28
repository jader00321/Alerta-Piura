// src/components/Analisis/GraficoTortaSimple.jsx
import React, { useMemo } from 'react';
import { Paper, Typography, Box, Skeleton, useTheme } from '@mui/material';
import { PieChart, Pie, Cell, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import ReportProblemIcon from '@mui/icons-material/ReportProblem';

/**
 * Componente GraficoTortaSimple - Gráfico circular (pie chart) para visualización de datos
 * 
 * @param {Object} props - Propiedades del componente
 * @param {Array} props.data - Datos para el gráfico en formato [{ name: string, value: number }]
 * @param {boolean} props.loading - Estado de carga para mostrar skeleton
 * @param {string} props.title - Título del gráfico
 * @param {Object} props.colorMapping - Mapeo personalizado de colores para las categorías
 * @param {string} props.innerRadius - Radio interno del gráfico (para donut chart)
 * @param {string} props.outerRadius - Radio externo del gráfico
 * 
 * @returns {JSX.Element} Componente de gráfico circular
 * 
 * @example
 * // Uso básico
 * <GraficoTortaSimple 
 *   data={[{ name: 'Categoría A', value: 40 }, { name: 'Categoría B', value: 60 }]}
 *   loading={false}
 *   title="Distribución de ventas"
 * />
 * 
 * @example
 * // Con mapeo de colores personalizado
 * <GraficoTortaSimple 
 *   data={data}
 *   colorMapping={{ 'Categoría A': '#ff0000', 'Categoría B': '#00ff00' }}
 * />
 */
function GraficoTortaSimple({ 
  data, 
  loading, 
  title, 
  colorMapping = {}, 
  innerRadius = "45%", 
  outerRadius = "80%" 
}) {
  const theme = useTheme();

  // Colores de respaldo usando la paleta de Material-UI
  const fallbackColors = [
    theme.palette.primary.main,
    theme.palette.secondary.main,
    theme.palette.success.main,
    theme.palette.warning.main,
    theme.palette.info.main,
    theme.palette.error.main,
  ];

  /**
   * Pre-calcula el total y porcentajes para evitar valores NaN
   * Filtra datos con valor 0 y calcula porcentajes seguros
   */
  const { dataWithPercent, total } = useMemo(() => {
    if (!data || data.length === 0) {
      return { dataWithPercent: [], total: 0 };
    }
    
    // Filtrar datos con valor positivo
    const filteredData = data.filter(entry => entry.value > 0);
    const totalValue = filteredData.reduce((acc, entry) => acc + entry.value, 0);
    
    // Aumentar datos con porcentajes pre-calculados
    const augmentedData = filteredData.map(entry => ({
      ...entry,
      percent: totalValue > 0 ? (entry.value / totalValue) : 0 
    }));
    
    return { dataWithPercent: augmentedData, total: totalValue };
  }, [data]);

  // Estado de carga - muestra skeleton
  if (loading) {
    return (
      <Paper sx={{ 
        p: 3, 
        borderRadius: '12px', 
        height: '100%', 
        display: 'flex', 
        flexDirection: 'column', 
        minHeight: 300 
      }} elevation={3}>
        <Skeleton variant="text" width="60%" sx={{ mb: 2, alignSelf: 'center' }} />
        <Box sx={{ 
          flexGrow: 1, 
          display: 'flex', 
          justifyContent: 'center', 
          alignItems: 'center' 
        }}>
          <Skeleton variant="circular" width={150} height={150} />
        </Box>
      </Paper>
    );
  }

  // Estado sin datos - muestra mensaje informativo
  if (total === 0) {
    return (
      <Paper sx={{ 
        p: 3, 
        borderRadius: '12px', 
        height: '100%', 
        display: 'flex', 
        flexDirection: 'column', 
        alignItems: 'center', 
        justifyContent: 'center', 
        textAlign: 'center', 
        minHeight: 300 
      }} elevation={3}>
        {title && (
          <Typography variant="h6" gutterBottom sx={{ fontWeight: 500 }}>
            {title}
          </Typography>
        )}
        <ReportProblemIcon color="action" sx={{ fontSize: 40, my: 2 }} />
        <Typography color="text.secondary">
          No hay datos para los filtros seleccionados.
        </Typography>
      </Paper>
    );
  }

  return (
    <Paper sx={{ 
      p: 3, 
      height: '100%', 
      borderRadius: '12px', 
      overflow: 'hidden', 
      display: 'flex', 
      flexDirection: 'column', 
      minHeight: 300 
    }} elevation={3}>
      
      {/* Título del gráfico */}
      {title && (
        <Typography variant="h6" gutterBottom sx={{ fontWeight: 500, textAlign: 'center' }}>
          {title}
        </Typography>
      )}
      
      {/* Contenedor del gráfico */}
      <Box sx={{ flexGrow: 1 }}>
        <ResponsiveContainer width="100%" height="100%">
          <PieChart>
            <Pie
              data={dataWithPercent}
              cx="50%" 
              cy="50%" 
              labelLine={false}
              outerRadius={outerRadius} 
              innerRadius={innerRadius}
              fill="#8884d8" 
              dataKey="value" 
              paddingAngle={1}
              
              /**
               * Función personalizada para etiquetas internas
               * - Muestra porcentaje en texto blanco
               * - Oculta etiquetas para porcentajes menores al 5%
               * - Posiciona etiquetas en el radio medio del gráfico
               */
              label={({ cx, cy, midAngle, innerRadius, outerRadius, payload }) => {
                const percent = payload.percent;
                
                // Ocultar etiquetas para segmentos muy pequeños
                if (percent < 0.05) return null;
                
                // Calcular posición de la etiqueta
                const radius = innerRadius + (outerRadius - innerRadius) * 0.5;
                const x = cx + radius * Math.cos(-midAngle * (Math.PI / 180));
                const y = cy + radius * Math.sin(-midAngle * (Math.PI / 180));
                
                return (
                  <text 
                    x={x} 
                    y={y} 
                    fill="white" 
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
              {/* Renderizar cada segmento del gráfico */}
              {dataWithPercent.map((entry, index) => (
                <Cell 
                  key={`cell-${index}`} 
                  fill={colorMapping[entry.name] || fallbackColors[index % fallbackColors.length]} 
                />
              ))}
            </Pie>
            
            {/* Tooltip personalizado */}
            <Tooltip
              contentStyle={{ 
                backgroundColor: theme.palette.background.paper, 
                border: `1px solid ${theme.palette.divider}`, 
                borderRadius: '8px',
                color: theme.palette.text.primary
              }}
              /**
               * Formateador del tooltip
               * Muestra: valor (porcentaje%)
               */
              formatter={(value, name, props) => {
                const percent = props.payload.percent || 0;
                return [
                  `${value} (${(percent * 100).toFixed(0)}%)`,
                  name
                ];
              }}
            />
            
            {/* Leyenda del gráfico */}
            <Legend 
              iconType="circle" 
              verticalAlign="bottom" 
              height={36} 
              wrapperStyle={{ 
                fontSize: 13, 
                color: theme.palette.text.secondary, 
                paddingTop: '10px' 
              }}
            />
          </PieChart>
        </ResponsiveContainer>
      </Box>
    </Paper>
  );
}

export default GraficoTortaSimple;