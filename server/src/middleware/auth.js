const jwt = require('jsonwebtoken');
const config = require('../config/environment');
const { getAuth } = require('../config/firebase');
const logger = require('../utils/logger');
const { AuthenticationError } = require('../utils/errors');

/**
 * Express middleware: Verify JWT token from Authorization header.
 * Attaches decoded user to req.user.
 */
async function authenticateJWT(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AuthenticationError('No token provided');
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, config.jwt.secret);
    req.user = decoded;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        error: { code: 'TOKEN_EXPIRED', message: 'Token has expired' },
      });
    }
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        error: { code: 'INVALID_TOKEN', message: 'Invalid token' },
      });
    }
    return res.status(401).json({
      success: false,
      error: { code: 'AUTH_ERROR', message: error.message },
    });
  }
}

/**
 * Express middleware: Verify Firebase ID token.
 * Alternative to JWT for direct Firebase auth.
 */
async function authenticateFirebase(req, res, next) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new AuthenticationError('No token provided');
    }

    const token = authHeader.split(' ')[1];
    const auth = getAuth();

    if (!auth) {
      // Firebase not configured — allow through in dev mode
      if (!config.isProduction) {
        req.user = { uid: 'dev-user', email: 'dev@test.com' };
        return next();
      }
      throw new AuthenticationError('Authentication service unavailable');
    }

    const decodedToken = await auth.verifyIdToken(token);
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      name: decodedToken.name,
      picture: decodedToken.picture,
    };
    next();
  } catch (error) {
    logger.error('Firebase auth error', { error: error.message });
    return res.status(401).json({
      success: false,
      error: { code: 'AUTH_ERROR', message: 'Invalid or expired token' },
    });
  }
}

/**
 * Socket.IO middleware: Authenticate socket connections.
 * Verifies JWT from handshake auth.
 */
function authenticateSocket(socket, next) {
  try {
    const token = socket.handshake.auth?.token;
    if (!token) {
      return next(new AuthenticationError('No token provided'));
    }

    const decoded = jwt.verify(token, config.jwt.secret);
    socket.user = decoded;
    logger.debug(`Socket authenticated: ${decoded.uid}`);
    next();
  } catch (error) {
    logger.error('Socket auth error', { error: error.message });
    next(new AuthenticationError('Authentication failed'));
  }
}

/**
 * Generate a JWT token for a user.
 */
function generateToken(user) {
  return jwt.sign(
    {
      uid: user.uid,
      username: user.username,
      avatar: user.avatar,
    },
    config.jwt.secret,
    { expiresIn: config.jwt.expiresIn }
  );
}

module.exports = {
  authenticateJWT,
  authenticateFirebase,
  authenticateSocket,
  generateToken,
};
