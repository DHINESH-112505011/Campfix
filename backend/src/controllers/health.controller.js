const { success } = require('../utils/apiResponse');
const supabaseAdmin = require('../config/supabaseClient');

async function getHealth(req, res, next) {
  try {
    const { error } = await supabaseAdmin.from('departments').select('id').limit(1);

    if (error) throw error;

    return success(res, {
      message: 'CampFix backend is healthy',
      data: {
        status: 'ok',
        database: 'connected',
        timestamp: new Date().toISOString(),
      },
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { getHealth };