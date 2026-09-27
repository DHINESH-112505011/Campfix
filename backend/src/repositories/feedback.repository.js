const supabaseAdmin = require('../config/supabaseClient');

async function create({ complaintId, studentId, rating, resolvedSuccessfully, comment }) {
  const { data, error } = await supabaseAdmin
    .from('complaint_feedback')
    .insert({
      complaint_id: complaintId,
      student_id: studentId,
      rating,
      resolved_successfully: resolvedSuccessfully,
      comment: comment || null,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

async function findByComplaintId(complaintId) {
  const { data, error } = await supabaseAdmin
    .from('complaint_feedback')
    .select('*')
    .eq('complaint_id', complaintId)
    .maybeSingle();
  if (error) throw error;
  return data;
}

module.exports = { create, findByComplaintId };