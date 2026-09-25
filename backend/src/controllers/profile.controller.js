const { success } = require('../utils/apiResponse');

async function getMyProfile(req, res) {
  // req.profile was already loaded and verified by requireAuth middleware
  return success(res, { message: 'Profile retrieved', data: req.profile });
}

module.exports = { getMyProfile };