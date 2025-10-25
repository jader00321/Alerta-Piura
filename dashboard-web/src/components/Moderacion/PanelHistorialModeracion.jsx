// dashboard-web/src/components/Moderacion/PanelHistorialModeracion.jsx
import React, { useState, useEffect } from 'react';
import {
  Box, Paper, Table, TableBody, TableCell, TableContainer,
  TableHead, TableRow, Typography, CircularProgress, Chip,
  Alert
} from '@mui/material';
import adminService from '../../services/adminService';

/**
 * Renderiza un chip visual con color según el tipo de acción de moderación.
 * 
 * @component
 * @example
 * ```jsx
 * <ActionChip action="ELIMINAR_COMENTARIO" />
 * ```
 * 
 * @param {Object} props - Propiedades del componente.
 * @param {string} props.action - Acción de moderación (por ejemplo, "ELIMINAR", "SUSPENDER", "DESESTIMAR").
 * @returns {JSX.Element} Un componente `<Chip>` con color temático acorde a la acción.
 */
const ActionChip = ({ action }) => {
  let color = 'default';
  if (action.includes('ELIMINAR') || action.includes('SUSPENDER')) {
    color = 'error';
  } else if (action.includes('DESESTIMAR')) {
    color = 'success';
  }

  return <Chip label={action} color={color} size="small" variant="outlined" />;
};

/**
 * Panel que muestra el historial de acciones de moderación realizadas por los administradores.
 * 
 * Obtiene los datos desde el servicio `adminService.getModerationHistory()` y muestra una tabla
 * con las acciones, el administrador que las realizó, la fecha y el contenido afectado.
 *
 * @component
 * @example
 * ```jsx
 * <PanelHistorialModeracion />
 * ```
 *
 * @returns {JSX.Element} Una tabla interactiva con el historial de moderaciones, estados de carga y errores.
 */
function PanelHistorialModeracion() {
  /** @type {[Array<Object>, Function]} Lista del historial de moderación */
  const [history, setHistory] = useState([]);

  /** @type {[boolean, Function]} Estado de carga */
  const [isLoading, setIsLoading] = useState(true);

  /** @type {[string|null, Function]} Mensaje de error en caso de fallo */
  const [error, setError] = useState(null);

  /**
   * Efecto que obtiene el historial de moderación al montar el componente.
   * Si ocurre un error, lo captura y lo muestra en pantalla.
   */
  useEffect(() => {
    setIsLoading(true);
    adminService.getModerationHistory()
      .then(setHistory)
      .catch(err => {
        console.error('Error fetching history:', err);
        setError(err.response?.data?.message || 'Error al cargar historial');
      })
      .finally(() => setIsLoading(false));
  }, []);

  // Estado de carga
  if (isLoading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', p: 5 }}>
        <CircularProgress />
      </Box>
    );
  }

  // Error al obtener datos
  if (error) {
    return <Alert severity="error" sx={{ m: 2 }}>{error}</Alert>;
  }

  // Tabla de historial
  return (
    <TableContainer component={Paper} sx={{ maxHeight: '70vh' }}>
      <Table stickyHeader>
        <TableHead>
          <TableRow>
            <TableCell sx={{ fontWeight: 'bold' }}>Fecha</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Admin</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Acción</TableCell>
            <TableCell sx={{ fontWeight: 'bold' }}>Contenido Afectado</TableCell>
          </TableRow>
        </TableHead>
        <TableBody>
          {history.length > 0 ? history.map(log => (
            <TableRow key={log.id} hover>
              <TableCell>
                <Typography variant="body2" noWrap>
                  {new Date(log.fecha_accion).toLocaleString()}
                </Typography>
              </TableCell>
              <TableCell>{log.admin_alias}</TableCell>
              <TableCell>
                <ActionChip action={log.accion.replace('_', ' ').toUpperCase()} />
              </TableCell>
              <TableCell>
                <Typography variant="body2" sx={{ fontStyle: 'italic' }}>
                  "{log.contenido_afectado}"
                </Typography>
              </TableCell>
            </TableRow>
          )) : (
            <TableRow>
              <TableCell colSpan={4} align="center">
                <Typography color="text.secondary" sx={{ p: 3 }}>
                  No hay acciones de moderación registradas.
                </Typography>
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>
    </TableContainer>
  );
}

export default PanelHistorialModeracion;
