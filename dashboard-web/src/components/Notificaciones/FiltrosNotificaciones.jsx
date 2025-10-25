// src/components/Notificaciones/FiltrosNotificaciones.jsx
import React, { useState } from 'react';
import { Box, Button, Stack } from '@mui/material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
// import dayjs from 'dayjs'; // <-- REMOVED THIS LINE - Not needed here

// Import icons
import FilterAltIcon from '@mui/icons-material/FilterAlt';
import ClearIcon from '@mui/icons-material/Clear';

function FiltrosNotificaciones({ onFiltersChange, disabled }) {
  const [startDate, setStartDate] = useState(null); // Use null for initial empty state
  const [endDate, setEndDate] = useState(null);

  const handleApply = () => {
    // Format dates to YYYY-MM-DD string or pass null
    // The date objects (startDate, endDate) are already Dayjs objects
    // provided by the DatePicker component due to the setup in main.jsx
    const formattedStartDate = startDate ? startDate.format('YYYY-MM-DD') : null;
    const formattedEndDate = endDate ? endDate.format('YYYY-MM-DD') : null;
    onFiltersChange({ startDate: formattedStartDate, endDate: formattedEndDate });
  };

  const handleClear = () => {
    setStartDate(null);
    setEndDate(null);
    onFiltersChange({ startDate: null, endDate: null }); // Notify parent that filters are cleared
  };

  return (
    <Stack direction={{ xs: 'column', sm: 'row' }} spacing={2} alignItems="center">
      <DatePicker
        label="Fecha Desde"
        value={startDate}
        onChange={(newValue) => setStartDate(newValue)}
        slotProps={{ textField: { size: 'small' } }}
        format="DD/MM/YYYY" // Display format
        maxDate={endDate || undefined} // Prevent start date being after end date
        disabled={disabled}
      />
      <DatePicker
        label="Fecha Hasta"
        value={endDate}
        onChange={(newValue) => setEndDate(newValue)}
        slotProps={{ textField: { size: 'small' } }}
        format="DD/MM/YYYY" // Display format
        minDate={startDate || undefined} // Prevent end date being before start date
        disabled={disabled}
      />
      <Box sx={{ display: 'flex', gap: 1 }}>
        <Button
          variant="contained"
          onClick={handleApply}
          startIcon={<FilterAltIcon />}
          disabled={disabled || (!startDate && !endDate)} // Disable if no dates selected
        >
          Aplicar Fechas
        </Button>
        <Button
          variant="outlined"
          onClick={handleClear}
          startIcon={<ClearIcon />}
          disabled={disabled || (!startDate && !endDate)} // Disable if no dates selected
        >
          Limpiar
        </Button>
      </Box>
    </Stack>
  );
}

export default FiltrosNotificaciones;