const staffRepository = require('../repositories/staff.repository');

async function listAvailableStaffWithWorkload({ departmentId }) {
  const [staff, workloadMap] = await Promise.all([
    staffRepository.findAvailableStaff({ departmentId }),
    staffRepository.getWorkloadMap(),
  ]);

  // Sort by lowest workload first, per §32 recommendation logic
  return staff
    .map((s) => ({ ...s, active_assignments: workloadMap[s.id] || 0 }))
    .sort((a, b) => a.active_assignments - b.active_assignments);
}

module.exports = { listAvailableStaffWithWorkload };