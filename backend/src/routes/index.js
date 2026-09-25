const express = require('express');
const healthRoutes = require('./health.routes');
const complaintRoutes = require('./complaint.routes');
const uploadRoutes = require('./upload.routes');
const assignmentRoutes = require('./assignment.routes');
const dashboardRoutes = require('./dashboard.routes');
const staffRoutes = require('./staff.routes');
const categoryRoutes = require('./category.routes');
const profileRoutes = require('./profile.routes');

const router = express.Router();

router.use('/health', healthRoutes);
router.use('/complaints', complaintRoutes);
router.use('/uploads', uploadRoutes);
router.use('/assignments', assignmentRoutes);
router.use('/dashboard', dashboardRoutes);
router.use('/staff', staffRoutes);
router.use('/categories', categoryRoutes);
router.use('/profile', profileRoutes);

module.exports = router;