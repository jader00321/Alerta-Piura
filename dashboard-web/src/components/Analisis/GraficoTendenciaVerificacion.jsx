// src/components/Analisis/GraficoTendenciaVerificacion.jsx
import React from 'react';
import { Box, Skeleton, Typography, Paper, useTheme } from '@mui/material';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import AccessTimeIcon from '@mui/icons-material/AccessTime';

/**
 * Componente que muestra un gráfico de línea con la tendencia
 * del tiempo promedio de verificación, utilizando `recharts` y el tema de MUI.
 *
 * @component
 * @example
 * const data = [
 *   { name: 'Enero', value: 2.5 },
 *   { name: 'Febrero', value: 3.1 },
 *   { name: 'Marzo', value: 2.8 },
 * ];
 * return <GraficoTendenciaVerificacion data={data} loading={false} />;
 *
 * @param {Object[]} data - Arreglo de objetos con los datos del gráfico.
 * @param {string} data[].name - Etiqueta del eje X (por ejemplo, el mes).
 * @param {number} data[].value - Valor numérico del promedio de horas.
 * @param {boolean} loading - Si es `true`, muestra esqueletos de carga.
 * @returns {JSX.Element} Gráfico de línea o mensaje de estado.
 */
function GraficoTendenciaVerificacion({ data, loading }) {
  const theme = useTheme();

  if (loading) {
    return (
      <Paper sx={{ p: 3, borderRadius: '12px', height: '100%', display: 'flex', flexDirection: 'column', minHeight: 300 }} elevation={3}>
        <Skeleton variant="text" width="60%" sx={{ mb: 2, alignSelf: 'center' }} />
        <Box sx={{ flexGrow: 1, display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
          <Skeleton variant="rectangular" width="90%" height={250} />
        </Box>
      </Paper>
    );
  }

  if (!data || data.length === 0) {
    return (
      <Paper sx={{ p: 3, borderRadius: '12px', height: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', minHeight: 300 }} elevation={3}>
        <AccessTimeIcon color="action" sx={{ fontSize: 40, my: 2 }} />
        <Typography color="text.secondary">No hay datos de tendencia de verificación para mostrar.</Typography>
      </Paper>
    );
  }

  return (
    <Box sx={{ width: '100%', height: '100%', minHeight: 300 }}>
      <ResponsiveContainer width="100%" height="100%">
        <LineChart data={data} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
          <CartesianGrid strokeDasharray="3 3" stroke={theme.palette.divider} opacity={0.5} />
          <XAxis dataKey="name" tick={{ fontSize: 12, fill: theme.palette.text.secondary }} stroke={theme.palette.divider} />
          <YAxis
            allowDecimals
            unit="h"
            tick={{ fontSize: 12, fill: theme.palette.text.secondary }}
            stroke={theme.palette.divider}
            domain={['auto', 'auto']}
          />
          <Tooltip
            contentStyle={{
              backgroundColor: theme.palette.background.paper,
              border: `1px solid ${theme.palette.divider}`,
              borderRadius: '8px',
              color: theme.palette.text.primary,
            }}
            formatter={(value) => [`${Number(value).toFixed(1)} horas`, 'Promedio']}
          />
          <Legend wrapperStyle={{ fontSize: 13, color: theme.palette.text.secondary }} />
          <Line
            type="monotone"
            dataKey="value"
            stroke={theme.palette.secondary.main}
            strokeWidth={2}
            name="Tiempo Promedio (Horas)"
            dot={{ r: 4, fill: theme.palette.secondary.main }}
            activeDot={{ r: 6, stroke: theme.palette.secondary.main }}
          />
        </LineChart>
      </ResponsiveContainer>
    </Box>
  );
}

export default GraficoTendenciaVerificacion;
