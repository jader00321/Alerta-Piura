const db = require('../config/db');

const checkAndAwardBadges = async (client, id_usuario) => {
  try {
    // 1. Get user's current points and badges they already have
    const userQuery = 'SELECT puntos, ARRAY(SELECT id_insignia FROM usuario_insignias WHERE id_usuario = $1) as insignias_ganadas FROM usuarios WHERE id = $1';
    const userResult = await client.query(userQuery, [id_usuario]);
    const { puntos, insignias_ganadas } = userResult.rows[0];

    // 2. Find new badges they qualify for but don't have yet
    const newBadgesQuery = 'SELECT id FROM insignias WHERE puntos_necesarios <= $1 AND NOT (id = ANY($2))';
    const newBadgesResult = await client.query(newBadgesQuery, [puntos, insignias_ganadas]);

    if (newBadgesResult.rows.length > 0) {
      // 3. Award the new badges
      const awardQuery = 'INSERT INTO usuario_insignias (id_usuario, id_insignia) VALUES ' +
        newBadgesResult.rows.map(row => `(${id_usuario}, ${row.id})`).join(',') +
        ' ON CONFLICT DO NOTHING';
      await client.query(awardQuery);
      console.log(`Usuario ${id_usuario} ha ganado ${newBadgesResult.rows.length} nueva(s) insignia(s).`);
    }
  } catch (error) {
    console.error('Error al otorgar insignias:', error);
    // We don't throw an error here to avoid rolling back the main transaction (like creating a report)
    // if only the badge awarding fails.
  }
};
// Obtener todos los reportes
const getAllReports = async (req, res) => {
  try {
    // Consulta para obtener los reportes y transformar la ubicación a un formato GeoJSON
    const { categoriaIds } = req.query;
    let query = `
      SELECT 
        r.id, r.titulo, c.nombre as categoria,
        ST_AsGeoJSON(r.location) as location 
      FROM Reportes r
      JOIN Categorias c ON r.id_categoria = c.id
      WHERE r.estado = 'verificado'
    `;
      
    const result = await db.query(query);

    // Parseamos el string de GeoJSON a un objeto JSON para cada reporte
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

const createReport = async (req, res) => {
  const id_usuario = req.user.id;
  // Get all the new fields from the request body
  const { 
    id_categoria, titulo, descripcion, es_anonimo, categoria_sugerida,
    urgencia, hora_incidente, tags, impacto, referencia_ubicacion, distrito 
  } = req.body;
  const location = JSON.parse(req.body.location);
  const foto_url = req.file ? req.file.path : null;

  if (!id_categoria || !titulo || !location) {
    return res.status(400).json({ message: 'Categoría, título y ubicación son requeridos.' });
  }

  // --- NEW: Generate a Unique Report Code ---
  const year = new Date().getFullYear();
  const reportCountResult = await db.query('SELECT COUNT(*) FROM reportes');
  const nextId = parseInt(reportCountResult.rows[0].count, 10) + 1;
  const codigo_reporte = `AP-${year}-${nextId.toString().padStart(5, '0')}`;

  const client = await db.getClient();
  try {
    await client.query('BEGIN');

    const reporteQuery = `
      INSERT INTO Reportes (
        id_usuario, id_categoria, titulo, descripcion, location, es_anonimo, 
        categoria_sugerida, foto_url, urgencia, hora_incidente, tags, 
        impacto, referencia_ubicacion, distrito, codigo_reporte
      )
      VALUES ($1, $2, $3, $4, ST_SetSRID(ST_GeomFromGeoJSON($5), 4326), $6, $7, $8, $9, $10, $11, $12, $13, $14, $15)
      RETURNING *;
    `;
    const reporteValues = [
      id_usuario, id_categoria, titulo, descripcion, JSON.stringify(location), 
      es_anonimo || false, categoria_sugerida, foto_url, urgencia, hora_incidente, 
      tags, impacto, referencia_ubicacion, distrito, codigo_reporte
    ];
    const result = await client.query(reporteQuery, reporteValues);

    const puntosQuery = 'UPDATE Usuarios SET puntos = puntos + 10 WHERE id = $1';
    await client.query(puntosQuery, [id_usuario]);
    
    await checkAndAwardBadges(client, id_usuario);

    await client.query('COMMIT');
    res.status(201).json({
      message: 'Reporte creado exitosamente y +10 puntos obtenidos.',
      reporte: result.rows[0],
    });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error al crear el reporte:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  } finally {
    client.release();
  }
};


// Apoyar un reporte
const apoyarReporte = async (req, res) => {
  const id_usuario = req.user.id;
  const { id: id_reporte } = req.params; // Obtenemos el ID del reporte de la URL

  try {
    // Intentamos insertar el apoyo. Si el usuario ya apoyó, la BD dará un error
    // de clave primaria duplicada, que capturaremos.
    const query = 'INSERT INTO Apoyos (id_reporte, id_usuario) VALUES ($1, $2)';
    await db.query(query, [id_reporte, id_usuario]);

    res.status(201).json({ message: 'Gracias por apoyar este reporte.' });
  } catch (error) {
    if (error.code === '23505') { // Error de duplicado
      // Si el usuario ya apoyó, podemos optar por quitar el apoyo
      await db.query('DELETE FROM Apoyos WHERE id_reporte = $1 AND id_usuario = $2', [id_reporte, id_usuario]);
      return res.status(200).json({ message: 'Has quitado tu apoyo a este reporte.' });
    }
    // Manejar otros errores
    console.error('Error al apoyar reporte:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const getReporteById = async (req, res) => {
  const { id } = req.params;
  try {
    const reporteQuery = `
      SELECT 
        r.id, r.titulo, r.descripcion, r.estado, r.foto_url,
        r.urgencia, r.distrito, r.referencia_ubicacion, r.tags, r.impacto, r.codigo_reporte,
        to_char(r.hora_incidente, 'HH24:MI') as hora_incidente,
        c.nombre as categoria,
        to_char(r.fecha_creacion, 'DD Mon YYYY, HH24:MI') as fecha_creacion,
        r.es_anonimo,
        CASE WHEN r.es_anonimo = true THEN 'Anónimo' ELSE COALESCE(u.alias, u.nombre) END as autor,
        u.id as id_autor,
        (SELECT COUNT(*) FROM apoyos WHERE id_reporte = r.id) as apoyos_count,
        ST_AsGeoJSON(r.location) as location -- Keep sending as GeoJSON string
      FROM Reportes r
      JOIN Usuarios u ON r.id_usuario = u.id
      JOIN Categorias c ON r.id_categoria = c.id
      WHERE r.id = $1
    `;
    const reporteResult = await db.query(reporteQuery, [id]);

    if (reporteResult.rows.length === 0) {
      return res.status(404).json({ message: 'Reporte no encontrado.' });
    }
    const reporte = reporteResult.rows[0];

    const comentariosQuery = `
      SELECT 
        c.id, c.comentario, c.id_usuario,
        to_char(c.fecha_creacion, 'DD Mon YYYY, HH24:MI') as fecha_creacion,
        COALESCE(u.alias, u.nombre) as autor,
        (SELECT COUNT(*) FROM comentario_apoyos WHERE id_comentario = c.id) as apoyos_count
      FROM Comentarios c
      JOIN Usuarios u ON c.id_usuario = u.id
      WHERE c.id_reporte = $1
      ORDER BY c.fecha_creacion ASC
    `;
    const comentariosResult = await db.query(comentariosQuery, [id]);
    
    // IMPORTANT: Send comments as a simple list, just as before.
    reporte.comentarios = comentariosResult.rows; 
    
    res.status(200).json(reporte);
  } catch (error) {
    console.error('Error al obtener el reporte por ID:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// Crear un nuevo comentario en un reporte
const createComentario = async (req, res) => {
  const { id: id_reporte } = req.params;
  const id_usuario = req.user.id;
  const { comentario } = req.body;

  if (!comentario) {
    return res.status(400).json({ message: 'El comentario no puede estar vacío.' });
  }

  try {
    const query = 'INSERT INTO Comentarios (id_reporte, id_usuario, comentario) VALUES ($1, $2, $3) RETURNING *';
    const result = await db.query(query, [id_reporte, id_usuario, comentario]);
    res.status(201).json({ message: 'Comentario añadido.', comentario: result.rows[0] });
  } catch (error) {
    console.error('Error al crear comentario:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const eliminarReporte = async (req, res) => {
  const { id: id_reporte } = req.params;
  const id_usuario = req.user.id;

  try {
    // This query is very specific: it only deletes if the ID, user ID, AND status all match.
    const query = `
      DELETE FROM reportes 
      WHERE id = $1 AND id_usuario = $2 AND estado = 'pendiente_verificacion'
      RETURNING *;
    `;
    const result = await db.query(query, [id_reporte, id_usuario]);

    if (result.rows.length === 0) {
      // This means the report didn't exist, wasn't owned by the user, or was no longer pending.
      return res.status(403).json({ message: 'No se pudo eliminar el reporte. Es posible que ya haya sido moderado.' });
    }

    res.status(200).json({ message: 'Reporte cancelado exitosamente.' });
  } catch (error) {
    console.error('Error al eliminar el reporte:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const getRiesgoZona = async (req, res) => {
  // We get the coordinates and radius from the query parameters sent by the app
  const { lat, lon, radius } = req.query; // radius is in meters

  if (!lat || !lon || !radius) {
    return res.status(400).json({ message: 'Latitud, longitud y radio son requeridos.' });
  }

  try {
    // This powerful PostGIS query finds all verified reports within the specified radius
    const query = `
      SELECT c.nombre as categoria
      FROM Reportes r
      JOIN Categorias c ON r.id_categoria = c.id
      WHERE r.estado = 'verificado' AND ST_DWithin(
        r.location,
        ST_MakePoint($1, $2)::geography,
        $3
      )
    `;
    const result = await db.query(query, [lon, lat, radius]);

    // Simple risk calculation logic: different categories have different weights
    let riesgoScore = 0;
    result.rows.forEach(reporte => {
      switch (reporte.categoria) {
        case 'Delito':
          riesgoScore += 10;
          break;
        case 'Falla de Alumbrado':
          riesgoScore += 3;
          break;
        case 'Bache':
          riesgoScore += 2;
          break;
        case 'Basura':
          riesgoScore += 1;
          break;
        default:
          riesgoScore += 1;
      }
    });

    res.status(200).json({ riesgo: riesgoScore });

  } catch (error){
    console.error('Error al calcular el riesgo de la zona:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

/*const getRiesgoZona = async (req, res) => {
  const { lat, lon, radius } = req.query;

  // --- ADD THIS DEBUGGING BLOCK ---
  console.log('--- DEBUG: Calculando Riesgo de Zona ---');
  console.log('Latitud recibida:', lat);
  console.log('Longitud recibida:', lon);
  console.log('Radio recibido (metros):', radius);
  // --- END OF DEBUGGING BLOCK ---

  if (!lat || !lon || !radius) {
    return res.status(400).json({ message: 'Latitud, longitud y radio son requeridos.' });
  }

  try {
    const query = `
      SELECT c.nombre as categoria
      FROM Reportes r
      JOIN Categorias c ON r.id_categoria = c.id
      WHERE r.estado = 'verificado' AND ST_DWithin(
        r.location,
        ST_MakePoint($1, $2)::geography,
        $3
      )
    `;
    const result = await db.query(query, [lon, lat, radius]);

    // --- ADD THIS DEBUGGING LOG ---
    console.log('Reportes encontrados en el área:', result.rows.length);
    console.log('------------------------------------');

    let riesgoScore = 0;
    result.rows.forEach(reporte => {
      switch (reporte.categoria) {
        case 'Delito':
          riesgoScore += 10;
          break;
        case 'Falla de Alumbrado':
          riesgoScore += 3;
          break;
        case 'Bache':
          riesgoScore += 2;
          break;
        case 'Basura':
          riesgoScore += 1;
          break;
        default:
          riesgoScore += 1;
      }
    });

    res.status(200).json({ riesgo: riesgoScore });

  } catch (error) {
    console.error('Error detallado al calcular riesgo:', error); // Changed to log the actual error
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};*/

const getChatHistory = async (req, res) => {
  const { id: id_reporte } = req.params;
  try {
    const query = `
      SELECT m.id, m.id_reporte, m.id_sender, m.message_text, m.timestamp, u.alias as sender_alias
      FROM chat_messages m
      JOIN usuarios u ON m.id_sender = u.id
      WHERE m.id_reporte = $1
      ORDER BY m.timestamp ASC
    `;
    const result = await db.query(query, [id_reporte]);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('Error fetching chat history:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const getZonasPeligrosas = async (req, res) => {
  try {
    const query = `
      SELECT ST_AsGeoJSON(r.location) as location
      FROM Reportes r
      JOIN Categorias c ON r.id_categoria = c.id
      WHERE r.estado = 'verificado' AND c.nombre = 'Delito'
    `;
    const result = await db.query(query);

    const locations = result.rows.map(row => JSON.parse(row.location).coordinates);
    res.status(200).json(locations);

  } catch (error) {
    console.error('Error al obtener zonas peligrosas:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

module.exports = {
  getAllReports,
  createReport,
  apoyarReporte, 
  getReporteById,
  createComentario,
  eliminarReporte,
  getRiesgoZona,
  checkAndAwardBadges,
  getChatHistory, 
  getZonasPeligrosas,
};