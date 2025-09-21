const { Router } = require('express');
const express = require('express');
const perfilController = require('../controllers/perfil.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();
const jsonParser = express.json();
// All profile routes require authentication
router.use(authMiddleware);

router.get('/me', perfilController.getMiPerfil);

// --- ADD THESE NEW ROUTES ---
router.get('/me/reportes', perfilController.getMisReportes);
router.get('/me/apoyos', perfilController.getMisApoyos);
router.get('/me/comentarios', perfilController.getMisComentarios);
router.get('/me/conversaciones', perfilController.getMisConversaciones);
router.put('/me', jsonParser, authMiddleware, perfilController.updateMyProfile);
router.put('/me/email', jsonParser, authMiddleware, perfilController.updateMyEmail);
router.put('/me/password', jsonParser, authMiddleware, perfilController.updateMyPassword);
router.get('/me/notificaciones', authMiddleware, perfilController.getMisNotificaciones);

module.exports = router;