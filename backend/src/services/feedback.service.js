const feedbackRepository = require('../repositories/feedback.repository');
const complaintRepository = require('../repositories/complaint.repository');
const { AppError } = require('./complaint.service');

async function submitFeedback({ complaintId, studentProfile, rating, resolvedSuccessfully, comment }) {
  const complaint = await complaintRepository.findById(complaintId);
  if (!complaint) throw new AppError('Complaint not found.', 404, 'NOT_FOUND');

  if (complaint.student_id !== studentProfile.id) {
    throw new AppError('You do not have access to this complaint.', 403, 'FORBIDDEN');
  }

  if (complaint.status !== 'RESOLVED') {
    throw new AppError('Feedback can only be given for resolved complaints.', 400, 'INVALID_STATE');
  }

  const existing = await feedbackRepository.findByComplaintId(complaintId);
  if (existing) {
    throw new AppError('Feedback has already been submitted for this complaint.', 400, 'ALREADY_EXISTS');
  }

  if (!rating || rating < 1 || rating > 5) {
    throw new AppError('Rating must be between 1 and 5.', 400, 'VALIDATION_ERROR');
  }

  return feedbackRepository.create({
    complaintId,
    studentId: studentProfile.id,
    rating,
    resolvedSuccessfully: !!resolvedSuccessfully,
    comment,
  });
}

async function getFeedback({ complaintId }) {
  return feedbackRepository.findByComplaintId(complaintId);
}

module.exports = { submitFeedback, getFeedback };