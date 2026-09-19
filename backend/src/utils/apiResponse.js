function success(res, { message = 'Success', data = {}, statusCode = 200 } = {}) {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
}

function error(res, { message = 'Something went wrong', code = 'INTERNAL_ERROR', statusCode = 500 } = {}) {
  return res.status(statusCode).json({
    success: false,
    message,
    error: { code },
  });
}

module.exports = { success, error };