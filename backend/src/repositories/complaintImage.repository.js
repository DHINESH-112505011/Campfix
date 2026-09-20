const supabaseAdmin = require('../config/supabaseClient');

async function createComplaintImage({ complaintId, uploadedBy, imageType, url, publicId }) {
  const { data, error } = await supabaseAdmin
    .from('complaint_images')
    .insert({
      complaint_id: complaintId,
      uploaded_by: uploadedBy,
      image_type: imageType,
      cloudinary_url: url,
      cloudinary_public_id: publicId,
    })
    .select()
    .single();
  if (error) throw error;
  return data;
}

async function findByComplaintId(complaintId) {
  const { data, error } = await supabaseAdmin
    .from('complaint_images')
    .select('*')
    .eq('complaint_id', complaintId)
    .order('created_at', { ascending: true });
  if (error) throw error;
  return data;
}

module.exports = { createComplaintImage, findByComplaintId };