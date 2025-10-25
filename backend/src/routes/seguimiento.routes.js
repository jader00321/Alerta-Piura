// backend/src/routes/seguimiento.routes.js
const { Router } = require('express');
const seguimientoController = require('../controllers/seguimiento.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();

router.use(authMiddleware);

// Ruta modificada (devuelve más datos)
router.get('/mis-seguimientos', seguimientoController.getMisReportesSeguidos);

// Rutas existentes
router.post('/reporte/:id_reporte/seguir', seguimientoController.seguirReporte);
router.delete('/reporte/:id_reporte/dejar-de-seguir', seguimientoController.dejarDeSeguirReporte);
router.get('/reporte/:id_reporte/verificar', seguimientoController.verificarSeguimiento);

module.exports = router;