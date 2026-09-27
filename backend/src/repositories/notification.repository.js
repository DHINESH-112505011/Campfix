const supabaseAdmin = require('../config/supabaseClient');

async function create({ userId, title, message, type, relatedComplaintId }) {
  const { data, error } = await supabaseAdmin
    .from('notifications')
    .insert({
      user_id: userId,
      title,
      message,
      type,
      related_complaint_id: relatedComplaintId || null,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

async function findByUserId(userId, { limit = 30 } = {}) {
  const { data, error } = await supabaseAdmin
    .from('notifications')
    .select('*')
    .eq('user_id', userId)
    .order('created_at', { ascending: false })
    .limit(limit);
  if (error) throw error;
  return data;
}

async function countUnread(userId) {
  const { count, error } = await supabaseAdmin
    .from('notifications')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('is_read', false);
  if (error) throw error;
  return count || 0;
}

async function markAsRead(id, userId) {
  const { data, error } = await supabaseAdmin
    .from('notifications')
    .update({ is_read: true })
    .eq('id', id)
    .eq('user_id', userId)
    .select()
    .single();
  if (error) throw error;
  return data;
}

async function markAllAsRead(userId) {
  const { error } = await supabaseAdmin
    .from('notifications')
    .update({ is_read: true })
    .eq('user_id', userId)
    .eq('is_read', false);
  if (error) throw error;
}

async function findAdminsAndSuperAdmins() {
  const { data, error } = await supabaseAdmin
    .from('profiles')
    .select('id')
    .in('role', ['ADMIN', 'SUPER_ADMIN'])
    .eq('is_active', true);
  if (error) throw error;
  return data;
}

module.exports = {
  create,
  findByUserId,
  countUnread,
  markAsRead,
  markAllAsRead,
  findAdminsAndSuperAdmins,
};