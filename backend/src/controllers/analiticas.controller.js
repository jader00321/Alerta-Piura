const db = require('../config/db');

// (buildDateFilter se mantiene igual)
const buildDateFilter = (startDate, endDate, params, dateColumn = 'r.fecha_creacion') => {
  if (startDate && endDate) {
    params.push(startDate);
    params.push(endDate);
    return `AND ${dateColumn} BETWEEN $${params.length - 1} AND $${params.length}`;
  }
  return '';
};

// (getReportesPorCategoria se mantiene igual)
const getReportesPorCategoria = async (req, res) => {
  const { startDate, endDate } = req.query;
  const params = [];
  const dateFilter = buildDateFilter(startDate, endDate, params);

  try {
    const query = `
      SELECT c.nombre as name, COUNT(r.id) as value
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      WHERE r.estado = 'verificado' ${dateFilter}
      GROUP BY c.nombre
      ORDER BY value DESC
    `;
    const result = await db.query(query, params);
    if (!res.headersSent) res.status(200).json(result.rows);
  } catch (error) {
    if (!res.headersSent) res.status(500).json({ message: 'Error al obtener reportes por categoría.' });
  }
};

// (getReportesPorDistrito se mantiene igual)
const getReportesPorDistrito = async (req, res) => {
  const { startDate, endDate } = req.query;
  const params = [];
  const dateFilter = buildDateFilter(startDate, endDate, params);

  try {
    const query = `
      SELECT distrito as name, COUNT(id) as value
      FROM reportes r
      WHERE distrito IS NOT NULL AND distrito <> '' AND r.estado = 'verificado' ${dateFilter}
      GROUP BY distrito
      ORDER BY value DESC
    `;
    const result = await db.query(query, params);
    if (!res.headersSent) res.status(200).json(result.rows);
  } catch (error) {
    if (!res.headersSent) res.status(500).json({ message: 'Error al obtener reportes por distrito.' });
  }
};

// --- FUNCIÓN CORREGIDA Y OPTIMIZADA ---
const getTendenciaReportes = async (req, res) => {
  try {
    const query = `
      SELECT 
        to_char(d.day, 'YYYY-MM-DD') AS name,
        COUNT(r.id) as value
      FROM 
        generate_series(
          current_date - interval '29 days', 
          current_date, 
          '1 day'
        ) AS d(day)
      LEFT JOIN 
        reportes r ON to_char(r.fecha_creacion, 'YYYY-MM-DD') = to_char(d.day, 'YYYY-MM-DD')
        AND r.estado = 'verificado' -- <<< CORRECCIÓN: Añadido filtro de estado
      GROUP BY 
        d.day
      ORDER BY 
        d.day ASC;
    `;
    const result = await db.query(query);
    if (!res.headersSent) {
      res.status(200).json(result.rows);
    }
  } catch (error) {
    console.error('Error al obtener la tendencia de reportes:', error);
    if (!res.headersSent) {
      res.status(500).json({ message: 'Error al obtener la tendencia de reportes.' });
    }
  }
};

// --- ESTA FUNCIÓN AHORA ES UN PLACEHOLDER ---
// La lógica real de PDF se moverá a la app, como solicitaste.
const solicitarExportacionPDF = async (req, res) => {
  const { email } = req.user; 
  try {
    res.status(200).json({ 
      message: `La generación de PDF ahora se maneja localmente en la app.` 
    });
  } catch (error) {
    if (!res.headersSent) {
      res.status(500).json({ message: 'Error al procesar la solicitud.' });
    }
  }
};

module.exports = {
  getReportesPorCategoria,
  getReportesPorDistrito,
  getTendenciaReportes,
  solicitarExportacionPDF // La mantenemos por completitud
};