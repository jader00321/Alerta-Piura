// src/main.jsx
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.jsx';
import './index.css'; // Your global styles

// --- DATE PICKER SETUP (CORRECTED IMPORTS) ---
import { LocalizationProvider } from '@mui/x-date-pickers'; // <-- CORRECT IMPORT PATH
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs'; // <-- Adapter import remains the same
import dayjs from 'dayjs';
import 'dayjs/locale/es'; // Import Spanish locale for dayjs

// Set locale globally (optional but recommended for consistency)
dayjs.locale('es');
// --- END DATE PICKER SETUP ---

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    {/* Wrap App with LocalizationProvider */}
    <LocalizationProvider dateAdapter={AdapterDayjs} adapterLocale="es">
      <App />
    </LocalizationProvider>
  </React.StrictMode>,
);