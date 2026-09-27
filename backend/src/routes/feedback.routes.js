const express = require('express');
const { requireAuth } = require('../middleware/auth.middleware');
const controller = require('../controllers/feedback.controller');

const router = express.Router();

router.use(requireAuth);

router.post('/:id/feedback', controller.submitFeedback);
router.get('/:id/feedback', controller.getFeedback);

module.exports = router;