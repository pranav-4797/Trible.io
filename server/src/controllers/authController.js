const { getAuth } = require('../config/firebase');
const { generateToken } = require('../middleware/auth');
const userService = require('../services/userService');
const logger = require('../utils/logger');
const { AuthenticationError, ValidationError } = require('../utils/errors');

/**
 * Register a new user or login existing user.
 * POST /api/auth/register
 */
async function register(req, res, next) {
  try {
    const { firebaseToken, username, avatar } = req.body;

    // Verify Firebase token
    const auth = getAuth();
    let firebaseUser;

    if (auth) {
      const decodedToken = await auth.verifyIdToken(firebaseToken);
      firebaseUser = {
        uid: decodedToken.uid,
        email: decodedToken.email || '',
        isAnonymous: !decodedToken.email,
      };
    } else {
      // Dev mode without Firebase
      firebaseUser = {
        uid: `dev-${Date.now()}`,
        email: '',
        isAnonymous: true,
      };
    }

    // Check if username is taken
    const existingUser = await userService.findByUsername(username);
    if (existingUser && existingUser.uid !== firebaseUser.uid) {
      throw new ValidationError('Username is already taken');
    }

    // Create or update user
    const user = await userService.createOrUpdate({
      uid: firebaseUser.uid,
      username,
      avatar,
      email: firebaseUser.email,
      isGuest: firebaseUser.isAnonymous,
    });

    // Generate JWT
    const token = generateToken(user);

    logger.info(`User registered: ${user.uid} (${user.username})`);

    res.status(201).json({
      success: true,
      data: { user, token },
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Login existing user with Firebase token.
 * POST /api/auth/login
 */
async function login(req, res, next) {
  try {
    const { firebaseToken } = req.body;

    const auth = getAuth();
    let uid;

    if (auth) {
      const decodedToken = await auth.verifyIdToken(firebaseToken);
      uid = decodedToken.uid;
    } else {
      throw new AuthenticationError('Authentication service unavailable');
    }

    const user = await userService.findByUid(uid);
    if (!user) {
      return res.status(404).json({
        success: false,
        error: { code: 'USER_NOT_FOUND', message: 'User profile not found' },
      });
    }

    // Update online status
    await userService.updateOnlineStatus(uid, true);

    // Generate JWT
    const token = generateToken(user);

    logger.info(`User logged in: ${uid} (${user.username})`);

    res.json({
      success: true,
      data: { user, token },
    });
  } catch (error) {
    next(error);
  }
}

/**
 * Get current user profile.
 * GET /api/auth/me
 */
async function getProfile(req, res, next) {
  try {
    const { uid } = req.user;
    const user = await userService.findByUid(uid);

    if (!user) {
      return res.status(404).json({
        success: false,
        error: { code: 'USER_NOT_FOUND', message: 'User profile not found' },
      });
    }

    res.json({ success: true, data: { user } });
  } catch (error) {
    next(error);
  }
}

/**
 * Update user profile.
 * PATCH /api/auth/profile
 */
async function updateProfile(req, res, next) {
  try {
    const { uid } = req.user;
    const updates = req.body;

    // If username change, check availability
    if (updates.username) {
      const existing = await userService.findByUsername(updates.username);
      if (existing && existing.uid !== uid) {
        throw new ValidationError('Username is already taken');
      }
    }

    const user = await userService.update(uid, updates);

    res.json({ success: true, data: { user } });
  } catch (error) {
    next(error);
  }
}

module.exports = { register, login, getProfile, updateProfile };
