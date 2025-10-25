// src/components/Reportes/PanelSolicitudesRevision.jsx
import React from 'react';
import { Box, Typography, Grid, Paper, Button, Divider, Tooltip} from '@mui/material';
import { ThumbUp as ApproveIcon, ThumbDown as DisapproveIcon, AssignmentLate as ReviewIcon, InfoOutlined as MotivoIcon } from '@mui/icons-material'; // Añadir MotivoIcon

function PanelSolicitudesRevision({ reviewRequests, onResolveRequest }) {

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
            <Paper elevation={1} sx={{ p: 2, display: 'flex', flexDirection: 'column', height: '100%', borderLeft: '4px solid', borderColor: 'warning.main' }}>
              <Typography variant="caption" color="text.secondary">Solicitud de {req.lider_nombre || req.lider_alias}</Typography>
              <Tooltip title={req.titulo}>
                 <Typography variant="body1" sx={{ fontWeight: 'bold', my: 0.5 }} noWrap>{req.titulo}</Typography>
              </Tooltip>
              <Typography variant="body2" color="text.secondary">Código: {req.codigo_reporte}</Typography>
              <Typography variant="body2" color="text.secondary">Fecha Reporte: {req.fecha_reporte}</Typography>

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