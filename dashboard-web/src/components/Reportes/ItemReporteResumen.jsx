// src/components/Reportes/ItemReporteResumen.jsx
import React from 'react';
import {
  Paper, Box, Typography, Avatar, Chip, IconButton, Tooltip, Stack, Divider, Grid
} from '@mui/material';
import {
    ImageNotSupported as NoImageIcon, MoreVert as MoreVertIcon,
    CheckCircleOutline as CheckIcon, CancelOutlined as RejectIcon, HourglassEmpty as PendingIcon,
    HelpOutline as SuggestionIcon, Star as StarIcon, WorkspacePremium as PremiumIcon,
    Person as PersonIcon, CalendarToday as CalendarTodayIcon, LocationOn as LocationIcon,
    Label as CategoryIcon, Numbers as CodeIcon, VisibilityOff as VisibilityOffIcon,
    PriorityHigh as PriorityHighIcon,
    MergeType as MergeTypeIcon,
} from '@mui/icons-material';

// --- StatusChip ---
const StatusChip = ({ status }) => {
    const statusInfo = {
        verificado: { label: 'Verificado', color: 'success', icon: <CheckIcon /> },
        rechazado: { label: 'Rechazado', color: 'error', icon: <RejectIcon /> },
        pendiente_verificacion: { label: 'Pendiente', color: 'warning', icon: <PendingIcon /> },
        oculto: { label: 'Oculto', color: 'default', icon: <VisibilityOffIcon /> },
        fusionado: { label: 'Fusionado', color: 'primary', icon: <MergeTypeIcon /> },
    };
    const { label, color, icon } = statusInfo[status] || { label: status, color: 'default', icon: <></> };
    return <Chip
             icon={icon}
             label={label}
             color={color}
             size="medium"
             variant="filled"
             sx={{
                fontWeight: 'bold',
                color: '#fff',
                height: 'auto',
                '& .MuiChip-label': { py: 0.8, px: 1.2 },
                '& .MuiChip-icon': { ml: 0.8 },
                boxShadow: 1
             }}
           />;
};

// --- Info Item Helper ---
const InfoItem = ({icon, label, value, chip = false, chipProps = {} }) => (
    <Box sx={{ display: 'flex', alignItems: 'center', gap: 0.8 }}>
        {React.cloneElement(icon, { sx: { fontSize: '1rem', color: 'text.secondary' } })} {/* <-- Icono más pequeño y gris */}
        <Typography variant="caption" color="text.secondary" sx={{ textTransform: 'uppercase', letterSpacing: '0.5px', minWidth: '80px' }}>
            {label}
        </Typography>
        <Tooltip title={value || label}>
           {chip ? (
              <Chip size="small" variant="outlined" {...chipProps} label={value || 'N/A'}/>
           ) : (
             <Typography variant="body2" noWrap sx={{ fontWeight: 500 }}>
                 {value || 'N/A'}
             </Typography>
           )}
        </Tooltip>
    </Box>
);


function ItemReporteResumen({ report, index, onOpenDrawer }) {
  const authorName = report.autor_alias || report.autor_nombre || (report.es_anonimo ? 'Anónimo' : 'Desconocido');
  const isAuthorPremium = report.nombre_plan_autor && report.nombre_plan_autor !== 'Plan Gratuito';

  return (
    <Paper variant="outlined" sx={{ display: 'flex', p: 2, gap: 2.5, alignItems: 'center',minWidth:"1100px",maxWidth:'100%' }}>

        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, pr: 1, borderRight: 1, borderColor: 'divider' }}>
            <Typography variant="h5" color="text.secondary">
                {index + 1}
            </Typography>
        </Box>

        <Box sx={{ flexShrink: 0, alignSelf: 'center' }}>
            <Avatar variant="rounded" src={report.foto_url} sx={{ width: 90, height: 90, bgcolor: 'action.hover' }}>
                <NoImageIcon sx={{ fontSize: 40 }}/>
            </Avatar>
        </Box>

        <Box sx={{ flexGrow: 1, overflow: 'hidden' }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 1.5 }}>
                 {report.es_prioritario && (
                   <Tooltip title="Reporte Premium (Prioritario)">
                     <StarIcon color="warning" sx={{ fontSize: '1.4rem', mr: -0.5 }} />
                   </Tooltip>
                 )}
                <Tooltip title={report.titulo}>
                    <Typography variant="h6" noWrap sx={{ fontWeight: 600 }}>
                        {report.titulo}
                    </Typography>
                </Tooltip>
                <Chip icon={<CodeIcon />} label={report.codigo_reporte} size="small" variant='outlined' sx={{fontWeight: 'bold'}}/>
            </Box>

             <Grid container spacing={1.5} alignItems="center">
                <Grid item xs={12} sm={6} md={5} lg={4}>
                    <Stack spacing={1}>
                        <InfoItem
                            icon={<PersonIcon />}
                            label="Autor"
                            value={authorName}
                            chip={true}
                            chipProps={{
                                color: report.es_anonimo ? 'default' : (isAuthorPremium ? 'warning' : 'primary'),
                                variant: isAuthorPremium ? 'filled' : 'outlined',
                                icon: isAuthorPremium ? <PremiumIcon /> : undefined
                            }}
                        />
                         <InfoItem icon={<CalendarTodayIcon />} label="Fecha" value={new Date(report.fecha_creacion_formateada || report.fecha_creacion).toLocaleDateString()} />
                    </Stack>
                </Grid>
                <Grid item xs={12} sm={6} md={5} lg={4}>
                     <Stack spacing={1}>
                        <InfoItem
                            icon={<CategoryIcon />}
                            label="Categoría"
                            value={report.categoria_sugerida ? `${report.categoria_sugerida} (Sug.)` : report.categoria}
                            chip={report.categoria_sugerida ? true : false}
                            chipProps={{color:'info', icon: <SuggestionIcon />}}
                        />
                         <InfoItem icon={<LocationIcon />} label="Distrito" value={report.distrito} />
                     </Stack>
                </Grid>
                {/* --- MODIFICADO: Columna para Urgencia y Vinculados --- */}
                <Grid item xs={12} sm={6} md={5} lg={4}> {/* Ajustar tamaños si es necesario */}
                    <Stack spacing={1}>
                        <InfoItem icon={<PriorityHighIcon />} label="Urgencia" value={report.urgencia} />
                        {/* --- NUEVO: Mostrar Reportes Vinculados --- */}
                        {report.reportes_vinculados_count > 0 && (
                            <InfoItem
                                icon={<MergeTypeIcon />}
                                label="Vinculados"
                                value={report.reportes_vinculados_count.toString()}
                                chip={true}
                                chipProps={{ color: 'secondary', size: 'small' }}
                            />
                        )}
                        {/* --- FIN NUEVO --- */}
                    </Stack>
                </Grid>
            </Grid>
        </Box>

        <Box sx={{ display: 'flex', alignItems: 'center', mr:8, justifyContent: { xs: 'flex-start', md: 'center' }, mt:{xs: 1, md: 0} }}>
            <StatusChip status={report.estado} />
        </Box>

        <Box sx={{ flexShrink: 0, alignSelf: 'center', pl: 1, borderLeft: 1, borderColor: 'divider' }}>
            <Tooltip title="Ver Detalles y Acciones">
                <IconButton onClick={() => onOpenDrawer(report)}>
                    <MoreVertIcon />
                </IconButton>
            </Tooltip>
        </Box>
    </Paper>
  );
}

export default ItemReporteResumen;