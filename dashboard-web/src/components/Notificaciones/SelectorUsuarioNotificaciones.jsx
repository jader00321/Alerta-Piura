// src/components/Notificaciones/SelectorUsuarioNotificaciones.jsx
import React, { useState, useEffect, useCallback } from 'react';
import { Autocomplete, TextField, CircularProgress, Box, Avatar, Typography } from '@mui/material';
import adminService from '../../services/adminService';
import { useDebounce } from '../../hooks/useDebounce';

/**
 * SelectorUsuarioNotificaciones - Componente de autocompletado para seleccionar usuarios en notificaciones
 * @param {Object} props - Propiedades del componente
 * @param {function} props.onUserSelected - Callback cuando se selecciona un usuario
 * @param {boolean} props.disabled - Estado deshabilitado del componente
 * @param {Object} props.value - Valor controlado desde el componente padre
 * @returns {JSX.Element}
 */
function SelectorUsuarioNotificaciones({ onUserSelected, disabled, value: controlledValue }) { // Added controlledValue
  const [open, setOpen] = useState(false);
  const [options, setOptions] = useState([]);
  const [loading, setLoading] = useState(false);
  const [inputValue, setInputValue] = useState('');
  const debouncedSearch = useDebounce(inputValue, 400);
  const [selectedValue, setSelectedValue] = useState(null);

   /**
    * Sincroniza el valor controlado desde el padre
    */
   useEffect(() => {
    if (controlledValue === null && selectedValue !== null) {
      setSelectedValue(null);
      setInputValue(''); // Clear input when parent clears selection
    }
    // Note: We don't fetch based on controlledValue here to avoid extra calls
  }, [controlledValue, selectedValue]);

  /**
   * Obtiene usuarios del servicio basado en término de búsqueda
   * @param {string} searchTerm - Término de búsqueda para filtrar usuarios
   */
  const fetchUsers = useCallback(async (searchTerm) => {
    setLoading(true);
    try {
      const users = await adminService.getAllUsers({
        search: searchTerm,
        includeSuspended: true,
        sortBy: 'name'
      });
      setOptions(users);
    } catch (error) {
      console.error("Error fetching users for autocomplete:", error);
      setOptions([]);
    } finally {
      setLoading(false);
    }
  }, []);

  /**
   * Efecto para buscar usuarios cuando cambia el término de búsqueda
   */
  useEffect(() => {
    //let active = true; 

    if (!open) {
      setOptions([]);
      return undefined;
    }

    // Fetch immediately if input is empty OR after debounce if typing
    if (inputValue === '' || debouncedSearch === inputValue) {
       (async () => {
         await fetchUsers(inputValue);
       })();
    }

  }, [inputValue, debouncedSearch, open, fetchUsers]);


  return (
    <Autocomplete
      id="selector-usuario-notificaciones"
      open={open}
      onOpen={() => setOpen(true)}
      onClose={() => setOpen(false)}
      value={selectedValue} // Controlled by internal state
      isOptionEqualToValue={(option, value) => option.id === value.id}
      getOptionLabel={(option) => `${option.alias || option.nombre || 'Usuario Desconocido'} (${option.email || 'Sin Email'})`} // Show email too
      options={options}
      loading={loading}
      inputValue={inputValue} // Control input value separately
      onInputChange={(event, newInputValue, reason) => {
         setInputValue(newInputValue);
         // If input is cleared by user, also clear selection internally and notify parent
         if (reason === 'clear' || (reason === 'input' && newInputValue === '')) {
             setSelectedValue(null);
             onUserSelected(null);
         }
      }}
      onChange={(event, newValue) => {
        setOptions(newValue ? [newValue, ...options] : options); // Keep selected option available
        setSelectedValue(newValue); // Update internal state
        onUserSelected(newValue ? newValue.id : null); // Notify parent
      }}
      disabled={disabled}
      renderInput={(params) => (
        <TextField
          {...params}
          label="Buscar usuario"
          variant="outlined"
          size="small"
          InputProps={{
            ...params.InputProps,
            endAdornment: (
              <>
                {loading ? <CircularProgress color="inherit" size={20} /> : null}
                {params.InputProps.endAdornment}
              </>
            ),
          }}
        />
      )}
      renderOption={(props, option) => (
        <Box component="li" sx={{ '& > img': { mr: 2, flexShrink: 0 } }} {...props}>
              <Avatar sx={{ mr: 1.5, width: 32, height: 32, bgcolor: option.status === 'activo' ? 'success.light' : 'error.light' }}>
                  {option.alias ? option.alias[0].toUpperCase() : (option.nombre ? option.nombre[0].toUpperCase() : '?')}
              </Avatar>
              <Box>
                <Typography variant="body1">{option.alias || option.nombre}</Typography>
                <Typography variant="caption" color="text.secondary">{option.email} - {option.rol} ({option.status})</Typography>
            </Box>
        </Box>
      )}
      noOptionsText={inputValue ? "No se encontraron usuarios" : "Escribe para buscar..."}
      loadingText="Cargando..."
    />
  );
}

export default SelectorUsuarioNotificaciones;