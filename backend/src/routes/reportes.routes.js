// backend/src/routes/reportes.routes.js
const { Router } = require('express');
const express = require('express');
const reportesController = require('../controllers/reportes.controller');
const authMiddleware = require('../middleware/auth.middleware');
const upload = require('../config/cloudinary');

const router = Router();
const jsonParser = express.json();

// --- Rutas Públicas ---
// Cualquiera puede obtener la lista de reportes (filtrada a 'verificado' por defecto en el controlador)
router.get('/', reportesController.getAllReports); 
// Cualquiera puede ver el riesgo de una zona
router.get('/riesgo-zona', reportesController.getRiesgoZona); 
// Cualquiera puede obtener un reporte por ID (el controlador maneja estados 'oculto'/'fusionado')
router.get('/:id', reportesController.getReporteById); 
// Cualquiera puede obtener datos del mapa de calor y zonas
router.get('/mapa-calor', reportesController.getDatosMapaDeCalor);
router.get('/zonas-peligrosas', reportesController.getZonasPeligrosas);

// --- Rutas Protegidas (Requieren autenticación) ---
router.use(authMiddleware);

// Obtener reportes cercanos (requiere login para saber la ubicación relativa)
router.get('/v1/cercanos', reportesController.getReportesCercanos);
// Crear un nuevo reporte
router.post('/', upload.single('foto'), reportesController.createReport);
// Apoyar un reporte verificado
router.post('/:id/apoyar', jsonParser, reportesController.apoyarReporte);
// Unirse a un reporte pendiente
router.post('/:id/unirse_pendiente', jsonParser, reportesController.unirseReportePendiente);
// Quitar apoyo a un reporte pendiente
router.delete('/:id/unirse_pendiente', reportesController.quitarApoyoPendiente);
// Eliminar un reporte (si es el autor y está pendiente)
router.delete('/:id', reportesController.eliminarReporte);
// Obtener historial de chat de un reporte (requiere estar logueado)
router.get('/:id/chat', reportesController.getChatHistory);
// Permite al AUTOR editar su reporte SI está PENDIENTE
router.put('/:id/author-edit', jsonParser, reportesController.editReportAuthor);

router.put('/:id/chat/mark-read', reportesController.markChatAsReadUser);

module.exports = router;