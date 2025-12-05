const { Router } = require('express');
const express = require('express');
const aiController = require('../controllers/ai.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();
const jsonParser = express.json();

// Protegemos la ruta para que solo usuarios registrados usen la IA
router.use(authMiddleware);

router.post('/enhance', jsonParser, aiController.improveDescription);

module.exports = router;