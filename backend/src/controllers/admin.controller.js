const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const fetch = require('node-fetch');

const login = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email y contraseña son requeridos.' });
  }

  try {
    // Buscamos un usuario que coincida Y tenga el rol de 'admin'
    const userResult = await db.query("SELECT * FROM Usuarios WHERE email = $1 AND rol = 'admin'", [email]);
    
    if (userResult.rows.length === 0) {
      return res.status(403).json({ message: 'Acceso denegado. Credenciales incorrectas o sin privilegios de administrador.' });
    }
    
    const user = userResult.rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(403).json({ message: 'Acceso denegado. Credenciales incorrectas o sin privilegios de administrador.' });
    }

    const payload = {
      user: {
        id: user.id,
        rol: user.rol
      }
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '8h' }, // Sesión de admin más corta
      (error, token) => {
        if (error) throw error;
        res.status(200).json({ token });
      }
    );
  } catch (error) {
    console.error('Error en el login de admin:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
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
    // Add "telefono" to the SELECT statement
    const query = "SELECT id, nombre, alias, email, rol, status, telefono, to_char(fecha_registro, 'DD Mon YYYY') as fecha_registro FROM usuarios ORDER BY id ASC";
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener la lista de usuarios.' });
  }
};
// Actualizar el rol de un usuario
const updateUserRole = async (req, res) => {
  console.log('--- DEBUG: Recibido en updateUserRole ---');
  console.log('Request Body:', req.body);
  console.log('------------------------------------');

  const { id: targetUserId } = req.params;
  const { rol, adminPassword } = req.body;
  const adminId = req.user.id;

  if (!['ciudadano', 'lider_vecinal', 'admin'].includes(rol)) {
    return res.status(400).json({ message: 'Rol no válido.' });
  }

  // --- SECURITY CHECK ---
  if (rol === 'admin') {
    if (!adminPassword) {
      return res.status(400).json({ message: 'Se requiere su contraseña para confirmar esta acción.' });
    }
    // Verify the logged-in admin's password
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
    const result = await db.query('SELECT * FROM categorias ORDER BY nombre ASC');
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

// Resolver un reporte de comentario (desestimar o eliminar)
const resolveCommentReport = async (req, res) => {
  const { id } = req.params; // ID del reporte de comentario (de la tabla comentario_reportes)
  const { action } = req.body; // 'desestimar' o 'eliminar_comentario'

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    if (action === 'eliminar_comentario') {
      // Primero obtenemos el ID del comentario original
      const getCommentIdQuery = 'SELECT id_comentario FROM comentario_reportes WHERE id = $1';
      const commentIdResult = await client.query(getCommentIdQuery, [id]);
      const id_comentario = commentIdResult.rows[0].id_comentario;
      // Luego eliminamos el comentario de la tabla 'comentarios'
      await client.query('DELETE FROM comentarios WHERE id = $1', [id_comentario]);
    }

    // Finalmente, marcamos el reporte como resuelto
    const updateReportQuery = "UPDATE comentario_reportes SET estado = 'resuelto' WHERE id = $1";
    await client.query(updateReportQuery, [id]);

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

// Resolve a user report (dismiss or suspend user)
const resolveUserReport = async (req, res) => {
  const { id } = req.params; // ID of the user report
  const { action, userId } = req.body; // 'desestimar' or 'suspender_usuario'

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    if (action === 'suspender_usuario') {
      // Set the user's status in the 'usuarios' table to 'suspendido'
      await client.query("UPDATE usuarios SET status = 'suspendido' WHERE id = $1", [userId]);
    }

    // Mark the report itself as resolved
    await client.query("UPDATE usuario_reportes SET estado = 'resuelto' WHERE id = $1", [id]);

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

const getAllAdminReports = async (req, res) => {
  try {
    // --- QUERY UPDATED to include user's real name, email, description, and anonymous status ---
    let query = `
      SELECT 
        r.id, r.titulo, r.descripcion, r.es_anonimo, 
        c.nombre as categoria, 
        u.nombre as autor_nombre, -- Get the real name
        u.email as autor_email,    -- Get the email
        r.estado, 
        to_char(r.fecha_creacion, 'DD Mon YYYY') as fecha
      FROM reportes r
      LEFT JOIN usuarios u ON r.id_usuario = u.id
      LEFT JOIN categorias c ON r.id_categoria = c.id
    `;
    
    // ... (The filtering logic below remains exactly the same)
    const whereClauses = [];
    const queryParams = [];
    let paramIndex = 1;

    const { search, status, categoryId } = req.query;

    if (search) {
      whereClauses.push(`(r.titulo ILIKE $${paramIndex} OR u.nombre ILIKE $${paramIndex})`); // Search by real name now
      queryParams.push(`%${search}%`);
      paramIndex++;
    }
    if (status) {
      whereClauses.push(`r.estado = $${paramIndex}`);
      queryParams.push(status);
      paramIndex++;
    }
    if (categoryId) {
      whereClauses.push(`r.id_categoria = $${paramIndex}`);
      queryParams.push(categoryId);
      paramIndex++;
    }

    if (whereClauses.length > 0) {
      query += ' WHERE ' + whereClauses.join(' AND ');
    }

    query += ' ORDER BY r.id DESC';
    
    const result = await db.query(query, queryParams);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching admin reports:", error);
    res.status(500).json({ message: 'Error al obtener los reportes.' });
  }
};

// --- NEW FUNCTION to hide/publish a report ---
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
      SELECT sr.id, r.titulo, u.alias as lider_alias
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
    const result = await db.query('SELECT * FROM simulated_sms_log ORDER BY fecha_envio DESC');
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener el registro de SMS.' });
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
    // Create an INSERT query for each user ID
    for (const userId of userIds) {
      const query = 'INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo) VALUES ($1, $2, $3)';
      await client.query(query, [userId, title, body]);
    }
    await client.query('COMMIT');
    res.status(200).json({ message: 'Notificación(es) guardada(s) en la base de datos.' });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error sending notification:", error);
    res.status(500).json({ message: 'Error al enviar la notificación.' });
  } finally {
    client.release();
  }
};

const getNotificationHistory = async (req, res) => {
  try {
    // --- QUERY UPDATED to JOIN with usuarios and get the email ---
    const query = `
      SELECT n.id, n.titulo, n.cuerpo, n.leido, n.fecha_envio, 
             u.alias as receptor, u.email as receptor_email
      FROM notificaciones n
      JOIN usuarios u ON n.id_usuario_receptor = u.id
      ORDER BY n.fecha_envio DESC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener historial de notificaciones.' });
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
  try {
    const result = await db.query("UPDATE reportes SET estado = 'verificado', fecha_actualizacion = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *", [id]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Reporte no encontrado.' });
    }
    res.status(200).json({ message: 'Reporte aprobado.', report: result.rows[0] });
  } catch (error) {
    console.error('Error in adminAprobarReporte:', error);
    res.status(500).json({ message: 'Error al aprobar el reporte.', error: error.message });
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

const getReportsByCategory = async (req, res) => {
  try {
    const query = `
      SELECT c.nombre as name, COUNT(r.id) as value
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      GROUP BY c.nombre
      ORDER BY value DESC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener reportes por categoría.' });
  }
};

const getReportsByStatus = async (req, res) => {
  try {
    const query = "SELECT estado as name, COUNT(id) as value FROM reportes GROUP BY estado";
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
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
    res.status(500).json({ message: 'Error al obtener reportes por mes.' });
  }
};

const getUsersByStatus = async (req, res) => {
  try {
    const query = "SELECT status as name, COUNT(id) as value FROM usuarios GROUP BY status";
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener usuarios por estado.' });
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

const getLeaderPerformance = async (req, res) => {
  try {
    // Esta consulta cuenta cuántos reportes ha moderado cada líder
    const query = `
      SELECT u.alias as name, COUNT(r.id) as value
      FROM reportes r
      JOIN usuarios u ON r.id_lider_verificador = u.id
      WHERE u.rol = 'lider_vecinal'
      GROUP BY u.alias
      ORDER BY value DESC
      LIMIT 10;
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener rendimiento de líderes.' });
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
  getSosDashboardData,
  getReportCoordinates,
  getReportsByCategory,
  getReportsByStatus,
  getReportsByMonth,
  getUsersByStatus,
  getAverageResolutionTime,
  getLeaderPerformance,
};