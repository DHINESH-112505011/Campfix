const express = require('express');
const { requireAuth, requireRole } = require('../middleware/auth.middleware');
const controller = require('../controllers/assignment.controller');

const router = express.Router();

router.use(requireAuth);

// Staff-only actions
router.get('/my', requireRole('STAFF'), controller.listMyAssignments);
router.patch('/:id/accept', requireRole('STAFF'), controller.acceptAssignment);
router.patch('/:id/start', requireRole('STAFF'), controller.startWork);
router.patch('/:id/complete', requireRole('STAFF'), controller.markCompleted);

// Admin-only actions
router.post('/assign', requireRole('ADMIN', 'SUPER_ADMIN'), controller.assignStaff);
router.post('/reassign', requireRole('ADMIN', 'SUPER_ADMIN'), controller.reassignStaff);

module.exports = router;