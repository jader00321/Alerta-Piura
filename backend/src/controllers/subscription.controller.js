const db = require('../config/db');
const jwt = require('jsonwebtoken');
// Importamos el servicio de gamificación que ya creamos
const gamificacionService = require('../services/gamificacionService');

const getPlans = async (req, res) => {
  // ... (esta función no cambia, asumiendo que ya tienes el plan 'reportero_prensa' en tu tabla planes_suscripcion)
  try {
    const query = "SELECT id, identificador_plan, nombre_publico, descripcion, precio_mensual FROM planes_suscripcion WHERE activo = true ORDER BY precio_mensual ASC";
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error al obtener los planes:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const subscribe = async (req, res) => {
  const { planId, paymentMethod, paymentMethodId } = req.body;
  const userId = req.user.userId;

  if (!planId || (!paymentMethod && !paymentMethodId)) {
    return res.status(400).json({ message: 'Se requiere un ID de plan y un método de pago.' });
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const planResult = await client.query('SELECT * FROM planes_suscripcion WHERE id = $1', [planId]);
    if (planResult.rows.length === 0) throw new Error('Plan no encontrado.');
    const plan = planResult.rows[0];

    let metodoDePagoId = paymentMethodId;

    if (paymentMethod) {
      const ultimos_cuatro = paymentMethod.numeroTarjeta.slice(-4);
      if (paymentMethod.guardarMetodo) {
          const countResult = await client.query('SELECT COUNT(*) FROM metodos_pago WHERE id_usuario = $1', [userId]);
          const esElPrimero = parseInt(countResult.rows[0].count, 10) === 0;
          if(esElPrimero){
            paymentMethod.es_predeterminado = true;
          }
      }
      
      const metodoPagoResult = await client.query(
        `INSERT INTO metodos_pago (id_usuario, tipo_tarjeta, ultimos_cuatro_digitos, fecha_expiracion, token_tarjeta_cifrado, es_predeterminado)
         VALUES ($1, 'VISA', $2, $3, $4, $5) RETURNING id`,
        [userId, ultimos_cuatro, paymentMethod.fechaExp, `tok_sim_${Date.now()}`, paymentMethod.guardarMetodo ? paymentMethod.es_predeterminado || false : false]
      );
      metodoDePagoId = metodoPagoResult.rows[0].id;
    }
    
    const expirationDate = new Date();
    expirationDate.setMonth(expirationDate.getMonth() + 1);

    let nuevoRol = req.user.rol; // Mantenemos el rol actual por defecto

    if (plan.identificador_plan === 'reportero_prensa') {
      nuevoRol = 'reportero';
      // Otorgamos la insignia "Analista Urbano"
      const insigniaResult = await client.query("SELECT id FROM insignias WHERE nombre = 'Analista Urbano'");
      if (insigniaResult.rows.length > 0) {
        await client.query('INSERT INTO usuario_insignias (id_usuario, id_insignia) VALUES ($1, $2) ON CONFLICT DO NOTHING', [userId, insigniaResult.rows[0].id]);
      }
    } else if (plan.identificador_plan === 'ciudadano_premium') {
      // Si es premium pero no reportero, aseguramos que su rol sea 'ciudadano' (si era 'lider_vecinal' lo mantiene)
      if (nuevoRol !== 'lider_vecinal' && nuevoRol !== 'admin') {
        nuevoRol = 'ciudadano';
      }
      // Otorgamos la insignia "Guardián Premium"
      await gamificacionService.verificarYOtorgarInsignias(client, userId); // Re-usamos la lógica de gamificación
    }

    await client.query(
      'UPDATE usuarios SET id_plan_suscripcion = $1, fecha_fin_suscripcion = $2, rol = $3 WHERE id = $4',
      [planId, expirationDate, nuevoRol, userId]
    );

    const transaccionResult = await client.query(
      `INSERT INTO transacciones_pago (id_usuario, id_plan, id_metodo_pago, monto_pagado, estado_transaccion, id_transaccion_pasarela)
       VALUES ($1, $2, $3, $4, 'APROBADO', $5) RETURNING id`,
      [userId, planId, metodoDePagoId, plan.precio_mensual, `sim_txn_${Date.now()}`]
    );

    // Generar un nuevo token JWT con el ROL y PLAN actualizados
    const userResult = await client.query('SELECT * FROM usuarios WHERE id = $1', [userId]);
    const user = userResult.rows[0];
    const payload = { user: { userId: user.id, email: user.email, alias: user.alias || user.nombre, rol: user.rol, planId: planId } };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' });

    await client.query('COMMIT');

    res.status(200).json({ 
        message: '¡Suscripción exitosa!', 
        token: token,
        transactionId: transaccionResult.rows[0].id
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error en subscribe:", error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};

const cancelarSuscripcion = async (req, res) => {
  const userId = req.user.userId;
  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    // Lógica de prueba: Expira en 1 minuto
    const expirationDate = new Date(Date.now() + 60 * 1000); 

    // Al cancelar, volvemos al rol 'ciudadano' (a menos que sea líder o admin)
    const userResult = await client.query('SELECT rol FROM usuarios WHERE id = $1', [userId]);
    let rolActual = userResult.rows[0].rol;
    let nuevoRol = rolActual;

    if (rolActual === 'reportero') {
      nuevoRol = 'ciudadano'; // El rol de reportero se pierde al cancelar
    }
    // Si es 'lider_vecinal' o 'admin', su rol no cambia.

    await db.query(
      'UPDATE usuarios SET fecha_fin_suscripcion = $1, rol = $2 WHERE id = $3',
      [expirationDate, nuevoRol, userId]
    );

    await client.query('COMMIT');

    res.status(200).json({ 
      message: 'Tu suscripción ha sido cancelada. Tus beneficios premium expirarán pronto.',
      fecha_expiracion: expirationDate.toISOString(),
    });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};

module.exports = {
  getPlans,
  subscribe,
  cancelarSuscripcion,
};