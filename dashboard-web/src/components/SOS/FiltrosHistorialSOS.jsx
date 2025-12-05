// src/components/SOS/FiltrosHistorialSOS.jsx
import React, { useState, useEffect } from 'react';
import {
    Paper, Stack, Button, ButtonGroup, FormControl, InputLabel,
    Select, MenuItem, Box, Tooltip, Grid, Divider, Typography, useTheme
} from '@mui/material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import dayjs from 'dayjs';
import 'dayjs/locale/es'; 
import { FilterListOff as ClearIcon, CalendarMonth as DateIcon } from '@mui/icons-material';
import SelectorUsuarioNotificaciones from '../Notificaciones/SelectorUsuarioNotificaciones';

// date-fns
import { startOfDay, endOfDay, subDays, startOfWeek, endOfWeek, startOfMonth, endOfMonth } from 'date-fns';

function FiltrosHistorialSOS({ initialFilters, onFilterChange }) {
    const theme = useTheme();
    const defaultFilters = { userId: null, startDate: null, endDate: null, estado: '', estado_atencion: '' };
    const [filters, setFilters] = useState(initialFilters || defaultFilters);

    useEffect(() => {
        setFilters(initialFilters || defaultFilters);
    // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [initialFilters]);

    const handleInputChange = (event) => {
        const { name, value } = event.target;
        const newFilters = { ...filters, [name]: value };
        setFilters(newFilters);
        onFilterChange(newFilters);
    };

    const handleUserChange = (userId) => {
        const newFilters = { ...filters, userId: userId };
        setFilters(newFilters);
        onFilterChange(newFilters);
    };

    const handleDateChange = (field, date) => {
        const newDate = date ? date.toDate() : null;
        let newFilters = { ...filters, [field]: newDate };

        // Validaciones de rango
        if (field === 'startDate' && newFilters.endDate && newDate && newFilters.endDate < newDate) {
            newFilters = { ...newFilters, endDate: newDate };
        }
        if (field === 'endDate' && newFilters.startDate && newDate && newFilters.startDate > newDate) {
            newFilters = { ...newFilters, startDate: newDate };
        }

        setFilters(newFilters);
        onFilterChange(newFilters);
    };

    const setDatePreset = (preset) => {
        let start = null, end = null;
        const now = new Date();
        switch (preset) {
            case 'today': start = startOfDay(now); end = endOfDay(now); break;
            case 'yesterday': start = startOfDay(subDays(now, 1)); end = endOfDay(subDays(now, 1)); break;
            case 'last7': start = startOfWeek(subDays(now, 6)); end = endOfWeek(now); break;
            case 'month': start = startOfMonth(now); end = endOfMonth(now); break;
            default: break;
        }
        const newFilters = { ...filters, startDate: start, endDate: end };
        setFilters(newFilters);
        onFilterChange(newFilters);
    };

    const handleClear = () => {
        setFilters(defaultFilters);
        onFilterChange(defaultFilters);
    };

    return (
        <Paper 
            elevation={0} 
            variant="outlined" 
            sx={{ 
                p: 3, 
                mb: 3, 
                borderRadius: 3, 
                bgcolor: 'background.paper',
                border: `1px solid ${theme.palette.divider}`
            }}
        >
            <Stack spacing={3}>
                
                {/* 1. Fila Superior: Usuario y Fechas Rápidas */}
                <Grid container spacing={2} alignItems="center">
                    <Grid item xs={12} md={5}>
                        {/* SOLUCIÓN AL PROBLEMA DE CONTRAÍDO:
                           Envolvemos el selector en un Box con width: 100%. 
                           Esto fuerza al componente hijo a ocupar todo el espacio de la celda del Grid.
                        */}
                        <Box sx={{ width: '100%', minWidth: '450px' }}>
                            <SelectorUsuarioNotificaciones
                                onUserSelected={handleUserChange}
                                value={filters.userId}
                                label="Filtrar por Usuario"
                                fullWidth // Propiedad estándar de MUI, por si el componente la soporta directamente
                            />
                        </Box>
                    </Grid>
                    
                    <Grid item xs={12} md={7}>
                        <Stack direction="row" alignItems="center" spacing={2} justifyContent={{ xs: 'flex-start', md: 'flex-end' }}>
                            <Typography variant="caption" color="text.secondary" fontWeight="bold">RANGO RÁPIDO:</Typography>
                            <ButtonGroup variant="outlined" size="small" sx={{ bgcolor: 'background.paper' }}>
                                <Button onClick={() => setDatePreset('today')}>Hoy</Button>
                                <Button onClick={() => setDatePreset('yesterday')}>Ayer</Button>
                                <Button onClick={() => setDatePreset('last7')}>Semana</Button>
                                <Button onClick={() => setDatePreset('month')}>Mes</Button>
                            </ButtonGroup>
                        </Stack>
                    </Grid>
                </Grid>

                <Divider />

                {/* 2. Fila Inferior: DatePickers y Estados */}
                <Grid container spacing={2} alignItems="center">
                    
                    {/* Selectores de Fecha */}
                    <Grid item xs={12} lg={5}>
                        <LocalizationProvider dateAdapter={AdapterDayjs} adapterLocale="es">
                            <Stack direction="row" spacing={2}>
                                <DatePicker
                                    label="Desde"
                                    value={filters.startDate ? dayjs(filters.startDate) : null}
                                    onChange={(date) => handleDateChange('startDate', date)}
                                    slotProps={{ textField: { size: 'small', fullWidth: true, InputProps: { startAdornment: <DateIcon color="action" sx={{mr:1}}/> } } }}
                                    format="DD/MM/YYYY"
                                    maxDate={filters.endDate ? dayjs(filters.endDate) : undefined}
                                />
                                <DatePicker
                                    label="Hasta"
                                    value={filters.endDate ? dayjs(filters.endDate) : null}
                                    onChange={(date) => handleDateChange('endDate', date)}
                                    slotProps={{ textField: { size: 'small', fullWidth: true } }}
                                    format="DD/MM/YYYY"
                                    minDate={filters.startDate ? dayjs(filters.startDate) : undefined}
                                />
                            </Stack>
                        </LocalizationProvider>
                    </Grid>

                    {/* Selectores de Estado - con minWidth para evitar colapso */}
                    <Grid item xs={12} sm={6} lg={2.5}>
                        <FormControl size="small" fullWidth sx={{ minWidth: 140 }}>
                            <InputLabel>Estado Alerta</InputLabel>
                            <Select name="estado" value={filters.estado} label="Estado Alerta" onChange={handleInputChange}>
                                <MenuItem value="">Todos</MenuItem>
                                <MenuItem value="activo">⚠️ Activa</MenuItem>
                                <MenuItem value="finalizado">✅ Finalizada</MenuItem>
                            </Select>
                        </FormControl>
                    </Grid>

                    <Grid item xs={12} sm={6} lg={2.5}>
                        <FormControl size="small" fullWidth sx={{ minWidth: 140 }}>
                            <InputLabel>Atención</InputLabel>
                            <Select name="estado_atencion" value={filters.estado_atencion} label="Atención" onChange={handleInputChange}>
                                <MenuItem value="">Cualquiera</MenuItem>
                                <MenuItem value="En Espera">🔴 En Espera</MenuItem>
                                <MenuItem value="En Curso">🟠 En Curso</MenuItem>
                                <MenuItem value="Atendida">🟢 Atendida</MenuItem>
                            </Select>
                        </FormControl>
                    </Grid>

                    {/* Botón Limpiar */}
                    <Grid item xs={12} lg={2} sx={{ display: 'flex', justifyContent: { xs: 'flex-start', lg: 'flex-end' } }}>
                        <Button
                            variant="text"
                            color="inherit"
                            size="small"
                            startIcon={<ClearIcon />}
                            onClick={handleClear}
                            sx={{ color: 'text.secondary', fontWeight: 'bold', whiteSpace: 'nowrap' }}
                        >
                            Limpiar Filtros
                        </Button>
                    </Grid>
                </Grid>

            </Stack>
        </Paper>
    );
}

export default FiltrosHistorialSOS;