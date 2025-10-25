const db = require('../config/db');

const premiumMiddleware = async (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ message: 'No autenticado.' });
  }

  // Los administradores siempre tienen acceso premium.
  if (req.user && (req.user.planId !== null || req.user.rol === 'admin' || req.user.rol === 'reportero')) { 
    next();
  }

  const { userId } = req.user;

  try {
    // Obtenemos la información de suscripción más reciente desde la base de datos.
    const userSub = await db.query(
      'SELECT id_plan_suscripcion, fecha_fin_suscripcion FROM usuarios WHERE id = $1',
      [userId]
    );

    if (userSub.rows.length === 0) {
      return res.status(403).json({ message: 'Acceso denegado.' });
    }

    const { id_plan_suscripcion, fecha_fin_suscripcion } = userSub.rows[0];

    // LÓGICA CORREGIDA: Verificamos si tiene un plan Y si la fecha de expiración es futura.
    if (id_plan_suscripcion !== null && fecha_fin_suscripcion && new Date(fecha_fin_suscripcion) > new Date()) {
      // Si el plan es válido, nos aseguramos de que el objeto 'user' de la petición esté actualizado y continuamos.
      req.user.planId = id_plan_suscripcion;
      next();
    } else {
      // Si el plan ha expirado, lo limpiamos de la base de datos para consistencia.
      if (id_plan_suscripcion !== null) {
        await db.query('UPDATE usuarios SET id_plan_suscripcion = NULL, fecha_fin_suscripcion = NULL WHERE id = $1', [userId]);
      }
      res.status(403).json({ message: 'Acceso denegado. Esta función requiere una suscripción Premium activa.' });
    }
  } catch (error) {
    res.status(500).json({ message: 'Error interno del servidor al verificar la suscripción.' });
  }
};

module.exports = premiumMiddleware;