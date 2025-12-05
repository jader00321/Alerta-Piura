import React from 'react';
import {
  Paper, Box, Typography, Avatar, Chip, IconButton, Tooltip, Stack, Grid, useTheme
} from '@mui/material';
import {
  ImageNotSupported as NoImageIcon, MoreVert as MoreVertIcon,
  CheckCircle as CheckIcon, Cancel as RejectIcon, HourglassEmpty as PendingIcon,
  HelpOutline as SuggestionIcon, Star as StarIcon, WorkspacePremium as PremiumIcon,
  Person as PersonIcon, CalendarToday as CalendarTodayIcon, LocationOn as LocationIcon,
  Label as CategoryIcon, VisibilityOff as VisibilityOffIcon,
  PriorityHigh as PriorityHighIcon,
  MergeType as MergeTypeIcon,
  Chat as ChatIcon
} from '@mui/icons-material';

// --- StatusChip (Más grande y legible) ---
const StatusChip = ({ status }) => {
  const theme = useTheme();
  
  const statusConfig = {
    verificado: { label: 'Verificado', bg: theme.palette.success.dark, icon: <CheckIcon fontSize="small" style={{color: 'white'}} /> },
    rechazado: { label: 'Rechazado', bg: theme.palette.error.dark, icon: <RejectIcon fontSize="small" style={{color: 'white'}} /> },
    pendiente_verificacion: { label: 'Pendiente', bg: theme.palette.warning.dark, icon: <PendingIcon fontSize="small" style={{color: 'white'}} /> },
    oculto: { label: 'Oculto', bg: theme.palette.text.secondary, icon: <VisibilityOffIcon fontSize="small" style={{color: 'white'}} /> },
    fusionado: { label: 'Fusionado', bg: theme.palette.info.dark, icon: <MergeTypeIcon fontSize="small" style={{color: 'white'}} /> },
  };

  const config = statusConfig[status] || { label: status, bg: theme.palette.grey[600], icon: null };

  return (
    <Chip
      icon={config.icon}
      label={config.label}
      sx={{
        bgcolor: config.bg,
        color: 'white',
        fontWeight: 'bold',
        fontSize: '0.85rem', // Letra más grande
        height: 30, // Chip más alto
        borderRadius: 2
      }}
    />
  );
};

// --- Helper para filas de datos con Contexto ---
const DataRow = ({ icon, label, value, highlightColor = null }) => (
  <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 1 }}>
    {React.cloneElement(icon, { sx: { color: highlightColor || 'action.active', fontSize: 22 } })}
    <Box>
      <Typography variant="caption" sx={{ display: 'block', fontWeight: 700, color: 'text.secondary', letterSpacing: 0.5 }}>
        {label}
      </Typography>
      <Typography variant="body1" sx={{ fontWeight: highlightColor ? 700 : 400, color: highlightColor || 'text.primary', lineHeight: 1.2 }}>
        {value}
      </Typography>
    </Box>
  </Box>
);

/**
 * ItemReporteResumen - Diseño Espacioso y Detallado
 */
function ItemReporteResumen({ report, index, onOpenDrawer }) {
  const theme = useTheme();
  
  // Datos procesados
  const authorName = report.autor_alias || report.autor_nombre || (report.es_anonimo ? 'Anónimo' : 'Desconocido');
  const isAuthorPremium = report.nombre_plan_autor && report.nombre_plan_autor !== 'Plan Gratuito';
  const unreadMessages = report.mensajes_no_leidos || 0;
  
  // Lógica de color para categoría sugerida (Tu petición específica)
  const isSuggestedCategory = !!report.categoria_sugerida;
  const categoryColor = isSuggestedCategory ? theme.palette.info.main : null;
  const categoryText = isSuggestedCategory ? `${report.categoria_sugerida} (Sugerida)` : report.categoria;
  const categoryIcon = isSuggestedCategory ? <SuggestionIcon /> : <CategoryIcon />;

  return (
    <Paper 
      elevation={0}
      sx={{ 
        display: 'flex', 
        p: 2, // Aumentado padding para más espacio
        gap: 5, 
        alignItems: 'flex-start', // Alineación superior para mejor lectura vertical
        width: '100%',
        border: `1px solid ${theme.palette.divider}`,
        borderRadius: 3,
        bgcolor: 'background.paper',
        transition: 'all 0.2s ease-in-out',
        '&:hover': {
          borderColor: theme.palette.primary.main,
          boxShadow: theme.shadows[6],
          transform: 'translateY(-2px)'
        }
      }}
    >
      {/* 1. Índice Grande */}
      <Typography variant="h5" color="text.disabled" sx={{ minWidth: 30, fontWeight: 'bold', mt: 1 }}>
        #{index + 1}
      </Typography>

      {/* 2. Imagen Grande (Thumbnail) */}
      <Box sx={{ flexShrink: 0 }}>
        {report.foto_url ? (
          <Box 
            component="img"
            src={report.foto_url}
            alt="Reporte"
            sx={{
              width: 140, height: 100, // Imagen más grande
              borderRadius: 2,
              objectFit: 'cover',
              border: `1px solid ${theme.palette.divider}`,
              boxShadow: 1
            }}
          />
        ) : (
          <Avatar variant="rounded" sx={{ width: 140, height: 100, bgcolor: 'action.hover', borderRadius: 2 }}>
            <NoImageIcon sx={{ fontSize: 40, color: 'text.disabled' }} />
          </Avatar>
        )}
      </Box>

      {/* 3. Contenido Principal - Expandido */}
      <Box sx={{ flexGrow: 1, minWidth: 0 }}>
        
        {/* Encabezado: Título y Badges */}
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 2, flexWrap: 'wrap' }}>
          {report.es_prioritario && (
            <Tooltip title="Prioridad Alta">
              <StarIcon sx={{ color: '#FFD700', fontSize: 28 }} />
            </Tooltip>
          )}
          
          <Typography variant="h6" sx={{ fontWeight: 800, fontSize: '1.25rem', lineHeight: 1.2 }}>
            {report.titulo}
          </Typography>

          <Chip 
            label={report.codigo_reporte} 
            size="small" 
            sx={{ fontWeight: 'bold', bgcolor: 'action.selected', fontSize: '0.75rem' }} 
          />

          {unreadMessages > 0 && (
            <Chip 
                icon={<ChatIcon style={{ fontSize: 16, color: 'white' }} />} 
                label={`${unreadMessages} msj`} 
                color="error" 
                size="small" 
                sx={{ fontWeight: 'bold' }}
            />
          )}
        </Box>

        {/* Grid de Detalles con Contexto */}
        <Grid container spacing={2}>
            {/* Columna 1: Ubicación y Fecha */}
            <Grid item xs={12} md={4}>
                <DataRow 
                    icon={<LocationIcon />} 
                    label="UBICACIÓN / DISTRITO" 
                    value={report.distrito} 
                />
                <DataRow 
                    icon={<CalendarTodayIcon />} 
                    label="FECHA DE REPORTE" 
                    value={new Date(report.fecha_creacion_formateada || report.fecha_creacion).toLocaleDateString()} 
                />
            </Grid>

            {/* Columna 2: Categoría y Autor */}
            <Grid item xs={12} md={4}>
                <DataRow 
                    icon={categoryIcon}
                    label="CATEGORÍA" 
                    value={categoryText}
                    highlightColor={categoryColor} // Color distintivo si es sugerida
                />
                <DataRow 
                    icon={isAuthorPremium ? <PremiumIcon /> : <PersonIcon />}
                    label="AUTOR DEL REPORTE" 
                    value={authorName}
                    highlightColor={isAuthorPremium ? theme.palette.warning.main : null}
                />
            </Grid>

            {/* Columna 3: Urgencia y Vinculados */}
            <Grid item xs={12} md={4}>
                <DataRow 
                    icon={<PriorityHighIcon />} 
                    label="NIVEL DE URGENCIA" 
                    value={report.urgencia}
                    highlightColor={report.urgencia === 'Alta' ? theme.palette.error.main : null}
                />
                {report.reportes_vinculados_count > 0 && (
                    <DataRow 
                        icon={<MergeTypeIcon />} 
                        label="REPORTE VINCULADOS" 
                        value={`${report.reportes_vinculados_count} reportes`}
                        highlightColor={theme.palette.secondary.main}
                    />
                )}
            </Grid>
        </Grid>
      </Box>

      {/* 4. Columna Derecha: Estado y Botón */}
      <Stack spacing={2} alignItems="flex-end" justifyContent="center" sx={{ alignSelf: 'center' }}>
        <StatusChip status={report.estado} />
        
        <Tooltip title="Gestionar Reporte">
          <IconButton 
            onClick={() => onOpenDrawer(report)} 
            sx={{ 
              border: `1px solid ${theme.palette.divider}`, 
              width: 44, height: 44,
              '&:hover': { bgcolor: 'primary.light', color: 'primary.main', borderColor: 'primary.main' }
            }}
          >
            <MoreVertIcon />
          </IconButton>
        </Tooltip>
      </Stack>

    </Paper>
  );
}

export default ItemReporteResumen;