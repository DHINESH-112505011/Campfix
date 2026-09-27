const auditLogRepository = require('../repositories/auditLog.repository');

async function log({ userId, action, entityType, entityId, oldValue, newValue }) {
  try {
    return await auditLogRepository.create({ userId, action, entityType, entityId, oldValue, newValue });
  } catch (err) {
    // Audit logging failures must never block the underlying action,
    // but ARE logged server-side loudly since losing an audit trail matters.
    console.error('[AUDIT LOG] Failed to record audit entry:', err.message);
    return null;
  }
}

async function listAll({ pagination }) {
  return auditLogRepository.findAll(pagination);
}

module.exports = { log, listAll };