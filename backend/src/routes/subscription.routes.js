const { Router } = require('express');
const express = require('express');
const subscriptionController = require('../controllers/subscription.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();
const jsonParser = express.json();

// Todas las rutas de suscripción requieren que el usuario esté autenticado
router.use(authMiddleware);

// Endpoint para obtener todos los planes disponibles
router.get('/plans', subscriptionController.getPlans);

// Endpoint para que un usuario se suscriba a un plan
router.post('/subscribe', jsonParser, subscriptionController.subscribe);
// Endpoint para que un usuario cancele su suscripción
router.put('/cancel', subscriptionController.cancelarSuscripcion);

module.exports = router;