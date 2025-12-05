import React from 'react';
import {
  Paper, Typography, Box, Skeleton, Table, TableBody, TableCell,
  TableContainer, TableHead, TableRow, Chip, useTheme, alpha, Avatar
} from '@mui/material';
import { 
  PriorityHigh as UrgencyIcon, 
  CalendarToday as CalendarIcon,
  Tag as TagIcon
} from '@mui/icons-material';

// Chip de Urgencia Estilizado
const UrgencyChip = ({ urgency }) => {
  const theme = useTheme();
  let color = theme.palette.success.main;
  let bg = alpha(theme.palette.success.main, 0.1);

  if (urgency === 'Alta') {
    color = theme.palette.error.main;
    bg = alpha(theme.palette.error.main, 0.1);
  } else if (urgency === 'Media') {
    color = theme.palette.warning.main;
    bg = alpha(theme.palette.warning.main, 0.1);
  }

  return (
    <Chip 
      label={urgency || 'N/A'} 
      size="small" 
      sx={{ 
        bgcolor: bg, 
        color: color, 
        fontWeight: 'bold', 
        border: 'none',
        height: 24
      }}
    />
  );
};

function TablaUltimosReportes({ reports, loading, onReportClick }) {
  const theme = useTheme();

  // --- Estado de Carga (Skeleton) ---
  if (loading) {
     return (
        <Paper elevation={0} sx={{ borderRadius: 3, border: `1px solid ${theme.palette.divider}`, overflow: 'hidden' }}>
            <Box sx={{ p: 2 }}>
                <Skeleton variant="text" width={200} height={30} />
            </Box>
            <TableContainer>
                <Table>
                    <TableHead>
                        <TableRow>
                            {[1, 2, 3, 4, 5].map((i) => <TableCell key={i}><Skeleton width="100%" /></TableCell>)}
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {[...Array(5)].map((_, i) => (
                             <TableRow key={i}><TableCell colSpan={5}><Skeleton /></TableCell></TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
       </Paper>
     );
  }

  // --- Estado Cargado ---
  return (
    <Paper 
        elevation={0} 
        sx={{ 
            borderRadius: 3, 
            overflow: 'hidden', 
            border: `1px solid ${theme.palette.divider}`,
            bgcolor: 'background.paper'
        }}
    >
        {/* Encabezado de la Tabla (Fuera del TableContainer para sticky real si se necesita) */}
        <Box sx={{ p: 3, borderBottom: `1px solid ${theme.palette.divider}` }}>
             <Typography variant="h6" sx={{ fontWeight: 700 }}>
                Últimos Reportes Pendientes
             </Typography>
             <Typography variant="body2" color="text.secondary">
                Requieren verificación antes de ser públicos.
             </Typography>
        </Box>

        <TableContainer>
            <Table>
                <TableHead sx={{ bgcolor: alpha(theme.palette.primary.main, 0.04) }}>
                    <TableRow>
                        <TableCell sx={{ fontWeight: 'bold', color: 'text.secondary' }}>CÓDIGO</TableCell>
                        <TableCell sx={{ fontWeight: 'bold', color: 'text.secondary' }}>TÍTULO</TableCell>
                        <TableCell sx={{ fontWeight: 'bold', color: 'text.secondary' }}>URGENCIA</TableCell>
                        <TableCell sx={{ fontWeight: 'bold', color: 'text.secondary' }}>DISTRITO</TableCell>
                        <TableCell sx={{ fontWeight: 'bold', color: 'text.secondary' }}>AUTOR</TableCell>
                        <TableCell sx={{ fontWeight: 'bold', color: 'text.secondary' }}>FECHA</TableCell>
                    </TableRow>
                </TableHead>
                <TableBody>
                    {reports.length > 0 ? reports.map((report) => (
                        <TableRow
                            key={report.id} 
                            hover 
                            onClick={() => onReportClick(report)}
                            sx={{ 
                                cursor: 'pointer',
                                transition: '0.2s',
                                '&:hover': { bgcolor: 'action.hover' } 
                            }}
                        >
                            <TableCell>
                                <Chip 
                                    icon={<TagIcon style={{fontSize: 14}}/>} 
                                    label={report.codigo_reporte} 
                                    size="small" 
                                    variant="outlined" 
                                    sx={{ borderRadius: 1, borderColor: theme.palette.divider, fontWeight: 600 }}
                                />
                            </TableCell>
                            <TableCell>
                                <Typography variant="body2" fontWeight={600} color="text.primary">
                                    {report.titulo}
                                </Typography>
                                <Typography variant="caption" color="text.secondary">
                                    {report.categoria}
                                </Typography>
                            </TableCell>
                            <TableCell>
                                <UrgencyChip urgency={report.urgencia} />
                            </TableCell>
                            <TableCell>{report.distrito || 'N/A'}</TableCell>
                            <TableCell>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
                                    <Avatar sx={{ width: 24, height: 24, fontSize: 12, bgcolor: 'primary.main' }}>
                                        {report.autor_nombre ? report.autor_nombre[0] : '?'}
                                    </Avatar>
                                    <Typography variant="body2">
                                        {report.autor_alias || report.autor_nombre || 'Anónimo'}
                                    </Typography>
                                </Box>
                            </TableCell>
                            <TableCell>
                                <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.5, color: 'text.secondary' }}>
                                    <CalendarIcon sx={{ fontSize: 14 }} />
                                    <Typography variant="caption">
                                        {new Date(report.fecha_creacion).toLocaleDateString()}
                                    </Typography>
                                </Box>
                            </TableCell>
                        </TableRow>
                    )) : (
                        <TableRow>
                            <TableCell colSpan={6} align="center" sx={{ py: 6 }}>
                                <Typography color="text.secondary" fontWeight="medium">
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