const multer = require('multer');
const { success } = require('../utils/apiResponse');
const uploadService = require('../services/upload.service');

// Store in memory - we stream the buffer directly to Cloudinary,
// never touching the server's disk (simpler, no cleanup needed).
const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB, matches service-layer check
});

const uploadMiddleware = upload.single('image');

async function uploadComplaintImage(req, res, next) {
  try {
    const { complaintId, imageType } = req.body;
    if (!complaintId) {
      return res.status(400).json({
        success: false,
        message: 'complaintId is required.',
        error: { code: 'VALIDATION_ERROR' },
      });
    }

    const imageRecord = await uploadService.uploadComplaintImage({
      file: req.file,
      complaintId,
      uploaderProfile: req.profile,
      imageType,
    });

    return success(res, {
      message: 'Image uploaded successfully',
      data: imageRecord,
      statusCode: 201,
    });
  } catch (err) {
    next(err);
  }
}

module.exports = { uploadMiddleware, uploadComplaintImage };