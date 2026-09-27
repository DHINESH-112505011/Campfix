const supabaseAdmin = require('../config/supabaseClient');

async function getOverviewCounts() {
  const [totalRes, activeRes, resolvedRes, criticalRes] = await Promise.all([
    supabaseAdmin.from('complaints').select('id', { count: 'exact', head: true }),
    supabaseAdmin
      .from('complaints')
      .select('id', { count: 'exact', head: true })
      .not('status', 'in', '(RESOLVED,REJECTED,CANCELLED)'),
    supabaseAdmin
      .from('complaints')
      .select('id', { count: 'exact', head: true })
      .eq('status', 'RESOLVED'),
    supabaseAdmin
      .from('complaints')
      .select('id', { count: 'exact', head: true })
      .eq('priority', 'CRITICAL')
      .not('status', 'in', '(RESOLVED,REJECTED,CANCELLED)'),
  ]);

  if (totalRes.error) throw totalRes.error;
  if (activeRes.error) throw activeRes.error;
  if (resolvedRes.error) throw resolvedRes.error;
  if (criticalRes.error) throw criticalRes.error;

  return {
    total: totalRes.count || 0,
    active: activeRes.count || 0,
    resolved: resolvedRes.count || 0,
    critical: criticalRes.count || 0,
  };
}

async function getComplaintsByStatus() {
  const { data, error } = await supabaseAdmin.from('complaints').select('status');
  if (error) throw error;

  const counts = {};
  for (const row of data) {
    counts[row.status] = (counts[row.status] || 0) + 1;
  }
  return counts;
}

async function getComplaintsByCategory() {
  const { data, error } = await supabaseAdmin
    .from('complaints')
    .select('category_id, categories(name)');
  if (error) throw error;

  const counts = {};
  for (const row of data) {
    const name = row.categories?.name || 'Uncategorized';
    counts[name] = (counts[name] || 0) + 1;
  }
  return counts;
}

async function getComplaintsByDepartment() {
  const { data, error } = await supabaseAdmin
    .from('complaints')
    .select('department_id, departments(name)');
  if (error) throw error;

  const counts = {};
  for (const row of data) {
    const name = row.departments?.name || 'Unassigned';
    counts[name] = (counts[name] || 0) + 1;
  }
  return counts;
}

async function getRecentComplaints(limit = 5) {
  const { data, error } = await supabaseAdmin
    .from('complaints')
    .select('*')
    .order('created_at', { ascending: false })
    .limit(limit);
  if (error) throw error;
  return data;
}

async function getStaffWorkload() {
  const { data, error } = await supabaseAdmin
    .from('staff_active_workload')
    .select('staff_id, active_assignments, profiles(full_name, staff_specialization)');
  if (error) throw error;
  return data;
}

async function getAverageResolutionTimeHours() {
  const { data, error } = await supabaseAdmin
    .from('complaints')
    .select('created_at, resolved_at')
    .not('resolved_at', 'is', null);
  if (error) throw error;

  if (data.length === 0) return 0;

  const totalHours = data.reduce((sum, row) => {
    const created = new Date(row.created_at).getTime();
    const resolved = new Date(row.resolved_at).getTime();
    return sum + (resolved - created) / (1000 * 60 * 60);
  }, 0);

  return Math.round((totalHours / data.length) * 10) / 10;
}

async function getReopenedCount() {
  const { count, error } = await supabaseAdmin
    .from('complaints')
    .select('id', { count: 'exact', head: true })
    .eq('status', 'REOPENED');
  if (error) throw error;
  return count || 0;
}

async function getSatisfactionStats() {
  const { data, error } = await supabaseAdmin
    .from('complaint_feedback')
    .select('rating, resolved_successfully');
  if (error) throw error;

  if (data.length === 0) {
    return { averageRating: 0, totalFeedback: 0, resolvedSuccessfullyPercent: 0 };
  }

  const averageRating =
    Math.round((data.reduce((sum, f) => sum + f.rating, 0) / data.length) * 10) / 10;
  const successCount = data.filter((f) => f.resolved_successfully).length;
  const resolvedSuccessfullyPercent = Math.round((successCount / data.length) * 100);

  return { averageRating, totalFeedback: data.length, resolvedSuccessfullyPercent };
}

async function getStaffPerformance() {
  const { data, error } = await supabaseAdmin
    .from('staff_average_rating')
    .select('staff_id, average_rating, total_ratings, profiles(full_name, staff_specialization)');
  if (error) throw error;
  return data;
}

module.exports = {
  getOverviewCounts,
  getComplaintsByStatus,
  getComplaintsByCategory,
  getComplaintsByDepartment,
  getRecentComplaints,
  getStaffWorkload,
  getAverageResolutionTimeHours,
  getReopenedCount,
  getSatisfactionStats,
  getStaffPerformance,
};