// backend/src/controllers/admin/reporte.admin.controller.js
const db = require('../../config/db'); // <-- Adjusted path
const servicioNotificacionesZonas = require('../../services/servicioNotificacionesZonas');
const socketNotificationService = require('../../services/socketNotificationService');

const getAllAdminReports = async (req, res) => {
  try {
    // --- NUEVO FILTRO 'prioridad' ---
    const { search, status, categoryId, sortBy, page = 1, suggestedOnly, distrito, planType, prioridad } = req.query;
    const limit = 10;
    const offset = (page - 1) * limit;

    // Base query joins Usuarios (u) and optionally Planes (p)
    let query = `
      SELECT r.id, r.titulo, r.foto_url, r.distrito, r.urgencia, r.tags, r.codigo_reporte,
             r.apoyos_pendientes, to_char(r.hora_incidente, 'HH24:MI') as hora_incidente,
             c.nombre as categoria, r.categoria_sugerida, r.es_anonimo,
             u.nombre as autor_nombre, u.alias as autor_alias, u.email as autor_email,
             l.nombre as lider_verificador_nombre, l.alias as lider_verificador_alias, l.email as lider_verificador_email,
             r.estado, r.fecha_creacion,
             to_char(r.fecha_creacion, 'DD Mon YYYY, HH24:MI') as fecha_creacion_formateada,
             r.descripcion, r.referencia_ubicacion, r.impacto, ST_AsGeoJSON(r.location) as location,
             CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario,
             CASE
               WHEN u.id_plan_suscripcion IS NOT NULL AND u.fecha_fin_suscripcion > NOW()
               THEN p.nombre_publico ELSE 'Plan Gratuito'
             END AS nombre_plan_autor,
             r.reportes_vinculados_count
      FROM reportes r
      LEFT JOIN usuarios u ON r.id_usuario = u.id
      LEFT JOIN planes_suscripcion p ON u.id_plan_suscripcion = p.id
      LEFT JOIN categorias c ON r.id_categoria = c.id
      LEFT JOIN usuarios l ON r.id_lider_verificador = l.id
      LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
    `;
    const whereClauses = [];
    const queryParams = [];
    let paramIndex = 1;

    // Search filter (unchanged)
    if (search) {
      whereClauses.push(`(r.titulo ILIKE $${paramIndex} OR r.codigo_reporte ILIKE $${paramIndex} OR u.alias ILIKE $${paramIndex} OR u.nombre ILIKE $${paramIndex})`); // Added codigo_reporte
      queryParams.push(`%${search}%`); paramIndex++;
    }
    // Status filter (unchanged)
    if (status) { whereClauses.push(`r.estado = $${paramIndex++}`); queryParams.push(status); }
    // Category filter (unchanged logic)
    if (categoryId && suggestedOnly !== 'true') { 
        whereClauses.push(`r.id_categoria = $${paramIndex++}`); 
        queryParams.push(categoryId); 
    }
    // Suggested Only filter (unchanged logic)
    if (suggestedOnly === 'true') { whereClauses.push(`r.categoria_sugerida IS NOT NULL AND r.categoria_sugerida != ''`); }

    // --- NEW: Distrito filter ---
    if (distrito) {
      whereClauses.push(`r.distrito = $${paramIndex++}`);
      queryParams.push(distrito);
    }

    // --- NEW: PlanType filter ---
    if (planType === 'premium') {
      // User has a plan AND subscription is active
      whereClauses.push(`(u.id_plan_suscripcion IS NOT NULL AND u.fecha_fin_suscripcion > NOW())`);
    } else if (planType === 'gratuito') {
      // User has NO plan OR subscription is expired
      whereClauses.push(`(u.id_plan_suscripcion IS NULL OR u.fecha_fin_suscripcion <= NOW())`);
    }
    if (prioridad === 'prioritario') {
      // Filtrar donde SÍ hay una coincidencia en reportes_prioritarios
      whereClauses.push(`rp.id_reporte IS NOT NULL`);
    } else if (prioridad === 'no_prioritario') {
      // Filtrar donde NO hay una coincidencia en reportes_prioritarios
      whereClauses.push(`rp.id_reporte IS NULL`);
    }
    // Apply WHERE clauses
    if (whereClauses.length > 0) query += ' WHERE ' + whereClauses.join(' AND ');

    // Sorting (use original timestamp)
    query += ` ORDER BY r.fecha_creacion ${sortBy === 'oldest' ? 'ASC' : 'DESC'}`;

    // Pagination
    query += ` LIMIT $${paramIndex++} OFFSET $${paramIndex++}`;
    queryParams.push(limit, offset);

    const result = await db.query(query, queryParams);
    const reportsWithParsedLocation = result.rows.map(row => ({
        ...row,
        location: row.location ? JSON.parse(row.location) : null
    }));
    res.status(200).json(reportsWithParsedLocation);
  } catch (error) {
    console.error("Error fetching admin reports:", error);
    res.status(500).json({ message: 'Error al obtener los reportes.' });
  }
};
const updateReportVisibility = async (req, res) => {
    // ... (updateReportVisibility function code remains the same) ...
      const { id } = req.params;
  const { currentState } = req.body;
  const newState = currentState === 'verificado' ? 'oculto' : 'verificado';
  try {
    await db.query("UPDATE reportes SET estado = $1, fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = $2 AND estado IN ('verificado', 'oculto')", [newState, id]);
    res.status(200).json({ message: `Reporte ahora está ${newState}` });
  } catch (error) {
    console.error("Error en updateReportVisibility:", error);
    res.status(500).json({ message: 'Error al cambiar la visibilidad del reporte.' });
  }
};
const adminDeleteReport = async (req, res) => {
    // ... (adminDeleteReport function code remains the same) ...
        const { id } = req.params;
    try {
        await db.query('DELETE FROM reportes WHERE id = $1', [id]);
        res.status(200).json({ message: 'Reporte eliminado permanentemente.' });
    } catch (error) {
        console.error("Error en adminDeleteReport:", error);
        res.status(500).json({ message: 'Error al eliminar el reporte.' });
    }
};
const adminAprobarReporte = async (req, res) => {
    // ... (adminAprobarReporte function code remains the same) ...
      const { id } = req.params;
  const adminId = req.user.userId;
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    const result = await client.query("UPDATE reportes SET estado = 'verificado', fecha_actualizacion = CURRENT_TIMESTAMP, id_lider_verificador = $1 WHERE id = $2 RETURNING *", [adminId, id]);
    if (result.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ message: 'Reporte no encontrado.' });
    }
    const reporteAprobado = result.rows[0];
    const io = req.app.get('socketio');
    const reporteCompletoResult = await client.query(`SELECT r.*, c.nombre as categoria, ST_AsGeoJSON(r.location) as location FROM reportes r JOIN categorias c ON r.id_categoria = c.id WHERE r.id = $1`, [reporteAprobado.id]);
    if (reporteCompletoResult.rows.length > 0) {
        const reporteCompleto = reporteCompletoResult.rows[0];
        reporteCompleto.location = JSON.parse(reporteCompleto.location);
        await servicioNotificacionesZonas.verificarReporteEnZonas(io, reporteCompleto);
    }
    await client.query('COMMIT');
    res.status(200).json({ message: 'Reporte aprobado por administrador.', report: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error in adminAprobarReporte:', error);
    res.status(500).json({ message: 'Error al aprobar el reporte.', error: error.message });
  } finally {
    client.release();
  }
};
const adminRechazarReporte = async (req, res) => {
    // ... (adminRechazarReporte function code remains the same) ...
      const { id } = req.params;
  try {
    const result = await db.query("UPDATE reportes SET estado = 'rechazado', fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *", [id]);
    if (result.rows.length === 0) return res.status(404).json({ message: 'Reporte no encontrado.' });
    res.status(200).json({ message: 'Reporte rechazado.', report: result.rows[0] });
  } catch (error) {
    console.error('Error in adminRechazarReporte:', error);
    res.status(500).json({ message: 'Error al rechazar el reporte.', error: error.message });
  }
};
const adminSetReportToPending = async (req, res) => {
    // ... (adminSetReportToPending function code remains the same) ...
      const { id } = req.params;
  try {
    const result = await db.query("UPDATE reportes SET estado = 'pendiente_verificacion', fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *", [id]);
    if (result.rows.length === 0) return res.status(404).json({ message: 'Reporte no encontrado.' });
    res.status(200).json({ message: 'Reporte establecido como pendiente.', report: result.rows[0] });
  } catch (error) {
    console.error('Error in adminSetReportToPending:', error);
    res.status(500).json({ message: 'Error al actualizar el reporte.', error: error.message });
  }
};
const getLatestPendingReports = async (req, res) => {
  try {
    // --- QUERY CONFIRMADA Y MEJORADA ---
    const query = `
      SELECT
        r.id, r.titulo, r.descripcion, r.es_anonimo, r.foto_url, r.estado,
        r.urgencia, r.distrito, r.referencia_ubicacion, r.tags, r.impacto, r.codigo_reporte,
        to_char(r.hora_incidente, 'HH24:MI') as hora_incidente,
        c.nombre as categoria,
        u.nombre as autor_nombre,
        u.alias as autor_alias,
        u.email as autor_email,
        u.telefono as autor_telefono,
        u.rol as autor_rol,
        to_char(r.fecha_creacion, 'DD Mon YYYY, HH24:MI') as fecha_creacion_formateada, -- Formato para mostrar
        ST_AsGeoJSON(r.location) as location,
        -- Prioridad (viene del LEFT JOIN con reportes_prioritarios)
        CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario,
        -- Plan del Autor (viene del LEFT JOIN con planes_suscripcion)
        CASE
          WHEN u.id_plan_suscripcion IS NOT NULL AND u.fecha_fin_suscripcion > NOW()
          THEN p.nombre_publico
          ELSE 'Plan Gratuito'
        END AS nombre_plan_autor
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      JOIN usuarios u ON r.id_usuario = u.id
      LEFT JOIN planes_suscripcion p ON u.id_plan_suscripcion = p.id -- Join para plan
      LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte    -- Join para prioridad
      WHERE r.estado = 'pendiente_verificacion'
      ORDER BY r.fecha_creacion DESC
      LIMIT 5
    `;
    const result = await db.query(query);

    const reports = result.rows.map(row => ({
      ...row,
      location: row.location ? JSON.parse(row.location) : null,
      // Aseguramos que fecha_creacion original también esté disponible si se necesita
      fecha_creacion: row.fecha_creacion,
    }));

    res.status(200).json(reports);
  } catch (error) {
    console.error("Error en getLatestPendingReports:", error); // Log de error específico
    res.status(500).json({ message: 'Error al obtener últimos reportes pendientes.' });
  }
};
const getReviewRequests = async (req, res) => {
    // ... (getReviewRequests function code remains the same) ...
      try {
    const query = `
      SELECT sr.id, sr.motivo, r.titulo, r.codigo_reporte, to_char(r.fecha_creacion, 'DD Mon YYYY') as fecha_reporte,
             u.alias as lider_alias, u.nombre as lider_nombre
      FROM solicitudes_revision sr JOIN reportes r ON sr.id_reporte = r.id JOIN usuarios u ON sr.id_lider = u.id
      WHERE sr.estado = 'pendiente' ORDER BY sr.fecha_solicitud ASC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error en getReviewRequests:", error);
    res.status(500).json({ message: 'Error al obtener solicitudes de revisión.' });
  }
};
const resolveReviewRequest = async (req, res) => {
  const { id } = req.params; // ID de la solicitud
  const { action, motivoRechazo } = req.body; 
  const client = await db.getClient();

  try {
    await client.query('BEGIN');

    const solicitudResult = await client.query(
        "SELECT id_reporte, id_lider FROM solicitudes_revision WHERE id = $1 AND estado = 'pendiente' FOR UPDATE",
        [id]
    );

    if (solicitudResult.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({ message: 'Solicitud no encontrada o ya procesada.' });
    }
    const { id_reporte, id_lider } = solicitudResult.rows[0];

    let nuevoEstadoSolicitud = '';
    let notificationTitle = '';
    let notificationBody = '';
    let payloadObj = {}; // Objeto para el payload

    if (action === 'aprobar') {
      nuevoEstadoSolicitud = 'aprobada';
      await client.query(
          "UPDATE reportes SET estado = 'pendiente_verificacion', fecha_actualizacion = NOW(), id_lider_verificador = NULL WHERE id = $1",
          [id_reporte]
      );
      notificationTitle = `Solicitud Aprobada`;
      notificationBody = `Tu solicitud de revisión para el reporte #${id_reporte} fue aprobada.`;
      
      // --- CAMBIO: Payload específico apuntando al reporte ---
      payloadObj = { type: 'report_detail', id: id_reporte }; 

    } else if (action === 'desestimar') {
      nuevoEstadoSolicitud = 'desestimada';
      notificationTitle = `Solicitud Desestimada`;
      notificationBody = `Tu solicitud de revisión para el reporte #${id_reporte} fue desestimada. ${motivoRechazo || ''}`.trim();
      
      // --- CAMBIO: Payload específico para que el líder vea el reporte rechazado ---
      payloadObj = { type: 'report_detail', id: id_reporte }; 
    } else {
       await client.query('ROLLBACK');
       return res.status(400).json({ message: 'Acción inválida.' });
    }

    await client.query(
        "UPDATE solicitudes_revision SET estado = $1 WHERE id = $2",
        [nuevoEstadoSolicitud, id]
    );

    await client.query('COMMIT');

    // Notificar al líder
    const io = req.app.get('socketio');
    const payloadJson = JSON.stringify(payloadObj);
    const categoria = 'Sistema'; // Categoría para el icono

    try {
        await db.query(
            'INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo, payload, categoria) VALUES ($1, $2, $3, $4, $5)', 
            [id_lider, notificationTitle, notificationBody, payloadJson, categoria]
        );
        socketNotificationService.sendNotification(io, id_lider, { 
            title: notificationTitle, 
            body: notificationBody, 
            payload: payloadJson,
            categoria: categoria 
        });
    } catch (notifyError) { console.error(`Error al notificar resolución:`, notifyError); }

    res.status(200).json({ message: `Solicitud marcada como ${nuevoEstadoSolicitud}.` });

  } catch (error) {
    if (client && client.active) await client.query('ROLLBACK');
    console.error("Error en resolveReviewRequest:", error);
    res.status(500).json({ message: 'Error al resolver la solicitud.' });
  } finally {
    if (client) client.release();
  }
};

const getAllConversations = async (req, res) => {
  try {
    const { search } = req.query;
    
    let query = `
      WITH LastMessages AS (
        SELECT DISTINCT ON (m.id_reporte) 
          m.id_reporte, 
          m.mensaje, 
          m.fecha_envio, 
          m.id_remitente,
          m.es_admin
        FROM chat_messages m
        ORDER BY m.id_reporte, m.fecha_envio DESC
      )
      SELECT 
        lm.*,
        r.titulo as reporte_titulo,
        r.codigo_reporte,
        COALESCE(u.alias, u.nombre) as usuario_nombre,
        u.email as usuario_email,
        r.foto_url,
        -- CORRECCIÓN CRÍTICA: Contamos mensajes donde es_admin = FALSE (son del usuario)
        -- y leido = FALSE. Estos son los que el Admin debe atender.
        (SELECT COUNT(*) FROM chat_messages cm 
         WHERE cm.id_reporte = lm.id_reporte 
         AND cm.es_admin = false 
         AND cm.leido = false
        ) as unread_count
      FROM LastMessages lm
      JOIN reportes r ON lm.id_reporte = r.id
      JOIN usuarios u ON r.id_usuario = u.id
    `;

    const params = [];
    let paramIndex = 1;
    
    if (search) {
      query += ` WHERE (r.titulo ILIKE $${paramIndex} OR u.nombre ILIKE $${paramIndex} OR u.alias ILIKE $${paramIndex} OR r.codigo_reporte ILIKE $${paramIndex})`;
      params.push(`%${search}%`);
    }

    // Ordenamos por fecha descendente en SQL también por defecto
    query += ` ORDER BY lm.fecha_envio DESC`;

    const result = await db.query(query, params);
    res.status(200).json(result.rows);

  } catch (error) {
    console.error("Error en getAllConversations:", error);
    if(!res.headersSent) res.status(500).json({ message: 'Error al cargar conversaciones.' });
  }
};

const getChatHistory = async (req, res) => {
  const { id: id_reporte } = req.params;
  const client = await db.getClient();

  try {
    await client.query('BEGIN');

    // Obtener mensajes
    const query = `
      SELECT m.id, m.id_reporte, m.id_remitente, m.remitente_alias, m.mensaje, m.es_admin,
             to_char(m.fecha_envio, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') as timestamp
      FROM chat_messages m
      WHERE m.id_reporte = $1
      ORDER BY m.fecha_envio ASC
    `;
    const result = await client.query(query, [id_reporte]);

    // MARCAR COMO LEÍDO (Perspectiva Admin)
    // Actualizamos a leido=true solo los mensajes que NO son del admin (es_admin=false)
    await client.query(
      `UPDATE chat_messages 
       SET leido = true 
       WHERE id_reporte = $1 AND es_admin = false AND leido = false`,
      [id_reporte]
    );

    await client.query('COMMIT');
    res.status(200).json(result.rows);

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error fetching chat history:', error);
    if(!res.headersSent) res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};

// Marcar mensajes del usuario como leídos por el admin
const markChatAsReadAdmin = async (req, res) => {
  const { id: id_reporte } = req.params;
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    // El admin lee los mensajes que envió el USUARIO (es_admin = false) y que no estaban leídos
    const result = await client.query(
      `UPDATE chat_messages 
       SET leido = true 
       WHERE id_reporte = $1 AND es_admin = false AND leido = false`,
      [id_reporte]
    );
    await client.query('COMMIT');
    
    res.status(200).json({ message: 'Chat marcado como leído.', updated: result.rowCount });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error marking chat read (admin):", error);
    if(!res.headersSent) res.status(500).json({ message: 'Error interno.' });
  } finally {
    client.release();
  }
};

const getUnreadGlobalCount = async (req, res) => {
  try {
    // Contamos cuántos reportes tienen al menos un mensaje del usuario sin leer
    const query = `
      SELECT COUNT(DISTINCT id_reporte) as count
      FROM chat_messages
      WHERE es_admin = false AND leido = false
    `;
    const result = await db.query(query);
    res.status(200).json({ count: parseInt(result.rows[0].count) });
  } catch (error) {
    console.error("Error counting unread chats:", error);
    res.status(500).json({ count: 0 });
  }
};

module.exports = {
  getAllAdminReports,
  updateReportVisibility,
  adminDeleteReport,
  adminAprobarReporte,
  adminRechazarReporte,
  adminSetReportToPending,
  getLatestPendingReports,
  getReviewRequests,
  resolveReviewRequest,
  getAllConversations,
  getChatHistory,
  markChatAsReadAdmin,
  getUnreadGlobalCount,
};