const express = require('express');
const healthRoutes = require('./health.routes');
const complaintRoutes = require('./complaint.routes');
const uploadRoutes = require('./upload.routes');
const assignmentRoutes = require('./assignment.routes');

const router = express.Router();

router.use('/health', healthRoutes);
router.use('/complaints', complaintRoutes);
router.use('/uploads', uploadRoutes);
router.use('/assignments', assignmentRoutes);

module.exports = router;