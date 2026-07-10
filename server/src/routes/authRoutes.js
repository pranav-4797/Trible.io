const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const { authenticateJWT } = require('../middleware/auth');
const { authLimiter } = require('../middleware/rateLimit');
const { validateBody, schemas } = require('../middleware/validation');

// Public routes
router.post('/register', authLimiter, validateBody(schemas.register), authController.register);
router.post('/login', authLimiter, validateBody(schemas.login), authController.login);

// Protected routes
router.get('/me', authenticateJWT, authController.getProfile);
router.patch('/profile', authenticateJWT, validateBody(schemas.updateProfile), authController.updateProfile);

module.exports = router;
