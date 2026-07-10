const Joi = require('joi');
const { ValidationError } = require('../utils/errors');

/**
 * Express middleware factory: Validate request body against a Joi schema.
 * @param {Joi.ObjectSchema} schema
 */
function validateBody(schema) {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.body, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const details = error.details.map((d) => ({
        field: d.path.join('.'),
        message: d.message,
      }));
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid request data',
          details,
        },
      });
    }

    req.body = value;
    next();
  };
}

/**
 * Express middleware factory: Validate query parameters.
 */
function validateQuery(schema) {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.query, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const details = error.details.map((d) => ({
        field: d.path.join('.'),
        message: d.message,
      }));
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid query parameters',
          details,
        },
      });
    }

    req.query = value;
    next();
  };
}

/**
 * Express middleware factory: Validate URL params.
 */
function validateParams(schema) {
  return (req, res, next) => {
    const { error, value } = schema.validate(req.params, {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      const details = error.details.map((d) => ({
        field: d.path.join('.'),
        message: d.message,
      }));
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid URL parameters',
          details,
        },
      });
    }

    req.params = value;
    next();
  };
}

// ─── Validation Schemas ───

const schemas = {
  // Auth
  register: Joi.object({
    firebaseToken: Joi.string().required(),
    username: Joi.string().min(3).max(16).pattern(/^[a-zA-Z0-9_]+$/).required(),
    avatar: Joi.string().max(10).required(),
  }),

  login: Joi.object({
    firebaseToken: Joi.string().required(),
  }),

  updateProfile: Joi.object({
    username: Joi.string().min(3).max(16).pattern(/^[a-zA-Z0-9_]+$/),
    avatar: Joi.string().max(10),
  }),

  // Room
  createRoom: Joi.object({
    isPrivate: Joi.boolean().default(false),
    maxPlayers: Joi.number().integer().min(2).max(12).default(8),
    rounds: Joi.number().integer().min(1).max(10).default(3),
    drawTime: Joi.number().integer().min(30).max(180).default(80),
    difficulty: Joi.string().valid('easy', 'medium', 'hard').default('medium'),
    categories: Joi.array().items(Joi.string()).default([]),
  }),

  joinRoom: Joi.object({
    roomCode: Joi.string().length(6).pattern(/^[A-Z0-9]+$/).required(),
  }),

  roomSettings: Joi.object({
    maxPlayers: Joi.number().integer().min(2).max(12),
    rounds: Joi.number().integer().min(1).max(10),
    drawTime: Joi.number().integer().min(30).max(180),
    difficulty: Joi.string().valid('easy', 'medium', 'hard'),
    categories: Joi.array().items(Joi.string()),
    isPrivate: Joi.boolean(),
  }),

  // Chat
  chatMessage: Joi.object({
    message: Joi.string().max(100).required(),
    roomId: Joi.string().required(),
  }),

  // Game
  wordChoice: Joi.object({
    wordIndex: Joi.number().integer().min(0).max(2).required(),
  }),

  // Leaderboard
  leaderboardQuery: Joi.object({
    type: Joi.string().valid('global', 'weekly', 'monthly', 'friends').default('global'),
    limit: Joi.number().integer().min(1).max(100).default(50),
    offset: Joi.number().integer().min(0).default(0),
  }),

  // Friends
  friendRequest: Joi.object({
    targetUserId: Joi.string().required(),
  }),
};

/**
 * Validate socket event data.
 * @param {Joi.ObjectSchema} schema
 * @param {object} data
 * @throws {ValidationError}
 */
function validateSocketData(schema, data) {
  const { error, value } = schema.validate(data, {
    abortEarly: false,
    stripUnknown: true,
  });

  if (error) {
    const details = error.details.map((d) => d.message).join(', ');
    throw new ValidationError(`Validation failed: ${details}`);
  }

  return value;
}

module.exports = {
  validateBody,
  validateQuery,
  validateParams,
  validateSocketData,
  schemas,
};
