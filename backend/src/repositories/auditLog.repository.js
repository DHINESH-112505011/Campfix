const supabaseAdmin = require('../config/supabaseClient');

async function create({ userId, action, entityType, entityId, oldValue, newValue }) {
  const { data, error } = await supabaseAdmin
    .from('audit_logs')
    .insert({
      user_id: userId,
      action,
      entity_type: entityType,
      entity_id: entityId,
      old_value: oldValue || null,
      new_value: newValue || null,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

async function findAll({ limit = 50, offset = 0 } = {}) {
  const { data, error, count } = await supabaseAdmin
    .from('audit_logs')
    .select('*, profiles(full_name, role)', { count: 'exact' })
    .order('created_at', { ascending: false })
    .range(offset, offset + limit - 1);
  if (error) throw error;
  return { data, total: count };
}

module.exports = { create, findAll };