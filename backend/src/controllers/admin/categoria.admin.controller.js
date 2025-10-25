// backend/src/controllers/admin/categoria.admin.controller.js
const db = require('../../config/db'); // <-- Adjusted path

const getAllCategories = async (req, res) => {
    // ... (getAllCategories function code remains the same) ...
      try {
    const result = await db.query('SELECT * FROM categorias ORDER BY orden ASC');
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error en getAllCategories:", error);
    res.status(500).json({ message: 'Error al obtener categorías.' });
  }
};
const getCategoriesWithStats = async (req, res) => {
    // ... (getCategoriesWithStats function code remains the same) ...
      try {
    const query = `
      SELECT c.id, c.nombre, c.icono_url, c.orden,
             COUNT(r.id) FILTER (WHERE r.estado = 'verificado') as reportes_activos,
             COUNT(r.id) FILTER (WHERE r.estado = 'pendiente_verificacion') as reportes_pendientes,
             COUNT(r.id) FILTER (WHERE r.estado = 'rechazado') as reportes_rechazados
      FROM categorias c LEFT JOIN reportes r ON c.id = r.id_categoria
      GROUP BY c.id ORDER BY c.orden ASC, c.nombre ASC;
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching categories with stats:", error);
    res.status(500).json({ message: 'Error al obtener categorías.' });
  }
};
const getCategorySuggestions = async (req, res) => {
    // ... (getCategorySuggestions function code remains the same) ...
      try {
    const query = `
      SELECT categoria_sugerida, COUNT(*) as count, MAX(fecha_creacion) as mas_reciente
      FROM reportes
      WHERE id_categoria = (SELECT id FROM categorias WHERE nombre = 'Otro')
        AND categoria_sugerida IS NOT NULL AND categoria_sugerida != ''
        AND LOWER(categoria_sugerida) NOT IN (SELECT LOWER(nombre) FROM categorias)
      GROUP BY categoria_sugerida ORDER BY mas_reciente DESC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error en getCategorySuggestions:", error);
    res.status(500).json({ message: 'Error al obtener sugerencias de categorías.' });
  }
};
const createCategory = async (req, res) => {
    // ... (createCategory function code remains the same) ...
      const { nombre } = req.body;
  if (!nombre) return res.status(400).json({ message: 'El nombre es requerido.' });
  try {
    const query = 'INSERT INTO categorias (nombre) VALUES ($1) RETURNING *';
    const result = await db.query(query, [nombre]);
    res.status(201).json({ message: 'Categoría creada.', categoria: result.rows[0] });
  } catch (error) {
    if (error.code === '23505') return res.status(409).json({ message: 'Categoría ya existe.' });
    console.error("Error en createCategory:", error);
    res.status(500).json({ message: 'Error al crear la categoría.' });
  }
};
const deleteCategory = async (req, res) => {
    // ... (deleteCategory function code remains the same) ...
      const { id } = req.params;
  try {
    const catRes = await db.query('SELECT nombre FROM categorias WHERE id = $1', [id]);
    if (catRes.rows.length > 0 && catRes.rows[0].nombre === 'Otro') {
      return res.status(400).json({ message: 'Categoría "Otro" no se puede eliminar.' });
    }
    const reportCountRes = await db.query('SELECT COUNT(*) FROM reportes WHERE id_categoria = $1', [id]);
    if (parseInt(reportCountRes.rows[0].count, 10) > 0) {
      return res.status(400).json({ message: 'Categoría en uso por reportes.' });
    }
    await db.query('DELETE FROM categorias WHERE id = $1', [id]);
    res.status(200).json({ message: 'Categoría eliminada.' });
  } catch (error) {
    console.error("Error en deleteCategory:", error);
    res.status(500).json({ message: 'Error al eliminar la categoría.' });
  }
};
const reorderCategories = async (req, res) => {
    // ... (reorderCategories function code remains the same) ...
      const { orderedIds } = req.body;
  if (!Array.isArray(orderedIds)) return res.status(400).json({ message: 'Se requiere array de IDs.' });
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    await Promise.all(orderedIds.map((categoryId, index) =>
      client.query('UPDATE categorias SET orden = $1 WHERE id = $2', [index + 1, categoryId])
    ));
    await client.query('COMMIT');
    res.status(200).json({ message: 'Categorías reordenadas.' });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error reordering categories:", error);
    res.status(500).json({ message: 'Error al reordenar categorías.' });
  } finally {
    client.release();
  }
};
const mergeCategorySuggestion = async (req, res) => {
    // ... (mergeCategorySuggestion function code remains the same) ...
      const { sourceSuggestionName, targetCategoryId } = req.body;
  if (!sourceSuggestionName || !targetCategoryId) return res.status(400).json({ message: 'Faltan parámetros.' });
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    const otroRes = await client.query("SELECT id FROM categorias WHERE nombre = 'Otro'");
    if (otroRes.rows.length === 0) throw new Error('"Otro" no encontrada.');
    const otroId = otroRes.rows[0].id;
    const updateRes = await client.query(
      `UPDATE reportes SET id_categoria = $1, categoria_sugerida = NULL
       WHERE id_categoria = $2 AND categoria_sugerida = $3`,
      [targetCategoryId, otroId, sourceSuggestionName]
    );
    await client.query('COMMIT');
    res.status(200).json({ message: `Sugerencia '${sourceSuggestionName}' fusionada. ${updateRes.rowCount} reportes actualizados.` });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error merging category:", error);
    res.status(500).json({ message: 'Error al fusionar categoría.' });
  } finally {
    client.release();
  }
};

module.exports = {
  getAllCategories,
  getCategoriesWithStats,
  getCategorySuggestions,
  createCategory,
  deleteCategory,
  reorderCategories,
  mergeCategorySuggestion,
};