const authMiddleware = require('./auth.middleware');

const adminMiddleware = (req, res, next) => {
  // Primero, usamos el middleware de autenticación normal para verificar el token
  authMiddleware(req, res, () => {
    // Después, verificamos si el usuario tiene el rol de 'admin'
    if (req.user && req.user.rol === 'admin') {
      next(); // El usuario es un admin, continuar
    } else {
      res.status(403).json({ message: 'Acceso denegado. Se requieren privilegios de administrador.' });
    }
  });
};

module.exports = adminMiddleware;