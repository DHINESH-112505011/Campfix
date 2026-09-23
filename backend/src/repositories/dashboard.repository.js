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

module.exports = {
  getOverviewCounts,
  getComplaintsByStatus,
  getComplaintsByCategory,
  getRecentComplaints,
  getStaffWorkload,
};