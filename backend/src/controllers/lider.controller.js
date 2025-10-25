// backend/src/controllers/lider.controller.js
const db = require('../config/db');
const socketNotificationService = require('../services/socketNotificationService');
const servicioNotificacionesZonas = require('../services/servicioNotificacionesZonas');
const gamificacionService = require('../services/gamificacionService');

const PAGE_SIZE = 20; // Número de items por página para paginación

// --- NUEVO: Helper para construir filtro de fecha preciso ---
const buildDateFilter = (startDate, endDate, params, dateColumn) => {
  let filter = '';
  let startIndex = params.length + 1;
  if (startDate) {
    params.push(startDate);
    filter += ` AND ${dateColumn} >= $${startIndex++}`;
  }
  if (endDate) {
    params.push(endDate);
    // Agregamos '::date + interval \'1 day\'' para incluir todo el día de endDate
    filter += ` AND ${dateColumn} < ($${startIndex}::date + interval '1 day')`;
  }
  return filter;
};
// --- FIN NUEVO ---


// --- Obtener Estadísticas de Moderación (sin cambios) ---
const getModeracionStats = async (req, res) => {
  const id_lider = req.user.userId;
  try {
    const zonasResult = await db.query('SELECT nombre_distrito FROM lider_zonas_asignadas WHERE id_usuario = $1', [id_lider]);
    const zonasAsignadas = zonasResult.rows.map(z => z.nombre_distrito);

    let queryPendientes = `SELECT COUNT(*) FROM reportes WHERE estado = 'pendiente_verificacion'`;
    const paramsPendientes = [];

    if (!zonasAsignadas.includes('*') && zonasAsignadas.length > 0) {
      queryPendientes += ` AND distrito = ANY($1::text[])`;
      paramsPendientes.push(zonasAsignadas);
    } else if (!zonasAsignadas.includes('*') && zonasAsignadas.length === 0) {
      // Si no tiene zonas asignadas (y no es '*'), no puede ver pendientes
      queryPendientes = 'SELECT 0 AS count';
    }

    const pendientesCountResult = await db.query(queryPendientes, paramsPendientes);

    const historialCountResult = await db.query(
      "SELECT COUNT(*) FROM reportes WHERE id_lider_verificador = $1 AND estado IN ('verificado', 'rechazado', 'fusionado')",
      [id_lider]
    );
    const misReportesCountResult = await db.query(
      `SELECT COUNT(*) FROM (
         SELECT id FROM comentario_reportes WHERE id_reportador = $1
         UNION ALL
         SELECT id FROM usuario_reportes WHERE id_reportador = $1
       ) AS combined_reports`,
      [id_lider]
    );

    res.status(200).json({
      pendientes: parseInt(pendientesCountResult.rows[0].count, 10),
      historial: parseInt(historialCountResult.rows[0].count, 10),
      misReportes: parseInt(misReportesCountResult.rows[0].count, 10)
    });

  } catch (error) {
    console.error('Error al obtener estadísticas de moderación:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};


// --- REESCRITO: getReportesPendientes (con Zonas, Paginación, Filtros y Orden) ---
const getReportesPendientes = async (req, res) => {
  const id_lider = req.user.userId;
  const page = parseInt(req.query.page || '1', 10);
  const offset = (page - 1) * PAGE_SIZE;

  // --- MODIFICADO: Extraer sortBy ---
  const { categoriaId, prioritario, conApoyos, search, sortBy = 'fecha_asc' } = req.query;
  // --- FIN MODIFICADO ---

  try {
    const zonasResult = await db.query('SELECT nombre_distrito FROM lider_zonas_asignadas WHERE id_usuario = $1', [id_lider]);
    const zonasAsignadas = zonasResult.rows.map(z => z.nombre_distrito);

    // Si no tiene zonas asignadas (y no es '*'), no puede ver pendientes
    if (!zonasAsignadas.includes('*') && zonasAsignadas.length === 0) {
      return res.status(200).json({ reportes: [], hasMore: false, totalFiltrado: 0 }); // Devolver 0
    }

    let queryBase = `
      FROM reportes r
      JOIN categorias c ON r.id_categoria = c.id
      JOIN usuarios u ON r.id_usuario = u.id
      LEFT JOIN reportes_prioritarios rp ON r.id = rp.id_reporte
      WHERE r.estado = 'pendiente_verificacion'
    `;
    const params = [];
    let paramIndex = 1; // Start index for filters

    // Filtro de distrito (obligatorio según zonas)
    if (!zonasAsignadas.includes('*')) {
      queryBase += ` AND r.distrito = ANY($${paramIndex++}::text[])`;
      params.push(zonasAsignadas);
    }

    // Aplicar filtros opcionales (sin cambios)
    if (categoriaId) {
      queryBase += ` AND r.id_categoria = $${paramIndex++}`;
      params.push(parseInt(categoriaId, 10));
    }
    if (prioritario === 'true') {
      queryBase += ` AND rp.id_reporte IS NOT NULL`; // Filtrar por prioritarios
    }
    if (conApoyos === 'true') {
      queryBase += ` AND r.apoyos_pendientes > 0`; // Filtrar por > 0 apoyos
    }
    if (search && search.trim() !== '') {
      // Usar LOWER para búsqueda insensible a mayúsculas
      queryBase += ` AND (LOWER(r.titulo) LIKE LOWER($${paramIndex++}) OR LOWER(r.codigo_reporte) LIKE LOWER($${paramIndex++}))`;
      const searchTerm = `%${search.trim()}%`;
      params.push(searchTerm);
      params.push(searchTerm); // Añadir dos veces para OR
    }

    // --- MODIFICADO: Aplicar orden ---
    let orderByClause = 'ORDER BY r.fecha_creacion ASC'; // Default
    switch (sortBy) {
        case 'fecha_desc': orderByClause = 'ORDER BY r.fecha_creacion DESC'; break;
        case 'apoyos_desc': orderByClause = 'ORDER BY r.apoyos_pendientes DESC, r.fecha_creacion ASC'; break;
        case 'prioridad': orderByClause = 'ORDER BY rp.id_reporte DESC NULLS LAST, r.fecha_creacion ASC'; break; // Prioritarios primero
        // case 'fecha_asc': // Ya es el default
    }
    // --- FIN MODIFICADO ---


    // Consulta para obtener los datos paginados
    let queryData = `
      SELECT
        r.id, r.titulo, r.estado, to_char(r.fecha_creacion, 'DD Mon YYYY, HH24:MI') as fecha,
        r.foto_url,
        c.nombre as categoria,
        CASE WHEN r.es_anonimo = true THEN 'Anónimo' ELSE COALESCE(u.alias, u.nombre) END as autor,
        CASE WHEN rp.id_reporte IS NOT NULL THEN true ELSE false END as es_prioritario,
        r.urgencia,
        r.apoyos_pendientes
      ${queryBase}
      ${orderByClause} -- Usar orden dinámico
      LIMIT $${paramIndex++} OFFSET $${paramIndex++}
    `;
    const paramsData = [...params]; // Copiar params para la consulta de datos
    paramsData.push(PAGE_SIZE);
    paramsData.push(offset);

    // Consulta para contar el total CON LOS MISMOS FILTROS
    const queryCount = `SELECT COUNT(*) ${queryBase}`;
    // Params para count son los mismos que para los filtros (antes de LIMIT/OFFSET)
    const paramsCount = [...params];

    // Ejecutar ambas consultas en paralelo
    const [resultData, resultCount] = await Promise.all([
        db.query(queryData, paramsData),
        db.query(queryCount, paramsCount)
    ]);

    const totalReportes = parseInt(resultCount.rows[0].count, 10);
    const hasMore = (offset + resultData.rows.length) < totalReportes;

    // --- MODIFICADO: Devolver totalFiltrado ---
    res.status(200).json({ reportes: resultData.rows, hasMore: hasMore, totalFiltrado: totalReportes });
    // --- FIN MODIFICADO ---

  } catch (error) {
    console.error('Error al obtener reportes pendientes:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// --- aprobarReporte (sin cambios funcionales) ---
const aprobarReporte = async (req, res) => {
  const { id } = req.params;
  const id_lider = req.user.userId;
  const client = await db.getClient();
  let reporteAprobado = null;

  try {
    await client.query('BEGIN');

    const updateQuery = `
      UPDATE reportes
      SET estado = 'verificado', id_lider_verificador = $1, fecha_actualizacion = NOW()
      WHERE id = $2 AND estado = 'pendiente_verificacion'
      RETURNING id, id_usuario, titulo, categoria_sugerida, location, distrito, -- Añadir distrito
                (SELECT nombre FROM categorias WHERE id = reportes.id_categoria) as categoria
    `;
    const result = await client.query(updateQuery, [id_lider, id]);

    if (result.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ message: 'Reporte no encontrado o ya moderado.' });
    }
    reporteAprobado = result.rows[0];

    await client.query('COMMIT');

    // Notificaciones y Zonas Seguras (Fuera de la transacción)
    const io = req.app.get('socketio');
    const title = `Reporte Aprobado: "${reporteAprobado.titulo}"`;
    const body = 'Tu reporte ha sido verificado y ahora es visible.';
    const payload = JSON.stringify({ type: 'report_detail', id: reporteAprobado.id });

    if (reporteAprobado.id_usuario) {
      try {
        await db.query('INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo, payload) VALUES ($1, $2, $3, $4)', [reporteAprobado.id_usuario, title, body, payload]);
        socketNotificationService.sendNotification(io, reporteAprobado.id_usuario, { title, body, payload });
      } catch (notifyError) { console.error(`Error al notificar aprobación:`, notifyError); }
    }

    servicioNotificacionesZonas.verificarReporteEnZonas(io, reporteAprobado)
      .then(() => console.log(`Verificación zona segura iniciada para reporte ${reporteAprobado.id}.`))
      .catch(zoneError => console.error(`Error en verificación zona segura ${reporteAprobado.id}:`, zoneError));

    res.status(200).json({ message: 'Reporte aprobado exitosamente.' });

  } catch (error) {
    // Solo hacer rollback si aún no se hizo commit
    if (client && client.active) await client.query('ROLLBACK');
    console.error('Error al aprobar reporte:', error);
    res.status(500).json({ message: 'Error interno del servidor al aprobar.' });
  } finally {
    if (client) client.release();
  }
};

// --- rechazarReporte (sin cambios funcionales) ---
const rechazarReporte = async (req, res) => {
    const { id } = req.params;
    const id_lider = req.user.userId;
    const client = await db.getClient();
    let reporteRechazado = null;
    try {
      await client.query('BEGIN');
      const updateQuery = `
          UPDATE reportes
          SET estado = 'rechazado', id_lider_verificador = $1, fecha_actualizacion = NOW()
          WHERE id = $2 AND estado = 'pendiente_verificacion'
          RETURNING id, id_usuario, titulo
      `;
      const result = await client.query(updateQuery, [id_lider, id]);
      if (result.rows.length === 0) {
        await client.query('ROLLBACK');
        return res.status(404).json({ message: 'Reporte no encontrado o ya moderado.' });
      }
      reporteRechazado = result.rows[0];
      await client.query('COMMIT');

      // Notificar fuera de TX
      if (reporteRechazado.id_usuario) {
          const io = req.app.get('socketio');
          const title = `Reporte Rechazado: "${reporteRechazado.titulo}"`;
          const body = 'Tu reporte ha sido revisado pero no pudo ser verificado.';
          const payload = JSON.stringify({ type: 'my_reports' }); // O link a 'mi actividad'
           try {
              await db.query('INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo, payload) VALUES ($1, $2, $3, $4)', [reporteRechazado.id_usuario, title, body, payload]);
              socketNotificationService.sendNotification(io, reporteRechazado.id_usuario, { title, body, payload });
           } catch (notifyError) { console.error(`Error al notificar rechazo:`, notifyError); }
      }
      res.status(200).json({ message: 'Reporte rechazado.' });
    } catch (error) {
      if (client && client.active) await client.query('ROLLBACK');
      console.error('Error al rechazar reporte:', error);
      res.status(500).json({ message: 'Error interno del servidor.' });
    } finally {
      if (client) client.release();
    }
};

// --- MODIFICADO: getReportesModerados (con Filtros de Fecha Precisos y totalFiltrado) ---
const getReportesModerados = async (req, res) => {
  const id_lider = req.user.userId;
  const page = parseInt(req.query.page || '1', 10);
  const offset = (page - 1) * PAGE_SIZE;

  // --- MODIFICADO: Aceptar startDate y endDate ---
  const { estado, fecha, startDate, endDate } = req.query; // estado='verificado'|'rechazado'|'fusionado', fecha='hoy'|'semana'|'mes'
  // --- FIN MODIFICADO ---

  try {
    let queryBase = `
        FROM reportes r
        JOIN categorias c ON r.id_categoria = c.id
        WHERE r.id_lider_verificador = $1 AND r.estado IN ('verificado', 'rechazado', 'fusionado')
    `;
    const params = [id_lider];
    let paramIndex = 2;

    // --- MODIFICADO: Aplicar filtros ---
    if (estado && ['verificado', 'rechazado', 'fusionado'].includes(estado)) {
        queryBase += ` AND r.estado = $${paramIndex++}`;
        params.push(estado);
    }
    // Dar prioridad a startDate/endDate si existen
    if (startDate || endDate) {
       queryBase += buildDateFilter(startDate, endDate, params, 'r.fecha_actualizacion');
       // Actualizar paramIndex basado en cuántos parámetros añadió buildDateFilter
       paramIndex = params.length + 1;
    } else if (fecha) { // Usar filtro simple si no hay rango preciso
        let interval = '';
        if (fecha === 'hoy') interval = '1 day';
        else if (fecha === 'semana') interval = '7 days';
        else if (fecha === 'mes') interval = '1 month';

        if (interval) {
            // Asegurarse que fecha_actualizacion no sea NULL
            queryBase += ` AND r.fecha_actualizacion IS NOT NULL AND r.fecha_actualizacion >= NOW() - interval '${interval}'`;
        }
    }
    // --- FIN MODIFICADO ---

    const queryData = `
      SELECT r.id, r.titulo, r.estado, c.nombre as categoria,
             TO_CHAR(r.fecha_actualizacion, 'DD Mon YYYY, HH24:MI') as fecha,
             r.fecha_actualizacion as sort_date, -- Para ordenar correctamente
             r.id_reporte_original
      ${queryBase}
      ORDER BY r.fecha_actualizacion DESC NULLS LAST -- Manejar nulos
      LIMIT $${paramIndex++} OFFSET $${paramIndex++}
    `;
    const paramsData = [...params];
    paramsData.push(PAGE_SIZE);
    paramsData.push(offset);

    const queryCount = `SELECT COUNT(*) ${queryBase}`;
    const paramsCount = [...params];

    const [resultData, resultCount] = await Promise.all([
         db.query(queryData, paramsData),
         db.query(queryCount, paramsCount)
     ]);

     const totalReportes = parseInt(resultCount.rows[0].count, 10);
     const hasMore = (offset + resultData.rows.length) < totalReportes;

    // --- MODIFICADO: Devolver totalFiltrado ---
    res.status(200).json({ reportes: resultData.rows, hasMore, totalFiltrado: totalReportes });
    // --- FIN MODIFICADO ---
  } catch (error) {
    console.error('Error al obtener historial de moderación:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const getMisComentariosReportados = async (req, res) => {
  const id_reportador = req.user.userId;
  const page = parseInt(req.query.page || '1', 10);
  const offset = (page - 1) * PAGE_SIZE;
  const { fecha, startDate, endDate } = req.query;

  try {
    let queryBase = `
      FROM comentario_reportes cr
      JOIN comentarios c ON cr.id_comentario = c.id
      JOIN reportes r ON c.id_reporte = r.id -- <<< NUEVO JOIN para obtener codigo_reporte
      WHERE cr.id_reportador = $1
    `;
    const params = [id_reportador];
    let paramIndex = 2;

    // Aplicar filtro fecha (sin cambios aquí)
    if (startDate || endDate) {
        queryBase += buildDateFilter(startDate, endDate, params, 'cr.fecha_creacion');
        paramIndex = params.length + 1;
    } else if (fecha) {
        let interval = '';
        if (fecha === 'hoy') interval = '1 day';
        else if (fecha === 'semana') interval = '7 days';
        else if (fecha === 'mes') interval = '1 month';
        if (interval) queryBase += ` AND cr.fecha_creacion >= NOW() - interval '${interval}'`;
    }

    const queryData = `
      SELECT cr.id, cr.motivo, cr.estado,
             to_char(cr.fecha_creacion, 'DD Mon YYYY') as fecha,
             cr.fecha_creacion as sort_date,
             LEFT(c.comentario, 100) || CASE WHEN LENGTH(c.comentario) > 100 THEN '...' ELSE '' END as contenido,
             c.id_reporte,
             r.codigo_reporte -- <<< CAMPO AÑADIDO
      ${queryBase}
      ORDER BY cr.fecha_creacion DESC
      LIMIT $${paramIndex++} OFFSET $${paramIndex++}
    `;
    const paramsData = [...params];
    paramsData.push(PAGE_SIZE);
    paramsData.push(offset);

    const queryCount = `SELECT COUNT(*) ${queryBase}`;
    const paramsCount = [...params];

    const [resultData, resultCount] = await Promise.all([
      db.query(queryData, paramsData),
      db.query(queryCount, paramsCount)
    ]);

    const total = parseInt(resultCount.rows[0].count, 10);
    const hasMore = (offset + resultData.rows.length) < total;

    res.status(200).json({ reportes: resultData.rows, hasMore, totalFiltrado: total });
  } catch (error) {
    console.error('Error al obtener comentarios reportados:', error);
    res.status(500).json({ message: 'Error al obtener comentarios reportados.' });
  }
};

// --- MODIFICADO: getMisUsuariosReportados (con Filtro de Fecha Preciso y totalFiltrado) ---
const getMisUsuariosReportados = async (req, res) => {
  const id_reportador = req.user.userId;
  const page = parseInt(req.query.page || '1', 10);
  const offset = (page - 1) * PAGE_SIZE;
   // --- MODIFICADO: Aceptar startDate y endDate ---
  const { fecha, startDate, endDate } = req.query;
  // --- FIN MODIFICADO ---

  try {
    let queryBase = `
      FROM usuario_reportes ur
      JOIN usuarios u_reportado ON ur.id_usuario_reportado = u_reportado.id
      WHERE ur.id_reportador = $1
    `;
    const params = [id_reportador];
    let paramIndex = 2;

    // --- MODIFICADO: Aplicar filtro fecha ---
    if (startDate || endDate) {
        queryBase += buildDateFilter(startDate, endDate, params, 'ur.fecha_creacion');
        paramIndex = params.length + 1;
    } else if (fecha) {
        let interval = '';
        if (fecha === 'hoy') interval = '1 day';
        else if (fecha === 'semana') interval = '7 days';
        else if (fecha === 'mes') interval = '1 month';
        if (interval) queryBase += ` AND ur.fecha_creacion >= NOW() - interval '${interval}'`;
    }
    // --- FIN MODIFICADO ---

    const queryData = `
      SELECT ur.id, ur.motivo, ur.estado,
             to_char(ur.fecha_creacion, 'DD Mon YYYY') as fecha,
             ur.fecha_creacion as sort_date, -- Para ordenar
             COALESCE(u_reportado.alias, u_reportado.nombre) as contenido,
             ur.id_usuario_reportado
      ${queryBase}
      ORDER BY ur.fecha_creacion DESC
      LIMIT $${paramIndex++} OFFSET $${paramIndex++}
    `;
    const paramsData = [...params];
    paramsData.push(PAGE_SIZE);
    paramsData.push(offset);

    const queryCount = `SELECT COUNT(*) ${queryBase}`;
    const paramsCount = [...params];

     const [resultData, resultCount] = await Promise.all([
       db.query(queryData, paramsData),
       db.query(queryCount, paramsCount)
     ]);

     const total = parseInt(resultCount.rows[0].count, 10);
     const hasMore = (offset + resultData.rows.length) < total;

    // --- MODIFICADO: Devolver totalFiltrado ---
    res.status(200).json({ reportes: resultData.rows, hasMore, totalFiltrado: total });
    // --- FIN MODIFICADO ---
  } catch (error) {
    console.error('Error al obtener usuarios reportados:', error);
    res.status(500).json({ message: 'Error al obtener usuarios reportados.' });
  }
};

// --- solicitarRevision (Acepta motivo y ajusta validación) ---
const solicitarRevision = async (req, res) => {
  const { id: id_reporte } = req.params;
  const id_lider = req.user.userId;
  // --- NUEVO: Obtener motivo del body ---
  const { motivo } = req.body;

  // --- NUEVO: Validar motivo ---
  if (!motivo || motivo.trim() === '') {
      return res.status(400).json({ message: 'Se requiere un motivo para la solicitud.' });
  }

  const client = await db.getClient();
  try {
      await client.query('BEGIN');

      // 1. Verificar que el reporte fue moderado por este líder
      // --- MODIFICADO: Ya no se verifica el estado actual del reporte ---
      const reporteResult = await client.query(
          "SELECT id FROM reportes WHERE id = $1 AND id_lider_verificador = $2",
          [id_reporte, id_lider]
      );
      if (reporteResult.rows.length === 0) {
          await client.query('ROLLBACK');
          // Mensaje más genérico ya que no depende del estado actual
          return res.status(404).json({ message: 'Reporte no encontrado o no fue moderado por ti.' });
      }
      // --- FIN MODIFICADO ---

      // 2. Verificar si ya existe una solicitud PENDIENTE para este reporte
      const checkSolicitud = await client.query(
          "SELECT id FROM solicitudes_revision WHERE id_reporte = $1 AND estado = 'pendiente'",
          [id_reporte]
      );
      if (checkSolicitud.rows.length > 0) {
          await client.query('ROLLBACK');
          return res.status(409).json({ message: 'Ya existe una solicitud de revisión pendiente para este reporte.' });
      }

      // 3. Crear la solicitud, guardando el motivo
      // --- MODIFICADO: Añadir columna y valor 'motivo' ---
      // Asegúrate de tener la columna 'motivo' TEXT en tu tabla 'solicitudes_revision'
      const insertQuery = 'INSERT INTO solicitudes_revision (id_reporte, id_lider, motivo) VALUES ($1, $2, $3) RETURNING id';
      const insertResult = await client.query(insertQuery, [id_reporte, id_lider, motivo.trim()]);
      // --- FIN MODIFICADO ---

      await client.query('COMMIT');
      res.status(201).json({ message: 'Solicitud de revisión enviada al administrador.', solicitudId: insertResult.rows[0].id });

  } catch (error) {
      if (client && client.active) await client.query('ROLLBACK');
      console.error('Error al solicitar revisión:', error);
      res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
      if (client) client.release();
  }
};

// --- getMisSolicitudesRevision (sin cambios) ---
const getMisSolicitudesRevision = async (req, res) => {
    const id_lider = req.user.userId;
    try {
        const query = `
            SELECT sr.id, sr.estado, to_char(sr.fecha_solicitud, 'DD Mon YYYY') as fecha, r.titulo, r.id as id_reporte
            FROM solicitudes_revision sr
            JOIN reportes r ON sr.id_reporte = r.id
            WHERE sr.id_lider = $1
            ORDER BY sr.fecha_solicitud DESC
        `;
        const result = await db.query(query, [id_lider]);
        res.status(200).json(result.rows);
    } catch (error) {
        console.error('Error al obtener mis solicitudes de revisión:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

// --- editarReporteLider (sin cambios funcionales) ---
const editarReporteLider = async (req, res) => {
  const { id } = req.params;
  const id_lider = req.user.userId;
  const { titulo, descripcion, id_categoria, referencia_ubicacion, tags } = req.body;

  if (!titulo || !id_categoria) {
    return res.status(400).json({ message: 'Título y categoría son requeridos.' });
  }
  if (tags && !Array.isArray(tags)) {
      return res.status(400).json({ message: 'Las etiquetas deben ser un array de strings.' });
  }

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    // Verificar zonas asignadas
    const zonasResult = await client.query('SELECT nombre_distrito FROM lider_zonas_asignadas WHERE id_usuario = $1', [id_lider]);
    const zonasAsignadas = zonasResult.rows.map(z => z.nombre_distrito);

    let checkQuery = "SELECT id FROM reportes WHERE id = $1 AND estado = 'pendiente_verificacion'";
    const paramsCheck = [id];
    if (!zonasAsignadas.includes('*') && zonasAsignadas.length > 0) {
        checkQuery += ` AND distrito = ANY($2::text[])`;
        paramsCheck.push(zonasAsignadas);
    } else if (!zonasAsignadas.includes('*') && zonasAsignadas.length === 0) {
         await client.query('ROLLBACK');
         return res.status(403).json({ message: 'No autorizado para editar este reporte (zona).' });
    }

    const checkResult = await client.query(checkQuery, paramsCheck);
    if (checkResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ message: 'Reporte no encontrado, ya moderado o no autorizado.' });
    }

    const updateQuery = `
      UPDATE reportes SET
        titulo = $1,
        descripcion = $2,
        id_categoria = $3,
        referencia_ubicacion = $4,
        tags = $5, -- Actualizar tags
        fecha_actualizacion = NOW() -- Registrar edición
      WHERE id = $6
      RETURNING *
    `;
    const tagsToSave = (tags && tags.length > 0) ? tags : null;
    const result = await client.query(updateQuery, [
      titulo, descripcion, id_categoria, referencia_ubicacion, tagsToSave, id
    ]);

    await client.query('COMMIT');
    res.status(200).json({ message: 'Reporte actualizado por el líder.', reporte: result.rows[0] });

  } catch (error) {
    if (client && client.active) await client.query('ROLLBACK');
    console.error('Error al editar reporte (líder):', error);
    if (error.code === '23503') return res.status(400).json({ message: 'Categoría inválida.' });
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    if (client) client.release();
  }
};

const fusionarReporte = async (req, res) => {
  const { id: id_reporte_duplicado } = req.params;
  const id_lider = req.user.userId;
  const { id_reporte_original } = req.body;

  if (!id_reporte_original) {
    return res.status(400).json({ message: 'Se requiere ID del reporte original.' });
  }
  if (parseInt(id_reporte_duplicado, 10) === parseInt(id_reporte_original, 10)) {
    return res.status(400).json({ message: 'No se puede fusionar consigo mismo.' });
  }

  const client = await db.getClient();
  let infoDuplicado = null;
  let infoOriginal = null;

  try {
    await client.query('BEGIN');

    // 1. Validar reporte duplicado (zona y estado)
    const zonasResult = await client.query('SELECT nombre_distrito FROM lider_zonas_asignadas WHERE id_usuario = $1', [id_lider]);
    const zonasAsignadas = zonasResult.rows.map(z => z.nombre_distrito);
    let dupQuery = "SELECT id_usuario, codigo_reporte, titulo FROM reportes WHERE id = $1 AND estado = 'pendiente_verificacion'";
    const paramsDup = [id_reporte_duplicado];

    if (!zonasAsignadas.includes('*') && zonasAsignadas.length > 0) {
        dupQuery += ` AND distrito = ANY($2::text[])`;
        paramsDup.push(zonasAsignadas);
    } else if (!zonasAsignadas.includes('*') && zonasAsignadas.length === 0) {
         await client.query('ROLLBACK');
         return res.status(403).json({ message: 'No autorizado para fusionar este reporte (zona).' });
    }

    const dupResult = await client.query(dupQuery + ' FOR UPDATE', paramsDup);
    if (dupResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ message: 'Reporte duplicado no encontrado, ya moderado o no autorizado.' });
    }
    infoDuplicado = dupResult.rows[0];

    // 2. Validar reporte original (verificado y obtener datos)
    const origResult = await client.query(
      "SELECT id, codigo_reporte, titulo FROM reportes WHERE id = $1 AND estado = 'verificado' FOR UPDATE",
      [id_reporte_original]
    );
    if (origResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ message: 'Reporte original no encontrado o no está verificado.' });
    }
    infoOriginal = origResult.rows[0];

    // 3. Actualizar estado y link del duplicado
    await client.query(
      "UPDATE reportes SET estado = 'fusionado', id_reporte_original = $1, id_lider_verificador = $2, fecha_actualizacion = NOW() WHERE id = $3",
      [id_reporte_original, id_lider, id_reporte_duplicado]
    );

    // 4. Incrementar contador 'reportes_vinculados_count' del original
    await client.query(
      "UPDATE reportes SET reportes_vinculados_count = COALESCE(reportes_vinculados_count, 0) + 1 WHERE id = $1",
      [id_reporte_original]
    );

    // 5. Añadir comentario automático al original
    const comentario = `Reporte #${infoDuplicado.codigo_reporte || infoDuplicado.id} (${infoDuplicado.titulo}) fue fusionado con este por un líder vecinal.`;
    await client.query(
      "INSERT INTO comentarios (id_reporte, id_usuario, comentario) VALUES ($1, $2, $3)",
      [id_reporte_original, id_lider, comentario]
    );

    await client.query('COMMIT');

    // 6. Notificar al autor del duplicado (fuera de TX)
    if (infoDuplicado.id_usuario) {
      const io = req.app.get('socketio');
      const title = `Reporte Fusionado: "${infoDuplicado.titulo}"`;
      const body = `Tu reporte #${infoDuplicado.codigo_reporte} era similar a otro ya verificado (#${infoOriginal.codigo_reporte}) y ha sido fusionado.`;
      const payload = JSON.stringify({ type: 'report_detail', id: id_reporte_original });
      try {
        await db.query('INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo, payload) VALUES ($1, $2, $3, $4)', [infoDuplicado.id_usuario, title, body, payload]);
        socketNotificationService.sendNotification(io, infoDuplicado.id_usuario, { title, body, payload });
      } catch (notifyError) { console.error(`Error al notificar fusión:`, notifyError); }
    }

    res.status(200).json({ message: 'Reporte fusionado exitosamente.' });

  } catch (error) {
    if (client && client.active) await client.query('ROLLBACK');
    console.error('Error al fusionar reporte:', error);
    res.status(500).json({ message: 'Error interno del servidor al intentar fusionar.' });
  } finally {
    if (client) client.release();
  }
};

// --- eliminarReporteModeracion (sin cambios funcionales) ---
const eliminarReporteModeracion = async (req, res) => {
    const { tipo, id } = req.params; // tipo='comentario' o 'usuario', id=ID del reporte de moderación
    const id_lider = req.user.userId;

    if (tipo !== 'comentario' && tipo !== 'usuario') {
        return res.status(400).json({ message: 'Tipo de reporte inválido.' });
    }
    const tabla = tipo === 'comentario' ? 'comentario_reportes' : 'usuario_reportes';

    try {
        // Solo permitir eliminar si el estado es 'pendiente' y fue reportado por este líder
        const query = `DELETE FROM ${tabla} WHERE id = $1 AND id_reportador = $2 AND estado = 'pendiente'`;
        const result = await db.query(query, [id, id_lider]);

        if (result.rowCount === 0) {
            return res.status(404).json({ message: 'Reporte de moderación no encontrado, ya resuelto o no autorizado para eliminar.' });
        }
        res.status(200).json({ message: 'Reporte de moderación eliminado.' });
    } catch (error) {
        console.error('Error al eliminar reporte de moderación:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

// --- NUEVA FUNCIÓN: Obtener Zonas Asignadas ---
const getMisZonasAsignadas = async (req, res) => {
    const id_lider = req.user.userId;
    try {
        const zonasResult = await db.query('SELECT nombre_distrito FROM lider_zonas_asignadas WHERE id_usuario = $1 ORDER BY nombre_distrito', [id_lider]);
        const zonas = zonasResult.rows.map(z => z.nombre_distrito);
        // Devolver ['*'] si el resultado es ['*']
        res.status(200).json(zonas);
    } catch (error) {
        console.error('Error al obtener zonas asignadas:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};
// --- FIN NUEVA FUNCIÓN ---

module.exports = {
  getReportesPendientes,
  aprobarReporte,
  rechazarReporte,
  getReportesModerados,
  getMisComentariosReportados,
  getMisUsuariosReportados,
  solicitarRevision,
  getMisSolicitudesRevision,
  getModeracionStats,
  editarReporteLider,
  fusionarReporte,
  eliminarReporteModeracion,
  getMisZonasAsignadas, // <-- Exportar la nueva función
};