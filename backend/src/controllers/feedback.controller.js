const { success } = require('../utils/apiResponse');
const feedbackService = require('../services/feedback.service');

async function submitFeedback(req, res, next) {
  try {
    const { rating, resolvedSuccessfully, comment } = req.body;
    const feedback = await feedbackService.submitFeedback({
      complaintId: req.params.id,
      studentProfile: req.profile,
      rating,
      resolvedSuccessfully,
      comment,
    });
    return success(res, { message: 'Feedback submitted successfully', data: feedback, statusCode: 201 });
  } catch (err) {
    next(err);
  }
}

async function getFeedback(req, res, next) {
  try {
    const feedback = await feedbackService.getFeedback({ complaintId: req.params.id });
    return success(res, { message: 'Feedback retrieved', data: feedback });
  } catch (err) {
    next(err);
  }
}

module.exports = { submitFeedback, getFeedback };