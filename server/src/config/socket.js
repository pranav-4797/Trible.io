const { Server } = require('socket.io');
const config = require('./environment');
const logger = require('../utils/logger');

/**
 * Create and configure Socket.IO server.
 * @param {import('http').Server} httpServer
 * @returns {import('socket.io').Server}
 */
function createSocketServer(httpServer) {
  const io = new Server(httpServer, {
    cors: {
      origin: config.cors.origin,
      methods: ['GET', 'POST'],
      credentials: true,
    },
    pingInterval: config.socket.pingInterval,
    pingTimeout: config.socket.pingTimeout,
    maxHttpBufferSize: config.socket.maxBufferSize,
    transports: ['websocket', 'polling'],
    allowUpgrades: true,
    perMessageDeflate: {
      threshold: 1024, // Only compress messages > 1KB
    },
    connectionStateRecovery: {
      maxDisconnectionDuration: 2 * 60 * 1000, // 2 minutes
      skipMiddlewares: false,
    },
  });

  // Connection logging
  io.engine.on('connection_error', (err) => {
    logger.error('Socket.IO connection error', {
      code: err.code,
      message: err.message,
      context: err.context,
    });
  });

  logger.info('Socket.IO server created', {
    pingInterval: config.socket.pingInterval,
    pingTimeout: config.socket.pingTimeout,
    maxBufferSize: config.socket.maxBufferSize,
  });

  return io;
}

module.exports = { createSocketServer };
