import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, CssBaseline, Box, CircularProgress } from '@mui/material'; // Imports necesarios
import theme from './theme';
import LoginPage from './pages/LoginPage';
import DashboardLayout from './pages/DashboardLayout';
import { AuthProvider, useAuth } from './context/AuthContext'; 
import { ChatProvider } from './context/ChatContext';

// --- RENAMED IMPORT ---
import PaginaHistorialNotificaciones from './pages/PaginaHistorialNotificaciones';
// --- Other page imports ---
// (Estas páginas se infiere que son cargadas dentro de DashboardLayout)
import PaginaResumen from './pages/PaginaResumen';
import PaginaUsuarios from './pages/PaginaUsuarios';
import PaginaCategorias from './pages/PaginaCategorias';
import ModerationPage from './pages/ModerationPage';
import PaginaReportes from './pages/PaginaReportes';
import PaginaAlertasSOS from './pages/PaginaAlertasSOS';
import PaginaAnalisis from './pages/PaginaAnalisis';
import PaginaRegistroSms from './pages/PaginaRegistroSms';


/**
 * @file src/App.jsx
 * @description
 * Archivo principal de la aplicación que configura el enrutador (`react-router-dom`),
 * el proveedor de tema (`ThemeProvider` de MUI) y el proveedor de
 * autenticación (`AuthProvider`).
 * Define la lógica de enrutamiento de nivel superior, incluyendo las
 * rutas protegidas.
 */

/**
 * Componente "guardián" (HOC) para proteger rutas.
 *
 * Utiliza el `useAuth` hook para verificar el estado de autenticación.
 * 1. Muestra un spinner de carga (`CircularProgress`) mientras `loading` es true.
 * 2. Redirige a `/login` si `isAuthenticated` es false (después de cargar).
 * 3. Renderiza los `children` (la ruta protegida) si `isAuthenticated` es true.
 *
 * @component
 * @param {object} props - Propiedades del componente.
 * @param {React.ReactNode} props.children - Los componentes/rutas
 * hijas que se renderizarán si el usuario está autenticado.
 * @returns {JSX.Element} El componente hijo, un `<Navigate>` a /login,
 * o un spinner de carga.
 */
function ProtectedRoute({ children }) {
    const { isAuthenticated, loading } = useAuth();

    if (loading) {
        // Muestra spinner mientras se verifica el token
        return (
            <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
                <CircularProgress size={60} />
            </Box>
        );
    }

    if (!isAuthenticated) {
        // Redirige a login si no está autenticado DESPUÉS de verificar
        return <Navigate to="/login" replace />;
    }

    // Renderiza el contenido protegido si está autenticado
    return children;
}

/**
 * Componente auxiliar que consume `useAuth` y provee el contexto
 * a sus hijos mediante el patrón "children as a function" (render prop).
 *
 * @component
 * @param {object} props - Propiedades del componente.
 * @param {function(object): React.ReactNode} props.children - Una función
 * que recibe el objeto de contexto `auth` (con `loading`, `isAuthenticated`,
 * `logout`, etc.) y retorna un elemento de React.
 * @returns {React.ReactNode} El resultado de ejecutar la función `children`.
 */
function AuthConsumer({ children }) {
  const auth = useAuth();
  // Puedes decidir aquí qué mostrar mientras carga, o dejar que ProtectedRoute lo haga
  // if (auth.loading) return <CircularProgress />; // Opcional
  return children(auth);
}

/**
 * Componente raíz de la aplicación.
 *
 * Configura `ThemeProvider`, `CssBaseline`, `Router` y `AuthProvider`.
 * Utiliza `AuthConsumer` para obtener el estado de autenticación y
 * renderizar la lógica de rutas principal:
 *
 * 1. Muestra un spinner global mientras el `AuthContext` está `loading`.
 * 2. Si no está cargando, renderiza `Routes`:
 * - `/login`: Ruta pública. Si el usuario ya está autenticado,
 * redirige a `/` (dashboard).
 * - `/*`: Captura todas las demás rutas. Si el usuario no está
 * autenticado, redirige a `/login`. Si lo está, renderiza
 * `DashboardLayout`, que contiene todas las rutas protegidas
 * de la aplicación (Resumen, Usuarios, Reportes, etc.).
 *
 * @component
 * @returns {JSX.Element} La aplicación completa.
 */
function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <AuthProvider>
          <ChatProvider>
          {/* Usar AuthConsumer para acceder a loading e isAuthenticated */}
          <AuthConsumer>
            {({ loading, isAuthenticated, logout }) => (
              // No renderizar Routes hasta que loading sea false
              loading ? (
                // Spinner de carga global para la verificación inicial de auth
                <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
                  <CircularProgress size={60} />
                </Box>
              ) : (
                <Routes>
                  {/* Ruta Login */}
                  <Route
                    path="/login"
                    element={
                      // Si está autenticado, redirige al dashboard, sino muestra Login
                      isAuthenticated ? <Navigate to="/" replace /> : <LoginPage />
                    }
                  />

                  {/* Rutas Protegidas (Todas las demás) */}
                  <Route
                    path="/*" // Captura todas las demás rutas
                    element={
                      // Si NO está autenticado, redirige a login, sino muestra DashboardLayout
                      !isAuthenticated ? (
                          <Navigate to="/login" replace />
                        ) : (
                          // DashboardLayout es la entrada a todas las páginas protegidas
                          <DashboardLayout onLogout={logout} />
                        )
                      // Alternativa usando ProtectedRoute (definido arriba pero no usado aquí):
                      // <ProtectedRoute>
                      //   <DashboardLayout onLogout={logout} />
                      // </ProtectedRoute>
                    }
                  />
                </Routes>
              )
            )}
          </AuthConsumer>
          </ChatProvider>
        </AuthProvider>
      </Router>
    </ThemeProvider>
  );
}

export default App;