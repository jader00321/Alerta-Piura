const db = require('../config/db');

// Helper para filtros de fecha
const buildDateFilter = (startDate, endDate, params, dateColumn = 'r.fecha_creacion') => {
  if (startDate && endDate) {
    params.push(startDate);
    params.push(endDate);
    return `AND ${dateColumn} BETWEEN $${params.length - 1} AND $${params.length}`;
  }
  return '';
};

// 1. Reportes por Categoría
const getReportesPorCategoria = async (req, res) => {
  if (res.headersSent) return; // Protección inicial

  try {
    const { startDate, endDate } = req.query;
    const params = [];
    const dateFilter = buildDateFilter(startDate, endDate, params);

    const query = `
      SELECT c.nombre as name, COUNT(r.id) as value
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      WHERE r.estado = 'verificado' ${dateFilter}
      GROUP BY c.nombre
      ORDER BY value DESC
    `;
    const result = await db.query(query, params);
    return res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getReportesPorCategoria:', error);
    if (!res.headersSent) return res.status(500).json({ message: 'Error servidor' });
  }
};

// 2. Reportes por Distrito
const getReportesPorDistrito = async (req, res) => {
  if (res.headersSent) return;
  try {
    const { startDate, endDate } = req.query;
    const params = [];
    const dateFilter = buildDateFilter(startDate, endDate, params);

    const query = `
      SELECT distrito as name, COUNT(id) as value
      FROM reportes r
      WHERE distrito IS NOT NULL AND distrito <> '' AND r.estado = 'verificado' ${dateFilter}
      GROUP BY distrito
      ORDER BY value DESC
    `;
    const result = await db.query(query, params);
    return res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getReportesPorDistrito:', error);
    if (!res.headersSent) return res.status(500).json({ message: 'Error servidor' });
  }
};

// 3. Tendencia Temporal
const getTendenciaReportes = async (req, res) => {
  if (res.headersSent) return;
  try {
    const query = `
      SELECT to_char(d.day, 'YYYY-MM-DD') AS name, COUNT(r.id) as value
      FROM generate_series(current_date - interval '29 days', current_date, '1 day') AS d(day)
      LEFT JOIN reportes r ON to_char(r.fecha_creacion, 'YYYY-MM-DD') = to_char(d.day, 'YYYY-MM-DD') AND r.estado = 'verificado'
      GROUP BY d.day
      ORDER BY d.day ASC;
    `;
    const result = await db.query(query);
    return res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getTendenciaReportes:', error);
    if (!res.headersSent) return res.status(500).json({ message: 'Error servidor' });
  }
};

// 4. Mapa de Calor
const getHeatmapData = async (req, res) => {
  if (res.headersSent) return;
  try {
    const query = `
      SELECT ST_Y(location) as lat, ST_X(location) as lon
      FROM reportes WHERE estado = 'verificado' AND location IS NOT NULL LIMIT 1000;
    `;
    const result = await db.query(query);
    return res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getHeatmapData:', error);
    if (!res.headersSent) return res.status(500).json({ message: 'Error servidor' });
  }
};

// 5. Eficiencia (Tiempo Promedio)
const getTiemposAtencion = async (req, res) => {
  if (res.headersSent) return;
  try {
    const query = `
      SELECT AVG(EXTRACT(EPOCH FROM (fecha_actualizacion - fecha_creacion))) as segundos_promedio
      FROM reportes WHERE estado IN ('verificado', 'rechazado') AND fecha_actualizacion IS NOT NULL
    `;
    const result = await db.query(query);
    
    // CORRECCIÓN NaN: Si no hay datos, segundos_promedio es null.
    const segundos = result.rows[0].segundos_promedio !== null ? parseFloat(result.rows[0].segundos_promedio) : 0;
    const horas = (segundos / 3600).toFixed(1);

    return res.status(200).json({ 
      tiempoPromedioHoras: horas,
      totalProcesados: result.rowCount 
    });
  } catch (error) {
    console.error('Error en getTiemposAtencion:', error);
    if (!res.headersSent) return res.status(500).json({ message: 'Error servidor' });
  }
};

// 6. Urgencia
const getReportesPorUrgencia = async (req, res) => {
  if (res.headersSent) return;
  try {
    const query = `
      SELECT urgencia as name, COUNT(*) as value
      FROM reportes WHERE estado = 'verificado' AND urgencia IS NOT NULL
      GROUP BY urgencia ORDER BY value DESC
    `;
    const result = await db.query(query);
    return res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getReportesPorUrgencia:', error);
    if (!res.headersSent) return res.status(500).json({ message: 'Error servidor' });
  }
};

const solicitarExportacionPDF = async (req, res) => {
  return res.status(200).json({ message: 'PDF generado localmente.' });
};

module.exports = {
  getReportesPorCategoria,
  getReportesPorDistrito,
  getTendenciaReportes,
  getHeatmapData,
  getTiemposAtencion,
  getReportesPorUrgencia,
  solicitarExportacionPDF
};