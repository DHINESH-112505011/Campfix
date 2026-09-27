const { success } = require('../utils/apiResponse');
const complaintService = require('../services/complaint.service');
const { validateCreateComplaint } = require('../validators/complaint.validator');

function parsePagination(query) {
  const limit = Math.min(parseInt(query.limit, 10) || 20, 100);
  const page = Math.max(parseInt(query.page, 10) || 1, 1);
  const offset = (page - 1) * limit;
  return { limit, offset, page };
}

async function createComplaint(req, res, next) {
  try {
    const errors = validateCreateComplaint(req.body);
    if (errors.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Please check your complaint details and try again.',
        error: { code: 'VALIDATION_ERROR', details: errors },
      });
    }

    const complaint = await complaintService.createComplaint({
      studentProfile: req.profile,
      body: req.body,
    });

    return success(res, {
      message: 'Complaint created successfully',
      data: complaint,
      statusCode: 201,
    });
  } catch (err) {
    next(err);
  }
}

async function getComplaintById(req, res, next) {
  try {
    const complaint = await complaintService.getComplaintById({
      id: req.params.id,
      profile: req.profile,
    });
    return success(res, { message: 'Complaint retrieved', data: complaint });
  } catch (err) {
    next(err);
  }
}

async function listComplaints(req, res, next) {
  try {
    const pagination = parsePagination(req.query);
    const filters = {
      status: req.query.status,
      priority: req.query.priority,
      categoryId: req.query.categoryId,
      search: req.query.search,
      dateFrom: req.query.dateFrom,
      dateTo: req.query.dateTo,
    };
    let result;

    if (req.profile.role === 'STUDENT') {
      result = await complaintService.listMyComplaints({ profile: req.profile, pagination, filters });
    } else if (req.profile.role === 'STAFF') {
      result = await complaintService.listAssignedComplaints({ profile: req.profile, pagination });
    } else {
      result = await complaintService.listAllComplaints({ filters, pagination });
    }

    return success(res, {
      message: 'Complaints retrieved',
      data: {
        items: result.data,
        total: result.total,
        page: pagination.page,
        limit: pagination.limit,
      },
    });
  } catch (err) {
    next(err);
  }
}

async function updateComplaintStatus(req, res, next) {
  try {
    const { status } = req.body;
    if (!status) {
      return res.status(400).json({
        success: false,
        message: 'Status is required.',
        error: { code: 'VALIDATION_ERROR' },
      });
    }

    const updated = await complaintService.updateComplaintStatus({
      id: req.params.id,
      newStatus: status,
      actorProfile: req.profile,
    });

    return success(res, { message: 'Complaint status updated', data: updated });
  } catch (err) {
    next(err);
  }
}

async function updateComplaintDetails(req, res, next) {
  try {
    const updated = await complaintService.updateComplaintDetails({
      id: req.params.id,
      updates: req.body,
      actorProfile: req.profile,
    });
    return success(res, { message: 'Complaint updated', data: updated });
  } catch (err) {
    next(err);
  }
}

async function getComplaintTimeline(req, res, next) {
  try {
    const timeline = await complaintService.getComplaintTimeline({
      id: req.params.id,
      profile: req.profile,
    });
    return success(res, { message: 'Timeline retrieved', data: timeline });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  createComplaint,
  getComplaintById,
  listComplaints,
  updateComplaintStatus,
  updateComplaintDetails,
  getComplaintTimeline,
};