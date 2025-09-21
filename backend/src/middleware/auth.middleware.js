const jwt = require('jsonwebtoken');
require('dotenv').config();

const authMiddleware = (req, res, next) => {
  // Obtenemos el token del header de la petición
  const authHeader = req.header('Authorization');

  // Verificamos si el header de autorización existe
  if (!authHeader) {
    return res.status(401).json({ message: 'Acceso denegado. No se proporcionó un token.' });
  }

  // El token usualmente viene como "Bearer <token>"
  const token = authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Formato de token inválido.' });
  }

  try {
    // Verificamos la validez del token usando nuestro secreto
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Si el token es válido, adjuntamos la información del usuario a la petición
    // para que los siguientes controladores puedan usarla.
    req.user = decoded.user;
    
    // Pasamos al siguiente middleware o controlador
    next();
  } catch (error) {
    res.status(401).json({ message: 'Token no es válido.' });
  }
};

module.exports = authMiddleware;