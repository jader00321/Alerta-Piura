/**
 * @file GraficoBarrasSimple.jsx
 * @description Componente que renderiza un gráfico de barras horizontales utilizando Recharts y Material UI.
 * Permite mostrar datos analíticos con soporte para estados de carga (`loading`) y ausencia de datos.
 * Incluye tooltips personalizados y estilos adaptados al tema actual.
 * @version 1.1.0
 * @date 2025-10-25
 * @author Juan
 */

import React from 'react';
import { Box, Skeleton, Typography, Paper, useTheme } from '@mui/material';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Cell } from 'recharts';
import ReportProblemIcon from '@mui/icons-material/ReportProblem';

/**
 * Componente gráfico de barras simple (horizontal) para mostrar datos estadísticos.
 *
 * Maneja tres estados:
 * - **Cargando (`loading`)**: muestra esqueletos de carga (`Skeleton`)
 * - **Sin datos**: muestra un mensaje de advertencia
 * - **Con datos**: renderiza el gráfico de barras
 *
 * @component
 * @example
 * const datos = [
 *   { name: 'Lima', value: 120 },
 *   { name: 'Cusco', value: 80 },
 *   { name: 'Arequipa', value: 45 }
 * ];
 *
 * <GraficoBarrasSimple
 *   data={datos}
 *   dataKey="value"
 *   xAxisKey="name"
 *   fillColor="#2196f3"
 *   barName="Pedidos por región"
 *   loading={false}
 * />
 *
 * @param {Object} props - Propiedades del componente.
 * @param {Array<Object>} props.data - Arreglo de objetos con los datos a graficar.
 * Cada objeto debe contener al menos la clave usada en `dataKey` y `xAxisKey`.
 * @param {boolean} props.loading - Indica si el componente debe mostrar el estado de carga.
 * @param {string} [props.dataKey="value"] - Clave del objeto `data` que contiene el valor numérico.
 * @param {string} [props.xAxisKey="name"] - Clave del objeto `data` que contiene las etiquetas del eje Y.
 * @param {string} [props.fillColor] - Color por defecto de las barras si no se usa mapeo de colores.
 * @param {string} [props.barName="Total"] - Nombre descriptivo que se mostrará en el tooltip.
 *
 * @returns {JSX.Element} Gráfico de barras o placeholder según el estado de carga o datos.
 */
function GraficoBarrasSimple({
  data,
  loading,
  dataKey = "value",
  xAxisKey = "name",
  fillColor,
  barName = "Total"
}) {
  const theme = useTheme();

  /** Color de respaldo si no se especifica `fillColor`. */
  const defaultColor = fillColor || theme.palette.secondary.main;

  // --- Estado: Cargando ---
  if (loading) {
    return (
      <Paper
        sx={{
          p: 3,
          borderRadius: '12px',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          minHeight: 300
        }}
        elevation={3}
      >
        <Skeleton variant="text" width="60%" sx={{ mb: 2, alignSelf: 'center' }} />
        <Box
          sx={{
            flexGrow: 1,
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center'
          }}
        >
          <Skeleton variant="rectangular" width="90%" height={250} />
        </Box>
      </Paper>
    );
  }

  // --- Estado: Sin datos ---
  if (!data || data.length === 0) {
    return (
      <Paper
        sx={{
          p: 3,
          borderRadius: '12px',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          justifyContent: 'center',
          textAlign: 'center',
          minHeight: 300
        }}
        elevation={3}
      >
        <ReportProblemIcon color="action" sx={{ fontSize: 40, my: 2 }} />
        <Typography color="text.secondary">
          No hay datos para los filtros seleccionados.
        </Typography>
      </Paper>
    );
  }

  // --- Estado: Datos disponibles ---
  return (
    <Box sx={{ width: '100%', height: '100%', minHeight: 300 }}>
      <ResponsiveContainer width="100%" height="100%">
        <BarChart
          data={data}
          margin={{ top: 5, right: 10, left: -15, bottom: 5 }}
          layout="vertical" // Barras horizontales
        >
          {/* Líneas de cuadrícula */}
          <CartesianGrid strokeDasharray="3 3" stroke={theme.palette.divider} opacity={0.5} />

          {/* Eje X: valores numéricos */}
          <XAxis
            type="number"
            tick={{ fontSize: 12, fill: theme.palette.text.secondary }}
            stroke={theme.palette.divider}
            allowDecimals={false}
          />

          {/* Eje Y: categorías */}
          <YAxis
            dataKey={xAxisKey}
            type="category"
            tick={{ fontSize: 12, fill: theme.palette.text.secondary }}
            stroke={theme.palette.divider}
            width={100}
            interval={0}
          />

          {/* Tooltip personalizado */}
          <Tooltip
            contentStyle={{
              backgroundColor: theme.palette.background.paper,
              border: `1px solid ${theme.palette.divider}`,
              borderRadius: '8px',
              color: theme.palette.text.primary
            }}
            formatter={(value, name) => [`${value}`, name]}
            labelFormatter={(label) => `Estado: ${label}`}
          />

          {/* Barras de datos */}
          <Bar
            dataKey={dataKey}
            fill={defaultColor}
            name={barName}
            radius={[0, 4, 4, 0]}
            barSize={25}
          >
            {/* Cell puede usarse en el futuro para colorear individualmente */}
            {data.map((entry, index) => (
              <Cell key={`cell-${index}`} fill={defaultColor} />
            ))}
          </Bar>
        </BarChart>
      </ResponsiveContainer>
    </Box>
  );
}

export default GraficoBarrasSimple;
