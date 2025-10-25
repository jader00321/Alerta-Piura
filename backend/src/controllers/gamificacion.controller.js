// backend/src/controllers/gamificacion.controller.js
const db = require('../config/db'); // Ajusta la ruta a tu config/db.js

/**
 * Obtiene todas las insignias de progreso (basadas en puntos) 
 * y las compara con las insignias ganadas por el usuario.
 */
const getProgresoInsignias = async (req, res) => {
  const id_usuario = req.user.userId;
  
  try {
    // 1. Obtener todas las insignias de progreso (puntos > 0)
    //    y también las insignias de estatus (puntos = 0 o null)
    const todasInsigniasQuery = `
      SELECT id, nombre, descripcion, icono_url, puntos_necesarios 
      FROM insignias 
      ORDER BY puntos_necesarios ASC, id ASC
    `;
    
    // 2. Obtener los IDs de las insignias que el usuario ya ha ganado
    const insigniasGanadasQuery = `
      SELECT id_insignia 
      FROM usuario_insignias 
      WHERE id_usuario = $1
    `;
    
    // 3. Obtener los puntos actuales del usuario
    const puntosUsuarioQuery = 'SELECT puntos FROM usuarios WHERE id = $1';

    // Ejecutar consultas en paralelo
    const [
      todasInsigniasResult, 
      insigniasGanadasResult, 
      puntosUsuarioResult
    ] = await Promise.all([
      db.query(todasInsigniasQuery),
      db.query(insigniasGanadasQuery, [id_usuario]),
      db.query(puntosUsuarioQuery, [id_usuario])
    ]);

    const insigniasGanadasSet = new Set(insigniasGanadasResult.rows.map(r => r.id_insignia));
    const puntosUsuario = puntosUsuarioResult.rows[0]?.puntos ?? 0;

    // 4. Combinar los resultados
    const progresoInsignias = todasInsigniasResult.rows.map(insignia => ({
      ...insignia,
      // 'isEarned' es true si el ID de la insignia está en el Set de ganadas
      isEarned: insigniasGanadasSet.has(insignia.id) 
    }));

    res.status(200).json({
      puntosUsuario: puntosUsuario,
      insignias: progresoInsignias,
    });

  } catch (error) {
    console.error('Error al obtener progreso de insignias:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

module.exports = {
  getProgresoInsignias,
};