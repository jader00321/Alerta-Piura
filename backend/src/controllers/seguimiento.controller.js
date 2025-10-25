const db = require('../config/db');

/**
 * Permite al usuario autenticado seguir un reporte.
 */
const seguirReporte = async (req, res) => {
  const id_usuario = req.user.userId;
  const { id_reporte } = req.params;
  try {
    await db.query('INSERT INTO reportes_seguidos (id_usuario, id_reporte) VALUES ($1, $2)', [id_usuario, id_reporte]);
    res.status(201).json({ message: 'Ahora sigues este reporte.' });
  } catch (error) {
    if (error.code === '23505') { // Error de clave duplicada
      return res.status(409).json({ message: 'Ya estás siguiendo este reporte.' });
    }
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

/**
 * Permite al usuario autenticado dejar de seguir un reporte.
 */
const dejarDeSeguirReporte = async (req, res) => {
  const id_usuario = req.user.userId;
  const { id_reporte } = req.params;
  try {
    await db.query('DELETE FROM reportes_seguidos WHERE id_usuario = $1 AND id_reporte = $2', [id_usuario, id_reporte]);
    res.status(200).json({ message: 'Has dejado de seguir este reporte.' });
  } catch (error) {
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

/**
 * Obtiene la lista de reportes que el usuario autenticado está siguiendo.
 */
const getMisReportesSeguidos = async (req, res) => {
  const id_usuario_seguidor = req.user.userId;
  try {
    const query = `
      SELECT
        r.id, r.titulo, r.estado, to_char(rs.fecha_seguimiento, 'DD Mon YYYY') as fecha,
        r.foto_url,
        c.nombre as categoria,
        CASE WHEN r.es_anonimo = true THEN 'Anónimo' ELSE COALESCE(u_autor.alias, u_autor.nombre) END as autor,
        CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario
      FROM reportes r
      JOIN reportes_seguidos rs ON r.id = rs.id_reporte
      JOIN categorias c ON r.id_categoria = c.id
      JOIN usuarios u_autor ON r.id_usuario = u_autor.id
      LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
      WHERE rs.id_usuario = $1
      ORDER BY rs.fecha_seguimiento DESC
    `;
    const result = await db.query(query, [id_usuario_seguidor]);
    res.status(200).json(result.rows);
  }catch (error) {
    res.status(500).json({ message: 'Error al obtener reportes seguidos.' });
  }
};

/**
 * Verifica si el usuario autenticado está siguiendo un reporte específico.
 */
const verificarSeguimiento = async (req, res) => {
  const id_usuario = req.user.userId;
  const { id_reporte } = req.params;
  try {
    const result = await db.query('SELECT 1 FROM reportes_seguidos WHERE id_usuario = $1 AND id_reporte = $2', [id_usuario, id_reporte]);
    const siguiendo = result.rows.length > 0;
    res.status(200).json({ siguiendo: siguiendo });
  } catch (error) {
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

module.exports = {
  seguirReporte,
  dejarDeSeguirReporte,
  getMisReportesSeguidos,
  verificarSeguimiento,
};