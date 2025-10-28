import React from 'react';
import { Box, Typography, Grid, Paper, Button, Divider, Tooltip} from '@mui/material';
import { ThumbUp as ApproveIcon, ThumbDown as DisapproveIcon, AssignmentLate as ReviewIcon, InfoOutlined as MotivoIcon } from '@mui/icons-material'; // Añadir MotivoIcon

/**
 * Renderiza un panel/sección que muestra una cuadrícula de "Solicitudes de Revisión" pendientes.
 * Estas son solicitudes (generalmente de Líderes Vecinales) para que un administrador
 * re-evalúe un reporte (ej. uno que fue rechazado).
 *
 * El componente proporciona acciones para "Aprobar" (marcar para re-evaluar) o
 * "Desestimar" la solicitud.
 *
 * Si no hay solicitudes (`reviewRequests` está vacío o es nulo), el componente
 * retorna `null` y no renderiza nada.
 *
 * @param {object} props - Propiedades del componente.
 * @param {Array<object> | null} props.reviewRequests - Un array de objetos de solicitud de revisión.
 * @param {string} props.reviewRequests[].id - ID único de la solicitud de revisión.
 * @param {string} [props.reviewRequests[].lider_nombre] - Nombre del líder que solicita.
 * @param {string} [props.reviewRequests[].lider_alias] - Alias del líder que solicita.
 * @param {string} props.reviewRequests[].titulo - Título del reporte asociado.
 * @param {string} props.reviewRequests[].codigo_reporte - Código del reporte asociado.
 * @param {string} props.reviewRequests[].fecha_reporte - Fecha del reporte asociado.
 * @param {string} [props.reviewRequests[].motivo] - Motivo opcional de la solicitud.
 * @param {Function} props.onResolveRequest - Callback que se ejecuta al aprobar o desestimar.
 * Recibe `(requestId, actionType)`, donde `actionType`
 * es 'aprobar' o 'desestimar'.
 * @returns {JSX.Element | null} El panel de solicitudes o null si no hay solicitudes.
 */
function PanelSolicitudesRevision({ reviewRequests, onResolveRequest }) {

  // Si no hay solicitudes, no mostrar el panel.
  if (!reviewRequests || reviewRequests.length === 0) {
    return null;
  }

  return (
    <Box mb={4}>
      <Typography variant="h6" gutterBottom sx={{ display: 'flex', alignItems: 'center', gap: 1, mb: 2 }}>
         <ReviewIcon color="warning"/> Solicitudes de Revisión Pendientes ({reviewRequests.length})
      </Typography>
      <Grid container spacing={2}>
        {reviewRequests.map(req => (
          <Grid item key={req.id} xs={12} sm={6} md={4} lg={3}>
            {/* Tarjeta individual de solicitud */}
            <Paper elevation={1} sx={{ p: 2, display: 'flex', flexDirection: 'column', height: '100%', borderLeft: '4px solid', borderColor: 'warning.main' }}>
              <Typography variant="caption" color="text.secondary">Solicitud de {req.lider_nombre || req.lider_alias}</Typography>
              <Tooltip title={req.titulo}>
                 <Typography variant="body1" sx={{ fontWeight: 'bold', my: 0.5 }} noWrap>{req.titulo}</Typography>
              </Tooltip>
              <Typography variant="body2" color="text.secondary">Código: {req.codigo_reporte}</Typography>
              <Typography variant="body2" color="text.secondary">Fecha Reporte: {req.fecha_reporte}</Typography>

              {/* Motivo (si existe) */}
              {req.motivo && (
                <Tooltip title={req.motivo}>
                    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5, mt: 1, color: 'text.secondary' }}>
                       <MotivoIcon sx={{ fontSize: '1rem' }} />
                       <Typography variant="caption" noWrap>
                           Motivo: {req.motivo}
                       </Typography>
                    </Box>
                </Tooltip>
              )}

              {/* Acciones */}
              <Box mt="auto" pt={2} display="flex" justifyContent="space-between" gap={1}>
                <Button size="small" variant="outlined" color="error" startIcon={<DisapproveIcon />} onClick={() => onResolveRequest(req.id, 'desestimar')}>Desestimar</Button>
                <Button size="small" variant="contained" color="success" startIcon={<ApproveIcon />} onClick={() => onResolveRequest(req.id, 'aprobar')}>Re-evaluar</Button>
              </Box>
            </Paper>
          </Grid>
        ))}
      </Grid>
       <Divider sx={{ mt: 4 }} />
    </Box>
  );
}

export default PanelSolicitudesRevision;