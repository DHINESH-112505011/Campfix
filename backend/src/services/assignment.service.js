const assignmentRepository = require('../repositories/assignment.repository');
const complaintRepository = require('../repositories/complaint.repository');
const { AppError } = require('./complaint.service');

async function assignStaff({ complaintId, staffId, adminProfile, notes }) {
  const complaint = await complaintRepository.findById(complaintId);
  if (!complaint) throw new AppError('Complaint not found.', 404, 'NOT_FOUND');

  const existingActive = await assignmentRepository.findActiveByComplaintId(complaintId);
  if (existingActive) {
    throw new AppError(
      'This complaint already has an active assignment. Use reassign instead.',
      400,
      'ALREADY_ASSIGNED'
    );
  }

  const assignment = await assignmentRepository.createAssignment({
    complaintId,
    staffId,
    assignedBy: adminProfile.id,
    notes,
  });

  await complaintRepository.updateComplaint(complaintId, { status: 'ASSIGNED' });

  return assignment;
}

async function reassignStaff({ complaintId, newStaffId, adminProfile, notes }) {
  const complaint = await complaintRepository.findById(complaintId);
  if (!complaint) throw new AppError('Complaint not found.', 404, 'NOT_FOUND');

  const existingActive = await assignmentRepository.findActiveByComplaintId(complaintId);
  if (existingActive) {
    await assignmentRepository.updateStatus(existingActive.id, { status: 'REASSIGNED' });
  }

  const newAssignment = await assignmentRepository.createAssignment({
    complaintId,
    staffId: newStaffId,
    assignedBy: adminProfile.id,
    notes,
  });

  await complaintRepository.updateComplaint(complaintId, { status: 'ASSIGNED' });

  return newAssignment;
}
async function listMyAssignments({ staffProfile, status }) {
  return assignmentRepository.findByStaffId(staffProfile.id, { status });
}

async function acceptAssignment({ assignmentId, staffProfile }) {
  const assignment = await assignmentRepository.findById(assignmentId);
  if (!assignment) throw new AppError('Assignment not found.', 404, 'NOT_FOUND');
  if (assignment.staff_id !== staffProfile.id) {
    throw new AppError('This assignment does not belong to you.', 403, 'FORBIDDEN');
  }
  if (assignment.status !== 'ASSIGNED') {
    throw new AppError('This assignment has already been actioned.', 400, 'INVALID_STATE');
  }

  const updated = await assignmentRepository.updateStatus(assignmentId, {
    status: 'ACCEPTED',
    accepted_at: new Date().toISOString(),
  });

  await complaintRepository.updateComplaint(assignment.complaint_id, { status: 'ACCEPTED' });

  return updated;
}

async function startWork({ assignmentId, staffProfile }) {
  const assignment = await assignmentRepository.findById(assignmentId);
  if (!assignment) throw new AppError('Assignment not found.', 404, 'NOT_FOUND');
  if (assignment.staff_id !== staffProfile.id) {
    throw new AppError('This assignment does not belong to you.', 403, 'FORBIDDEN');
  }
  if (assignment.status !== 'ACCEPTED') {
    throw new AppError('You must accept the assignment before starting work.', 400, 'INVALID_STATE');
  }

  const updated = await assignmentRepository.updateStatus(assignmentId, { status: 'IN_PROGRESS' });
  await complaintRepository.updateComplaint(assignment.complaint_id, { status: 'IN_PROGRESS' });

  return updated;
}

async function markCompleted({ assignmentId, staffProfile, notes }) {
  const assignment = await assignmentRepository.findById(assignmentId);
  if (!assignment) throw new AppError('Assignment not found.', 404, 'NOT_FOUND');
  if (assignment.staff_id !== staffProfile.id) {
    throw new AppError('This assignment does not belong to you.', 403, 'FORBIDDEN');
  }
  if (assignment.status !== 'IN_PROGRESS') {
    throw new AppError('Work must be in progress before it can be marked completed.', 400, 'INVALID_STATE');
  }

  const updated = await assignmentRepository.updateStatus(assignmentId, {
    status: 'COMPLETED',
    completed_at: new Date().toISOString(),
    notes: notes || assignment.notes,
  });

  // Staff cannot directly resolve - goes to admin verification (§28)
  await complaintRepository.updateComplaint(assignment.complaint_id, { status: 'WORK_COMPLETED' });

  return updated;
}

module.exports = {
  listMyAssignments,
  acceptAssignment,
  startWork,
  markCompleted,
  assignStaff,
  reassignStaff,
};