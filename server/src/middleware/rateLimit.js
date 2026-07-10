const rateLimit = require('express-rate-limit');
const config = require('../config/environment');
const logger = require('../utils/logger');

/**
 * General API rate limiter
 */
const apiLimiter = rateLimit({
  windowMs: config.rateLimit.windowMs,
  max: config.rateLimit.maxRequests,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn('Rate limit exceeded', {
      ip: req.ip,
      path: req.path,
    });
    res.status(429).json({
      success: false,
      error: {
        code: 'RATE_LIMITED',
        message: 'Too many requests. Please try again later.',
      },
    });
  },
});

/**
 * Strict rate limiter for auth endpoints
 */
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn('Auth rate limit exceeded', { ip: req.ip });
    res.status(429).json({
      success: false,
      error: {
        code: 'AUTH_RATE_LIMITED',
        message: 'Too many authentication attempts. Please try again later.',
      },
    });
  },
});

/**
 * Socket.IO rate limiter (in-memory)
 * Tracks message rates per socket for anti-spam.
 */
class SocketRateLimiter {
  constructor(maxMessages = 10, windowMs = 3000) {
    this.maxMessages = maxMessages;
    this.windowMs = windowMs;
    this.clients = new Map();
  }

  /**
   * Check if a socket has exceeded its rate limit.
   * @param {string} socketId
   * @returns {boolean} true if rate-limited
   */
  isRateLimited(socketId) {
    const now = Date.now();
    if (!this.clients.has(socketId)) {
      this.clients.set(socketId, [now]);
      return false;
    }

    const timestamps = this.clients.get(socketId);
    // Remove old timestamps outside the window
    const filtered = timestamps.filter((t) => now - t < this.windowMs);
    filtered.push(now);
    this.clients.set(socketId, filtered);

    return filtered.length > this.maxMessages;
  }

  /**
   * Remove a client from tracking (on disconnect)
   */
  removeClient(socketId) {
    this.clients.delete(socketId);
  }

  /**
   * Clean up stale entries periodically
   */
  cleanup() {
    const now = Date.now();
    for (const [socketId, timestamps] of this.clients.entries()) {
      const filtered = timestamps.filter((t) => now - t < this.windowMs);
      if (filtered.length === 0) {
        this.clients.delete(socketId);
      } else {
        this.clients.set(socketId, filtered);
      }
    }
  }
}

// Create instances for different socket event types
const chatRateLimiter = new SocketRateLimiter(5, 3000); // 5 msgs per 3s
const drawRateLimiter = new SocketRateLimiter(60, 1000); // 60 draw events per 1s
const guessRateLimiter = new SocketRateLimiter(5, 3000); // 5 guesses per 3s

module.exports = {
  apiLimiter,
  authLimiter,
  SocketRateLimiter,
  chatRateLimiter,
  drawRateLimiter,
  guessRateLimiter,
};
