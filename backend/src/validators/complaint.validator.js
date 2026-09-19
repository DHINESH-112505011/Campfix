function validateCreateComplaint(body) {
  const errors = [];

  if (!body.title || typeof body.title !== 'string' || body.title.trim().length < 3) {
    errors.push('Title must be at least 3 characters.');
  }
  if (!body.description || typeof body.description !== 'string' || body.description.trim().length < 5) {
    errors.push('Description must be at least 5 characters.');
  }
  if (!body.building || typeof body.building !== 'string' || body.building.trim().length === 0) {
    errors.push('Building is required.');
  }
  if (!body.room || typeof body.room !== 'string' || body.room.trim().length === 0) {
    errors.push('Room is required.');
  }
  if (body.priority && !['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].includes(body.priority)) {
    errors.push('Invalid priority value.');
  }

  return errors;
}

const VALID_STATUSES = [
  'SUBMITTED', 'AI_CLASSIFIED', 'ADMIN_REVIEW', 'ASSIGNED', 'ACCEPTED',
  'IN_PROGRESS', 'WORK_COMPLETED', 'ADMIN_VERIFIED', 'RESOLVED',
  'REJECTED', 'CANCELLED', 'ON_HOLD', 'REOPENED',
];

// Controlled status transitions (§24) - prevents arbitrary jumps like
// SUBMITTED -> RESOLVED with nothing in between.
const ALLOWED_TRANSITIONS = {
  SUBMITTED: ['AI_CLASSIFIED', 'ADMIN_REVIEW', 'CANCELLED'],
  AI_CLASSIFIED: ['ADMIN_REVIEW', 'CANCELLED'],
  ADMIN_REVIEW: ['ASSIGNED', 'REJECTED', 'ON_HOLD', 'CANCELLED'],
  ASSIGNED: ['ACCEPTED', 'ON_HOLD', 'CANCELLED'],
  ACCEPTED: ['IN_PROGRESS', 'ON_HOLD'],
  IN_PROGRESS: ['WORK_COMPLETED', 'ON_HOLD'],
  WORK_COMPLETED: ['ADMIN_VERIFIED', 'IN_PROGRESS'],
  ADMIN_VERIFIED: ['RESOLVED'],
  RESOLVED: ['REOPENED'],
  REOPENED: ['ADMIN_REVIEW', 'ASSIGNED'],
  ON_HOLD: ['ADMIN_REVIEW', 'ASSIGNED', 'IN_PROGRESS'],
  REJECTED: [],
  CANCELLED: [],
};

function validateStatusTransition(currentStatus, newStatus) {
  if (!VALID_STATUSES.includes(newStatus)) {
    return `"${newStatus}" is not a valid status.`;
  }
  const allowed = ALLOWED_TRANSITIONS[currentStatus] || [];
  if (!allowed.includes(newStatus)) {
    return `Cannot change status from "${currentStatus}" to "${newStatus}".`;
  }
  return null;
}

module.exports = { validateCreateComplaint, validateStatusTransition, VALID_STATUSES };