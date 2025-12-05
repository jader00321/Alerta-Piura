// backend/src/routes/analiticas.routes.js
const { Router } = require('express');
const analiticasController = require('../controllers/analiticas.controller');
const authMiddleware = require('../middleware/auth.middleware');
const premiumMiddleware = require('../middleware/premium.middleware');

const router = Router();

// Seguridad: Usuario Logueado + Rol Premium/Reportero/Admin
router.use(authMiddleware);
router.use(premiumMiddleware);

// --- Gráficos Existentes ---
router.get('/por-categoria', analiticasController.getReportesPorCategoria);
router.get('/por-distrito', analiticasController.getReportesPorDistrito);
router.get('/tendencia', analiticasController.getTendenciaReportes);

// --- NUEVOS Gráficos para Reportero ---
router.get('/mapa-calor', analiticasController.getHeatmapData);
router.get('/tiempos-atencion', analiticasController.getTiemposAtencion);
router.get('/por-urgencia', analiticasController.getReportesPorUrgencia);

// --- Utilidades ---
router.post('/exportar-pdf', analiticasController.solicitarExportacionPDF);

module.exports = router;