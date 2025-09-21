import { createTheme } from '@mui/material/styles';

// Define our dark theme
const darkTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#26a69a', // Teal
    },
    secondary: {
      main: '#ffab40', // Amber
    },
    // --- ADD THESE DEFINITIONS ---
    success: {
      main: '#66bb6a', // A pleasant green color
    },
    error: {
      main: '#f44336', // A standard red color
    },
    background: {
      default: '#121212',
      paper: '#1e1e1e',
    },
  },
  typography: {
    fontFamily: 'Roboto, Arial, sans-serif',
  },
});

export default darkTheme;