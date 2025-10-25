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

/**
 * Componente Chip para mostrar el estado de un reporte con un ícono y color específico.
 * Utiliza un estilo predefinido (negrita, color de texto blanco) para alta visibilidad.
 * * @param {object} props - Propiedades del componente.
 * @param {string} props.status - El estado del reporte (ej: 'verificado', 'rechazado', 'pendiente_verificacion').
 * @returns {JSX.Element} Un componente Chip de MUI estilizado.
 */
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
                color: '#fff', // Asegura contraste sobre colores de fondo
                height: 'auto',
                '& .MuiChip-label': { py: 0.8, px: 1.2 },
                '& .MuiChip-icon': { ml: 0.8 },
                boxShadow: 1
              }}
           />;
};

// --- Info Item Helper ---

/**
 * Componente helper para mostrar una línea de información (Icono + Label + Valor).
 * El valor puede ser texto plano o un Chip.
 * * @param {object} props - Propiedades del componente.
 * @param {JSX.Element} props.icon - El ícono a mostrar (ej: <PersonIcon />).
 * @param {string} props.label - El texto de la etiqueta (ej: "Autor").
 * @param {string|number} props.value - El valor a mostrar.
 * @param {boolean} [props.chip=false] - Si es true, renderiza el valor dentro de un Chip.
 * @param {object} [props.chipProps={}] - Propiedades adicionales para pasar al Chip (ej: color, variant).
 * @returns {JSX.Element} Un componente Box que contiene la línea de información.
 */
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


/**
 * Componente principal que renderiza un item de resumen de reporte en una lista.
 * Muestra la información clave del reporte, incluyendo título, autor, fechas, estado,
 * y un botón de acciones para abrir un drawer con más detalles.
 * * @param {object} props - Propiedades del componente.
 * @param {object} props.report - El objeto de datos del reporte.
 * @param {string} [props.report.foto_url] - URL de la imagen principal del reporte.
 * @param {string} props.report.titulo - Título del reporte.
 * @param {boolean} props.report.es_prioritario - Si el reporte es prioritario (premium).
 * @param {string} props.report.codigo_reporte - Código único del reporte.
 * @param {string} [props.report.autor_alias] - Alias del autor.
 * @param {string} [props.report.autor_nombre] - Nombre del autor.
 * @param {boolean} props.report.es_anonimo - Si el reporte es anónimo.
 * @param {string} [props.report.nombre_plan_autor] - Nombre del plan del autor (para destacar si es premium).
 * @param {string} props.report.fecha_creacion_formateada - Fecha de creación (formateada).
 * @param {string} [props.report.categoria_sugerida] - Categoría sugerida por IA o usuario.
 * @param {string} props.report.categoria - Categoría principal.
 * @param {string} props.report.distrito - Distrito del reporte.
 * @param {string} props.report.urgencia - Nivel de urgencia.
 *React {number} [props.report.reportes_vinculados_count] - Número de reportes vinculados.
 * @param {string} props.report.estado - Estado actual del reporte (ej: 'verificado').
 * @param {number} props.index - El índice del item en la lista (para mostrar numeración).
 * @param {Function} props.onOpenDrawer - Callback que se ejecuta al hacer clic en el ícono de "Más". Recibe el objeto `report`.
 * @returns {JSX.Element} Un componente Paper que representa la fila del reporte.
 */
function ItemReporteResumen({ report, index, onOpenDrawer }) {
  const authorName = report.autor_alias || report.autor_nombre || (report.es_anonimo ? 'Anónimo' : 'Desconocido');
  const isAuthorPremium = report.nombre_plan_autor && report.nombre_plan_autor !== 'Plan Gratuito';

  return (
    <Paper variant="outlined" sx={{ display: 'flex', p: 2, gap: 2.5, alignItems: 'center',minWidth:"1100px",maxWidth:'100%' }}>

        {/* --- # Índice --- */}
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, pr: 1, borderRight: 1, borderColor: 'divider' }}>
            <Typography variant="h5" color="text.secondary">
                {index + 1}
            </Typography>
        </Box>

        {/* --- Foto --- */}
        <Box sx={{ flexShrink: 0, alignSelf: 'center' }}>
            <Avatar variant="rounded" src={report.foto_url} sx={{ width: 90, height: 90, bgcolor: 'action.hover' }}>
                <NoImageIcon sx={{ fontSize: 40 }}/>
            </Avatar>
        </Box>

        {/* --- Contenido Principal --- */}
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

            {/* --- Detalles (Grid) --- */}
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
                {/* --- Columna Urgencia y Vinculados --- */}
                <Grid item xs={12} sm={6} md={5} lg={4}> {/* Ajustar tamaños si es necesario */}
                    <Stack spacing={1}>
                        <InfoItem icon={<PriorityHighIcon />} label="Urgencia" value={report.urgencia} />
                        {/* --- Mostrar Reportes Vinculados --- */}
                        {report.reportes_vinculados_count > 0 && (
                            <InfoItem
                                icon={<MergeTypeIcon />}
                                label="Vinculados"
                                value={report.reportes_vinculados_count.toString()}
                                chip={true}
                                chipProps={{ color: 'secondary', size: 'small' }}
                            />
                        )}
                    </Stack>
                </Grid>
            </Grid>
        </Box>

        {/* --- Estado --- */}
        <Box sx={{ display: 'flex', alignItems: 'center', mr:8, justifyContent: { xs: 'flex-start', md: 'center' }, mt:{xs: 1, md: 0} }}>
            <StatusChip status={report.estado} />
        </Box>

        {/* --- Botón de Acciones --- */}
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