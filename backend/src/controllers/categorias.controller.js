const db = require('../config/db');

/**
 * Obtiene todas las categorías activas.
 * ORDENAMIENTO ROBUSTO:
 * 1. Detecta 'Otro' (sin importar mayúsculas/espacios) y le asigna peso 1.
 * 2. Al resto le asigna peso 0.
 * 3. Ordena primero por ese peso (0 antes que 1).
 * 4. Luego respeta el 'orden' establecido en el Panel Web.
 * 5. Finalmente desempate alfabético.
 */
const getPublicCategorias = async (req, res) => {
  try {
    const query = `
      SELECT id, nombre, icono_url 
      FROM categorias 
      ORDER BY 
        -- Lógica Maestra: Forzar 'Otro' al final
        CASE WHEN TRIM(LOWER(nombre)) = 'otro' THEN 1 ELSE 0 END ASC,
        -- Respetar el orden del Panel Web
        orden ASC,
        -- Desempate Alfabético
        nombre ASC
    `;
    
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