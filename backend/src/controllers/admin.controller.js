/*const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const socketNotificationService = require('../services/socketNotificationService');
const servicioNotificacionesZonas = require('../services/servicioNotificacionesZonas');

const login = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email y contraseña son requeridos.' });
  }
  try {
    const userResult = await db.query("SELECT * FROM Usuarios WHERE email = $1 AND (rol = 'admin' OR rol = 'reportero')", [email]); // Permitir login a admin y reportero
    if (userResult.rows.length === 0) {
      return res.status(403).json({ message: 'Acceso denegado. Credenciales incorrectas o sin privilegios.' });
    }
    const user = userResult.rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(403).json({ message: 'Acceso denegado. Credenciales incorrectas.' });
    }
    const payload = { user: { id: user.id, rol: user.rol, alias: user.alias || user.nombre } };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '8h' });
    res.json({ token, user: payload.user });
  } catch (error) {
    console.error("Error en login de admin:", error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

const getDashboardStats = async (req, res) => {
  try {
    // We run all count queries concurrently for better performance
    const [
      userCount,
      reportesPendientes,
      reportesVerificados,
      comentariosReportados,
      usuariosReportados
    ] = await Promise.all([
      db.query('SELECT COUNT(*) FROM usuarios'),
      db.query("SELECT COUNT(*) FROM reportes WHERE estado = 'pendiente_verificacion'"),
      db.query("SELECT COUNT(*) FROM reportes WHERE estado = 'verificado'"),
      db.query("SELECT COUNT(*) FROM comentario_reportes WHERE estado = 'pendiente'"),
      db.query("SELECT COUNT(*) FROM usuario_reportes WHERE estado = 'pendiente'")
    ]);

    res.status(200).json({
      totalUsuarios: parseInt(userCount.rows[0].count, 10),
      reportesPendientes: parseInt(reportesPendientes.rows[0].count, 10),
      reportesVerificados: parseInt(reportesVerificados.rows[0].count, 10),
      comentariosReportados: parseInt(comentariosReportados.rows[0].count, 10),
      usuariosReportados: parseInt(usuariosReportados.rows[0].count, 10),
    });
  } catch (error) {
    console.error("Error fetching dashboard stats:", error);
    res.status(500).json({ message: 'Error al obtener estadísticas.' });
  }
};

const getAllUsers = async (req, res) => {
  try {
    const { role, status, sortBy, search } = req.query;

    // LÓGICA MEJORADA: La consulta ahora verifica si la suscripción está activa.
    let query = `
      SELECT 
        u.id, u.nombre, u.alias, u.email, u.rol, u.status, u.telefono, u.puntos, 
        to_char(u.fecha_registro, 'DD Mon YYYY') as fecha_registro_formateada,
        CASE 
          WHEN u.id_plan_suscripcion IS NOT NULL AND u.fecha_fin_suscripcion > NOW()
          THEN p.nombre_publico
          ELSE 'Plan Gratuito'
        END AS nombre_plan,
        to_char(u.fecha_fin_suscripcion, 'DD Mon YYYY') AS fecha_fin_suscripcion_formateada
      FROM usuarios u
      LEFT JOIN planes_suscripcion p ON u.id_plan_suscripcion = p.id
    `;

    const whereClauses = [];
    const queryParams = [];
    let paramIndex = 1;

    if (search) {
      whereClauses.push(`(u.nombre ILIKE $${paramIndex} OR u.email ILIKE $${paramIndex} OR u.alias ILIKE $${paramIndex})`);
      queryParams.push(`%${search}%`);
      paramIndex++;
    }
    if (role) {
      whereClauses.push(`u.rol = $${paramIndex++}`);
      queryParams.push(role);
    }
    if (status) {
      whereClauses.push(`u.status = $${paramIndex++}`);
      queryParams.push(status);
    }

    if (whereClauses.length > 0) {
      query += ' WHERE ' + whereClauses.join(' AND ');
    }

    let orderByClause = ' ORDER BY u.fecha_registro DESC';
    if (sortBy === 'oldest') {
      orderByClause = ' ORDER BY u.fecha_registro ASC';
    } else if (sortBy === 'name') {
        orderByClause = ' ORDER BY u.nombre ASC';
    }
    query += orderByClause;

    const result = await db.query(query, queryParams);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error en getAllUsers:", error);
    res.status(500).json({ message: 'Error al obtener la lista de usuarios.' });
  }
};

// Actualizar el rol de un usuario
const updateUserRole = async (req, res) => {
  const { id: targetUserId } = req.params;
  const { rol, adminPassword } = req.body;
  const adminId = req.user.userId; // Corregido para usar userId

  // --- MODIFICACIÓN CLAVE ---
  // Añadimos 'reportero' a la lista de roles válidos.
  if (!['ciudadano', 'lider_vecinal', 'admin', 'reportero'].includes(rol)) {
    return res.status(400).json({ message: 'Rol no válido.' });
  }

  // --- SECURITY CHECK ---
  // La lógica de seguridad para promover a 'admin' se mantiene.
  if (rol === 'admin') {
    if (!adminPassword) {
      return res.status(400).json({ message: 'Se requiere su contraseña para confirmar esta acción.' });
    }
    const adminResult = await db.query('SELECT password_hash FROM usuarios WHERE id = $1', [adminId]);
    const admin = adminResult.rows[0];
    const isMatch = await bcrypt.compare(adminPassword, admin.password_hash);

    if (!isMatch) {
      return res.status(403).json({ message: 'Su contraseña es incorrecta. Acción denegada.' });
    }
  }

  try {
    const query = 'UPDATE usuarios SET rol = $1 WHERE id = $2 RETURNING id, nombre, rol';
    const result = await db.query(query, [rol, targetUserId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Usuario no encontrado.' });
    }
    res.status(200).json({ message: 'Rol de usuario actualizado.', user: result.rows[0] });
  } catch (error) {
    res.status(500).json({ message: 'Error al actualizar el rol del usuario.' });
  }
};

const updateUserStatus = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  if (!['activo', 'suspendido'].includes(status)) {
    return res.status(400).json({ message: 'Estado no válido.' });
  }

  try {
    const query = 'UPDATE usuarios SET status = $1 WHERE id = $2 RETURNING id, nombre, status';
    const result = await db.query(query, [status, id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Usuario no encontrado.' });
    }
    res.status(200).json({ message: 'Estado de usuario actualizado.', user: result.rows[0] });
  } catch (error) {
    res.status(500).json({ message: 'Error al actualizar el estado del usuario.' });
  }
};

// Obtener todas las categorías oficiales
const getAllCategories = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM categorias ORDER BY orden ASC');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener categorías.' });
  }
};

// Obtener todas las sugerencias de categorías de los reportes
const getCategorySuggestions = async (req, res) => {
  try {
    const query = `
      SELECT 
        categoria_sugerida, 
        COUNT(*) as count, 
        MAX(fecha_creacion) as mas_reciente
      FROM reportes
      WHERE id_categoria = (SELECT id FROM categorias WHERE nombre = 'Otro')
        AND categoria_sugerida IS NOT NULL
        AND categoria_sugerida != ''
        -- THIS IS THE KEY FIX: Only select suggestions that are NOT IN the official categories list
        AND LOWER(categoria_sugerida) NOT IN (SELECT LOWER(nombre) FROM categorias)
      GROUP BY categoria_sugerida
      ORDER BY mas_reciente DESC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener sugerencias de categorías.' });
  }
};

// Crear/Aprobar una nueva categoría
const createCategory = async (req, res) => {
  const { nombre } = req.body;
  if (!nombre) {
    return res.status(400).json({ message: 'El nombre de la categoría es requerido.' });
  }

  try {
    const query = 'INSERT INTO categorias (nombre) VALUES ($1) RETURNING *';
    const result = await db.query(query, [nombre]);
    res.status(201).json({ message: 'Categoría creada exitosamente.', categoria: result.rows[0] });
  } catch (error) {
    // Código 23505 significa violación de unicidad (la categoría ya existe)
    if (error.code === '23505') {
      return res.status(409).json({ message: 'Esta categoría ya existe.' });
    }
    res.status(500).json({ message: 'Error al crear la categoría.' });
  }
};

const deleteCategory = async (req, res) => {
  const { id } = req.params;
  try {
    // Safety check to prevent deleting essential categories
    const categoryResult = await db.query('SELECT nombre FROM categorias WHERE id = $1', [id]);
    if (categoryResult.rows.length > 0 && categoryResult.rows[0].nombre === 'Otro') {
      return res.status(400).json({ message: 'La categoría "Otro" no se puede eliminar.' });
    }
    
    // Check if any reports are using this category
    const reportCountResult = await db.query('SELECT COUNT(*) FROM reportes WHERE id_categoria = $1', [id]);
    if (parseInt(reportCountResult.rows[0].count, 10) > 0) {
      return res.status(400).json({ message: 'No se puede eliminar la categoría porque está siendo usada por reportes existentes.' });
    }

    await db.query('DELETE FROM categorias WHERE id = $1', [id]);
    res.status(200).json({ message: 'Categoría eliminada exitosamente.' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar la categoría.' });
  }
};

// Obtener todos los comentarios reportados que están pendientes
const getReportedComments = async (req, res) => {
  try {
    const query = `
      SELECT 
        cr.id, 
        cr.motivo, 
        c.comentario, 
        u_reportado.alias as autor_comentario, 
        u_reportador.alias as reportado_por
      FROM comentario_reportes cr
      JOIN comentarios c ON cr.id_comentario = c.id
      JOIN usuarios u_reportado ON c.id_usuario = u_reportado.id
      JOIN usuarios u_reportador ON cr.id_reportador = u_reportador.id
      WHERE cr.estado = 'pendiente'
      ORDER BY cr.fecha_creacion ASC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener comentarios reportados.' });
  }
};

const resolveCommentReport = async (req, res) => {
  const { id } = req.params;
  const { action } = req.body;
  const adminId = req.user.id; // Asumimos que el admin está logueado

  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    const adminResult = await client.query('SELECT alias FROM usuarios WHERE id = $1', [adminId]);
    const adminAlias = adminResult.rows[0].alias;

    const reportResult = await client.query('SELECT c.comentario, cr.motivo FROM comentario_reportes cr JOIN comentarios c ON cr.id_comentario = c.id WHERE cr.id = $1', [id]);
    const { comentario, motivo } = reportResult.rows[0];

    if (action === 'eliminar_comentario') {
      const getCommentIdQuery = 'SELECT id_comentario FROM comentario_reportes WHERE id = $1';
      const commentIdResult = await client.query(getCommentIdQuery, [id]);
      await client.query('DELETE FROM comentarios WHERE id = $1', [commentIdResult.rows[0].id_comentario]);
    }

    await client.query("UPDATE comentario_reportes SET estado = 'resuelto' WHERE id = $1", [id]);
    
    // REGISTRAR EN EL LOG
    const logQuery = `INSERT INTO moderation_log (id_admin, admin_alias, accion, entidad_tipo, contenido_afectado, motivo_reporte) VALUES ($1, $2, $3, 'comentario', $4, $5)`;
    await client.query(logQuery, [adminId, adminAlias, action, comentario, motivo]);

    await client.query('COMMIT');
    res.status(200).json({ message: 'Acción de moderación completada.' });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error al resolver reporte de comentario:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};

// Get all user reports that are pending
const getReportedUsers = async (req, res) => {
  try {
    const query = `
      SELECT 
        ur.id, 
        ur.motivo, 
        u_reportado.id as id_usuario_reportado,
        u_reportado.nombre as usuario_reportado_nombre, -- Get real name
        u_reportado.email as usuario_reportado_email,  -- Get email
        u_reportador.alias as reportado_por
      FROM usuario_reportes ur
      JOIN usuarios u_reportado ON ur.id_usuario_reportado = u_reportado.id
      JOIN usuarios u_reportador ON ur.id_reportador = u_reportador.id
      WHERE ur.estado = 'pendiente'
      ORDER BY ur.fecha_creacion ASC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener usuarios reportados.' });
  }
};

const resolveUserReport = async (req, res) => {
  const { id } = req.params;
  const { action, userId } = req.body;
  const adminId = req.user.id;

  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    const adminResult = await client.query('SELECT alias FROM usuarios WHERE id = $1', [adminId]);
    const adminAlias = adminResult.rows[0].alias;

    const reportResult = await client.query('SELECT u.alias as user_alias, ur.motivo FROM usuario_reportes ur JOIN usuarios u ON ur.id_usuario_reportado = u.id WHERE ur.id = $1', [id]);
    const { user_alias, motivo } = reportResult.rows[0];
    
    if (action === 'suspender_usuario') {
      await client.query("UPDATE usuarios SET status = 'suspendido' WHERE id = $1", [userId]);
    }

    await client.query("UPDATE usuario_reportes SET estado = 'resuelto' WHERE id = $1", [id]);

    // REGISTRAR EN EL LOG
    const logQuery = `INSERT INTO moderation_log (id_admin, admin_alias, accion, entidad_tipo, contenido_afectado, motivo_reporte) VALUES ($1, $2, $3, 'usuario', $4, $5)`;
    await client.query(logQuery, [adminId, adminAlias, action, user_alias, motivo]);

    await client.query('COMMIT');
    res.status(200).json({ message: 'Acción de moderación de usuario completada.' });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error al resolver reporte de usuario:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};

const getModerationHistory = async (req, res) => {
    try {
        const result = await db.query('SELECT * FROM moderation_log ORDER BY fecha_accion DESC');
        res.status(200).json(result.rows);
    } catch (error) {
        res.status(500).json({ message: 'Error al obtener el historial.' });
    }
};

const getAllAdminReports = async (req, res) => {
  try {
    const { search, status, categoryId, sortBy, page = 1, suggestedOnly } = req.query;
    const limit = 10; // Aumentar el límite para el panel web
    const offset = (page - 1) * limit;

    let query = `
      SELECT 
        r.id, r.titulo, r.foto_url, r.distrito, r.urgencia, r.tags,
        r.codigo_reporte,
        r.apoyos_pendientes,
        to_char(r.hora_incidente, 'HH24:MI') as hora_incidente,
        c.nombre as categoria, 
        r.categoria_sugerida,
        r.es_anonimo,
        u.nombre as autor_nombre,
        u.alias as autor_alias,
        u.email as autor_email,
        l.nombre as lider_verificador_nombre,
        l.alias as lider_verificador_alias,
        l.email as lider_verificador_email,
        r.estado, 
        to_char(r.fecha_creacion, 'DD Mon YYYY, HH24:MI') as fecha_creacion,
        r.descripcion, 
        r.referencia_ubicacion,
        r.impacto,
        ST_AsGeoJSON(r.location) as location,
        -- AÑADIMOS EL CAMPO PARA SABER SI ES PRIORITARIO
        CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario
      FROM reportes r
      LEFT JOIN usuarios u ON r.id_usuario = u.id
      LEFT JOIN categorias c ON r.id_categoria = c.id
      LEFT JOIN usuarios l ON r.id_lider_verificador = l.id
      -- Hacemos un LEFT JOIN con la tabla de reportes prioritarios
      LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
    `;
    
    const whereClauses = [];
    const queryParams = [];
    let paramIndex = 1;

    if (search) {
      whereClauses.push(`(r.titulo ILIKE $${paramIndex} OR u.alias ILIKE $${paramIndex} OR u.nombre ILIKE $${paramIndex})`);
      queryParams.push(`%${search}%`);
      paramIndex++;
    }
    if (status) {
      whereClauses.push(`r.estado = $${paramIndex++}`);
      queryParams.push(status);
    }
    if (categoryId) {
      whereClauses.push(`r.id_categoria = $${paramIndex++}`);
      queryParams.push(categoryId);
    }

    if (suggestedOnly === 'true') {
        whereClauses.push(`r.categoria_sugerida IS NOT NULL AND r.categoria_sugerida != ''`);
    }

    if (whereClauses.length > 0) {
      query += ' WHERE ' + whereClauses.join(' AND ');
    }

    query += ` ORDER BY r.fecha_creacion ${sortBy === 'oldest' ? 'ASC' : 'DESC'}`;
    query += ` LIMIT $${paramIndex++} OFFSET $${paramIndex++}`;
    queryParams.push(limit, offset);
    
    const result = await db.query(query, queryParams);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching admin reports:", error);
    res.status(500).json({ message: 'Error al obtener los reportes.' });
  }
};

const updateReportVisibility = async (req, res) => {
  const { id } = req.params;
  const { currentState } = req.body;
  
  // Toggle between 'verificado' (public) and 'oculto' (private/hidden)
  const newState = currentState === 'verificado' ? 'oculto' : 'verificado';
  
  try {
    await db.query("UPDATE reportes SET estado = $1, fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = $2 AND estado IN ('verificado', 'oculto')", [newState, id]);
    res.status(200).json({ message: `Reporte ahora está ${newState}` });
  } catch (error) {
    res.status(500).json({ message: 'Error al cambiar la visibilidad del reporte.' });
  }
};


const getReviewRequests = async (req, res) => {
  try {
    const query = `
      SELECT 
        sr.id, 
        r.titulo, 
        r.codigo_reporte,
        to_char(r.fecha_creacion, 'DD Mon YYYY') as fecha_reporte,
        u.alias as lider_alias,
        u.nombre as lider_nombre
      FROM solicitudes_revision sr
      JOIN reportes r ON sr.id_reporte = r.id
      JOIN usuarios u ON sr.id_lider = u.id
      WHERE sr.estado = 'pendiente'
      ORDER BY sr.fecha_solicitud ASC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener solicitudes de revisión.' });
  }
};

const resolveReviewRequest = async (req, res) => {
  const { id } = req.params; // This is now the ID from 'solicitudes_revision'
  const { action } = req.body;
  try {
    const getReportIdQuery = 'SELECT id_reporte FROM solicitudes_revision WHERE id = $1';
    const reportIdResult = await db.query(getReportIdQuery, [id]);
    const id_reporte = reportIdResult.rows[0].id_reporte;

    if (action === 'aprobar') {
      await db.query("UPDATE reportes SET estado = 'pendiente_verificacion' WHERE id = $1", [id_reporte]);
      await db.query("UPDATE solicitudes_revision SET estado = 'aprobada' WHERE id = $1", [id]);
    } else { // desestimar
      await db.query("UPDATE solicitudes_revision SET estado = 'desestimada' WHERE id = $1", [id]);
    }
    res.status(200).json({ message: 'Solicitud de revisión resuelta.' });
  } catch (error) {
    res.status(500).json({ message: 'Error al resolver la solicitud.' });
  }
};

const adminDeleteReport = async (req, res) => {
    const { id } = req.params;
    try {
        await db.query('DELETE FROM reportes WHERE id = $1', [id]);
        res.status(200).json({ message: 'Reporte eliminado permanentemente.' });
    } catch (error) {
        res.status(500).json({ message: 'Error al eliminar el reporte.' });
    }
};

const getReportsByDay = async (req, res) => {
  try {
    // This PostgreSQL query generates a series of the last 7 days
    // and counts the reports for each day.
    const query = `
      SELECT 
        to_char(d.day, 'YYYY-MM-DD') AS date,
        COUNT(r.id) as count
      FROM 
        generate_series(
          current_date - interval '6 days', 
          current_date, 
          '1 day'
        ) AS d(day)
      LEFT JOIN 
        reportes r ON to_char(r.fecha_creacion, 'YYYY-MM-DD') = to_char(d.day, 'YYYY-MM-DD')
      GROUP BY 
        d.day
      ORDER BY 
        d.day ASC;
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching reports by day:", error);
    res.status(500).json({ message: 'Error al obtener datos del gráfico.' });
  }
};

const getHeatmapData = async (req, res) => {
  try {
    // Select the latitude (Y) and longitude (X) of all verified reports
    const query = `
      SELECT 
        ST_Y(location) as lat, 
        ST_X(location) as lon 
      FROM reportes 
      WHERE estado = 'verificado'
    `;
    const result = await db.query(query);
    // The heatmap library expects an array of [lat, lon, intensity]
    // We'll give every report an intensity of 1.
    const heatmapData = result.rows.map(r => [r.lat, r.lon, 1]);
    res.status(200).json(heatmapData);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener datos del mapa de calor.' });
  }
};

const runPredictionSimulation = async (req, res) => {
  const { categoryName, increasePercent } = req.body;

  // This is a simplified, rule-based prediction model for demonstration.
  // A real-world version would use a more complex machine learning model.
  let prediction = {
    title: "Predicción Basada en Simulación",
    text: "No se encontró una correlación significativa para esta categoría.",
    confidence: "Baja"
  };

  if (categoryName === 'Falla de Alumbrado') {
    const predictedCrimeIncrease = (increasePercent * 0.30).toFixed(0); // 30% correlation
    prediction.text = `Un aumento del ${increasePercent}% en fallas de alumbrado podría correlacionarse con un aumento de aproximadamente ${predictedCrimeIncrease}% en reportes de "Delito" en las próximas 2-4 semanas.`;
    prediction.confidence = "Media";
  }

  if (categoryName === 'Basura') {
    const predictedHealthIncrease = (increasePercent * 0.15).toFixed(0); // 15% correlation
    prediction.text = `Un aumento del ${increasePercent}% en reportes de basura podría llevar a un aumento del ${predictedHealthIncrease}% en quejas de salud pública o plagas en las próximas 3-6 semanas.`;
    prediction.confidence = "Baja";
  }
  
  if (categoryName === 'Bache') {
    const predictedAccidentIncrease = (increasePercent * 0.45).toFixed(0); // 45% correlation
    prediction.text = `Un aumento del ${increasePercent}% en reportes de baches podría estar correlacionado con un aumento del ${predictedAccidentIncrease}% en accidentes de tráfico menores en la misma zona.`;
    prediction.confidence = "Media";
  }

  res.status(200).json(prediction);
};

const getSimulatedSmsLog = async (req, res) => {
  try {
    const { search, page = 1 } = req.query;
    const limit = 20;
    const offset = (page - 1) * limit;

    let query = `
      SELECT 
        log.id, log.contacto_telefono, log.mensaje, log.fecha_envio,
        u.alias as usuario_sos_alias
      FROM simulated_sms_log log
      LEFT JOIN usuarios u ON log.id_usuario_sos = u.id
    `;
    const whereClauses = [];
    const queryParams = [];
    let paramIndex = 1;

    if (search) {
      whereClauses.push(`(log.mensaje ILIKE $${paramIndex} OR log.contacto_telefono ILIKE $${paramIndex} OR u.alias ILIKE $${paramIndex})`);
      queryParams.push(`%${search}%`);
      paramIndex++;
    }

    if (whereClauses.length > 0) {
      query += ' WHERE ' + whereClauses.join(' AND ');
    }

    query += ` ORDER BY log.fecha_envio DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`;
    queryParams.push(limit, offset);

    const result = await db.query(query, queryParams);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener el registro de SMS.' });
  }
};


// REEMPLAZA la función getNotificationHistory con esta versión mejorada
const getNotificationHistory = async (req, res) => {
  try {
    const { search, page = 1 } = req.query;
    const limit = 20;
    const offset = (page - 1) * limit;

    let query = `
      SELECT 
        n.id, n.id_usuario_receptor, n.titulo, n.cuerpo, n.leido, n.fecha_envio, 
        u.alias as receptor, u.email as receptor_email
      FROM notificaciones n
      JOIN usuarios u ON n.id_usuario_receptor = u.id
    `;
    const whereClauses = [];
    const queryParams = [];
    let paramIndex = 1;

    if (search) {
      whereClauses.push(`(n.titulo ILIKE $${paramIndex} OR n.cuerpo ILIKE $${paramIndex} OR u.alias ILIKE $${paramIndex})`);
      queryParams.push(`%${search}%`);
      paramIndex++;
    }

    if (whereClauses.length > 0) {
      query += ' WHERE ' + whereClauses.join(' AND ');
    }

    query += ` ORDER BY n.fecha_envio DESC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`;
    queryParams.push(limit, offset);

    const result = await db.query(query, queryParams);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener historial de notificaciones.' });
  }
};

const sendNotification = async (req, res) => {
  const { userIds, title, body } = req.body;
  if (!userIds || !userIds.length || !title || !body) {
    return res.status(400).json({ message: 'Se requieren IDs de usuario, título y cuerpo del mensaje.' });
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    const io = req.app.get('socketio');

    for (const userId of userIds) {
      const payload = JSON.stringify({ type: 'alerts_screen', id: reporte.id });
      // 1. Guardar la notificación en la base de datos para el historial.
      const query = 'INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo, payload) VALUES ($1, $2, $3)';
      await client.query(query, [userId, title, body, payload]);

      // 2. Enviar la notificación en tiempo real a través del socket.
      socketNotificationService.sendNotification(io, userId, { title, body, payload});
    }
    
    await client.query('COMMIT');
    res.status(200).json({ message: `${userIds.length} notificación(es) enviada(s) exitosamente.` });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error sending notification:", error);
    res.status(500).json({ message: 'Error al enviar la notificación.' });
  } finally {
    client.release();
  }
};

const deleteNotification = async (req, res) => {
    const { id } = req.params;
    try {
        await db.query('DELETE FROM notificaciones WHERE id = $1', [id]);
        res.status(200).json({ message: 'Notificación eliminada.' });
    } catch (error) {
        res.status(500).json({ message: 'Error al eliminar notificación.' });
    }
};

const getLatestPendingReports = async (req, res) => {
  try {
    const query = `
      SELECT 
        r.id, r.titulo, r.descripcion, r.es_anonimo, r.foto_url, r.estado, -- Added r.estado
        r.urgencia, r.distrito, r.referencia_ubicacion, r.tags, r.impacto, r.codigo_reporte,
        to_char(r.hora_incidente, 'HH24:MI') as hora_incidente,
        c.nombre as categoria, 
        u.nombre as autor_nombre,
        u.email as autor_email,
        u.telefono as autor_telefono,
        u.rol as autor_rol, -- Added u.rol
        to_char(r.fecha_creacion, 'DD Mon YYYY, HH24:MI') as fecha_creacion,
        ST_AsGeoJSON(r.location) as location
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      JOIN usuarios u ON r.id_usuario = u.id
      WHERE r.estado = 'pendiente_verificacion'
      ORDER BY r.fecha_creacion DESC
      LIMIT 5
    `;
    const result = await db.query(query);
    
    const reports = result.rows.map(row => ({
      ...row,
      location: row.location ? JSON.parse(row.location) : null,
    }));

    res.status(200).json(reports);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener últimos reportes.' });
  }
};

// Admin-specific moderation functions (as provided previously, ensuring they exist)
const adminAprobarReporte = async (req, res) => {
  const { id } = req.params;
  const adminId = req.user.id;
  const client = await db.getClient();

  try {
    await client.query('BEGIN');
    
    // La lógica es casi idéntica a la del líder, pero asignamos el ID del admin
    const result = await client.query("UPDATE reportes SET estado = 'verificado', fecha_actualizacion = CURRENT_TIMESTAMP, id_lider_verificador = $1 WHERE id = $2 RETURNING *", [adminId, id]);
    
    if (result.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ message: 'Reporte no encontrado.' });
    }
    
    const reporteAprobado = result.rows[0];
    const io = req.app.get('socketio');
    
    // --- LÓGICA AÑADIDA PARA ALERTAS PERSONALIZADAS ---
    const reporteCompletoResult = await client.query(`
      SELECT r.*, c.nombre as categoria, ST_AsGeoJSON(r.location) as location 
      FROM reportes r JOIN categorias c ON r.id_categoria = c.id WHERE r.id = $1
    `, [reporteAprobado.id]);

    if (reporteCompletoResult.rows.length > 0) {
        const reporteCompleto = reporteCompletoResult.rows[0];
        reporteCompleto.location = JSON.parse(reporteCompleto.location);

        // Llamar al servicio de notificación de zonas seguras
        await servicioNotificacionesZonas.verificarReporteEnZonas(io, reporteCompleto);
    }
    // --- FIN DE LA LÓGICA AÑADIDA ---

    await client.query('COMMIT');
    res.status(200).json({ message: 'Reporte aprobado por administrador.', report: result.rows[0] });
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error in adminAprobarReporte:', error);
    res.status(500).json({ message: 'Error al aprobar el reporte.', error: error.message });
  } finally {
    client.release();
  }
};

const adminRechazarReporte = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await db.query("UPDATE reportes SET estado = 'rechazado', fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *", [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Reporte no encontrado.' });
    }
    res.status(200).json({ message: 'Reporte rechazado.', report: result.rows[0] });
  } catch (error) {
    console.error('Error in adminRechazarReporte:', error);
    res.status(500).json({ message: 'Error al rechazar el reporte.', error: error.message });
  }
};

const getSosDashboardData = async (req, res) => {
  try {
    // 1. Get all alerts, with user info, ordered by most recent
    const alertsQuery = `
      SELECT sa.*, 
             u.alias, u.nombre, u.email, u.telefono, u.rol
      FROM sos_alerts sa
      JOIN usuarios u ON sa.id_usuario = u.id
      ORDER BY sa.fecha_inicio DESC
    `;
    const alertsResult = await db.query(alertsQuery);
    let alerts = alertsResult.rows;

    // 2. Find the most recent ACTIVE alert
    const latestActiveAlert = alerts.find(a => a.estado === 'activo');

    // 3. If an active alert exists, fetch its full location history
    if (latestActiveAlert) {
      const historyQuery = `
        SELECT ST_Y(location) as lat, ST_X(location) as lon
        FROM sos_location_updates
        WHERE id_alerta_sos = $1
        ORDER BY fecha_registro ASC
      `;
      const historyResult = await db.query(historyQuery, [latestActiveAlert.id]);
      latestActiveAlert.locationHistory = historyResult.rows;
    }

    res.status(200).json(alerts);
  } catch (error) {
    console.error("Error fetching SOS dashboard data:", error);
    res.status(500).json({ message: 'Error al obtener datos del panel SOS.' });
  }
};

const getReportCoordinates = async (req, res) => {
  try {
    const query = `
      SELECT ST_Y(location) as lat, ST_X(location) as lon 
      FROM reportes 
      WHERE estado = 'verificado' AND location IS NOT NULL
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener coordenadas de reportes.' });
  }
};

const buildDateFilter = (startDate, endDate, params, dateColumn = 'r.fecha_creacion') => {
  if (startDate && endDate) {
    params.push(startDate);
    params.push(endDate);
    return `AND ${dateColumn} BETWEEN $${params.length - 1} AND $${params.length}`;
  }
  return '';
};

const getReportsByCategory = async (req, res) => {
  const { startDate, endDate } = req.query;
  const params = [];
  const dateFilter = buildDateFilter(startDate, endDate, params);

  try {
    const query = `
      SELECT c.nombre as name, COUNT(r.id) as value
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      WHERE 1=1 ${dateFilter}
      GROUP BY c.nombre
      ORDER BY value DESC
    `;
    const result = await db.query(query, params);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getReportsByCategory:', error);
    res.status(500).json({ message: 'Error al obtener reportes por categoría.' });
  }
};

const getReportsByStatus = async (req, res) => {
  const { startDate, endDate } = req.query;
  const params = [];
  const dateFilter = buildDateFilter(startDate, endDate, params);
  
  try {
    const query = `
      SELECT estado as name, COUNT(id) as value 
      FROM reportes r 
      WHERE 1=1 ${dateFilter} 
      GROUP BY estado
    `;
    const result = await db.query(query, params);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getReportsByStatus:', error);
    res.status(500).json({ message: 'Error al obtener reportes por estado.' });
  }
};

const getReportsByMonth = async (req, res) => {
  try {
    const query = `
      SELECT to_char(fecha_creacion, 'YYYY-MM') as name, COUNT(id) as value
      FROM reportes
      GROUP BY to_char(fecha_creacion, 'YYYY-MM')
      ORDER BY name ASC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getReportsByMonth:', error);
    res.status(500).json({ message: 'Error al obtener reportes por mes.' });
  }
};

const getUsersByStatus = async (req, res) => {
  try {
    const query = "SELECT status as name, COUNT(id) as value FROM usuarios GROUP BY status";
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getUsersByStatus:', error);
    res.status(500).json({ message: 'Error al obtener usuarios por estado.' });
  }
};

const getAverageVerificationTime = async (req, res) => {
    const { startDate, endDate } = req.query;
    const params = [];
    // Nota: El alias 'r' es crucial para que la columna de fecha se identifique correctamente.
    const dateFilter = buildDateFilter(startDate, endDate, params, 'r.fecha_creacion');

    try {
        const query = `
            SELECT AVG(EXTRACT(EPOCH FROM (r.fecha_actualizacion - r.fecha_creacion))) as avg_seconds
            FROM reportes r
            WHERE r.estado IN ('verificado', 'rechazado') 
            AND r.fecha_actualizacion IS NOT NULL 
            AND r.id_lider_verificador IS NOT NULL
            ${dateFilter}
        `;
        const result = await db.query(query, params);
        
        const avg_seconds = result.rows[0].avg_seconds;

        if (avg_seconds === null || isNaN(avg_seconds)) {
            return res.status(200).json({ avg_time_formatted: 'N/A' });
        }
        
        // Convertir el promedio de segundos a un formato legible
        const totalMinutes = Math.floor(avg_seconds / 60);
        const hours = Math.floor(totalMinutes / 60);
        const minutes = totalMinutes % 60;
        
        const formatted_avg_time = `${hours}h ${minutes}m`;

        res.status(200).json({ avg_time_formatted: formatted_avg_time });

    } catch (error) {
        console.error('Error en getAverageVerificationTime:', error);
        res.status(500).json({ message: 'Error al calcular el tiempo de verificación.' });
    }
};

// **CORREGIDO Y MEJORADO**: Se estandarizó el filtro para usar fecha_creacion para consistencia.
const getLeaderPerformance = async (req, res) => {
  const { startDate, endDate } = req.query;
  const params = [];
  // Se cambió el filtro a 'fecha_creacion' para que sea consistente con los otros gráficos.
  const dateFilter = buildDateFilter(startDate, endDate, params, 'r.fecha_creacion');

  try {
    const query = `
      SELECT u.alias as name, COUNT(r.id) as value
      FROM reportes r
      JOIN usuarios u ON r.id_lider_verificador = u.id
      WHERE u.rol = 'lider_vecinal' AND r.id_lider_verificador IS NOT NULL ${dateFilter}
      GROUP BY u.alias
      ORDER BY value DESC
      LIMIT 10
    `;
    const result = await db.query(query, params);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getLeaderPerformance:', error);
    res.status(500).json({ message: 'Error al obtener rendimiento de líderes.' });
  }
};

const getReportsByDistrict = async (req, res) => {
    const { startDate, endDate } = req.query;
    const params = [];
    const dateFilter = buildDateFilter(startDate, endDate, params);

    try {
        const query = `
        SELECT distrito as name, COUNT(id) as value
        FROM reportes r
        WHERE distrito IS NOT NULL AND distrito <> '' ${dateFilter}
        GROUP BY distrito
        ORDER BY value DESC
        `;
        const result = await db.query(query, params);
        res.status(200).json(result.rows);
    } catch (error) {
        console.error('Error en getReportsByDistrict:', error);
        res.status(500).json({ message: 'Error al obtener reportes por distrito.' });
    }
};

const getReportsByHour = async (req, res) => {
  const { startDate, endDate } = req.query;
  const params = [];
  const dateFilter = buildDateFilter(startDate, endDate, params);

  let dateExpression = "to_char(r.fecha_creacion, 'HH24:00')"; // Por defecto, agrupar por hora
  let orderBy = "name ASC";

  if (startDate && endDate) {
    const start = new Date(startDate);
    const end = new Date(endDate);
    // Calcula la diferencia en días. Se suma 1 para incluir el día final.
    const diffDays = ((end - start) / (1000 * 60 * 60 * 24)) + 1;
    
    if (diffDays > 1 && diffDays <= 7) {
      // Si el rango es de más de un día hasta una semana, agrupa por día de la semana
      dateExpression = "to_char(r.fecha_creacion, 'ID-Day')"; // '1-Monday', '2-Tuesday'
    } else if (diffDays > 7) {
      // Si el rango es mayor a una semana, agrupa por fecha
      dateExpression = "to_char(r.fecha_creacion, 'YYYY-MM-DD')";
    }
  }
  
  try {
    const query = `
      SELECT 
        ${dateExpression} as name, 
        COUNT(r.id) as value
      FROM reportes r
      WHERE 1=1 ${dateFilter}
      GROUP BY name
      ORDER BY name ASC
    `;
    const result = await db.query(query, params);
    
    // Limpia la etiqueta del día de la semana si se usó (ej. '1-Monday' -> 'Monday')
    const formattedResult = result.rows.map(row => {
        const nameParts = row.name.split('-');
        return { ...row, name: nameParts.length > 1 ? nameParts.slice(1).join('-').trim() : row.name };
    });

    res.status(200).json(formattedResult);
  } catch (error) {
    console.error('Error en getReportsByHour:', error);
    res.status(500).json({ message: 'Error al obtener reportes por hora.' });
  }
};

const getAverageResolutionTime = async (req, res) => {
  try {
    const query = `
      SELECT AVG(fecha_actualizacion - fecha_creacion) as avg_time
      FROM reportes
      WHERE estado IN ('verificado', 'rechazado') AND fecha_actualizacion IS NOT NULL
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error al calcular el tiempo de resolución.' });
  }
};

// Obtener detalles completos de un usuario específico (para admin)
const getUserDetails = async (req, res) => {
  const { id } = req.params; // ID del usuario a consultar

  try {
    // 1. Obtener datos básicos del usuario
    const userQuery = 'SELECT id, nombre, alias, email, puntos, telefono, to_char(fecha_registro, \'DD Mon YYYY\') as fecha_registro_formateada FROM usuarios WHERE id = $1';
    const userResult = await db.query(userQuery, [id]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'Usuario no encontrado.' });
    }
    const userDetails = userResult.rows[0];

    // 2. Obtener las insignias del usuario
    const insigniasQuery = `
      SELECT i.nombre, i.descripcion, i.icono_url 
      FROM Insignias i
      JOIN Usuario_Insignias ui ON i.id = ui.id_insignia
      WHERE ui.id_usuario = $1
      ORDER BY i.nombre
    `;
    const insigniasResult = await db.query(insigniasQuery, [id]);
    userDetails.insignias = insigniasResult.rows;

    // 3. Obtener los 5 reportes más recientes del usuario
    const reportesQuery = `
      SELECT codigo_reporte, titulo, estado, urgencia, to_char(fecha_creacion, 'DD Mon YYYY') as fecha
      FROM reportes 
      WHERE id_usuario = $1
      ORDER BY fecha_creacion DESC
      LIMIT 5
    `;
    const reportesResult = await db.query(reportesQuery, [id]);
    userDetails.reportes = reportesResult.rows;

    res.status(200).json(userDetails);
  } catch (error) {
    console.error('Error al obtener detalles del usuario:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const adminSetReportToPending = async (req, res) => {
  const { id } = req.params;
  try {
    const result = await db.query("UPDATE reportes SET estado = 'pendiente_verificacion', fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *", [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Reporte no encontrado.' });
    }
    res.status(200).json({ message: 'Reporte establecido como pendiente.', report: result.rows[0] });
  } catch (error) {
    console.error('Error in adminSetReportToPending:', error);
    res.status(500).json({ message: 'Error al actualizar el reporte.', error: error.message });
  }
};

const getCategoriesWithStats = async (req, res) => {
  try {
    // MEJORA: La consulta ahora usa agregación condicional para contar reportes por estado
    const query = `
      SELECT 
        c.id, 
        c.nombre, 
        c.icono_url, 
        c.orden,
        COUNT(r.id) FILTER (WHERE r.estado = 'verificado') as reportes_activos,
        COUNT(r.id) FILTER (WHERE r.estado = 'pendiente_verificacion') as reportes_pendientes,
        COUNT(r.id) FILTER (WHERE r.estado = 'rechazado') as reportes_rechazados
      FROM categorias c
      LEFT JOIN reportes r ON c.id = r.id_categoria
      GROUP BY c.id
      ORDER BY c.orden ASC, c.nombre ASC;
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching categories with stats:", error);
    res.status(500).json({ message: 'Error al obtener categorías.' });
  }
};

const reorderCategories = async (req, res) => {
  const { orderedIds } = req.body; // Se espera un array de IDs en el nuevo orden
  if (!Array.isArray(orderedIds)) {
    return res.status(400).json({ message: 'Se esperaba un array de IDs de categorías.' });
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    // Usamos Promise.all para ejecutar todas las actualizaciones en paralelo
    await Promise.all(orderedIds.map((categoryId, index) => {
      const newOrder = index + 1;
      return client.query('UPDATE categorias SET orden = $1 WHERE id = $2', [newOrder, categoryId]);
    }));
    await client.query('COMMIT');
    res.status(200).json({ message: 'Categorías reordenadas exitosamente.' });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error reordering categories:", error);
    res.status(500).json({ message: 'Error al reordenar las categorías.' });
  } finally {
    client.release();
  }
};

// NUEVA FUNCIÓN PARA FUSIONAR CATEGORÍAS
const mergeCategorySuggestion = async (req, res) => {
  const { sourceSuggestionName, targetCategoryId } = req.body;
  if (!sourceSuggestionName || !targetCategoryId) {
    return res.status(400).json({ message: 'Faltan parámetros para la fusión.' });
  }
  
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    // 1. Encontrar el ID de la categoría "Otro"
    const otroCategoryResult = await client.query("SELECT id FROM categorias WHERE nombre = 'Otro'");
    if (otroCategoryResult.rows.length === 0) {
      throw new Error('La categoría "Otro" no fue encontrada.');
    }
    const otroCategoryId = otroCategoryResult.rows[0].id;

    // 2. Actualizar todos los reportes que coincidan con la sugerencia
    const updateResult = await client.query(
      `UPDATE reportes 
       SET id_categoria = $1, categoria_sugerida = NULL 
       WHERE id_categoria = $2 AND categoria_sugerida = $3`,
      [targetCategoryId, otroCategoryId, sourceSuggestionName]
    );

    await client.query('COMMIT');
    res.status(200).json({ message: `Sugerencia '${sourceSuggestionName}' fusionada exitosamente. ${updateResult.rowCount} reportes actualizados.` });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error merging category:", error);
    res.status(500).json({ message: 'Error al fusionar la categoría.' });
  } finally {
    client.release();
  }
};

const getSolicitudesRol = async (req, res) => {
  try {
    const query = `
      SELECT 
        s.id, s.id_usuario, s.estado, 
        to_char(s.fecha_solicitud, 'DD Mon YYYY, HH24:MI') as fecha,
        u.nombre, u.alias, u.email,
        s.motivacion, 
        s.zona_propuesta
      FROM solicitudes_rol s
      JOIN usuarios u ON s.id_usuario = u.id
      WHERE s.estado = 'pendiente'
      ORDER BY s.fecha_solicitud ASC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error al obtener solicitudes de rol:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const resolverSolicitudRol = async (req, res) => {
  const { id } = req.params;
  const { accion } = req.body; // 'aprobar' o 'rechazar'

  if (!['aprobar', 'rechazar'].includes(accion)) {
    return res.status(400).json({ message: 'Acción no válida.' });
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const solicitudResult = await client.query('SELECT id_usuario FROM solicitudes_rol WHERE id = $1', [id]);
    if (solicitudResult.rows.length === 0) {
      throw new Error('Solicitud no encontrada.');
    }
    const id_usuario = solicitudResult.rows[0].id_usuario;

    if (accion === 'aprobar') {
      // 1. Promover al usuario a 'lider_vecinal'
      await client.query("UPDATE usuarios SET rol = 'lider_vecinal' WHERE id = $1", [id_usuario]);
      // 2. Actualizar el estado de la solicitud
      await client.query("UPDATE solicitudes_rol SET estado = 'aprobado' WHERE id = $1", [id]);
    } else { // rechazar
      await client.query("UPDATE solicitudes_rol SET estado = 'rechazado' WHERE id = $1", [id]);
    }

    await client.query('COMMIT');
    res.status(200).json({ message: `Solicitud ${accion === 'aprobar' ? 'aprobada' : 'rechazada'} exitosamente.` });
  } catch (error) {
    await client.query('ROLLBACK');
    res.status(500).json({ message: 'Error al resolver la solicitud.' });
  } finally {
    client.release();
  }
};

const asignarZonasLider = async (req, res) => {
    const { id: id_lider } = req.params;
    const { distritos } = req.body; 

    if (!Array.isArray(distritos) || distritos.length === 0) {
        return res.status(400).json({ message: 'Se requiere un array de distritos (puede ser ["*"] para todas).' });
    }
    const zonasParaInsertar = distritos.includes('*') ? ['*'] : distritos;

    const client = await db.getClient();
    try {
        await client.query('BEGIN');
        const userResult = await client.query("SELECT rol FROM usuarios WHERE id = $1", [id_lider]);
        if (userResult.rows.length === 0 || userResult.rows[0].rol !== 'lider_vecinal') {
            await client.query('ROLLBACK');
            return res.status(404).json({ message: 'Usuario no encontrado o no es un líder vecinal.' });
        }
        await client.query("DELETE FROM lider_zonas_asignadas WHERE id_usuario = $1", [id_lider]);
        const insertPromises = zonasParaInsertar.map(distrito => {
            return client.query("INSERT INTO lider_zonas_asignadas (id_usuario, nombre_distrito) VALUES ($1, $2)", [id_lider, distrito]);
        });
        await Promise.all(insertPromises);
        await client.query('COMMIT');
        res.status(200).json({ message: `Zonas asignadas correctamente al líder ${id_lider}.` });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error al asignar zonas al líder:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    } finally {
        client.release();
    }
};

const getZonasAsignadas = async (req, res) => {
    const { id: id_lider } = req.params;
    try {
        const query = "SELECT nombre_distrito FROM lider_zonas_asignadas WHERE id_usuario = $1";
        const result = await db.query(query, [id_lider]);
        res.status(200).json(result.rows.map(row => row.nombre_distrito));
    } catch (error) {
        console.error('Error al obtener zonas asignadas:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

module.exports = {
  login,
  getDashboardStats,
  getAllUsers,
  updateUserRole,
  updateUserStatus,
  getAllCategories,
  getCategorySuggestions,
  createCategory,
  deleteCategory,
  getReportedComments,
  resolveCommentReport,
  getReportedUsers,
  resolveUserReport,
  getAllAdminReports,
  updateReportVisibility,
  getReviewRequests,
  resolveReviewRequest,
  adminDeleteReport,
  getReportsByDay,
  sendNotification,
  getHeatmapData,
  runPredictionSimulation,
  getSimulatedSmsLog,
  getNotificationHistory,
  deleteNotification,
  getLatestPendingReports,
  adminAprobarReporte,
  adminRechazarReporte,
  adminSetReportToPending, 
  getSosDashboardData,
  getReportCoordinates,
  getReportsByCategory,
  getReportsByStatus,
  getReportsByMonth,
  getUsersByStatus,
  getAverageResolutionTime,
  getLeaderPerformance,
  getAverageVerificationTime,
  getReportsByDistrict,
  getReportsByHour,
  getUserDetails,
  getCategoriesWithStats,
  reorderCategories,
  mergeCategorySuggestion,
  getModerationHistory,
  getSolicitudesRol,
  resolverSolicitudRol,
  asignarZonasLider,
  getZonasAsignadas,
};*/