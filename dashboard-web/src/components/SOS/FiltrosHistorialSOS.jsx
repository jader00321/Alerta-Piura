import React, { useState, useEffect } from 'react';
import {
    Paper, Stack, TextField, Button, ButtonGroup, FormControl, InputLabel,
    Select, MenuItem, Box, Tooltip, IconButton // IconButton still used for Clear if preferred
} from '@mui/material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import dayjs from 'dayjs';
import 'dayjs/locale/es'; // Importa localización en español para dayjs
import FilterListOffIcon from '@mui/icons-material/FilterListOff';
import SelectorUsuarioNotificaciones from '../Notificaciones/SelectorUsuarioNotificaciones';

// date-fns functions needed for presets and ensuring correct Date objects
import { startOfDay, endOfDay, subDays, startOfWeek, endOfWeek, startOfMonth, endOfMonth } from 'date-fns';

/**
 * Renderiza una barra de filtros (en un Paper) para el historial de alertas SOS.
 *
 * Este componente maneja su propio estado interno para los valores de los filtros
 * (usuario, rango de fechas, estado de alerta y estado de atención).
 *
 * Llama al callback `onFilterChange` **inmediatamente** después de que
 * cualquier valor de filtro cambie, pasando el nuevo objeto de filtros completo.
 * No utiliza un botón de "Aplicar", los filtros son en vivo.
 *
 * Utiliza `date-fns` para los preajustes de fecha y `dayjs` como adaptador
 * para los `DatePicker` de MUI.
 *
 * @param {object} props - Propiedades del componente.
 * @param {object} [props.initialFilters] - El estado inicial de los filtros.
 * @param {string|null} [props.initialFilters.userId] - ID del usuario seleccionado inicialmente.
 * @param {Date|null} [props.initialFilters.startDate] - Fecha de inicio inicial.
 * @param {Date|null} [props.initialFilters.endDate] - Fecha de fin inicial.
 * @param {string} [props.initialFilters.estado] - Estado de alerta (ej: 'activo', 'finalizado').
 * @param {string} [props.initialFilters.estado_atencion] - Estado de atención (ej: 'En Espera').
 * @param {Function} props.onFilterChange - Callback que se dispara con CADA cambio en los filtros.
 * Recibe un objeto con la nueva configuración de filtros.
 * (newFilters: object) => void
 * @returns {JSX.Element} El componente del panel de filtros.
 */
function FiltrosHistorialSOS({ initialFilters, onFilterChange }) {
    // Define el estado inicial por defecto
    const defaultFilters = {
        userId: null, startDate: null, endDate: null, estado: '', estado_atencion: '',
    };
    
    // Initialize state directly from potentially updated initialFilters
    const [filters, setFilters] = useState(initialFilters || defaultFilters);

    // Sync state if initialFilters prop changes externally (e.g., parent reset)
    useEffect(() => {
        setFilters(initialFilters || defaultFilters);
    }, [initialFilters]);


    /**
     * Maneja cambios en los campos <Select> (estado y estado_atencion).
     * @param {React.ChangeEvent<HTMLInputElement>} event - El evento de cambio.
     */
    const handleInputChange = (event) => {
        const { name, value } = event.target;
        const newFilters = { ...filters, [name]: value };
        setFilters(newFilters);
        onFilterChange(newFilters); // Notifica al padre inmediatamente
    };

    /**
     * Maneja el cambio de usuario desde el componente SelectorUsuarioNotificaciones.
     * @param {string|null} userId - El ID del usuario seleccionado, o null.
     */
    const handleUserChange = (userId) => {
        const newFilters = { ...filters, userId: userId };
        setFilters(newFilters);
        onFilterChange(newFilters);
    };

    /**
     * Maneja el cambio de fecha desde los DatePicker.
     * @param {'startDate' | 'endDate'} field - El campo de fecha a actualizar.
     * @param {dayjs.Dayjs | null} date - El nuevo valor de fecha (de dayjs).
     */
    const handleDateChange = (field, date) => {
        const newDate = date ? date.toDate() : null; // DatePicker -> Dayjs -> Date | null
        let newFilters = { ...filters, [field]: newDate };

        // Validaciones básicas de rango para evitar cruces
        if (field === 'startDate' && newFilters.endDate && newDate && newFilters.endDate < newDate) {
            newFilters = {...newFilters, endDate: newDate}; // Ajusta fecha fin si es necesario
        }
        if (field === 'endDate' && newFilters.startDate && newDate && newFilters.startDate > newDate) {
             newFilters = {...newFilters, startDate: newDate}; // Ajusta fecha inicio si es necesario
        }

        setFilters(newFilters);
        onFilterChange(newFilters);
    };

     /**
      * Establece un rango de fechas predefinido (Hoy, Ayer, etc.) usando date-fns.
      * @param {'today'|'yesterday'|'last7'|'last30'|'month'} preset - El preajuste a aplicar.
      */
    const setDatePreset = (preset) => {
        let start = null, end = null;
        const now = new Date();
        switch (preset) {
            case 'today': start = startOfDay(now); end = endOfDay(now); break;
            case 'yesterday': start = startOfDay(subDays(now, 1)); end = endOfDay(subDays(now, 1)); break;
            case 'last7': start = startOfWeek(subDays(now, 6)); end = endOfWeek(now); break; // Ajustado para últimos 7 días
            case 'last30': start = startOfDay(subDays(now, 29)); end = endOfDay(now); break;
            case 'month': start = startOfMonth(now); end = endOfMonth(now); break;
        }
        const newFilters = { ...filters, startDate: start, endDate: end };
        setFilters(newFilters);
        onFilterChange(newFilters);
    };

    /**
     * Limpia todos los filtros a su estado por defecto y notifica al padre.
     */
    const handleClear = () => {
        setFilters(defaultFilters);
        onFilterChange(defaultFilters);
    };

    return (
        <Paper variant="outlined" sx={{ p: 2, mb: 3 }}>
            <Stack spacing={2}>
                {/* Fila 1: Selector de Usuario, Presets de Fecha, Botón Limpiar */}
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
                     {/* Botón Limpiar */}
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

                {/* Fila 2: DatePickers, Selectores de Estado */}
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