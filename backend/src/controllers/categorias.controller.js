// backend/src/controllers/categorias.controller.js
const db = require('../config/db'); // Ajusta la ruta si es necesario

/**
 * Obtiene todas las categorías activas, ordenadas.
 * Esta función es pública o para usuarios logueados, no requiere admin.
 */
const getPublicCategorias = async (req, res) => {
  try {
    // Seleccionamos solo id y nombre, ordenadas por el campo 'orden'
    // Asumiendo que tienes una columna 'activo' o similar, puedes añadir WHERE activo = true
    const query = "SELECT id, nombre FROM categorias ORDER BY orden ASC, nombre ASC"; // Ordenamos por 'orden' y luego por 'nombre'
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error al obtener categorías públicas:', error);
    res.status(500).json({ message: 'Error interno del servidor al obtener categorías.' });
  }
};

module.exports = {
  getPublicCategorias,
};