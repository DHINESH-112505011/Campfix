const express = require('express');
const { requireAuth } = require('../middleware/auth.middleware');
const { uploadMiddleware, uploadComplaintImage } = require('../controllers/upload.controller');

const router = express.Router();

router.use(requireAuth);

router.post('/complaint-image', uploadMiddleware, uploadComplaintImage);

module.exports = router;