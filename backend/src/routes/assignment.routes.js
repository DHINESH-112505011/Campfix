const express = require('express');
const { requireAuth, requireRole } = require('../middleware/auth.middleware');
const controller = require('../controllers/assignment.controller');

const router = express.Router();

router.use(requireAuth);
router.use(requireRole('STAFF'));

router.get('/my', controller.listMyAssignments);
router.patch('/:id/accept', controller.acceptAssignment);
router.patch('/:id/start', controller.startWork);
router.patch('/:id/complete', controller.markCompleted);

module.exports = router;