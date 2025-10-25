// src/components/Resumen/TablaUltimosReportes.jsx
import React from 'react';
import {
  Paper, Typography, Box, Skeleton, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Tooltip, Chip
} from '@mui/material';
import { PriorityHigh as UrgencyIcon, Star as StarIcon } from '@mui/icons-material'; // Icono para Urgencia

// Helper para Chip de Urgencia
const UrgencyChip = ({ urgency }) => {
    let color = 'default';
    if (urgency === 'Alta') color = 'error';
    else if (urgency === 'Media') color = 'warning';
    else if (urgency === 'Baja') color = 'success';
    return <Chip icon={<UrgencyIcon/>} label={urgency || 'N/A'} color={color} size="small" variant='outlined'/>;
};


function TablaUltimosReportes({ reports, loading, onReportClick }) {

  if (loading) {
      return (
         <Paper elevation={3} sx={{ borderRadius: '12px', overflow: 'hidden', mb: 4}}>
             <Box sx={{p:2}}>
                 <Skeleton variant="text" width="40%" sx={{mb: 2}}/>
             </Box>
            <TableContainer>
                <Table>
                    <TableHead>
                        <TableRow>
                            {/* Ajusta número de celdas */}
                            <TableCell><Skeleton width="80%" /></TableCell>
                            <TableCell><Skeleton width="90%" /></TableCell>
                            <TableCell><Skeleton width="60%" /></TableCell>
                            <TableCell><Skeleton width="70%" /></TableCell>
                            <TableCell><Skeleton width="80%" /></TableCell>
                            <TableCell><Skeleton width="70%" /></TableCell>
                            <TableCell><Skeleton width="60%" /></TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {[...Array(5)].map((_, i) => ( // Muestra 5 filas de Skeletons
                             <TableRow key={i}>
                                <TableCell><Skeleton /></TableCell>
                                <TableCell><Skeleton /></TableCell>
                                <TableCell><Skeleton /></TableCell>
                                <TableCell><Skeleton /></TableCell>
                                <TableCell><Skeleton /></TableCell>
                                <TableCell><Skeleton /></TableCell>
                                <TableCell><Skeleton /></TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
         </Paper>
      );
  }

  return (
    <Paper elevation={3} sx={{ borderRadius: '12px', overflow: 'hidden', mb: 4 }}>
        <Box sx={{p: 2, borderBottom: 1, borderColor: 'divider'}}>
             <Typography variant="h6" sx={{ fontWeight: 500 }}>
                Últimos Reportes Pendientes de Verificación
             </Typography>
        </Box>
        <TableContainer sx={{ maxHeight: 450 }}> 
            <Table stickyHeader> {/* Cabecera fija */}
                <TableHead>
                    <TableRow>
                        <TableCell sx={{ fontWeight: 'bold' }}>Código</TableCell>
                        <TableCell sx={{ fontWeight: 'bold' }}>Título</TableCell>
                        <TableCell sx={{ fontWeight: 'bold' }}>Urgencia</TableCell>
                        <TableCell sx={{ fontWeight: 'bold' }}>Distrito</TableCell>
                        <TableCell sx={{ fontWeight: 'bold' }}>Autor</TableCell>
                        <TableCell sx={{ fontWeight: 'bold' }}>Categoría</TableCell>
                        <TableCell sx={{ fontWeight: 'bold' }}>Fecha</TableCell>
                    </TableRow>
                </TableHead>
                <TableBody>
                    {reports.length > 0 ? reports.map((report) => (
                        <TableRow
                            key={report.id} hover onClick={() => onReportClick(report)}
                            sx={{ cursor: 'pointer' }}
                        >
                            <TableCell sx={{ fontWeight: 'bold' }}>{report.codigo_reporte}</TableCell>
                            <TableCell>
                                <Box sx={{ display: 'flex', alignItems: 'center' }}>
                                    {report.es_prioritario && (
                                        <Tooltip title="Reporte Prioritario (Premium)">
                                            <StarIcon color="warning" sx={{ fontSize: '1.1rem', mr: 0.5 }} />
                                        </Tooltip>
                                    )}
                                    <Typography variant="body2" sx={{ fontWeight: 'bold' }} noWrap>
                                        {report.titulo}
                                    </Typography>
                                </Box>
                            </TableCell>
                            <TableCell><UrgencyChip urgency={report.urgencia} /></TableCell>
                            <TableCell>{report.distrito || 'N/A'}</TableCell>
                            <TableCell>{report.autor_alias || report.autor_nombre || (report.es_anonimo ? 'Anónimo' : 'N/A')}</TableCell>
                            <TableCell>{report.categoria}</TableCell>
                            <TableCell>{report.fecha_creacion_formateada || new Date(report.fecha_creacion).toLocaleDateString()}</TableCell>
                        </TableRow>
                    )) : (
                        <TableRow>
                            <TableCell colSpan={7} align="center">
                                <Typography color="text.secondary" sx={{ p: 3 }}>
                                    No hay reportes pendientes en este momento.
                                </Typography>
                            </TableCell>
                        </TableRow>
                    )}
                </TableBody>
            </Table>
        </TableContainer>
    </Paper>
  );
}

export default TablaUltimosReportes;