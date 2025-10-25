const { Router } = require('express');
const express = require('express');
const sosController = require('../controllers/sos.controller');
const authMiddleware = require('../middleware/auth.middleware');
const adminMiddleware = require('../middleware/admin.middleware');
const premiumMiddleware = require('../middleware/premium.middleware');

const router = Router();
const jsonParser = express.json();

// Todas las rutas SOS requieren que un usuario esté autenticado
router.use(authMiddleware);

// --- Rutas para el usuario de la App ---
router.post('/activate', jsonParser, premiumMiddleware, sosController.activateSos);
router.post('/:alertId/location', jsonParser, sosController.addLocationUpdate);
router.put('/:alertId/deactivate', sosController.deactivateSos); 

// --- Rutas solo para Administradores ---
router.get('/all', adminMiddleware, sosController.getAllSosAlerts);
router.get('/:alertId/history', adminMiddleware, sosController.getSosLocationHistory);
router.put('/:id/status', jsonParser, adminMiddleware, sosController.updateSosStatus);

module.exports = router;