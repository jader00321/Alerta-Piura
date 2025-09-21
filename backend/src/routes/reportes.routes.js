const { Router } = require('express');
const express = require('express');
const reportesController = require('../controllers/reportes.controller');
const authMiddleware = require('../middleware/auth.middleware');
const upload = require('../config/cloudinary');

const router = Router();
const jsonParser = express.json();

// --- CORRECT ROUTE ORDER ---
// Public routes first, with specific routes before dynamic ones.

router.get('/', reportesController.getAllReports);

router.get('/riesgo-zona', reportesController.getRiesgoZona);

router.get('/:id', reportesController.getReporteById);

router.get('/:id/chat', authMiddleware, reportesController.getChatHistory);

// Authenticated routes
router.post('/', authMiddleware, upload.single('foto'), reportesController.createReport);
router.post('/:id/apoyar', jsonParser, authMiddleware, reportesController.apoyarReporte);
router.post('/:id/comentarios', jsonParser, authMiddleware, reportesController.createComentario);
router.delete('/:id', authMiddleware, reportesController.eliminarReporte);

module.exports = router;