// src/components/Analisis/TablaRendimientoLideres.jsx
import React from 'react';
import {
    Box, Skeleton, Typography, Paper,
    TableContainer, Table, TableHead, TableRow, TableCell, TableBody,
    useTheme
} from '@mui/material';
import LeaderboardIcon from '@mui/icons-material/Leaderboard';

/**
 * Tabla que muestra el rendimiento de líderes vecinales según la cantidad de reportes moderados.
 *
 * Presenta tres estados:
 * 1. **Cargando**: muestra placeholders (`Skeleton`) mientras se obtienen los datos.
 * 2. **Sin datos**: muestra un mensaje y un ícono indicando que no hay información disponible.
 * 3. **Con datos**: renderiza una tabla con los nombres de los líderes y la cantidad de reportes.
 *
 * @component
 * @example
 * const data = [
 *   { name: "Líder 1", value: 25 },
 *   { name: "Líder 2", value: 18 },
 * ];
 *
 * return (
 *   <TablaRendimientoLideres data={data} loading={false} />
 * );
 *
 * @param {Object} props - Propiedades del componente.
 * @param {Array<{name: string, value: number}>} props.data - Arreglo de objetos con los datos de rendimiento por líder.
 * @param {boolean} props.loading - Indica si los datos están cargándose (true muestra un estado de carga).
 *
 * @returns {JSX.Element} Componente visual de tabla de rendimiento de líderes.
 */
function TablaRendimientoLideres({ data, loading }) {
  const theme = useTheme();

  // --- Estado de carga ---
  if (loading) {
    return (
      <Paper
        sx={{
          p: 3,
          borderRadius: '12px',
          height: '100%',
          display: 'flex',
          flexDirection: 'column',
          minHeight: 300,
        }}
        elevation={3}
      >
        <Skeleton variant="text" width="60%" sx={{ mb: 2 }} />
        <Skeleton variant="rectangular" width="100%" height={250} />
      </Paper>
    );
  }

  // --- Estado sin datos ---
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
          minHeight: 300,
        }}
        elevation={3}
      >
        <LeaderboardIcon color="action" sx={{ fontSize: 40, my: 2 }} />
        <Typography color="text.secondary">
          No hay datos de rendimiento de líderes para mostrar.
        </Typography>
      </Paper>
    );
  }

  // --- Renderizado principal con datos ---
  return (
    <TableContainer sx={{ height: '100%', minHeight: 300, maxHeight: 400 }}>
      <Table stickyHeader>
        <TableHead>
          <TableRow>
            <TableCell
              sx={{
                fontWeight: 'bold',
                backgroundColor: theme.palette.background.default,
                color: theme.palette.text.primary,
              }}
            >
              Líder Vecinal (Alias)
            </TableCell>
            <TableCell
              align="right"
              sx={{
                fontWeight: 'bold',
                backgroundColor: theme.palette.background.default,
                color: theme.palette.text.primary,
              }}
            >
              Reportes Moderados
            </TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {data.map((leader) => (
            <TableRow key={leader.name} hover>
              <TableCell>{leader.name}</TableCell>
              <TableCell align="right" sx={{ fontWeight: 'bold', fontSize: '1rem' }}>
                {leader.value}
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </TableContainer>
  );
}

export default TablaRendimientoLideres;
