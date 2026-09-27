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

async function getAnalytics(req, res, next) {
  try {
    const analytics = await dashboardService.getAnalytics();
    return success(res, { message: 'Analytics retrieved', data: analytics });
  } catch (err) {
    next(err);
  }
}

module.exports = { getAdminDashboard, getAnalytics };