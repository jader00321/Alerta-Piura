import React from 'react';
import {
  Paper, TextField, Select, MenuItem, FormControl, InputLabel,
  Button, ButtonGroup, Stack, InputAdornment, Tooltip, Switch,
  FormControlLabel, Box, CircularProgress, Grid // Grid added for layout
} from '@mui/material';
import { Search as SearchIcon, FilterListOff as FilterListOffIcon, Add as AddIcon, Star as StarIcon} from '@mui/icons-material';

// --- Hardcoded Districts (Replace with API call if needed) ---
const DISTRITOS_PIURA = [
  'Piura', 'Castilla', 'Veintiséis de Octubre', 'Catacaos', 'Cura Mori',
  'El Tallán', 'La Arena', 'La Unión', 'Las Lomas', 'Tambo Grande',
];
// --- Plan Types ---
const PLAN_TYPES = [
    { value: 'premium', label: 'Premium' },
    { value: 'gratuito', label: 'Gratuito' },
    // Add specific plan names if needed
];
const PRIORIDAD_TYPES = [
    { value: 'prioritario', label: 'Prioritario', icon: <StarIcon color="warning"/> },
    { value: 'no_prioritario', label: 'No Prioritario' },
];

function FiltrosReportes({
  filters, categories, showOnlySuggested,
  onFilterChange, onSortChange, onToggleSuggested, onClearFilters,
  onLoadMore, hasMore, loadingMore
}) {

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    onFilterChange(name, value);
  };

  const handleCategoryChange = (e) => {
      const { name, value } = e.target;
      onFilterChange(name, value);
      if (value !== '') {
          onToggleSuggested(false);
      }
  };

   const handleSuggestedToggle = (event) => {
        const isChecked = event.target.checked;
        onToggleSuggested(isChecked);
        if (isChecked) {
            onFilterChange('categoryId', '');
        }
    };

  return (
    <Paper sx={{ p: 3, display: 'flex', flexDirection: 'column', gap: 2, mb: 3, boxShadow: 'none',width: '100%'}} variant="outlined">
      <Stack spacing={2}>
        {/* Row 1: Search and Status */}
        <Stack direction={{ xs: 'column', md: 'row' }} spacing={2}>
          <TextField
            fullWidth
            size="small"
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <SearchIcon />
                </InputAdornment>
              ),
            }}
            label="Buscar por título, código o autor..."
            name="search"
            value={filters.search}
            onChange={handleInputChange}
          />
          <FormControl sx={{ minWidth: 220 }} size="small">
            <InputLabel>Estado</InputLabel>
            <Select
              name="status"
              value={filters.status}
              label="Estado"
              onChange={handleInputChange}
              disabled={showOnlySuggested}
              sx={{ flexGrow: 1 }}
            >
              <MenuItem value="">Todos</MenuItem>
              <MenuItem value="pendiente_verificacion">Pendiente</MenuItem>
              <MenuItem value="verificado">Verificado</MenuItem>
              <MenuItem value="rechazado">Rechazado</MenuItem>
              <MenuItem value="fusionado">Fusionado</MenuItem>
              <MenuItem value="oculto">Oculto</MenuItem>
            </Select>
          </FormControl>
        </Stack>

        {/* Row 2: Category, Suggested Toggle, Sorting */}
        <Stack direction={{ xs: 'column', md: 'row' }} spacing={2} alignItems="center">
           <FormControl sx={{ minWidth: 200, flexGrow: 1 }} size="small" disabled={showOnlySuggested}>
                <InputLabel>Categoría</InputLabel>
                <Select
                    name="categoryId"
                    value={filters.categoryId}
                    label="Categoría"
                    onChange={handleCategoryChange} // Use specific handler
                >
                    <MenuItem value="">Todas</MenuItem>
                    {categories.map(cat => <MenuItem key={cat.id} value={cat.id}>{cat.nombre}</MenuItem>)}
                </Select>
            </FormControl>

           <Tooltip title="Mostrar solo reportes con categoría sugerida por el usuario">
               <FormControlLabel
                   control={
                       <Switch
                           checked={showOnlySuggested}
                           onChange={handleSuggestedToggle} // Use specific handler
                           color="info"
                       />
                   }
                   label="Solo Sugeridas"
                   sx={{ flexShrink: 0, mr: 'auto' }} // Push sorting buttons to the right
               />
            </Tooltip>


          <ButtonGroup size="small" sx={{ flexShrink: 0 }}>
            <Button variant={filters.sortBy === 'newest' ? 'contained' : 'outlined'} onClick={() => onSortChange('newest')}>Más Recientes</Button>
            <Button variant={filters.sortBy === 'oldest' ? 'contained' : 'outlined'} onClick={() => onSortChange('oldest')}>Más Antiguos</Button>
          </ButtonGroup>

           <Button
               variant="text"
               size="small"
               startIcon={<FilterListOffIcon />}
               onClick={onClearFilters}
               sx={{ flexShrink: 0, ml: 1 }}
           >
               Limpiar
           </Button>
        </Stack>
        <Stack direction={{ xs: 'column', md: 'row' }} spacing={2} alignItems="center">
              <FormControl sx={{ minWidth: 200, flexGrow: 1 }} size="small">
                <InputLabel>Distrito</InputLabel>
                <Select
                    name="distrito"
                    value={filters.distrito}
                    label="Distrito"
                    onChange={handleInputChange}
                    disabled={showOnlySuggested}
                >
                    <MenuItem value="">Todos</MenuItem>
                    {DISTRITOS_PIURA.map(distrito => (
                        <MenuItem key={distrito} value={distrito}>{distrito}</MenuItem>
                    ))}
                </Select>
              </FormControl>    
                <FormControl sx={{ minWidth: 200, flexGrow: 1 }} size="small">
                    <InputLabel>Tipo de Plan</InputLabel>
                    <Select
                        name="planType"
                        value={filters.planType}
                        label="Tipo de Plan"
                        onChange={handleInputChange}
                        disabled={showOnlySuggested}
                    >
                        <MenuItem value="">Todos</MenuItem>
                        {PLAN_TYPES.map(plan => (
                            <MenuItem key={plan.value} value={plan.value}>{plan.label}</MenuItem>
                        ))}
                    </Select>
                </FormControl>
                <FormControl sx={{ minWidth: 200, flexGrow: 1 }} size="small">
                <InputLabel>Prioridad</InputLabel>
                <Select name="prioridad" value={filters.prioridad} label="Prioridad" onChange={handleInputChange} disabled={showOnlySuggested}>
                    <MenuItem value="">Todos</MenuItem>
                    {PRIORIDAD_TYPES.map(p => (
                       <MenuItem key={p.value} value={p.value}>{p.label}</MenuItem>
                    ))}
                </Select>
            </FormControl>
                <Button
                    variant="contained"
                    color="primary"
                    size="small"
                    startIcon={loadingMore ? <CircularProgress size={16} color="inherit" /> : <AddIcon />}
                    onClick={onLoadMore}
                    disabled={!hasMore || loadingMore}
                    sx={{ flexShrink: 0 }}
                >
                    Cargar Más
                </Button>
            </Stack>
        </Stack>
    </Paper>
  );
}

export default FiltrosReportes;