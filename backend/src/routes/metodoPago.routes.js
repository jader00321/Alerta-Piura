const { Router } = require('express');
const express = require('express');
const metodoPagoController = require('../controllers/metodoPago.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();
const jsonParser = express.json();

// Todas estas rutas requieren que el usuario esté autenticado
router.use(authMiddleware);

router.get('/', metodoPagoController.listarMetodos);
router.post('/', jsonParser, metodoPagoController.crearMetodo);
router.put('/:id/predeterminado', metodoPagoController.establecerPredeterminado);
router.delete('/:id', metodoPagoController.eliminarMetodo);

module.exports = router;