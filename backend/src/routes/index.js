const express = require('express');
const healthRoutes = require('./health.routes');
const complaintRoutes = require('./complaint.routes');
const uploadRoutes = require('./upload.routes');
const assignmentRoutes = require('./assignment.routes');
const dashboardRoutes = require('./dashboard.routes');
const staffRoutes = require('./staff.routes');
const categoryRoutes = require('./category.routes');
const profileRoutes = require('./profile.routes');
const notificationRoutes = require('./notification.routes');
const feedbackRoutes = require('./feedback.routes');
const auditLogRoutes = require('./auditLog.routes');

const router = express.Router();

router.use('/health', healthRoutes);
router.use('/complaints', complaintRoutes);
router.use('/complaints', feedbackRoutes);
router.use('/uploads', uploadRoutes);
router.use('/assignments', assignmentRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/staff', staffRoutes);
router.use('/categories', categoryRoutes);
router.use('/profile', profileRoutes);
router.use('/notifications', notificationRoutes);
router.use('/audit-logs', auditLogRoutes);

module.exports = router;