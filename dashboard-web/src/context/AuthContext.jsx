// src/context/AuthContext.jsx
import React, { createContext, useState, useContext, useEffect } from 'react';
import { jwtDecode } from 'jwt-decode';
// Removed unused import: authService - Assuming logout handles storage/redirect, not socket disconnection directly here
import socketService from '../services/socketService'; // Ensure path is correct

const AuthContext = createContext(null);

// Keep the exported hook - this is correct
// eslint-disable-next-line react-refresh/only-export-components
export const useAuth = () => useContext(AuthContext);

// Remove the internal, unused definition
// const useAuth = () => null; // <-- REMOVED THIS LINE

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  // Effect to check token on initial load
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

  const handleLogout = () => {
    console.log("AuthContext: Logging out.");
    localStorage.removeItem('admin_token');
    setUser(null);
    setIsAuthenticated(false);
    socketService.disconnect(); // Disconnect socket on logout
  };

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