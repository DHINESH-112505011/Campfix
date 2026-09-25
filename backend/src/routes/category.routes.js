const express = require('express');
const { requireAuth } = require('../middleware/auth.middleware');
const { listCategories } = require('../controllers/category.controller');

const router = express.Router();

router.use(requireAuth);
router.get('/', listCategories);

module.exports = router;