const express = require('express');
const { requireAuth, requireRole } = require('../middleware/auth.middleware');
const controller = require('../controllers/dashboard.controller');

const router = express.Router();

router.use(requireAuth);
router.use(requireRole('ADMIN', 'SUPER_ADMIN'));

router.get('/admin', controller.getAdminDashboard);
router.get('/analytics', controller.getAnalytics);

module.exports = router;