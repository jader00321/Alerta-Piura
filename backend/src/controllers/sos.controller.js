const db = require('../config/db');

// --- ACTIVAR SOS ---
const activateSos = async (req, res) => {
  const id_usuario = req.user.userId;
  const { lat, lon, emergencyContact, durationInSeconds } = req.body;

  try {
    await db.query('BEGIN');

    // 1. Verificar si ya tiene alerta activa
    const activeCheck = await db.query(
      "SELECT id, codigo_alerta FROM sos_alerts WHERE id_usuario = $1 AND estado = 'activo' LIMIT 1",
      [id_usuario]
    );

    if (activeCheck.rows.length > 0) {
      await db.query('COMMIT');
      const existing = activeCheck.rows[0];
      return res.status(200).json({
        success: true,
        isExisting: true,
        alertId: existing.id,
        codigo: existing.codigo_alerta,
        message: 'Alerta activa recuperada.'
      });
    }

    // 2. Generar código único
    const year = new Date().getFullYear();
    const uniqueSuffix = Date.now().toString().slice(-6);
    const randomPad = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
    const codigo_alerta = `SOS-${year}-${uniqueSuffix}${randomPad}`;

    // 3. Insertar Alerta
    const alertQuery = `
      INSERT INTO sos_alerts (id_usuario, codigo_alerta, contacto_emergencia_telefono, contacto_emergencia_mensaje, duracion_segundos)
      VALUES ($1, $2, $3, $4, $5) RETURNING *
    `;
    const alertResult = await db.query(alertQuery, [
      id_usuario,
      codigo_alerta,
      emergencyContact?.telefono,
      emergencyContact?.mensaje,
      durationInSeconds || 600
    ]);
    const newAlert = alertResult.rows[0];

    // 4. Ubicación Inicial
    if (lat && lon) {
      await db.query(
        'INSERT INTO sos_location_updates (id_alerta_sos, location) VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326))',
        [newAlert.id, lon, lat]
      );
    }

    await db.query('COMMIT');

    // 5. Notificar al Dashboard (Socket)
    const io = req.app.get('socketio');
    const userRes = await db.query('SELECT nombre, alias, telefono, email, rol FROM usuarios WHERE id = $1', [id_usuario]);
    const userData = userRes.rows[0];

    io.emit('new-sos-alert', {
      ...newAlert,
      ...userData,
      lat_inicial: lat,
      lon_inicial: lon
    });

    res.status(201).json({ success: true, alertId: newAlert.id, codigo: codigo_alerta });

  } catch (error) {
    await db.query('ROLLBACK');
    console.error('Error activando SOS:', error);
    res.status(500).json({ message: 'Error interno.' });
  }
};

// --- AGREGAR UBICACIÓN ---
const addLocationUpdate = async (req, res) => {
  const { alertId } = req.params;
  const { lat, lon } = req.body;
  try {
    await db.query(
      'INSERT INTO sos_location_updates (id_alerta_sos, location) VALUES ($1, ST_SetSRID(ST_MakePoint($2, $3), 4326))',
      [alertId, lon, lat]
    );
    const io = req.app.get('socketio');
    io.emit('sos-location-update', { alertId: parseInt(alertId), lat, lon });
    res.status(200).json({ message: 'OK' });
  } catch (error) {
    res.status(500).json({ message: 'Error ubicación' });
  }
};

// --- DESACTIVAR SOS (Usuario) ---
const deactivateSos = async (req, res) => {
  const { alertId } = req.params;
  try {
    const result = await db.query(
      "UPDATE sos_alerts SET estado = 'finalizado', fecha_fin = NOW() WHERE id = $1 RETURNING *",
      [alertId]
    );
    if (result.rowCount > 0) {
        const io = req.app.get('socketio');
        io.emit('sos-alert-ended', { id: parseInt(alertId) });
    }
    res.status(200).json({ message: 'Desactivada.' });
  } catch (error) {
    res.status(500).json({ message: 'Error interno.' });
  }
};

// --- ACTUALIZAR ESTADO (Admin - Puente de Mando CRÍTICO) ---
const updateSosStatus = async (req, res) => {
    const { id } = req.params;
    const { estado_atencion, revisada, estado } = req.body; // 'estado' es el general (activo/finalizado)
    const io = req.app.get('socketio');
    
    try {
        await db.query('BEGIN');

        // 1. Actualización dinámica de campos
        const fields = [];
        const values = [];
        let queryIndex = 1;

        if (estado_atencion) {
            fields.push(`estado_atencion = $${queryIndex++}`);
            values.push(estado_atencion);
        }
        if (revisada !== undefined) {
            fields.push(`revisada = $${queryIndex++}`);
            values.push(revisada);
        }
        // Si el admin manda finalizar
        if (estado === 'finalizado') {
            fields.push(`estado = 'finalizado'`);
            fields.push(`fecha_fin = NOW()`);
        }

        values.push(id); // ID al final

        if (fields.length === 0) {
            await db.query('ROLLBACK');
            return res.status(400).json({ message: 'Nada que actualizar.' });
        }

        const query = `UPDATE sos_alerts SET ${fields.join(', ')} WHERE id = $${queryIndex} RETURNING *`;
        const result = await db.query(query, values);

        if (result.rows.length === 0) {
            await db.query('ROLLBACK');
            return res.status(404).json({ message: 'Alerta no encontrada.' });
        }

        const updatedAlert = result.rows[0];
        await db.query('COMMIT');

        // --- 2. LÓGICA DE INTERRUPCIÓN REMOTA ---
        // Si la alerta pasó a 'finalizado', enviamos la orden de paro a la App
        if (updatedAlert.estado === 'finalizado') {
            const id_usuario = updatedAlert.id_usuario;
            if (id_usuario) {
                // Emitimos a la sala privada del usuario "user_{id}"
                // El SocketService de la App escucha 'stopSos'
                const userRoom = `user_${id_usuario}`;
                io.to(userRoom).emit('stopSos', { 
                    alertId: parseInt(id), 
                    reason: 'admin_stop',
                    message: 'La autoridad ha finalizado tu alerta.'
                });
                console.log(`🛑 [ADMIN STOP] Alerta ${id} finalizada. Orden enviada a sala ${userRoom}`);
            }
            // También avisamos al dashboard general que terminó
            io.emit('sos-alert-ended', { id: parseInt(id) });
        } 
        
        // 3. Notificar actualización general de datos (para la lista y detalles)
        io.emit('sos-alert-updated', updatedAlert);

        res.status(200).json(updatedAlert);

    } catch (error) {
        await db.query('ROLLBACK');
        console.error('Error updating SOS status:', error);
        res.status(500).json({ message: 'Error interno.' });
    }
};

// ... (Otras funciones de lectura: getAllSosAlerts, getSosLocationHistory, deleteSosAlert se mantienen igual) ...
const getAllSosAlerts = async (req, res) => {
  try {
    const result = await db.query(`
      SELECT sa.*, u.alias, u.nombre, u.telefono, u.email 
      FROM sos_alerts sa 
      JOIN usuarios u ON sa.id_usuario = u.id 
      ORDER BY sa.fecha_inicio DESC
    `);
    res.status(200).json(result.rows);
  } catch (error) { res.status(500).json({ message: 'Error.' }); }
};

const getSosLocationHistory = async (req, res) => {
  const { alertId } = req.params;
  try {
    const result = await db.query(`SELECT ST_Y(location) as lat, ST_X(location) as lon, fecha_registro FROM sos_location_updates WHERE id_alerta_sos = $1 ORDER BY fecha_registro ASC`, [alertId]);
    res.status(200).json(result.rows);
  } catch (error) { res.status(500).json({ message: 'Error.' }); }
};

const deleteSosAlert = async (req, res) => {
    const { id } = req.params;
    try {
        await db.query('DELETE FROM sos_alerts WHERE id = $1', [id]);
        const io = req.app.get('socketio');
        io.emit('sos-alert-deleted', { id: parseInt(id) });
        res.status(200).json({ message: 'Eliminada.' });
    } catch (e) { res.status(500).json({ message: 'Error.' }); }
};

module.exports = {
  activateSos,
  addLocationUpdate,
  deactivateSos,
  updateSosStatus, // <-- ACTUALIZADO
  getAllSosAlerts,
  getSosLocationHistory,
  deleteSosAlert
};