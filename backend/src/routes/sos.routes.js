const { Router } = require('express');
const express = require('express');
const sosController = require('../controllers/sos.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();
const jsonParser = express.json();

router.use(authMiddleware);

router.get('/active', sosController.getActiveSosAlerts);

router.post('/activate', jsonParser, sosController.activateSos);
router.post('/:alertId/location', jsonParser, sosController.addLocationUpdate);

module.exports = router;