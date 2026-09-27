const { success } = require('../utils/apiResponse');
const notificationService = require('../services/notification.service');

async function listMyNotifications(req, res, next) {
  try {
    const notifications = await notificationService.listMyNotifications(req.profile.id);
    const unreadCount = await notificationService.getUnreadCount(req.profile.id);
    return success(res, {
      message: 'Notifications retrieved',
      data: { items: notifications, unreadCount },
    });
  } catch (err) {
    next(err);
  }
}

async function markAsRead(req, res, next) {
  try {
    const updated = await notificationService.markAsRead(req.params.id, req.profile.id);
    return success(res, { message: 'Notification marked as read', data: updated });
  } catch (err) {
    next(err);
  }
}

async function markAllAsRead(req, res, next) {
  try {
    await notificationService.markAllAsRead(req.profile.id);
    return success(res, { message: 'All notifications marked as read' });
  } catch (err) {
    next(err);
  }
}

module.exports = { listMyNotifications, markAsRead, markAllAsRead };