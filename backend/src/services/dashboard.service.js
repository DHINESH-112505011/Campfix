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

module.exports = { getAdminDashboard };