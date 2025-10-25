// src/hooks/useDebounce.js
import { useState, useEffect } from 'react';

/**
 * Un Hook personalizado para "retrasar" la actualización de un valor.
 * Es útil para no llamar a la API en cada tecla que presiona el usuario.
 */
export function useDebounce(value, delay) {
  // Estado para el valor retrasado (debounced)
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
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
  }, [value, delay]); // Solo se re-ejecuta si 'value' o 'delay' cambian

  return debouncedValue;
}