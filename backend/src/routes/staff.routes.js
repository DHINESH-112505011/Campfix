const express = require('express');
const { requireAuth, requireRole } = require('../middleware/auth.middleware');
const controller = require('../controllers/staff.controller');

const router = express.Router();

router.use(requireAuth);
router.use(requireRole('ADMIN', 'SUPER_ADMIN'));

router.get('/available', controller.listAvailableStaff);

module.exports = router;