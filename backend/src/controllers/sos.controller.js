const db = require('../config/db');

const activateSos = async (req, res) => {
  const id_usuario = req.user.id;
  // The app will now send the contact info in the body
  const { lat, lon, emergencyContact } = req.body;

  try {
    const alertQuery = 'INSERT INTO sos_alerts (id_usuario) VALUES ($1) RETURNING *';
    const alertResult = await db.query(alertQuery, [id_usuario]);
    const newAlertRaw = alertResult.rows[0];

    if (lat && lon) {
      const locationQuery = `
        INSERT INTO sos_location_updates (id_alerta_sos, location) 
        VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326))
      `;
      await db.query(locationQuery, [newAlertRaw.id, lon, lat]);
    }
    
    // --- NEW: SIMULATED SMS LOGIC ---
    if (emergencyContact && emergencyContact.telefono) {
      const userResult = await db.query('SELECT nombre, telefono FROM usuarios WHERE id = $1', [id_usuario]);
      const user = userResult.rows[0];

      const messageBody = `ALERTA SOS de ${user.nombre} (${user.telefono || 'N/A'}). Ubicación: http://maps.google.com/?q=${lat},${lon}. Mensaje: "${emergencyContact.mensaje || '¡Necesito ayuda urgente!'}"`;
      
      // Log to console AND save to database
      console.log(`--- SIMULATED SMS ---`);
      console.log(`TO: ${emergencyContact.telefono}`);
      console.log(`MESSAGE: ${messageBody}`);
      console.log(`---------------------`);
      
      await db.query(
        'INSERT INTO simulated_sms_log (id_usuario_sos, contacto_nombre, contacto_telefono, mensaje) VALUES ($1, $2, $3, $4)',
        [id_usuario, emergencyContact.nombre, emergencyContact.telefono, messageBody]
      );
    }
    // --- END OF NEW LOGIC ---

    const userResultForSocket = await db.query('SELECT nombre, alias, email FROM usuarios WHERE id = $1', [id_usuario]);
    
    const newAlert = {
      id: newAlertRaw.id,
      id_usuario: newAlertRaw.id_usuario,
      estado: newAlertRaw.estado,
      fecha_inicio: newAlertRaw.fecha_inicio,
      usuario: userResultForSocket.rows[0],
      latitude: lat,
      longitude: lon
    };

    const io = req.app.get('socketio');
    io.emit('new-sos-alert', newAlert);

    res.status(201).json({ message: 'Alerta SOS activada.', alert: newAlert });
  } catch (error) {
    console.error("Error al activar SOS:", error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const addLocationUpdate = async (req, res) => {
  const { alertId } = req.params;
  const { lat, lon } = req.body;

  if (!lat || !lon) {
    return res.status(400).json({ message: 'Coordenadas requeridas.' });
  }

  try {
    const locationQuery = `
      INSERT INTO sos_location_updates (id_alerta_sos, location) 
      VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326))
    `;
    await db.query(locationQuery, [alertId, lon, lat]);
    
    const io = req.app.get('socketio');
    io.emit('sos-location-update', {
      alertId: parseInt(alertId, 10),
      location: { lat, lon }
    });

    res.status(200).json({ message: 'Ubicación actualizada.' });
  } catch (error) {
    res.status(500).json({ message: 'Error al actualizar ubicación.' });
  }
};

const getActiveSosAlerts = async (req, res) => {
  try {
    const query = `
      SELECT sa.id, sa.id_usuario, sa.estado, sa.fecha_inicio, u.nombre, u.alias, u.email
      FROM sos_alerts sa
      JOIN usuarios u ON sa.id_usuario = u.id
      WHERE sa.estado = 'activo'
      ORDER BY sa.fecha_inicio DESC
    `;
    const result = await db.query(query);
    
    const alerts = result.rows.map(row => ({
      id: row.id,
      id_usuario: row.id_usuario,
      estado: row.estado,
      fecha_inicio: row.fecha_inicio,
      usuario: {
        nombre: row.nombre,
        alias: row.alias,
        email: row.email
      }
    }));

    res.status(200).json(alerts);
  } catch (error) {
    console.error("Error fetching active SOS alerts:", error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const getAllSosAlerts = async (req, res) => {
  try {
    const query = `
      SELECT sa.*, u.alias, u.nombre, u.email, u.telefono, u.rol
      FROM sos_alerts sa
      JOIN usuarios u ON sa.id_usuario = u.id
      ORDER BY sa.fecha_inicio DESC
    `;
    const result = await db.query(query);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener alertas SOS.' });
  }
};

const getSosLocationHistory = async (req, res) => {
  const { alertId } = req.params;
  try {
    const query = `
      SELECT ST_Y(location) as lat, ST_X(location) as lon
      FROM sos_location_updates
      WHERE id_alerta_sos = $1
      ORDER BY fecha_registro ASC
    `;
    const result = await db.query(query, [alertId]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener historial de ubicación.' });
  }
};

const updateSosStatus = async (req, res) => {
  const { id } = req.params;
  const { estado, estado_atencion, revisada } = req.body;
  const io = req.app.get('socketio');

  try {
    // Build the query dynamically based on the fields provided
    const fields = [];
    const values = [];
    let queryIndex = 1;

    if (estado !== undefined) {
      fields.push(`estado = $${queryIndex++}`);
      values.push(estado);
    }
    if (estado_atencion !== undefined) {
      fields.push(`estado_atencion = $${queryIndex++}`);
      values.push(estado_atencion);
    }
    if (revisada !== undefined) {
      fields.push(`revisada = $${queryIndex++}`);
      values.push(revisada);
    }
    
    if (fields.length === 0) {
      return res.status(400).json({ message: 'No fields to update.' });
    }
    
    values.push(id);
    const query = `UPDATE sos_alerts SET ${fields.join(', ')} WHERE id = $${queryIndex} RETURNING *`;
    const result = await db.query(query, values);
    
    // Notify all clients of the update
    io.emit('sos-alert-updated', result.rows[0]);
    res.status(200).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({ message: 'Error al actualizar alerta SOS.' });
  }
};

module.exports = {
  activateSos,
  addLocationUpdate,
  getActiveSosAlerts,
  getAllSosAlerts,
  getSosLocationHistory,
  updateSosStatus,
};