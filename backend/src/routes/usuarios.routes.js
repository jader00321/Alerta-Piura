const { Router } = require('express');
const express = require('express');
const usuariosController = require('../controllers/usuarios.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();
const jsonParser = express.json();

router.use(authMiddleware);

// Ruta para reportar un usuario
router.post('/:id/reportar', jsonParser, usuariosController.reportarUsuario);

module.exports = router;