const { success } = require('../utils/apiResponse');
const dashboardService = require('../services/dashboard.service');

async function getAdminDashboard(req, res, next) {
  try {
    const dashboard = await dashboardService.getAdminDashboard();
    return success(res, { message: 'Dashboard retrieved', data: dashboard });
  } catch (err) {
    next(err);
  }
}

module.exports = { getAdminDashboard };