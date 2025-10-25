const db = require('../config/db');
const socketNotificationService = require('../services/socketNotificationService');
const gamificacionService = require('../services/gamificacionService');

// ... (editarComentario, eliminarComentario, reportarComentario, apoyarComentario se mantienen igual) ...
const editarComentario = async (req, res) => {
  // ... (código existente sin cambios) ...
  const { id } = req.params; // id del comentario
  const id_usuario = req.user.userId;
  const { comentario } = req.body;

  if (!comentario || comentario.trim() === '') {
    return res.status(400).json({ message: 'El comentario no puede estar vacío.' });
  }

  try {
    const query = 'UPDATE comentarios SET comentario = $1 WHERE id = $2 AND id_usuario = $3 RETURNING *';
    const result = await db.query(query, [comentario, id, id_usuario]);

    if (result.rows.length === 0) {
      return res.status(403).json({ message: 'No autorizado para editar este comentario o el comentario no existe.' });
    }
    res.status(200).json({ message: 'Comentario actualizado.', comentario: result.rows[0] });
  } catch (error) {
    console.error('Error al editar comentario:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const eliminarComentario = async (req, res) => {
  // ... (código existente sin cambios) ...
  const { id } = req.params; // id del comentario
  const { userId: id_usuario, rol } = req.user;

  try {
    let query;
    let values;

    if (rol === 'lider_vecinal' || rol === 'admin') {
      query = 'DELETE FROM comentarios WHERE id = $1 RETURNING *';
      values = [id];
    } else {
      query = 'DELETE FROM comentarios WHERE id = $1 AND id_usuario = $2 RETURNING *';
      values = [id, id_usuario];
    }
    
    const result = await db.query(query, values);

    if (result.rows.length === 0) {
      return res.status(403).json({ message: 'No autorizado para eliminar este comentario o el comentario no existe.' });
    }
    res.status(200).json({ message: 'Comentario eliminado.' });
  } catch (error) {
    console.error('Error al eliminar comentario:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const reportarComentario = async (req, res) => {
    // ... (código existente sin cambios) ...
    const { id: id_comentario } = req.params; // id del comentario
    const id_reportador = req.user.userId;
    const { motivo } = req.body;

    if (!motivo) {
        return res.status(400).json({ message: 'Se requiere un motivo para reportar.'});
    }

    try {
        const query = 'INSERT INTO comentario_reportes (id_comentario, id_reportador, motivo) VALUES ($1, $2, $3)';
        await db.query(query, [id_comentario, id_reportador, motivo]);
        res.status(201).json({ message: 'Comentario reportado. Será revisado por un moderador.' });
    } catch (error) {
        console.error('Error al reportar comentario:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

const apoyarComentario = async (req, res) => {
  // ... (código existente sin cambios) ...
  const { id: id_comentario } = req.params; // id del comentario
  const id_usuario = req.user.userId;

  try {
    const checkQuery = 'SELECT * FROM comentario_apoyos WHERE id_comentario = $1 AND id_usuario = $2';
    const checkResult = await db.query(checkQuery, [id_comentario, id_usuario]);

    if (checkResult.rows.length > 0) {
      await db.query('DELETE FROM comentario_apoyos WHERE id_comentario = $1 AND id_usuario = $2', [id_comentario, id_usuario]);
      res.status(200).json({ message: 'Ya no te gusta este comentario.' });
    } else {
      await db.query('INSERT INTO comentario_apoyos (id_comentario, id_usuario) VALUES ($1, $2)', [id_comentario, id_usuario]);
      res.status(201).json({ message: 'Te gusta este comentario.' });
    }
  } catch (error) {
    console.error('Error al apoyar comentario:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

/**
 * Crea un comentario, otorga puntos, verifica insignias y notifica al autor del reporte.
 * AHORA OBTIENE id_reporte del BODY.
 */
const createComentario = async (req, res) => {
  // --- CAMBIO AQUÍ ---
  const { id_reporte, comentario } = req.body; // Obtiene id_reporte del body
  // --- FIN CAMBIO ---
  const id_usuario_comenta = req.user.userId;

  if (!id_reporte || !comentario || comentario.trim() === '') {
    return res.status(400).json({ message: 'Se requiere ID del reporte y el comentario no puede estar vacío.' });
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    // La inserción sigue igual
    const result = await client.query('INSERT INTO comentarios (id_reporte, id_usuario, comentario) VALUES ($1, $2, $3) RETURNING *', [id_reporte, id_usuario_comenta, comentario]);

    // Otorgar puntos y verificar insignias (sin cambios)
    await client.query('UPDATE usuarios SET puntos = puntos + 5 WHERE id = $1', [id_usuario_comenta]);
    await gamificacionService.verificarYOtorgarInsignias(client, id_usuario_comenta);

    const reporteResult = await client.query('SELECT id_usuario, titulo FROM reportes WHERE id = $1', [id_reporte]);
    const reporte = reporteResult.rows[0];
    const io = req.app.get('socketio');

    // Lógica de notificación (sin cambios)
    const title = `Nuevo comentario en: "${reporte.titulo}"`;
    const body = `${req.user.alias} ha comentado.`;
    const payload = JSON.stringify({ type: 'report_detail', id: id_reporte });

    if (reporte && reporte.id_usuario !== id_usuario_comenta) {
      await client.query('INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo, payload) VALUES ($1, $2, $3, $4)', [reporte.id_usuario, title, body, payload]);
      socketNotificationService.sendNotification(io, reporte.id_usuario, { title, body, payload });
    }

    const seguidoresResult = await client.query('SELECT id_usuario FROM reportes_seguidos WHERE id_reporte = $1', [id_reporte]);
    for (const seguidor of seguidoresResult.rows) {
      if (seguidor.id_usuario !== reporte.id_usuario && seguidor.id_usuario !== id_usuario_comenta) {
        await client.query('INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo, payload) VALUES ($1, $2, $3, $4) ON CONFLICT DO NOTHING', [seguidor.id_usuario, title, body, payload]);
        socketNotificationService.sendNotification(io, seguidor.id_usuario, { title, body, payload });
      }
    }

    await client.query('COMMIT');
    res.status(201).json({ message: 'Comentario añadido y +5 puntos obtenidos.', comentario: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    // Verificar si el reporte existe antes de intentar comentar
    if (error.code === '23503') { // foreign key violation
        return res.status(404).json({ message: 'El reporte especificado no existe.' });
    }
    console.error("Error creating comment:", error); // Log para depuración
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};


module.exports = {
  editarComentario,
  eliminarComentario,
  reportarComentario,
  apoyarComentario,
  createComentario, // Exportamos la función
};