const { Router } = require('express');
const express = require('express');
const comentariosController = require('../controllers/comentarios.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();
const jsonParser = express.json();

// All comment routes require authentication
router.use(authMiddleware);

router.put('/:id', jsonParser, comentariosController.editarComentario);
router.delete('/:id', comentariosController.eliminarComentario);
router.post('/:id/reportar', jsonParser, comentariosController.reportarComentario);
router.post('/:id/apoyar', jsonParser, comentariosController.apoyarComentario);

module.exports = router;