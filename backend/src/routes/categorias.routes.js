// backend/src/routes/categorias.routes.js
const { Router } = require('express');
const categoriasController = require('../controllers/categorias.controller');
// NO importamos adminMiddleware aquí
// Opcional: Podrías importar authMiddleware si quieres que solo usuarios logueados las vean

const router = Router();

// Opcional: Si quieres requerir login (pero no admin) para ver categorías:
// const authMiddleware = require('../middleware/auth.middleware');
// router.use(authMiddleware);

// Definimos la ruta pública (o solo para logueados)
router.get('/', categoriasController.getPublicCategorias);

module.exports = router;