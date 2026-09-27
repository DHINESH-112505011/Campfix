const supabaseAdmin = require('../config/supabaseClient');

function applyFilters(query, { status, priority, categoryId, search, dateFrom, dateTo }) {
  if (status) query = query.eq('status', status);
  if (priority) query = query.eq('priority', priority);
  if (categoryId) query = query.eq('category_id', categoryId);
  if (dateFrom) query = query.gte('created_at', dateFrom);
  if (dateTo) query = query.lte('created_at', dateTo);
  if (search) {
    query = query.or(
      `complaint_number.ilike.%${search}%,title.ilike.%${search}%,description.ilike.%${search}%,building.ilike.%${search}%,room.ilike.%${search}%`
    );
  }
  return query;
}

async function createComplaint(payload) {
  const { data, error } = await supabaseAdmin
    .from('complaints')
    .insert(payload)
    .select()
    .single();
  if (error) throw error;
  return data;
}

async function findById(id) {
  const { data, error } = await supabaseAdmin
    .from('complaints')
    .select('*')
    .eq('id', id)
    .maybeSingle();
  if (error) throw error;
  return data;
}

async function findByStudentId(studentId, { limit = 20, offset = 0, ...filters } = {}) {
  let query = supabaseAdmin
    .from('complaints')
    .select('*', { count: 'exact' })
    .eq('student_id', studentId)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  query = applyFilters(query, filters);

  const { data, error, count } = await query;
  if (error) throw error;
  return { data, total: count };
}

async function findAll({ limit = 20, offset = 0, ...filters } = {}) {
  let query = supabaseAdmin
    .from('complaints')
    .select('*', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);

  query = applyFilters(query, filters);

  const { data, error, count } = await query;
  if (error) throw error;
  return { data, total: count };
}

async function findAssignedToStaff(staffId, { limit = 20, offset = 0 } = {}) {
  const { data, error, count } = await supabaseAdmin
    .from('complaints')
    .select('*, complaint_assignments!inner(staff_id, status)', { count: 'exact' })
    .eq('complaint_assignments.staff_id', staffId)
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);
  if (error) throw error;
  return { data, total: count };
}

/**
 * Updates a complaint. If `actor` is provided and the update changes
 * `status`, we directly patch the most recent matching timeline row
 * (inserted a moment earlier by the Phase 6 trigger) with the real
 * performed_by/role, since PostgREST connection pooling makes Postgres
 * session variables unreliable for trigger attribution.
 */
async function updateComplaint(id, updates, actor = null) {
  const { data, error } = await supabaseAdmin
    .from('complaints')
    .update(updates)
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;

  if (actor?.userId && updates.status) {
    await supabaseAdmin
      .from('complaint_timeline')
      .update({ performed_by: actor.userId, role: actor.role })
      .eq('complaint_id', id)
      .eq('new_status', updates.status)
      .is('performed_by', null)
      .order('created_at', { ascending: false })
      .limit(1);
  }

  return data;
}

async function getTimeline(complaintId) {
  const { data, error } = await supabaseAdmin
    .from('complaint_timeline')
    .select('*')
    .eq('complaint_id', complaintId)
    .order('created_at', { ascending: true });
  if (error) throw error;
  return data;
}

module.exports = {
  createComplaint,
  findById,
  findByStudentId,
  findAll,
  findAssignedToStaff,
  updateComplaint,
  getTimeline,
};