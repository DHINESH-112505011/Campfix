const notificationRepository = require('../repositories/notification.repository');

async function notifyUser({ userId, title, message, type, relatedComplaintId }) {
  try {
    return await notificationRepository.create({ userId, title, message, type, relatedComplaintId });
  } catch (err) {
    // Notifications are best-effort - never let a notification failure
    // break the underlying business operation (complaint creation, etc).
    console.error('[NOTIFICATION] Failed to create notification:', err.message);
    return null;
  }
}

async function notifyAllAdmins({ title, message, type, relatedComplaintId }) {
  try {
    const admins = await notificationRepository.findAdminsAndSuperAdmins();
    await Promise.all(
      admins.map((admin) =>
        notificationRepository.create({
          userId: admin.id,
          title,
          message,
          type,
          relatedComplaintId,
        })
      )
    );
  } catch (err) {
    console.error('[NOTIFICATION] Failed to notify admins:', err.message);
  }
}

async function listMyNotifications(userId) {
  return notificationRepository.findByUserId(userId);
}

async function getUnreadCount(userId) {
  return notificationRepository.countUnread(userId);
}

async function markAsRead(id, userId) {
  return notificationRepository.markAsRead(id, userId);
}

async function markAllAsRead(userId) {
  return notificationRepository.markAllAsRead(userId);
}

module.exports = {
  notifyUser,
  notifyAllAdmins,
  listMyNotifications,
  getUnreadCount,
  markAsRead,
  markAllAsRead,
};