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

module.exports = { findByStaffId, findById, updateStatus };