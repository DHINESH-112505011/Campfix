const supabaseAdmin = require('../config/supabaseClient');

async function findByStaffId(staffId, { status } = {}) {
  let query = supabaseAdmin
    .from('complaint_assignments')
    .select('*, complaints(*)')
    .eq('staff_id', staffId)
    .order('assigned_at', { ascending: false });

  if (status) query = query.eq('status', status);

  const { data, error } = await query;
  if (error) throw error;
  return data;
}

async function findById(id) {
  const { data, error } = await supabaseAdmin
    .from('complaint_assignments')
    .select('*, complaints(*)')
    .eq('id', id)
    .maybeSingle();
  if (error) throw error;
  return data;
}

async function updateStatus(id, updates) {
  const { data, error } = await supabaseAdmin
    .from('complaint_assignments')
    .update(updates)
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return data;
}

async function createAssignment({ complaintId, staffId, assignedBy, notes }) {
  const { data, error } = await supabaseAdmin
    .from('complaint_assignments')
    .insert({
      complaint_id: complaintId,
      staff_id: staffId,
      assigned_by: assignedBy,
      status: 'ASSIGNED',
      notes: notes || null,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

async function findActiveByComplaintId(complaintId) {
  const { data, error } = await supabaseAdmin
    .from('complaint_assignments')
    .select('*')
    .eq('complaint_id', complaintId)
    .in('status', ['ASSIGNED', 'ACCEPTED', 'IN_PROGRESS'])
    .maybeSingle();
  if (error) throw error;
  return data;
}

module.exports = {
  findByStaffId,
  findById,
  updateStatus,
  createAssignment,
  findActiveByComplaintId,
};