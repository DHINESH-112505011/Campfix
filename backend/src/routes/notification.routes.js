const express = require('express');
const { requireAuth } = require('../middleware/auth.middleware');
const controller = require('../controllers/notification.controller');

const router = express.Router();

router.use(requireAuth);

router.get('/', controller.listMyNotifications);
router.patch('/:id/read', controller.markAsRead);
router.patch('/read-all', controller.markAllAsRead);

module.exports = router;