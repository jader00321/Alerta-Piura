const { Router } = require('express');
const liderController = require('../controllers/lider.controller');
const authMiddleware = require('../middleware/auth.middleware');
// Podríamos crear un middleware de rol específico, pero por ahora usaremos el de auth.
// La lógica de si el usuario es líder estará en la app.

const router = Router();

// Todas las rutas de líder requieren autenticación
router.use(authMiddleware);

router.get('/reportes-pendientes', liderController.getReportesPendientes);
router.put('/reportes/:id/aprobar', liderController.aprobarReporte);
router.put('/reportes/:id/rechazar', liderController.rechazarReporte);
router.get('/reportes-moderados', liderController.getReportesModerados);
router.get('/me/comentarios-reportados', liderController.getMisComentariosReportados);
router.get('/me/usuarios-reportados', liderController.getMisUsuariosReportados);
router.post('/reportes/:id/solicitar-revision', liderController.solicitarRevision);
router.get('/me/solicitudes-revision', liderController.getMisSolicitudesRevision); 

module.exports = router;