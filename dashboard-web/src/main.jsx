// src/main.jsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './index.css'; // Tus estilos globales

// --- CONFIGURACIÓN DE DATE PICKER (IMPORTACIONES CORREGIDAS) ---
import { LocalizationProvider } from '@mui/x-date-pickers'; // <-- IMPORTACIÓN CORRECTA
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs'; // <-- La importación del adapter sigue igual
import dayjs from 'dayjs';
import 'dayjs/locale/es'; // Importar locale español para dayjs

// Establecer locale globalmente (opcional pero recomendado para consistencia)
dayjs.locale('es');
// --- FIN DE CONFIGURACIÓN DE DATE PICKER ---

/**
 * Punto de entrada principal de la aplicación React.
 * 
 * Este archivo configura el renderizado de la app en el DOM, importa estilos globales,
 * y envuelve la app con el proveedor de localización para componentes de selección de fechas
 * de Material-UI (usando Day.js con locale español).
 * 
 * Funcionalidades principales:
 * - Renderiza el componente raíz <App /> en el elemento DOM con id 'root'.
 * - Habilita React.StrictMode para detectar problemas en desarrollo.
 * - Configura LocalizationProvider para date pickers con locale español.
 * - Importa estilos globales desde 'index.css'.
 */
ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    {/* Envuelve App con LocalizationProvider para soporte de fechas localizadas */}
    <LocalizationProvider dateAdapter={AdapterDayjs} adapterLocale="es">
      <App />
    </LocalizationProvider>
  </React.StrictMode>,
);
