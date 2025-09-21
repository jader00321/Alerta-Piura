const db = require('../config/db');

// Reportar una cuenta de usuario
const reportarUsuario = async (req, res) => {
    const { id: id_usuario_reportado } = req.params;
    const { id: id_reportador } = req.user;
    const { motivo } = req.body;

    if (!motivo) {
        return res.status(400).json({ message: 'Se requiere un motivo para reportar.'});
    }

    try {
        const query = 'INSERT INTO usuario_reportes (id_usuario_reportado, id_reportador, motivo) VALUES ($1, $2, $3)';
        await db.query(query, [id_usuario_reportado, id_reportador, motivo]);
        res.status(201).json({ message: 'Usuario reportado. Un administrador revisará el caso.' });
    } catch (error) {
        console.error('Error al reportar usuario:', error);
        res.status(500).json({ message: 'Error interno del servidor.' });
    }
};

module.exports = {
    reportarUsuario,
};