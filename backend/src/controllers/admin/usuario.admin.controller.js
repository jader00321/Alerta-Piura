// backend/src/controllers/admin/usuario.admin.controller.js
const db = require('../../config/db'); // <-- Adjusted path
const bcrypt = require('bcryptjs');

const getAllUsers = async (req, res) => {
  try {
    // Added includeSuspended query parameter
    const { role, status, sortBy, search, includeSuspended } = req.query;
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
    // Apply status filter ONLY if includeSuspended is not true
    if (status && includeSuspended !== 'true') {
      whereClauses.push(`u.status = $${paramIndex++}`);
      queryParams.push(status);
    } else if (!status && includeSuspended !== 'true') {
        // Default to active if status is not provided AND includeSuspended is not true
        // Comment this out if you want NO status filter by default unless specified
        // whereClauses.push(`u.status = 'activo'`);
    }
     // If includeSuspended is true, we don't add any status clause here, getting all statuses

    if (whereClauses.length > 0) {
      query += ' WHERE ' + whereClauses.join(' AND ');
    }

    let orderByClause = ' ORDER BY u.fecha_registro DESC';
    if (sortBy === 'oldest') orderByClause = ' ORDER BY u.fecha_registro ASC';
    else if (sortBy === 'name') orderByClause = ' ORDER BY u.nombre ASC';
    query += orderByClause;

    const result = await db.query(query, queryParams);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error en getAllUsers:", error);
    res.status(500).json({ message: 'Error al obtener la lista de usuarios.' });
  }
};
const getUserSummary = async (req, res) => {
    const { id } = req.params;
    try {
        // Query 1: Get user basic info + plan
        const userQuery = `
            SELECT
                u.id, u.nombre, u.alias, u.email, u.rol, u.status,
                CASE
                    WHEN u.id_plan_suscripcion IS NOT NULL AND u.fecha_fin_suscripcion > NOW()
                    THEN p.nombre_publico
                    ELSE 'Plan Gratuito'
                END AS nombre_plan,
                CASE
                    WHEN u.id_plan_suscripcion IS NOT NULL AND u.fecha_fin_suscripcion > NOW()
                    THEN true ELSE false
                END AS is_premium
            FROM usuarios u
            LEFT JOIN planes_suscripcion p ON u.id_plan_suscripcion = p.id
            WHERE u.id = $1
        `;
        const userResult = await db.query(userQuery, [id]);
        if (userResult.rows.length === 0) {
            return res.status(404).json({ message: 'Usuario no encontrado.' });
        }
        const userSummary = userResult.rows[0];

        // Query 2: Get total notification count for this user
        const countQuery = 'SELECT COUNT(*) FROM notificaciones WHERE id_usuario_receptor = $1';
        const countResult = await db.query(countQuery, [id]);
        userSummary.total_notificaciones = parseInt(countResult.rows[0].count, 10);

        res.status(200).json(userSummary);

    } catch (error) {
        console.error("Error en getUserSummary:", error);
        res.status(500).json({ message: 'Error al obtener el resumen del usuario.' });
    }
};
const updateUserRole = async (req, res) => {
  const { id: targetUserId } = req.params;
  const { rol, adminPassword } = req.body;
  const adminId = req.user.userId; // Asume que adminMiddleware añade esto

  if (!['ciudadano', 'lider_vecinal', 'admin', 'reportero'].includes(rol)) {
    return res.status(400).json({ message: 'Rol no válido.' });
  }

  // Verificación de contraseña si se promueve a admin
  if (rol === 'admin') {
    if (!adminPassword) {
      return res.status(400).json({ message: 'Se requiere su contraseña para confirmar esta acción.' });
    }
    try {
        const adminResult = await db.query('SELECT password_hash FROM usuarios WHERE id = $1', [adminId]);
        if (adminResult.rows.length === 0) return res.status(403).json({ message: 'Admin no encontrado.' });
        const admin = adminResult.rows[0];
        const isMatch = await bcrypt.compare(adminPassword, admin.password_hash);
        if (!isMatch) {
          return res.status(403).json({ message: 'Su contraseña es incorrecta. Acción denegada.' });
        }
    } catch(error){
        console.error("Error verificando contraseña de admin:", error);
        return res.status(500).json({ message: 'Error verificando credenciales.' });
    }
  }

  // Actualización del rol en la base de datos
  try {
    const query = 'UPDATE usuarios SET rol = $1 WHERE id = $2 RETURNING id, nombre, rol';
    const result = await db.query(query, [rol, targetUserId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: 'Usuario no encontrado.' });
    }
    res.status(200).json({ message: 'Rol de usuario actualizado.', user: result.rows[0] });
  } catch (error) {
    console.error("Error en updateUserRole:", error);
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
    console.error("Error en updateUserStatus:", error);
    res.status(500).json({ message: 'Error al actualizar el estado del usuario.' });
  }
};
const getUserDetails = async (req, res) => {
    // ... (getUserDetails function code remains the same) ...
      const { id } = req.params;
  try {
    const userQuery = 'SELECT id, nombre, alias, email, puntos, telefono, to_char(fecha_registro, \'DD Mon YYYY\') as fecha_registro_formateada FROM usuarios WHERE id = $1';
    const userResult = await db.query(userQuery, [id]);
    if (userResult.rows.length === 0) return res.status(404).json({ message: 'Usuario no encontrado.' });
    const userDetails = userResult.rows[0];

    const insigniasQuery = `SELECT i.nombre, i.descripcion, i.icono_url FROM Insignias i JOIN Usuario_Insignias ui ON i.id = ui.id_insignia WHERE ui.id_usuario = $1 ORDER BY i.nombre`;
    const insigniasResult = await db.query(insigniasQuery, [id]);
    userDetails.insignias = insigniasResult.rows;

    const reportesQuery = `SELECT codigo_reporte, titulo, estado, urgencia, to_char(fecha_creacion, 'DD Mon YYYY') as fecha FROM reportes WHERE id_usuario = $1 ORDER BY fecha_creacion DESC LIMIT 5`;
    const reportesResult = await db.query(reportesQuery, [id]);
    userDetails.reportes = reportesResult.rows;

    res.status(200).json(userDetails);
  } catch (error) {
    console.error('Error al obtener detalles del usuario:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};
const getSolicitudesRol = async (req, res) => {
    // ... (getSolicitudesRol function code remains the same) ...
      try {
    const query = `
      SELECT s.id, s.id_usuario, s.estado, to_char(s.fecha_solicitud, 'DD Mon YYYY, HH24:MI') as fecha,
             u.nombre, u.alias, u.email, s.motivacion, s.zona_propuesta
      FROM solicitudes_rol s JOIN usuarios u ON s.id_usuario = u.id
      WHERE s.estado = 'pendiente' ORDER BY s.fecha_solicitud ASC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error al obtener solicitudes de rol:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};
const resolverSolicitudRol = async (req, res) => {
    // ... (resolverSolicitudRol function code remains the same) ...
      const { id } = req.params;
  const { accion } = req.body;
  if (!['aprobar', 'rechazar'].includes(accion)) {
    return res.status(400).json({ message: 'Acción no válida.' });
  }
  const client = await db.getClient();
  try {
    await client.query('BEGIN');
    const solicitudResult = await client.query('SELECT id_usuario FROM solicitudes_rol WHERE id = $1', [id]);
    if (solicitudResult.rows.length === 0) throw new Error('Solicitud no encontrada.');
    const id_usuario = solicitudResult.rows[0].id_usuario;

    if (accion === 'aprobar') {
      await client.query("UPDATE usuarios SET rol = 'lider_vecinal' WHERE id = $1", [id_usuario]);
      await client.query("UPDATE solicitudes_rol SET estado = 'aprobado' WHERE id = $1", [id]);
    } else {
      await client.query("UPDATE solicitudes_rol SET estado = 'rechazado' WHERE id = $1", [id]);
    }
    await client.query('COMMIT');
    res.status(200).json({ message: `Solicitud ${accion === 'aprobar' ? 'aprobada' : 'rechazada'} exitosamente.` });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error("Error en resolverSolicitudRol:", error);
    res.status(500).json({ message: 'Error al resolver la solicitud.' });
  } finally {
    client.release();
  }
};
const asignarZonasLider = async (req, res) => {
    const { id: id_lider } = req.params;
    const { distritos } = req.body; // Array de strings, puede ser ['*']

    if (!Array.isArray(distritos) || distritos.length === 0) {
        return res.status(400).json({ message: 'Se requiere un array de distritos (puede ser ["*"] para todas).' });
    }
    // Si se envía '*', solo guardar ese.
    const zonasParaInsertar = distritos.includes('*') ? ['*'] : distritos;
    const client = await db.getClient();

    try {
        await client.query('BEGIN');
        // Verificar que el usuario sea líder vecinal
        const userResult = await client.query("SELECT rol FROM usuarios WHERE id = $1", [id_lider]);
        if (userResult.rows.length === 0 || userResult.rows[0].rol !== 'lider_vecinal') {
            await client.query('ROLLBACK');
            return res.status(404).json({ message: 'Usuario no encontrado o no es un líder vecinal.' });
        }
        // Borrar asignaciones existentes
        await client.query("DELETE FROM lider_zonas_asignadas WHERE id_usuario = $1", [id_lider]);
        // Insertar nuevas asignaciones
        const insertPromises = zonasParaInsertar.map(distrito => {
            return client.query("INSERT INTO lider_zonas_asignadas (id_usuario, nombre_distrito) VALUES ($1, $2)", [id_lider, distrito]);
        });
        await Promise.all(insertPromises);
        await client.query('COMMIT');
        res.status(200).json({ message: `Zonas asignadas correctamente al líder ${id_lider}.` });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error al asignar zonas al líder:', error);
        res.status(500).json({ message: 'Error interno del servidor al asignar zonas.' });
    } finally {
        client.release();
    }
};
const getZonasAsignadas = async (req, res) => {
    const { id: id_lider } = req.params;
    try {
        const query = "SELECT nombre_distrito FROM lider_zonas_asignadas WHERE id_usuario = $1";
        const result = await db.query(query, [id_lider]);
        // Devuelve un array de strings con los nombres de los distritos o ['*']
        res.status(200).json(result.rows.map(row => row.nombre_distrito));
    } catch (error) {
        console.error('Error al obtener zonas asignadas:', error);
        res.status(500).json({ message: 'Error interno del servidor al obtener zonas.' });
    }
};

module.exports = {
  getAllUsers,
  getUserSummary,
  updateUserRole,
  updateUserStatus,
  getUserDetails,
  getSolicitudesRol,
  resolverSolicitudRol,
  asignarZonasLider,
  getZonasAsignadas,
};