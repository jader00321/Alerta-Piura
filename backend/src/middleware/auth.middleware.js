const jwt = require('jsonwebtoken');
require('dotenv').config();

const authMiddleware = (req, res, next) => {
  const authHeader = req.header('Authorization');

  if (!authHeader) {
    return res.status(401).json({ message: 'Acceso denegado. No se proporcionó un token.' });
  }

  const token = authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ message: 'Formato de token inválido.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded.user;
    
    next(); // Pasa al siguiente controlador
    return; // <--- IMPORTANTE: Detiene la ejecución de este middleware aquí.

  } catch (error) {
    return res.status(401).json({ message: 'Token no es válido o ha expirado.' });
  }
};

module.exports = authMiddleware;