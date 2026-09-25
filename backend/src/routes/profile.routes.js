const express = require('express');
const { requireAuth } = require('../middleware/auth.middleware');
const { getMyProfile } = require('../controllers/profile.controller');

const router = express.Router();

router.use(requireAuth);
router.get('/me', getMyProfile);

module.exports = router;