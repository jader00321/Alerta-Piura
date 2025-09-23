const { Router } = require('express');
const express = require('express');
const sosController = require('../controllers/sos.controller');
const authMiddleware = require('../middleware/auth.middleware');
const adminMiddleware = require('../middleware/admin.middleware');

const router = Router();
const jsonParser = express.json();

router.use(authMiddleware);

router.get('/active', sosController.getActiveSosAlerts);

router.post('/activate', jsonParser, sosController.activateSos);
router.post('/:alertId/location', jsonParser, sosController.addLocationUpdate);
router.get('/all', adminMiddleware, sosController.getAllSosAlerts);
router.get('/:alertId/history', adminMiddleware, sosController.getSosLocationHistory);
router.put('/:id/status', jsonParser, adminMiddleware, sosController.updateSosStatus);

module.exports = router;