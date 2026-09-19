const express = require('express');
const healthRoutes = require('./health.routes');
const complaintRoutes = require('./complaint.routes');

const router = express.Router();

router.use('/health', healthRoutes);
router.use('/complaints', complaintRoutes);

module.exports = router;    