// backend/src/controllers/admin/sos.admin.controller.js
const db = require('../../config/db'); // Ajusta la ruta si es necesario

const getSosDashboardData = async (req, res) => {
  try {
    // Query para obtener todas las alertas, uniendo con usuarios para obtener sus detalles
    const alertsQuery = `
      SELECT
        sa.id, sa.id_usuario, sa.codigo_alerta, sa.estado, sa.fecha_inicio, sa.fecha_fin,
        sa.duracion_segundos, sa.revisada, sa.estado_atencion,
        sa.contacto_emergencia_telefono, sa.contacto_emergencia_mensaje, -- Campos añadidos
        u.alias, u.nombre, u.email, u.telefono, u.rol -- Campos del usuario
      FROM sos_alerts sa
      JOIN usuarios u ON sa.id_usuario = u.id
      ORDER BY sa.fecha_inicio DESC -- Ordenar por más reciente primero
    `;
    const alertsResult = await db.query(alertsQuery);
    let alerts = alertsResult.rows;

    // (Opcional, si quieres incluir historial solo para la última activa en esta llamada)
    // Encuentra la alerta activa más reciente (si existe)
     const latestActiveAlert = alerts.find(a => a.estado === 'activo');
     if (latestActiveAlert) {
       const historyQuery = `SELECT ST_Y(location) as lat, ST_X(location) as lon FROM sos_location_updates WHERE id_alerta_sos = $1 ORDER BY fecha_registro ASC`;
       const historyResult = await db.query(historyQuery, [latestActiveAlert.id]);
       latestActiveAlert.locationHistory = historyResult.rows; // Adjunta historial a esa alerta
     }

    // Devuelve la lista completa de alertas (el frontend pedirá historial específico si es necesario)
    res.status(200).json(alerts);

  } catch (error) {
    console.error("Error fetching SOS dashboard data:", error);
    res.status(500).json({ message: 'Error al obtener datos del panel SOS.' });
  }
};

module.exports = {
  getSosDashboardData,
};