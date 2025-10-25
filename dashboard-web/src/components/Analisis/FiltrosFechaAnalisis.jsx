// src/components/Analisis/FiltrosFechaAnalisis.jsx
import React from 'react';
import { Box, Button, ButtonGroup, Stack } from '@mui/material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { startOfDay, endOfDay, startOfWeek, endOfWeek, startOfMonth, endOfMonth } from 'date-fns';
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import AssessmentIcon from '@mui/icons-material/Assessment';
import dayjs from 'dayjs';

// --- MODIFICADO: Añadida la prop 'onOpenExcelModal' ---
function FiltrosFechaAnalisis({ 
  activeFilterName, 
  onFilterChange, 
  onOpenPdfModal, 
  onOpenExcelModal, // <-- NUEVO
  loading 
}) {

  const setDatePreset = (preset) => {
    let start, end, name;
    const now = new Date();
    
    switch (preset) {
      case 'today':
        start = startOfDay(now); end = endOfDay(now); name = 'Hoy';
        break;
      case 'week':
        start = startOfWeek(now, { weekStartsOn: 1 }); end = endOfWeek(now, { weekStartsOn: 1 }); name = 'Esta Semana';
        break;
      case 'month':
        start = startOfMonth(now); end = endOfMonth(now); name = 'Este Mes';
        break;
      case 'all':
      default:
        start = null; end = null; name = 'Todos los registros';
        break;
    }
    onFilterChange({ startDate: start, endDate: end, filterName: name });
  };

  const handleMonthChange = (date) => {
      if (date) {
         const selectedDate = date.toDate();
         onFilterChange({
             startDate: startOfMonth(selectedDate),
             endDate: endOfMonth(selectedDate),
             filterName: date.format('MMM YYYY')
         });
      } else {
         onFilterChange({ startDate: null, endDate: null, filterName: 'Todos los registros' });
      }
  };


  return (
    <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3, flexWrap: 'wrap', gap: 2 }}>
        {/* Contenedor Izquierdo (sin cambios) */}
        <Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap" gap={1}>
            <ButtonGroup variant="outlined" size="small" disabled={loading}>
                 <Button onClick={() => setDatePreset('all')} variant={activeFilterName === 'Todos los registros' ? 'contained' : 'outlined'}>Todos</Button>
                 <Button onClick={() => setDatePreset('today')} variant={activeFilterName === 'Hoy' ? 'contained' : 'outlined'}>Hoy</Button>
                 <Button onClick={() => setDatePreset('week')} variant={activeFilterName === 'Esta Semana' ? 'contained' : 'outlined'}>Semana</Button>
                 <Button onClick={() => setDatePreset('month')} variant={activeFilterName === 'Este Mes' ? 'contained' : 'outlined'}>Este Mes</Button>
            </ButtonGroup>
             <DatePicker
                 views={['month', 'year']}
                 label="Seleccionar Mes"
                 value={activeFilterName.includes(' ') && !['Hoy', 'Esta Semana', 'Este Mes', 'Todos los registros'].includes(activeFilterName) ? dayjs(activeFilterName, 'MMM YYYY') : null}
                 onChange={handleMonthChange}
                 slotProps={{ textField: { size: 'small' } }}
                 format="MMM YYYY"
                 disabled={loading}
             />
        </Stack>

         {/* Contenedor Derecho */}
         <Stack direction="row" spacing={1} sx={{ml: {xs: 0, sm:'auto'}}}>
             <Button
                 variant="contained"
                 color="secondary"
                 // --- MODIFICADO: Llama al nuevo handler ---
                 onClick={onOpenExcelModal}
                 startIcon={<AssessmentIcon />}
                 disabled={loading}
             >
                Descargar Excel
             </Button>
             <Button
                 variant="contained"
                 onClick={onOpenPdfModal}
                 startIcon={<FileDownloadIcon />}
                 disabled={loading}
             >
                Descargar PDF
             </Button>
         </Stack>
    </Box>
  );
}

export default FiltrosFechaAnalisis;