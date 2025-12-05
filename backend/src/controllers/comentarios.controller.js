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
 * Crea un comentario, otorga puntos, verifica insignias y notifica al autor.
 * ACTUALIZADO: Inyecta categoría, remitente y payload para navegación inteligente.
 */
const createComentario = async (req, res) => {
  const { id_reporte, comentario } = req.body;
  const id_usuario_comenta = req.user.userId;
  // Obtenemos alias y rol del token o req.user para guardar en la notificación
  const remitenteAlias = req.user.alias || 'Usuario'; 
  const remitenteRol = req.user.rol || 'ciudadano';

  if (!id_reporte || !comentario || comentario.trim() === '') {
    return res.status(400).json({ message: 'Se requiere ID del reporte y el comentario no puede estar vacío.' });
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    // 1. Insertar Comentario
    const result = await client.query(
      'INSERT INTO comentarios (id_reporte, id_usuario, comentario) VALUES ($1, $2, $3) RETURNING *', 
      [id_reporte, id_usuario_comenta, comentario]
    );

    // 2. Gamificación
    await client.query('UPDATE usuarios SET puntos = puntos + 5 WHERE id = $1', [id_usuario_comenta]);
    await gamificacionService.verificarYOtorgarInsignias(client, id_usuario_comenta);

    // 3. Obtener datos del reporte para notificar
    const reporteResult = await client.query('SELECT id_usuario, titulo FROM reportes WHERE id = $1', [id_reporte]);
    const reporte = reporteResult.rows[0];
    const io = req.app.get('socketio');

    // --- PREPARACIÓN DE DATOS RICOS PARA NOTIFICACIÓN ---
    const title = `Nuevo comentario en: "${reporte.titulo}"`;
    const body = `${remitenteAlias} ha comentado: "${comentario.substring(0, 30)}${comentario.length > 30 ? '...' : ''}"`;
    
    // Payload: JSON que le dice a la App a dónde ir
    const payloadObj = { 
      type: 'report_detail', 
      id: id_reporte 
    };
    const payload = JSON.stringify(payloadObj);
    
    // Info del Remitente: Para mostrar avatar o nombre sin consultas extra
    const remitenteInfo = JSON.stringify({
      alias: remitenteAlias,
      rol: remitenteRol,
      id: id_usuario_comenta
    });

    const categoria = 'Comentario'; // Para el icono y filtro

    // Función auxiliar para insertar notificación enriquecida
    const notificarUsuario = async (receptorId) => {
      await client.query(
        `INSERT INTO notificaciones 
        (id_usuario_receptor, titulo, cuerpo, payload, categoria, remitente_info, archivado, leido) 
        VALUES ($1, $2, $3, $4, $5, $6, false, false)`, 
        [receptorId, title, body, payload, categoria, remitenteInfo]
      );
      
      socketNotificationService.sendNotification(io, receptorId, { 
        title, 
        body, 
        payload, 
        categoria,
        remitenteInfo: JSON.parse(remitenteInfo) // Enviamos objeto al socket
      });
    };

    // 4. Notificar al Dueño del Reporte
    if (reporte && reporte.id_usuario !== id_usuario_comenta) {
      await notificarUsuario(reporte.id_usuario);
    }

    // 5. Notificar a Seguidores
    const seguidoresResult = await client.query('SELECT id_usuario FROM reportes_seguidos WHERE id_reporte = $1', [id_reporte]);
    for (const seguidor of seguidoresResult.rows) {
      if (seguidor.id_usuario !== reporte.id_usuario && seguidor.id_usuario !== id_usuario_comenta) {
        await notificarUsuario(seguidor.id_usuario);
      }
    }

    await client.query('COMMIT');
    res.status(201).json({ message: 'Comentario añadido y +5 puntos obtenidos.', comentario: result.rows[0] });

  } catch (error) {
    await client.query('ROLLBACK');
    if (error.code === '23503') {
        return res.status(404).json({ message: 'El reporte especificado no existe.' });
    }
    console.error("Error creating comment:", error);
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
  createComentario, 
};