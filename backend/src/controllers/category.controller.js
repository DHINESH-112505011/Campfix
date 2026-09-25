const { success } = require('../utils/apiResponse');
const supabaseAdmin = require('../config/supabaseClient');

async function listCategories(req, res, next) {
  try {
    const { data, error } = await supabaseAdmin
      .from('categories')
      .select('id, name, icon, department_id')
      .eq('is_active', true)
      .order('name');
    if (error) throw error;
    return success(res, { message: 'Categories retrieved', data });
  } catch (err) {
    next(err);
  }
}

module.exports = { listCategories };