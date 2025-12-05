import React from 'react';
import {
  Paper, TextField, Select, MenuItem, FormControl, InputLabel,
  Button, ButtonGroup, Stack, InputAdornment, Tooltip, Switch,
  FormControlLabel, Box, CircularProgress, Divider, Typography, useTheme, alpha
} from '@mui/material';
import { 
    Search as SearchIcon, 
    FilterListOff as FilterListOffIcon, 
    Add as AddIcon, 
    Star as StarIcon,
    Sort as SortIcon,
    FilterAlt as FilterIcon
} from '@mui/icons-material';

// --- Constantes ---
const DISTRITOS_PIURA = [
  'Piura', 'Castilla', 'Veintiséis de Octubre', 'Catacaos', 'Cura Mori',
  'El Tallán', 'La Arena', 'La Unión', 'Las Lomas', 'Tambo Grande',
];

const PLAN_TYPES = [
    { value: 'premium', label: 'Premium' },
    { value: 'gratuito', label: 'Gratuito' },
];

const PRIORIDAD_TYPES = [
    { value: 'prioritario', label: 'Prioritario', icon: <StarIcon sx={{ color: '#FFD700', mr: 1, fontSize: 18 }} /> },
    { value: 'no_prioritario', label: 'Estándar' },
];

function FiltrosReportes({
  filters, categories, showOnlySuggested,
  onFilterChange, onSortChange, onToggleSuggested, onClearFilters,
  onLoadMore, hasMore, loadingMore
}) {
  const theme = useTheme();

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    onFilterChange(name, value);
  };

  const handleCategoryChange = (e) => {
      const { name, value } = e.target;
      onFilterChange(name, value);
      if (value !== '') onToggleSuggested(false);
  };

   const handleSuggestedToggle = (event) => {
        const isChecked = event.target.checked;
        onToggleSuggested(isChecked);
        if (isChecked) onFilterChange('categoryId', '');
    };

  return (
    <Paper 
        elevation={0} 
        variant="outlined"
        sx={{ 
            p: 3, 
            display: 'flex', 
            flexDirection: 'column', 
            gap: 3, 
            mb: 4, 
            width: '100%',
            borderRadius: 3,
            bgcolor: 'background.paper',
            borderColor: 'divider'
        }}
    >
      
      {/* ----------------------------------------------------------- */}
      {/* SECCIÓN 1: BÚSQUEDA Y FILTROS PRINCIPALES */}
      {/* ----------------------------------------------------------- */}
      <Stack direction={{ xs: 'column', md: 'row' }} spacing={2} alignItems="center">
        {/* Barra de Búsqueda (Expandida) */}
        <TextField
            fullWidth
            placeholder="Buscar por título, código o autor..."
            name="search"
            value={filters.search}
            onChange={handleInputChange}
            sx={{ 
                flexGrow: 2,
                '& .MuiOutlinedInput-root': { borderRadius: 2, bgcolor: 'action.hover' } 
            }}
            InputProps={{
                startAdornment: (
                <InputAdornment position="start">
                    <SearchIcon color="action" />
                </InputAdornment>
                ),
            }}
        />

        <Divider orientation="vertical" flexItem sx={{ display: { xs: 'none', md: 'block' }, height: 40, my: 'auto' }} />

        {/* Botones de Ordenamiento */}
        <ButtonGroup variant="outlined" sx={{ flexShrink: 0 }}>
            <Button 
                onClick={() => onSortChange('newest')}
                variant={filters.sortBy === 'newest' ? 'contained' : 'outlined'}
                sx={{ borderRadius: 2 }}
            >
                Recientes
            </Button>
            <Button 
                onClick={() => onSortChange('oldest')}
                variant={filters.sortBy === 'oldest' ? 'contained' : 'outlined'}
                sx={{ borderRadius: 2 }}
            >
                Antiguos
            </Button>
        </ButtonGroup>
      </Stack>

      {/* ----------------------------------------------------------- */}
      {/* SECCIÓN 2: FILTROS AVANZADOS (GRID) */}
      {/* ----------------------------------------------------------- */}
      <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', sm: '1fr 1fr', md: 'repeat(4, 1fr)' }, gap: 2 }}>
        
        {/* Filtro: Estado */}
        <FormControl size="small" fullWidth>
            <InputLabel>Estado del Reporte</InputLabel>
            <Select
                name="status"
                value={filters.status}
                label="Estado del Reporte"
                onChange={handleInputChange}
                disabled={showOnlySuggested}
                sx={{ borderRadius: 2 }}
            >
                <MenuItem value="">Todos los Estados</MenuItem>
                <MenuItem value="pendiente_verificacion">⚠️ Pendiente</MenuItem>
                <MenuItem value="verificado">✅ Verificado</MenuItem>
                <MenuItem value="rechazado">❌ Rechazado</MenuItem>
                <MenuItem value="fusionado">🔗 Fusionado</MenuItem>
                <MenuItem value="oculto">👁️ Oculto</MenuItem>
            </Select>
        </FormControl>

        {/* Filtro: Categoría */}
        <FormControl size="small" fullWidth disabled={showOnlySuggested}>
            <InputLabel>Categoría</InputLabel>
            <Select
                name="categoryId"
                value={filters.categoryId}
                label="Categoría"
                onChange={handleCategoryChange}
                sx={{ borderRadius: 2 }}
            >
                <MenuItem value="">Todas las Categorías</MenuItem>
                {categories.map(cat => <MenuItem key={cat.id} value={cat.id}>{cat.nombre}</MenuItem>)}
            </Select>
        </FormControl>

        {/* Filtro: Distrito */}
        <FormControl size="small" fullWidth disabled={showOnlySuggested}>
            <InputLabel>Distrito</InputLabel>
            <Select
                name="distrito"
                value={filters.distrito}
                label="Distrito"
                onChange={handleInputChange}
                sx={{ borderRadius: 2 }}
            >
                <MenuItem value="">Todos los Distritos</MenuItem>
                {DISTRITOS_PIURA.map(distrito => (
                    <MenuItem key={distrito} value={distrito}>{distrito}</MenuItem>
                ))}
            </Select>
        </FormControl>

        {/* Filtro: Prioridad */}
        <FormControl size="small" fullWidth disabled={showOnlySuggested}>
            <InputLabel>Prioridad</InputLabel>
            <Select 
                name="prioridad" 
                value={filters.prioridad} 
                label="Prioridad" 
                onChange={handleInputChange}
                sx={{ borderRadius: 2 }}
            >
                <MenuItem value="">Cualquiera</MenuItem>
                {PRIORIDAD_TYPES.map(p => (
                    <MenuItem key={p.value} value={p.value} sx={{ display: 'flex', alignItems: 'center' }}>
                        {p.icon} {p.label}
                    </MenuItem>
                ))}
            </Select>
        </FormControl>
      </Box>

      {/* ----------------------------------------------------------- */}
      {/* SECCIÓN 3: ACCIONES Y EXTRAS */}
      {/* ----------------------------------------------------------- */}
      <Stack direction={{ xs: 'column', md: 'row' }} spacing={2} justifyContent="space-between" alignItems="center">
        
        {/* Toggle: Solo Sugeridos */}
        <Stack direction="row" spacing={2} alignItems="center">
            <Paper 
                variant="outlined" 
                sx={{ 
                    p: '4px 12px', 
                    borderRadius: 10, 
                    borderColor: showOnlySuggested ? 'primary.main' : 'divider',
                    bgcolor: showOnlySuggested ? alpha(theme.palette.primary.main, 0.05) : 'transparent'
                }}
            >
                <FormControlLabel
                    control={
                        <Switch
                            checked={showOnlySuggested}
                            onChange={handleSuggestedToggle}
                            color="primary"
                            size="small"
                        />
                    }
                    label={<Typography variant="body2" fontWeight={showOnlySuggested ? 'bold' : 'normal'}>Solo Categorías Sugeridas</Typography>}
                    sx={{ mr: 0 }}
                />
            </Paper>

            <Button
                variant="text"
                color="inherit"
                size="small"
                startIcon={<FilterListOffIcon />}
                onClick={onClearFilters}
                sx={{ color: 'text.secondary' }}
            >
                Limpiar Filtros
            </Button>
        </Stack>

        {/* Botón Principal: Cargar Más */}
        <Button
            variant="contained"
            color="primary"
            size="medium"
            startIcon={loadingMore ? <CircularProgress size={20} color="inherit" /> : <AddIcon />}
            onClick={onLoadMore}
            disabled={!hasMore || loadingMore}
            sx={{ 
                borderRadius: 2, 
                px: 4, 
                minWidth: { xs: '100%', md: '200px' },
                boxShadow: 2
            }}
        >
            {loadingMore ? 'Cargando...' : 'Cargar Más Resultados'}
        </Button>
      </Stack>

    </Paper>
  );
}

export default FiltrosReportes;