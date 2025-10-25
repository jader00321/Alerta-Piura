// backend/src/routes/lider.routes.js
const { Router } = require('express');
const express = require('express');
const liderController = require('../controllers/lider.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();
const jsonParser = express.json();

router.use(authMiddleware); // Todas requieren auth

// Rutas modificadas (aceptan ?page=X y otros filtros)
router.get('/reportes-pendientes', liderController.getReportesPendientes);
router.get('/reportes-moderados', liderController.getReportesModerados);
router.get('/me/comentarios-reportados', liderController.getMisComentariosReportados);
router.get('/me/usuarios-reportados', liderController.getMisUsuariosReportados);

// Rutas existentes
router.put('/reportes/:id/aprobar', liderController.aprobarReporte);
router.put('/reportes/:id/rechazar', liderController.rechazarReporte);
router.post('/reportes/:id/solicitar-revision', liderController.solicitarRevision);
router.get('/me/solicitudes-revision', liderController.getMisSolicitudesRevision);

// Nuevas rutas
router.get('/stats/moderacion', liderController.getModeracionStats);
router.put('/reporte/:id', jsonParser, liderController.editarReporteLider);
router.post('/reporte/:id/fusionar', jsonParser, liderController.fusionarReporte);
router.delete('/moderacion/:tipo/:id', liderController.eliminarReporteModeracion);

// --- NUEVA RUTA ---
router.get('/me/zonas-asignadas', liderController.getMisZonasAsignadas);
// --- FIN NUEVA RUTA ---

module.exports = router;