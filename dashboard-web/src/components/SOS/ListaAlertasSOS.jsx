/**

* Componente: ListaAlertasSOS
* ---
* Muestra el historial de alertas SOS emitidas por usuarios, con posibilidad de visualizar su estado,
* revisar si fueron atendidas y actualizar su estado de atención.
*
* Incluye tres componentes principales:
* 1. EstadoAlertaChip → Indica si la alerta está activa o finalizada.
* 2. EstadoAtencionControl → Permite cambiar entre los estados de atención ("En Espera", "En Curso", "Atendida").
* 3. Lista principal → Renderiza cada alerta con sus detalles y controles.
     */

import React from 'react';
import {
    List, ListItemButton, ListItemText, Typography, Box, Chip,
    Skeleton, Paper, Stack, Tooltip, ButtonGroup, Button, useTheme
} from '@mui/material';
import {
    Warning as WarningIcon, CheckCircle as CheckIcon,
    RadioButtonChecked as ActiveIcon, RadioButtonUnchecked as WaitingIcon,
    Autorenew as InProgressIcon, DoneAll as AttendedIcon,
    Visibility as VisibleIcon, VisibilityOff as NotVisibleIcon
} from '@mui/icons-material';

/*                    Componente auxiliar: EstadoAlertaChip                   */
/**

* Muestra el estado general de la alerta (activa o finalizada)
  */
const EstadoAlertaChip = ({ estado }) => {
    const active = estado === 'activo';
    return (
        <Chip
            label={active ? 'Activa' : 'Finalizada'}
            color={active ? 'error' : 'default'}
            size="small"
            icon={active ? <WarningIcon /> : <CheckIcon />}
            variant="filled"
            sx={{
                mr: 1,
                color: active ? '#fff' : 'text.primary',
                fontWeight: 'bold'
            }}
        />
    );
};

/*                Componente auxiliar: EstadoAtencionControl                  */
/**

* Permite modificar el estado de atención de una alerta SOS.
* Los tres estados disponibles son: "En Espera", "En Curso", "Atendida".
  */
const EstadoAtencionControl = ({ estado, alertId, onChange }) => {
    const theme = useTheme();
    const statuses = [
        { value: 'En Espera', icon: <WaitingIcon />, color: 'error', activeIcon: <ActiveIcon sx={{ color: theme.palette.error.contrastText }} /> },
        { value: 'En Curso', icon: <InProgressIcon />, color: 'warning', activeIcon: <InProgressIcon sx={{ color: theme.palette.warning.contrastText }} /> },
        { value: 'Atendida', icon: <AttendedIcon />, color: 'success', activeIcon: <AttendedIcon sx={{ color: theme.palette.success.contrastText }} /> },
    ];
    const currentStatusValue = estado || 'En Espera';

    return (<ButtonGroup variant="outlined" size="small" aria-label="Estado de atención SOS">
        {statuses.map(s => {
            const isSelected = currentStatusValue === s.value;
            return (<Tooltip title={s.value} key={s.value}>
                <Button
                    onClick={(e) => { e.stopPropagation(); onChange(alertId, s.value); }}
                    color={s.color}
                    variant={isSelected ? 'contained' : 'outlined'}
                    sx={{
                        minWidth: 40,
                        px: 1,
                        boxShadow: isSelected ? 'none' : undefined,
                        '& .MuiButton-startIcon': {
                            color: isSelected
                                ? theme.palette[s.color].contrastText
                                : theme.palette[s.color].main
                        }
                    }}
                    startIcon={isSelected ? s.activeIcon : s.icon}
                /> </Tooltip>
            );
        })} </ButtonGroup>
    );
};

/*                      Componente principal: ListaAlertasSOS                 */
/**

* Props:
* * alerts: Array con las alertas SOS
* * selectedAlertId: ID de la alerta seleccionada actualmente
* * loading: Booleano que indica si se están cargando las alertas
* * onSelectAlert: Callback ejecutado al seleccionar una alerta
* * onAttentionChange: Callback ejecutado al cambiar el estado de atención
    */
function ListaAlertasSOS({ alerts, selectedAlertId, loading, onSelectAlert, onAttentionChange }) {

    /* ----------------------------- Estado: cargando ----------------------------- */
    if (loading) {
        return (<Paper variant="outlined">
            <Stack spacing={1} sx={{ p: 1 }}>
                {[...Array(5)].map((_, i) => (<Skeleton key={i} variant="rounded" height={80} />
                ))} </Stack> </Paper>
        );
    }

    /* ----------------------------- Estado: vacío -------------------------------- */
    if (!alerts || alerts.length === 0) {
        return (
            <Paper
                variant="outlined"
                sx={{
                    p: 3,
                    textAlign: 'center',
                    borderStyle: 'dashed',
                    bgcolor: 'action.hover'
                }}
            > <Typography color="text.secondary">
                    No hay historial de alertas SOS. </Typography> </Paper>
        );
    }

    /* ------------------------- Renderizado principal --------------------------- */
    return (<Paper variant="outlined">
        <List
            sx={{
                p: 0,
                maxHeight: { xs: '50vh', md: '75vh' },
                overflowY: 'auto'
            }}
        >
            {alerts.map((alert, index) => (
                <ListItemButton
                    key={alert.id}
                    selected={selectedAlertId === alert.id}
                    onClick={() => onSelectAlert(alert)}
                    divider={index < alerts.length - 1}
                    sx={{
                        py: 1.5,
                        bgcolor: !alert.revisada ? 'warning.lighter' : 'inherit',
                        '&.Mui-selected': {
                            bgcolor: 'action.selected',
                            '&:hover': { bgcolor: 'action.selected' }
                        }
                    }}
                    alignItems="flex-start"
                >
                    <ListItemText
                        disableTypography
                        primary={
                            <Box sx={{
                                display: 'flex',
                                justifyContent: 'space-between',
                                alignItems: 'center',
                                mb: 1
                            }}> <Stack
                                direction="row"
                                spacing={1}
                                alignItems="center"
                                flexWrap="wrap"
                            > <EstadoAlertaChip estado={alert.estado} />
                                    <Typography
                                        variant="body1"
                                        sx={{ fontWeight: 'bold' }}
                                    >
                                        {alert.alias || alert.nombre} </Typography>
                                    {!alert.revisada && (
                                        <Chip
                                            label="Nueva"
                                            color="warning"
                                            size="small"
                                            sx={{ ml: 1, height: 'auto' }}
                                        />
                                    )} </Stack>
                                <Typography
                                    variant="caption"
                                    color="text.secondary"
                                    sx={{ flexShrink: 0, ml: 1 }}
                                >
                                    {new Date(alert.fecha_inicio).toLocaleString()} </Typography> </Box>
                        }
                        secondary={
                            <Stack spacing={1} sx={{ mt: 0.5 }}>
                                {/* Línea con código y estado de revisión */}
                                <Stack
                                    direction={{ xs: 'column', sm: 'row' }}
                                    justifyContent="space-between"
                                    alignItems={{ xs: 'flex-start', sm: 'center' }}
                                    spacing={1}
                                >
                                    <Typography
                                        variant="body2"
                                        color="text.secondary"
                                        sx={{ fontSize: '0.8rem' }}
                                    >
                                        Código: <strong>{alert.codigo_alerta}</strong> </Typography>
                                    <Tooltip
                                        title={alert.revisada
                                            ? "Alerta ya revisada"
                                            : "Alerta NUEVA (no revisada)"}
                                    >
                                        <Chip
                                            icon={alert.revisada
                                                ? <VisibleIcon />
                                                : <NotVisibleIcon />}
                                            label={alert.revisada
                                                ? "Revisada"
                                                : "Nueva"}
                                            size="small"
                                            color={alert.revisada
                                                ? "default"
                                                : "warning"}
                                            variant="outlined"
                                        /> </Tooltip> </Stack>

                                ```
                                {/* Datos de contacto y mensaje */}
                                <Box>
                                    <Typography
                                        variant="caption"
                                        color="text.secondary"
                                    >
                                        Contacto Emergencia: {alert.contacto_emergencia_telefono || 'N/A'}
                                    </Typography>
                                    <Tooltip title={alert.contacto_emergencia_mensaje || ''}>
                                        <Typography
                                            variant="caption"
                                            color="text.secondary"
                                            noWrap
                                            display="block"
                                        >
                                            Mensaje: {alert.contacto_emergencia_mensaje || 'N/A'}
                                        </Typography>
                                    </Tooltip>
                                </Box>

                                {/* Controles de atención */}
                                <Box sx={{ display: 'flex', justifyContent: 'flex-end', mt: 1 }}>
                                    <EstadoAtencionControl
                                        estado={alert.estado_atencion}
                                        alertId={alert.id}
                                        onChange={onAttentionChange}
                                    />
                                </Box>
                            </Stack>
                        }
                    />
                </ListItemButton>
            ))}
        </List>
    </Paper>
    );
}

export default ListaAlertasSOS;
