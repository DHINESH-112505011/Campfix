const supabaseAdmin = require('../config/supabaseClient');
const { error: errorResponse } = require('../utils/apiResponse');

/**
 * Verifies the Supabase JWT sent by the Flutter app (Authorization: Bearer <token>),
 * then looks up the REAL profile/role from the database. Never trusts any role
 * value the client might send in the request body (§71).
 */
async function requireAuth(req, res, next) {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;

    if (!token) {
      return errorResponse(res, {
        message: 'Authentication required.',
        code: 'UNAUTHORIZED',
        statusCode: 401,
      });
    }

    const { data: userData, error: userError } = await supabaseAdmin.auth.getUser(token);
    if (userError || !userData?.user) {
      return errorResponse(res, {
        message: 'Invalid or expired session. Please log in again.',
        code: 'UNAUTHORIZED',
        statusCode: 401,
      });
    }

    const { data: profile, error: profileError } = await supabaseAdmin
      .from('profiles')
      .select('id, auth_user_id, full_name, email, role, department_id, is_active')
      .eq('auth_user_id', userData.user.id)
      .single();

    if (profileError || !profile) {
      return errorResponse(res, {
        message: 'User profile not found.',
        code: 'PROFILE_NOT_FOUND',
        statusCode: 404,
      });
    }

    if (!profile.is_active) {
      return errorResponse(res, {
        message: 'This account has been disabled.',
        code: 'ACCOUNT_DISABLED',
        statusCode: 403,
      });
    }

    req.authUser = { authUserId: userData.user.id };
    req.profile = profile; // real, DB-verified role - always use this, never req.body.role
    next();
  } catch (err) {
    next(err);
  }
}

/**
 * Restricts a route to specific roles. Must run AFTER requireAuth.
 */
function requireRole(...allowedRoles) {
  return (req, res, next) => {
    if (!req.profile || !allowedRoles.includes(req.profile.role)) {
      return errorResponse(res, {
        message: 'You do not have permission to perform this action.',
        code: 'FORBIDDEN',
        statusCode: 403,
      });
    }
    next();
  };
}

module.exports = { requireAuth, requireRole };