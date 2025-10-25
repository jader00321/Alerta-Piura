// backend/src/routes/perfil.routes.js
const { Router } = require('express');
const express = require('express');
const perfilController = require('../controllers/perfil.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();
const jsonParser = express.json();

router.use(authMiddleware);

// Rutas existentes
router.get('/me', perfilController.getMiPerfil);
router.get('/me/reportes', perfilController.getMisReportes); // Devuelve más datos
router.get('/me/apoyos', perfilController.getMisApoyos); // Devuelve más datos
router.get('/me/comentarios', perfilController.getMisComentarios); // Devuelve más datos
router.get('/me/conversaciones', perfilController.getMisConversaciones);
router.get('/me/notificaciones', perfilController.getMisNotificaciones);
router.put('/me', jsonParser, perfilController.updateMyProfile);
router.put('/me/email', jsonParser, perfilController.updateMyEmail);
router.put('/me/password', jsonParser, perfilController.updateMyPassword);
router.put('/me/notificaciones/mark-all-read', perfilController.marcarTodasComoLeidas);
router.get('/me/payment-history', perfilController.getPaymentHistory);
router.get('/me/invoices/:transactionId', perfilController.getInvoiceDetails);
router.get('/me/estadisticas/resumen', perfilController.getMisEstadisticasResumen);
router.get('/me/estadisticas/por-categoria', perfilController.getMisReportesPorCategoria);
router.get('/me/estadisticas/por-mes', perfilController.getMisReportesPorMes);
router.get('/me/estadisticas/ubicaciones', perfilController.getMisReportesUbicaciones);
router.get('/me/zonas-seguras', perfilController.getMisZonasSeguras);
router.post('/me/zonas-seguras', jsonParser, perfilController.crearZonaSegura);
router.delete('/me/zonas-seguras/:id', perfilController.eliminarZonaSegura);

// Ruta modificada
router.post('/postular-lider', jsonParser, perfilController.postularComoLider); // Acepta más datos

// Nueva ruta
router.get('/me/stats/actividad', perfilController.getStatsActividad); // Para contadores "Mi Actividad"

module.exports = router;