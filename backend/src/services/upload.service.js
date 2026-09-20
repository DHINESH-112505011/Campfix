const cloudinary = require('../config/cloudinaryClient');
const complaintImageRepository = require('../repositories/complaintImage.repository');
const complaintRepository = require('../repositories/complaint.repository');
const { AppError } = require('./complaint.service');

const MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024; // 5MB
const ALLOWED_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp'];

function validateFile(file) {
  if (!file) {
    throw new AppError('No image file provided.', 400, 'VALIDATION_ERROR');
  }
  if (!ALLOWED_MIME_TYPES.includes(file.mimetype)) {
    throw new AppError('Only JPEG, PNG, or WEBP images are allowed.', 400, 'INVALID_FILE_TYPE');
  }
  if (file.size > MAX_FILE_SIZE_BYTES) {
    throw new AppError('Image must be smaller than 5MB.', 400, 'FILE_TOO_LARGE');
  }
}

function uploadBufferToCloudinary(buffer, folder) {
  return new Promise((resolve, reject) => {
    const uploadStream = cloudinary.uploader.upload_stream(
      { folder, resource_type: 'image' },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      }
    );
    uploadStream.end(buffer);
  });
}

async function uploadComplaintImage({ file, complaintId, uploaderProfile, imageType }) {
  validateFile(file);

  const complaint = await complaintRepository.findById(complaintId);
  if (!complaint) {
    throw new AppError('Complaint not found.', 404, 'NOT_FOUND');
  }

  // Basic ownership/role check - students can only attach images to their
  // own complaints; staff/admin can attach completion images more broadly
  // (fully scoped assignment check lands alongside Phase 11/13 staff flows).
  const isOwner = complaint.student_id === uploaderProfile.id;
  const isPrivileged = ['ADMIN', 'SUPER_ADMIN', 'STAFF'].includes(uploaderProfile.role);
  if (!isOwner && !isPrivileged) {
    throw new AppError('You do not have permission to upload to this complaint.', 403, 'FORBIDDEN');
  }

  const folder = `campfix/complaints/${complaintId}`;
  const result = await uploadBufferToCloudinary(file.buffer, folder);

  const imageRecord = await complaintImageRepository.createComplaintImage({
    complaintId,
    uploadedBy: uploaderProfile.id,
    imageType: imageType || 'COMPLAINT',
    url: result.secure_url,
    publicId: result.public_id,
  });

  return imageRecord;
}

module.exports = { uploadComplaintImage };