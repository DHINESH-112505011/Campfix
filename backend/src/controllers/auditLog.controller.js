const { success } = require('../utils/apiResponse');
const auditLogService = require('../services/auditLog.service');

async function listAuditLogs(req, res, next) {
  try {
    const limit = Math.min(parseInt(req.query.limit, 10) || 50, 100);
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
    const offset = (page - 1) * limit;

    const result = await auditLogService.listAll({ pagination: { limit, offset } });
    return success(res, {
      message: 'Audit logs retrieved',
      data: { items: result.data, total: result.total, page, limit },
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { listAuditLogs };