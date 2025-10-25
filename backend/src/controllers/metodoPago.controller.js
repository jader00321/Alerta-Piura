const db = require('../config/db');

const listarMetodos = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT id, tipo_tarjeta, ultimos_cuatro_digitos, fecha_expiracion, es_predeterminado
      FROM metodos_pago 
      WHERE id_usuario = $1 
      ORDER BY es_predeterminado DESC, id ASC`;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener los métodos de pago.' });
  }
};

const crearMetodo = async (req, res) => {
  const id_usuario = req.user.userId;
  const { nombreTitular, numeroTarjeta, fechaExp, cvc, es_predeterminado } = req.body;

  if (!numeroTarjeta || !fechaExp || !cvc) {
    return res.status(400).json({ message: 'Los detalles de la tarjeta son requeridos.' });
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    // Si se marca como predeterminado, primero desmarcamos los otros.
    if (es_predeterminado) {
      await client.query('UPDATE metodos_pago SET es_predeterminado = false WHERE id_usuario = $1', [id_usuario]);
    }

    const ultimos_cuatro = numeroTarjeta.slice(-4);
    const insertQuery = `
      INSERT INTO metodos_pago (id_usuario, tipo_tarjeta, ultimos_cuatro_digitos, fecha_expiracion, token_tarjeta_cifrado, es_predeterminado)
      VALUES ($1, 'VISA', $2, $3, $4, $5) RETURNING id, tipo_tarjeta, ultimos_cuatro_digitos, es_predeterminado`;

    const result = await client.query(insertQuery, [id_usuario, ultimos_cuatro, fechaExp, `tok_sim_${Date.now()}`, es_predeterminado]);

    await client.query('COMMIT');
    res.status(201).json({ message: 'Método de pago añadido con éxito.', metodo: result.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(500).json({ message: 'Error al crear el método de pago.' });
  } finally {
    client.release();
  }
};

const establecerPredeterminado = async (req, res) => {
  const id_usuario = req.user.userId;
  const { id: id_metodo } = req.params;
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    // Quita el predeterminado de todas las tarjetas del usuario
    await client.query('UPDATE metodos_pago SET es_predeterminado = false WHERE id_usuario = $1', [id_usuario]);
    // Establece la nueva tarjeta como predeterminada
    await client.query('UPDATE metodos_pago SET es_predeterminado = true WHERE id = $1 AND id_usuario = $2', [id_metodo, id_usuario]);
    await client.query('COMMIT');
    res.status(200).json({ message: 'Método de pago predeterminado actualizado.' });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(500).json({ message: 'Error al actualizar el método de pago.' });
  } finally {
    client.release();
  }
};

const eliminarMetodo = async (req, res) => {
  const id_usuario = req.user.userId;
  const { id: id_metodo } = req.params;

  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    // Lógica de seguridad: no permitir eliminar el último método si hay suscripción activa
    const subResult = await db.query('SELECT id_plan_suscripcion, fecha_fin_suscripcion FROM usuarios WHERE id = $1', [id_usuario]);
    const userSub = subResult.rows[0];
    const isPremium = userSub.id_plan_suscripcion && userSub.fecha_fin_suscripcion && new Date(userSub.fecha_fin_suscripcion) > new Date();

    if (isPremium) {
      const countResult = await db.query('SELECT COUNT(*) FROM metodos_pago WHERE id_usuario = $1', [id_usuario]);
      if (parseInt(countResult.rows[0].count, 10) <= 1) {
        await client.query('ROLLBACK');
        return res.status(400).json({ message: 'No puedes eliminar tu único método de pago mientras tengas una suscripción activa.' });
      }
    }

    await client.query('DELETE FROM metodos_pago WHERE id = $1 AND id_usuario = $2', [id_metodo, id_usuario]);

    await client.query('COMMIT');
    res.status(200).json({ message: 'Método de pago eliminado.' });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(500).json({ message: 'Error al eliminar el método de pago.' });
  } finally {
    client.release();
  }
};

module.exports = {
  listarMetodos,
  crearMetodo,
  establecerPredeterminado,
  eliminarMetodo,
};