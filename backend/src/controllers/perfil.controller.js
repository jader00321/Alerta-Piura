const db = require('../config/db');

// Obtener el perfil del usuario autenticado
const getMiPerfil = async (req, res) => {
  // Obtenemos el ID del usuario desde el token (gracias al middleware)
  const id_usuario = req.user.id;

  try {
    // Consulta para obtener los datos del usuario
    const userQuery = 'SELECT id, nombre, alias, email, puntos, fecha_registro FROM Usuarios WHERE id = $1';
    const userResult = await db.query(userQuery, [id_usuario]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'Usuario no encontrado.' });
    }
    const perfil = userResult.rows[0];

    // Consulta para obtener las insignias ganadas por el usuario
    const insigniasQuery = `
      SELECT i.nombre, i.descripcion, i.icono_url 
      FROM Insignias i
      INNER JOIN Usuario_Insignias ui ON i.id = ui.id_insignia
      WHERE ui.id_usuario = $1
    `;
    const insigniasResult = await db.query(insigniasQuery, [id_usuario]);
    
    // Añadimos las insignias al objeto de perfil
    perfil.insignias = insigniasResult.rows;

    res.status(200).json(perfil);
  } catch (error) {
    console.error('Error al obtener el perfil:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// Obtener los reportes creados por el usuario logueado
const getMisReportes = async (req, res) => {
  const id_usuario = req.user.id;
  try {
    const query = "SELECT id, titulo, estado, to_char(fecha_creacion, 'DD Mon YYYY') as fecha FROM reportes WHERE id_usuario = $1 ORDER BY fecha_creacion DESC";
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener mis reportes.' });
  }
};

// Obtener los reportes que el usuario ha apoyado
const getMisApoyos = async (req, res) => {
  const id_usuario = req.user.id;
  try {
    const query = `
      SELECT r.id, r.titulo, r.estado, to_char(r.fecha_creacion, 'DD Mon YYYY') as fecha 
      FROM reportes r
      JOIN apoyos a ON r.id = a.id_reporte
      WHERE a.id_usuario = $1
      ORDER BY a.fecha_creacion DESC
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener mis apoyos.' });
  }
};

// Obtener los reportes que el usuario ha comentado
const getMisComentarios = async (req, res) => {
  const id_usuario = req.user.id;
  try {
    // Usamos DISTINCT ON(r.id) para asegurar que cada reporte aparezca solo una vez
    const query = `
      SELECT DISTINCT ON (r.id) r.id, r.titulo, r.estado, to_char(r.fecha_creacion, 'DD Mon YYYY') as fecha
      FROM reportes r
      JOIN comentarios c ON r.id = c.id_reporte
      WHERE c.id_usuario = $1
      ORDER BY r.id, c.fecha_creacion DESC
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener mis comentarios.' });
  }
};

const getMisConversaciones = async (req, res) => {
  const id_usuario = req.user.id;
  try {
    const query = `
      SELECT DISTINCT ON (r.id) r.id, r.titulo
      FROM reportes r
      JOIN chat_messages cm ON r.id = cm.id_reporte
      WHERE r.id_usuario = $1
      ORDER BY r.id, cm.timestamp DESC
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener conversaciones.' });
  }
};

const updateMyProfile = async (req, res) => {
  const { nombre, alias, telefono } = req.body;
  const id_usuario = req.user.id;

  if (!nombre) {
    return res.status(400).json({ message: 'El nombre es requerido.' });
  }

  try {
    const query = 'UPDATE usuarios SET nombre = $1, alias = $2, telefono = $3 WHERE id = $4 RETURNING id, nombre, alias, telefono';
    const result = await db.query(query, [nombre, alias, telefono, id_usuario]);
    res.status(200).json({ message: 'Perfil actualizado con éxito.', user: result.rows[0] });
  } catch (error) {
    if (error.code === '23505' && error.constraint === 'usuarios_alias_unique') {
      return res.status(409).json({ message: 'Ese alias ya está en uso. Por favor, elige otro.' });
    }
    res.status(500).json({ message: 'Error al actualizar el perfil.' });
  }
};

const updateMyEmail = async (req, res) => {
  const { newEmail, password } = req.body;
  const id_usuario = req.user.id;

  if (!newEmail || !password) {
    return res.status(400).json({ message: 'El nuevo email y la contraseña son requeridos.' });
  }

  try {
    // Verify user's current password
    const userResult = await db.query('SELECT password_hash FROM usuarios WHERE id = $1', [id_usuario]);
    const isMatch = await bcrypt.compare(password, userResult.rows[0].password_hash);

    if (!isMatch) {
      return res.status(403).json({ message: 'La contraseña actual es incorrecta.' });
    }

    // If password is correct, update the email
    await db.query('UPDATE usuarios SET email = $1 WHERE id = $2', [newEmail, id_usuario]);
    res.status(200).json({ message: 'Email actualizado con éxito. Por favor, vuelve a iniciar sesión.' });

  } catch (error) {
    if (error.code === '23505') { // Unique violation
      return res.status(409).json({ message: 'El nuevo correo electrónico ya está en uso.' });
    }
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const updateMyPassword = async (req, res) => {
  const { currentPassword, newPassword } = req.body;
  const id_usuario = req.user.id;

  if (!currentPassword || !newPassword) {
    return res.status(400).json({ message: 'Todos los campos son requeridos.' });
  }

  try {
    // Verify user's current password
    const userResult = await db.query('SELECT password_hash FROM usuarios WHERE id = $1', [id_usuario]);
    const isMatch = await bcrypt.compare(currentPassword, userResult.rows[0].password_hash);

    if (!isMatch) {
      return res.status(403).json({ message: 'La contraseña actual es incorrecta.' });
    }

    // If password is correct, hash the new password and update it
    const salt = await bcrypt.genSalt(10);
    const new_password_hash = await bcrypt.hash(newPassword, salt);
    await db.query('UPDATE usuarios SET password_hash = $1 WHERE id = $2', [new_password_hash, id_usuario]);
    
    res.status(200).json({ message: 'Contraseña actualizada con éxito. Por favor, vuelve a iniciar sesión.' });
  } catch (error) {
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const getMisNotificaciones = async (req, res) => {
  const id_usuario = req.user.id;
  try {
    // We also get a count of unread messages for the badge
    const query = `
      SELECT *, (SELECT COUNT(*) FROM notificaciones WHERE id_usuario_receptor = $1 AND leido = FALSE) as unread_count
      FROM notificaciones
      WHERE id_usuario_receptor = $1
      ORDER BY fecha_envio DESC
    `;
    const result = await db.query(query, [id_usuario]);
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener notificaciones.' });
  }
};

module.exports = {
  getMiPerfil,
  getMisReportes,   
  getMisApoyos,
  getMisComentarios,
  getMisConversaciones,
  updateMyProfile,
  updateMyEmail,
  updateMyPassword,
  getMisNotificaciones,
};