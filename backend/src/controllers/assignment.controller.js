const { success } = require('../utils/apiResponse');
const assignmentService = require('../services/assignment.service');

async function listMyAssignments(req, res, next) {
  try {
    const assignments = await assignmentService.listMyAssignments({
      staffProfile: req.profile,
      status: req.query.status,
    });
    return success(res, { message: 'Assignments retrieved', data: assignments });
  } catch (err) {
    next(err);
  }
}

async function acceptAssignment(req, res, next) {
  try {
    const updated = await assignmentService.acceptAssignment({
      assignmentId: req.params.id,
      staffProfile: req.profile,
    });
    return success(res, { message: 'Assignment accepted', data: updated });
  } catch (err) {
    next(err);
  }
}

async function startWork(req, res, next) {
  try {
    const updated = await assignmentService.startWork({
      assignmentId: req.params.id,
      staffProfile: req.profile,
    });
    return success(res, { message: 'Work started', data: updated });
  } catch (err) {
    next(err);
  }
}

async function markCompleted(req, res, next) {
  try {
    const updated = await assignmentService.markCompleted({
      assignmentId: req.params.id,
      staffProfile: req.profile,
      notes: req.body.notes,
    });
    return success(res, { message: 'Work marked as completed', data: updated });
  } catch (err) {
    next(err);
  }
}

async function assignStaff(req, res, next) {
  try {
    const { complaintId, staffId, notes } = req.body;
    const assignment = await assignmentService.assignStaff({
      complaintId,
      staffId,
      adminProfile: req.profile,
      notes,
    });
    return success(res, { message: 'Staff assigned successfully', data: assignment, statusCode: 201 });
  } catch (err) {
    next(err);
  }
}

async function reassignStaff(req, res, next) {
  try {
    const { complaintId, newStaffId, notes } = req.body;
    const assignment = await assignmentService.reassignStaff({
      complaintId,
      newStaffId,
      adminProfile: req.profile,
      notes,
    });
    return success(res, { message: 'Staff reassigned successfully', data: assignment, statusCode: 201 });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  listMyAssignments,
  acceptAssignment,
  startWork,
  markCompleted,
  assignStaff,
  reassignStaff,
};