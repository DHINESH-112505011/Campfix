const complaintRepository = require('../repositories/complaint.repository');
const { validateStatusTransition } = require('../validators/complaint.validator');
const { classifyComplaint } = require('./ai.service');
const notificationService = require('./notification.service');
const auditLogService = require('./auditLog.service');

class AppError extends Error {
  constructor(message, statusCode = 400, code = 'BAD_REQUEST') {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
  }
}

async function createComplaint({ studentProfile, body }) {
  const combinedText = `${body.title} ${body.description}`;
  const aiResult = await classifyComplaint(combinedText);

  const payload = {
    student_id: studentProfile.id,
    category_id: body.categoryId || null,
    department_id: body.departmentId || null,
    title: body.title.trim(),
    description: body.description.trim(),
    priority: aiResult.priority || body.priority || 'MEDIUM',
    ai_category: aiResult.category,
    ai_priority: aiResult.priority,
    ai_confidence: aiResult.confidence,
    campus: body.campus || 'Main Campus',
    building: body.building.trim(),
    block: body.block || null,
    floor: body.floor || null,
    room: body.room.trim(),
    specific_location: body.specificLocation || null,
  };

  const complaint = await complaintRepository.createComplaint(payload);

  notificationService.notifyUser({
    userId: studentProfile.id,
    title: 'Complaint Submitted',
    message: `Your complaint "${complaint.title}" has been submitted successfully.`,
    type: 'COMPLAINT_SUBMITTED',
    relatedComplaintId: complaint.id,
  });

  const notifyType = complaint.priority === 'CRITICAL' ? 'CRITICAL_COMPLAINT' : 'NEW_COMPLAINT';
  notificationService.notifyAllAdmins({
    title: complaint.priority === 'CRITICAL' ? 'Critical Complaint Submitted' : 'New Complaint Submitted',
    message: `"${complaint.title}" (${complaint.complaint_number}) needs review.`,
    type: notifyType,
    relatedComplaintId: complaint.id,
  });

  return complaint;
}

async function getComplaintById({ id, profile }) {
  const complaint = await complaintRepository.findById(id);
  if (!complaint) {
    throw new AppError('Complaint not found.', 404, 'NOT_FOUND');
  }

  const isOwner = complaint.student_id === profile.id;
  const isPrivileged = ['ADMIN', 'SUPER_ADMIN'].includes(profile.role);

  if (!isOwner && !isPrivileged && profile.role !== 'STAFF') {
    throw new AppError('You do not have access to this complaint.', 403, 'FORBIDDEN');
  }

  return complaint;
}

async function listMyComplaints({ profile, pagination, filters }) {
  return complaintRepository.findByStudentId(profile.id, { ...pagination, ...filters });
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

  const studentAllowedTargets = ['CANCELLED', 'REOPENED'];
  if (actorProfile.role === 'STUDENT') {
    if (complaint.student_id !== actorProfile.id) {
      throw new AppError('You do not have access to this complaint.', 403, 'FORBIDDEN');
    }
    if (!studentAllowedTargets.includes(newStatus)) {
      throw new AppError('Students cannot set this status.', 403, 'FORBIDDEN');
    }
  }

  const updated = await complaintRepository.updateComplaint(
    id,
    { status: newStatus },
    { userId: actorProfile.id, role: actorProfile.role }
  );

  if (newStatus === 'RESOLVED') {
    notificationService.notifyUser({
      userId: complaint.student_id,
      title: 'Complaint Resolved',
      message: `Your complaint "${complaint.title}" has been resolved.`,
      type: 'COMPLAINT_RESOLVED',
      relatedComplaintId: complaint.id,
    });
  } else if (newStatus === 'REOPENED') {
    notificationService.notifyAllAdmins({
      title: 'Complaint Reopened',
      message: `"${complaint.title}" (${complaint.complaint_number}) was reopened by the student.`,
      type: 'COMPLAINT_REOPENED',
      relatedComplaintId: complaint.id,
    });
  } else if (newStatus === 'REJECTED') {
    auditLogService.log({
      userId: actorProfile.id,
      action: 'COMPLAINT_REJECTED',
      entityType: 'complaint',
      entityId: id,
      oldValue: { status: complaint.status },
      newValue: { status: newStatus },
    });
  }

  return updated;
}

async function updateComplaintDetails({ id, updates, actorProfile }) {
  if (!['ADMIN', 'SUPER_ADMIN'].includes(actorProfile.role)) {
    throw new AppError('Only administrators can edit complaint details.', 403, 'FORBIDDEN');
  }

  const complaint = await complaintRepository.findById(id);
  if (!complaint) {
    throw new AppError('Complaint not found.', 404, 'NOT_FOUND');
  }

  const allowedFields = ['priority', 'category_id', 'department_id'];
  const sanitized = {};
  for (const key of allowedFields) {
    if (key in updates) sanitized[key] = updates[key];
  }

  const updated = await complaintRepository.updateComplaint(id, sanitized);

  // Audit log priority overrides specifically - matches §47's own example
  // (Priority: Medium -> High) and §91 (AI is advisory, admin has final say).
  if ('priority' in sanitized && sanitized.priority !== complaint.priority) {
    auditLogService.log({
      userId: actorProfile.id,
      action: 'PRIORITY_CHANGED',
      entityType: 'complaint',
      entityId: id,
      oldValue: { priority: complaint.priority },
      newValue: { priority: sanitized.priority },
    });
  }

  return updated;
}

async function getComplaintTimeline({ id, profile }) {
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