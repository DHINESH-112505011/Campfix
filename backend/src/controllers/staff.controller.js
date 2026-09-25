const { success } = require('../utils/apiResponse');
const staffService = require('../services/staff.service');

async function listAvailableStaff(req, res, next) {
  try {
    const staff = await staffService.listAvailableStaffWithWorkload({
      departmentId: req.query.departmentId,
    });
    return success(res, { message: 'Staff retrieved', data: staff });
  } catch (err) {
    next(err);
  }
}

module.exports = { listAvailableStaff };

