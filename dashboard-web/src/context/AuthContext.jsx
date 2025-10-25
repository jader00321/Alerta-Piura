// src/context/AuthContext.jsx
import React, { createContext, useState, useContext, useEffect } from 'react';
import { jwtDecode } from 'jwt-decode';
// Removed unused import: authService - Assuming logout handles storage/redirect, not socket disconnection directly here
import socketService from '../services/socketService'; // Ensure path is correct

/**
 * AuthContext - Context para manejar la autenticación en la aplicación
 * @type {React.Context}
 */
const AuthContext = createContext(null);

/**
 * useAuth - Hook personalizado para acceder al contexto de autenticación
 * @returns {Object} Objeto con estado y funciones de autenticación
 */
// eslint-disable-next-line react-refresh/only-export-components
export const useAuth = () => useContext(AuthContext);

/**
 * AuthProvider - Proveedor del contexto de autenticación
 * @param {Object} props - Propiedades del componente
 * @param {ReactNode} props.children - Componentes hijos
 * @returns {JSX.Element}
 */
export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  /**
   * Efecto para verificar el token al cargar la aplicación
   * Valida el token JWT almacenado y conecta el socket si es válido
   */
  useEffect(() => {
    const token = localStorage.getItem('admin_token');
    if (token) {
      try {
        const decoded = jwtDecode(token);
        // Check if token is expired
        if (decoded.exp * 1000 > Date.now()) {
          setUser(decoded.user);
          setIsAuthenticated(true);
          // Connect and authenticate socket
          socketService.connect(token); // Pass token for potential connection auth
          // You might not need this emit if auth is handled on connect
          // socketService.emit('authenticate', { token });
        } else {
          // Token expired
          console.log("AuthContext: Token expired on initial load.");
          handleLogout(); // Use the logout handler to clean up
        }
      } catch (error) {
        // --- FIX: Use the error variable ---
        console.error("AuthContext: Invalid token on initial load.", error);
        handleLogout(); // Clean up if token is invalid
      }
    }
    setLoading(false);
   
  }, []); // Empty dependency array means this runs only once on mount

  /**
   * Maneja el proceso de login del usuario
   * @param {string} token - Token JWT recibido del servidor
   */
  const handleLogin = (token) => {
    localStorage.setItem('admin_token', token);
    try {
        const decoded = jwtDecode(token);
        setUser(decoded.user);
        setIsAuthenticated(true);
        // Connect and authenticate socket
        socketService.connect(token);
        // socketService.emit('authenticate', { token }); // Potentially redundant if handled on connect
        console.log("AuthContext: User logged in.", decoded.user);
    } catch(error){
        console.error("AuthContext: Error decoding token on login.", error);
        handleLogout(); // Logout if token is bad on login attempt
    }
  };

  /**
   * Maneja el proceso de logout del usuario
   * Limpia el almacenamiento local, estado y desconecta el socket
   */
  const handleLogout = () => {
    console.log("AuthContext: Logging out.");
    localStorage.removeItem('admin_token');
    setUser(null);
    setIsAuthenticated(false);
    socketService.disconnect(); // Disconnect socket on logout
  };

  /**
   * Valor del contexto que se provee a los componentes hijos
   * @type {Object}
   */
  const value = {
    user,
    isAuthenticated,
    loading,
    login: handleLogin,
    logout: handleLogout,
  };

  // Render children only after initial loading check is complete
  return (
    <AuthContext.Provider value={value}>
      {!loading && children}
    </AuthContext.Provider>
  );
};