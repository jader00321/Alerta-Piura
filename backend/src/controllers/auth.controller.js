const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Lógica para registrar un usuario
const register = async (req, res) => {
  // Add 'telefono' to the destructured body
  const { nombre, alias, email, password, telefono } = req.body;

  if (!nombre || !email || !password) {
    return res.status(400).json({ message: 'Nombre, email y contraseña son requeridos.' });
  }

  try {
    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    // Update the INSERT query to include the new field
    const query = 'INSERT INTO Usuarios (nombre, alias, email, password_hash, telefono) VALUES ($1, $2, $3, $4, $5) RETURNING id, nombre, email, alias';
    const values = [nombre, alias, email, password_hash, telefono];
    
    const result = await db.query(query, values);
    const newUser = result.rows[0];

    res.status(201).json({
      message: 'Usuario registrado exitosamente.',
      user: newUser,
    });
  } catch (error) {
    console.error('Error en el registro:', error);
    // --- ERROR HANDLING IMPROVED ---
    // Check if it's a unique constraint violation
    if (error.code === '23505') {
      if (error.constraint === 'usuarios_email_unique') {
        return res.status(409).json({ message: 'Este correo electrónico ya está en uso.' });
      }
      if (error.constraint === 'usuarios_alias_unique') {
        return res.status(409).json({ message: 'Este alias ya está en uso. Por favor, elige otro.' });
      }
    }
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

// Lógica para iniciar sesión
const login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Email y contraseña son requeridos.' });
  }

  try {
    // Paso 1: Buscar al usuario por su email
    const userResult = await db.query('SELECT * FROM Usuarios WHERE email = $1', [email]);
    
    // Si no se encuentra ningún usuario, el email no está registrado.
    if (userResult.rows.length === 0) {
      return res.status(404).json({ message: 'El correo electrónico no está registrado.' });
    }
    
    const user = userResult.rows[0];

    // Paso 2: Si se encuentra el usuario, verificar su estado.
    if (user.status === 'suspendido') {
      return res.status(403).json({ message: 'Esta cuenta ha sido deshabilitada.' });
    }

    // Paso 3: Si está activo, verificar la contraseña.
    const isMatch = await bcrypt.compare(password, user.password_hash);

    if (!isMatch) {
      return res.status(401).json({ message: 'La contraseña es incorrecta.' });
    }

    // Paso 4: Si todo es correcto, crear y enviar el token.
    const payload = {
      user: {
        id: user.id,
        email: user.email,
        alias: user.alias,
        nombre: user.nombre,
        rol: user.rol
      }
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: '7d' },
      (error, token) => {
        if (error) throw error;
        res.status(200).json({ token });
      }
    );

  } catch (error) {
    console.error('Error en el login:', error);
    res.status(500).json({ message: 'Error interno del servidor.' });
  }
};

const verifyPassword = async (req, res) => {
  const { password } = req.body;
  const id_usuario = req.user.id;

  if (!password) {
    return res.status(400).json({ message: 'Se requiere la contraseña.' });
  }

  try {
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

module.exports = {
  register,
  login,
  verifyPassword,
};