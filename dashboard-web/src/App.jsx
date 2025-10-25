import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, CssBaseline, Box, CircularProgress } from '@mui/material'; // Imports necesarios
import theme from './theme';
import LoginPage from './pages/LoginPage';
import DashboardLayout from './pages/DashboardLayout';
import { AuthProvider, useAuth } from './context/AuthContext'; // Assuming context is set up

// --- RENAMED IMPORT ---
import PaginaHistorialNotificaciones from './pages/PaginaHistorialNotificaciones';
// --- Other page imports ---
import PaginaResumen from './pages/PaginaResumen';
import PaginaUsuarios from './pages/PaginaUsuarios';
import PaginaCategorias from './pages/PaginaCategorias';
import ModerationPage from './pages/ModerationPage';
import PaginaReportes from './pages/PaginaReportes';
import PaginaAlertasSOS from './pages/PaginaAlertasSOS';
import PaginaAnalisis from './pages/PaginaAnalisis';
import PaginaRegistroSms from './pages/PaginaRegistroSms';


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

// Componente auxiliar para consumir el contexto fácilmente
function AuthConsumer({ children }) {
  const auth = useAuth();
  // Puedes decidir aquí qué mostrar mientras carga, o dejar que ProtectedRoute lo haga
  // if (auth.loading) return <CircularProgress />; // Opcional
  return children(auth);
}

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <AuthProvider>
          {/* Usar AuthConsumer para acceder a loading e isAuthenticated */}
          <AuthConsumer>
            {({ loading, isAuthenticated, logout }) => (
              // No renderizar Routes hasta que loading sea false
              loading ? (
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

                  {/* Rutas Protegidas */}
                  <Route
                    path="/*" // Captura todas las demás rutas
                    element={
                      // Si NO está autenticado, redirige a login, sino muestra DashboardLayout
                      !isAuthenticated ? (
                          <Navigate to="/login" replace />
                       ) : (
                          <DashboardLayout onLogout={logout} />
                       )
                      // Alternativa usando ProtectedRoute (un poco redundante aquí si ya verificamos arriba)
                      // <ProtectedRoute>
                      //   <DashboardLayout onLogout={logout} />
                      // </ProtectedRoute>
                    }
                  />
                </Routes>
              )
            )}
          </AuthConsumer>
        </AuthProvider>
      </Router>
    </ThemeProvider>
  );
}

export default App;

/*
// src/App.jsx
import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { ThemeProvider, CssBaseline } from '@mui/material';
import theme from './theme';
import PaginaLogin from './pages/PaginaLogin';
import DashboardLayout from './pages/DashboardLayout';
import { AuthProvider, useAuth } from './context/AuthContext';
import CircularProgress from '@mui/material/CircularProgress';
import Box from '@mui/material/Box';

// Componente para manejar las rutas protegidas.
// Este componente se asegura de que el usuario esté autenticado antes de renderizar los children.
function ProtectedRoute({ children }) {
    const { isAuthenticated, loading } = useAuth(); // Obtener 'loading' del contexto

    if (loading) {
        // Muestra un spinner de carga mientras se verifica el estado de autenticación.
        return (
            <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
                <CircularProgress size={60} />
            </Box>
        );
    }

    if (!isAuthenticated) {
        // Si no está autenticado, redirige a la página de login.
        return <Navigate to="/login" replace />;
    }

    return children; // Si está autenticado, renderiza los componentes hijos.
}

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <AuthProvider>
          <Routes>

            <Route
                path="/login"
                element={
                    <AuthChecker> 
                        {({ isAuthenticated, loading }) => {
                            if (loading) {
                                return (
                                    <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100vh' }}>
                                        <CircularProgress size={60} />
                                    </Box>
                                );
                            }
                            // Si ya está autenticado, redirige a la raíz (dashboard)
                            return isAuthenticated ? <Navigate to="/" replace /> : <PaginaLogin />;
                        }}
                    </AuthChecker>
                }
            />
            <Route
              path="/*" // Captura cualquier ruta que no sea /login
              element={
                <ProtectedRoute>

                  <AuthChecker>
                    {({ logout }) => <DashboardLayout onLogout={logout} />}
                  </AuthChecker>
                </ProtectedRoute>
              }
            />
          </Routes>
        </AuthProvider>
      </Router>
    </ThemeProvider>
  );
}

// Componente auxiliar para verificar el estado de autenticación de forma consistente
function AuthChecker({ children }) {
    const auth = useAuth();
    return children(auth);
}

export default App;*/