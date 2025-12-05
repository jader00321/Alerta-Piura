// src/components/SOS/ListaAlertasSOS.jsx
import React, { useState } from 'react';
import {
    List, Typography, Box, Chip, Skeleton, Paper, Stack, Tooltip, IconButton, 
    useTheme, alpha, Fade, Divider, Button
} from '@mui/material';
import {
    WarningAmber as ActiveIcon, CheckCircleOutline as FinishedIcon,
    RadioButtonUnchecked as WaitingIcon, Autorenew as InProgressIcon, CheckCircle as AttendedIcon,
    DeleteOutline as DeleteIcon, Person as PersonIcon, AccessTime as TimeIcon,
    ContactPhone as ContactIcon
} from '@mui/icons-material';

import sosService from '../../services/sosService';
import ModalConfirmacion from '../Comunes/ModalConfirmacion';

// --- SUBCOMPONENTES ---

const StatusBadge = ({ isActive }) => {
    const theme = useTheme();
    return (
        <Chip
            icon={isActive ? <ActiveIcon style={{ fontSize: 16 }} /> : <FinishedIcon style={{ fontSize: 16 }} />}
            label={isActive ? 'ACTIVA' : 'FINALIZADA'}
            size="small"
            sx={{
                fontWeight: 'bold',
                fontSize: '0.65rem',
                height: 24,
                bgcolor: isActive ? alpha(theme.palette.error.main, 0.1) : alpha(theme.palette.grey[500], 0.1),
                color: isActive ? 'error.main' : 'text.secondary',
                border: `1px solid ${isActive ? alpha(theme.palette.error.main, 0.2) : theme.palette.divider}`
            }}
        />
    );
};

const AttentionControl = ({ status, onChange }) => {
    const theme = useTheme();
    const config = {
        'En Espera': { color: theme.palette.error.main, bg: alpha(theme.palette.error.main, 0.1), icon: <WaitingIcon fontSize="small"/> },
        'En Curso': { color: theme.palette.warning.main, bg: alpha(theme.palette.warning.main, 0.1), icon: <InProgressIcon fontSize="small"/> },
        'Atendida': { color: theme.palette.success.main, bg: alpha(theme.palette.success.main, 0.1), icon: <AttendedIcon fontSize="small"/> },
    };
    
    // Ciclo de estados para clic rápido: Espera -> Curso -> Atendida -> Espera
    const nextStatus = {
        'En Espera': 'En Curso',
        'En Curso': 'Atendida',
        'Atendida': 'En Espera'
    };

    const current = config[status] || config['En Espera'];

    return (
        <Tooltip title={`Estado actual: ${status} (Clic para cambiar)`}>
            <Button
                size="small"
                onClick={(e) => { e.stopPropagation(); onChange(nextStatus[status] || 'En Espera'); }}
                startIcon={current.icon}
                sx={{
                    bgcolor: current.bg,
                    color: current.color,
                    fontSize: '0.75rem',
                    fontWeight: 'bold',
                    textTransform: 'none',
                    px: 1.5,
                    borderRadius: 1.5,
                    border: `1px solid ${alpha(current.color, 0.2)}`,
                    '&:hover': {
                        bgcolor: alpha(current.color, 0.2),
                        borderColor: current.color
                    }
                }}
            >
                {status}
            </Button>
        </Tooltip>
    );
};

// --- ITEM DE LISTA (TARJETA) ---

const AlertListItem = ({ alert, isSelected, onSelect, onDelete, onAttentionChange }) => {
    const theme = useTheme();
    const isActive = alert.estado === 'activo';

    return (
        <Paper
            elevation={0}
            onClick={() => onSelect(alert)}
            sx={{
                p: 2,
                mb: 1.5,
                borderRadius: 2,
                border: `1px solid ${isSelected ? theme.palette.primary.main : theme.palette.divider}`,
                bgcolor: isSelected ? alpha(theme.palette.primary.main, 0.04) : 'background.paper',
                cursor: 'pointer',
                transition: 'all 0.2s',
                '&:hover': {
                    borderColor: theme.palette.primary.main,
                    transform: 'translateY(-2px)',
                    boxShadow: theme.shadows[2]
                },
                display: 'flex',
                alignItems: 'center',
                gap: 2
            }}
        >
            {/* 1. Indicador Visual Lateral */}
            <Box 
                sx={{ 
                    width: 4, 
                    height: 40, 
                    borderRadius: 4, 
                    bgcolor: isActive ? 'error.main' : 'text.disabled' 
                }} 
            />

            {/* 2. Info Principal */}
            <Box sx={{ flexGrow: 1, minWidth: 0 }}>
                <Stack direction="row" alignItems="center" spacing={1} mb={0.5}>
                    <StatusBadge isActive={isActive} />
                    <Typography variant="caption" color="text.secondary" sx={{ fontFamily: 'monospace' }}>
                        #{alert.codigo_alerta}
                    </Typography>
                    {!alert.revisada && (
                        <Chip label="NUEVA" size="small" color="error" sx={{ height: 16, fontSize: '0.6rem', fontWeight: 'bold' }} />
                    )}
                </Stack>
                
                <Stack direction="row" alignItems="center" spacing={2}>
                    <Box display="flex" alignItems="center" gap={0.5} color="text.primary">
                        <PersonIcon sx={{ fontSize: 16, color: 'action.active' }} />
                        <Typography variant="body2" fontWeight="bold">
                            {alert.alias || alert.nombre || 'Desconocido'}
                        </Typography>
                    </Box>
                    <Divider orientation="vertical" flexItem sx={{ height: 12, my: 'auto' }} />
                    <Box display="flex" alignItems="center" gap={0.5} color="text.secondary">
                        <TimeIcon sx={{ fontSize: 16 }} />
                        <Typography variant="caption">
                            {new Date(alert.fecha_inicio).toLocaleString()}
                        </Typography>
                    </Box>
                </Stack>
                
                {/* Contacto Resumen */}
                {alert.contacto_emergencia_telefono && (
                    <Box display="flex" alignItems="center" gap={0.5} mt={0.5} color="text.secondary">
                        <ContactIcon sx={{ fontSize: 14 }} />
                        <Typography variant="caption" noWrap>
                            Contacto: {alert.contacto_emergencia_telefono}
                        </Typography>
                    </Box>
                )}
            </Box>

            {/* 3. Acciones Derecha */}
            <Stack direction="column" alignItems="flex-end" spacing={1}>
                <AttentionControl 
                    status={alert.estado_atencion || 'En Espera'} 
                    onChange={(newStatus) => onAttentionChange(alert.id, newStatus)}
                />
                
                <Tooltip title="Eliminar del historial">
                    <IconButton 
                        size="small" 
                        onClick={(e) => onDelete(e, alert.id)}
                        sx={{ 
                            color: 'text.disabled',
                            '&:hover': { color: 'error.main', bgcolor: alpha(theme.palette.error.main, 0.1) }
                        }}
                    >
                        <DeleteIcon fontSize="small" />
                    </IconButton>
                </Tooltip>
            </Stack>
        </Paper>
    );
};

// --- COMPONENTE PRINCIPAL ---

function ListaAlertasSOS({ alerts, selectedAlertId, loading, onSelectAlert, onAttentionChange, onRefresh }) {
    const [deleteModal, setDeleteModal] = useState({ open: false, id: null });

    const handleDeleteClick = (e, id) => {
        e.stopPropagation();
        setDeleteModal({ open: true, id });
    };

    const confirmDelete = async () => {
        try {
            await sosService.deleteAlert(deleteModal.id);
            if (onRefresh) onRefresh();
            else window.location.reload(); 
        } catch (error) {
            console.error("Error al eliminar alerta:", error);
            alert("Error al eliminar.");
        } finally {
            setDeleteModal({ open: false, id: null });
        }
    };

    if (loading) {
        return (
            <Stack spacing={2}>
                {[1, 2, 3].map((i) => (
                    <Paper key={i} sx={{ p: 2, borderRadius: 2 }} variant="outlined">
                        <Skeleton variant="text" width="40%" height={30} />
                        <Skeleton variant="text" width="70%" />
                    </Paper>
                ))}
            </Stack>
        );
    }

    if (!alerts || alerts.length === 0) {
        return (
            <Paper variant="outlined" sx={{ p: 4, textAlign: 'center', borderStyle: 'dashed', borderRadius: 3, bgcolor: 'background.default' }}>
                <Typography color="text.secondary">No se encontraron alertas en el historial.</Typography>
            </Paper>
        );
    }

    return (
        <>
            <Box sx={{ maxHeight: '800px', overflowY: 'auto', pr: 1 }}>
                <Stack spacing={0}>
                    {alerts.map((alert) => (
                        <Fade in={true} key={alert.id}>
                            <Box>
                                <AlertListItem
                                    alert={alert}
                                    isSelected={selectedAlertId === alert.id}
                                    onSelect={onSelectAlert}
                                    onDelete={handleDeleteClick}
                                    onAttentionChange={onAttentionChange}
                                />
                            </Box>
                        </Fade>
                    ))}
                </Stack>
            </Box>

            <ModalConfirmacion
                open={deleteModal.open}
                onClose={() => setDeleteModal({ open: false, id: null })}
                title="Eliminar Registro"
                content="¿Estás seguro de eliminar esta alerta del historial? Esta acción no se puede deshacer."
                confirmText="Eliminar"
                confirmColor="error"
                onConfirm={confirmDelete}
            />
        </>
    );
}

export default ListaAlertasSOS;