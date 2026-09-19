const complaintRepository = require('../repositories/complaint.repository');
const { validateStatusTransition } = require('../validators/complaint.validator');

class AppError extends Error {
  constructor(message, statusCode = 400, code = 'BAD_REQUEST') {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
  }
}

async function createComplaint({ studentProfile, body }) {
  const payload = {
    student_id: studentProfile.id,
    category_id: body.categoryId || null,
    department_id: body.departmentId || null,
    title: body.title.trim(),
    description: body.description.trim(),
    priority: body.priority || 'MEDIUM',
    ai_category: body.aiCategory || null,
    ai_priority: body.aiPriority || null,
    ai_confidence: body.aiConfidence || null,
    campus: body.campus || 'Main Campus',
    building: body.building.trim(),
    block: body.block || null,
    floor: body.floor || null,
    room: body.room.trim(),
    specific_location: body.specificLocation || null,
  };

  return complaintRepository.createComplaint(payload);
}

async function getComplaintById({ id, profile }) {
  const complaint = await complaintRepository.findById(id);
  if (!complaint) {
    throw new AppError('Complaint not found.', 404, 'NOT_FOUND');
  }

  // Defense in depth: even though RLS protects direct DB access, the
  // backend (using service role) must also enforce scoping explicitly,
  // since service role bypasses RLS.
  const isOwner = complaint.student_id === profile.id;
  const isPrivileged = ['ADMIN', 'SUPER_ADMIN'].includes(profile.role);

  if (!isOwner && !isPrivileged && profile.role !== 'STAFF') {
    throw new AppError('You do not have access to this complaint.', 403, 'FORBIDDEN');
  }
  // Staff scoping (only assigned complaints) is enforced at the route/query
  // level via findAssignedToStaff - a STAFF profile reaching this function
  // via getById is further checked by the controller for assignment.

  return complaint;
}

async function listMyComplaints({ profile, pagination }) {
  return complaintRepository.findByStudentId(profile.id, pagination);
}

async function listAllComplaints({ filters, pagination }) {
  return complaintRepository.findAll({ ...filters, ...pagination });
}

async function listAssignedComplaints({ profile, pagination }) {
  return complaintRepository.findAssignedToStaff(profile.id, pagination);
}

async function updateComplaintStatus({ id, newStatus, actorProfile }) {
  const complaint = await complaintRepository.findById(id);
  if (!complaint) {
    throw new AppError('Complaint not found.', 404, 'NOT_FOUND');
  }

  const transitionError = validateStatusTransition(complaint.status, newStatus);
  if (transitionError) {
    throw new AppError(transitionError, 400, 'INVALID_TRANSITION');
  }

  // Students may only cancel or reopen their own complaint (§7 - cannot
  // arbitrarily change status); staff/admin get broader allowed transitions
  // via validateStatusTransition, but role-appropriateness is checked here.
  const studentAllowedTargets = ['CANCELLED', 'REOPENED'];
  if (actorProfile.role === 'STUDENT') {
    if (complaint.student_id !== actorProfile.id) {
      throw new AppError('You do not have access to this complaint.', 403, 'FORBIDDEN');
    }
    if (!studentAllowedTargets.includes(newStatus)) {
      throw new AppError('Students cannot set this status.', 403, 'FORBIDDEN');
    }
  }

  return complaintRepository.updateComplaint(id, { status: newStatus });
}

async function updateComplaintDetails({ id, updates, actorProfile }) {
  if (!['ADMIN', 'SUPER_ADMIN'].includes(actorProfile.role)) {
    throw new AppError('Only administrators can edit complaint details.', 403, 'FORBIDDEN');
  }
  const allowedFields = ['priority', 'category_id', 'department_id'];
  const sanitized = {};
  for (const key of allowedFields) {
    if (key in updates) sanitized[key] = updates[key];
  }
  return complaintRepository.updateComplaint(id, sanitized);
}

async function getComplaintTimeline({ id, profile }) {
  // Reuses the same access check as getComplaintById to avoid duplicating
  // the ownership/role logic.
  await getComplaintById({ id, profile });
  return complaintRepository.getTimeline(id);
}

module.exports = {
  AppError,
  createComplaint,
  getComplaintById,
  listMyComplaints,
  listAllComplaints,
  listAssignedComplaints,
  updateComplaintStatus,
  updateComplaintDetails,
  getComplaintTimeline,
};