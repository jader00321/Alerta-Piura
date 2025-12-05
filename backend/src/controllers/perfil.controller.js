// backend/src/controllers/perfil.controller.js

/**
 * Controlador de Perfil de Usuario
 * --------------------------------
 * Gestiona todas las operaciones relacionadas con la cuenta personal del usuario:
 * - Obtención de datos del perfil y suscripción.
 * - Historial de actividad (reportes, apoyos, comentarios).
 * - Gestión de seguridad (email, password).
 * - Notificaciones y pagos.
 * - Funcionalidades Premium (zonas seguras, estadísticas).
 */

const db = require('../config/db');
const bcrypt = require('bcryptjs'); 

/**
 * Obtiene la información completa del perfil del usuario autenticado.
 * Verifica si la suscripción ha expirado y limpia el estado si es necesario.
 */
const getMiPerfil = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    // Consulta principal de datos del usuario y su plan actual
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

    // Lógica de negocio: Verificar vencimiento de suscripción al consultar el perfil
    if (perfil.id_plan_suscripcion && perfil.fecha_fin_suscripcion && new Date(perfil.fecha_fin_suscripcion) < new Date()) {
      await db.query('UPDATE usuarios SET id_plan_suscripcion = NULL, fecha_fin_suscripcion = NULL WHERE id = $1', [id_usuario]);
      perfil.nombre_plan = null;
      perfil.fecha_fin_suscripcion = null;
    }

    // Obtener insignias ganadas
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
    console.error('Error en getMiPerfil:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

/**
 * Obtiene el historial de reportes creados por el usuario.
 * Orden: Del más reciente al más antiguo.
 */
const getMisReportes = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
   SELECT
     r.id, r.titulo, r.estado, 
     to_char(r.fecha_creacion, 'DD Mon YYYY, HH24:MI') as fecha, -- Formato con hora
     r.foto_url,
     c.nombre as categoria,
     CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario,
     r.urgencia, 
     r.distrito  
   FROM reportes r
   JOIN categorias c ON r.id_categoria = c.id
   LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
   WHERE r.id_usuario = $1
   ORDER BY r.fecha_creacion DESC
 `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getMisReportes:', error);
    res.status(500).json({ message: 'Error al obtener mis reportes.' });
  }
};

/**
 * Obtiene el historial de reportes que el usuario ha apoyado.
 * Orden: Basado en la fecha del APOYO, no del reporte.
 */
const getMisApoyos = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT 
        r.id, r.titulo, r.estado, 
        to_char(a.fecha_creacion, 'DD Mon YYYY, HH24:MI') as fecha, -- Fecha del apoyo
        r.foto_url,
        c.nombre as categoria,
        CASE WHEN r.es_anonimo = true THEN 'Anónimo' ELSE COALESCE(u.alias, u.nombre) END as autor,
        CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario
      FROM reportes r
      JOIN apoyos a ON r.id = a.id_reporte
      JOIN categorias c ON r.id_categoria = c.id
      JOIN usuarios u ON r.id_usuario = u.id -- Autor del reporte
      LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
      WHERE a.id_usuario = $1 
      ORDER BY a.fecha_creacion DESC
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getMisApoyos:', error);
    res.status(500).json({ message: 'Error al obtener mis apoyos.' });
  }
};

/**
 * Obtiene el historial completo de comentarios hechos por el usuario.
 * Corrección: Muestra TODOS los comentarios cronológicamente, sin agrupar por reporte.
 */
const getMisComentarios = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT 
        r.id, r.titulo, r.estado, 
        to_char(c_user.fecha_creacion, 'DD Mon YYYY, HH24:MI') as fecha, -- Fecha del comentario
        r.foto_url,
        cat.nombre as categoria,
        CASE WHEN r.es_anonimo = true THEN 'Anónimo' ELSE COALESCE(u_autor.alias, u_autor.nombre) END as autor,
        CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario,
        c_user.comentario as mi_comentario
      FROM comentarios c_user 
      JOIN reportes r ON c_user.id_reporte = r.id
      JOIN categorias cat ON r.id_categoria = cat.id
      JOIN usuarios u_autor ON r.id_usuario = u_autor.id 
      LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
      WHERE c_user.id_usuario = $1 
      ORDER BY c_user.fecha_creacion DESC
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getMisComentarios:', error);
    res.status(500).json({ message: 'Error al obtener mis comentarios.' });
  }
};

/**
 * Obtiene la lista de conversaciones activas (Chats) del usuario.
 * Agrupa por reporte, muestra el último mensaje, cuenta los no leídos
 * y define quién habló por última vez.
 */
const getMisConversaciones = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT DISTINCT ON (m.id_reporte)
        r.id as id_reporte,
        r.titulo as titulo_reporte,
        r.foto_url,
        r.codigo_reporte,
        m.mensaje as ultimo_mensaje,
        m.es_admin as ultimo_es_admin,
        to_char(m.fecha_envio, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') as fecha_ultimo_mensaje,
        
        -- CORRECCIÓN CRÍTICA: Solo contar como NO LEÍDOS los mensajes que:
        -- 1. Vienen del Admin (es_admin = true)
        -- 2. No han sido leídos (leido = false)
        (SELECT COUNT(*) 
         FROM chat_messages cm 
         WHERE cm.id_reporte = m.id_reporte 
           AND cm.es_admin = true  -- <-- IMPORTANTE
           AND cm.leido = false
        ) as unread_count
        
      FROM chat_messages m
      JOIN reportes r ON m.id_reporte = r.id
      WHERE r.id_usuario = $1
      ORDER BY m.id_reporte, m.fecha_envio DESC
    `;
    
    const result = await db.query(query, [id_usuario]);
    
    const sortedRows = result.rows.sort((a, b) => 
      new Date(b.fecha_ultimo_mensaje) - new Date(a.fecha_ultimo_mensaje)
    );

    res.status(200).json(sortedRows);
  } catch (error) {
    console.error('Error en getMisConversaciones:', error);
    res.status(500).json({ message: 'Error al obtener conversaciones.' });
  }
};

/**
 * Obtiene los reportes propios que AÚN NO tienen una conversación iniciada.
 * Incluye pendientes, verificados y rechazados.
 */
const getReportesSinChat = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT 
        r.id, 
        r.titulo, 
        r.foto_url, 
        r.estado, 
        r.codigo_reporte,
        to_char(r.fecha_creacion, 'DD/MM/YYYY') as fecha_creacion
      FROM reportes r
      WHERE r.id_usuario = $1
      -- Excluir reportes que ya tienen mensajes en la tabla chat
      AND r.id NOT IN (SELECT DISTINCT id_reporte FROM chat_messages)
      ORDER BY r.fecha_creacion DESC
    `;
    
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getReportesSinChat:', error);
    res.status(500).json({ message: 'Error al obtener reportes disponibles.' });
  }
};

/**
 * Actualiza los datos básicos del perfil (nombre, alias, teléfono).
 */
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

/**
 * Actualiza el correo electrónico del usuario (requiere confirmación de contraseña).
 */
const updateMyEmail = async (req, res) => {
  const { newEmail, password } = req.body;
  const id_usuario = req.user.userId;

  if (!newEmail || !password) {
    return res.status(400).json({ message: 'El nuevo email y la contraseña son requeridos.' });
  }

  try {
    const userResult = await db.query('SELECT password_hash FROM usuarios WHERE id = $1', [id_usuario]);
    const isMatch = await bcrypt.compare(password, userResult.rows[0].password_hash);

    if (!isMatch) {
      return res.status(403).json({ message: 'La contraseña actual es incorrecta.' });
    }

    await db.query('UPDATE usuarios SET email = $1 WHERE id = $2', [newEmail, id_usuario]);
    res.status(200).json({ message: 'Email actualizado con éxito. Por favor, vuelve a iniciar sesión.' });

  } catch (error) {
    if (error.code === '23505') {
      return res.status(409).json({ message: 'El nuevo correo electrónico ya está en uso.' });
    }
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

/**
 * Actualiza la contraseña del usuario.
 */
const updateMyPassword = async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  const id_usuario = req.user.userId;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ message: 'Todos los campos son requeridos.' });
  }

  try {
    const userResult = await db.query('SELECT password_hash FROM usuarios WHERE id = $1', [id_usuario]);
    const isMatch = await bcrypt.compare(currentPassword, userResult.rows[0].password_hash);

    if (!isMatch) {
      return res.status(403).json({ message: 'La contraseña actual es incorrecta.' });
    }

    const salt = await bcrypt.genSalt(10);
    const new_password_hash = await bcrypt.hash(newPassword, salt);
    await db.query('UPDATE usuarios SET password_hash = $1 WHERE id = $2', [new_password_hash, id_usuario]);
    
    res.status(200).json({ message: 'Contraseña actualizada con éxito. Por favor, vuelve a iniciar sesión.' });
  } catch (error) {
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

/**
 * Obtiene el historial de notificaciones push recibidas.
 */
const getMisNotificaciones = async (req, res) => {
  const id_usuario = req.user.userId;
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

/**
 * Marca todas las notificaciones del usuario como leídas.
 */
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

/**
 * Obtiene el historial de transacciones (pagos de suscripción).
 */
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

/**
 * Obtiene el detalle completo de una boleta/transacción específica.
 */
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

/**
 * Permite a un ciudadano postular para ser Líder Vecinal.
 */
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

    const query = `
      INSERT INTO solicitudes_rol (id_usuario, motivacion, zona_propuesta)
      VALUES ($1, $2, $3)
    `;
    await db.query(query, [id_usuario, motivacion.trim(), zona_propuesta.trim()]);

    res.status(201).json({ message: 'Postulación enviada exitosamente. Un administrador la revisará.' });
  } catch (error) {
    if (error.code === '23505') { 
      return res.status(409).json({ message: 'Ya tienes una solicitud pendiente.' });
    }
    console.error('Error al postular como líder:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

/**
 * Obtiene contadores resumidos para la sección "Mi Actividad".
 */
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

/**
 * Datos para gráficos: Reportes por categoría del usuario.
 */
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

/**
 * Datos para gráficos: Reportes por mes del usuario.
 */
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

/**
 * Datos geoespaciales: Ubicaciones de los reportes del usuario (para mapa de calor personal).
 */
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

/**
 * Obtiene las Zonas Seguras creadas por el usuario (Premium).
 */
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

/**
 * Crea una nueva Zona Segura (Premium).
 */
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

/**
 * Elimina una Zona Segura.
 */
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

/**
 * Endpoint auxiliar para obtener contadores rápidos de actividad.
 */
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

/**
 * Obtiene notificaciones con filtros avanzados (Estilo Gmail).
 * Query params: 
 * - search: texto a buscar en titulo/cuerpo
 * - filter: 'all', 'unread', 'archived'
 * - category: 'Sistema', 'Chat', etc.
 * - page: paginación
 */
const getMisNotificacionesAvanzadas = async (req, res) => {
  const id_usuario = req.user.userId;
  const { search, filter, category, page = 1 } = req.query;
  const limit = 20;
  const offset = (page - 1) * limit;

  try {
    let query = `
      SELECT id, titulo, cuerpo, leido, fecha_envio, payload, categoria, remitente_info, archivado
      FROM notificaciones
      WHERE id_usuario_receptor = $1
    `;
    const params = [id_usuario];
    let paramIndex = 2;

    // Filtro de Estado (Archivado / Bandeja de Entrada)
    if (filter === 'archived') {
      query += ` AND archivado = true`;
    } else {
      query += ` AND archivado = false`; // Por defecto mostramos la bandeja de entrada
    }

    // Filtro de Leído/No Leído (dentro de la bandeja actual)
    if (filter === 'unread') {
      query += ` AND leido = false`;
    }

    // Filtro por Categoría
    if (category && category !== 'Todas') {
      query += ` AND categoria = $${paramIndex++}`;
      params.push(category);
    }

    // Búsqueda de Texto
    if (search) {
      query += ` AND (titulo ILIKE $${paramIndex} OR cuerpo ILIKE $${paramIndex})`;
      params.push(`%${search}%`);
      paramIndex++;
    }

    query += ` ORDER BY fecha_envio DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`;
    params.push(limit, offset);

    const result = await db.query(query, params);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getMisNotificacionesAvanzadas:', error);
    res.status(500).json({ message: 'Error al obtener notificaciones.' });
  }
};

/**
 * Obtiene solo el conteo de no leídas para el "Badge" (Icono rojo).
 * Es muy rápido y ligero.
 */
const getConteoNoLeidas = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `SELECT COUNT(*) FROM notificaciones WHERE id_usuario_receptor = $1 AND leido = false AND archivado = false`;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json({ count: parseInt(result.rows[0].count, 10) });
  } catch (error) {
    res.status(500).json({ message: 'Error al contar no leídas.' });
  }
};

/**
 * Marca una notificación específica como leída.
 */
const marcarUnaComoLeida = async (req, res) => {
  const { id } = req.params;
  const id_usuario = req.user.userId;
  try {
    await db.query('UPDATE notificaciones SET leido = true WHERE id = $1 AND id_usuario_receptor = $2', [id, id_usuario]);
    res.status(200).json({ success: true });
  } catch (error) {
    res.status(500).json({ message: 'Error al actualizar notificación.' });
  }
};

/**
 * Archiva o Desarchiva una notificación.
 */
const toggleArchivarNotificacion = async (req, res) => {
  const { id } = req.params;
  const { archivar } = req.body; // boolean
  const id_usuario = req.user.userId;
  try {
    await db.query('UPDATE notificaciones SET archivado = $1 WHERE id = $2 AND id_usuario_receptor = $3', [archivar, id, id_usuario]);
    res.status(200).json({ message: archivar ? 'Notificación archivada' : 'Notificación movida a entrada' });
  } catch (error) {
    res.status(500).json({ message: 'Error al archivar.' });
  }
};

/**
 * Elimina notificaciones (individual o masiva).
 * Body: { ids: [1, 2, 3] }
 */
const eliminarNotificaciones = async (req, res) => {
  const { ids } = req.body; // Array de IDs
  const id_usuario = req.user.userId;
  
  if (!ids || !Array.isArray(ids) || ids.length === 0) {
    return res.status(400).json({ message: 'Se requieren IDs para eliminar.' });
  }

  try {
    // Eliminar múltiples IDs de forma segura
    const query = `DELETE FROM notificaciones WHERE id = ANY($1::int[]) AND id_usuario_receptor = $2`;
    await db.query(query, [ids, id_usuario]);
    res.status(200).json({ message: 'Notificaciones eliminadas.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error al eliminar.' });
  }
};

/**
 * Datos para tabla: Reportes del usuario agrupados por estado.
 * Útil para medir la "efectividad" de los reportes del usuario.
 */
const getMisReportesPorEstado = async (req, res) => {
  const id_usuario = req.user.userId;
  try {
    const query = `
      SELECT estado as name, COUNT(id) as value
      FROM reportes
      WHERE id_usuario = $1
      GROUP BY estado
      ORDER BY value DESC;
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getMisReportesPorEstado:', error);
    res.status(500).json({ message: 'Error al obtener reportes por estado.' });
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
  getMisNotificacionesAvanzadas,
  getConteoNoLeidas,
  marcarUnaComoLeida,
  toggleArchivarNotificacion,
  eliminarNotificaciones,
  getMisReportesPorEstado,
  getReportesSinChat,
};