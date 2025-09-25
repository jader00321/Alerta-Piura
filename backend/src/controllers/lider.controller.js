const db = require('../config/db');

// Obtener todos los reportes pendientes de verificación
const getReportesPendientes = async (req, res) => {
  try {
    // --- CAMBIO CLAVE: Añadimos "estado" a la consulta SQL ---
    const query = `
      SELECT r.id, r.titulo, r.descripcion, r.estado, c.nombre as categoria, --<-- ADD
             TO_CHAR(r.fecha_creacion, 'DD/MM/YYYY HH24:MI') as fecha 
      FROM Reportes r
      JOIN Categorias c ON r.id_categoria = c.id --<-- ADD
      WHERE r.estado = 'pendiente_verificacion' 
      ORDER BY r.fecha_creacion ASC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error al obtener reportes pendientes:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// Aprobar un reporte
const aprobarReporte = async (req, res) => {
  const { id } = req.params;
  const id_lider = req.user.id; // ID del reporte
  try {
    // --- CAMBIO CLAVE: Añadimos fecha_actualizacion ---
    const query = "UPDATE Reportes SET estado = 'verificado', fecha_actualizacion = CURRENT_TIMESTAMP , id_lider_verificador = $1 WHERE id = $2 RETURNING *";
    const result = await db.query(query, [id_lider, id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Reporte no encontrado.' });
    }
    res.status(200).json({ message: 'Reporte aprobado exitosamente.' });
  } catch (error) {
    console.error('Error al aprobar el reporte:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};
// Rechazar un reporte
const rechazarReporte = async (req, res) => {
  const { id } = req.params;
  const id_lider = req.user.id; 
  try {
    // --- CAMBIO CLAVE: Añadimos fecha_actualizacion ---
    const query = "UPDATE Reportes SET estado = 'rechazado', fecha_actualizacion = CURRENT_TIMESTAMP id_lider_verificador = $1 WHERE id = $2 RETURNING *";
    const result = await db.query(query, [id_lider, id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Reporte no encontrado.' });
    }
    res.status(200).json({ message: 'Reporte rechazado exitosamente.' });
  } catch (error) {
    console.error('Error al rechazar el reporte:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const getReportesModerados = async (req, res) => {
  try {
    const query = `
      SELECT r.id, r.titulo, r.descripcion, r.estado, c.nombre as categoria, --<-- ADD
             COALESCE(to_char(r.fecha_actualizacion, 'DD Mon YYYY'), 'N/A') as fecha 
      FROM reportes r
      JOIN Categorias c ON r.id_categoria = c.id --<-- ADD
      WHERE r.estado IN ('verificado', 'rechazado') 
      ORDER BY r.fecha_actualizacion DESC NULLS LAST
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error detallado al obtener historial:', error);
    res.status(500).json({ message: 'Error al obtener el historial de reportes.' });
  }
};

const getMisComentariosReportados = async (req, res) => {
  const id_reportador = req.user.id;
  try {
    const query = `
      SELECT cr.id, cr.motivo, cr.estado, 
             to_char(cr.fecha_creacion, 'DD Mon YYYY') as fecha,
             cr.fecha_creacion as sort_date, -- <-- ADD THIS LINE
             c.comentario as contenido, u_reportado.alias as usuario_reportado
      FROM comentario_reportes cr
      JOIN comentarios c ON cr.id_comentario = c.id
      JOIN usuarios u_reportado ON c.id_usuario = u_reportado.id
      WHERE cr.id_reportador = $1
      ORDER BY cr.fecha_creacion DESC
    `;
    const result = await db.query(query, [id_reportador]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener comentarios reportados.' });
  }
};

// Get user reports filed by the current leader
const getMisUsuariosReportados = async (req, res) => {
  const id_reportador = req.user.id;
  try {
    const query = `
      SELECT ur.id, ur.motivo, ur.estado, 
             to_char(ur.fecha_creacion, 'DD Mon YYYY') as fecha,
             ur.fecha_creacion as sort_date, -- <-- ADD THIS LINE
             u_reportado.alias as contenido
      FROM usuario_reportes ur
      JOIN usuarios u_reportado ON ur.id_usuario_reportado = u_reportado.id
      WHERE ur.id_reportador = $1
      ORDER BY ur.fecha_creacion DESC
    `;
    const result = await db.query(query, [id_reportador]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener usuarios reportados.' });
  }
};

const solicitarRevision = async (req, res) => {
  const { id: id_reporte } = req.params;
  const id_lider = req.user.id;
  try {
    await db.query("INSERT INTO solicitudes_revision (id_reporte, id_lider) VALUES ($1, $2)", [id_reporte, id_lider]);
    res.status(200).json({ message: 'Solicitud de revisión enviada al administrador.' });
  } catch (error) {
    res.status(500).json({ message: 'Error al solicitar la revisión.' });
  }
};

// Add a new function for the leader to get THEIR requests
const getMisSolicitudesRevision = async (req, res) => {
  const id_lider = req.user.id;
  try {
    const query = `
      SELECT sr.id, sr.estado, sr.id_reporte, -- <-- ADD sr.id_reporte
             to_char(sr.fecha_solicitud, 'DD Mon YYYY') as fecha, 
             r.titulo
      FROM solicitudes_revision sr
      JOIN reportes r ON sr.id_reporte = r.id
      WHERE sr.id_lider = $1
      ORDER BY sr.fecha_solicitud DESC
    `;
    const result = await db.query(query, [id_lider]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener solicitudes.' });
  }
};

module.exports = {
  getReportesPendientes,
  aprobarReporte,
  rechazarReporte,
  getReportesModerados, 
  getMisComentariosReportados,
  getMisUsuariosReportados,
  solicitarRevision,
  getMisSolicitudesRevision,
};