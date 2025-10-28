/**

* Componente: FiltrosReportes
* ---
* Permite aplicar filtros, ordenar y cargar más reportes dentro del panel de administración o gestión.
* Incluye búsqueda, estado, categoría, distrito, tipo de plan, prioridad y opción de mostrar solo sugerencias.
*
* Usa componentes de Material UI para construir una interfaz limpia y responsiva.
  */

import React from 'react';
import {
  Paper, TextField, Select, MenuItem, FormControl, InputLabel,
  Button, ButtonGroup, Stack, InputAdornment, Tooltip, Switch,
  FormControlLabel, CircularProgress
} from '@mui/material';
import {
  Search as SearchIcon,
  FilterListOff as FilterListOffIcon,
  Add as AddIcon,
  Star as StarIcon
} from '@mui/icons-material';

/*                            CONSTANTES Y DATOS BASE                         */

/**

* Distritos predefinidos de Piura (pueden reemplazarse por datos desde una API).
  */
const DISTRITOS_PIURA = [
  'Piura', 'Castilla', 'Veintiséis de Octubre', 'Catacaos', 'Cura Mori',
  'El Tallán', 'La Arena', 'La Unión', 'Las Lomas', 'Tambo Grande',
];

/**

* Tipos de plan posibles.
  */
const PLAN_TYPES = [
  { value: 'premium', label: 'Premium' },
  { value: 'gratuito', label: 'Gratuito' },
];

/**

* Tipos de prioridad disponibles.
  */
const PRIORIDAD_TYPES = [
  { value: 'prioritario', label: 'Prioritario', icon: <StarIcon color="warning" /> },
  { value: 'no_prioritario', label: 'No Prioritario' },
];

/*                              COMPONENTE PRINCIPAL                          */

/**

* @param {Object} props - Propiedades del componente.
* @param {Object} props.filters - Objeto con los valores actuales de los filtros aplicados.
* @param {Array} props.categories - Lista de categorías disponibles.
* @param {boolean} props.showOnlySuggested - Indica si se muestran solo reportes sugeridos.
* @param {Function} props.onFilterChange - Callback para actualizar un filtro individual.
* @param {Function} props.onSortChange - Callback para cambiar el orden (más nuevos / antiguos).
* @param {Function} props.onToggleSuggested - Callback para activar o desactivar el modo "solo sugeridas".
* @param {Function} props.onClearFilters - Callback para limpiar todos los filtros.
* @param {Function} props.onLoadMore - Callback para cargar más resultados.
* @param {boolean} props.hasMore - Indica si existen más resultados por cargar.
* @param {boolean} props.loadingMore - Indica si se está cargando más contenido actualmente.
  */
function FiltrosReportes({
  filters,
  categories,
  showOnlySuggested,
  onFilterChange,
  onSortChange,
  onToggleSuggested,
  onClearFilters,
  onLoadMore,
  hasMore,
  loadingMore
}) {

  /*                          FUNCIONES MANEJADORAS DE EVENTOS                 */

  /**
   * Maneja cambios en los campos de entrada (textos y selects).
   * @param {Event} e - Evento del input o select.
    */
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    onFilterChange(name, value);
  };

  /**
  
  * Maneja el cambio de categoría.
  * Si se selecciona una categoría, desactiva el modo "solo sugeridas".
    */
  const handleCategoryChange = (e) => {
    const { name, value } = e.target;
    onFilterChange(name, value);
    if (value !== '') {
      onToggleSuggested(false);
    }
  };

  /**
  
  * Maneja el cambio del interruptor "Solo sugeridas".
  * Si se activa, limpia la categoría seleccionada.
    */
  const handleSuggestedToggle = (event) => {
    const isChecked = event.target.checked;
    onToggleSuggested(isChecked);
    if (isChecked) {
      onFilterChange('categoryId', '');
    }
  };

  /*                             RENDERIZADO DEL UI                             */

  return (
    <Paper
      sx={{
        p: 3,
        display: 'flex',
        flexDirection: 'column',
        gap: 2,
        mb: 3,
        boxShadow: 'none',
        width: '100%'
      }}
      variant="outlined"
    > <Stack spacing={2}>
        {/* -------------------- FILA 1: BÚSQUEDA Y ESTADO -------------------- */}
        <Stack direction={{ xs: 'column', md: 'row' }} spacing={2}>
          {/* Campo de búsqueda */}
          <TextField
            fullWidth
            size="small"
            InputProps={{
              startAdornment: (<InputAdornment position="start"> <SearchIcon /> </InputAdornment>
              ),
            }}
            label="Buscar por título, código o autor..."
            name="search"
            value={filters.search}
            onChange={handleInputChange}
          />

          ```
          {/* Filtro por estado */}
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

        {/* -------------------- FILA 2: CATEGORÍA, TOGGLE, ORDEN -------------------- */}
        <Stack direction={{ xs: 'column', md: 'row' }} spacing={2} alignItems="center">
          {/* Filtro por categoría */}
          <FormControl sx={{ minWidth: 200, flexGrow: 1 }} size="small" disabled={showOnlySuggested}>
            <InputLabel>Categoría</InputLabel>
            <Select
              name="categoryId"
              value={filters.categoryId}
              label="Categoría"
              onChange={handleCategoryChange}
            >
              <MenuItem value="">Todas</MenuItem>
              {categories.map(cat => (
                <MenuItem key={cat.id} value={cat.id}>{cat.nombre}</MenuItem>
              ))}
            </Select>
          </FormControl>

          {/* Toggle para mostrar solo sugeridas */}
          <Tooltip title="Mostrar solo reportes con categoría sugerida por el usuario">
            <FormControlLabel
              control={
                <Switch
                  checked={showOnlySuggested}
                  onChange={handleSuggestedToggle}
                  color="info"
                />
              }
              label="Solo Sugeridas"
              sx={{ flexShrink: 0, mr: 'auto' }}
            />
          </Tooltip>

          {/* Botones de orden */}
          <ButtonGroup size="small" sx={{ flexShrink: 0 }}>
            <Button
              variant={filters.sortBy === 'newest' ? 'contained' : 'outlined'}
              onClick={() => onSortChange('newest')}
            >
              Más Recientes
            </Button>
            <Button
              variant={filters.sortBy === 'oldest' ? 'contained' : 'outlined'}
              onClick={() => onSortChange('oldest')}
            >
              Más Antiguos
            </Button>
          </ButtonGroup>

          {/* Botón para limpiar filtros */}
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

        {/* -------------------- FILA 3: DISTRITO, PLAN, PRIORIDAD, CARGAR MÁS -------------------- */}
        <Stack direction={{ xs: 'column', md: 'row' }} spacing={2} alignItems="center">
          {/* Filtro por distrito */}
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

          {/* Filtro por tipo de plan */}
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

          {/* Filtro por prioridad */}
          <FormControl sx={{ minWidth: 200, flexGrow: 1 }} size="small">
            <InputLabel>Prioridad</InputLabel>
            <Select
              name="prioridad"
              value={filters.prioridad}
              label="Prioridad"
              onChange={handleInputChange}
              disabled={showOnlySuggested}
            >
              <MenuItem value="">Todos</MenuItem>
              {PRIORIDAD_TYPES.map(p => (
                <MenuItem key={p.value} value={p.value}>{p.label}</MenuItem>
              ))}
            </Select>
          </FormControl>

          {/* Botón para cargar más resultados */}
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
