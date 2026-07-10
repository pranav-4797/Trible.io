require('dotenv').config();

const config = {
  port: parseInt(process.env.PORT, 10) || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  isProduction: process.env.NODE_ENV === 'production',

  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID,
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
    privateKey: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n'),
    databaseUrl: process.env.FIREBASE_DATABASE_URL,
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
  },

  jwt: {
    secret: process.env.JWT_SECRET || 'dev-secret-change-me',
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  },

  cors: {
    origin: process.env.CORS_ORIGIN || '*',
  },

  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS, 10) || 60000,
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS, 10) || 100,
  },

  socket: {
    pingInterval: parseInt(process.env.SOCKET_PING_INTERVAL, 10) || 25000,
    pingTimeout: parseInt(process.env.SOCKET_PING_TIMEOUT, 10) || 20000,
    maxBufferSize: parseInt(process.env.SOCKET_MAX_BUFFER_SIZE, 10) || 1000000,
  },

  game: {
    maxRooms: parseInt(process.env.MAX_ROOMS, 10) || 100,
    roomCleanupInterval: parseInt(process.env.ROOM_CLEANUP_INTERVAL, 10) || 300000,
  },
};

// Validate required config in production
if (config.isProduction) {
  const required = ['firebase.projectId', 'jwt.secret'];
  for (const key of required) {
    const keys = key.split('.');
    let value = config;
    for (const k of keys) {
      value = value?.[k];
    }
    if (!value || value === 'dev-secret-change-me') {
      throw new Error(`Missing required config: ${key}`);
    }
  }
}

module.exports = config;
