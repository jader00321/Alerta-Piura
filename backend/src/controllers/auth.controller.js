const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const register = async (req, res) => {
  const { nombre, alias, email, password, telefono } = req.body;
  if (!nombre || !email || !password) {
    return res.status(400).json({ message: 'Nombre, email y contraseña son requeridos.' });
  }
  try {
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);
    // Corrección: Usar nombre de tabla en minúsculas para consistencia
    const query = 'INSERT INTO usuarios (nombre, alias, email, password_hash, telefono) VALUES ($1, $2, $3, $4, $5) RETURNING id, nombre, email, alias';
    const values = [nombre, alias, email, password_hash, telefono];
    const result = await db.query(query, values);
    res.status(201).json({ message: 'Usuario registrado exitosamente.', user: result.rows[0] });
  } catch (error) {
    if (error.code === '23505') {
      if (error.constraint === 'usuarios_email_unique') return res.status(409).json({ message: 'Este correo electrónico ya está en uso.' });
      if (error.constraint === 'usuarios_alias_unique') return res.status(409).json({ message: 'Este alias ya está en uso.' });
    }
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const login = async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email y contraseña son requeridos.' });
  }
  try {
    // Corrección: Usar nombre de tabla en minúsculas
    const userResult = await db.query('SELECT id, nombre, alias, email, password_hash, rol, status, id_plan_suscripcion FROM usuarios WHERE email = $1', [email]);
    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'El correo electrónico no está registrado.' });
    }
    const user = userResult.rows[0];
    if (user.status === 'suspendido') {
      return res.status(403).json({ message: 'Esta cuenta ha sido deshabilitada.' });
    }
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ message: 'La contraseña es incorrecta.' });
    }

    const payload = {
      user: {
        userId: user.id,
        email: user.email,
        alias: user.alias || user.nombre,
        rol: user.rol,
        planId: user.id_plan_suscripcion
      }
    };

    // Mejora: Manejo de errores más robusto y explícito en la firma del token
    jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' }, (error, token) => {
      if (error) {
        console.error('Error al firmar el token JWT:', error);
        return res.status(500).json({ message: 'Error al generar la sesión.' });
      }
      res.status(200).json({ token });
    });
  } catch (error) {
    console.error('Error en la función de login:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const verifyPassword = async (req, res) => {
  const { password } = req.body;
  // CORRECCIÓN: Usar 'userId' en lugar de 'id'
  const id_usuario = req.user.userId;

  if (!password) {
    return res.status(400).json({ message: 'Se requiere la contraseña.' });
  }

  try {
    // Corrección: Usar nombre de tabla en minúsculas
    const userResult = await db.query('SELECT password_hash FROM usuarios WHERE id = $1', [id_usuario]);
    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'Usuario no encontrado.' });
    }
    
    const isMatch = await bcrypt.compare(password, userResult.rows[0].password_hash);

    if (!isMatch) {
      return res.status(401).json({ message: 'La contraseña es incorrecta.' });
    }

    res.status(200).json({ success: true, message: 'Contraseña verificada.' });
  } catch (error) {
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const refreshToken = async (req, res) => {
  const userId = req.user.userId;
  try {
    // 1. Obtenemos los datos más frescos del usuario desde la base de datos.
    const userResult = await db.query(
      'SELECT id, nombre, alias, email, rol, status, id_plan_suscripcion, fecha_fin_suscripcion FROM usuarios WHERE id = $1',
      [userId]
    );

    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'Usuario no encontrado.' });
    }
    const user = userResult.rows[0];

    // 2. Lógica de verificación de expiración
    let planIdFinal = user.id_plan_suscripcion;
    if (user.id_plan_suscripcion && user.fecha_fin_suscripcion && new Date(user.fecha_fin_suscripcion) < new Date()) {
      // Si el plan ha expirado, lo limpiamos en la BD y en el token.
      await db.query('UPDATE usuarios SET id_plan_suscripcion = NULL, fecha_fin_suscripcion = NULL WHERE id = $1', [userId]);
      planIdFinal = null;
    }

    // 3. Construimos el nuevo payload del token.
    const payload = {
      user: {
        userId: user.id,
        email: user.email,
        alias: user.alias || user.nombre,
        rol: user.rol,
        planId: planIdFinal
      }
    };

    // 4. Firmamos y enviamos el nuevo token.
    jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '7d' }, (error, token) => {
      if (error) {
        return res.status(500).json({ message: 'Error al refrescar la sesión.' });
      }
      res.status(200).json({ token });
    });

  } catch (error) {
    console.error('Error en refreshToken:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

module.exports = {
  register,
  login,
  verifyPassword,
  refreshToken,
};