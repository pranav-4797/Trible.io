const http = require('http');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const compression = require('compression');

const config = require('./config/environment');
const { initializeFirebase } = require('./config/firebase');
const { createSocketServer } = require('./config/socket');
const { authenticateSocket } = require('./middleware/auth');
const { apiLimiter } = require('./middleware/rateLimit');
const logger = require('./utils/logger');

// Import route handlers
const authRoutes = require('./routes/authRoutes');
const roomRoutes = require('./routes/roomRoutes');
const leaderboardRoutes = require('./routes/leaderboardRoutes');

// Import socket handlers
const roomHandler = require('./socket/roomHandler');
const gameHandler = require('./socket/gameHandler');
const drawingHandler = require('./socket/drawingHandler');
const chatHandler = require('./socket/chatHandler');

// Import services
const { RoomManager } = require('./services/roomService');

// ─── Initialize Firebase ───
initializeFirebase();

// ─── Express App ───
const app = express();
const server = http.createServer(app);

// ─── Middleware ───
app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors({ origin: config.cors.origin, credentials: true }));
app.use(compression());
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(apiLimiter);

// Request logging
if (config.isProduction) {
  app.use(morgan('combined', {
    stream: { write: (msg) => logger.info(msg.trim()) },
  }));
} else {
  app.use(morgan('dev'));
}

// ─── Health Check ───
app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    version: '1.0.0',
    rooms: RoomManager.getRoomCount(),
    players: RoomManager.getPlayerCount(),
  });
});

// ─── API Routes ───
app.use('/api/auth', authRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/leaderboard', leaderboardRoutes);

// ─── 404 Handler ───
app.use((req, res) => {
  res.status(404).json({
    success: false,
    error: { code: 'NOT_FOUND', message: `Route ${req.method} ${req.path} not found` },
  });
});

// ─── Error Handler ───
app.use((err, req, res, _next) => {
  logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  });

  const statusCode = err.statusCode || 500;
  res.status(statusCode).json({
    success: false,
    error: {
      code: err.code || 'INTERNAL_ERROR',
      message: config.isProduction && statusCode === 500
        ? 'Internal server error'
        : err.message,
    },
  });
});

// ─── Socket.IO ───
const io = createSocketServer(server);

// Socket authentication middleware
io.use(authenticateSocket);

// Socket connection handler
io.on('connection', (socket) => {
  logger.info(`Player connected: ${socket.user?.uid || 'unknown'}`, {
    socketId: socket.id,
    username: socket.user?.username,
  });

  // Register all socket event handlers
  roomHandler(io, socket);
  gameHandler(io, socket);
  drawingHandler(io, socket);
  chatHandler(io, socket);

  // Handle disconnect
  socket.on('disconnect', (reason) => {
    logger.info(`Player disconnected: ${socket.user?.uid || 'unknown'}`, {
      socketId: socket.id,
      reason,
    });
    RoomManager.handleDisconnect(socket);
  });

  // Handle errors
  socket.on('error', (error) => {
    logger.error('Socket error', {
      socketId: socket.id,
      error: error.message,
    });
  });
});

// ─── Room Cleanup Interval ───
setInterval(() => {
  const cleaned = RoomManager.cleanupEmptyRooms();
  if (cleaned > 0) {
    logger.info(`Cleaned up ${cleaned} empty rooms`);
  }
}, config.game.roomCleanupInterval);

// ─── Start Server ───
server.listen(config.port, () => {
  logger.info(`🎮 Trible server running on port ${config.port}`, {
    env: config.nodeEnv,
    pid: process.pid,
  });
});

// ─── Graceful Shutdown ───
const shutdown = (signal) => {
  logger.info(`${signal} received. Shutting down gracefully...`);
  io.close(() => {
    logger.info('Socket.IO server closed');
    server.close(() => {
      logger.info('HTTP server closed');
      process.exit(0);
    });
  });
  // Force shutdown after 10 seconds
  setTimeout(() => {
    logger.error('Forced shutdown after timeout');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('uncaughtException', (error) => {
  logger.fatal('Uncaught exception', { error: error.message, stack: error.stack });
  process.exit(1);
});
process.on('unhandledRejection', (reason) => {
  logger.error('Unhandled rejection', { reason: reason?.toString() });
});

module.exports = { app, server, io };
