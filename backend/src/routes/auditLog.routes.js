const express = require('express');
const { requireAuth, requireRole } = require('../middleware/auth.middleware');
const { listAuditLogs } = require('../controllers/auditLog.controller');

const router = express.Router();

router.use(requireAuth);
router.use(requireRole('SUPER_ADMIN')); // §47 - even ADMIN is excluded, only SUPER_ADMIN

router.get('/', listAuditLogs);

module.exports = router;