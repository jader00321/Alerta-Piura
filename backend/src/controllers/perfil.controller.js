const db = require('../config/db');
const bcrypt = require('bcryptjs'); 

// Obtener el perfil del usuario autenticado
const getMiPerfil = async (req, res) => {
  // ... (Tu código existente aquí, no necesita cambios)
  const id_usuario = req.user.userId;
  try {
    const userQuery = `
      SELECT u.id, u.nombre, u.alias, u.email, u.puntos, u.telefono,
             p.nombre_publico as nombre_plan,
             u.fecha_fin_suscripcion
      FROM usuarios u
      LEFT JOIN planes_suscripcion p ON u.id_plan_suscripcion = p.id
      WHERE u.id = $1
    `;
    const userResult = await db.query(userQuery, [id_usuario]);
    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'Usuario no encontrado.' });
    }
    const perfil = userResult.rows[0];
    if (perfil.id_plan_suscripcion && perfil.fecha_fin_suscripcion && new Date(perfil.fecha_fin_suscripcion) < new Date()) {
      await db.query('UPDATE usuarios SET id_plan_suscripcion = NULL, fecha_fin_suscripcion = NULL WHERE id = $1', [id_usuario]);
      perfil.nombre_plan = null;
      perfil.fecha_fin_suscripcion = null;
    }
    const insigniasQuery = `
      SELECT i.nombre, i.descripcion, i.icono_url 
      FROM insignias i
      JOIN usuario_insignias ui ON i.id = ui.id_insignia
      WHERE ui.id_usuario = $1
    `;
    const insigniasResult = await db.query(insigniasQuery, [id_usuario]);
    perfil.insignias = insigniasResult.rows;
    res.status(200).json(perfil);
  } catch (error) {
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// --- getMisReportes (MODIFICADO) ---
const getMisReportes = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    // Añadido JOIN con categorias y reportes_prioritarios
    const query = `
   SELECT
     r.id, r.titulo, r.estado, to_char(r.fecha_creacion, 'DD Mon YYYY') as fecha,
     r.foto_url,
     c.nombre as categoria,
     CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario,
     r.urgencia, 
     r.distrito  
     -- 'autor' no es necesario aquí
   FROM reportes r
   JOIN categorias c ON r.id_categoria = c.id
   LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
   WHERE r.id_usuario = $1
   ORDER BY r.fecha_creacion DESC
 `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener mis reportes.' });
  }
};

// --- getMisApoyos (MODIFICADO) ---
const getMisApoyos = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    // Añadido JOIN con categorias, usuarios (para el autor) y reportes_prioritarios
    const query = `
      SELECT 
        r.id, r.titulo, r.estado, to_char(a.fecha_creacion, 'DD Mon YYYY') as fecha,
        r.foto_url,
        c.nombre as categoria,
        CASE WHEN r.es_anonimo = true THEN 'Anónimo' ELSE COALESCE(u.alias, u.nombre) END as autor,
        CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario
      FROM reportes r
      JOIN apoyos a ON r.id = a.id_reporte
      JOIN categorias c ON r.id_categoria = c.id
      JOIN usuarios u ON r.id_usuario = u.id -- u es el autor del reporte
      LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
      WHERE a.id_usuario = $1 -- $1 es el usuario que dio el apoyo
      ORDER BY a.fecha_creacion DESC
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener mis apoyos.' });
  }
};

// --- getMisComentarios (MODIFICADO) ---
const getMisComentarios = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    // Query más compleja para obtener el último comentario del usuario por reporte
    const query = `
      SELECT DISTINCT ON (r.id) 
        r.id, r.titulo, r.estado, to_char(c_user.fecha_creacion, 'DD Mon YYYY') as fecha,
        r.foto_url,
        cat.nombre as categoria,
        CASE WHEN r.es_anonimo = true THEN 'Anónimo' ELSE COALESCE(u_autor.alias, u_autor.nombre) END as autor,
        CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario,
        c_user.comentario as mi_comentario
      FROM comentarios c_user -- c_user es el comentario del usuario actual
      JOIN reportes r ON c_user.id_reporte = r.id
      JOIN categorias cat ON r.id_categoria = cat.id
      JOIN usuarios u_autor ON r.id_usuario = u_autor.id -- u_autor es el autor del reporte
      LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
      WHERE c_user.id_usuario = $1 -- $1 es el usuario que comentó
      -- Ordenar para que DISTINCT ON se quede con el comentario más reciente
      ORDER BY r.id, c_user.fecha_creacion DESC
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener mis comentarios.' });
  }
};

const getMisConversaciones = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT DISTINCT ON (r.id) r.id, r.titulo
      FROM reportes r
      JOIN chat_messages cm ON r.id = cm.id_reporte
      WHERE r.id_usuario = $1
      ORDER BY r.id, cm.timestamp DESC
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener conversaciones.' });
  }
};

const updateMyProfile = async (req, res) => {
  const { nombre, alias, telefono } = req.body;
  const id_usuario = req.user.userId;

  if (!nombre) {
    return res.status(400).json({ message: 'El nombre es requerido.' });
  }

  try {
    const query = 'UPDATE usuarios SET nombre = $1, alias = $2, telefono = $3 WHERE id = $4 RETURNING id, nombre, alias, telefono';
    const result = await db.query(query, [nombre, alias, telefono, id_usuario]);
    res.status(200).json({ message: 'Perfil actualizado con éxito.', user: result.rows[0] });
  } catch (error) {
    if (error.code === '23505' && error.constraint === 'usuarios_alias_unique') {
      return res.status(409).json({ message: 'Ese alias ya está en uso. Por favor, elige otro.' });
    }
    res.status(500).json({ message: 'Error al actualizar el perfil.' });
  }
};

const updateMyEmail = async (req, res) => {
  const { newEmail, password } = req.body;
  const id_usuario = req.user.userId;

  if (!newEmail || !password) {
    return res.status(400).json({ message: 'El nuevo email y la contraseña son requeridos.' });
  }

  try {
    // Verify user's current password
    const userResult = await db.query('SELECT password_hash FROM usuarios WHERE id = $1', [id_usuario]);
    const isMatch = await bcrypt.compare(password, userResult.rows[0].password_hash);

    if (!isMatch) {
      return res.status(403).json({ message: 'La contraseña actual es incorrecta.' });
    }

    // If password is correct, update the email
    await db.query('UPDATE usuarios SET email = $1 WHERE id = $2', [newEmail, id_usuario]);
    res.status(200).json({ message: 'Email actualizado con éxito. Por favor, vuelve a iniciar sesión.' });

  } catch (error) {
    if (error.code === '23505') { // Unique violation
      return res.status(409).json({ message: 'El nuevo correo electrónico ya está en uso.' });
    }
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const updateMyPassword = async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  const id_usuario = req.user.userId;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ message: 'Todos los campos son requeridos.' });
  }

  try {
    // Verify user's current password
    const userResult = await db.query('SELECT password_hash FROM usuarios WHERE id = $1', [id_usuario]);
    const isMatch = await bcrypt.compare(currentPassword, userResult.rows[0].password_hash);

    if (!isMatch) {
      return res.status(403).json({ message: 'La contraseña actual es incorrecta.' });
    }

    // If password is correct, hash the new password and update it
    const salt = await bcrypt.genSalt(10);
    const new_password_hash = await bcrypt.hash(newPassword, salt);
    await db.query('UPDATE usuarios SET password_hash = $1 WHERE id = $2', [new_password_hash, id_usuario]);
    
    res.status(200).json({ message: 'Contraseña actualizada con éxito. Por favor, vuelve a iniciar sesión.' });
  } catch (error) {
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const getMisNotificaciones = async (req, res) => {
  const id_usuario = req.user.userId; // Corregido para usar userId del token refactorizado
  try {
    const query = `
      SELECT id, titulo, cuerpo, leido, fecha_envio
      FROM notificaciones
      WHERE id_usuario_receptor = $1
      ORDER BY fecha_envio DESC
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener notificaciones.' });
  }
};

const marcarTodasComoLeidas = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = 'UPDATE notificaciones SET leido = true WHERE id_usuario_receptor = $1 AND leido = false';
    await db.query(query, [id_usuario]);
    res.status(200).json({ message: 'Todas las notificaciones han sido marcadas como leídas.' });
  } catch (error) {
    console.error('Error al marcar notificaciones como leídas:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const getPaymentHistory = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT 
        t.id, 
        t.monto_pagado, 
        t.estado_transaccion, 
        to_char(t.fecha_transaccion, 'DD Mon YYYY, HH24:MI') as fecha_formateada,
        p.nombre_publico as nombre_plan
      FROM transacciones_pago t
      JOIN planes_suscripcion p ON t.id_plan = p.id
      WHERE t.id_usuario = $1
      ORDER BY t.fecha_transaccion DESC;
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error al obtener historial de pagos:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const getInvoiceDetails = async (req, res) => {
  const id_usuario = req.user.userId;
  const { transactionId } = req.params;
  try {
    const query = `
      SELECT 
        t.id, 
        t.monto_pagado, 
        t.estado_transaccion, 
        t.id_transaccion_pasarela,
        to_char(t.fecha_transaccion, 'DD de Mon del YYYY, HH24:MI') as fecha_completa,
        p.nombre_publico as nombre_plan,
        mp.tipo_tarjeta,
        mp.ultimos_cuatro_digitos,
        u.nombre as nombre_usuario,
        u.email as email_usuario
      FROM transacciones_pago t
      JOIN planes_suscripcion p ON t.id_plan = p.id
      JOIN metodos_pago mp ON t.id_metodo_pago = mp.id
      JOIN usuarios u ON t.id_usuario = u.id
      WHERE t.id_usuario = $1 AND t.id = $2;
    `;
    const result = await db.query(query, [id_usuario, transactionId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Boleta no encontrada o no pertenece a este usuario.' });
    }
    res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error('Error al obtener detalles de la boleta:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const postularComoLider = async (req, res) => {
  const id_usuario = req.user.userId;
  const { motivacion, zona_propuesta } = req.body;

  if (!motivacion || !zona_propuesta || motivacion.trim() === '' || zona_propuesta.trim() === '') {
      return res.status(400).json({ message: 'La motivación y la zona propuesta son requeridas.' });
  }

  try {
    const checkResult = await db.query("SELECT rol FROM usuarios WHERE id = $1", [id_usuario]);
    if (checkResult.rows.length === 0) return res.status(404).json({ message: 'Usuario no encontrado.' });
    if (checkResult.rows[0].rol !== 'ciudadano') return res.status(400).json({ message: 'Ya tienes un rol asignado o una postulación en proceso.' });

    const existingRequest = await db.query("SELECT id FROM solicitudes_rol WHERE id_usuario = $1 AND estado = 'pendiente'", [id_usuario]);
    if (existingRequest.rows.length > 0) return res.status(409).json({ message: 'Ya tienes una postulación pendiente.' });

    // Guardar los nuevos datos
    const query = `
      INSERT INTO solicitudes_rol (id_usuario, motivacion, zona_propuesta)
      VALUES ($1, $2, $3)
    `;
    await db.query(query, [id_usuario, motivacion.trim(), zona_propuesta.trim()]);

    res.status(201).json({ message: 'Postulación enviada exitosamente. Un administrador la revisará.' });
  } catch (error) {
    if (error.code === '23505') { // Error de unicidad
      return res.status(409).json({ message: 'Ya tienes una solicitud pendiente.' });
    }
    console.error('Error al postular como líder:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const getMisEstadisticasResumen = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT
        (SELECT COUNT(*) FROM reportes WHERE id_usuario = $1) as total_reportes,
        (SELECT COUNT(*) FROM apoyos WHERE id_usuario = $1) as total_apoyos,
        (SELECT COUNT(*) FROM comentarios WHERE id_usuario = $1) as total_comentarios;
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener el resumen de estadísticas.' });
  }
};

const getMisReportesPorCategoria = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT c.nombre as name, COUNT(r.id) as value
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      WHERE r.id_usuario = $1
      GROUP BY c.nombre
      ORDER BY value DESC;
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener reportes por categoría.' });
  }
};

const getMisReportesPorMes = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT to_char(fecha_creacion, 'YYYY-MM') as name, COUNT(id) as value
      FROM reportes
      WHERE id_usuario = $1
      GROUP BY to_char(fecha_creacion, 'YYYY-MM')
      ORDER BY name ASC;
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener reportes por mes.' });
  }
};

const getMisReportesUbicaciones = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT ST_Y(location) as lat, ST_X(location) as lon
      FROM reportes
      WHERE id_usuario = $1 AND location IS NOT NULL;
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener ubicaciones de reportes.' });
  }
};

const getMisZonasSeguras = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT id, nombre, radio_metros, ST_Y(centro) as lat, ST_X(centro) as lon
      FROM zonas_seguras WHERE id_usuario = $1 ORDER BY fecha_creacion DESC
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener zonas seguras.' });
  }
};

const crearZonaSegura = async (req, res) => {
  const id_usuario = req.user.userId;
  const { nombre, lat, lon, radio_metros } = req.body;
  try {
    const query = `
      INSERT INTO zonas_seguras (id_usuario, nombre, centro, radio_metros)
      VALUES ($1, $2, ST_SetSRID(ST_MakePoint($3, $4), 4326), $5) RETURNING *
    `;
    const result = await db.query(query, [id_usuario, nombre, lon, lat, radio_metros]);
    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error al crear la zona segura.' });
  }
};

const eliminarZonaSegura = async (req, res) => {
  const id_usuario = req.user.userId;
  const { id } = req.params;
  try {
    const result = await db.query('DELETE FROM zonas_seguras WHERE id = $1 AND id_usuario = $2', [id, id_usuario]);
    if (result.rowCount === 0) {
      return res.status(404).json({ message: 'Zona no encontrada o no pertenece al usuario.' });
    }
    res.status(200).json({ message: 'Zona segura eliminada.' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar la zona segura.' });
  }
};

const getStatsActividad = async (req, res) => {
    const id_usuario = req.user.userId;
    try {
        const reportesResult = await db.query('SELECT COUNT(*) FROM reportes WHERE id_usuario = $1', [id_usuario]);
        const apoyosResult = await db.query('SELECT COUNT(*) FROM apoyos WHERE id_usuario = $1', [id_usuario]);
        const seguimientosResult = await db.query('SELECT COUNT(*) FROM reportes_seguidos WHERE id_usuario = $1', [id_usuario]);
        const comentariosResult = await db.query('SELECT COUNT(DISTINCT id_reporte) FROM comentarios WHERE id_usuario = $1', [id_usuario]);

        res.status(200).json({
          misReportes: parseInt(reportesResult.rows[0].count, 10),
          misApoyos: parseInt(apoyosResult.rows[0].count, 10),
          misSeguimientos: parseInt(seguimientosResult.rows[0].count, 10),
          misComentarios: parseInt(comentariosResult.rows[0].count, 10)
        });
    } catch (error) { 
        res.status(500).json({ message: 'Error al obtener estadísticas de actividad.' });
    }
};

module.exports = {
  getMiPerfil,
  getMisReportes,   
  getMisApoyos,
  getMisComentarios,
  getMisConversaciones,
  updateMyProfile,
  updateMyEmail,
  updateMyPassword,
  getMisNotificaciones,
  marcarTodasComoLeidas,
  getPaymentHistory,
  getInvoiceDetails,
  postularComoLider,
  getMisEstadisticasResumen,
  getMisReportesPorCategoria,
  getMisReportesPorMes,
  getMisReportesUbicaciones,
  getMisZonasSeguras,
  crearZonaSegura,
  eliminarZonaSegura,
  getStatsActividad,
};