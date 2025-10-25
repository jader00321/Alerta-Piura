import { createTheme } from '@mui/material/styles';

/**
 * Tema oscuro personalizado para la aplicación de administración
 * Define la paleta de colores, tipografía y componentes para el modo oscuro
 * @type {import('@mui/material/styles').Theme}
 */
const darkTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#26a69a', // Teal - Color principal para acciones y elementos destacados
    },
    secondary: {
      main: '#ffab40', // Amber - Color secundario para elementos complementarios
    },
    // --- ADD THESE DEFINITIONS ---
    success: {
      main: '#66bb6a', // Verde agradable para estados exitosos y confirmaciones
    },
    error: {
      main: '#f44336', // Rojo estándar para errores y estados críticos
    },
    background: {
      default: '#121212', // Color de fondo principal
      paper: '#1e1e1e', // Color de fondo para componentes tipo Paper
    },
  },
  typography: {
    fontFamily: 'Roboto, Arial, sans-serif', // Fuente principal de la aplicación
  },
  components: {
    /**
     * Personalizaciones globales de componentes Material-UI
     * Pueden añadirse aquí override específicos si son necesarios
     */
  },
});

export default darkTheme;