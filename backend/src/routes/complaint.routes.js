const express = require('express');
const { requireAuth } = require('../middleware/auth.middleware');
const controller = require('../controllers/complaint.controller');

const router = express.Router();

router.use(requireAuth); // every complaint route requires a logged-in user

router.post('/', controller.createComplaint);
router.get('/', controller.listComplaints);
router.get('/:id', controller.getComplaintById);
router.patch('/:id/status', controller.updateComplaintStatus);
router.patch('/:id', controller.updateComplaintDetails);
router.get('/:id/timeline', controller.getComplaintTimeline);

module.exports = router;