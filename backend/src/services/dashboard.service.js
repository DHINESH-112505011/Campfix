const dashboardRepository = require('../repositories/dashboard.repository');

async function getAdminDashboard() {
  const [overview, byStatus, byCategory, recentComplaints, staffWorkload] = await Promise.all([
    dashboardRepository.getOverviewCounts(),
    dashboardRepository.getComplaintsByStatus(),
    dashboardRepository.getComplaintsByCategory(),
    dashboardRepository.getRecentComplaints(5),
    dashboardRepository.getStaffWorkload(),
  ]);

  return { overview, byStatus, byCategory, recentComplaints, staffWorkload };
}

async function getAnalytics() {
  const [
    overview,
    byStatus,
    byCategory,
    byDepartment,
    avgResolutionTimeHours,
    reopenedCount,
    satisfaction,
    staffPerformance,
  ] = await Promise.all([
    dashboardRepository.getOverviewCounts(),
    dashboardRepository.getComplaintsByStatus(),
    dashboardRepository.getComplaintsByCategory(),
    dashboardRepository.getComplaintsByDepartment(),
    dashboardRepository.getAverageResolutionTimeHours(),
    dashboardRepository.getReopenedCount(),
    dashboardRepository.getSatisfactionStats(),
    dashboardRepository.getStaffPerformance(),
  ]);

  return {
    overview,
    byStatus,
    byCategory,
    byDepartment,
    avgResolutionTimeHours,
    reopenedCount,
    satisfaction,
    staffPerformance,
  };
}

module.exports = { getAdminDashboard, getAnalytics };