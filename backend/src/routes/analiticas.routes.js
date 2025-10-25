const { Router } = require('express');
const analiticasController = require('../controllers/analiticas.controller');
const authMiddleware = require('../middleware/auth.middleware');
const premiumMiddleware = require('../middleware/premium.middleware');

const router = Router();

// Aplicamos ambos middlewares a todas las rutas de este archivo
// 1. El usuario debe estar autenticado (authMiddleware)
// 2. El usuario debe tener un plan premium O ser reportero O ser admin (premiumMiddleware)
router.use(authMiddleware);
router.use(premiumMiddleware);

// Rutas para el panel analítico móvil
router.get('/por-categoria', analiticasController.getReportesPorCategoria);
router.get('/por-distrito', analiticasController.getReportesPorDistrito);
router.get('/tendencia', analiticasController.getTendenciaReportes);

// Ruta para la exportación de PDF
router.post('/exportar-pdf', analiticasController.solicitarExportacionPDF);

module.exports = router;