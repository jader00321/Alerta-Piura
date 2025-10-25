// backend/src/controllers/sos.controller.js
const db = require('../config/db');

const activateSos = async (req, res) => {
  const id_usuario = req.user.userId;
  // --- MODIFICADO: Recibir duración y contacto ---
  const { lat, lon, emergencyContact, durationInSeconds } = req.body;

  try {
    const year = new Date().getFullYear();
    const countResult = await db.query('SELECT COUNT(*) FROM sos_alerts');
    const nextId = parseInt(countResult.rows[0].count, 10) + 1;
    const codigo_alerta = `SOS-${year}-${nextId.toString().padStart(5, '0')}`;

    const alertQuery = `
      INSERT INTO sos_alerts (id_usuario, codigo_alerta, contacto_emergencia_telefono, contacto_emergencia_mensaje, duracion_segundos) 
      VALUES ($1, $2, $3, $4, $5) RETURNING *
    `;
    // --- MODIFICADO: Usar los nuevos parámetros ---
    const alertResult = await db.query(alertQuery, [
      id_usuario,
      codigo_alerta,
      emergencyContact?.telefono, // Usar 'telefono' (coincide con tu mapa_view)
      emergencyContact?.mensaje, // Usar 'mensaje'
      durationInSeconds || 600 // Default 10 min si no se envía
    ]);
    const newAlertRaw = alertResult.rows[0];

    if (lat && lon) {
      const locationQuery = `
        INSERT INTO sos_location_updates (id_alerta_sos, location) 
        VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326))
      `;
      await db.query(locationQuery, [newAlertRaw.id, lon, lat]);
    }
    
    // Lógica de SMS simulado (actualizada para usar 'telefono' y 'mensaje')
    if (emergencyContact && emergencyContact.telefono) {
      const userResult = await db.query('SELECT nombre, telefono FROM usuarios WHERE id = $1', [id_usuario]);
      const user = userResult.rows[0];
      const messageBody = `ALERTA SOS de ${user.nombre || 'Usuario de Reporta Piura'} (${user.telefono || 'N/A'}). Ubicación: http://googleusercontent.com/maps?q=${lat},${lon}. Mensaje: "${emergencyContact.mensaje || '¡Necesito ayuda urgente!'}"`;
      
      await db.query(
        'INSERT INTO simulated_sms_log (id_usuario_sos, contacto_nombre, contacto_telefono, mensaje) VALUES ($1, $2, $3, $4)',
        [id_usuario, emergencyContact.nombre, emergencyContact.telefono, messageBody] // 'nombre' puede ser null, está bien
      );
    }

    const userResultForSocket = await db.query('SELECT nombre, alias, email, telefono, rol FROM usuarios WHERE id = $1', [id_usuario]);
    
    const newAlert = {
      ...newAlertRaw,
      ...userResultForSocket.rows[0],
      latitude: lat,
      longitude: lon
    };

    const io = req.app.get('socketio');
    io.emit('new-sos-alert', newAlert); // Notifica al panel de admin

    // --- MODIFICADO: Devolver la alerta completa (incluyendo el ID) ---
    res.status(201).json({ message: 'Alerta SOS activada.', alert: newAlert });
  } catch (error) {
    console.error("Error al activar SOS:", error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const addLocationUpdate = async (req, res) => {
  const { alertId } = req.params;
  const { lat, lon } = req.body;

  if (!lat || !lon) return res.status(400).json({ message: 'Coordenadas requeridas.' });

  try {
    const locationQuery = `INSERT INTO sos_location_updates (id_alerta_sos, location) VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326))`;
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

const deactivateSos = async (req, res) => {
    const { alertId } = req.params;
    const userId = req.user.userId;

    try {
        const query = "UPDATE sos_alerts SET estado = 'finalizado', fecha_fin = CURRENT_TIMESTAMP WHERE id = $1 AND id_usuario = $2 RETURNING *";
        const result = await db.query(query, [alertId, userId]);

        if (result.rows.length === 0) {
            return res.status(403).json({ message: 'No autorizado para desactivar esta alerta o la alerta no existe.' });
        }

        const io = req.app.get('socketio');
        // Notifica al admin panel que la alerta se actualizó
        io.emit('sos-alert-updated', result.rows[0]);
        
        res.status(200).json({ message: 'Alerta SOS finalizada por el usuario.' });
    } catch (error) {
        console.error('Error al desactivar SOS por el usuario:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

const getAllSosAlerts = async (req, res) => {
  // ... (Sin cambios)
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
  // ... (Sin cambios)
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
  const { id } = req.params; // id de la alerta
  const { estado, estado_atencion, revisada } = req.body;
  const io = req.app.get('socketio');

  try {
    const fields = [];
    const values = [];
    let queryIndex = 1;

    if (estado !== undefined) {
      fields.push(`estado = $${queryIndex++}`);
      values.push(estado);
      // --- MODIFICADO: Añadir fecha_fin si se finaliza ---
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
    const updatedAlert = result.rows[0];

    // --- LÓGICA DE SOCKET MODIFICADA ---
    if (estado === 'finalizado' && updatedAlert) {
      // 1. Obtener el id_usuario de la alerta
      const id_usuario = updatedAlert.id_usuario;
      if (id_usuario) {
        // 2. Emitir evento 'stopSos' a la sala privada de ESE usuario
        const userRoom = `user_${id_usuario}`;
        io.to(userRoom).emit('stopSos', { alertId: parseInt(id, 10) });
        console.log(`Admin finalizó SOS. Enviando 'stopSos' a la sala ${userRoom}`);
      }
    }
    
    // Notificar a todos los clientes (paneles de admin) de la actualización
    io.emit('sos-alert-updated', updatedAlert);
    res.status(200).json(updatedAlert);
  } catch (error) {
    console.error('Error al actualizar alerta SOS (admin):', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};


module.exports = {
  activateSos,
  addLocationUpdate,
  getAllSosAlerts,
  getSosLocationHistory,
  updateSosStatus,
  deactivateSos,
};