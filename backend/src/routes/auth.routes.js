const { Router } = require('express');
const express = require('express'); // <-- AÑADIR IMPORT
const authController = require('../controllers/auth.controller');
const authMiddleware = require('../middleware/auth.middleware');

const router = Router();
const jsonParser = express.json(); // <-- CREAR PARSER

// Usamos el parser de JSON en las rutas que lo necesitan
router.post('/register', jsonParser, authController.register);
router.post('/login', jsonParser, authController.login);
router.post('/verify-password', jsonParser, authMiddleware, authController.verifyPassword);
router.get('/refresh-token', authMiddleware, authController.refreshToken);

module.exports = router;