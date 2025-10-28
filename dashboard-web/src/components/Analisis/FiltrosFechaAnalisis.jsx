/**
 * @file FiltrosFechaAnalisis.jsx
 * @description Componente que permite filtrar registros por rango de fechas, con opciones predefinidas
 * (hoy, semana, mes o todos), así como la selección manual de mes y año. También incluye botones
 * para descargar reportes en formato PDF o Excel.
 * @version 1.1.0
 * @date 2025-10-25
 * @author Juan
 */

import React from 'react';
import { Box, Button, ButtonGroup, Stack } from '@mui/material';
import { DatePicker } from '@mui/x-date-pickers/DatePicker';
import { startOfDay, endOfDay, startOfWeek, endOfWeek, startOfMonth, endOfMonth } from 'date-fns';
import FileDownloadIcon from '@mui/icons-material/FileDownload';
import AssessmentIcon from '@mui/icons-material/Assessment';
import dayjs from 'dayjs';

/**
 * Componente de filtros de fecha para análisis de datos.
 *
 * Permite aplicar filtros rápidos por día, semana, mes o todos los registros,
 * y seleccionar manualmente un mes específico. Además, incluye botones para
 * abrir modales de descarga en PDF o Excel.
 *
 * @component
 * @example
 * <FiltrosFechaAnalisis
 *   activeFilterName="Hoy"
 *   onFilterChange={(filtros) => console.log(filtros)}
 *   onOpenPdfModal={() => console.log("Abrir PDF")}
 *   onOpenExcelModal={() => console.log("Abrir Excel")}
 *   loading={false}
 * />
 *
 * @param {Object} props - Propiedades del componente.
 * @param {string} props.activeFilterName - Nombre del filtro actualmente activo (ej. 'Hoy', 'Esta Semana').
 * @param {Function} props.onFilterChange - Callback ejecutado al cambiar el rango de fechas.
 * Recibe un objeto `{ startDate: Date|null, endDate: Date|null, filterName: string }`.
 * @param {Function} props.onOpenPdfModal - Función que abre el modal de descarga PDF.
 * @param {Function} props.onOpenExcelModal - Función que abre el modal de descarga Excel.
 * @param {boolean} props.loading - Indica si los botones deben estar deshabilitados mientras se carga información.
 *
 * @returns {JSX.Element} Interfaz de selección de fechas y botones de descarga.
 */
function FiltrosFechaAnalisis({ 
  activeFilterName, 
  onFilterChange, 
  onOpenPdfModal, 
  onOpenExcelModal, 
  loading 
}) {
  /**
   * Establece un filtro de fecha predefinido (Hoy, Semana, Mes, Todos).
   * 
   * @param {'today'|'week'|'month'|'all'} preset - Tipo de filtro de fecha seleccionado.
   */
  const setDatePreset = (preset) => {
    let start, end, name;
    const now = new Date();
    
    switch (preset) {
      case 'today':
        start = startOfDay(now);
        end = endOfDay(now);
        name = 'Hoy';
        break;
      case 'week':
        start = startOfWeek(now, { weekStartsOn: 1 });
        end = endOfWeek(now, { weekStartsOn: 1 });
        name = 'Esta Semana';
        break;
      case 'month':
        start = startOfMonth(now);
        end = endOfMonth(now);
        name = 'Este Mes';
        break;
      case 'all':
      default:
        start = null;
        end = null;
        name = 'Todos los registros';
        break;
    }
    onFilterChange({ startDate: start, endDate: end, filterName: name });
  };

  /**
   * Maneja el cambio manual de mes mediante el `DatePicker`.
   *
   * @param {dayjs.Dayjs|null} date - Fecha seleccionada (puede ser null).
   */
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
    <Box
      sx={{
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        mb: 3,
        flexWrap: 'wrap',
        gap: 2
      }}
    >
      {/* --- Contenedor izquierdo: botones de filtros de fecha --- */}
      <Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap" gap={1}>
        <ButtonGroup variant="outlined" size="small" disabled={loading}>
          <Button
            onClick={() => setDatePreset('all')}
            variant={activeFilterName === 'Todos los registros' ? 'contained' : 'outlined'}
          >
            Todos
          </Button>
          <Button
            onClick={() => setDatePreset('today')}
            variant={activeFilterName === 'Hoy' ? 'contained' : 'outlined'}
          >
            Hoy
          </Button>
          <Button
            onClick={() => setDatePreset('week')}
            variant={activeFilterName === 'Esta Semana' ? 'contained' : 'outlined'}
          >
            Semana
          </Button>
          <Button
            onClick={() => setDatePreset('month')}
            variant={activeFilterName === 'Este Mes' ? 'contained' : 'outlined'}
          >
            Este Mes
          </Button>
        </ButtonGroup>

        {/* Selector de mes/año */}
        <DatePicker
          views={['month', 'year']}
          label="Seleccionar Mes"
          value={
            activeFilterName.includes(' ') &&
            !['Hoy', 'Esta Semana', 'Este Mes', 'Todos los registros'].includes(activeFilterName)
              ? dayjs(activeFilterName, 'MMM YYYY')
              : null
          }
          onChange={handleMonthChange}
          slotProps={{ textField: { size: 'small' } }}
          format="MMM YYYY"
          disabled={loading}
        />
      </Stack>

      {/* --- Contenedor derecho: botones de descarga --- */}
      <Stack direction="row" spacing={1} sx={{ ml: { xs: 0, sm: 'auto' } }}>
        <Button
          variant="contained"
          color="secondary"
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
