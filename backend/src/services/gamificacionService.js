const db = require('../config/db');

/**
 * Verifica si un usuario califica para nuevas insignias basado en sus puntos
 * y las otorga si es necesario. Se debe usar dentro de una transacción de BD.
 * @param {object} client - El cliente de la transacción de la base de datos.
 * @param {number} id_usuario - El ID del usuario a verificar.
 */
const verificarYOtorgarInsignias = async (client, id_usuario) => {
  try {
    // 1. Obtener los puntos actuales del usuario y las insignias que ya posee.
    const userQuery = 'SELECT puntos, ARRAY(SELECT id_insignia FROM usuario_insignias WHERE id_usuario = $1) as insignias_ganadas FROM usuarios WHERE id = $1';
    const userResult = await client.query(userQuery, [id_usuario]);

    if (userResult.rows.length === 0) {
      console.log(`Gamificación: Usuario ${id_usuario} no encontrado.`);
      return;
    }

    const { puntos, insignias_ganadas } = userResult.rows[0];

    // 2. Encontrar insignias para las que califica por puntos y que aún no tiene.
    const nuevasInsigniasQuery = 'SELECT id FROM insignias WHERE puntos_necesarios <= $1 AND NOT (id = ANY($2))';
    const nuevasInsigniasResult = await client.query(nuevasInsigniasQuery, [puntos, insignias_ganadas]);

    if (nuevasInsigniasResult.rows.length > 0) {
      // 3. Otorgar las nuevas insignias.
      const idsParaOtorgar = nuevasInsigniasResult.rows.map(row => row.id);
      const valoresInsert = idsParaOtorgar.map(id_insignia => `(${id_usuario}, ${id_insignia})`).join(',');

      const otorgarQuery = `INSERT INTO usuario_insignias (id_usuario, id_insignia) VALUES ${valoresInsert} ON CONFLICT DO NOTHING`;
      await client.query(otorgarQuery);

      console.log(`Gamificación: Usuario ${id_usuario} ha ganado ${idsParaOtorgar.length} nueva(s) insignia(s) por puntos.`);
    }
  } catch (error) {
    console.error('Error en verificarYOtorgarInsignias:', error);
    // No lanzamos un error aquí para no revertir la transacción principal
    // si solo falla el otorgamiento de insignias.
  }
};

module.exports = {
  verificarYOtorgarInsignias,
};