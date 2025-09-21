import React, { useState, useRef, useEffect } from 'react';
import { Button, Box } from '@mui/material';

function HoldToConfirmButton({ onConfirm, label, color = 'primary', duration = 2000 }) {
  const [isHolding, setIsHolding] = useState(false);
  const [progress, setProgress] = useState(0);
  const timerRef = useRef(null);
  const progressRef = useRef(null);

  const handleMouseDown = () => {
    setIsHolding(true); // This is now used for styling
    timerRef.current = setTimeout(() => {
      onConfirm();
      handleMouseUp();
    }, duration);
    progressRef.current = setInterval(() => {
      setProgress(p => p + 100 / (duration / 100));
    }, 100);
  };

  const handleMouseUp = () => {
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
      onMouseDown={handleMouseDown}
      onMouseUp={handleMouseUp}
      onMouseLeave={handleMouseUp}
      sx={{ 
        position: 'relative', 
        overflow: 'hidden',
        // --- THIS IS THE FIX: The button's style changes while holding ---
        transform: isHolding ? 'scale(0.98)' : 'scale(1)',
        opacity: isHolding ? 0.9 : 1,
        transition: 'transform 0.1s ease, opacity 0.1s ease',
      }}
    >
      <Box
        sx={{
          position: 'absolute',
          top: 0,
          left: 0,
          height: '100%',
          width: `${progress}%`,
          backgroundColor: 'rgba(255, 255, 255, 0.3)',
          transition: 'width 0.1s linear',
        }}
      />
      <span style={{ position: 'relative', zIndex: 1 }}>{label}</span>
    </Button>
  );
}

export default HoldToConfirmButton;