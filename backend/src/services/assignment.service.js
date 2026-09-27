const assignmentRepository = require('../repositories/assignment.repository');
const complaintRepository = require('../repositories/complaint.repository');
const notificationService = require('./notification.service');
const auditLogService = require('./auditLog.service');
const { AppError } = require('./complaint.service');

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
  const complaint = await complaintRepository.updateComplaint(assignment.complaint_id, { status: 'IN_PROGRESS' });

  notificationService.notifyUser({
    userId: complaint.student_id,
    title: 'Work Started',
    message: `Work has started on your complaint "${complaint.title}".`,
    type: 'WORK_STARTED',
    relatedComplaintId: complaint.id,
  });

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

  const complaint = await complaintRepository.updateComplaint(assignment.complaint_id, { status: 'WORK_COMPLETED' });

  notificationService.notifyUser({
    userId: complaint.student_id,
    title: 'Work Completed',
    message: `Work on your complaint "${complaint.title}" has been completed and is pending verification.`,
    type: 'COMPLAINT_COMPLETED',
    relatedComplaintId: complaint.id,
  });
  notificationService.notifyAllAdmins({
    title: 'Work Completed - Verification Needed',
    message: `"${complaint.title}" (${complaint.complaint_number}) is awaiting your verification.`,
    type: 'NEW_COMPLAINT',
    relatedComplaintId: complaint.id,
  });

  return updated;
}

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

  notificationService.notifyUser({
    userId: staffId,
    title: 'New Assignment',
    message: `You have been assigned to "${complaint.title}" (${complaint.complaint_number}).`,
    type: 'NEW_ASSIGNMENT',
    relatedComplaintId: complaintId,
  });

  if (complaint.priority === 'CRITICAL') {
    notificationService.notifyUser({
      userId: staffId,
      title: 'Urgent: Critical Complaint Assigned',
      message: `"${complaint.title}" is marked CRITICAL and needs immediate attention.`,
      type: 'URGENT_COMPLAINT',
      relatedComplaintId: complaintId,
    });
  }

  return assignment;
}

async function reassignStaff({ complaintId, newStaffId, adminProfile, notes }) {
  const complaint = await complaintRepository.findById(complaintId);
  if (!complaint) throw new AppError('Complaint not found.', 404, 'NOT_FOUND');

  const existingActive = await assignmentRepository.findActiveByComplaintId(complaintId);
  if (existingActive) {
    await assignmentRepository.updateStatus(existingActive.id, { status: 'REASSIGNED' });
    notificationService.notifyUser({
      userId: existingActive.staff_id,
      title: 'Assignment Changed',
      message: `You have been unassigned from "${complaint.title}" (${complaint.complaint_number}).`,
      type: 'ASSIGNMENT_CHANGED',
      relatedComplaintId: complaintId,
    });
  }

  const newAssignment = await assignmentRepository.createAssignment({
    complaintId,
    staffId: newStaffId,
    assignedBy: adminProfile.id,
    notes,
  });

  await complaintRepository.updateComplaint(complaintId, { status: 'ASSIGNED' });

  notificationService.notifyUser({
    userId: newStaffId,
    title: 'New Assignment',
    message: `You have been assigned to "${complaint.title}" (${complaint.complaint_number}).`,
    type: 'NEW_ASSIGNMENT',
    relatedComplaintId: complaintId,
  });

  // Audit log: reassignment is a sensitive action per §47 example
  auditLogService.log({
    userId: adminProfile.id,
    action: 'STAFF_REASSIGNED',
    entityType: 'complaint',
    entityId: complaintId,
    oldValue: existingActive ? { staff_id: existingActive.staff_id } : null,
    newValue: { staff_id: newStaffId },
  });

  return newAssignment;
}

module.exports = {
  listMyAssignments,
  acceptAssignment,
  startWork,
  markCompleted,
  assignStaff,
  reassignStaff,
};