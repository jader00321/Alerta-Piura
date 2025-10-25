// src/components/Comunes/BotonConfirmacionMantenida.jsx
import React, { useState, useRef, useEffect } from 'react';
import { Button, Box, useTheme } from '@mui/material';
import AccessTimeIcon from '@mui/icons-material/AccessTime';

function BotonConfirmacionMantenida({ 
  onConfirm, 
  label, 
  color = 'primary', 
  duration = 2000, 
  startIcon 
}) {
  const [isHolding, setIsHolding] = useState(false);
  const [progress, setProgress] = useState(0);
  const timerRef = useRef(null);
  const progressRef = useRef(null);
  const theme = useTheme();

  const handleHoldStart = (e) => {
    e.preventDefault(); 
    setIsHolding(true);
    
    timerRef.current = setTimeout(() => {
      onConfirm();
      handleHoldEnd();
    }, duration);

    const intervalTime = 50; // ms
    const increment = 100 / (duration / intervalTime);
    
    progressRef.current = setInterval(() => {
      setProgress(p => {
        if (p >= 100) {
          clearInterval(progressRef.current);
          return 100;
        }
        return p + increment;
      });
    }, intervalTime);
  };

  const handleHoldEnd = () => {
    setIsHolding(false);
    clearTimeout(timerRef.current);
    clearInterval(progressRef.current);
    setProgress(0);
  };

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
          opacity: 2,
          borderRadius: 'inherit',
          transition: 'width 0.05s linear',
          zIndex: 1,
        }}
      />
      <span style={{ position: 'relative', zIndex: 1 }}>
        {isHolding ? 'Confirmando...' : label}
      </span>
    </Button>
  );
}

export default BotonConfirmacionMantenida;