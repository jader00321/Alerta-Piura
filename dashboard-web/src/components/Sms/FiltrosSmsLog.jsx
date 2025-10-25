// src/components/Sms/FiltrosSmsLog.jsx
import React from 'react'; // No necesitas useState/useEffect aquí si solo pasas props
import {
    Paper, Stack, TextField, Button, ButtonGroup, Box, Tooltip,
    IconButton, Grid, InputAdornment, Typography // Typography añadido
} from '@mui/material';
import { DatePicker, LocalizationProvider } from '@mui/x-date-pickers';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';
import dayjs from 'dayjs';
import 'dayjs/locale/es';
import { Search as SearchIcon, FilterListOff as FilterListOffIcon } from '@mui/icons-material';
import SelectorUsuarioNotificaciones from '../Notificaciones/SelectorUsuarioNotificaciones';
import { startOfDay, endOfDay, subDays, startOfMonth, endOfMonth } from 'date-fns';

function FiltrosSmsLog({ filters, onFilterChange, loading }) {

  // Handlers (sin cambios)
  const handleInputChange = (e) => {
    onFilterChange({ ...filters, search: e.target.value });
  };
  const handleUserChange = (userId) => {
    onFilterChange({ ...filters, userId: userId });
  };
  const handleDateChange = (field, date) => {
    const newDate = date ? date.toDate() : null;
    let newFilters = { ...filters, [field]: newDate };
    if (field === 'startDate' && newFilters.endDate && newDate && newFilters.endDate < newDate) {
        newFilters.endDate = newDate;
    }
    if (field === 'endDate' && newFilters.startDate && newDate && newFilters.startDate > newDate) {
        newFilters.startDate = newDate;
    }
    onFilterChange(newFilters);
  };
  const setDatePreset = (preset) => {
    let start = null, end = null;
    const now = new Date();
    switch (preset) {
        case 'today': start = startOfDay(now); end = endOfDay(now); break;
        case 'last7': start = startOfDay(subDays(now, 6)); end = endOfDay(now); break;
        case 'month': start = startOfMonth(now); end = endOfMonth(now); break;
    }
    onFilterChange({ ...filters, startDate: start, endDate: end });
  };
  const handleClear = () => {
    onFilterChange({ search: '', userId: null, startDate: null, endDate: null });
  };

  return (
    <Paper variant="outlined" sx={{ p: 2, mb: 3 }}>
      <Stack spacing={2}>
        <Grid container spacing={2} alignItems="center">
          {/* Fila 1: Búsqueda y Usuario */}
          <Grid item xs={12} md={6}>
            <TextField
              fullWidth size="small"
              label="Buscar en mensajes, contactos o alias..."
              value={filters.search}
              onChange={handleInputChange}
              disabled={loading}
              InputProps={{ startAdornment: <InputAdornment position="start"><SearchIcon /></InputAdornment> }}
            />
          </Grid>
          
          {/* --- CORRECCIÓN: Grid item ahora ocupa el espacio completo --- */}
          <Grid item xs={12} md={6}>
            <Box sx={{ width: '260px', maxWidth: { lg: '400px' } }}>
                <SelectorUsuarioNotificaciones
                onUserSelected={handleUserChange}
                value={filters.userId} // Controlar valor
                disabled={loading}
                />
            </Box>
          </Grid>

          {/* Fila 2: Filtros de Fecha */}
          <Grid item xs={12} display="flex" flexWrap="wrap" gap={2} alignItems="center">
            <LocalizationProvider dateAdapter={AdapterDayjs} adapterLocale="es">
                <Box sx={{ width: '160px', maxWidth: { lg: '400px' } }}>
              <DatePicker
                label="Fecha Desde"
                value={filters.startDate ? dayjs(filters.startDate) : null}
                onChange={(date) => handleDateChange('startDate', date)}
                slotProps={{ textField: { size: 'small' } }}
                format="DD/MM/YYYY"
                maxDate={filters.endDate ? dayjs(filters.endDate) : undefined}
                disabled={loading}
              />
              </Box>
              <Box sx={{ width: '160px', maxWidth: { lg: '400px' } }}>
              <DatePicker
                label="Fecha Hasta"
                value={filters.endDate ? dayjs(filters.endDate) : null}
                onChange={(date) => handleDateChange('endDate', date)}
                slotProps={{ textField: { size: 'small' } }}
                format="DD/MM/YYYY"
                minDate={filters.startDate ? dayjs(filters.startDate) : undefined}
                disabled={loading}
              />
              </Box>
            </LocalizationProvider>
            
            <ButtonGroup variant="outlined" size="small" disabled={loading} sx={{ flexShrink: 0 }}>
              {/* --- MEJORA: Aplicar variant 'contained' al filtro activo --- */}
              <Button
                variant={filters.startDate && dayjs(filters.startDate).isSame(startOfDay(new Date()), 'day') ? 'contained' : 'outlined'}
                onClick={() => setDatePreset('today')}
              >
                Hoy
              </Button>
              <Button
                variant={filters.startDate && dayjs(filters.startDate).isSame(startOfDay(subDays(new Date(), 6)), 'day') ? 'contained' : 'outlined'}
                onClick={() => setDatePreset('last7')}
              >
                Últimos 7 Días
              </Button>
              <Button
                variant={filters.startDate && dayjs(filters.startDate).isSame(startOfMonth(new Date()), 'day') ? 'contained' : 'outlined'}
                onClick={() => setDatePreset('month')}
              >
                Este Mes
              </Button>
            </ButtonGroup>
            
            {/* --- MEJORA: Botón Limpiar con Texto --- */}
            <Tooltip title="Limpiar filtros y mostrar todos los registros">
              <Button
                onClick={handleClear}
                size="small"
                disabled={loading}
                startIcon={<FilterListOffIcon />}
                sx={{ ml: 'auto', color: 'text.secondary' }} // Mover a la derecha
              >
                Limpiar / Ver Todos
              </Button>
            </Tooltip>
          </Grid>
        </Grid>
      </Stack>
    </Paper>
  );
}

export default FiltrosSmsLog;