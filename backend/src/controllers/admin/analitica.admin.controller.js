// backend/src/controllers/admin/analitica.admin.controller.js
const db = require('../../config/db'); // <-- Adjusted path

const getDynamicDateGrouping = (startDate, endDate) => {
    if (!startDate || !endDate) {
        // Sin filtro (o filtro 'Todos'), agrupar por mes
        // Usamos 'r.fecha_creacion' asumiendo que 'r' será el alias
        return { sql: "to_char(r.fecha_creacion, 'YYYY-MM')", type: 'month' };
    }
    
    try {
        const start = new Date(startDate);
        const end = new Date(endDate);
        // Añadir 1 para incluir el día final en el cálculo
        const diffDays = (end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24) + 1;

        if (diffDays <= 2) {
            // 2 días o menos (ej. "Hoy"), agrupar por hora
            return { sql: "to_char(r.fecha_creacion, 'YYYY-MM-DD HH24:00')", type: 'hour' };
        } else if (diffDays <= 60) {
            // Entre 3 y 60 días (ej. "Semana" o "Mes"), agrupar por día
            return { sql: "to_char(r.fecha_creacion, 'YYYY-MM-DD')", type: 'day' };
        } else {
            // Más de 60 días, agrupar por mes
            return { sql: "to_char(r.fecha_creacion, 'YYYY-MM')", type: 'month' };
        }
    } catch (e) {
        // Fallback seguro
        return { sql: "to_char(r.fecha_creacion, 'YYYY-MM')", type: 'month' };
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
const getDashboardStats = async (req, res) => {
  // ... (Esta función se mantiene sin cambios, no usa filtros de fecha) ...
  try {
    const [
      userCount, premiumUserCount, // <-- Premium Users
      reportesPendientes, reportesVerificados, reportesRechazados, reportesOcultos, // <-- Rechazados/Ocultos
      comentariosReportados, usuariosReportados,
      activeSosAlerts,
      officialCategoriesCount, // <-- Official Categories
      suggestedCategoriesCount, // <-- Suggested Categories
      pendingRoleRequestsCount // <-- Role Requests
    ] = await Promise.all([
      db.query('SELECT COUNT(*) FROM usuarios'),
      // Contar usuarios con plan activo
      db.query(`SELECT COUNT(*) FROM usuarios WHERE id_plan_suscripcion IS NOT NULL AND fecha_fin_suscripcion > NOW()`),
      db.query("SELECT COUNT(*) FROM reportes WHERE estado = 'pendiente_verificacion'"),
      db.query("SELECT COUNT(*) FROM reportes WHERE estado = 'verificado'"),
      db.query("SELECT COUNT(*) FROM reportes WHERE estado = 'rechazado'"), // <-- Nuevo
      db.query("SELECT COUNT(*) FROM reportes WHERE estado = 'oculto'"), // <-- Nuevo
      db.query("SELECT COUNT(*) FROM comentario_reportes WHERE estado = 'pendiente'"),
      db.query("SELECT COUNT(*) FROM usuario_reportes WHERE estado = 'pendiente'"),
      db.query("SELECT COUNT(*) FROM sos_alerts WHERE estado = 'activo'"),
      db.query("SELECT COUNT(*) FROM categorias WHERE nombre != 'Otro'"), // <-- Nuevo
      // Contar sugerencias únicas que NO son categorías oficiales
      db.query(`SELECT COUNT(DISTINCT LOWER(categoria_sugerida)) FROM reportes
                WHERE categoria_sugerida IS NOT NULL AND categoria_sugerida != ''
                AND LOWER(categoria_sugerida) NOT IN (SELECT LOWER(nombre) FROM categorias)`), // <-- Nuevo
      db.query("SELECT COUNT(*) FROM solicitudes_rol WHERE estado = 'pendiente'") // <-- Nuevo
    ]);

    res.status(200).json({
      totalUsuarios: parseInt(userCount.rows[0].count, 10),
      usuariosPremium: parseInt(premiumUserCount.rows[0].count, 10), // <-- Nuevo
      reportesPendientes: parseInt(reportesPendientes.rows[0].count, 10),
      reportesVerificados: parseInt(reportesVerificados.rows[0].count, 10),
      reportesRechazados: parseInt(reportesRechazados.rows[0].count, 10), // <-- Nuevo
      reportesOcultos: parseInt(reportesOcultos.rows[0].count, 10), // <-- Nuevo
      comentariosReportados: parseInt(comentariosReportados.rows[0].count, 10),
      usuariosReportados: parseInt(usuariosReportados.rows[0].count, 10),
      alertasSosActivas: parseInt(activeSosAlerts.rows[0].count, 10),
      categoriasOficiales: parseInt(officialCategoriesCount.rows[0].count, 10), // <-- Nuevo
      categoriasSugeridas: parseInt(suggestedCategoriesCount.rows[0].count, 10), // <-- Nuevo
      solicitudesRolPendientes: parseInt(pendingRoleRequestsCount.rows[0].count, 10), // <-- Nuevo
    });
  } catch (error) {
    console.error("Error fetching dashboard stats:", error);
    res.status(500).json({ message: 'Error al obtener estadísticas.' });
  }
};

// --- MODIFICADO ---
const getReportsGroupedByStatus = async (req, res) => {
    // 1. Añadir recepción de query params
    const { startDate, endDate } = req.query;
    const params = [];
    // 2. Usar el helper de filtro (sin alias 'r', usa nombre de tabla)
    const dateFilter = buildDateFilter(startDate, endDate, params, 'reportes.fecha_creacion');

    try {
        const query = `
            SELECT
                CASE estado
                    WHEN 'pendiente_verificacion' THEN 'Pendiente'
                    WHEN 'verificado' THEN 'Verificado'
                    WHEN 'rechazado' THEN 'Rechazado'
                    WHEN 'oculto' THEN 'Oculto'
                    ELSE 'Otro' -- Por si acaso
                END as name, -- 'name' es esperado por recharts PieChart
                COUNT(*) as value -- 'value' es esperado por recharts PieChart
            FROM reportes
            WHERE 1=1 ${dateFilter} -- 3. Aplicar el filtro
            GROUP BY estado
            ORDER BY estado; -- Opcional: ordenar
        `;
        // 4. Pasar params a la consulta
        const result = await db.query(query, params);
        res.status(200).json(result.rows);
    } catch (error) {
        console.error("Error fetching reports grouped by status:", error);
        res.status(500).json({ message: 'Error al obtener reportes agrupados por estado.' });
    }
};

// --- MODIFICADO ---
const getReportsByDay = async (req, res) => {
  const { startDate, endDate } = req.query;
  const params = [];

  // Lógica para determinar el rango
  let startRange, endRange;
  if (startDate && endDate) {
      startRange = new Date(startDate);
      endRange = new Date(endDate);
  } else {
      // Default: últimos 7 días si no hay rango
      endRange = new Date();
      startRange = new Date();
      startRange.setDate(endRange.getDate() - 6);
  }

  // Asegurar que las fechas estén en formato YYYY-MM-DD para la query
  const startParam = startRange.toISOString().split('T')[0];
  const endParam = endRange.toISOString().split('T')[0];

  params.push(startParam, endParam);

  try {
    const query = `
      SELECT
        -- Formatea la fecha como YYYY-MM-DD para consistencia, el frontend la reformateará
        to_char(d.day, 'YYYY-MM-DD') AS date,
        COUNT(r.id) as count
      FROM
        -- Genera una serie de fechas desde los parámetros
        generate_series(
          $1::date,
          $2::date,
          '1 day'
        ) AS d(day)
      LEFT JOIN
        -- Une con reportes basándose solo en la fecha (ignora la hora)
        reportes r ON date_trunc('day', r.fecha_creacion) = d.day
      GROUP BY
        d.day -- Agrupa por cada día generado
      ORDER BY
        d.day ASC; -- Ordena cronológicamente
    `;
    const result = await db.query(query, params);
    // Devuelve las filas [{ date: 'YYYY-MM-DD', count: N }, ...]
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error fetching reports by day:", error);
    res.status(500).json({ message: 'Error al obtener datos del gráfico de reportes por día.' });
  }
};

const getHeatmapData = async (req, res) => {
    // ... (getHeatmapData function code remains the same) ...
      try {
    const query = `SELECT ST_Y(location) as lat, ST_X(location) as lon FROM reportes WHERE estado = 'verificado' AND location IS NOT NULL`;
    const result = await db.query(query);
    const heatmapData = result.rows.map(r => [r.lat, r.lon, 1]);
    res.status(200).json(heatmapData);
  } catch (error) {
    console.error("Error en getHeatmapData:", error);
    res.status(500).json({ message: 'Error al obtener datos del mapa de calor.' });
  }
};
const getReportCoordinates = async (req, res) => {
    // ... (getReportCoordinates function code remains the same) ...
      try {
    const query = `SELECT ST_Y(location) as lat, ST_X(location) as lon FROM reportes WHERE estado = 'verificado' AND location IS NOT NULL`;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error("Error en getReportCoordinates:", error);
    res.status(500).json({ message: 'Error al obtener coordenadas de reportes.' });
  }
};

// --- ESTA FUNCIÓN YA ESTABA BIEN (ACEPTA FILTROS) ---
const getReportsByCategory = async (req, res) => {
    // ... (getReportsByCategory function code remains the same) ...
      const { startDate, endDate } = req.query;
  const params = [];
  const dateFilter = buildDateFilter(startDate, endDate, params); // Usa alias 'r' por defecto
  try {
    const query = `SELECT c.nombre as name, COUNT(r.id) as value FROM reportes r JOIN categorias c ON r.id_categoria = c.id WHERE 1=1 ${dateFilter} GROUP BY c.nombre ORDER BY value DESC`;
    const result = await db.query(query, params);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getReportsByCategory:', error);
    res.status(500).json({ message: 'Error al obtener reportes por categoría.' });
  }
};

// --- ESTA FUNCIÓN YA ESTABA BIEN (ACEPTA FILTROS) ---
const getReportsByStatus = async (req, res) => {
    // ... (getReportsByStatus function code remains the same) ...
      const { startDate, endDate } = req.query;
  const params = [];
  const dateFilter = buildDateFilter(startDate, endDate, params); // Usa alias 'r' por defecto
  try {
    const query = `SELECT estado as name, COUNT(id) as value FROM reportes r WHERE 1=1 ${dateFilter} GROUP BY estado`;
    const result = await db.query(query, params);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getReportsByStatus:', error);
    res.status(500).json({ message: 'Error al obtener reportes por estado.' });
  }
};

const getReportTrend = async (req, res) => {
    const { startDate, endDate } = req.query;
    const params = [];
    const dateFilter = buildDateFilter(startDate, endDate, params, 'r.fecha_creacion');
    // 1. Obtener la agrupación dinámica
    const grouping = getDynamicDateGrouping(startDate, endDate);

    try {
        const query = `
            SELECT 
                ${grouping.sql} as name, 
                COUNT(r.id) as value 
            FROM reportes r 
            WHERE 1=1 ${dateFilter} 
            GROUP BY name 
            ORDER BY name ASC
        `;
        const result = await db.query(query, params);
        // 2. Devolver los datos Y el tipo de agrupación
        res.status(200).json({ data: result.rows, groupingType: grouping.type });
    } catch (error) {
        console.error('Error en getReportTrend:', error);
        res.status(500).json({ message: 'Error al obtener tendencia de reportes.' });
    }
};

const getVerificationTimeTrend = async (req, res) => {
    const { startDate, endDate } = req.query;
    const params = [];
    const dateFilter = buildDateFilter(startDate, endDate, params, 'r.fecha_creacion');
    // 1. Obtener la agrupación dinámica
    const grouping = getDynamicDateGrouping(startDate, endDate);

    try {
        const query = `
            SELECT
                ${grouping.sql} as name,
                AVG(EXTRACT(EPOCH FROM (r.fecha_actualizacion - r.fecha_creacion))) as avg_seconds
            FROM reportes r
            WHERE r.estado IN ('verificado', 'rechazado')
            AND r.fecha_actualizacion IS NOT NULL
            AND r.id_lider_verificador IS NOT NULL
            ${dateFilter}
            GROUP BY name
            ORDER BY name ASC;
        `;
        const result = await db.query(query, params);
        
        // 2. Formatear la data (se mantiene igual)
        const formattedResult = result.rows.map(row => ({
             name: row.name,
             // Asegurar que el valor sea numérico, 0 si es null
             value: parseFloat((parseFloat(row.avg_seconds || 0) / 3600).toFixed(1))
        }));
        
        // 3. Devolver los datos Y el tipo de agrupación
        res.status(200).json({ data: formattedResult, groupingType: grouping.type });

    } catch (error) {
        console.error('Error en getVerificationTimeTrend:', error);
        res.status(500).json({ message: 'Error al calcular la tendencia del tiempo de verificación.' });
    }
};

// --- NO MODIFICADO (No se filtra por fecha) ---
const getUsersByStatus = async (req, res) => {
    // ... (getUsersByStatus function code remains the same) ...
      try {
    const query = "SELECT status as name, COUNT(id) as value FROM usuarios GROUP BY status";
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getUsersByStatus:', error);
    res.status(500).json({ message: 'Error al obtener usuarios por estado.' });
  }
};

// --- ESTA FUNCIÓN YA ESTABA BIEN (ACEPTA FILTROS) ---
const getAverageVerificationTime = async (req, res) => {
    // ... (getAverageVerificationTime function code remains the same) ...
        const { startDate, endDate } = req.query;
    const params = [];
    const dateFilter = buildDateFilter(startDate, endDate, params, 'r.fecha_creacion');
    try {
        const query = `
            SELECT AVG(EXTRACT(EPOCH FROM (r.fecha_actualizacion - r.fecha_creacion))) as avg_seconds
            FROM reportes r WHERE r.estado IN ('verificado', 'rechazado') AND r.fecha_actualizacion IS NOT NULL
            AND r.id_lider_verificador IS NOT NULL ${dateFilter}
        `;
        const result = await db.query(query, params);
        const avg_seconds = result.rows[0].avg_seconds;
        if (avg_seconds === null || isNaN(avg_seconds)) {
            return res.status(200).json({ avg_time_formatted: 'N/A' });
        }
        const totalMinutes = Math.floor(avg_seconds / 60);
        const hours = Math.floor(totalMinutes / 60);
        const minutes = totalMinutes % 60;
        res.status(200).json({ avg_time_formatted: `${hours}h ${minutes}m` });
    } catch (error) {
        console.error('Error en getAverageVerificationTime:', error);
        res.status(500).json({ message: 'Error al calcular el tiempo de verificación.' });
    }
};

// --- ESTA FUNCIÓN YA ESTABA BIEN (ACEPTA FILTROS) ---
const getLeaderPerformance = async (req, res) => {
    // ... (getLeaderPerformance function code remains the same) ...
      const { startDate, endDate } = req.query;
  const params = [];
  const dateFilter = buildDateFilter(startDate, endDate, params, 'r.fecha_creacion');
  try {
    const query = `
      SELECT u.alias as name, COUNT(r.id) as value FROM reportes r JOIN usuarios u ON r.id_lider_verificador = u.id
      WHERE u.rol = 'lider_vecinal' AND r.id_lider_verificador IS NOT NULL ${dateFilter}
      GROUP BY u.alias ORDER BY value DESC LIMIT 10
    `;
    const result = await db.query(query, params);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error en getLeaderPerformance:', error);
    res.status(500).json({ message: 'Error al obtener rendimiento de líderes.' });
  }
};

// --- ESTA FUNCIÓN YA ESTABA BIEN (ACEPTA FILTROS) ---
const getReportsByDistrict = async (req, res) => {
    // ... (getReportsByDistrict function code remains the same) ...
        const { startDate, endDate } = req.query;
    const params = [];
    const dateFilter = buildDateFilter(startDate, endDate, params); // Usa alias 'r' por defecto
    try {
        const query = `SELECT distrito as name, COUNT(id) as value FROM reportes r WHERE distrito IS NOT NULL AND distrito <> '' ${dateFilter} GROUP BY distrito ORDER BY value DESC`;
        const result = await db.query(query, params);
        res.status(200).json(result.rows);
    } catch (error) {
        console.error('Error en getReportsByDistrict:', error);
        res.status(500).json({ message: 'Error al obtener reportes por distrito.' });
    }
};

const getAverageResolutionTime = async (req, res) => {
    // ... (getAverageResolutionTime function code remains the same) ...
      // Nota: Esta función parece duplicada con getAverageVerificationTime.
  // Mantendré la lógica original aquí. Revisa si necesitas ambas.
  try {
    const query = `SELECT AVG(fecha_actualizacion - fecha_creacion) as avg_time FROM reportes WHERE estado IN ('verificado', 'rechazado') AND fecha_actualizacion IS NOT NULL`;
    const result = await db.query(query);
    res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error("Error en getAverageResolutionTime:", error);
    res.status(500).json({ message: 'Error al calcular el tiempo de resolución.' });
  }
};
const runPredictionSimulation = async (req, res) => {
    // ... (runPredictionSimulation function code remains the same) ...
      const { categoryName, increasePercent } = req.body;
  let prediction = { title: "Predicción Basada en Simulación", text: "No se encontró correlación.", confidence: "Baja" };
  if (categoryName === 'Falla de Alumbrado') {
    const predictedCrimeIncrease = (increasePercent * 0.30).toFixed(0);
    prediction.text = `Aumento del ${increasePercent}% en ${categoryName} podría correlacionarse con ~${predictedCrimeIncrease}% más reportes de "Delito" en 2-4 semanas.`;
    prediction.confidence = "Media";
  } else if (categoryName === 'Basura') {
    const predictedHealthIncrease = (increasePercent * 0.15).toFixed(0);
    prediction.text = `Aumento del ${increasePercent}% en ${categoryName} podría llevar a ~${predictedHealthIncrease}% más quejas de salud/plagas en 3-6 semanas.`;
    prediction.confidence = "Baja";
  } else if (categoryName === 'Bache') {
    const predictedAccidentIncrease = (increasePercent * 0.45).toFixed(0);
    prediction.text = `Aumento del ${increasePercent}% en ${categoryName} podría correlacionarse con ~${predictedAccidentIncrease}% más accidentes menores.`;
    prediction.confidence = "Media";
  }
  res.status(200).json(prediction);
};

const aprobarSolicitudRevision = async (req, res) => {
    const { idSolicitud } = req.params; // ID de la solicitud_revision
    const client = await db.getClient();
    try {
        await client.query('BEGIN');

        // 1. Actualizar estado de la solicitud
        const solicitudResult = await client.query(
            "UPDATE solicitudes_revision SET estado = 'aprobada' WHERE id = $1 AND estado = 'pendiente' RETURNING id_reporte, id_lider",
            [idSolicitud]
        );
        if (solicitudResult.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ message: 'Solicitud no encontrada o ya procesada.' });
        }
        const { id_reporte, id_lider } = solicitudResult.rows[0];

        // 2. Cambiar estado del reporte a pendiente_verificacion
        await client.query(
            "UPDATE reportes SET estado = 'pendiente_verificacion', fecha_actualizacion = NOW() WHERE id = $1",
            [id_reporte]
        );

        // (Opcional) Registrar en moderation_log
        // await client.query("INSERT INTO moderation_log (...) VALUES (...)");

        await client.query('COMMIT');

        // Notificar al líder (fuera de TX)
        const io = req.app.get('socketio');
        const title = `Solicitud Aprobada`;
        const body = `Tu solicitud de revisión para el reporte #${id_reporte} fue aprobada. El reporte está nuevamente pendiente.`;
        const payload = JSON.stringify({ type: 'verification_panel' }); // Navegar al panel
        try {
            await db.query('INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo, payload) VALUES ($1, $2, $3, $4)', [id_lider, title, body, payload]);
            socketNotificationService.sendNotification(io, id_lider, { title, body, payload });
        } catch (notifyError) { console.error(`Error al notificar aprobación solicitud:`, notifyError); }

        res.status(200).json({ message: 'Solicitud aprobada. El reporte está pendiente de verificación.' });
    } catch (error) {
        if (client && client.active) await client.query('ROLLBACK');
        console.error('Error al aprobar solicitud:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    } finally {
        if (client) client.release();
    }
};

const rechazarSolicitudRevision = async (req, res) => {
    const { idSolicitud } = req.params; // ID de la solicitud_revision
    // Asumiendo que el admin puede incluir un motivo de rechazo (opcional)
    const { motivoRechazo } = req.body;
    try {
        // Solo actualizamos la solicitud, no el reporte
        const solicitudResult = await db.query(
            "UPDATE solicitudes_revision SET estado = 'rechazada' WHERE id = $1 AND estado = 'pendiente' RETURNING id_reporte, id_lider",
            [idSolicitud]
        );
        if (solicitudResult.rows.length === 0) {
            return res.status(404).json({ message: 'Solicitud no encontrada o ya procesada.' });
        }
        const { id_reporte, id_lider } = solicitudResult.rows[0];

        // Notificar al líder
        const io = req.app.get('socketio');
        const title = `Solicitud Rechazada`;
        const body = `Tu solicitud de revisión para el reporte #${id_reporte} fue rechazada. ${motivoRechazo || ''}`;
        const payload = JSON.stringify({ type: 'moderation_history' }); // Navegar al historial
        try {
            await db.query('INSERT INTO notificaciones (id_usuario_receptor, titulo, cuerpo, payload) VALUES ($1, $2, $3, $4)', [id_lider, title, body, payload]);
            socketNotificationService.sendNotification(io, id_lider, { title, body, payload });
        } catch (notifyError) { console.error(`Error al notificar rechazo solicitud:`, notifyError); }

        res.status(200).json({ message: 'Solicitud rechazada.' });
    } catch (error) {
        console.error('Error al rechazar solicitud:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

module.exports = {
  getDashboardStats,
  getVerificationTimeTrend,
  getReportsGroupedByStatus,
  getReportsByDay,
  getHeatmapData,
  getReportCoordinates,
  getReportsByCategory,
  getReportsByStatus,
  getUsersByStatus,
  getAverageVerificationTime,
  getLeaderPerformance,
  getReportsByDistrict,
  getAverageResolutionTime,
  runPredictionSimulation,
  getReportTrend,
  aprobarSolicitudRevision,
  rechazarSolicitudRevision,
};