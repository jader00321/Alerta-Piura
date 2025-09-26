const { Router } = require('express');
const express = require('express');
const adminController = require('../controllers/admin.controller');
const authMiddleware = require('../middleware/auth.middleware');
const adminMiddleware = require('../middleware/admin.middleware');

const router = Router();
const jsonParser = express.json();

router.post('/login', jsonParser, adminController.login);


// All routes below this require a valid admin token
router.get('/stats', authMiddleware, adminController.getDashboardStats);
router.get('/users', adminMiddleware, adminController.getAllUsers);
router.put('/users/:id/role', jsonParser, adminMiddleware, adminController.updateUserRole);
router.put('/users/:id/status', jsonParser, adminMiddleware, adminController.updateUserStatus);
router.get('/categories', adminController.getAllCategories);
router.get('/category-suggestions', adminMiddleware, adminController.getCategorySuggestions);
router.post('/categories', jsonParser, adminMiddleware, adminController.createCategory);
router.delete('/categories/:id', adminMiddleware, adminController.deleteCategory);
router.get('/moderation/comments', adminMiddleware, adminController.getReportedComments);
router.put('/moderation/comments/:id', jsonParser, adminMiddleware, adminController.resolveCommentReport);
router.get('/moderation/users', adminMiddleware, adminController.getReportedUsers);
router.put('/moderation/users/:id', jsonParser, adminMiddleware, adminController.resolveUserReport);
router.get('/reports', adminMiddleware, adminController.getAllAdminReports);
router.get('/reports/review-requests', adminMiddleware, adminController.getReviewRequests);
router.put('/reports/review-requests/:id', jsonParser, adminMiddleware, adminController.resolveReviewRequest);
router.delete('/reports/:id', adminMiddleware, adminController.adminDeleteReport);
router.put('/reports/:id/visibility', jsonParser, adminMiddleware, adminController.updateReportVisibility);
router.get('/stats/reports-by-day', adminMiddleware, adminController.getReportsByDay);
router.get('/reports/heatmap-data', adminMiddleware, adminController.getHeatmapData);
router.post('/predict', jsonParser, adminMiddleware, adminController.runPredictionSimulation);
router.get('/sms-log', adminMiddleware, adminController.getSimulatedSmsLog);
router.post('/users/notify', jsonParser, adminMiddleware, adminController.sendNotification);
router.get('/notifications-history', adminMiddleware, adminController.getNotificationHistory);
router.delete('/notifications-history/:id', adminMiddleware, adminController.deleteNotification);
router.get('/reports/latest-pending', adminMiddleware, adminController.getLatestPendingReports);
router.put('/reports/:id/approve', adminMiddleware, adminController.adminAprobarReporte);
router.put('/reports/:id/reject', adminMiddleware, adminController.adminRechazarReporte);
router.get('/sos-dashboard', adminMiddleware, adminController.getSosDashboardData);
router.get('/reports/coordinates', adminMiddleware, adminController.getReportCoordinates);
router.get('/analytics/by-category', adminMiddleware, adminController.getReportsByCategory);
router.get('/analytics/by-status', adminMiddleware, adminController.getReportsByStatus);
router.get('/analytics/by-month', adminMiddleware, adminController.getReportsByMonth);
router.get('/analytics/users-by-status', adminMiddleware, adminController.getUsersByStatus);
router.get('/analytics/resolution-time', adminMiddleware, adminController.getAverageResolutionTime);
router.get('/analytics/leader-performance', adminMiddleware, adminController.getLeaderPerformance);
router.get('/analytics/verification-time', adminMiddleware, adminController.getAverageVerificationTime);
router.get('/analytics/by-district', adminMiddleware, adminController.getReportsByDistrict);
router.get('/analytics/by-hour', adminMiddleware, adminController.getReportsByHour);
router.get('/users/:id/details', adminMiddleware, adminController.getUserDetails);

module.exports = router;