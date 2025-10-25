// backend/src/controllers/admin/comunicacion.admin.controller.js
const db = require('../../config/db'); // <-- Adjusted path
const socketNotificationService = require('../../services/socketNotificationService'); // <-- Adjusted path

// backend/src/controllers/admin/comunicacion.admin.controller.js

const getSimulatedSmsLog = async (req, res) => {
  try {
    const { search, page = 1, userId, startDate, endDate } = req.query;
    const limit = 20;
    const offset = (page - 1) * limit;

    // --- MODIFICACIÓN: Añadir más campos del usuario y log ---
    let query = `
      SELECT 
        log.id, log.contacto_telefono, log.mensaje, log.fecha_envio,
        log.contacto_nombre, -- <-- CAMBIO: Añadir nombre del contacto
        u.alias as usuario_sos_alias,
        u.telefono as telefono_usuario_sos, -- <-- CAMBIO: Añadir teléfono del usuario
        u.email as usuario_sos_email,     -- <-- CAMBIO: Añadir email del usuario
        u.rol as usuario_sos_rol         -- <-- CAMBIO: Añadir rol del usuario
      FROM simulated_sms_log log
      LEFT JOIN usuarios u ON log.id_usuario_sos = u.id
    `;
    // --- FIN MODIFICACIÓN ---

    const whereClauses = [];
    const queryParams = [];
    let paramIndex = 1;

    // --- Lógica de Filtros (sin cambios) ---
    if (search) {
      whereClauses.push(`(log.mensaje ILIKE $${paramIndex} OR log.contacto_telefono ILIKE $${paramIndex} OR u.alias ILIKE $${paramIndex})`);
      queryParams.push(`%${search}%`);
      paramIndex++;
    }
    if (userId) {
        whereClauses.push(`log.id_usuario_sos = $${paramIndex}`);
        queryParams.push(userId);
        paramIndex++;
    }
    if (startDate) {
        whereClauses.push(`log.fecha_envio >= $${paramIndex}`);
        queryParams.push(startDate);
        paramIndex++;
    }
    if (endDate) {
        whereClauses.push(`log.fecha_envio < ($${paramIndex}::date + interval '1 day')`);
        queryParams.push(endDate);
        paramIndex++;
    }

    if (whereClauses.length > 0) {
      query += ' WHERE ' + whereClauses.join(' AND ');
    }

    // --- CORRECCIÓN: Lógica de paginación ---
    // Usar paramIndex para los placeholders
    const limitIndex = paramIndex++;
    const offsetIndex = paramIndex++;
    
    query += ` ORDER BY log.fecha_envio DESC LIMIT $${limitIndex} OFFSET $${offsetIndex}`;
    
    queryParams.push(limit, offset);
    // --- FIN CORRECCIÓN ---

    const result = await db.query(query, queryParams);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error en getSimulatedSmsLog:", error);
    res.status(500).json({ message: 'Error al obtener el registro de SMS.' });
  }
};
const getNotificationHistory = async (req, res) => {
  try {
    // Extraer nuevos parámetros de filtro
    const { search, page = 1, userId, startDate, endDate } = req.query;
    const limit = 20;
    const offset = (page - 1) * limit;

    let query = `
      SELECT
        n.id, n.id_usuario_receptor, n.titulo, n.cuerpo, n.leido, n.fecha_envio,
        u.alias as receptor, u.email as receptor_email
      FROM notificaciones n
      JOIN usuarios u ON n.id_usuario_receptor = u.id
    `;
    const whereClauses = [];
    const queryParams = [];
    let paramIndex = 1; // Start parameter index at 1

    // Añadir filtro de búsqueda (si existe)
    if (search) {
      whereClauses.push(`(n.titulo ILIKE $${paramIndex} OR n.cuerpo ILIKE $${paramIndex} OR u.alias ILIKE $${paramIndex})`);
      queryParams.push(`%${search}%`);
      paramIndex++;
    }

    // Añadir filtro de userId (si existe)
    if (userId) {
      whereClauses.push(`n.id_usuario_receptor = $${paramIndex}`);
      queryParams.push(userId);
      paramIndex++;
    }

    // Añadir filtro de startDate (si existe)
    if (startDate) {
      // Asegúrate que la fecha tenga el formato correcto o usa TO_TIMESTAMP si es necesario
      whereClauses.push(`n.fecha_envio >= $${paramIndex}`);
      queryParams.push(startDate); // Ej: '2025-10-20'
      paramIndex++;
    }

    // Añadir filtro de endDate (si existe)
    if (endDate) {
      // Usamos '<' y añadimos 1 día al endDate para incluir todo el día final
      // O ajusta según cómo manejes las fechas (ej. '2025-10-21' para incluir el 20)
      whereClauses.push(`n.fecha_envio < ($${paramIndex}::date + interval '1 day')`); // Asegura que incluya todo el día endDate
      queryParams.push(endDate); // Ej: '2025-10-25'
      paramIndex++;
    }

    // Unir cláusulas WHERE si existen
    if (whereClauses.length > 0) {
      query += ' WHERE ' + whereClauses.join(' AND ');
    }

    // Añadir ordenamiento, límite y offset
    query += ` ORDER BY n.fecha_envio DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`;
    queryParams.push(limit, offset);

    // Ejecutar la consulta
    const result = await db.query(query, queryParams);
    res.status(200).json(result.rows);

  } catch (error) {
    console.error("Error en getNotificationHistory:", error);
    res.status(500).json({ message: 'Error al obtener historial de notificaciones.' });
  }
};
const sendNotification = async (req, res) => {
  const { userIds, title, body } = req.body; // userIds es un array
  if (!userIds || !Array.isArray(userIds) || userIds.length === 0 || !title || !body) {
    return res.status(400).json({ message: 'Se requieren IDs de usuario (array), título y cuerpo.' });
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    const io = req.app.get('socketio'); // Obtener io de la app Express

    for (const userId of userIds) {
      // Insertar en la base de datos
      const payload = JSON.stringify({ type: 'admin_message' }); // Payload genérico
      const query = 'INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo, payload) VALUES ($1, $2, $3, $4) RETURNING id';
      const result = await client.query(query, [userId, title, body, payload]);
      
      // Enviar notificación por Socket.IO si está conectado
      if (io && result.rows.length > 0) {
           const notificationData = {
               id: result.rows[0].id, // Incluir ID para posible interacción futura
               title,
               body,
               payload, // Enviar payload por si el cliente lo necesita
               fecha_envio: new Date() // Añadir fecha
           };
          socketNotificationService.sendNotification(io, userId.toString(), notificationData);
      }
    }

    await client.query('COMMIT');
    res.status(200).json({ message: `${userIds.length} notificación(es) enviada(s) exitosamente.` });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error sending notification:", error);
    res.status(500).json({ message: 'Error interno al enviar la notificación.' });
  } finally {
    client.release();
  }
};
const deleteNotification = async (req, res) => {
    // ... (deleteNotification function code remains the same) ...
        const { id } = req.params;
    try {
        await db.query('DELETE FROM notificaciones WHERE id = $1', [id]);
        res.status(200).json({ message: 'Notificación eliminada.' });
    } catch (error) {
        console.error("Error en deleteNotification:", error);
        res.status(500).json({ message: 'Error al eliminar notificación.' });
    }
};

module.exports = {
  getSimulatedSmsLog,
  getNotificationHistory,
  sendNotification,
  deleteNotification,
};