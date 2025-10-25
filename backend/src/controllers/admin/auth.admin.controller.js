// backend/src/controllers/admin/auth.admin.controller.js
const db = require('../../config/db'); // <-- Adjusted path
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const login = async (req, res) => {
  // ... (login function code remains the same) ...
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ message: 'Email y contraseña son requeridos.' });
  }
  try {
    const userResult = await db.query("SELECT * FROM Usuarios WHERE email = $1 AND (rol = 'admin' OR rol = 'reportero')", [email]);
    if (userResult.rows.length === 0) {
      return res.status(403).json({ message: 'Acceso denegado. Credenciales incorrectas o sin privilegios.' });
    }
    const user = userResult.rows[0];
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(403).json({ message: 'Acceso denegado. Credenciales incorrectas.' });
    }
    const payload = { user: { userId: user.id, rol: user.rol, alias: user.alias || user.nombre } };
    const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '8h' });
    res.json({ token, user: payload.user });
  } catch (error) {
    console.error("Error en login de admin:", error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

module.exports = {
  login,
};