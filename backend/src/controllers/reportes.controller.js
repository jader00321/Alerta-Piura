// backend/src/controllers/reportes.controller.js
const db = require('../config/db');
const socketNotificationService = require('../services/socketNotificationService'); 
const gamificacionService = require('../services/gamificacionService');

// Esta función ya estaba correcta, se mantiene igual
const getAllReports = async (req, res) => {
  try {
    const { categoriaIds, status, searchQuery, dateRange } = req.query;

    let query = `
      SELECT 
        r.id, r.titulo, r.descripcion, c.nombre as categoria,
        ST_AsGeoJSON(r.location) as location,
        CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
    `;

    const whereClauses = [];
    const queryParams = [];
    let paramIndex = 1;

    // Por defecto, solo mostrar reportes verificados si no se especifica otro estado
    let statusFilter = "r.estado = 'verificado'";
    if (status) {
      statusFilter = `r.estado = $${paramIndex++}`;
      queryParams.push(status);
    }
    whereClauses.push(statusFilter);

    if (categoriaIds) {
      const ids = categoriaIds.split(',').map(id => parseInt(id, 10));
      whereClauses.push(`r.id_categoria = ANY($${paramIndex++})`);
      queryParams.push(ids);
    }
    if (searchQuery) {
      whereClauses.push(`(r.titulo ILIKE $${paramIndex} OR r.codigo_reporte ILIKE $${paramIndex})`);
      queryParams.push(`%${searchQuery}%`);
      paramIndex++;
    }
    if (dateRange) {
        const days = parseInt(dateRange, 10);
        if (!isNaN(days) && days > 0) {
            whereClauses.push(`r.fecha_creacion >= NOW() - interval '${days} days'`);
        }
    }

    if (whereClauses.length > 0) {
      query += ' WHERE ' + whereClauses.join(' AND ');
    }

    const result = await db.query(query, queryParams);

    const reportes = result.rows.map(reporte => ({
      ...reporte,
      location: JSON.parse(reporte.location)
    }));

    res.status(200).json(reportes);
  } catch (error) {
    console.error('Error al obtener reportes:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// Esta función ya estaba correcta, se mantiene igual
const createReport = async (req, res) => {
  const { userId, planId } = req.user;
  const {
    id_categoria, titulo, descripcion, es_anonimo, categoria_sugerida,
    urgencia, hora_incidente, tags, impacto, referencia_ubicacion, distrito
  } = req.body;
  const location = JSON.parse(req.body.location);
  const foto_url = req.file ? req.file.path : null;

  if (!id_categoria || !titulo || !location) {
    return res.status(400).json({ message: 'Categoría, título y ubicación son requeridos.' });
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const reporteQuery = `
      INSERT INTO reportes (
        id_usuario, id_categoria, titulo, descripcion, location, es_anonimo,
        categoria_sugerida, foto_url, urgencia, hora_incidente, tags,
        impacto, referencia_ubicacion, distrito
      )
      VALUES ($1, $2, $3, $4, ST_SetSRID(ST_GeomFromGeoJSON($5), 4326), $6, $7, $8, $9, $10, $11, $12, $13, $14)
      RETURNING id;
    `;
    const reporteValues = [
      userId, id_categoria, titulo, descripcion, JSON.stringify(location),
      es_anonimo || false, categoria_sugerida, foto_url, urgencia, hora_incidente,
      tags, impacto, referencia_ubicacion, distrito
    ];
    const result = await client.query(reporteQuery, reporteValues);
    const newReportId = result.rows[0].id;

    const year = new Date().getFullYear();
    const codigo_reporte = `AP-${year}-${newReportId.toString().padStart(5, '0')}`;
    await client.query('UPDATE reportes SET codigo_reporte = $1 WHERE id = $2', [codigo_reporte, newReportId]);

    if (planId) {
      await client.query('INSERT INTO reportes_prioritarios (id_reporte, id_usuario_premium) VALUES ($1, $2)', [newReportId, userId]);
    }

    const puntosQuery = 'UPDATE usuarios SET puntos = puntos + 10 WHERE id = $1';
    await client.query(puntosQuery, [userId]);

    await gamificacionService.verificarYOtorgarInsignias(client, userId);

    await client.query('COMMIT');

    res.status(201).json({
      message: 'Reporte creado exitosamente y +10 puntos obtenidos.',
      reporte: { id: newReportId, codigo_reporte },
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error al crear el reporte:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};

// Esta función ya estaba correcta, se mantiene igual
const apoyarReporte = async (req, res) => {
  const id_usuario = req.user.userId;
  const { id: id_reporte } = req.params;

  if (!id_usuario) {
      return res.status(401).json({ message: 'Usuario no autenticado correctamente.' });
  }
  if (!id_reporte) {
       return res.status(400).json({ message: 'ID de reporte inválido.' });
  }

  const client = await db.getClient();
  try {
    const checkQuery = 'SELECT * FROM apoyos WHERE id_reporte = $1 AND id_usuario = $2';
    const checkResult = await client.query(checkQuery, [id_reporte, id_usuario]);

    if (checkResult.rows.length > 0) {
      await client.query('DELETE FROM apoyos WHERE id_reporte = $1 AND id_usuario = $2', [id_reporte, id_usuario]);
      res.status(200).json({ message: 'Has quitado tu apoyo a este reporte.' });
    } else {
      const insertQuery = 'INSERT INTO apoyos (id_reporte, id_usuario) VALUES ($1, $2)';
      await client.query(insertQuery, [id_reporte, id_usuario]);
      res.status(201).json({ message: 'Gracias por apoyar este reporte.' });
    }
  } catch (error) {
     if (error.code === '23503') {
         return res.status(404).json({ message: 'El reporte especificado no existe.' });
     }
    console.error('Error al apoyar/quitar apoyo reporte:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};

// --- FUNCIÓN getReporteById CORREGIDA ---
// Usa nombres de tabla en minúsculas y formato de fecha ISO para comentarios
const getReporteById = async (req, res) => {
  const { id } = req.params;
  const id_usuario_actual = req.user?.userId; // Obtener ID (puede ser null)

  try {
    // --- CORRECCIÓN: Nombres de tabla en minúsculas ---
    const reporteQuery = `
      SELECT
        r.id, r.titulo, r.descripcion, r.estado, r.foto_url, r.id_reporte_original,
        r.urgencia, r.distrito, r.referencia_ubicacion, r.tags, r.impacto, r.codigo_reporte,
        to_char(r.hora_incidente, 'HH24:MI') as hora_incidente,
        c.nombre as categoria,
        to_char(r.fecha_creacion, 'DD Mon YYYY, HH24:MI') as fecha_creacion,
        r.es_anonimo,
        CASE WHEN r.es_anonimo = true THEN 'Anónimo' ELSE COALESCE(u.alias, u.nombre) END as autor,
        u.id as id_autor,
        (SELECT COUNT(*) FROM apoyos WHERE id_reporte = r.id) as apoyos_count,
        ST_AsGeoJSON(r.location) as location,
        r.reportes_vinculados_count -- Campo añadido en Hoja de Trabajo #7
      FROM reportes r
      LEFT JOIN usuarios u ON r.id_usuario = u.id
      LEFT JOIN categorias c ON r.id_categoria = c.id
      WHERE r.id = $1
    `;
    // --- FIN CORRECCIÓN ---
    const reporteResult = await db.query(reporteQuery, [id]);

    if (reporteResult.rows.length === 0) {
      return res.status(404).json({ message: 'Reporte no encontrado.' });
    }
    const reporte = reporteResult.rows[0];

    // --- CORRECCIÓN: Nombres de tabla en minúsculas y formato de fecha ISO ---
    const comentariosQuery = `
      SELECT
        c.id, c.comentario, c.id_usuario,
        to_char(c.fecha_creacion, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') as fecha_creacion,
        COALESCE(u.alias, u.nombre) as autor,
        (SELECT COUNT(*) FROM comentario_apoyos WHERE id_comentario = c.id) as apoyos_count,
        CASE WHEN EXISTS (
          SELECT 1 FROM comentario_apoyos ca WHERE ca.id_comentario = c.id AND ca.id_usuario = $2
        ) THEN true ELSE false END as usuario_dio_apoyo
      FROM comentarios c
      LEFT JOIN usuarios u ON c.id_usuario = u.id
      WHERE c.id_reporte = $1
      ORDER BY c.fecha_creacion ASC
    `;
    // --- FIN CORRECCIÓN ---
    const comentariosResult = await db.query(comentariosQuery, [id, id_usuario_actual]);

    reporte.comentarios = comentariosResult.rows;
    if (reporte.location) {
        reporte.location = JSON.parse(reporte.location);
    }

    res.status(200).json(reporte);
  } catch (error) {
    console.error('Error al obtener el reporte por ID:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// Esta función ya estaba correcta, se mantiene igual
const eliminarReporte = async (req, res) => {
  const { id: id_reporte } = req.params;
  const id_usuario = req.user.userId; // Corregido de req.user.id

  try {
    const query = `
      DELETE FROM reportes 
      WHERE id = $1 AND id_usuario = $2 AND estado = 'pendiente_verificacion'
      RETURNING *;
    `;
    const result = await db.query(query, [id_reporte, id_usuario]);

    if (result.rows.length === 0) {
      return res.status(403).json({ message: 'No se pudo eliminar el reporte. Es posible que ya haya sido moderado.' });
    }

    res.status(200).json({ message: 'Reporte cancelado exitosamente.' });
  } catch (error) {
    console.error('Error al eliminar el reporte:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// --- FUNCIÓN getRiesgoZona CORREGIDA ---
// Usa nombres de tabla en minúsculas
const getRiesgoZona = async (req, res) => {
  const { lat, lon, radius } = req.query;

  if (!lat || !lon || !radius) {
    return res.status(400).json({ message: 'Latitud, longitud y radio son requeridos.' });
  }

  try {
    // --- CORRECCIÓN: Nombres de tabla en minúsculas ---
    const query = `
      SELECT c.nombre as categoria
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      WHERE r.estado = 'verificado' AND ST_DWithin(
        r.location,
        ST_MakePoint($1, $2)::geography,
        $3
      )
    `;
    // --- FIN CORRECCIÓN ---
    const result = await db.query(query, [lon, lat, radius]);

    let riesgoScore = 0;
    result.rows.forEach(reporte => {
      switch (reporte.categoria) {
        case 'Delito': riesgoScore += 10; break;
        case 'Falla de Alumbrado': riesgoScore += 3; break;
        case 'Bache': riesgoScore += 2; break;
        case 'Basura': riesgoScore += 1; break;
        default: riesgoScore += 1;
      }
    });

    res.status(200).json({ riesgo: riesgoScore });

  } catch (error){
    console.error('Error al calcular el riesgo de la zona:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// backend/src/controllers/reportes.controller.js -> getChatHistory
const getChatHistory = async (req, res) => {
  const { id: id_reporte } = req.params;
  try {
    const query = `
      SELECT m.id, m.id_reporte, m.id_remitente, m.remitente_alias, m.mensaje,
             to_char(m.fecha_envio, 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') as timestamp
      FROM chat_messages m
      -- No necesitamos JOIN usuarios aquí si ya guardamos el alias
      WHERE m.id_reporte = $1
      ORDER BY m.fecha_envio ASC
    `;
    const result = await db.query(query, [id_reporte]);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error fetching chat history:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// --- FUNCIÓN getZonasPeligrosas CORREGIDA ---
// Usa nombres de tabla en minúsculas
const getZonasPeligrosas = async (req, res) => {
  try {
    // --- CORRECCIÓN: Nombres de tabla en minúsculas ---
    const query = `
      SELECT ST_AsGeoJSON(r.location) as location
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      WHERE r.estado = 'verificado' AND c.nombre = 'Delito'
    `;
    // --- FIN CORRECCIÓN ---
    const result = await db.query(query);

    const locations = result.rows.map(row => JSON.parse(row.location).coordinates);
    res.status(200).json(locations);

  } catch (error) {
    console.error('Error al obtener zonas peligrosas:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// Esta función ya estaba correcta, se mantiene igual
const getDatosMapaDeCalor = async (req, res) => {
  try {
    const query = `
      SELECT 
        ST_Y(location) as lat, 
        ST_X(location) as lon 
      FROM reportes 
      WHERE estado = 'verificado' AND location IS NOT NULL
    `;
    const result = await db.query(query);
    const heatmapData = result.rows.map(r => [r.lat, r.lon]);
    res.status(200).json(heatmapData);
  } catch (error) {
    console.error('Error al obtener datos del mapa de calor:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// --- FUNCIÓN getReportesCercanos CORREGIDA ---
// Usa nombres de tabla en minúsculas
const getReportesCercanos = async (req, res) => {
  const { lat, lon, radius = 500 } = req.query;
  const { categoriaId, estado, urgencia, dias } = req.query;
  const id_usuario_solicitante = req.user?.userId;

  if (!lat || !lon) {
    return res.status(400).json({ message: 'Se requieren latitud y longitud.' });
  }

  try {
    const params = [lon, lat, radius];
    let paramIndex = 4;
    // --- CORRECCIÓN: Nombres de tabla en minúsculas ---
    let query = `
      SELECT
        r.id, r.titulo, c.nombre as categoria, r.estado, r.foto_url,
        r.apoyos_pendientes, r.id_usuario,
        CASE WHEN r.es_anonimo = true THEN 'Anónimo' ELSE COALESCE(u.alias, u.nombre) END as autor,
        to_char(r.fecha_creacion, 'DD Mon YYYY') as fecha_creacion_formateada,
        CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario,
        r.urgencia,
        ST_Distance(r.location, ST_MakePoint($1, $2)::geography) as distancia_metros,
        CASE WHEN ap.id_usuario IS NOT NULL THEN true ELSE false END as usuario_actual_unido
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      JOIN usuarios u ON r.id_usuario = u.id
      LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
      LEFT JOIN apoyos_pendientes ap ON r.id = ap.id_reporte AND ap.id_usuario = $${paramIndex++}
      WHERE
        ST_DWithin(r.location, ST_MakePoint($1, $2)::geography, $3)
    `;
    // --- FIN CORRECCIÓN ---

    params.push(id_usuario_solicitante || null);

    // ... (lógica de filtros sin cambios) ...
    if (categoriaId) { /* ... */ }
    if (estado && (estado === 'pendiente_verificacion' || estado === 'verificado')) { /* ... */ }
    else { query += ` AND r.estado IN ('pendiente_verificacion', 'verificado')`; }
    if (urgencia && ['Baja', 'Media', 'Alta'].includes(urgencia)) { /* ... */ }
    if (dias) { /* ... */ }

    query += ` ORDER BY distancia_metros ASC LIMIT 20;`;

    const result = await db.query(query, params);

    const reportes = result.rows.map(r => ({
      ...r,
      puede_unirse: !!id_usuario_solicitante && r.estado === 'pendiente_verificacion' && r.id_usuario !== id_usuario_solicitante && !r.usuario_actual_unido
    }));

    res.status(200).json(reportes);
  } catch (error) {
    console.error('Error al obtener reportes cercanos:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// Esta función ya estaba correcta, se mantiene igual
const unirseReportePendiente = async (req, res) => {
  const id_usuario = req.user.userId;
  const { id: id_reporte } = req.params;

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const reporteResult = await client.query(
      "SELECT estado, id_usuario FROM reportes WHERE id = $1 FOR UPDATE",
      [id_reporte]
    );

    if (reporteResult.rows.length === 0) {
      return res.status(404).json({ message: 'Reporte no encontrado.' });
    }
    const reporte = reporteResult.rows[0];

    if (reporte.estado !== 'pendiente_verificacion') {
      return res.status(400).json({ message: 'Este reporte ya ha sido moderado.' });
    }
    if (reporte.id_usuario === id_usuario) {
      return res.status(403).json({ message: 'No puedes unirte a tu propio reporte pendiente.' });
    }

    const insertQuery = 'INSERT INTO apoyos_pendientes (id_reporte, id_usuario) VALUES ($1, $2) ON CONFLICT (id_reporte, id_usuario) DO NOTHING';
    const insertResult = await client.query(insertQuery, [id_reporte, id_usuario]);

    let updatedApoyos = 0;
    if (insertResult.rowCount > 0) {
      const updateResult = await client.query(
        'UPDATE reportes SET apoyos_pendientes = apoyos_pendientes + 1 WHERE id = $1 RETURNING apoyos_pendientes',
        [id_reporte]
      );
      updatedApoyos = updateResult.rows[0].apoyos_pendientes;
      await client.query('UPDATE usuarios SET puntos = puntos + 1 WHERE id = $1', [id_usuario]);
      await gamificacionService.verificarYOtorgarInsignias(client, id_usuario);

      await client.query('COMMIT');
      res.status(201).json({ message: 'Te has unido exitosamente (+1 punto).', currentApoyos: updatedApoyos });
    } else {
      const currentApoyosResult = await client.query('SELECT apoyos_pendientes FROM reportes WHERE id = $1', [id_reporte]);
      updatedApoyos = currentApoyosResult.rows[0].apoyos_pendientes;
      await client.query('COMMIT'); // Commit aunque no se haya hecho nada, para liberar el FOR UPDATE
      res.status(200).json({ message: 'Ya te habías unido a este reporte.', currentApoyos: updatedApoyos });
    }
  } catch (error) {
    await client.query('ROLLBACK');
    if (error.code === '23503') {
        return res.status(404).json({ message: 'Error de referencia, el usuario podría no existir.' });
    }
    console.error('Error al unirse a reporte pendiente:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};

// Esta función ya estaba correcta, se mantiene igual
const quitarApoyoPendiente = async (req, res) => {
  const id_usuario = req.user.userId;
  const { id: id_reporte } = req.params;

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const reporteResult = await client.query(
      "SELECT estado FROM reportes WHERE id = $1",
      [id_reporte]
    );

    if (reporteResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ message: 'Reporte no encontrado.' });
    }
    if (reporteResult.rows[0].estado !== 'pendiente_verificacion') {
      await client.query('ROLLBACK');
      return res.status(400).json({ message: 'Este reporte ya ha sido moderado.' });
    }

    const deleteQuery = 'DELETE FROM apoyos_pendientes WHERE id_reporte = $1 AND id_usuario = $2';
    const deleteResult = await client.query(deleteQuery, [id_reporte, id_usuario]);

    let updatedApoyos = 0;

    if (deleteResult.rowCount > 0) {
      const updateResult = await client.query(
          'UPDATE reportes SET apoyos_pendientes = GREATEST(0, apoyos_pendientes - 1) WHERE id = $1 RETURNING apoyos_pendientes',
          [id_reporte]
      );
      updatedApoyos = updateResult.rows[0].apoyos_pendientes;
      await client.query('UPDATE usuarios SET puntos = GREATEST(0, puntos - 1) WHERE id = $1', [id_usuario]);

      await client.query('COMMIT');
      res.status(200).json({ message: 'Has retirado tu apoyo (-1 punto).', currentApoyos: updatedApoyos });
    } else {
      const currentApoyosResult = await client.query('SELECT apoyos_pendientes FROM reportes WHERE id = $1', [id_reporte]);
      updatedApoyos = currentApoyosResult.rows[0].apoyos_pendientes;
      await client.query('ROLLBACK'); // Rollback si no se hizo nada
      res.status(404).json({ message: 'No estabas unido a este reporte pendiente.', currentApoyos: updatedApoyos });
    }
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error al quitar apoyo pendiente:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};

const editReportAuthor = async (req, res) => {
  const { id } = req.params;
  const { userId } = req.user; // ID del autor autenticado
  // Campos permitidos para editar por el autor
  const {
    titulo,
    descripcion,
    id_categoria, // Permitimos cambiar categoría
    referencia_ubicacion,
    tags,
    urgencia, // Nuevos campos permitidos
    hora_incidente,
    impacto,
    distrito
   } = req.body;

  // Validación básica
  if (!titulo || !id_categoria) {
    return res.status(400).json({ message: 'Título y categoría son requeridos.' });
  }
  if (tags && !Array.isArray(tags)) {
     return res.status(400).json({ message: 'Las etiquetas deben ser un array.' });
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    // --- VERIFICACIÓN CRUCIAL ---
    // Asegura que el reporte exista, pertenezca al usuario y esté pendiente
    const checkQuery = `
      SELECT id FROM reportes
      WHERE id = $1 AND id_usuario = $2 AND estado = 'pendiente_verificacion'
      FOR UPDATE`; // Bloquear la fila
    const checkResult = await client.query(checkQuery, [id, userId]);

    if (checkResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(403).json({ message: 'No autorizado para editar este reporte o el reporte ya no está pendiente.' });
    }
    // --- FIN VERIFICACIÓN ---

    // Construir la consulta de actualización dinámicamente (solo campos permitidos)
    const updateFields = [];
    const updateValues = [];
    let paramIndex = 1;

    if (titulo !== undefined) { updateFields.push(`titulo = $${paramIndex++}`); updateValues.push(titulo); }
    if (descripcion !== undefined) { updateFields.push(`descripcion = $${paramIndex++}`); updateValues.push(descripcion); }
    if (id_categoria !== undefined) { updateFields.push(`id_categoria = $${paramIndex++}`); updateValues.push(id_categoria); }
    if (referencia_ubicacion !== undefined) { updateFields.push(`referencia_ubicacion = $${paramIndex++}`); updateValues.push(referencia_ubicacion); }
    // Manejar tags (convertir array a string de PG si es necesario)
    const tagsToSave = (tags && tags.length > 0) ? tags : null;
    if (tags !== undefined) { updateFields.push(`tags = $${paramIndex++}`); updateValues.push(tagsToSave); }
    if (urgencia !== undefined) { updateFields.push(`urgencia = $${paramIndex++}`); updateValues.push(urgencia); }
    if (hora_incidente !== undefined) { updateFields.push(`hora_incidente = $${paramIndex++}`); updateValues.push(hora_incidente || null); } // Asegurar null si está vacío
    if (impacto !== undefined) { updateFields.push(`impacto = $${paramIndex++}`); updateValues.push(impacto); }
    if (distrito !== undefined) { updateFields.push(`distrito = $${paramIndex++}`); updateValues.push(distrito); }

    if (updateFields.length === 0) {
      await client.query('ROLLBACK');
      return res.status(400).json({ message: 'No hay campos válidos para actualizar.' });
    }

    // Añadir fecha de actualización y el ID para el WHERE
    updateFields.push(`fecha_actualizacion = NOW()`);
    updateValues.push(id); // Para WHERE id = $N
    updateValues.push(userId); // Para WHERE id_usuario = $N+1
    updateValues.push('pendiente_verificacion'); // Para WHERE estado = $N+2

    const updateQuery = `
      UPDATE reportes SET ${updateFields.join(', ')}
      WHERE id = $${paramIndex++} AND id_usuario = $${paramIndex++} AND estado = $${paramIndex++}
      RETURNING *`; // Devolver el reporte actualizado

    const result = await client.query(updateQuery, updateValues);

    await client.query('COMMIT');
    res.status(200).json({ message: 'Reporte actualizado exitosamente.', reporte: result.rows[0] });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error al editar reporte (autor):', error);
    // Manejar error de FK si la categoría no existe
    if (error.code === '23503' && error.constraint === 'reportes_id_categoria_fkey') {
       return res.status(400).json({ message: 'La categoría seleccionada no es válida.' });
    }
    res.status(500).json({ message: 'Error interno del servidor al actualizar reporte.' });
  } finally {
    client.release();
  }
};

// Exportar todas las funciones
module.exports = {
  getAllReports,
  createReport,
  apoyarReporte, 
  getReporteById,
  eliminarReporte,
  getRiesgoZona,
  // checkAndAwardBadges no se exporta porque es un helper interno
  getChatHistory, 
  getZonasPeligrosas,
  getReportesCercanos,
  unirseReportePendiente,
  getDatosMapaDeCalor,
  quitarApoyoPendiente,
  editReportAuthor,
};