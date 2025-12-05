// backend/src/routes/admin.routes.js
const { Router } = require('express');
const express = require('express');
const adminMiddleware = require('../middleware/admin.middleware');

// --- IMPORTACIONES ACTUALIZADAS ---
const authAdminController = require('../controllers/admin/auth.admin.controller');
const usuarioAdminController = require('../controllers/admin/usuario.admin.controller');
const categoriaAdminController = require('../controllers/admin/categoria.admin.controller');
const reporteAdminController = require('../controllers/admin/reporte.admin.controller');
const moderacionAdminController = require('../controllers/admin/moderacion.admin.controller');
const analiticaAdminController = require('../controllers/admin/analitica.admin.controller');
const comunicacionAdminController = require('../controllers/admin/comunicacion.admin.controller');
const sosAdminController = require('../controllers/admin/sos.admin.controller');

const router = Router();
const jsonParser = express.json();

// Login
router.post('/login', jsonParser, authAdminController.login);

router.use(adminMiddleware);

// Dashboard & Stats
router.get('/stats', analiticaAdminController.getDashboardStats);
router.get('/analytics/reports-by-status', analiticaAdminController.getReportsGroupedByStatus);

// User Management
router.get('/users', usuarioAdminController.getAllUsers);
router.put('/users/:id/role', jsonParser, usuarioAdminController.updateUserRole);
router.put('/users/:id/status', jsonParser, usuarioAdminController.updateUserStatus);
router.get('/users/:id/details', usuarioAdminController.getUserDetails);
router.get('/solicitudes-rol', usuarioAdminController.getSolicitudesRol);
router.put('/solicitudes-rol/:id', jsonParser, usuarioAdminController.resolverSolicitudRol);
router.post('/lider/:id/asignar-zonas', jsonParser, usuarioAdminController.asignarZonasLider);
router.get('/lider/:id/asignar-zonas', usuarioAdminController.getZonasAsignadas);
router.get('/users/:id/summary', usuarioAdminController.getUserSummary);

// Category Management
router.get('/categories', categoriaAdminController.getAllCategories);
router.get('/categories/with-stats', categoriaAdminController.getCategoriesWithStats);
router.get('/category-suggestions', categoriaAdminController.getCategorySuggestions);
router.post('/categories', jsonParser, categoriaAdminController.createCategory);
router.delete('/categories/:id', categoriaAdminController.deleteCategory);
router.put('/categories/reorder', jsonParser, categoriaAdminController.reorderCategories);
router.post('/categories/merge', jsonParser, categoriaAdminController.mergeCategorySuggestion);

// Report Management
router.get('/reports', reporteAdminController.getAllAdminReports);
router.put('/reports/:id/visibility', jsonParser, reporteAdminController.updateReportVisibility);
router.delete('/reports/:id', reporteAdminController.adminDeleteReport);
router.put('/reports/:id/approve', reporteAdminController.adminAprobarReporte);
router.put('/reports/:id/reject', reporteAdminController.adminRechazarReporte);
router.put('/reports/:id/set-pending', reporteAdminController.adminSetReportToPending);
router.get('/latest-pending', reporteAdminController.getLatestPendingReports);
router.get('/review-requests', reporteAdminController.getReviewRequests);
router.put('/review-requests/:id', jsonParser, reporteAdminController.resolveReviewRequest);
router.get('/conversations', reporteAdminController.getAllConversations); 
router.get('/reports/:id/chat', reporteAdminController.getChatHistory);

// Moderation
router.get('/moderation/comments', moderacionAdminController.getReportedComments);
router.put('/moderation/comments/:id', jsonParser, moderacionAdminController.resolveCommentReport);
router.get('/moderation/users', moderacionAdminController.getReportedUsers);
router.put('/moderation/users/:id', jsonParser, moderacionAdminController.resolveUserReport);
router.get('/moderation/history', moderacionAdminController.getModerationHistory);

// Analytics
router.get('/heatmap-data', analiticaAdminController.getHeatmapData);
router.get('/report-coordinates', analiticaAdminController.getReportCoordinates);
router.get('/analytics/by-category', analiticaAdminController.getReportsByCategory);
router.get('/analytics/by-status', analiticaAdminController.getReportsByStatus);
router.get('/analytics/by-district', analiticaAdminController.getReportsByDistrict);
router.get('/analytics/users-by-status', analiticaAdminController.getUsersByStatus);
router.get('/analytics/resolution-time', analiticaAdminController.getAverageResolutionTime);
router.get('/analytics/verification-time', analiticaAdminController.getAverageVerificationTime);
router.get('/analytics/leader-performance', analiticaAdminController.getLeaderPerformance);
router.post('/predict', jsonParser, analiticaAdminController.runPredictionSimulation); 
router.get('/analytics/by-day', analiticaAdminController.getReportsByDay);
router.get('/analytics/verification-time-trend', analiticaAdminController.getVerificationTimeTrend);
router.get('/analytics/report-trend', analiticaAdminController.getReportTrend);

// Communication & Logs
router.post('/users/notify', jsonParser, comunicacionAdminController.sendNotification); // Asegúrate que esta ruta sea la que usa el frontend
router.get('/notifications-history', comunicacionAdminController.getNotificationHistory);
router.delete('/notifications-history/:id', comunicacionAdminController.deleteNotification);
router.get('/sms-log', comunicacionAdminController.getSimulatedSmsLog);

// SOS
router.get('/sos-dashboard', sosAdminController.getSosDashboardData);

router.put('/reports/:id/chat/mark-read', reporteAdminController.markChatAsReadAdmin);

router.get('/conversations/unread-count', reporteAdminController.getUnreadGlobalCount);

router.delete('/sms-log/:id', comunicacionAdminController.deleteSmsLog);
module.exports = router;