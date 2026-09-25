const supabaseAdmin = require('../config/supabaseClient');

async function findAvailableStaff({ departmentId } = {}) {
  let query = supabaseAdmin
    .from('profiles')
    .select('id, full_name, staff_specialization, department_id, is_active')
    .eq('role', 'STAFF')
    .eq('is_active', true);

  if (departmentId) query = query.eq('department_id', departmentId);

  const { data, error } = await query;
  if (error) throw error;
  return data;
}

async function getWorkloadMap() {
  const { data, error } = await supabaseAdmin
    .from('staff_active_workload')
    .select('staff_id, active_assignments');
  if (error) throw error;

  const map = {};
  for (const row of data) {
    map[row.staff_id] = row.active_assignments;
  }
  return map;
}

module.exports = { findAvailableStaff, getWorkloadMap };