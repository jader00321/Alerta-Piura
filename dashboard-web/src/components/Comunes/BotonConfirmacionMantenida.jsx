// src/components/Comunes/BotonConfirmacionMantenida.jsx
import React, { useState, useRef, useEffect } from 'react';
import { Button, Box, useTheme } from '@mui/material';
import AccessTimeIcon from '@mui/icons-material/AccessTime';

/**
 * Un botón que requiere mantener presionado durante un tiempo definido para confirmar una acción.
 * Muestra una animación de progreso mientras se mantiene presionado.
 *
 * @component
 * @example
 * ```jsx
 * <BotonConfirmacionMantenida
 *   label="Eliminar"
 *   color="error"
 *   duration={2500}
 *   onConfirm={() => console.log('Acción confirmada')}
 *   startIcon={<DeleteIcon />}
 * />
 * ```
 *
 * @param {Object} props - Propiedades del componente.
 * @param {() => void} props.onConfirm - Función que se ejecuta al mantener presionado el botón durante el tiempo indicado.
 * @param {string} props.label - Texto que se muestra en el botón.
 * @param {'primary' | 'secondary' | 'error' | 'success' | 'warning' | 'info'} [props.color='primary'] - Color del botón según la paleta MUI.
 * @param {number} [props.duration=2000] - Tiempo (en milisegundos) que se debe mantener presionado para confirmar.
 * @param {React.ReactNode} [props.startIcon] - Icono opcional que se muestra antes del texto.
 * @returns {JSX.Element} El botón con animación de confirmación mantenida.
 */
function BotonConfirmacionMantenida({
  onConfirm,
  label,
  color = 'primary',
  duration = 2000,
  startIcon,
}) {
  const [isHolding, setIsHolding] = useState(false);
  const [progress, setProgress] = useState(0);
  const timerRef = useRef(null);
  const progressRef = useRef(null);
  const theme = useTheme();

  /**
   * Maneja el inicio de la pulsación mantenida del botón.
   * @param {React.MouseEvent | React.TouchEvent} e - Evento de mouse o touch.
   */
  const handleHoldStart = (e) => {
    e.preventDefault();
    setIsHolding(true);

    // Ejecuta la acción después de completar la duración requerida
    timerRef.current = setTimeout(() => {
      onConfirm();
      handleHoldEnd();
    }, duration);

    const intervalTime = 50;
    const increment = 100 / (duration / intervalTime);

    progressRef.current = setInterval(() => {
      setProgress((p) => {
        if (p >= 100) {
          clearInterval(progressRef.current);
          return 100;
        }
        return p + increment;
      });
    }, intervalTime);
  };

  /**
   * Detiene la pulsación mantenida y reinicia el progreso.
   */
  const handleHoldEnd = () => {
    setIsHolding(false);
    clearTimeout(timerRef.current);
    clearInterval(progressRef.current);
    setProgress(0);
  };

  // Limpieza en desmontaje del componente
  useEffect(() => {
    return () => {
      clearTimeout(timerRef.current);
      clearInterval(progressRef.current);
    };
  }, []);

  return (
    <Button
      variant="contained"
      color={color}
      onMouseDown={handleHoldStart}
      onMouseUp={handleHoldEnd}
      onMouseLeave={handleHoldEnd}
      onTouchStart={handleHoldStart}
      onTouchEnd={handleHoldEnd}
      onTouchCancel={handleHoldEnd}
      startIcon={isHolding ? <AccessTimeIcon /> : startIcon}
      sx={{
        position: 'relative',
        overflow: 'hidden',
        transform: isHolding ? 'scale(0.98)' : 'scale(1)',
        transition: 'transform 0.1s ease',
        userSelect: 'none',
      }}
    >
      <Box
        sx={{
          position: 'absolute',
          top: 0,
          left: 0,
          height: '100%',
          width: `${progress}%`,
          backgroundColor: theme.palette[color].dark,
          opacity: 0.2,
          borderRadius: 'inherit',
          transition: 'width 0.05s linear',
          zIndex: 1,
        }}
      />
      <span style={{ position: 'relative', zIndex: 2 }}>
        {isHolding ? 'Confirmando...' : label}
      </span>
    </Button>
  );
}

export default BotonConfirmacionMantenida;
