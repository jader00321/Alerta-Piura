const db = require('../config/db');

const activateSos = async (req, res) => {
  const id_usuario = req.user.id;
  const { lat, lon, emergencyContact, durationInSeconds } = req.body;// App will now send contact info

  try {
    const year = new Date().getFullYear();
    const countResult = await db.query('SELECT COUNT(*) FROM sos_alerts');
    const nextId = parseInt(countResult.rows[0].count, 10) + 1;
    const codigo_alerta = `SOS-${year}-${nextId.toString().padStart(5, '0')}`;

    // Guardar la alerta CON el contacto de emergencia y el código
    const alertQuery = `
      INSERT INTO sos_alerts (id_usuario, codigo_alerta, contacto_emergencia_telefono, contacto_emergencia_mensaje, duracion_segundos) 
      VALUES ($1, $2, $3, $4, $5) RETURNING *
    `;
    const alertResult = await db.query(alertQuery, [id_usuario, codigo_alerta, emergencyContact?.telefono, emergencyContact?.mensaje, durationInSeconds]);
    const newAlertRaw = alertResult.rows[0];

    if (lat && lon) {
      const locationQuery = `
        INSERT INTO sos_location_updates (id_alerta_sos, location) 
        VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326))
      `;
      await db.query(locationQuery, [newAlertRaw.id, lon, lat]);
    }
    
    // --- SIMULATED SMS LOGIC ---
    if (emergencyContact && emergencyContact.telefono) {
      const userResult = await db.query('SELECT nombre, telefono FROM usuarios WHERE id = $1', [id_usuario]);
      const user = userResult.rows[0];

      const messageBody = `ALERTA SOS de ${user.nombre || 'Usuario de Alerta Piura'} (${user.telefono || 'N/A'}). Última ubicación conocida: http://maps.google.com/maps?q=${lat},${lon}. Mensaje personalizado: "${emergencyContact.mensaje || '¡Necesito ayuda urgente!'}"`;
      
      console.log(`--- SIMULATED SMS SENT ---`);
      console.log(`TO: ${emergencyContact.telefono}`);
      console.log(`MESSAGE: ${messageBody}`);
      
      await db.query(
        'INSERT INTO simulated_sms_log (id_usuario_sos, contacto_nombre, contacto_telefono, mensaje) VALUES ($1, $2, $3, $4)',
        [id_usuario, emergencyContact.nombre, emergencyContact.telefono, messageBody]
      );
    }

    const userResultForSocket = await db.query('SELECT nombre, alias, email, telefono, rol FROM usuarios WHERE id = $1', [id_usuario]);
    
    const newAlert = {
      ...newAlertRaw,
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

    if (estado === 'finalizado') {
      io.emit('stopSos', { alertId: parseInt(id, 10) });
    }
    
    // Notify all clients of the update
    io.emit('sos-alert-updated', result.rows[0]);
    res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error('Error al actualizar alerta SOS:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const deactivateSos = async (req, res) => {
    const { alertId } = req.params;
    const io = req.app.get('socketio');
    try {
        const query = "UPDATE sos_alerts SET estado = 'finalizado', fecha_fin = CURRENT_TIMESTAMP WHERE id = $1 RETURNING *";
        const result = await db.query(query, [alertId]);
        if (result.rows.length > 0) {
            io.emit('sos-alert-updated', result.rows[0]);
        }
        res.status(200).json({ message: 'Alerta SOS finalizada.' });
    } catch (error) {
        res.status(500).json({ message: 'Error al desactivar SOS.' });
    }
};

const updateStatus = async (req, res) => {
  const { id } = req.params;
  const { estado, estado_atencion, revisada } = req.body;
  const io = req.app.get('socketio');

  try {
    const fields = [];
    const values = [];
    let queryIndex = 1;

    if (estado !== undefined) {
      fields.push(`estado = $${queryIndex++}`);
      values.push(estado);
      // --- THIS IS THE KEY FIX ---
      // If we are finalizing the alert, also set the end time.
      if (estado === 'finalizado') {
        fields.push(`fecha_fin = CURRENT_TIMESTAMP`);
      }
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
    
    // --- THIS IS THE SECOND KEY FIX ---
    // If the admin was the one who finished the alert, send a specific
    // command to the mobile app to force it to stop tracking.
    if (estado === 'finalizado') {
      io.emit('stopSos', { alertId: parseInt(id, 10) });
    }
    
    // Notify all web clients of the general update
    io.emit('sos-alert-updated', result.rows[0]);
    res.status(200).json(result.rows[0]);
  } catch (error) {
    console.error('Error al actualizar alerta SOS:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

module.exports = {
  activateSos,
  addLocationUpdate,
  getActiveSosAlerts,
  getAllSosAlerts,
  getSosLocationHistory,
  updateSosStatus,
  deactivateSos,
  updateStatus,
};