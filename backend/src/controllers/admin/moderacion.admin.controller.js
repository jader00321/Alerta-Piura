// backend/src/controllers/admin/moderacion.admin.controller.js
const db = require('../../config/db'); // <-- Adjusted path

const getReportedComments = async (req, res) => {
    // ... (getReportedComments function code remains the same) ...
      try {
    const query = `
      SELECT cr.id, cr.motivo, c.comentario, u_reportado.alias as autor_comentario, u_reportador.alias as reportado_por
      FROM comentario_reportes cr JOIN comentarios c ON cr.id_comentario = c.id
      JOIN usuarios u_reportado ON c.id_usuario = u_reportado.id JOIN usuarios u_reportador ON cr.id_reportador = u_reportador.id
      WHERE cr.estado = 'pendiente' ORDER BY cr.fecha_creacion ASC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error en getReportedComments:", error);
    res.status(500).json({ message: 'Error al obtener comentarios reportados.' });
  }
};
const resolveCommentReport = async (req, res) => {
    // ... (resolveCommentReport function code remains the same) ...
      const { id } = req.params;
  const { action } = req.body;
  const adminId = req.user.userId;
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    const adminRes = await client.query('SELECT alias FROM usuarios WHERE id = $1', [adminId]);
    const adminAlias = adminRes.rows[0].alias;
    const reportRes = await client.query('SELECT c.comentario, cr.motivo, cr.id_comentario FROM comentario_reportes cr JOIN comentarios c ON cr.id_comentario = c.id WHERE cr.id = $1', [id]);
    if (reportRes.rows.length === 0) throw new Error('Reporte no encontrado');
    const { comentario, motivo, id_comentario } = reportRes.rows[0];

    if (action === 'eliminar_comentario') {
      await client.query('DELETE FROM comentarios WHERE id = $1', [id_comentario]);
    }
    await client.query("UPDATE comentario_reportes SET estado = 'resuelto' WHERE id = $1", [id]);
    const logQuery = `INSERT INTO moderation_log (id_admin, admin_alias, accion, entidad_tipo, contenido_afectado, motivo_reporte) VALUES ($1, $2, $3, 'comentario', $4, $5)`;
    await client.query(logQuery, [adminId, adminAlias, action, comentario, motivo]);
    await client.query('COMMIT');
    res.status(200).json({ message: 'Acción de moderación completada.' });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error al resolver reporte de comentario:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};
const getReportedUsers = async (req, res) => {
    // ... (getReportedUsers function code remains the same) ...
      try {
    const query = `
      SELECT ur.id, ur.motivo, u_reportado.id as id_usuario_reportado, u_reportado.nombre as usuario_reportado_nombre,
             u_reportado.email as usuario_reportado_email, u_reportador.alias as reportado_por
      FROM usuario_reportes ur JOIN usuarios u_reportado ON ur.id_usuario_reportado = u_reportado.id
      JOIN usuarios u_reportador ON ur.id_reportador = u_reportador.id
      WHERE ur.estado = 'pendiente' ORDER BY ur.fecha_creacion ASC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error en getReportedUsers:", error);
    res.status(500).json({ message: 'Error al obtener usuarios reportados.' });
  }
};
const resolveUserReport = async (req, res) => {
    // ... (resolveUserReport function code remains the same) ...
      const { id } = req.params;
  const { action, userId } = req.body; // userId es el id_usuario_reportado
  const adminId = req.user.userId;
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    const adminRes = await client.query('SELECT alias FROM usuarios WHERE id = $1', [adminId]);
    const adminAlias = adminRes.rows[0].alias;
    const reportRes = await client.query('SELECT u.alias as user_alias, ur.motivo FROM usuario_reportes ur JOIN usuarios u ON ur.id_usuario_reportado = u.id WHERE ur.id = $1', [id]);
    if (reportRes.rows.length === 0) throw new Error('Reporte no encontrado');
    const { user_alias, motivo } = reportRes.rows[0];

    if (action === 'suspender_usuario') {
      if (!userId) throw new Error('ID de usuario a suspender no proporcionado');
      await client.query("UPDATE usuarios SET status = 'suspendido' WHERE id = $1", [userId]);
    }
    await client.query("UPDATE usuario_reportes SET estado = 'resuelto' WHERE id = $1", [id]);
    const logQuery = `INSERT INTO moderation_log (id_admin, admin_alias, accion, entidad_tipo, contenido_afectado, motivo_reporte) VALUES ($1, $2, $3, 'usuario', $4, $5)`;
    await client.query(logQuery, [adminId, adminAlias, action, user_alias, motivo]);
    await client.query('COMMIT');
    res.status(200).json({ message: 'Acción de moderación de usuario completada.' });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error al resolver reporte de usuario:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};
const getModerationHistory = async (req, res) => {
    // ... (getModerationHistory function code remains the same) ...
        try {
        const result = await db.query('SELECT * FROM moderation_log ORDER BY fecha_accion DESC');
        res.status(200).json(result.rows);
    } catch (error) {
        console.error("Error en getModerationHistory:", error);
        res.status(500).json({ message: 'Error al obtener el historial.' });
    }
};

module.exports = {
  getReportedComments,
  resolveCommentReport,
  getReportedUsers,
  resolveUserReport,
  getModerationHistory,
};