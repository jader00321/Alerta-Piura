// src/components/SOS/FiltrosHistorialSOS.jsx
import React, { useState, useEffect } from 'react';
import {
    Paper, Stack, TextField, Button, ButtonGroup, FormControl, InputLabel,
    Select, MenuItem, Box, Tooltip, IconButton // IconButton still used for Clear if preferred
} from '@mui/material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import dayjs from 'dayjs';
import 'dayjs/locale/es';
import FilterListOffIcon from '@mui/icons-material/FilterListOff';
import SelectorUsuarioNotificaciones from '../Notificaciones/SelectorUsuarioNotificaciones';

// date-fns functions needed for presets and ensuring correct Date objects
import { startOfDay, endOfDay, subDays, startOfWeek, endOfWeek, startOfMonth, endOfMonth } from 'date-fns';

function FiltrosHistorialSOS({ initialFilters, onFilterChange }) {
    // Initialize state directly from potentially updated initialFilters
    const [filters, setFilters] = useState(initialFilters || {
        userId: null, startDate: null, endDate: null, estado: '', estado_atencion: '',
    });

    // Sync state if initialFilters prop changes externally (e.g., parent reset)
    useEffect(() => {
        setFilters(initialFilters || { userId: null, startDate: null, endDate: null, estado: '', estado_atencion: '' });
    }, [initialFilters]);


    const handleInputChange = (event) => {
        const { name, value } = event.target;
        const newFilters = { ...filters, [name]: value };
        setFilters(newFilters);
        onFilterChange(newFilters); // Notifica al padre inmediatamente
    };

    const handleUserChange = (userId) => {
        const newFilters = { ...filters, userId: userId };
        setFilters(newFilters);
        onFilterChange(newFilters);
    };

    const handleDateChange = (field, date) => {
        const newDate = date ? date.toDate() : null; // DatePicker -> Dayjs -> Date | null
        let newFilters = { ...filters, [field]: newDate };

        // Validaciones básicas de rango
        if (field === 'startDate' && newFilters.endDate && newDate && newFilters.endDate < newDate) {
            newFilters = {...newFilters, endDate: newDate}; // Ajusta fecha fin si es necesario
        }
        if (field === 'endDate' && newFilters.startDate && newDate && newFilters.startDate > newDate) {
             newFilters = {...newFilters, startDate: newDate}; // Ajusta fecha inicio si es necesario
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
            case 'last30': start = startOfDay(subDays(now, 29)); end = endOfDay(now); break;
            case 'month': start = startOfMonth(now); end = endOfMonth(now); break;
        }
        const newFilters = { ...filters, startDate: start, endDate: end };
        setFilters(newFilters);
        onFilterChange(newFilters);
    };

    const handleClear = () => {
        const clearedFilters = { userId: null, startDate: null, endDate: null, estado: '', estado_atencion: '' };
        setFilters(clearedFilters);
        onFilterChange(clearedFilters);
    };

    return (
        <Paper variant="outlined" sx={{ p: 2, mb: 3 }}>
            <Stack spacing={2}>
                {/* Fila 1 */}
                <Stack direction={{ xs: 'column', lg: 'row' }} spacing={2} alignItems="center">
                    <Box sx={{ width: '100%', maxWidth: { lg: '400px' } }}>
                        <SelectorUsuarioNotificaciones
                            onUserSelected={handleUserChange}
                            value={filters.userId}
                        />
                    </Box>
                    <ButtonGroup variant="outlined" size="small" sx={{ flexShrink: 0 }}>
                        <Button onClick={() => setDatePreset('today')}>Hoy</Button>
                        <Button onClick={() => setDatePreset('yesterday')}>Ayer</Button>
                        <Button onClick={() => setDatePreset('last7')}>Últimos 7 Días</Button>
                        <Button onClick={() => setDatePreset('last30')}>Últimos 30 Días</Button>
                         <Button onClick={() => setDatePreset('month')}>Este Mes</Button>
                    </ButtonGroup>
                     {/* FIX: Clear button with text */}
                     <Tooltip title="Limpiar filtros y mostrar todas las alertas">
                         <Button
                            variant="text"
                            size="small"
                            startIcon={<FilterListOffIcon />}
                            onClick={handleClear}
                            sx={{ml: {xs: 0, lg: 'auto'}}} // Mover a la derecha en pantallas grandes
                         >
                             Limpiar / Ver Todas
                         </Button>
                    </Tooltip>
                </Stack>

                {/* Fila 2: DatePickers, Estado, Atención */}
                <Stack direction={{ xs: 'column', lg: 'row' }} spacing={2} alignItems="center">
                    <LocalizationProvider dateAdapter={AdapterDayjs} adapterLocale="es">
                        <DatePicker
                            label="Fecha Desde"
                            value={filters.startDate ? dayjs(filters.startDate) : null}
                            onChange={(date) => handleDateChange('startDate', date)}
                            slotProps={{ textField: { size: 'small', fullWidth: true } }}
                            format="DD/MM/YYYY"
                            maxDate={filters.endDate ? dayjs(filters.endDate) : undefined}
                        />
                        <DatePicker
                            label="Fecha Hasta"
                            value={filters.endDate ? dayjs(filters.endDate) : null}
                            onChange={(date) => handleDateChange('endDate', date)}
                            slotProps={{ textField: { size: 'small', fullWidth: true } }}
                            format="DD/MM/YYYY"
                            minDate={filters.startDate ? dayjs(filters.startDate) : undefined}
                        />
                    </LocalizationProvider>
                     <FormControl sx={{ minWidth: 150 }} size="small" fullWidth>
                        <InputLabel>Estado Alerta</InputLabel>
                        <Select name="estado" value={filters.estado} label="Estado Alerta" onChange={handleInputChange}>
                            <MenuItem value="">Todos</MenuItem>
                            <MenuItem value="activo">Activa</MenuItem>
                            <MenuItem value="finalizado">Finalizada</MenuItem>
                        </Select>
                    </FormControl>
                    <FormControl sx={{ minWidth: 150 }} size="small" fullWidth>
                        <InputLabel>Estado Atención</InputLabel>
                        <Select name="estado_atencion" value={filters.estado_atencion} label="Estado Atención" onChange={handleInputChange}>
                            <MenuItem value="">Todos</MenuItem>
                            <MenuItem value="En Espera">En Espera</MenuItem>
                            <MenuItem value="En Curso">En Curso</MenuItem>
                            <MenuItem value="Atendida">Atendida</MenuItem>
                        </Select>
                    </FormControl>
                </Stack>
            </Stack>
        </Paper>
    );
}

export default FiltrosHistorialSOS;