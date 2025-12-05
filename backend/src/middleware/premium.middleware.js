const db = require('../config/db');

const premiumMiddleware = async (req, res, next) => {
  // 1. Validación previa de autenticación
  if (!req.user) {
    return res.status(401).json({ message: 'No autenticado.' });
  }

  const { userId, rol, planId } = req.user;

  // 2. Acceso directo para Admins y Reporteros (Bypass de DB)
  if (rol === 'admin' || rol === 'reportero') {
    next();
    return; // <--- IMPORTANTE: Detener aquí
  }

  // 3. Acceso directo si el token ya dice que tiene plan (Optimización)
  if (planId) {
     next();
     return; // <--- IMPORTANTE
  }

  try {
    // 4. Verificación estricta en Base de Datos (para casos borde)
    const userSub = await db.query(
      'SELECT id_plan_suscripcion, fecha_fin_suscripcion FROM usuarios WHERE id = $1',
      [userId]
    );

    if (userSub.rows.length === 0) {
      return res.status(403).json({ message: 'Usuario no encontrado.' });
    }

    const { id_plan_suscripcion, fecha_fin_suscripcion } = userSub.rows[0];
    const isActive = id_plan_suscripcion !== null && fecha_fin_suscripcion && new Date(fecha_fin_suscripcion) > new Date();

    if (isActive) {
      req.user.planId = id_plan_suscripcion; // Actualizamos req para el futuro
      next();
      return; // <--- IMPORTANTE: Detener aquí
    } else {
      // Limpieza de datos sucios si expiró
      if (id_plan_suscripcion !== null) {
        await db.query('UPDATE usuarios SET id_plan_suscripcion = NULL, fecha_fin_suscripcion = NULL WHERE id = $1', [userId]);
      }
      return res.status(403).json({ message: 'Requiere suscripción Premium o acceso de Prensa.' });
    }

  } catch (error) {
    console.error("Error en premiumMiddleware:", error);
    if (!res.headersSent) {
      return res.status(500).json({ message: 'Error al verificar permisos.' });
    }
  }
};

module.exports = premiumMiddleware;