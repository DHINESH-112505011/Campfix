const { error: errorResponse } = require('../utils/apiResponse');

function errorHandler(err, req, res, next) {
  console.error(`[ERROR] ${req.method} ${req.originalUrl}:`, err);

  const statusCode = err.statusCode || 500;
  const code = err.code || 'INTERNAL_ERROR';
  const message = statusCode < 500
    ? err.message
    : 'Something went wrong on our end. Please try again.';

  return errorResponse(res, { message, code, statusCode });
}

function notFoundHandler(req, res) {
  return errorResponse(res, {
    message: 'The requested resource was not found.',
    code: 'NOT_FOUND',
    statusCode: 404,
  });
}

module.exports = { errorHandler, notFoundHandler };