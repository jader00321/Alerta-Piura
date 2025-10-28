import { useState, useEffect } from 'react';

/**
 * Hook personalizado de React que retrasa la actualización de un valor (debounce).
 *
 * Este Hook es útil para optimizar el rendimiento, por ejemplo,
 * al evitar llamadas a una API en cada pulsación de tecla en un campo de búsqueda.
 * Solo actualizará el valor devuelto (`debouncedValue`) una vez que el
 * valor de entrada (`value`) no haya cambiado durante el tiempo especificado (`delay`).
 *
 * @template T - El tipo del valor que se está procesando (ej: string, number).
 * @param {T} value El valor que se quiere "retrasar" (debounce).
 * @param {number} delay El tiempo en milisegundos (ms) que se debe esperar
 * antes de actualizar el valor devuelto.
 * @returns {T} El valor (`value`) después de que ha transcurrido el `delay`
 * sin cambios.
 *
 * @example
 * // En tu componente:
 * const [searchTerm, setSearchTerm] = useState('');
 * // El debouncedSearchTerm solo se actualizará 500ms después de que el usuario deje de escribir
 * const debouncedSearchTerm = useDebounce(searchTerm, 500);
 *
 * // useEffect se dispara solo cuando debouncedSearchTerm cambia, no con cada tecla
 * useEffect(() => {
 * if (debouncedSearchTerm) {
 * api.search(debouncedSearchTerm);
 * }
 * }, [debouncedSearchTerm]);
 *
 * return <input onChange={(e) => setSearchTerm(e.target.value)} />;
 */
export function useDebounce(value, delay) {
  // Estado para el valor retrasado (debounced)
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(
    () => {
      // Configura un temporizador (timeout)
      const handler = setTimeout(() => {
        // Actualiza el valor retrasado solo después de que haya pasado el 'delay'
        setDebouncedValue(value);
      }, delay);

      // Función de limpieza: se ejecuta si 'value' o 'delay' cambian
      // antes de que se cumpla el temporizador.
      // Esto cancela el temporizador anterior y reinicia uno nuevo.
      return () => {
        clearTimeout(handler);
      };
    },
    [value, delay] // Solo se re-ejecuta si 'value' o 'delay' cambian
  );

  return debouncedValue;
}