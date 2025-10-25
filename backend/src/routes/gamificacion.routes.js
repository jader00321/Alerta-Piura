// backend/src/routes/gamificacion.routes.js
const { Router } = require('express');
const gamificacionController = require('../controllers/gamificacion.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();

// Todas las rutas de gamificación requieren autenticación
router.use(authMiddleware);

// Ruta para obtener el progreso de todas las insignias
router.get('/insignias', gamificacionController.getProgresoInsignias);

module.exports = router;