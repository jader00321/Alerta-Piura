const db = require('../config/db');

// Editar un comentario (solo el autor puede)
const editarComentario = async (req, res) => {
  const { id } = req.params;
  const id_usuario = req.user.id;
  const { comentario } = req.body;

  try {
    const query = 'UPDATE comentarios SET comentario = $1 WHERE id = $2 AND id_usuario = $3 RETURNING *';
    const result = await db.query(query, [comentario, id, id_usuario]);

    if (result.rows.length === 0) {
      return res.status(403).json({ message: 'No autorizado para editar este comentario.' });
    }
    res.status(200).json({ message: 'Comentario actualizado.', comentario: result.rows[0] });
  } catch (error) {
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// Eliminar un comentario (autor, líder o admin pueden)
const eliminarComentario = async (req, res) => {
  const { id } = req.params;
  const { id: id_usuario, rol } = req.user;

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
      return res.status(403).json({ message: 'No autorizado para eliminar este comentario.' });
    }
    res.status(200).json({ message: 'Comentario eliminado.' });
  } catch (error) {
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// Reportar un comentario
const reportarComentario = async (req, res) => {
    const { id: id_comentario } = req.params;
    const id_reportador = req.user.id;
    const { motivo } = req.body;

    if (!motivo) {
        return res.status(400).json({ message: 'Se requiere un motivo para reportar.'});
    }

    try {
        const query = 'INSERT INTO comentario_reportes (id_comentario, id_reportador, motivo) VALUES ($1, $2, $3)';
        await db.query(query, [id_comentario, id_reportador, motivo]);
        res.status(201).json({ message: 'Comentario reportado. Será revisado por un moderador.' });
    } catch (error) {
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

const apoyarComentario = async (req, res) => {
  const { id: id_comentario } = req.params;
  const id_usuario = req.user.id;
  try {
    await db.query('INSERT INTO comentario_apoyos (id_comentario, id_usuario) VALUES ($1, $2)', [id_comentario, id_usuario]);
    res.status(201).json({ message: 'Te gusta este comentario.' });
  } catch (error) {
    if (error.code === '23505') {
      await db.query('DELETE FROM comentario_apoyos WHERE id_comentario = $1 AND id_usuario = $2', [id_comentario, id_usuario]);
      return res.status(200).json({ message: 'Ya no te gusta este comentario.' });
    }
    console.error('Error al apoyar comentario:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

module.exports = {
  editarComentario,
  eliminarComentario,
  reportarComentario,
  apoyarComentario,
};